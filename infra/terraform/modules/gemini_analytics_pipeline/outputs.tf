output "staging_dataset_id" {
  description = "BigQuery staging dataset ID."
  value       = local.staging_dataset_id
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

output "raw_logs_view" {
  description = "Linked BigQuery view over the raw log bucket (exporter-only; contains prompt text). Null when the log pipeline is disabled."
  value       = var.enable_log_pipeline ? local.raw_logs_view : null
}

output "log_sink_writer_identities" {
  description = "Writer identity of each log sink, keyed by source project and sink kind."
  value       = var.manage_source_project_resources ? module.source[0].log_sink_writer_identities : {}
}

output "exporter_service_account_email" {
  description = "Service account used by the exporter job."
  value       = google_service_account.exporter.email
}

output "looker_workspace_settings" {
  description = "Values for the Looker block's workspace_dataset and workspace_export settings."
  value = var.workspace_audit_dataset_id == "" ? null : {
    workspace_dataset = local.copy_workspace_audit ? google_bigquery_dataset.workspace_copy[0].dataset_id : var.workspace_audit_dataset_id
    workspace_export  = local.copy_workspace_audit || upper(var.workspace_audit_location) == upper(var.dataset_location) ? "same_region" : "separate_region"
  }
}
