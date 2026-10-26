# Set up Gemini analytics dashboards in Looker

Use this guide to export Gemini Enterprise and Workspace Gemini usage into BigQuery, run the daily pipeline, and install the Looker block that turns the exports into dashboards.

The default setup is client-hosted: the client owns the GCP project, BigQuery datasets, Cloud Run job, scheduler, and Looker connection.

## Quick start

1. **Deploy the pipeline**: configure and apply Terraform (steps 2 to 5), with `enable_log_pipeline = true` for user-level analytics (step 8).
2. **Install the block**: in Looker, **Marketplace → Install via Git URL**, then answer three prompts: connection, project and dataset (step 7). Every other prompt has a working default.
3. **Open Data Health** in the admin dashboard: it lists every data source the block reads, whether it has fresh rows, and what to do about anything missing.

Everything else is optional: the Workspace export (step 1) adds Gemini for Workspace adoption, org units and the Workspace population; seat costs and an hourly rate turn on the value scenarios; intervention and outcome rows turn on before/after measurement.

## How the pipeline works

The pipeline has two sources and one Looker block:

```text
Gemini Enterprise analytics API
  -> Cloud Scheduler (one job per engine)
  -> Cloud Run exporter job
       1. exports the engine's rolling 30-day window to BigQuery staging
       2. merges the window into the gemini_analytics.export_history table
  -> Looker Block dashboards

Workspace Admin BigQuery export
  -> BigQuery Workspace audit dataset
  -> Looker Block dashboards

Gemini Enterprise, Model Armor and Antigravity logs (optional, step 8)
  -> short-lived raw log bucket
  -> Cloud Run exporter job, hourly: redacted user-level tables
  -> executive, change-management and admin dashboards
```

Cloud Scheduler triggers the Cloud Run exporter every day for each Gemini Enterprise engine. The exporter merges its own staging data into `export_history` in the same run, so the history table is updated the moment an export succeeds — there is no separate scheduled merge to keep in sync.

> **Note:** You can run the Cloud Run job manually for testing, but production deployments should use Cloud Scheduler so the dashboards keep refreshing without operator work.

## Before you begin

You need:

- A GCP project with billing enabled.
- Permission to create BigQuery datasets, service accounts, IAM bindings, Cloud Run jobs, Cloud Scheduler jobs, and Cloud Monitoring alert policies.
- `gcloud` and Terraform installed locally (plus Docker if you build the exporter image yourself).
- A Gemini Enterprise engine ID and location, for example `eu` or `global`.
- A Looker instance with a BigQuery connection.
- Workspace admin access if you want Workspace Gemini audit log reporting.

Use matching BigQuery locations for your engines. Global and US Gemini Enterprise engines export to BigQuery `US`; EU engines export to BigQuery `EU`. Terraform validates this and refuses to apply a mixed-region configuration. If a client has both, deploy this stack twice (see the region requirement below).

## 1. Set up the Workspace Gemini export

Workspace Gemini usage comes from the Google Workspace audit log export. This export is configured in the Workspace Admin console, not Terraform.

1. As a Workspace **super admin**, go to **Reporting > BigQuery Export** (now labelled "Enable audit and reports data export to Google BigQuery").
2. Enable the export.
3. Choose the destination GCP project (e.g. `your-gcp-project-id`).
4. Note the dataset name it creates. We use `workspace_audit` as the example name throughout this guide; whatever your dataset is called, set the Looker `workspace_dataset` constant to that exact name at install time.
5. A Google-managed service account is automatically added as an editor on that project.
6. Wait for the export to start. The `activity` table backfills history and can take up to ~24 hours to first appear.

Verify the export with this query (swap in your dataset name):

```sql
SELECT
  gemini_for_workspace.app_name,
  gemini_for_workspace.feature_source,
  gemini_for_workspace.event_category,
  COUNT(*) AS event_count
FROM `your-gcp-project-id.workspace_audit.activity`
WHERE gemini_for_workspace.app_name IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY event_count DESC
LIMIT 100;
```

If the query returns rows, the Workspace side is ready for Looker. The block reads
this table directly (no merge needed) and uses `event_category` to separate active
usage (`active_generate`, `active_conversations`, `active_summarize`) from passive
surfacing (`inactive`).

