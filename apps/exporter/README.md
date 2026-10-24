# Gemini Analytics Exporter

Cloud Run job that exports analytics for one Gemini Enterprise engine and merges the result into the longitudinal `export_history` table. With the Terraform log pipeline on, the same job also transforms raw Gemini logs into redacted user-level tables and snapshots user licences (see [Modes](#modes)).

Each run handles a single engine, in three steps:

1. Call the Discovery Engine `analytics:exportMetrics` API and poll the operation until the staging tables are written.
2. Count the exported staging rows (logged as `export_completed`).
3. Run a parameterized `MERGE` that upserts the engine's rolling export window into `export_history` (logged as `merge_completed`).

Cloud Scheduler triggers one execution per engine per day, passing the engine identity as container env overrides. Because the merge runs inside the same job execution, there is no separate scheduled query and no ordering race between export and merge.

## Modes

The `MODE` environment variable picks what a run does. Cloud Scheduler sets it as a container override.

| `MODE` | Schedule | What it does |
| --- | --- | --- |
| `export` (default) | Daily, per engine | The export-and-merge run described above. |
| `transform_logs` | Hourly | Runs one `MERGE` per curated log table (`sql/logs/*.sql`) over the last `LOOKBACK_HOURS` of the raw log bucket. It copies an allow-list of metadata fields; prompt, response, grounding and file content are never selected. Logs `transform_completed` per table. If a table fails, the others still run and the execution fails at the end. |
| `snapshot_licenses` | Daily | Lists every user licence from the Discovery Engine `userLicenses` API in each `USER_STORE_LOCATIONS` location, and replaces today's partition of `ge_user_licenses`. |

The log transforms are idempotent: rows are keyed by log `insertId` (or tool-call ID), so overlapping windows and retries never duplicate data. Rows first written without a user (because the matching activity entry arrived later) get their user filled in by a later run.

## Environment Variables

| Name | Required | Description |
| --- | --- | --- |
| `PROJECT_ID` | Yes | GCP project the exporter runs BigQuery jobs in (the analytics project). |
| `ENGINE_PROJECT_ID` | No | Project that owns the Gemini Enterprise engine. Defaults to `PROJECT_ID`. |
| `STAGING_PROJECT_ID` | No | Project holding the staging dataset. Defaults to `ENGINE_PROJECT_ID` (the export API writes in the app project). |
| `STAGING_DATASET` | Yes | BigQuery dataset for raw export tables. |
| `ANALYTICS_PROJECT_ID` | No | Project holding the analytics dataset. Defaults to `PROJECT_ID`. |
| `ANALYTICS_DATASET` | Yes | BigQuery dataset holding `export_history`. |
| `ANALYTICS_TABLE` | No | History table name. Defaults to `export_history`. |
| `ENGINE_ID` | Yes | Gemini Enterprise engine ID to export. |
| `DISPLAY_NAME` | No | Friendly app name; written to `export_history.app_name`. Defaults to `ENGINE_ID`. |
| `ENGINE_LOCATION` | Yes | Discovery Engine location of the engine, e.g. `eu` or `global`. |
| `ENDPOINT_LOCATION` | No | API endpoint prefix. Defaults to `ENGINE_LOCATION`. |
| `TABLE_ID_PREFIX` | No | BigQuery staging table prefix. Defaults to `export_<engine_id with - replaced by _>`. |
| `MODE` | No | `export` (default), `transform_logs` or `snapshot_licenses`. |
| `RAW_LOGS_VIEW` | For `transform_logs` | `_AllLogs` view of the raw log bucket's linked dataset, e.g. `your-project.gemini_logs_raw._AllLogs`. |
| `APP_NAMES_JSON` | No | JSON object mapping engine ID to app name for the log tables. |
| `LOOKBACK_HOURS` | No | How far back each transform reads. Defaults to `3`. |
| `USER_STORE_LOCATIONS` | No | Comma-separated user store locations for `snapshot_licenses`. Defaults to `global`. |

`ENGINE_ID` and `ENGINE_LOCATION` are only required in `export` mode.

## Manual run

Trigger an ad-hoc export for one engine via the deployed Cloud Run job:

```sh
gcloud run jobs execute gemini-analytics-exporter \
  --region=europe-west2 \
  --update-env-vars=ENGINE_ID=your-engine-id,ENGINE_LOCATION=eu,DISPLAY_NAME="Your App"
```

## Local development

```sh
pip install -e ".[dev]"
ruff check src tests
pytest
```

To run the job locally, set the environment variables above and use Application Default Credentials with access to Discovery Engine and BigQuery:

```sh
python -m gemini_exporter.main
```

The merge SQL lives in `src/gemini_exporter/merge_export_history.sql`. Table identifiers are formatted in from config; all values (`@engine_id`, `@app_name`, `@window_start`, `@window_end`) are bound as BigQuery query parameters.

The log transform SQL lives in `src/gemini_exporter/sql/logs/`, one file per curated table, with the same rule: only `{raw_logs_view}` and `{analytics_dataset}` are formatted in, and `@window_start`, `@app_engine_ids` and `@app_display_names` are parameters. `tests/test_log_transforms.py` fails if a script reads a content field, if its insert columns drift from the Terraform table schema, or if it reads a payload path that doesn't exist in the fixture log shapes in `tests/fixtures/`. When you add a field, add its path to the fixtures too.
