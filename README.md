# Set up Gemini analytics dashboards in Looker

Use this guide to export Gemini Enterprise and Workspace Gemini usage into BigQuery, run the daily pipeline, and install the Looker block that turns the exports into dashboards.

The default setup is client-hosted: the client owns the GCP project, BigQuery datasets, Cloud Run job, scheduler, and Looker connection.

## How the pipeline works

The pipeline has two sources and one Looker block:

```text
Gemini Enterprise analytics API
  -> Cloud Scheduler
  -> Cloud Run exporter job
  -> BigQuery staging dataset
  -> Scheduled BigQuery merge
  -> BigQuery analytics dataset
  -> Looker Block dashboards

Workspace Admin BigQuery export
  -> BigQuery Workspace audit dataset
  -> Looker Block dashboards
```

Cloud Scheduler is required for the automated ETL. It triggers the Cloud Run exporter every day for each Gemini Enterprise engine. The Terraform deployment creates those scheduler jobs for you.

> **Note:** You can run the Cloud Run job manually for testing, but production deployments should use Cloud Scheduler so the dashboards keep refreshing without operator work.

## Before you begin

You need:

- A GCP project with billing enabled.
- Permission to create BigQuery datasets, service accounts, IAM bindings, Cloud Run jobs, Cloud Scheduler jobs, Secret Manager secrets, and BigQuery scheduled queries.
- `gcloud`, Docker, and Terraform installed locally.
- A Gemini Enterprise engine ID and location, for example `eu` or `global`.
- A Looker instance with a BigQuery connection.
- Workspace admin access if you want Workspace Gemini audit log reporting.

Use matching BigQuery locations for your engines. Global and US Gemini Enterprise engines export to BigQuery `US`; EU engines export to BigQuery `EU`. If a client has both, deploy separate regional datasets or extend the Terraform module to manage both locations.

## 1. Set up the Workspace Gemini export

Workspace Gemini usage comes from the Google Workspace audit log export. This export is configured in the Workspace Admin console, not Terraform.

1. As a Workspace **super admin**, go to **Reporting > BigQuery Export** (now labelled "Enable audit and reports data export to Google BigQuery").
2. Enable the export.
3. Choose the destination GCP project (e.g. `your-gcp-project-id`).
4. Note the dataset name it creates (e.g. `raw_google_workspace_exports`). You set the Looker `workspace_dataset` constant to this value later.
5. A Google-managed service account is automatically added as an editor on that project.
6. Wait for the export to start. The `activity` table backfills history and can take up to ~24 hours to first appear.

Verify the export with this query (swap in your dataset name):

```sql
SELECT
  gemini_for_workspace.app_name,
  gemini_for_workspace.feature_source,
  gemini_for_workspace.event_category,
  COUNT(*) AS event_count
FROM `your-gcp-project-id.raw_google_workspace_exports.activity`
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

## 2. Build and publish the Gemini Enterprise exporter

Terraform deploys a Cloud Run job, but the container image must exist first.

Set your project:

```sh
gcloud auth login
gcloud config set project your-gcp-project-id
```

Create an Artifact Registry repository for the exporter image:

```sh
gcloud artifacts repositories create gemini-analytics \
  --repository-format=docker \
  --location=europe \
  --description="Gemini analytics exporter images"
```

Build and push the image:

```sh
gcloud builds submit apps/exporter \
  --tag europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:latest
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
exporter_image   = "europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:latest"

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

For multiple engines, add one object per engine and stagger the schedules by at least one minute:

```hcl
engines = [
  {
    engine_id         = "customer-support-engine"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "0 6 * * *"
  },
  {
    engine_id         = "sales-enablement-engine"
    location          = "eu"
    endpoint_location = "eu"
    schedule          = "1 6 * * *"
  }
]
```

Staggering keeps the pipeline below the Gemini Enterprise analytics export rate limits.

## 4. Deploy the infrastructure

Run Terraform from `infra/terraform`:

```sh
terraform init
terraform plan
terraform apply
```

Terraform creates:

