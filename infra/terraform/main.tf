module "gemini_analytics_pipeline" {
  source = "./modules/gemini_analytics_pipeline"

  project_id                   = var.project_id
  engine_project_id            = var.engine_project_id
  staging_project_id           = var.staging_project_id
  region                       = var.region
  dataset_location             = var.dataset_location
  staging_dataset_id           = var.staging_dataset_id
  analytics_dataset_id         = var.analytics_dataset_id
  exporter_image               = var.exporter_image
  engines                      = var.engines
  alert_email                  = var.alert_email
  looker_service_account_email = var.looker_service_account_email
  labels                       = var.labels

  enable_log_pipeline                      = var.enable_log_pipeline
  log_source_project_ids                   = var.log_source_project_ids
  raw_logs_dataset_id                      = var.raw_logs_dataset_id
  raw_log_retention_days                   = var.raw_log_retention_days
  route_inference_logs                     = var.route_inference_logs
  enable_model_armor_audit_logs            = var.enable_model_armor_audit_logs
  exclude_content_logs_from_default_bucket = var.exclude_content_logs_from_default_bucket
  user_store_locations                     = var.user_store_locations
  log_app_display_names                    = var.log_app_display_names
  log_transform_schedule                   = var.log_transform_schedule
  license_snapshot_schedule                = var.license_snapshot_schedule

  workspace_audit_project_id = var.workspace_audit_project_id
  workspace_audit_dataset_id = var.workspace_audit_dataset_id
  workspace_audit_location   = var.workspace_audit_location
  workspace_copy_dataset_id  = var.workspace_copy_dataset_id
}
