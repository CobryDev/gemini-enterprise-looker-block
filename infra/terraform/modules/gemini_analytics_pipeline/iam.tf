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

resource "google_secret_manager_secret_iam_member" "exporter_engine_config_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.engine_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.exporter.email}"
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

resource "google_project_iam_member" "scheduled_query_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.scheduled_query.email}"
}

resource "google_bigquery_dataset_iam_member" "scheduled_query_staging_viewer" {
  project    = local.staging_project_id
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.scheduled_query.email}"
}

resource "google_bigquery_dataset_iam_member" "scheduled_query_analytics_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.scheduled_query.email}"
}
