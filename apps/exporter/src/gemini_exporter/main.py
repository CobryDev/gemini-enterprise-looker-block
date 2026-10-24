from __future__ import annotations

import json
import logging
import os
import time
from dataclasses import dataclass
from importlib import resources
from typing import Any

import google.auth
from google.auth.transport.requests import AuthorizedSession
from google.cloud import bigquery
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

OPERATION_TIMEOUT_SECONDS = 1200
POLL_INTERVAL_SECONDS = 10

# Retry transient failures (connection errors and 429/5xx) with exponential
# backoff so a momentary Discovery Engine blip doesn't fail the whole export.
RETRY_TOTAL = 5
RETRY_BACKOFF_FACTOR = 2.0
RETRY_STATUS_CODES = (429, 500, 502, 503, 504)


@dataclass(frozen=True)
class EngineConfig:
    engine_id: str
    display_name: str
    location: str
    endpoint_location: str
    table_id_prefix: str


@dataclass(frozen=True)
class PipelineConfig:
    project_id: str
    engine_project_id: str
    staging_project_id: str
    staging_dataset: str
    analytics_project_id: str
    analytics_dataset: str
    analytics_table: str


def configure_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(message)s")


def log_json(message: str, **payload: Any) -> None:
    logging.info(json.dumps({"message": message, **payload}, sort_keys=True))


def required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def engine_from_env() -> EngineConfig:
    engine_id = required_env("ENGINE_ID")
    location = required_env("ENGINE_LOCATION")
    endpoint_location = os.getenv("ENDPOINT_LOCATION") or location
    table_id_prefix = os.getenv("TABLE_ID_PREFIX") or f"export_{engine_id.replace('-', '_')}"
    display_name = os.getenv("DISPLAY_NAME") or engine_id

    return EngineConfig(
        engine_id=engine_id,
        display_name=display_name,
        location=location,
        endpoint_location=endpoint_location,
        table_id_prefix=table_id_prefix,
    )


def pipeline_from_env() -> PipelineConfig:
    project_id = required_env("PROJECT_ID")
    engine_project_id = os.getenv("ENGINE_PROJECT_ID") or project_id
    return PipelineConfig(
        project_id=project_id,
        engine_project_id=engine_project_id,
        staging_project_id=os.getenv("STAGING_PROJECT_ID") or engine_project_id,
        staging_dataset=required_env("STAGING_DATASET"),
        analytics_project_id=os.getenv("ANALYTICS_PROJECT_ID") or project_id,
        analytics_dataset=required_env("ANALYTICS_DATASET"),
        analytics_table=os.getenv("ANALYTICS_TABLE") or "export_history",
    )


