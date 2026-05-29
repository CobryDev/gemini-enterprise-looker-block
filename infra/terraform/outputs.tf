output "staging_dataset_id" {
  description = "BigQuery staging dataset ID."
  value       = module.gemini_analytics_pipeline.staging_dataset_id
}

output "staging_project_id" {
  description = "BigQuery staging project ID."
  value       = module.gemini_analytics_pipeline.staging_project_id
}

output "analytics_dataset_id" {
  description = "BigQuery analytics dataset ID."
  value       = module.gemini_analytics_pipeline.analytics_dataset_id
}

output "export_history_table" {
  description = "Fully qualified export history table."
  value       = module.gemini_analytics_pipeline.export_history_table
}

output "cloud_run_job_name" {
  description = "Cloud Run exporter job name."
  value       = module.gemini_analytics_pipeline.cloud_run_job_name
}
