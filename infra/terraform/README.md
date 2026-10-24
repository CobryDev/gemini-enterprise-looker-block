# Deploy the Gemini analytics pipeline

Use this Terraform deployment to create the client-hosted GCP infrastructure for the Gemini Enterprise export pipeline.

For the full export-to-dashboard walkthrough, start with the root `README.md`.

## What Terraform creates

Terraform creates the scheduled ETL path for Gemini Enterprise metrics:

- BigQuery staging dataset for the rolling 30-day export window.
- BigQuery analytics dataset with a partitioned, full-fidelity `export_history` table.
- Cloud Run job for the exporter container, which exports an engine's metrics **and merges them into `export_history` in the same run**.
- Cloud Scheduler jobs, one per Gemini Enterprise engine, with retry on transient failures.
- Service accounts and IAM bindings for the exporter and scheduler.
- Optional: a Cloud Monitoring email alert on exporter failures (`alert_email`).
- Optional: read access for the Looker connection service account (`looker_service_account_email`).
- Optional: the log pipeline for user-level Change Management analytics (`enable_log_pipeline`). See below.
- Optional: a daily cross-region copy of the Workspace audit export into `dataset_location` (`workspace_audit_dataset_id`). See [Workspace Gemini export](#workspace-gemini-export).

Cloud Scheduler is part of the required production setup. It invokes the Cloud Run job every day so both the staging export and the `export_history` table stay fresh. There is no separate scheduled query: the merge runs inside the exporter, so it can never fire before the export it depends on.

## Before you apply

Have an exporter image ready. Terraform expects `exporter_image` to point at an existing image — either one published by this repo's `publish-image.yml` workflow or one you built yourself (see the root README, step 2). Pin a version tag rather than `latest` so applies are reproducible:

```text
europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:v0.2.0
```

Set `dataset_location` to the location required by your Gemini Enterprise engines:

- Use `EU` for EU engines.
- Use `US` for global or US engines.

Terraform validates both rules at plan time: all engines must share one location, and `dataset_location` must match it. If you need both EU and US engines, run separate deployments.

## Configure variables

Copy the example file:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set your project, image, and engines:

```hcl
project_id       = "your-gcp-project-id"
region           = "europe-west2"
dataset_location = "EU"
exporter_image   = "europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:v0.2.0"

alert_email                  = "data-team@example.com"
looker_service_account_email = ""

engines = [
  {
    engine_id         = "customer-support-engine"
    display_name      = "Support Copilot"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "0 6 * * *"
    time_zone         = "Etc/UTC"
  },
  {
    engine_id         = "sales-assistant-engine"
    display_name      = "Sales Assistant"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "15 6 * * *"
    time_zone         = "Etc/UTC"
  }
]
```

Add one `engines` entry per Gemini Enterprise app you want to track. Each engine gets its own Cloud Scheduler job and staging tables, and each run merges its own data into the single `export_history` table. `display_name` is optional and sets the friendly `app_name` exposed in BigQuery and Looker (it defaults to `engine_id`); use it to tell apps apart in dashboards. Stagger schedules by a minute or two to stay below API rate limits.

**All engines listed here must be in the same location.** Each app's analytics export runs in the region of the app's data (`eu` apps export in the EU, `global` apps in the US), and BigQuery cannot union across regions into the single `export_history` table. Terraform rejects mixed-region configurations at plan time. For apps in two regions, deploy this stack twice (one per region/`dataset_location`) and use a separate Looker connection for each, so each region's data stays resident in that region.

## Configure remote state

State lives in a GCS bucket (the `backend "gcs"` block in `versions.tf`), not on
your laptop. Create a versioned bucket once per environment, then point the
backend at it:

```sh
gcloud storage buckets create gs://your-tf-state-bucket \
  --location=EU --uniform-bucket-level-access
gcloud storage buckets update gs://your-tf-state-bucket --versioning

cp backend.hcl.example backend.hcl   # then edit bucket/prefix
```

For a quick one-shot evaluation you can skip the bucket and use local state with `terraform init -backend=false`, but use the GCS backend for anything a team operates.

## Apply Terraform

```sh
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Run the first job

Wait for Cloud Scheduler, or trigger an export manually:

```sh
gcloud scheduler jobs run gemini-export-customer-support-engine \
  --location=europe-west2
```

Check exporter logs:

```sh
gcloud logging read \
  'resource.type="cloud_run_job" AND resource.labels.job_name="gemini-analytics-exporter"' \
  --limit=50 \
  --format=json
```

A healthy run logs `export_started`, `export_completed`, and `merge_completed`.

## Log pipeline (user-level analytics)

Set `enable_log_pipeline = true` to route Gemini Enterprise, Model Armor and Antigravity logs into redacted user-level tables. The root `README.md` (step 8) covers the console settings to turn on first and how to verify the result.

| Variable | Default | What it does |
|---|---|---|
| `enable_log_pipeline` | `false` | Creates the raw log bucket, sinks, curated tables, licence role and the two extra scheduler jobs. |
| `log_source_project_ids` | engine project | Projects whose logs are routed. Add the Antigravity or Model Armor project if they differ. |
| `raw_log_retention_days` | `2` | Days the raw bucket (which holds prompt text) keeps entries. 1 to 7. |
| `route_inference_logs` | `true` | Routes the gen_ai inference log for token, tool and skill reporting. |
| `enable_model_armor_audit_logs` | `false` | Turns on Model Armor Data Access audit logs (verdicts, no prompt text) in the source projects. |
| `exclude_content_logs_from_default_bucket` | `false` | Stops Cloud Logging keeping prompt-bearing entries in `_Default` for 30 days. |
| `user_store_locations` | engine locations | User store locations the licence snapshot reads. |
| `log_app_display_names` | `{}` | Friendly names for engine IDs that appear in logs but aren't in `engines`. |
| `log_transform_schedule` | `20 * * * *` | Cron schedule for the hourly transform. |
| `license_snapshot_schedule` | `0 5 * * *` | Cron schedule for the licence snapshot. |

A few design points:

- Logs land in a Log Analytics bucket exposed through a linked BigQuery dataset, not a BigQuery sink. Sink tables fix column types from the first entry they see, and these payloads change type between entries (action arguments, tool definitions), so a sink would quietly divert entries to `export_errors`. Log Analytics stores payloads as JSON, so every entry lands.
- The linked dataset is read-only and only the exporter service account gets **BigQuery Data Viewer** on it. Don't grant the Looker connection access to it.
- `enable_model_armor_audit_logs` uses `google_project_iam_audit_config`, which is authoritative for `modelarmor.googleapis.com` only. If you already manage that service's audit config elsewhere, leave the flag off and turn on DATA_READ there.
- The curated tables have `deletion_protection = true`. User-level history can't be rebuilt once raw entries expire.
- The transform SQL lives in `apps/exporter/src/gemini_exporter/sql/logs/`, one MERGE per curated table. The table schemas live in `modules/gemini_analytics_pipeline/logs.tf`, and a pytest check keeps the two in step.

## Workspace Gemini export

Workspace Gemini audit logs are not created by Terraform. Configure them in the Workspace Admin console:

1. Go to **Reporting > BigQuery Export**.
2. Enable the export.
3. Choose a destination project and dataset, for example `workspace_audit`.
4. Confirm the export service account has **BigQuery Data Editor** on the destination.
5. Set the `workspace_dataset` LookML constant to that dataset.
6. Grant the Looker connection service account **BigQuery Data Viewer** on it (this dataset is outside Terraform's scope).

### Copy the export into the Gemini location

The Looker AI adoption tabs join the Workspace export to `gemini_analytics`. That only works when both are in the same BigQuery location. When they aren't, Terraform can copy the export daily:

| Variable | Default | What it does |
|---|---|---|
| `workspace_audit_dataset_id` | `""` | The Workspace export dataset. Empty skips the copy. |
| `workspace_audit_location` | `""` | Its BigQuery location, for example `US`. The copy is only created when this differs from `dataset_location`. |
| `workspace_audit_project_id` | `project_id` | Project holding the export. |
| `workspace_copy_dataset_id` | `workspace_audit_copy` | Destination dataset in `dataset_location`. |

This creates a `cross_region_copy` BigQuery Data Transfer config running every 24 hours, a `gemini-workspace-copy` service account with read access on the source, the destination dataset, and Looker read access on it when `looker_service_account_email` is set. The `looker_workspace_settings` output gives the `workspace_dataset` and `workspace_export` values to enter in the Looker block. Each run copies changed tables in full, so a large `activity` table means daily cross-region egress charges.

## Notes

- The merge SQL lives in the exporter app (`apps/exporter/src/gemini_exporter/merge_export_history.sql`) and expects the staging export schema with a `date` column plus the metric columns mirrored in the `export_history` table schema. If Google changes the export payload shape, update both the SQL and the table schema in `main.tf`.
- Terraform enables the Google APIs needed by the module, but the caller still needs permission to enable services and create IAM bindings.
- Migrating from the previous version (scheduled-query merge): the new apply removes the BigQuery data transfer config, the `gemini-bq-scheduled-query` service account, and the Secret Manager engine config. `export_history` and its data are untouched. Build/publish the new exporter image and update `exporter_image` before applying.
