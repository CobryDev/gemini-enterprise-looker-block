# Optional daily copy of the Workspace audit export into dataset_location.
# The Admin console creates that export in its own location (often US), and
# BigQuery can't join datasets across locations, so without a co-located copy
# the Looker block can't put Gemini for Workspace next to Gemini Enterprise.

locals {
  workspace_audit_project_id = coalesce(var.workspace_audit_project_id, var.project_id)

  copy_workspace_audit = (
    var.workspace_audit_dataset_id != ""
    && var.workspace_audit_location != ""
    && upper(var.workspace_audit_location) != upper(var.dataset_location)
  )
}

data "google_project" "pipeline" {
  count = local.copy_workspace_audit ? 1 : 0

  project_id = var.project_id
}

resource "google_project_service" "data_transfer" {
  count = local.copy_workspace_audit ? 1 : 0

  project            = var.project_id
  service            = "bigquerydatatransfer.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "workspace_copy" {
  count = local.copy_workspace_audit ? 1 : 0

  project      = var.project_id
  account_id   = "gemini-workspace-copy"
  display_name = "Gemini Analytics Workspace audit copy"

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset" "workspace_copy" {
  count = local.copy_workspace_audit ? 1 : 0

  project                    = var.project_id
  dataset_id                 = var.workspace_copy_dataset_id
  location                   = var.dataset_location
  description                = "Daily copy of ${local.workspace_audit_project_id}.${var.workspace_audit_dataset_id} (${var.workspace_audit_location}) for the Looker block."
  delete_contents_on_destroy = false
  labels                     = var.labels

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset_iam_member" "workspace_copy_source_reader" {
  count = local.copy_workspace_audit ? 1 : 0

  project    = local.workspace_audit_project_id
  dataset_id = var.workspace_audit_dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.workspace_copy[0].email}"
}

resource "google_bigquery_dataset_iam_member" "workspace_copy_destination_owner" {
  count = local.copy_workspace_audit ? 1 : 0

  project    = var.project_id
  dataset_id = google_bigquery_dataset.workspace_copy[0].dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.workspace_copy[0].email}"
}

resource "google_project_iam_member" "workspace_copy_job_user" {
  count = local.copy_workspace_audit ? 1 : 0

  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.workspace_copy[0].email}"
}

# The Data Transfer Service agent mints tokens for the copy service account.
resource "google_service_account_iam_member" "workspace_copy_token_creator" {
  count = local.copy_workspace_audit ? 1 : 0

  service_account_id = google_service_account.workspace_copy[0].name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.pipeline[0].number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"

  depends_on = [google_project_service.data_transfer]
}

resource "google_bigquery_data_transfer_config" "workspace_copy" {
  count = local.copy_workspace_audit ? 1 : 0

  project                = var.project_id
  display_name           = "Copy Workspace audit export to ${var.dataset_location}"
  location               = var.dataset_location
  data_source_id         = "cross_region_copy"
  schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.workspace_copy[0].dataset_id
  service_account_name   = google_service_account.workspace_copy[0].email

  params = {
    source_project_id           = local.workspace_audit_project_id
    source_dataset_id           = var.workspace_audit_dataset_id
    overwrite_destination_table = "true"
  }

  depends_on = [
    google_project_service.data_transfer,
    google_bigquery_dataset_iam_member.workspace_copy_source_reader,
    google_bigquery_dataset_iam_member.workspace_copy_destination_owner,
    google_project_iam_member.workspace_copy_job_user,
    google_service_account_iam_member.workspace_copy_token_creator,
  ]
}

resource "google_bigquery_dataset_iam_member" "looker_workspace_copy_viewer" {
  count = local.copy_workspace_audit && var.looker_service_account_email != "" ? 1 : 0

  project    = var.project_id
  dataset_id = google_bigquery_dataset.workspace_copy[0].dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.looker_service_account_email}"
}
