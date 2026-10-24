"""Copy redacted metadata from the raw Gemini log bucket into curated tables.

The raw log bucket (read through its linked BigQuery dataset) holds full log
entries, including prompt and response text. Each curated table has its own
MERGE script under sql/logs/ that selects an allow-list of metadata fields and
upserts by log insertId over a rolling lookback window, so re-running a window
is idempotent and late-arriving entries are picked up by the next run.
"""

from __future__ import annotations

import json
import logging
import os
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from importlib import resources

from google.cloud import bigquery

from gemini_exporter.main import log_json, required_env

# Order matters: later scripts attribute users by joining to ge_user_activity
# rows merged earlier in the same run.
TRANSFORMS = (
    "ge_user_activity",
    "ge_model_calls",
    "ge_tool_calls",
    "ge_connector_activity",
    "ge_safety_events",
    "ge_admin_events",
    "antigravity_usage",
)

DEFAULT_LOOKBACK_HOURS = 3


@dataclass(frozen=True)
class LogTransformConfig:
    project_id: str
    analytics_project_id: str
    analytics_dataset: str
    raw_logs_view: str
    lookback_hours: int
    app_names: dict[str, str]


def config_from_env() -> LogTransformConfig:
    project_id = required_env("PROJECT_ID")
    app_names = json.loads(os.getenv("APP_NAMES_JSON") or "{}")
    if not isinstance(app_names, dict):
        raise ValueError("APP_NAMES_JSON must be a JSON object of engine_id to app name")

    return LogTransformConfig(
        project_id=project_id,
        analytics_project_id=os.getenv("ANALYTICS_PROJECT_ID") or project_id,
        analytics_dataset=required_env("ANALYTICS_DATASET"),
        raw_logs_view=required_env("RAW_LOGS_VIEW"),
        lookback_hours=int(os.getenv("LOOKBACK_HOURS") or DEFAULT_LOOKBACK_HOURS),
        app_names={str(key): str(value) for key, value in app_names.items()},
    )


def load_transform_sql(name: str) -> str:
    return resources.files("gemini_exporter").joinpath(f"sql/logs/{name}.sql").read_text()


def render_transform_sql(config: LogTransformConfig, name: str) -> str:
    # Identifiers can't be bound as query parameters; they come from trusted
    # Terraform-supplied config. All values are bound as parameters.
    return load_transform_sql(name).format(
        raw_logs_view=config.raw_logs_view,
        analytics_dataset=f"{config.analytics_project_id}.{config.analytics_dataset}",
    )


def query_parameters(
    config: LogTransformConfig, window_start: datetime
) -> list[bigquery.ScalarQueryParameter | bigquery.ArrayQueryParameter]:
    engine_ids = sorted(config.app_names)
    return [
        bigquery.ScalarQueryParameter("window_start", "TIMESTAMP", window_start),
        bigquery.ArrayQueryParameter("app_engine_ids", "STRING", engine_ids),
        bigquery.ArrayQueryParameter(
            "app_display_names", "STRING", [config.app_names[key] for key in engine_ids]
        ),
    ]


def run() -> None:
    config = config_from_env()
    window_start = datetime.now(UTC) - timedelta(hours=config.lookback_hours)
    client = bigquery.Client(project=config.project_id)
    job_config = bigquery.QueryJobConfig(query_parameters=query_parameters(config, window_start))

    log_json("transform_logs_started", window_start=window_start.isoformat())

    failures = []
    for name in TRANSFORMS:
        try:
            job = client.query(render_transform_sql(config, name), job_config=job_config)
            job.result()
        except Exception:
            # Keep going so one broken table doesn't stop the others; raising
            # at the end still fails the execution and triggers the alert.
            logging.exception("Log transform failed for %s", name)
            failures.append(name)
            continue
        log_json("transform_completed", table=name, affected_rows=job.num_dml_affected_rows)

    if failures:
        raise RuntimeError(f"Log transforms failed: {', '.join(failures)}")

    log_json("transform_logs_completed", tables=len(TRANSFORMS))
