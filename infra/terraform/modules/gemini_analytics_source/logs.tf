# Raw log routing. Entries land in a Log Analytics bucket rather than a BigQuery
# sink because sink tables fix column types from the first entry and these
# payloads change type between entries. The linked dataset is read-only and
# only the exporter can read it, because raw entries carry prompt text.

locals {
  log_source_project_ids = var.enable_log_pipeline ? toset(
    length(var.log_source_project_ids) > 0 ? var.log_source_project_ids : [var.project_id]
  ) : toset([])

  # The linked dataset takes the bucket's location, which must match the
  # analytics dataset so the transform can read raw and write curated in one query.
  raw_log_bucket_location = lower(var.dataset_location)
  raw_log_bucket_id       = "gemini-logs-raw"
  raw_logs_view           = "${local.raw_logs_project_id}.${var.raw_logs_dataset_id}._AllLogs"

  log_sink_filters = {
    usage = join(" OR ", concat(
      [
        "logName=\"projects/PROJECT_ID/logs/discoveryengine.googleapis.com%2Fgemini_enterprise_user_activity\"",
        "logName=\"projects/PROJECT_ID/logs/discoveryengine.googleapis.com%2Fconnector_activity\"",
      ],
      var.route_inference_logs ? [
        "logName=\"projects/PROJECT_ID/logs/discoveryengine.googleapis.com%2Fgen_ai.client.inference.operation.details\"",
      ] : [],
    ))
    audit = join(" OR ", [
      "(logName=\"projects/PROJECT_ID/logs/cloudaudit.googleapis.com%2Factivity\" AND protoPayload.serviceName=\"discoveryengine.googleapis.com\")",
      "(logName=\"projects/PROJECT_ID/logs/cloudaudit.googleapis.com%2Fdata_access\" AND protoPayload.serviceName=\"modelarmor.googleapis.com\" AND protoPayload.methodName:\"Sanitize\")",
    ])
    # Metadata-only Antigravity entries. InferenceRequestLog (the prompt) is
    # never routed.
    antigravity = "jsonPayload.@type=\"type.googleapis.com/google.cloud.businessaicode.logging.v1.InferenceResponseLog\""
  }

  log_sinks = {
    for pair in setproduct(local.log_source_project_ids, keys(local.log_sink_filters)) :
    "${pair[0]}/${pair[1]}" => {
      project = pair[0]
      kind    = pair[1]
      filter  = replace(local.log_sink_filters[pair[1]], "PROJECT_ID", pair[0])
    }
  }

  # Logs that carry prompt or response text. gen_ai.user.message and
  # gen_ai.choice are pure content and are not routed anywhere, so excluding
  # them from _Default drops them entirely.
  content_log_exclusion_filter = join(" OR ", [
    "logName=\"projects/PROJECT_ID/logs/discoveryengine.googleapis.com%2Fgemini_enterprise_user_activity\"",
    "logName:\"projects/PROJECT_ID/logs/discoveryengine.googleapis.com%2Fgen_ai.\"",
    "jsonPayload.@type=\"type.googleapis.com/google.cloud.businessaicode.logging.v1.InferenceRequestLog\"",
    "jsonPayload.@type=\"type.googleapis.com/google.cloud.businessaicode.logging.v1.InferenceResponseLog\"",
    "jsonPayload.@type=\"type.googleapis.com/google.cloud.modelarmor.logging.v1.SanitizeOperationLogEntry\"",
  ])
}

resource "google_project_service" "logging" {
  count = var.enable_log_pipeline && var.manage_project_services ? 1 : 0

  project            = local.raw_logs_project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_project_bucket_config" "raw" {
  count = var.enable_log_pipeline ? 1 : 0

  project          = local.raw_logs_project_id
  location         = local.raw_log_bucket_location
  bucket_id        = local.raw_log_bucket_id
  retention_days   = var.raw_log_retention_days
  enable_analytics = true
  description      = "Short-lived raw Gemini Enterprise, Model Armor and Antigravity logs. Entries include prompt text; the exporter copies redacted metadata out hourly."

  lifecycle {
    precondition {
      condition     = contains(["eu", "us"], local.raw_log_bucket_location)
      error_message = "The log pipeline needs dataset_location EU or US so the raw log bucket and the analytics dataset share a BigQuery location."
    }
  }

  depends_on = [google_project_service.logging]
}

resource "google_logging_linked_dataset" "raw" {
  count = var.enable_log_pipeline ? 1 : 0

  link_id     = var.raw_logs_dataset_id
  bucket      = google_logging_project_bucket_config.raw[0].id
  description = "Read-only view of the raw Gemini log bucket. Contains prompt text: grant access to the exporter only."
}

resource "google_logging_project_sink" "gemini" {
  for_each = local.log_sinks

  project                = each.value.project
  name                   = "gemini-analytics-${each.value.kind}"
  description            = "Routes Gemini ${each.value.kind} logs to the raw analytics log bucket."
  destination            = "logging.googleapis.com/${google_logging_project_bucket_config.raw[0].id}"
  filter                 = each.value.filter
  unique_writer_identity = true
}

resource "google_project_iam_member" "sink_bucket_writer" {
  for_each = local.log_sinks

  project = local.raw_logs_project_id
  role    = "roles/logging.bucketWriter"
  member  = google_logging_project_sink.gemini[each.key].writer_identity

  condition {
    title      = "gemini-logs-raw-only"
    expression = "resource.name.endsWith(\"buckets/${local.raw_log_bucket_id}\")"
  }
}

resource "google_bigquery_dataset_iam_member" "exporter_raw_logs_viewer" {
  count = var.enable_log_pipeline && var.grant_exporter_access ? 1 : 0

  project    = local.raw_logs_project_id
  dataset_id = google_logging_linked_dataset.raw[0].link_id
  role       = "roles/bigquery.dataViewer"
  member     = local.exporter_member
}

resource "google_project_iam_audit_config" "model_armor" {
  for_each = var.enable_model_armor_audit_logs ? local.log_source_project_ids : toset([])

  project = each.value
  service = "modelarmor.googleapis.com"

  audit_log_config {
    log_type = "DATA_READ"
  }
}

resource "google_logging_project_exclusion" "content_logs" {
  for_each = var.exclude_content_logs_from_default_bucket ? local.log_source_project_ids : toset([])

  project     = each.value
  name        = "gemini-content-logs"
  description = "Keeps Gemini Enterprise and Antigravity prompt and response text out of the _Default bucket; the analytics sinks still receive these entries."
  filter      = replace(local.content_log_exclusion_filter, "PROJECT_ID", each.value)
}

resource "google_project_iam_custom_role" "license_reader" {
  count = var.enable_log_pipeline ? 1 : 0

  project     = var.project_id
  role_id     = "geminiAnalyticsLicenseReader"
  title       = "Gemini Analytics Licence Reader"
  description = "Lists Gemini Enterprise user licences for the daily licence snapshot."
  permissions = ["discoveryengine.userStores.listUserLicenses"]
}

resource "google_project_iam_member" "exporter_license_reader" {
  count = var.enable_log_pipeline && var.grant_exporter_access ? 1 : 0

  project = var.project_id
  role    = google_project_iam_custom_role.license_reader[0].name
  member  = local.exporter_member
}
