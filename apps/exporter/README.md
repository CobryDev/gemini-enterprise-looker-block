# Gemini Analytics Exporter

Cloud Run job that calls the Gemini Enterprise `analytics:exportMetrics` API for one or more engines.

The job supports two modes:

- **Scheduled single-engine run**: Cloud Scheduler passes `ENGINE_ID`, `DISPLAY_NAME`, `ENGINE_LOCATION`, `ENDPOINT_LOCATION`, and `TABLE_ID_PREFIX` as environment overrides.
- **Manual all-engine run**: run the job without `ENGINE_ID`; it reads `ENGINE_CONFIG_SECRET` and exports every configured engine.

## Environment Variables

| Name | Required | Description |
| --- | --- | --- |
| `PROJECT_ID` | Yes | GCP project that owns the Gemini Enterprise engines and BigQuery datasets. |
| `STAGING_DATASET` | Yes | BigQuery dataset for raw export tables. |
| `ENGINE_ID` | Single-engine mode | Gemini Enterprise engine ID. |
| `DISPLAY_NAME` | No | Friendly app name for the engine; surfaced in logs and (via the merge query) as `app_name`. Defaults to `ENGINE_ID`. |
| `ENGINE_LOCATION` | Single-engine mode | Discovery Engine location for the engine. |
| `ENDPOINT_LOCATION` | Single-engine mode | API endpoint prefix, for example `eu` or `global`. |
| `TABLE_ID_PREFIX` | Single-engine mode | BigQuery table prefix for the export. |
| `ENGINE_CONFIG_SECRET` | All-engine mode | Secret Manager resource name containing the engine config JSON. |

## Local Run

```sh
python -m gemini_exporter.main
```

Use Application Default Credentials with access to Discovery Engine, BigQuery, and Secret Manager.
