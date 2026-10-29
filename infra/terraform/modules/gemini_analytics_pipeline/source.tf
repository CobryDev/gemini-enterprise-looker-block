# Source-project resources: the staging dataset, raw log routing and the
# exporter's access to the engine project. Managed here by default so a single
# apply sets up everything; set manage_source_project_resources = false when
# the engine project's owners apply the gemini_analytics_source module
# themselves.

module "source" {
  source = "../gemini_analytics_source"
  count  = var.manage_source_project_resources ? 1 : 0

  project_id                     = local.engine_project_id
  staging_project_id             = local.staging_project_id
  raw_logs_project_id            = local.raw_logs_project_id
  dataset_location               = var.dataset_location
  staging_dataset_id             = var.staging_dataset_id
  exporter_service_account_email = google_service_account.exporter.email
  labels                         = var.labels

  enable_log_pipeline                      = var.enable_log_pipeline
  log_source_project_ids                   = var.log_source_project_ids
  raw_logs_dataset_id                      = var.raw_logs_dataset_id
  raw_log_retention_days                   = var.raw_log_retention_days
  route_inference_logs                     = var.route_inference_logs
  enable_model_armor_audit_logs            = var.enable_model_armor_audit_logs
  exclude_content_logs_from_default_bucket = var.exclude_content_logs_from_default_bucket

  depends_on = [google_project_service.required]
}

moved {
  from = google_project_service.engine_required
  to   = module.source[0].google_project_service.engine_required
}

moved {
  from = google_bigquery_dataset.staging
  to   = module.source[0].google_bigquery_dataset.staging
}

moved {
  from = google_bigquery_dataset_iam_member.exporter_staging_editor
  to   = module.source[0].google_bigquery_dataset_iam_member.exporter_staging_editor[0]
}

moved {
  from = google_project_iam_member.exporter_discovery_engine_viewer
  to   = module.source[0].google_project_iam_member.exporter_discovery_engine_viewer[0]
}

moved {
  from = google_project_iam_member.exporter_engine_project_service_usage_consumer
  to   = module.source[0].google_project_iam_member.exporter_engine_project_service_usage_consumer[0]
}

moved {
  from = google_project_service.logging
  to   = module.source[0].google_project_service.logging
}

moved {
  from = google_logging_project_bucket_config.raw
  to   = module.source[0].google_logging_project_bucket_config.raw
}

moved {
  from = google_logging_linked_dataset.raw
  to   = module.source[0].google_logging_linked_dataset.raw
}

moved {
  from = google_logging_project_sink.gemini
  to   = module.source[0].google_logging_project_sink.gemini
}

moved {
  from = google_project_iam_member.sink_bucket_writer
  to   = module.source[0].google_project_iam_member.sink_bucket_writer
}

moved {
  from = google_bigquery_dataset_iam_member.exporter_raw_logs_viewer
  to   = module.source[0].google_bigquery_dataset_iam_member.exporter_raw_logs_viewer
}

moved {
  from = google_project_iam_audit_config.model_armor
  to   = module.source[0].google_project_iam_audit_config.model_armor
}

moved {
  from = google_logging_project_exclusion.content_logs
  to   = module.source[0].google_logging_project_exclusion.content_logs
}

moved {
  from = google_project_iam_custom_role.license_reader
  to   = module.source[0].google_project_iam_custom_role.license_reader
}

moved {
  from = google_project_iam_member.exporter_license_reader
  to   = module.source[0].google_project_iam_member.exporter_license_reader
}
