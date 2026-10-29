variable "project_id" {
  description = "GCP project that hosts the Gemini analytics pipeline."
  type        = string
}

variable "engine_project_id" {
  description = "GCP project that owns the Gemini Enterprise engines. Defaults to project_id."
  type        = string
  default     = null
}

variable "staging_project_id" {
  description = "GCP project for raw Gemini Enterprise export tables. Defaults to engine_project_id because the export API writes in the app project."
  type        = string
  default     = null
}

variable "region" {
  description = "Region for Cloud Run and Cloud Scheduler."
  type        = string
  default     = "europe-west2"
}

variable "dataset_location" {
  description = "BigQuery dataset location. Use US for global/US engines and EU for EU engines."
  type        = string
  default     = "EU"
}

variable "staging_dataset_id" {
  description = "BigQuery dataset for rolling 30-day Gemini Enterprise export tables."
  type        = string
  default     = "gemini_analytics_staging"
}

variable "manage_source_project_resources" {
  description = "Create the staging dataset, raw log bucket, sinks and the exporter's engine-project grants from this stack. Set false when the engine project applies modules/gemini_analytics_source itself."
  type        = bool
  default     = true
}

variable "raw_logs_project_id" {
  description = "Project that holds the raw log bucket and its linked dataset. Defaults to project_id. Set to the engine project when the source side is managed separately."
  type        = string
  default     = null
}

variable "analytics_dataset_id" {
  description = "BigQuery dataset for longitudinal analytics tables consumed by Looker."
  type        = string
  default     = "gemini_analytics"
}

variable "exporter_image" {
  description = "Container image for the Cloud Run exporter job."
  type        = string
}

variable "engines" {
  description = "Gemini Enterprise engines to export. Each engine maps to one Gemini Enterprise app; add an entry per app you want to track. Stagger schedules to stay below org-level API limits."
  type = list(object({
    engine_id         = string
    display_name      = optional(string)
    location          = string
    endpoint_location = optional(string)
    schedule          = string
    time_zone         = optional(string, "Etc/UTC")
    table_id_prefix   = optional(string)
  }))
}

variable "alert_email" {
  description = "Email address to notify when an exporter job execution fails. Leave empty to skip creating alerting resources."
  type        = string
  default     = ""
}

variable "looker_service_account_email" {
  description = "Looker connection service account. When set, grants it BigQuery Data Viewer on the analytics dataset and BigQuery Job User on the project."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enable_log_pipeline" {
  description = "Route Gemini Enterprise, Model Armor and Antigravity logs through a short-lived raw log bucket into redacted user-level tables for the executive, change-management and admin Looker dashboards."
  type        = bool
  default     = false
}

variable "log_source_project_ids" {
  description = "Projects whose logs are routed. Defaults to [engine_project_id]."
  type        = list(string)
  default     = []
}

variable "raw_logs_dataset_id" {
  description = "Name of the read-only BigQuery dataset linked to the raw log bucket."
  type        = string
  default     = "gemini_logs_raw"
}

variable "raw_log_retention_days" {
  description = "Days the raw log bucket (which contains prompt text) keeps entries."
  type        = number
  default     = 2
}

variable "route_inference_logs" {
  description = "Route the gen_ai inference log for token, tool and skill reporting."
  type        = bool
  default     = true
}

variable "enable_model_armor_audit_logs" {
  description = "Turn on Model Armor Data Access audit logs (screening verdicts, no prompt text) in the log source projects."
  type        = bool
  default     = false
}

variable "exclude_content_logs_from_default_bucket" {
  description = "Keep Gemini Enterprise and Antigravity prompt/response logs out of the _Default log bucket."
  type        = bool
  default     = false
}

variable "user_store_locations" {
  description = "Gemini Enterprise user store locations to snapshot licences from. Defaults to the engine locations."
  type        = list(string)
  default     = null
}

variable "log_app_display_names" {
  description = "Friendly app names for engine IDs that appear in the logs but are not listed in engines."
  type        = map(string)
  default     = {}
}

variable "log_transform_schedule" {
  description = "Cron schedule for the hourly raw-log transform."
  type        = string
  default     = "20 * * * *"
}

variable "license_snapshot_schedule" {
  description = "Cron schedule for the daily licence snapshot."
  type        = string
  default     = "0 5 * * *"
}

variable "workspace_audit_project_id" {
  description = "Project holding the Workspace audit export dataset. Defaults to project_id."
  type        = string
  default     = ""
}

variable "workspace_audit_dataset_id" {
  description = "Workspace audit export dataset (created by the Workspace Admin console BigQuery export). When set and workspace_audit_location differs from dataset_location, a daily BigQuery cross-region copy brings it into dataset_location so the Looker block can join it to the Gemini data. Leave empty to skip."
  type        = string
  default     = ""
}

variable "workspace_audit_location" {
  description = "BigQuery location of the Workspace audit export dataset, for example US. Check it with: bq show --format=prettyjson PROJECT:DATASET."
  type        = string
  default     = ""
}

variable "workspace_copy_dataset_id" {
  description = "Dataset in dataset_location that receives the Workspace audit copy. Set the Looker workspace_dataset constant to this name and workspace_export to same_region."
  type        = string
  default     = "workspace_audit_copy"
}