> **Note:** This export only covers Workspace Gemini activity (Gmail, Chat, Meet,
> Drive, Docs, etc.). Gemini Enterprise engine metrics come from the separate
> export API in the next steps. The export is created in the Admin console, not by
> Terraform, and requires a Workspace super admin.

### Check the export's location

The AI adoption tabs put Gemini for Workspace next to Gemini Enterprise, which means joining the two in one query. BigQuery can't join datasets in different locations, and the Workspace export often lands in `US` while `gemini_analytics` is in `EU`. Compare the two:

```sh
bq show --format=prettyjson your-gcp-project-id:workspace_audit | grep '"location"'
bq show --format=prettyjson your-gcp-project-id:gemini_analytics | grep '"location"'
```

- **Same location:** set the **Workspace audit export** install prompt to `same_region`.
- **Different locations:** either set it to `separate_region`, so only the dashboard's Workspace Gemini tab uses the export, or copy the export into the Gemini location. To copy, set `workspace_audit_dataset_id` and `workspace_audit_location` in `terraform.tfvars`. Terraform then creates a daily BigQuery cross-region copy into `workspace_audit_copy`, and the `looker_workspace_settings` output gives the install values. A dataset copy in the BigQuery console does the same thing by hand. The copy moves each changed table in full every day, so expect cross-region egress charges on large tenants.

## 2. Get the exporter image

Terraform deploys a Cloud Run job, and `exporter_image` must point at an existing container image. There are two ways to get one:

**Option A — use a published image (fastest).** If you (or your deployment partner) publish the exporter through this repo's `publish-image.yml` GitHub Actions workflow, point `exporter_image` at that image and skip the build entirely. Pin a version tag rather than `latest` so Terraform deploys a known build.

**Option B — build it yourself.** Create an Artifact Registry repository and build with Cloud Build:

```sh
gcloud auth login
gcloud config set project your-gcp-project-id

gcloud artifacts repositories create gemini-analytics \
  --repository-format=docker \
  --location=europe \
  --description="Gemini analytics exporter images"

gcloud builds submit apps/exporter \
  --tag europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:v0.2.0
```

Use a repository location that matches your deployment preference. For a US deployment, use a US Artifact Registry location and update `exporter_image` in Terraform.

## 3. Configure Terraform

Copy the example variables file:

```sh
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id       = "your-gcp-project-id"
region           = "europe-west2"
dataset_location = "EU"
exporter_image   = "europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:v0.2.0"

# Recommended: get an email when an export run fails.
alert_email = "data-team@example.com"

# Optional: let Terraform grant the Looker connection's service account access.
looker_service_account_email = "looker-connection@your-gcp-project-id.iam.gserviceaccount.com"

engines = [
  {
    engine_id         = "customer-support-engine"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "0 6 * * *"
    time_zone         = "Etc/UTC"
  }
]
```

Each engine maps to one Gemini Enterprise app. To track several apps, add one object per engine and stagger the schedules by at least one minute. Set `display_name` to a friendly app label — it is stored as `app_name` on every row in `export_history` and exposed as the **App** dimension and dashboard filter in Looker, so you can tell apps apart and slice or group by them. If omitted, `app_name` falls back to the raw `engine_id`.

```hcl
engines = [
  {
    engine_id         = "customer-support-engine"
    display_name      = "Support Copilot"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "0 6 * * *"
  },
  {
    engine_id         = "sales-enablement-engine"
    display_name      = "Sales Assistant"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "1 6 * * *"
  }
]
```

Each engine exports to its own staging tables, and each run merges its own window into the single `export_history` table, so the data is unioned automatically and distinguished by `engine_id` / `app_name`. Staggering keeps the pipeline below the Gemini Enterprise analytics export rate limits.

### Region requirement (important)

> **All engines in one deployment must live in the same location.** A Gemini Enterprise app's analytics export runs in the region of the app's data (an `eu` app exports in the EU, a `global` app exports in the US), and BigQuery cannot load or `UNION` data across regions. Because every engine merges into a single `export_history` table in `dataset_location`, mixing regions in one deployment fails. Terraform enforces this: a mixed-region `engines` list or a `dataset_location` that doesn't match the engine location fails validation before anything is created.

