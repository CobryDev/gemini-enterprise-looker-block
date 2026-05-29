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

resource "google_service_account" "scheduled_query" {
  project      = var.project_id
  account_id   = "gemini-bq-scheduled-query"
  display_name = "Gemini BigQuery Scheduled Query"

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset" "staging" {
  project                    = local.staging_project_id
  dataset_id                 = var.staging_dataset_id
  location                   = var.dataset_location
  delete_contents_on_destroy = false
  labels                     = var.labels

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

resource "google_bigquery_table" "metrics_history" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "metrics_history"
  labels     = var.labels

  deletion_protection = true

  time_partitioning {
    type  = "DAY"
    field = "metric_date"
  }

  clustering = ["engine_id", "metric_type"]

  schema = jsonencode([
    {
      name = "engine_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "metric_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "metric_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "metric_value"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "ingested_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
}

resource "google_secret_manager_secret" "engine_config" {
  project   = var.project_id
  secret_id = "gemini-analytics-engine-config"
  labels    = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "engine_config" {
  secret      = google_secret_manager_secret.engine_config.id
  secret_data = jsonencode(local.engine_config)
}

resource "google_cloud_run_v2_job" "exporter" {
  project  = var.project_id
  name     = "gemini-analytics-exporter"
  location = var.region
  labels   = var.labels

  template {
    template {
      service_account = google_service_account.exporter.email
      timeout         = "1200s"

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
          name  = "METRIC_FILTER"
          value = var.metric_filter
        }

        env {
          name  = "ENGINE_CONFIG_SECRET"
          value = google_secret_manager_secret.engine_config.id
        }
      }
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_bigquery_data_transfer_config" "merge_metrics_history" {
  project                = var.project_id
  location               = var.dataset_location
  display_name           = "gemini_metrics_history_merge"
  data_source_id         = "scheduled_query"
  schedule               = "every day 07:00"
  service_account_name   = google_service_account.scheduled_query.email
  destination_dataset_id = google_bigquery_dataset.analytics.dataset_id

  params = {
    query = templatefile("${path.module}/../../sql/merge_metrics_history.sql.tpl", {
      project_id           = var.project_id
      staging_project_id   = local.staging_project_id
      staging_dataset_id   = google_bigquery_dataset.staging.dataset_id
      analytics_dataset_id = google_bigquery_dataset.analytics.dataset_id
    })
  }

  depends_on = [
    google_bigquery_table.metrics_history,
    google_project_service.required,
  ]
}

resource "google_cloud_scheduler_job" "export_engine" {
  for_each = local.engines_by_id

  project     = var.project_id
  region      = var.region
  name        = "gemini-export-${each.key}"
  description = "Daily Gemini Enterprise analytics export for ${each.key}"
  schedule    = each.value.schedule
  time_zone   = each.value.time_zone

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
