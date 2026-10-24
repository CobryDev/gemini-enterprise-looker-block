# Log-based analytics: Gemini Enterprise, Model Armor and Antigravity logs are
# routed into a short-lived Log Analytics bucket, exposed to BigQuery through a
# read-only linked dataset, and transformed hourly by the exporter job into
# redacted curated tables. Raw entries carry prompt and response text, so only
# the exporter can read the linked dataset and the bucket keeps entries for
# raw_log_retention_days. The transform selects an allow-list of metadata
# fields; nothing that holds prompt, response, grounding or file content is
# copied into the curated tables.
#
# A Log Analytics bucket is used rather than a BigQuery dataset sink because
# sink tables fix their column types from the first entry, and these payloads
# (action arguments, tool definitions) change type between entries. Mismatched
# entries would be diverted to export_errors and silently missing from the
# dashboards; Log Analytics stores payloads as JSON so every entry lands.

locals {
  log_source_project_ids = var.enable_log_pipeline ? toset(
    length(var.log_source_project_ids) > 0 ? var.log_source_project_ids : [local.engine_project_id]
  ) : toset([])

  # Log bucket locations are lowercase multi-regions; the linked dataset takes
  # the bucket's location, which must match the analytics dataset so the
  # transform can read raw and write curated in one query.
  raw_log_bucket_location = lower(var.dataset_location)
  raw_log_bucket_id       = "gemini-logs-raw"
  raw_logs_view           = "${var.project_id}.${var.raw_logs_dataset_id}._AllLogs"

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

  user_store_locations = distinct(coalesce(
    var.user_store_locations,
    [for engine in var.engines : lower(engine.location)],
  ))

  app_display_names = merge(
    { for engine_id, engine in local.engines_by_id : engine_id => engine.display_name },
    var.log_app_display_names,
  )

  curated_tables = {
    ge_user_activity = {
      description = "One row per Gemini Enterprise user interaction from the user-activity log, redacted to metadata. No prompt, response, grounding or file content."
      partition   = "event_date"
      clustering  = ["user_email", "engine_id", "feature"]
      schema = [
        { name = "insert_id", type = "STRING", mode = "REQUIRED", description = "Log entry insertId; the merge key." },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "location", type = "STRING", mode = "NULLABLE" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE", description = "Lower-cased userIamPrincipal." },
        { name = "method", type = "STRING", mode = "NULLABLE", description = "API method: StreamAssist, Search, WriteUserEvent, UploadSessionFile, AddContextFile, CreateAgent, UpdateAgent, DeleteAgent, SetIamPolicy." },
        { name = "feature", type = "STRING", mode = "NULLABLE", description = "Derived Gemini Enterprise feature the interaction belongs to." },
        { name = "trace_id", type = "STRING", mode = "NULLABLE" },
        { name = "session_id", type = "STRING", mode = "NULLABLE" },
        { name = "assist_token", type = "STRING", mode = "NULLABLE" },
        { name = "is_user_prompt", type = "BOOLEAN", mode = "NULLABLE", description = "A prompt the user sent interactively (not a scheduled/triggered run or an action confirmation)." },
        { name = "is_user_search", type = "BOOLEAN", mode = "NULLABLE", description = "A search the user ran from the search bar, as opposed to the assistant's own grounding lookups." },
        { name = "invocation_mode", type = "STRING", mode = "NULLABLE", description = "Interactive, Scheduled or Triggered." },
        { name = "agent_id", type = "STRING", mode = "NULLABLE" },
        { name = "agent_display_name", type = "STRING", mode = "NULLABLE" },
        { name = "agent_kind", type = "STRING", mode = "NULLABLE" },
        { name = "is_core_assistant", type = "BOOLEAN", mode = "NULLABLE" },
        { name = "model", type = "STRING", mode = "NULLABLE" },
        { name = "model_selection_mode", type = "STRING", mode = "NULLABLE" },
        { name = "requested_model", type = "STRING", mode = "NULLABLE" },
        { name = "data_store_selection_mode", type = "STRING", mode = "NULLABLE" },
        { name = "data_store_ids", type = "STRING", mode = "REPEATED" },
        { name = "proposed_actions", type = "STRING", mode = "REPEATED", description = "Action names the assistant proposed (for example send email, create event)." },
        { name = "executed_action", type = "STRING", mode = "NULLABLE", description = "Action name the user confirmed and ran." },
        { name = "grounding_reference_count", type = "INTEGER", mode = "NULLABLE" },
        { name = "grounding_domains", type = "STRING", mode = "REPEATED", description = "Distinct domains of grounding sources (no URIs or titles)." },
        { name = "attachment_mime_types", type = "STRING", mode = "REPEATED" },
        { name = "answer_state", type = "STRING", mode = "NULLABLE" },
        { name = "skipped_reasons", type = "STRING", mode = "REPEATED" },
        { name = "is_blocked", type = "BOOLEAN", mode = "NULLABLE", description = "The answer was skipped for a policy or safety reason." },
        { name = "status_code", type = "INTEGER", mode = "NULLABLE" },
        { name = "search_result_count", type = "INTEGER", mode = "NULLABLE" },
        { name = "serving_config", type = "STRING", mode = "NULLABLE" },
        { name = "event_type", type = "STRING", mode = "NULLABLE" },
        { name = "page_type", type = "STRING", mode = "NULLABLE" },
        { name = "feedback_type", type = "STRING", mode = "NULLABLE" },
        { name = "feedback_reasons", type = "STRING", mode = "REPEATED" },
        { name = "device_class", type = "STRING", mode = "NULLABLE" },
        { name = "time_zone", type = "STRING", mode = "NULLABLE" },
        { name = "file_mime_type", type = "STRING", mode = "NULLABLE" },
        { name = "file_byte_count", type = "INTEGER", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_model_calls = {
      description = "One row per model inference from the gen_ai inference log: tokens and finish reasons, attributed to a user through the trace."
      partition   = "event_date"
      clustering  = ["user_email", "engine_id"]
      schema = [
        { name = "insert_id", type = "STRING", mode = "REQUIRED" },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "location", type = "STRING", mode = "NULLABLE" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "trace_id", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "agent_id", type = "STRING", mode = "NULLABLE" },
        { name = "agent_name", type = "STRING", mode = "NULLABLE" },
        { name = "conversation_id", type = "STRING", mode = "NULLABLE" },
        { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
        { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
        { name = "cached_input_tokens", type = "INTEGER", mode = "NULLABLE" },
        { name = "reasoning_tokens", type = "INTEGER", mode = "NULLABLE" },
        { name = "finish_reasons", type = "STRING", mode = "REPEATED" },
        { name = "tool_call_count", type = "INTEGER", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_tool_calls = {
      description = "One row per tool call the model made (new calls only, not replayed history). Skill loads carry skill_name; no other arguments are kept."
      partition   = "event_date"
      clustering  = ["user_email", "tool_family"]
      schema = [
        { name = "row_key", type = "STRING", mode = "REQUIRED", description = "insert_id of the model call plus the call index." },
        { name = "insert_id", type = "STRING", mode = "REQUIRED" },
        { name = "call_index", type = "INTEGER", mode = "REQUIRED" },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "trace_id", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "agent_name", type = "STRING", mode = "NULLABLE" },
        { name = "tool_name", type = "STRING", mode = "NULLABLE" },
        { name = "tool_family", type = "STRING", mode = "NULLABLE", description = "Connector or agent that owns the tool (the prefix before __), or the tool name." },
        { name = "skill_name", type = "STRING", mode = "NULLABLE" },
        { name = "is_skill_call", type = "BOOLEAN", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_connector_activity = {
      description = "Connector tool failures from the connector_activity log, bucketed into an error category. The raw error message is not kept."
      partition   = "event_date"
      clustering  = ["connector_type", "user_email"]
      schema = [
        { name = "insert_id", type = "STRING", mode = "REQUIRED" },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "location", type = "STRING", mode = "NULLABLE" },
        { name = "connector_id", type = "STRING", mode = "NULLABLE" },
        { name = "connector_type", type = "STRING", mode = "NULLABLE" },
        { name = "tool", type = "STRING", mode = "NULLABLE" },
        { name = "agent", type = "STRING", mode = "NULLABLE" },
        { name = "severity", type = "STRING", mode = "NULLABLE" },
        { name = "error_category", type = "STRING", mode = "NULLABLE" },
        { name = "assist_token", type = "STRING", mode = "NULLABLE" },
        { name = "trace_id", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_safety_events = {
      description = "Prompt and response screening: one row per Model Armor verdict category (or per Gemini Enterprise skip reason), attributed to a user where possible."
      partition   = "event_date"
      clustering  = ["user_email", "category"]
      schema = [
        { name = "row_key", type = "STRING", mode = "REQUIRED" },
        { name = "event_id", type = "STRING", mode = "REQUIRED", description = "Source log insertId; count distinct for screened or blocked interactions." },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "source", type = "STRING", mode = "NULLABLE", description = "MODEL_ARMOR or GEMINI_ENTERPRISE." },
        { name = "screened_content", type = "STRING", mode = "NULLABLE", description = "PROMPT or RESPONSE." },
        { name = "template", type = "STRING", mode = "NULLABLE" },
        { name = "category", type = "STRING", mode = "NULLABLE", description = "Model Armor filter category or Gemini Enterprise skip reason. Null on screened-and-passed rows." },
        { name = "is_match", type = "BOOLEAN", mode = "NULLABLE" },
        { name = "filter_match_state", type = "STRING", mode = "NULLABLE" },
        { name = "invocation_result", type = "STRING", mode = "NULLABLE" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "trace_id", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "attribution_method", type = "STRING", mode = "NULLABLE", description = "log, trace, time_window or unattributed." },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_admin_events = {
      description = "Gemini Enterprise Admin Activity audit events (agent, connector and app configuration changes)."
      partition   = "event_date"
      clustering  = ["method"]
      schema = [
        { name = "insert_id", type = "STRING", mode = "REQUIRED" },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "principal_email", type = "STRING", mode = "NULLABLE" },
        { name = "method", type = "STRING", mode = "NULLABLE", description = "Short method name, for example CreateAgent." },
        { name = "full_method_name", type = "STRING", mode = "NULLABLE" },
        { name = "resource_type", type = "STRING", mode = "NULLABLE" },
        { name = "resource_name", type = "STRING", mode = "NULLABLE" },
        { name = "engine_id", type = "STRING", mode = "NULLABLE" },
        { name = "app_name", type = "STRING", mode = "NULLABLE" },
        { name = "status_code", type = "INTEGER", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    antigravity_usage = {
      description = "One row per Antigravity inference from metadata-only InferenceResponseLog entries."
      partition   = "event_date"
      clustering  = ["user_email", "client_name"]
      schema = [
        { name = "insert_id", type = "STRING", mode = "REQUIRED" },
        { name = "event_ts", type = "TIMESTAMP", mode = "REQUIRED" },
        { name = "event_date", type = "DATE", mode = "REQUIRED" },
        { name = "project_id", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "client_name", type = "STRING", mode = "NULLABLE" },
        { name = "client_version", type = "STRING", mode = "NULLABLE" },
        { name = "model", type = "STRING", mode = "NULLABLE" },
        { name = "experience", type = "STRING", mode = "NULLABLE" },
        { name = "total_tokens", type = "INTEGER", mode = "NULLABLE" },
        { name = "request_id", type = "STRING", mode = "NULLABLE" },
        { name = "trajectory_id", type = "STRING", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }

    ge_user_licenses = {
      description = "Daily snapshot of Gemini Enterprise per-user licence assignment and last login, from the userLicenses API."
      partition   = "snapshot_date"
      clustering  = ["user_email"]
      schema = [
        { name = "snapshot_date", type = "DATE", mode = "REQUIRED" },
        { name = "location", type = "STRING", mode = "NULLABLE" },
        { name = "user_store", type = "STRING", mode = "NULLABLE" },
        { name = "user_email", type = "STRING", mode = "NULLABLE" },
        { name = "license_state", type = "STRING", mode = "NULLABLE" },
        { name = "license_config", type = "STRING", mode = "NULLABLE" },
        { name = "create_time", type = "TIMESTAMP", mode = "NULLABLE" },
        { name = "update_time", type = "TIMESTAMP", mode = "NULLABLE" },
        { name = "last_login_time", type = "TIMESTAMP", mode = "NULLABLE" },
        { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" },
      ]
    }
  }
}

resource "google_project_service" "logging" {
  count = var.enable_log_pipeline ? 1 : 0

  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_project_bucket_config" "raw" {
  count = var.enable_log_pipeline ? 1 : 0

  project          = var.project_id
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

  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member  = google_logging_project_sink.gemini[each.key].writer_identity

  condition {
    title      = "gemini-logs-raw-only"
    expression = "resource.name.endsWith(\"buckets/${local.raw_log_bucket_id}\")"
  }
}

resource "google_bigquery_dataset_iam_member" "exporter_raw_logs_viewer" {
  count = var.enable_log_pipeline ? 1 : 0

  project    = var.project_id
  dataset_id = google_logging_linked_dataset.raw[0].link_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.exporter.email}"
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

resource "google_bigquery_table" "curated" {
  for_each = var.enable_log_pipeline ? local.curated_tables : {}

  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = each.key
  labels     = var.labels

  deletion_protection = true
  description         = each.value.description

  time_partitioning {
    type  = "DAY"
    field = each.value.partition
  }

  clustering = each.value.clustering
  schema     = jsonencode(each.value.schema)
}

resource "google_project_iam_custom_role" "license_reader" {
  count = var.enable_log_pipeline ? 1 : 0

  project     = local.engine_project_id
  role_id     = "geminiAnalyticsLicenseReader"
  title       = "Gemini Analytics Licence Reader"
  description = "Lists Gemini Enterprise user licences for the daily licence snapshot."
  permissions = ["discoveryengine.userStores.listUserLicenses"]
}

resource "google_project_iam_member" "exporter_license_reader" {
  count = var.enable_log_pipeline ? 1 : 0

  project = local.engine_project_id
  role    = google_project_iam_custom_role.license_reader[0].name
  member  = "serviceAccount:${google_service_account.exporter.email}"
}

resource "google_cloud_scheduler_job" "log_jobs" {
  for_each = var.enable_log_pipeline ? {
    transform_logs = {
      schedule    = var.log_transform_schedule
      description = "Hourly transform of raw Gemini logs into redacted curated tables"
    }
    snapshot_licenses = {
      schedule    = var.license_snapshot_schedule
      description = "Daily snapshot of Gemini Enterprise per-user licences"
    }
  } : {}

  project     = var.project_id
  region      = var.region
  name        = "gemini-${replace(each.key, "_", "-")}"
  description = each.value.description
  schedule    = each.value.schedule
  time_zone   = "Etc/UTC"

  retry_config {
    retry_count          = 3
    min_backoff_duration = "30s"
    max_backoff_duration = "300s"
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.exporter.name}:run"

    headers = {
      "Content-Type" = "application/json"
    }

    body = base64encode(jsonencode({
      overrides = {
        containerOverrides = [
          {
            env = [
              {
                name  = "MODE"
                value = each.key
              }
            ]
          }
        ]
      }
    }))

    oauth_token {
      service_account_email = google_service_account.scheduler.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_project_service.required]
}
