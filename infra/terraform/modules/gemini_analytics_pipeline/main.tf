resource "google_project_service" "required" {
  for_each = local.pipeline_project_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_project_service" "engine_required" {
  for_each = local.engine_project_services

  project            = local.engine_project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "exporter" {
  project      = var.project_id
  account_id   = "gemini-exporter"
  display_name = "Gemini Analytics Exporter"

  depends_on = [google_project_service.required]
}

resource "google_service_account" "scheduler" {
  project      = var.project_id
  account_id   = "gemini-export-scheduler"
  display_name = "Gemini Export Scheduler"

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset" "staging" {
  project                    = local.staging_project_id
  dataset_id                 = var.staging_dataset_id
  location                   = var.dataset_location
  delete_contents_on_destroy = false
  labels                     = var.labels

  lifecycle {
    precondition {
      condition     = local.engine_locations_consistent
      error_message = "dataset_location does not match the engines' export location: eu engines export to BigQuery EU, global/us engines export to BigQuery US. Align dataset_location with the engine location (or deploy one stack per region)."
    }
  }

  depends_on = [
    google_project_service.required,
    google_project_service.engine_required,
  ]
}

resource "google_bigquery_dataset" "analytics" {
  project                    = var.project_id
  dataset_id                 = var.analytics_dataset_id
  location                   = var.dataset_location
  delete_contents_on_destroy = false
  labels                     = var.labels

  depends_on = [google_project_service.required]
}

resource "google_bigquery_table" "export_history" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "export_history"
  labels     = var.labels

  deletion_protection = true

  description = "Full-fidelity history of the Gemini Enterprise analytics export. Each row preserves the original export grain (data_source x product_type x device_type x query x document x agent), merged daily so history is retained beyond the export's rolling 30-day window."

  time_partitioning {
    type  = "DAY"
    field = "metric_date"
  }

  clustering = ["engine_id", "data_source", "product_type"]

  schema = jsonencode([
    { name = "row_key", type = "STRING", mode = "REQUIRED", description = "Stable hash of the dimension columns; the merge key." },
    { name = "engine_id", type = "STRING", mode = "REQUIRED" },
    { name = "app_name", type = "STRING", mode = "NULLABLE", description = "Friendly name of the Gemini Enterprise app this engine maps to; falls back to engine_id." },
    { name = "metric_date", type = "DATE", mode = "REQUIRED" },
    { name = "project_number", type = "INTEGER", mode = "NULLABLE" },
    { name = "data_source", type = "STRING", mode = "NULLABLE", description = "AGGREGATED_METRIC, GWS_LOG, or USER_EVENT." },
    { name = "product_type", type = "STRING", mode = "NULLABLE", description = "Total, Search, Assistant, Other (for active-user rows)." },
    { name = "device_type", type = "STRING", mode = "NULLABLE" },
    { name = "serving_config_id", type = "STRING", mode = "NULLABLE" },
    { name = "original_search_query", type = "STRING", mode = "NULLABLE", description = "Query text. Populated only above Google's k-anonymity threshold." },
    { name = "document_name", type = "STRING", mode = "NULLABLE" },
    { name = "agent_name", type = "STRING", mode = "NULLABLE" },
    { name = "agent_type", type = "STRING", mode = "NULLABLE" },
    { name = "agent_ownership", type = "STRING", mode = "NULLABLE" },
    { name = "dislike_reasons", type = "STRING", mode = "NULLABLE" },
    { name = "search_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "search_click_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "answer_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "action_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_search_contents", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_view_contents", type = "FLOAT", mode = "NULLABLE" },
    { name = "feedback_like_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "feedback_dislike_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "daily_active_user_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "weekly_active_user_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "monthly_active_user_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_retention_ratio_for7d", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_retention_ratio_for28d", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_churn_rate_for7d", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_churn_rate_for28d", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_growth_rate_for7d", type = "FLOAT", mode = "NULLABLE" },
    { name = "user_growth_rate_for28d", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_home_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_agent_gallery_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_prompts_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_people_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_notebook_lm_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_deep_research_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_idea_generation_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "total_agent_page_visit_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "seats_purchased", type = "FLOAT", mode = "NULLABLE" },
    { name = "seats_claimed", type = "FLOAT", mode = "NULLABLE" },
    { name = "monthly_new_agent_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "agent_session_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "agent_active_user_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "monthly_agent_active_user_count", type = "FLOAT", mode = "NULLABLE" },
    { name = "ingested_at", type = "TIMESTAMP", mode = "REQUIRED" }
  ])
}

resource "google_cloud_run_v2_job" "exporter" {
  project  = var.project_id
  name     = "gemini-analytics-exporter"
  location = var.region
  labels   = var.labels

  template {
    template {
      service_account = google_service_account.exporter.email
      # Export operation poll allows up to 1200s; the in-job merge and startup
      # need headroom on top, so the job timeout must exceed the poll timeout.
      timeout = "1800s"

      containers {
        image = var.exporter_image

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "ENGINE_PROJECT_ID"
          value = local.engine_project_id
        }

        env {
          name  = "STAGING_PROJECT_ID"
          value = local.staging_project_id
        }

        env {
          name  = "STAGING_DATASET"
          value = google_bigquery_dataset.staging.dataset_id
        }

        env {
          name  = "ANALYTICS_PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "ANALYTICS_DATASET"
          value = google_bigquery_dataset.analytics.dataset_id
        }

        env {
          name  = "ANALYTICS_TABLE"
          value = google_bigquery_table.export_history.table_id
        }

        # Used by the transform_logs and snapshot_licenses modes, which the
        # log-pipeline schedulers select with a MODE override.
        dynamic "env" {
          for_each = var.enable_log_pipeline ? {
            RAW_LOGS_VIEW        = local.raw_logs_view
            APP_NAMES_JSON       = jsonencode(local.app_display_names)
            USER_STORE_LOCATIONS = join(",", local.user_store_locations)
          } : {}

          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_cloud_scheduler_job" "export_engine" {
  for_each = local.engines_by_id

  project     = var.project_id
  region      = var.region
  name        = "gemini-export-${each.key}"
  description = "Daily Gemini Enterprise analytics export for ${each.key}"
  schedule    = each.value.schedule
  time_zone   = each.value.time_zone

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
                name  = "ENGINE_ID"
                value = each.value.engine_id
              },
              {
                name  = "DISPLAY_NAME"
                value = each.value.display_name
              },
              {
                name  = "ENGINE_LOCATION"
                value = each.value.location
              },
              {
                name  = "ENDPOINT_LOCATION"
                value = each.value.endpoint_location
              },
              {
                name  = "TABLE_ID_PREFIX"
                value = each.value.table_id_prefix
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