To get unified analytics across engines, keep them in the same region. **If you have apps in two regions (for example EU and US), deploy this block twice** — once per region, each with its own project/datasets and its own `dataset_location` — and point a separate Looker connection at each. This keeps each region's data (including search query text and user emails) resident in its own region rather than copying personal data across jurisdictions. A single cross-region dashboard would require deliberately consolidating data into one region, which is a data-residency decision to make explicitly rather than a default of this pipeline.

## 4. Deploy the infrastructure

Run Terraform from `infra/terraform` (see `infra/terraform/README.md` for the remote state setup):

```sh
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Terraform creates:

- `gemini_analytics_staging`, the raw 30-day export dataset.
- `gemini_analytics.export_history`, the partitioned, full-fidelity history table for Looker.
- `gemini_analytics.ai_interventions` and `gemini_analytics.ai_value_outcomes`, optional empty tables for change-management interventions and validated outcomes.
- A Cloud Run job named `gemini-analytics-exporter` that exports and merges in one run.
- One Cloud Scheduler job per engine, with retries.
- Service accounts and IAM bindings for the exporter and scheduler.
- If `alert_email` is set: an email notification channel and an alert policy on exporter failures.
- If `looker_service_account_email` is set: read access for the Looker connection.

## 5. Run the first export

You can wait for the next Cloud Scheduler run, or start one manually:

```sh
gcloud scheduler jobs run gemini-export-customer-support-engine \
  --location=europe-west2
```

Check the Cloud Run job logs:

```sh
gcloud logging read \
  'resource.type="cloud_run_job" AND resource.labels.job_name="gemini-analytics-exporter"' \
  --limit=50 \
  --format=json
```

A healthy run logs `export_started`, `export_completed`, and `merge_completed`. Because the merge runs inside the job, `export_history` is ready as soon as the run finishes:

```sql
SELECT
  metric_date,
  app_name,
  data_source,
  product_type,
  device_type,
  daily_active_user_count,
  search_count,
  seats_claimed
FROM `your-gcp-project-id.gemini_analytics.export_history`
ORDER BY metric_date DESC
LIMIT 100;
```

Each row preserves the original export grain, so different rows carry different
metrics (active users per `product_type`, activity per `device_type`, seats on
the aggregated rows). The Looker views slice these into clean explores.

## 6. Connect Looker to BigQuery

Create or confirm a Looker BigQuery connection that can read:

- `your-gcp-project-id.gemini_analytics.export_history`
- `your-gcp-project-id.workspace_audit.activity`, if using Workspace Gemini reporting

If you set `looker_service_account_email` in Terraform, the analytics dataset and job-user grants are already in place. Otherwise grant the Looker service account:

- **BigQuery Data Viewer** on `gemini_analytics`
- **BigQuery Job User** on the GCP project

Either way, grant **BigQuery Data Viewer** on the Workspace audit dataset manually if you use Workspace reporting (that dataset is created by the Admin console, not Terraform). The Workspace model also builds a persisted derived table, so the connection needs a PDT/scratch dataset configured (standard for Looker BigQuery connections).

In Looker, test the connection before installing the block.

## 7. Install the Looker block

The block is drop-in installable on any Looker instance whose BigQuery connection can read the `gemini_analytics` dataset.

**One-click install (recommended):** in Looker, open **Marketplace → gear menu → Install via Git URL**, paste this repo's Git URL and branch, and fill in the prompts:

- **BigQuery Connection** — the connection that reads `gemini_analytics`
- **BigQuery Project ID** — the project holding the dataset (e.g. `your-gcp-project-id`)
- **Gemini analytics dataset** — prefilled `gemini_analytics`

The remaining prompts are optional and have defaults:

| Prompt | Default | What it does |
| --- | --- | --- |
| Workspace audit dataset | `workspace_audit` | Name of the Workspace export (or its copy) |
| Workspace audit export | `none` | `none`, `separate_region` or `same_region` (see step 1) |
| Reporting time zone | `UTC` | Time zone for hour-of-day charts |
| Power / Normal user thresholds | `12` / `4` | AI-active days in 28 for each cohort |
| Seat costs, loaded hourly rate | `0` | Turn on spend and value figures |
| Currency symbol | `$` | Shown on spend and value figures |
| Minutes saved per AI action | conservative per-feature values | Basis of the time-saved estimate |
| Employee domains / exclusions | blank / defaults | Scope employee adoption rates and remove service accounts or guests |
| Use-case mapping | built-in defaults | Maps technical feature names to business-facing use cases |
| Org-unit depth for departments | `1` | How much of the org-unit path makes a department |

Click **Install** and the model, explores and dashboards are ready. To change a value later, use **Manage** on the listing. With the defaults, the dashboards load; tiles for sources you haven't set up show data-state messages rather than empty panels where possible.

See `looker/README.md` for the alternative "plain Git project" install and required Looker permissions (`develop`, `manage_models`, `deploy`).

After installing, open **Gemini | Admin AI Telemetry** and start on **Data Health**. The block installs one model and three role-based dashboards: **Gemini | Executive AI Adoption**, **Gemini | AI Change Management** and **Gemini | Admin AI Telemetry**. Without the log pipeline, the admin dashboard's Gemini Enterprise export telemetry already works: seats, active users and retention, searches and answers, feedback and agents. Workspace Gemini works once the Workspace export is set up. Step 8 fills the cross-product executive and change-management views.

The **Gemini Enterprise App** filter lets multi-app deployments slice every Gemini Enterprise tile per app.

## 8. Add user-level Change Management analytics (optional)

The export API in steps 2 to 5 only gives app-level totals. To see who is using Gemini Enterprise, which features, agents and skills they use, how Antigravity is being adopted, and whose prompts Model Armor blocks (and for what), turn on the log pipeline. It fills the executive, change-management and admin views that use user-level telemetry.

### How the log pipeline handles prompts

Gemini Enterprise logs carry prompt and response text, and the pipeline is built so that text never reaches a table Looker can read:

```text
Gemini Enterprise, Model Armor and Antigravity logs
  -> log sinks (only the log types listed below)
  -> gemini-logs-raw Log Analytics bucket (kept for 2 days, exporter-only access)
  -> Cloud Run exporter, hourly (MODE=transform_logs)
       copies an allow-list of metadata fields into curated tables
  -> gemini_analytics.ge_* and antigravity_usage tables
  -> executive, change-management and admin dashboards