def authorized_session() -> AuthorizedSession:
    credentials, _ = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    session = AuthorizedSession(credentials)

    retry = Retry(
        total=RETRY_TOTAL,
        connect=RETRY_TOTAL,
        read=RETRY_TOTAL,
        status=RETRY_TOTAL,
        backoff_factor=RETRY_BACKOFF_FACTOR,
        status_forcelist=RETRY_STATUS_CODES,
        allowed_methods=frozenset({"GET", "POST"}),
        respect_retry_after_header=True,
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session


def engine_path(project_id: str, engine: EngineConfig) -> str:
    return (
        f"projects/{project_id}/locations/{engine.location}"
        f"/collections/default_collection/engines/{engine.engine_id}"
    )


def api_base_url(endpoint_location: str, version: str = "v1alpha") -> str:
    return f"https://{endpoint_location}-discoveryengine.googleapis.com/{version}"


def operation_url(base_url: str, operation_name: str) -> str:
    if operation_name.startswith("https://"):
        return operation_name

    return f"{base_url}/{operation_name}"


def wait_for_operation(
    session: AuthorizedSession,
    *,
    base_url: str,
    operation_name: str,
    timeout_seconds: int = OPERATION_TIMEOUT_SECONDS,
) -> None:
    deadline = time.monotonic() + timeout_seconds
    url = operation_url(base_url, operation_name)

    while time.monotonic() < deadline:
        response = session.get(url, timeout=60)
        response.raise_for_status()
        operation = response.json()

        if operation.get("done"):
            if "error" in operation:
                raise RuntimeError(json.dumps(operation["error"], sort_keys=True))
            return

        time.sleep(POLL_INTERVAL_SECONDS)

    raise TimeoutError(
        f"Operation did not complete within {timeout_seconds} seconds: {operation_name}"
    )


def export_engine_metrics(*, pipeline: PipelineConfig, engine: EngineConfig) -> str:
    session = authorized_session()
    base_url = api_base_url(engine.endpoint_location)
    analytics_resource = engine_path(pipeline.engine_project_id, engine)
    url = f"{base_url}/{analytics_resource}/analytics:exportMetrics"
    payload = {
        "analytics": analytics_resource,
        "outputConfig": {
            "bigqueryDestination": {
                "datasetId": pipeline.staging_dataset,
                "tableId": engine.table_id_prefix,
            }
        }
    }

    response = session.post(
        url,
        headers={"X-Goog-User-Project": pipeline.engine_project_id},
        json=payload,
        timeout=60,
    )
    if not response.ok:
        log_json(
            "export_request_failed",
            engine_id=engine.engine_id,
            engine_project_id=pipeline.engine_project_id,
            staging_project_id=pipeline.staging_project_id,
            status_code=response.status_code,
            response_body=response.text,
        )
    response.raise_for_status()
    operation = response.json()
    operation_name = operation["name"]

    log_json(
        "export_started",
        engine_id=engine.engine_id,
        app_name=engine.display_name,
        operation_name=operation_name,
        table_id_prefix=engine.table_id_prefix,
    )

    wait_for_operation(session, base_url=base_url, operation_name=operation_name)
    return operation_name


def staging_table_wildcard(pipeline: PipelineConfig, engine: EngineConfig) -> str:
    return f"{pipeline.staging_project_id}.{pipeline.staging_dataset}.{engine.table_id_prefix}*"


def history_table(pipeline: PipelineConfig) -> str:
    return (
        f"{pipeline.analytics_project_id}.{pipeline.analytics_dataset}.{pipeline.analytics_table}"
    )


def load_merge_sql() -> str:
    return resources.files("gemini_exporter").joinpath("merge_export_history.sql").read_text()


def render_merge_sql(pipeline: PipelineConfig, engine: EngineConfig) -> str:
    # Identifiers can't be bound as query parameters; they come from trusted
    # Terraform-supplied config. All values are bound as parameters.
    return load_merge_sql().format(
        staging_table_wildcard=staging_table_wildcard(pipeline, engine),
        history_table=history_table(pipeline),
    )


def count_exported_rows(
    client: bigquery.Client,
    pipeline: PipelineConfig,
    engine: EngineConfig,
) -> int | None:
    query = f"""
        SELECT COUNT(*) AS row_count
        FROM `{staging_table_wildcard(pipeline, engine)}`
    """
    try:
        rows = client.query(query).result()
        return next(iter(rows)).row_count
    except Exception:
        logging.exception("Failed to count exported rows")
        return None


def merge_export_history(
    client: bigquery.Client,
    pipeline: PipelineConfig,
    engine: EngineConfig,
) -> int | None:
    """Upsert this engine's staging window into the history table.

    Returns the number of affected rows, or None when staging held no rows.
    """
    bounds_query = f"""
        SELECT
          MIN(SAFE_CAST(date AS DATE)) AS window_start,
          MAX(SAFE_CAST(date AS DATE)) AS window_end
        FROM `{staging_table_wildcard(pipeline, engine)}`
        WHERE date IS NOT NULL
    """
    bounds = next(iter(client.query(bounds_query).result()))
    if bounds.window_start is None:
        log_json("merge_skipped_empty_staging", engine_id=engine.engine_id)
        return None

    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("engine_id", "STRING", engine.engine_id),
            bigquery.ScalarQueryParameter("app_name", "STRING", engine.display_name),
            bigquery.ScalarQueryParameter("window_start", "DATE", bounds.window_start),
            bigquery.ScalarQueryParameter("window_end", "DATE", bounds.window_end),
        ]
    )
    job = client.query(render_merge_sql(pipeline, engine), job_config=job_config)
    job.result()

    log_json(
        "merge_completed",
        engine_id=engine.engine_id,
        app_name=engine.display_name,
        window_start=str(bounds.window_start),
        window_end=str(bounds.window_end),
        affected_rows=job.num_dml_affected_rows,
    )
    return job.num_dml_affected_rows


def run_export() -> None:
    pipeline = pipeline_from_env()
    engine = engine_from_env()

    log_json(
        "export_run_started",
        engine_id=engine.engine_id,
        app_name=engine.display_name,
        project_id=pipeline.project_id,
        engine_project_id=pipeline.engine_project_id,
        staging_project_id=pipeline.staging_project_id,
    )

    operation_name = export_engine_metrics(pipeline=pipeline, engine=engine)

    client = bigquery.Client(project=pipeline.project_id)
    row_count = count_exported_rows(client, pipeline, engine)
    log_json(
        "export_completed",
        engine_id=engine.engine_id,
        app_name=engine.display_name,
        operation_name=operation_name,
        row_count=row_count,
    )

    merge_export_history(client, pipeline, engine)

    log_json("export_run_completed", engine_id=engine.engine_id)


MODES = ("export", "transform_logs", "snapshot_licenses")


def main() -> None:
    configure_logging()

    mode = os.getenv("MODE") or "export"
    if mode == "export":
        run_export()
    elif mode == "transform_logs":
        from gemini_exporter import transform_logs

        transform_logs.run()
    elif mode == "snapshot_licenses":
        from gemini_exporter import licenses

        licenses.run()
    else:
        raise ValueError(f"Unknown MODE {mode!r}; expected one of {', '.join(MODES)}")


if __name__ == "__main__":
    main()
