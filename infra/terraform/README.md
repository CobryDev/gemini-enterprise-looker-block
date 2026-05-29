# Deploy the Gemini analytics pipeline

Use this Terraform deployment to create the client-hosted GCP infrastructure for the Gemini Enterprise export pipeline.

For the full export-to-dashboard walkthrough, start with the root `README.md`.

## What Terraform creates

Terraform creates the scheduled ETL path for Gemini Enterprise metrics:

- BigQuery staging dataset for the rolling 30-day export window.
- BigQuery analytics dataset with a partitioned, full-fidelity `export_history` table.
- Cloud Run job for the exporter container.
- Cloud Scheduler jobs, one per Gemini Enterprise engine.
- Secret Manager secret containing the engine configuration.
- BigQuery scheduled query that merges staging exports into history.
- Service accounts and IAM bindings for the exporter, scheduler, and scheduled query.

Cloud Scheduler is part of the required production setup. It invokes the Cloud Run job every day so the Gemini Enterprise staging export stays fresh. The BigQuery scheduled query then handles the transform step into `export_history`.

## Before you apply

Build and publish the exporter image first. Terraform expects `exporter_image` to point at an existing image:

```text
europe-docker.pkg.dev/your-gcp-project-id/gemini-analytics/gemini-exporter:latest
```

Set `dataset_location` to the location required by your Gemini Enterprise engine:

- Use `EU` for EU engines.
- Use `US` for global or US engines.

If you need both EU and US engines, run separate deployments or extend the module to manage separate dataset locations.

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

Add one `engines` entry per Gemini Enterprise engine. Stagger schedules by one minute to stay below API rate limits.

## Apply Terraform

```sh
terraform init
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

## Workspace Gemini export

Workspace Gemini audit logs are not created by Terraform. Configure them in the Workspace Admin console:

1. Go to **Reporting > BigQuery Export**.
2. Enable the export.
3. Choose a destination project and dataset, for example `workspace_audit`.
4. Confirm the export service account has **BigQuery Data Editor** on the destination.
5. Set the `workspace_dataset` LookML constant to that dataset.

## Notes

- The scheduled merge SQL assumes the exported staging tables expose `engine_id`, `metric_date`, `metric_type`, and `metric_value` columns.
- Confirm the exact export schema during the first real Gemini Enterprise spike and adjust `sql/merge_export_history.sql.tpl` if Google changes the payload shape.
- Terraform enables the Google APIs needed by the module, but the caller still needs permission to enable services and create IAM bindings.
