# bigquery.jobUser is the narrowest role that lets a principal run query jobs,
# and running jobs is a project-level capability with no resource-level binding,
# so it can only be granted at the project. Data access stays least-privilege
# via the dataset-level bindings below.
resource "google_project_iam_member" "exporter_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.exporter.email}"
}

resource "google_bigquery_dataset_iam_member" "exporter_staging_editor" {
  project    = local.staging_project_id
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.exporter.email}"
}

# The exporter runs the export_history merge itself after each export, so it
# needs write access to the analytics dataset.
resource "google_bigquery_dataset_iam_member" "exporter_analytics_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.exporter.email}"
}

resource "google_project_iam_member" "exporter_discovery_engine_viewer" {
  project = local.engine_project_id
  role    = "roles/discoveryengine.viewer"
  member  = "serviceAccount:${google_service_account.exporter.email}"
}

resource "google_project_iam_member" "exporter_engine_project_service_usage_consumer" {
  project = local.engine_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.exporter.email}"
}

# The scheduler only needs to execute one specific job, with env overrides, so
# scope the binding to that job rather than granting run.developer on the whole
# project. runWithOverrides is required because the scheduler passes per-engine
# container overrides; jobsExecutorWithOverrides is the minimal role for that.
resource "google_cloud_run_v2_job_iam_member" "scheduler_job_executor" {
  project  = google_cloud_run_v2_job.exporter.project
  location = google_cloud_run_v2_job.exporter.location
  name     = google_cloud_run_v2_job.exporter.name
  role     = "roles/run.jobsExecutorWithOverrides"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

# Optional: grant the Looker connection service account read access so the
# block works without manual IAM steps. The Workspace audit dataset is not
# managed by this module, so grant access to it manually if used.
resource "google_bigquery_dataset_iam_member" "looker_analytics_viewer" {
  count = var.looker_service_account_email != "" ? 1 : 0

  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.looker_service_account_email}"
}

resource "google_project_iam_member" "looker_bigquery_job_user" {
  count = var.looker_service_account_email != "" ? 1 : 0

  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${var.looker_service_account_email}"
}
