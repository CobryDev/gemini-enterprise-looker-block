output "staging_project_id" {
  description = "Project holding the staging dataset."
  value       = local.staging_project_id
}

output "staging_dataset_id" {
  description = "BigQuery staging dataset ID."
  value       = google_bigquery_dataset.staging.dataset_id
}

output "raw_logs_project_id" {
  description = "Project holding the raw log bucket and linked dataset."
  value       = local.raw_logs_project_id
}

output "raw_logs_view" {
  description = "Linked BigQuery view over the raw log bucket (exporter-only; contains prompt text). Null when the log pipeline is disabled."
  value       = var.enable_log_pipeline ? local.raw_logs_view : null
}

output "log_sink_writer_identities" {
  description = "Writer identity of each log sink, keyed by source project and sink kind."
  value       = { for key, sink in google_logging_project_sink.gemini : key => sink.writer_identity }
}
