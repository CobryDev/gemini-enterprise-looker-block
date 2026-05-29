from __future__ import annotations

import json
import logging
import os
import time
from dataclasses import dataclass
from typing import Any

import google.auth
from google.auth.transport.requests import AuthorizedSession
from google.cloud import bigquery, secretmanager

OPERATION_TIMEOUT_SECONDS = 1200
POLL_INTERVAL_SECONDS = 10


@dataclass(frozen=True)
class EngineConfig:
    engine_id: str
    display_name: str
    location: str
    endpoint_location: str
    table_id_prefix: str


def configure_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(message)s")


def log_json(message: str, **payload: Any) -> None:
    logging.info(json.dumps({"message": message, **payload}, sort_keys=True))


def required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def engine_from_env() -> EngineConfig | None:
    engine_id = os.getenv("ENGINE_ID")
    if not engine_id:
        return None

    location = required_env("ENGINE_LOCATION")
    endpoint_location = os.getenv("ENDPOINT_LOCATION", location)
    table_id_prefix = os.getenv("TABLE_ID_PREFIX", f"export_{engine_id.replace('-', '_')}")
    display_name = os.getenv("DISPLAY_NAME", engine_id)

    return EngineConfig(
        engine_id=engine_id,
        display_name=display_name,
        location=location,
        endpoint_location=endpoint_location,
        table_id_prefix=table_id_prefix,
    )


def load_engine_config_from_secret(secret_name: str) -> list[EngineConfig]:
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(request={"name": f"{secret_name}/versions/latest"})
    payload = json.loads(response.payload.data.decode("utf-8"))

    engines = []
    for engine in payload.get("engines", []):
        engine_id = engine["engine_id"]
        location = engine["location"]
        engines.append(
            EngineConfig(
                engine_id=engine_id,
                display_name=engine.get("display_name", engine_id),
                location=location,
                endpoint_location=engine.get("endpoint_location", location),
                table_id_prefix=engine.get("table_id_prefix", f"export_{engine_id.replace('-', '_')}"),
            )
        )

    if not engines:
        raise ValueError("Engine config secret did not contain any engines")

    return engines


def load_engines() -> list[EngineConfig]:
    env_engine = engine_from_env()
    if env_engine:
        return [env_engine]

    return load_engine_config_from_secret(required_env("ENGINE_CONFIG_SECRET"))


def authorized_session() -> AuthorizedSession:
    credentials, _ = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    return AuthorizedSession(credentials)


def engine_path(project_id: str, engine: EngineConfig) -> str:
    return (
        f"projects/{project_id}/locations/{engine.location}"
        f"/collections/default_collection/engines/{engine.engine_id}"
    )


def api_base_url(endpoint_location: str) -> str:
    return f"https://{endpoint_location}-discoveryengine.googleapis.com/v1alpha"


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

    raise TimeoutError(f"Operation did not complete within {timeout_seconds} seconds: {operation_name}")


def export_engine_metrics(
    *,
    project_id: str,
    engine_project_id: str,
    staging_project_id: str,
    staging_dataset: str,
    engine: EngineConfig,
) -> str:
    session = authorized_session()
    base_url = api_base_url(engine.endpoint_location)
    analytics_resource = engine_path(engine_project_id, engine)
    url = f"{base_url}/{analytics_resource}/analytics:exportMetrics"
    payload = {
        "analytics": analytics_resource,
        "outputConfig": {
            "bigqueryDestination": {
                "datasetId": staging_dataset,
                "tableId": engine.table_id_prefix,
            }
        }
    }

    response = session.post(
        url,
        headers={"X-Goog-User-Project": engine_project_id},
        json=payload,
        timeout=60,
    )
    if not response.ok:
        log_json(
            "export_request_failed",
            engine_id=engine.engine_id,
            engine_project_id=engine_project_id,
            staging_project_id=staging_project_id,
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


def count_exported_rows(
    job_project_id: str,
    staging_project_id: str,
    staging_dataset: str,
    table_id_prefix: str,
) -> int | None:
    query = f"""
        SELECT COUNT(*) AS row_count
        FROM `{staging_project_id}.{staging_dataset}.{table_id_prefix}*`
    """
    try:
        rows = bigquery.Client(project=job_project_id).query(query).result()
        return next(iter(rows)).row_count
    except Exception:
        logging.exception("Failed to count exported rows")
        return None


def main() -> None:
    configure_logging()

    project_id = required_env("PROJECT_ID")
    engine_project_id = os.getenv("ENGINE_PROJECT_ID", project_id)
    staging_project_id = os.getenv("STAGING_PROJECT_ID", engine_project_id)
    staging_dataset = required_env("STAGING_DATASET")

    engines = load_engines()
    log_json(
        "export_run_started",
        engine_count=len(engines),
        project_id=project_id,
        engine_project_id=engine_project_id,
        staging_project_id=staging_project_id,
    )

    failed_engines: list[str] = []
    for engine in engines:
        try:
            operation_name = export_engine_metrics(
                project_id=project_id,
                engine_project_id=engine_project_id,
                staging_project_id=staging_project_id,
                staging_dataset=staging_dataset,
                engine=engine,
            )
            row_count = count_exported_rows(
                project_id,
                staging_project_id,
                staging_dataset,
                engine.table_id_prefix,
            )
            log_json(
                "export_completed",
                engine_id=engine.engine_id,
                app_name=engine.display_name,
                operation_name=operation_name,
                row_count=row_count,
            )
        except Exception:
            # Keep going so one bad engine can't block the rest of the run; we
            # surface the failures with a non-zero exit at the end.
            logging.exception("Gemini analytics export failed for engine %s", engine.engine_id)
            failed_engines.append(engine.engine_id)

    log_json(
        "export_run_completed",
        engine_count=len(engines),
        failed_engine_count=len(failed_engines),
        failed_engines=failed_engines,
    )

    if failed_engines:
        raise SystemExit(f"Export failed for {len(failed_engines)} engine(s): {', '.join(failed_engines)}")


if __name__ == "__main__":
    main()