```

- The raw bucket keeps entries for `raw_log_retention_days` (default 2). Only the exporter service account can read its linked BigQuery dataset.
- The transform SQL in `apps/exporter/src/gemini_exporter/sql/logs/` reads named metadata fields only: user, app, method, agent, model, feature, token counts, skill names, verdicts. CI fails if it references prompt, response, grounding, file-name or tool-argument fields.
- Connector error messages are matched against patterns to give an error category and are not copied.
- Antigravity prompt logs (`InferenceRequestLog`) and the content-only `gen_ai.user.message` / `gen_ai.choice` logs are never routed.

> **Important:** Log sinks copy entries; they don't move them. Cloud Logging still keeps the original entries, prompt text included, in the project's `_Default` bucket for 30 days. Set `exclude_content_logs_from_default_bucket = true` to stop that. The sinks still receive the entries, but anyone who relies on reading prompts in Logs Explorer (for example during an incident review) loses that.

### Before you begin

Turn these on in the Gemini Enterprise project (and in the Antigravity and Model Armor projects, if they're different):

1. **Gemini Enterprise observability.** In the app's observability settings, turn on user activity logging. Turning on the OpenTelemetry (gen_ai) instrumentation as well adds token, tool and skill reporting. Both write to Cloud Logging.
2. **Antigravity logging (if you use Antigravity).** Turn on inference logging in metadata-only mode. The dashboards only need the response metadata (user, client, model, tokens); prompt logging isn't used.
3. **Model Armor (for the Safety & Governance tab).** Attach a Model Armor template to the app in **Inspect and block** mode, and set `enable_model_armor_audit_logs = true` in Terraform. This turns on Data Access audit logs for `modelarmor.googleapis.com`, which record the verdict per filter category but not the screened text. Don't turn on Model Armor's own sanitize-operation logging: those entries contain the prompt.
4. **Region.** `dataset_location` must be `EU` or `US`, because the raw log bucket and the analytics dataset have to share a BigQuery location.

### Turn on the pipeline

Add to `terraform.tfvars`:

```hcl
enable_log_pipeline           = true
enable_model_armor_audit_logs = true

