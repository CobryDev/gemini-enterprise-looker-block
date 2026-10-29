# Source-project half of the pipeline: everything that has to live next to the
# Gemini Enterprise engines. The analytics module calls this itself by default;
# call it directly when the source project is managed by a different team or
# Terraform state, and set manage_source_project_resources = false on the
# analytics side.

locals {
  staging_project_id  = coalesce(var.staging_project_id, var.project_id)
  raw_logs_project_id = coalesce(var.raw_logs_project_id, var.project_id)
  exporter_member     = "serviceAccount:${var.exporter_service_account_email}"

  engine_project_services = toset([
    "bigquery.googleapis.com",
    "discoveryengine.googleapis.com",
    "serviceusage.googleapis.com",
  ])
}

resource "google_project_service" "engine_required" {
  for_each = var.manage_project_services ? local.engine_project_services : toset([])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "staging" {
  project                    = local.staging_project_id
  dataset_id                 = var.staging_dataset_id
  location                   = var.dataset_location
  delete_contents_on_destroy = false
  labels                     = var.labels

  depends_on = [google_project_service.engine_required]
}

resource "google_bigquery_dataset_iam_member" "exporter_staging_editor" {
  count = var.grant_exporter_access ? 1 : 0

  project    = local.staging_project_id
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = local.exporter_member
}

resource "google_project_iam_member" "exporter_discovery_engine_viewer" {
  count = var.grant_exporter_access ? 1 : 0

  project = var.project_id
  role    = "roles/discoveryengine.viewer"
  member  = local.exporter_member
}

resource "google_project_iam_member" "exporter_engine_project_service_usage_consumer" {
  count = var.grant_exporter_access ? 1 : 0

  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = local.exporter_member
}