- `gemini_analytics_staging`, the raw 30-day export dataset.
- `gemini_analytics.export_history`, the partitioned, full-fidelity history table for Looker.
- A Cloud Run job named `gemini-analytics-exporter`.
- One Cloud Scheduler job per engine.
- A Secret Manager secret containing the engine config.
- A BigQuery scheduled query that merges staging data into `export_history`.
- Service accounts and IAM bindings for the exporter, scheduler, and merge query.

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

Verify staging tables were created:

```sql
SELECT table_name
FROM `your-gcp-project-id.gemini_analytics_staging.INFORMATION_SCHEMA.TABLES`
ORDER BY creation_time DESC;
```

The scheduled BigQuery merge runs daily after the export. To test the merge immediately, copy the SQL from `infra/terraform/sql/merge_export_history.sql.tpl`, replace the template variables, and run it in BigQuery.

Verify the history table:

```sql
SELECT
  metric_date,
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

Grant the Looker service account:

- **BigQuery Data Viewer** on `gemini_analytics`
- **BigQuery Data Viewer** on `workspace_audit`
- **BigQuery Job User** on the GCP project

In Looker, test the connection before installing the block.

## 7. Install the Looker block

The block is drop-in installable on any Looker instance whose BigQuery connection can read the `gemini_analytics` dataset.

**One-click install (recommended):** in Looker, open **Marketplace → gear menu → Install via Git URL**, paste this repo's Git URL and branch, and fill in the prompts:

- **BigQuery Connection** — the connection that reads `gemini_analytics`
- **BigQuery Project ID** — the project holding the dataset (e.g. `your-gcp-project-id`)
- **Gemini analytics dataset** — prefilled `gemini_analytics`
- **Workspace audit dataset** — prefilled `workspace_audit` (optional)

Click **Install** and the models, explores, and dashboards are ready. To change a value later, use **Manage** on the listing.

See `looker/README.md` for the alternative "plain Git project" install and required Looker permissions (`develop`, `manage_models`, `deploy`).

After installing, open the included dashboards:

- **Gemini Enterprise Adoption Overview**
- **Gemini Enterprise Usage and Quality**
- **Gemini Enterprise Agent Activity**
- **Gemini Enterprise Value Realised**

## Verify the full setup

Use this checklist before handing the dashboard to users:

1. The Workspace Admin export has an `activity` table.
2. Cloud Scheduler has one enabled job per Gemini Enterprise engine.
3. The Cloud Run exporter logs `export_completed`.
4. BigQuery staging tables exist in `gemini_analytics_staging`.
5. `gemini_analytics.export_history` contains recent rows.
6. The Looker BigQuery connection tests successfully.
7. LookML validation passes.
8. Dashboards load with a 90-day date filter.

## Troubleshooting

### The Workspace dashboard is empty

Confirm the Workspace Admin BigQuery export is enabled and the `activity` table has rows where `gemini_for_workspace.app_name IS NOT NULL`. New exports can take about 24 hours to appear.

### The Gemini Enterprise dashboard is empty

Check the Cloud Run job logs first. If the export succeeded, check the staging dataset, then run or wait for the scheduled BigQuery merge into `export_history`.

### The exporter fails with permission errors

Confirm Terraform applied successfully and that the exporter service account has access to Discovery Engine, BigQuery, and Secret Manager.

### The export runs in the wrong BigQuery location

Check the engine location and `dataset_location`. EU engines need EU BigQuery datasets. Global and US engines need US BigQuery datasets.

## Repository layout

```text
gemini-enterprise-looker-block/
├── apps/exporter        # Cloud Run exporter app
├── infra/terraform      # Client-hosted GCP infrastructure
├── looker               # LookML views, explores, models, dashboards
├── manifest.lkml        # Looker project manifest (constants) — project root
├── marketplace.json     # Looker Marketplace listing + install prompts
└── LICENSE              # MIT license (required for Marketplace blocks)
```

The repo root doubles as the Looker project root: Looker reads `manifest.lkml` and `marketplace.json` here and discovers the LookML under `looker/`. Non-LookML files (Terraform, Python) are ignored by Looker.

## Next steps

- Review `infra/terraform/README.md` for Terraform variable details.
- Review `looker/README.md` for Looker model and dashboard details.
- Validate the export schema against a real Gemini Enterprise engine before using the dashboards in production.