# Only if logs come from more than the engine project:
# log_source_project_ids = ["your-gemini-enterprise-project-id", "your-antigravity-project-id"]
```

Then `terraform apply`. On top of the base pipeline, Terraform creates:

- The `gemini-logs-raw` Log Analytics bucket and its linked, read-only `gemini_logs_raw` BigQuery dataset.
- Three log sinks per source project (`gemini-analytics-usage`, `gemini-analytics-audit`, `gemini-analytics-antigravity`).
- Eight curated tables in `gemini_analytics` (`ge_user_activity`, `ge_model_calls`, `ge_tool_calls`, `ge_connector_activity`, `ge_safety_events`, `ge_admin_events`, `antigravity_usage`, `ge_user_licenses`).
- Two scheduler jobs on the existing exporter: `gemini-transform-logs` (hourly) and `gemini-snapshot-licenses` (daily licence snapshot from the userLicenses API).
- A custom role in the engine project that lets the exporter list user licences.

### Verify the log pipeline

Use Gemini Enterprise for a few minutes, then run the transform instead of waiting for the hour:

```sh
gcloud scheduler jobs run gemini-transform-logs --location=europe-west2
gcloud scheduler jobs run gemini-snapshot-licenses --location=europe-west2
```

A healthy transform logs `transform_completed` once per table, then `transform_logs_completed`. Check that user-level rows are arriving:

```sql
SELECT event_date, feature, COUNT(*) AS interactions, COUNT(DISTINCT user_email) AS users
FROM `your-gcp-project-id.gemini_analytics.ge_user_activity`
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1, 2
ORDER BY interactions DESC;
```

### Check that Model Armor verdicts and user attribution work

Model Armor is called by the Gemini Enterprise service agent, so its audit entries don't name the user. The transform matches each verdict to a user through the shared trace ID. Failing that, it uses the nearest assistant call within 10 seconds, preferring a blocked answer when the verdict was a match (`attribution_method = 'time_window'`). With many people prompting at once, a time-window match can pick the wrong person, so treat those rows as indicative. Google's documentation is inconsistent about whether the audit entry includes the per-category verdict, so test it once in a test app:

1. Send a prompt your Model Armor template should block (for example a prompt-injection attempt).
2. Run `gemini-transform-logs` as above.
3. Query the safety table:

```sql
SELECT source, screened_content, category, filter_match_state, attribution_method, user_email
FROM `your-gcp-project-id.gemini_analytics.ge_safety_events`
WHERE event_date = CURRENT_DATE()
ORDER BY event_ts DESC
LIMIT 20;
```

You should see a `MODEL_ARMOR` row with `category` set (for example `pi_and_jailbreak`), `filter_match_state = 'MATCH_FOUND'`, `attribution_method` of `trace` or `time_window`, and your email. You should also see a `GEMINI_ENTERPRISE` row with `category = 'customer_policy_violation'`.

If the `MODEL_ARMOR` rows arrive with `filter_match_state` and `category` both null, the audit entries don't carry the verdict in your project. The dashboard still shows who was blocked, from the `GEMINI_ENTERPRISE` rows, but not the category. Getting the category then needs Model Armor's sanitize-operation logs, which include the prompt text. Decide deliberately before turning those on.

If most rows are `unattributed`, check that the trace ID reaches both logs, and that screening and the assistant call land within 10 seconds of each other.

### Role-based dashboards

The log pipeline fills the role-based dashboards. Cross-product views cover Gemini Enterprise, Gemini for Workspace (when the Workspace export is `same_region`) and Antigravity together:

- **Gemini | Executive AI Adoption**: canonical activation, regular adoption, engagement, retention, licence spend to review, data trust and the top recommended actions.
- **Gemini | AI Change Management**: opportunity queue, cohort movement, use-case adoption, authorised people/coaching lists, licence demand and intervention measurement.
- **Gemini | Admin AI Telemetry**: Gemini Enterprise export telemetry, Workspace event diagnostics, agents and models, Antigravity, governance and data health.

Cohorts count AI-active days in the trailing 28 days across every product: a Gemini Enterprise prompt or search, an active Workspace Gemini event (generate, converse, summarise), or an Antigravity request. Non-AI is everyone in the population (Workspace users seen in the audit log, licensed Gemini Enterprise users) with none. Time saved is an estimate: AI actions times the **Minutes saved per AI action** setting, which you should agree with the client before presenting it.

To split by department, enable the Workspace export (step 1) and set the **Workspace audit export** install prompt to `same_region`.

> **Note:** User-level history starts the day you enable the pipeline; logs from before then can't be backfilled. Segments are a rolling 28 days, and for people who used Gemini Enterprise before the pipeline was on, the licence API's last-login date keeps them out of **Never used**. If you install the block without enabling the pipeline, user-level tiles show missing or empty source states; the Gemini Enterprise export telemetry, Workspace Gemini and Data Health views are unaffected.

## Verify the full setup

Use this checklist before handing the dashboard to users:

1. The Workspace Admin export has an `activity` table.
2. Cloud Scheduler has one enabled job per Gemini Enterprise engine.
3. The Cloud Run exporter logs `export_completed` and `merge_completed`.
4. `gemini_analytics.export_history` contains recent rows.
5. The Looker BigQuery connection tests successfully.
6. LookML validation passes.
7. **Gemini | Admin AI Telemetry** → **Data Health** shows no red rows for the sources you set up.
8. The three dashboards load with the default date filter.
9. If the log pipeline is on: `gemini-transform-logs` logs `transform_logs_completed`, and `ge_user_activity` has rows from the last hour.

## Troubleshooting

Start with **Gemini | Admin AI Telemetry** → **Data Health**: it names the missing or stale source and the fix.

### Gemini for Workspace tiles are empty on the AI adoption tabs

The **Workspace audit export** install setting must be `same_region`, and the Workspace dataset must be in the same BigQuery location as `gemini_analytics` (step 1). If Data Health shows a "not found in location" error, the locations differ: copy the export or switch the setting to `separate_region`.

### The Workspace Gemini tab is empty

Confirm the **Workspace audit export** install setting isn't `none`, the Workspace Admin BigQuery export is enabled, and the `activity` table has rows where `gemini_for_workspace.app_name IS NOT NULL`. New exports can take about 24 hours to appear.

### The Gemini Enterprise Analytics tab is empty

Check the Cloud Run job logs first. A healthy run logs `export_started`, `export_completed`, and `merge_completed`. If `merge_skipped_empty_staging` appears, the export produced no rows — usually a brand-new engine with no usage yet.

### The exporter fails with permission errors

Confirm Terraform applied successfully and that the exporter service account has access to Discovery Engine and BigQuery (both datasets).

### The export runs in the wrong BigQuery location

Check the engine location and `dataset_location`. EU engines need EU BigQuery datasets. Global and US engines need US BigQuery datasets. Terraform validates this combination at plan time.

### I want to know when the pipeline breaks

Set `alert_email` in `terraform.tfvars`. Failed exporter executions then trigger an email through Cloud Monitoring; without it, failures only show up in logs. The same alert covers the log transform. Treat a failing transform as urgent: raw entries expire after `raw_log_retention_days`, and anything not transformed by then is gone.

### The user-level tabs are empty

Check that `ge_user_activity` has rows. If it doesn't, look for entries in Logs Explorer with `logName:"gemini_enterprise_user_activity"`: none means observability logging is off for the app. If entries exist but the table is empty, check the `gemini-transform-logs` run logs. If the Safety & Governance tab shows no `MODEL_ARMOR` source, Model Armor isn't attached to the app or `enable_model_armor_audit_logs` is off.

## Repository layout

```text
gemini-enterprise-looker-block/
├── .github/workflows    # CI (terraform, ruff, pytest, LookML checks) + image publish
├── apps/exporter        # Cloud Run exporter app (export + merge)
├── infra/terraform      # Client-hosted GCP infrastructure
├── looker               # LookML views, explores, the model and the dashboard
├── scripts              # CI helper scripts (LookML parse check)
├── manifest.lkml        # Looker project manifest (constants) — project root
├── marketplace.json     # Looker Marketplace listing + install prompts
└── LICENSE              # MIT license (required for Marketplace blocks)
```

The repo root doubles as the Looker project root: Looker reads `manifest.lkml` and `marketplace.json` here and discovers the LookML under `looker/`. Non-LookML files (Terraform, Python) are ignored by Looker.

## Next steps

- Review `infra/terraform/README.md` for Terraform variable details.
- Review `looker/README.md` for Looker model and dashboard details.
- Validate the export schema against a real Gemini Enterprise engine before using the dashboards in production.
