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

resource "google_project_iam_member" "scheduler_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.scheduler.email}"
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
