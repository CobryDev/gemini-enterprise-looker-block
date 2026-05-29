output "staging_dataset_id" {
  description = "BigQuery staging dataset ID."
  value       = google_bigquery_dataset.staging.dataset_id
}

output "staging_project_id" {
  description = "BigQuery staging project ID."
  value       = local.staging_project_id
}

output "analytics_dataset_id" {
  description = "BigQuery analytics dataset ID."
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "export_history_table" {
  description = "Fully qualified export history table."
  value       = "${var.project_id}.${google_bigquery_dataset.analytics.dataset_id}.${google_bigquery_table.export_history.table_id}"
}

output "cloud_run_job_name" {
  description = "Cloud Run exporter job name."
  value       = google_cloud_run_v2_job.exporter.name
}

output "exporter_service_account_email" {
  description = "Service account used by the exporter job."
  value       = google_service_account.exporter.email
}
