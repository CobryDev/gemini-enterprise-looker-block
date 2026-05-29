module "gemini_analytics_pipeline" {
  source = "./modules/gemini_analytics_pipeline"

  project_id           = var.project_id
  engine_project_id    = var.engine_project_id
  staging_project_id   = var.staging_project_id
  region               = var.region
  dataset_location     = var.dataset_location
  staging_dataset_id   = var.staging_dataset_id
  analytics_dataset_id = var.analytics_dataset_id
  exporter_image       = var.exporter_image
  engines              = var.engines
  labels               = var.labels
}
