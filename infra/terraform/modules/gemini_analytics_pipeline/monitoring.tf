# Optional failure alerting. Without it, a broken export silently stops the
# dashboards refreshing, so production deployments should set alert_email.

resource "google_monitoring_notification_channel" "email" {
  count = var.alert_email != "" ? 1 : 0

  project      = var.project_id
  display_name = "Gemini analytics pipeline alerts"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }

  depends_on = [google_project_service.required]
}

resource "google_monitoring_alert_policy" "exporter_failures" {
  count = var.alert_email != "" ? 1 : 0

  project      = var.project_id
  display_name = "Gemini analytics exporter failure"
  combiner     = "OR"

  conditions {
    display_name = "Exporter job execution logged an error"

    condition_matched_log {
      filter = <<-EOT
        resource.type="cloud_run_job"
        resource.labels.job_name="${google_cloud_run_v2_job.exporter.name}"
        severity>=ERROR
      EOT
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[0].id]

  alert_strategy {
    auto_close = "604800s"

    notification_rate_limit {
      period = "3600s"
    }
  }

  documentation {
    content   = "The Gemini analytics exporter Cloud Run job logged an error. Check the job logs: resource.type=\"cloud_run_job\" resource.labels.job_name=\"${google_cloud_run_v2_job.exporter.name}\" and the `mode` field (export, transform_logs, snapshot_licenses). Until the run succeeds the Looker dashboards go stale. A failing transform_logs run is urgent: raw log entries expire after ${var.raw_log_retention_days} day(s), and anything not transformed by then is lost."
    mime_type = "text/markdown"
  }

  depends_on = [google_project_service.required]
}
