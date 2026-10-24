"""Snapshot Gemini Enterprise licence assignments into ge_user_licenses.

Each run replaces today's partition with the current state of every user
store, so the table holds one row per user per day. That makes "licensed but
never used" and licence-growth charts possible without a separate history job.
"""

from __future__ import annotations

import os
from collections.abc import Iterator
from datetime import UTC, date, datetime
from typing import Any

from google.auth.transport.requests import AuthorizedSession
from google.cloud import bigquery

from gemini_exporter.main import authorized_session, log_json, required_env

USER_STORE_ID = "default_user_store"
PAGE_SIZE = 500
LICENSES_TABLE = "ge_user_licenses"


def user_store_path(project_id: str, location: str) -> str:
    return f"projects/{project_id}/locations/{location}/userStores/{USER_STORE_ID}"


def user_store_base_url(location: str) -> str:
    host = "discoveryengine.googleapis.com"
    if location != "global":
        host = f"{location}-{host}"
    return f"https://{host}/v1"


def list_user_licenses(
    session: AuthorizedSession, *, project_id: str, location: str
) -> Iterator[dict[str, Any]]:
    url = f"{user_store_base_url(location)}/{user_store_path(project_id, location)}/userLicenses"
    params: dict[str, Any] = {"pageSize": PAGE_SIZE}

    while True:
        response = session.get(
            url,
            params=params,
            headers={"X-Goog-User-Project": project_id},
            timeout=60,
        )
        if not response.ok:
            log_json(
                "list_user_licenses_failed",
                location=location,
                status_code=response.status_code,
                response_body=response.text,
            )
        response.raise_for_status()
        body = response.json()

        yield from body.get("userLicenses", [])

        page_token = body.get("nextPageToken")
        if not page_token:
            return
        params["pageToken"] = page_token


def license_row(
    license_: dict[str, Any], *, snapshot_date: date, location: str, ingested_at: datetime
) -> dict[str, Any]:
    principal = license_.get("userPrincipal") or ""
    return {
        "snapshot_date": snapshot_date.isoformat(),
        "location": location,
        "user_store": USER_STORE_ID,
        "user_email": principal.lower() or None,
        "license_state": license_.get("licenseAssignmentState"),
        "license_config": (license_.get("licenseConfig") or "").rsplit("/", 1)[-1] or None,
        "create_time": license_.get("createTime"),
        "update_time": license_.get("updateTime"),
        "last_login_time": license_.get("lastLoginTime"),
        "ingested_at": ingested_at.isoformat(),
    }


def user_store_locations() -> list[str]:
    raw = os.getenv("USER_STORE_LOCATIONS") or "global"
    return [location.strip() for location in raw.split(",") if location.strip()]


def run() -> None:
    project_id = required_env("PROJECT_ID")
    engine_project_id = os.getenv("ENGINE_PROJECT_ID") or project_id
    analytics_project_id = os.getenv("ANALYTICS_PROJECT_ID") or project_id
    analytics_dataset = required_env("ANALYTICS_DATASET")

    now = datetime.now(UTC)
    snapshot_date = now.date()
    session = authorized_session()

    rows: list[dict[str, Any]] = []
    for location in user_store_locations():
        location_rows = [
            license_row(item, snapshot_date=snapshot_date, location=location, ingested_at=now)
            for item in list_user_licenses(session, project_id=engine_project_id, location=location)
        ]
        log_json("licenses_listed", location=location, row_count=len(location_rows))
        rows.extend(location_rows)

    if not rows:
        log_json("license_snapshot_skipped_empty", snapshot_date=snapshot_date.isoformat())
        return

    client = bigquery.Client(project=project_id)
    table_id = f"{analytics_project_id}.{analytics_dataset}.{LICENSES_TABLE}"
    job_config = bigquery.LoadJobConfig(
        schema=client.get_table(table_id).schema,
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )
    # The partition decorator makes WRITE_TRUNCATE replace only today's snapshot.
    partition = f"{table_id}${snapshot_date:%Y%m%d}"
    client.load_table_from_json(rows, partition, job_config=job_config).result()

    log_json(
        "license_snapshot_completed",
        snapshot_date=snapshot_date.isoformat(),
        row_count=len(rows),
    )
