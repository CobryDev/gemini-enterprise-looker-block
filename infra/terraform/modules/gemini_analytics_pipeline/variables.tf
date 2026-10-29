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
  description = "Create the source-project resources (staging dataset, raw log bucket, sinks and the exporter's grants in the engine project) from this module. Set false when the engine project is managed separately with the gemini_analytics_source module; this module then only references them by name."
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

  validation {
    condition     = length(var.engines) > 0
    error_message = "Configure at least one engine."
  }

  validation {
    condition     = length(distinct([for engine in var.engines : lower(engine.location)])) <= 1
    error_message = "All engines in one deployment must share the same location. Engines in different regions export to different BigQuery locations and cannot merge into a single export_history table; deploy this stack once per region instead."
  }

  validation {
    condition     = length(distinct([for engine in var.engines : engine.engine_id])) == length(var.engines)
    error_message = "Engine IDs must be unique."
  }
}

variable "alert_email" {
  description = "Email address to notify when an exporter job execution fails. Leave empty to skip creating alerting resources."
  type        = string
  default     = ""
}

variable "looker_service_account_email" {
  description = "Looker connection service account. When set, grants it BigQuery Data Viewer on the analytics dataset and BigQuery Job User on the project. Leave empty to manage Looker access manually."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enable_log_pipeline" {
  description = "Route Gemini Enterprise, Model Armor and Antigravity logs into a short-lived raw log bucket and transform them hourly into redacted, user-level tables for the executive, change-management and admin Looker dashboards."
  type        = bool
  default     = false
}

variable "log_source_project_ids" {
  description = "Projects whose Gemini Enterprise, Model Armor and Antigravity logs are routed. Defaults to [engine_project_id]. Add the Model Armor template project and the Antigravity subscription project if they differ."
  type        = list(string)
  default     = []
}

variable "raw_logs_dataset_id" {
  description = "Name of the read-only BigQuery dataset linked to the raw log bucket. Only the exporter can read it."
  type        = string
  default     = "gemini_logs_raw"
}

variable "raw_log_retention_days" {
  description = "Days the raw log bucket keeps entries. Raw entries include prompt text, so keep this short; the hourly transform only needs a few hours, the rest is headroom to fix a failed run."
  type        = number
  default     = 2

  validation {
    condition     = var.raw_log_retention_days >= 1 && var.raw_log_retention_days <= 7
    error_message = "raw_log_retention_days must be between 1 and 7."
  }
}

variable "route_inference_logs" {
  description = "Route the gen_ai inference log (token usage, tool calls, skills). Entries are large because they replay the conversation; disable to cut log volume at the cost of token, tool and skill reporting."
  type        = bool
  default     = true
}

variable "enable_model_armor_audit_logs" {
  description = "Turn on Data Access (DATA_READ) audit logs for the Model Armor API in every log source project, so prompt and response screening verdicts are logged. Verdict audit entries don't contain prompt text."
  type        = bool
  default     = false
}

variable "exclude_content_logs_from_default_bucket" {
  description = "Exclude Gemini Enterprise and Antigravity logs that carry prompt or response text from the _Default log bucket (30-day retention), so the short-lived raw bucket is the only place they are kept."
  type        = bool
  default     = false
}

variable "user_store_locations" {
  description = "Locations of the Gemini Enterprise user stores to snapshot licences from (global, us, eu). Defaults to the distinct engine locations."
  type        = list(string)
  default     = null
}

variable "log_app_display_names" {
  description = "Friendly app names for engine IDs that appear in the logs but are not in engines (for example a global app in an EU deployment). Merged over the engines' display names."
  type        = map(string)
  default     = {}
}

variable "log_transform_schedule" {
  description = "Cron schedule for the hourly raw-log transform."
  type        = string
  default     = "20 * * * *"
}

variable "license_snapshot_schedule" {
  description = "Cron schedule for the daily per-user licence snapshot."
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
