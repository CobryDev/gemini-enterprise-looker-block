variable "project_id" {
  description = "GCP project that owns the Gemini Enterprise engines (the source project)."
  type        = string
}

variable "staging_project_id" {
  description = "Project for the raw analytics export tables. Defaults to project_id because the export API writes in the app project."
  type        = string
  default     = null
}

variable "raw_logs_project_id" {
  description = "Project that holds the raw log bucket and its linked dataset. Defaults to project_id."
  type        = string
  default     = null
}

variable "dataset_location" {
  description = "BigQuery location for the staging dataset and raw log bucket. Use US for global/US engines and EU for EU engines. Must match the analytics dataset."
  type        = string
}

variable "staging_dataset_id" {
  description = "BigQuery dataset for rolling 30-day Gemini Enterprise export tables."
  type        = string
  default     = "gemini_analytics_staging"
}

variable "exporter_service_account_email" {
  description = "Exporter service account in the analytics project, for example gemini-exporter@ANALYTICS_PROJECT.iam.gserviceaccount.com."
  type        = string
  default     = ""
}

variable "grant_exporter_access" {
  description = "Grant the exporter service account access to the staging dataset, raw logs and Discovery Engine. Leave false until the analytics side has created the service account, because IAM rejects grants to accounts that don't exist yet."
  type        = bool
  default     = true
}

variable "manage_project_services" {
  description = "Enable the APIs the source side needs. Set false if the source project's APIs are managed elsewhere."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enable_log_pipeline" {
  description = "Route Gemini Enterprise, Model Armor and Antigravity logs into a short-lived raw log bucket for the exporter's hourly transform."
  type        = bool
  default     = false
}

variable "log_source_project_ids" {
  description = "Projects whose Gemini Enterprise, Model Armor and Antigravity logs are routed. Defaults to [project_id]."
  type        = list(string)
  default     = []
}

variable "raw_logs_dataset_id" {
  description = "Name of the read-only BigQuery dataset linked to the raw log bucket. Only the exporter can read it."
  type        = string
  default     = "gemini_logs_raw"
}

variable "raw_log_retention_days" {
  description = "Days the raw log bucket keeps entries. Raw entries include prompt text, so keep this short."
  type        = number
  default     = 2

  validation {
    condition     = var.raw_log_retention_days >= 1 && var.raw_log_retention_days <= 7
    error_message = "raw_log_retention_days must be between 1 and 7."
  }
}

variable "route_inference_logs" {
  description = "Route the gen_ai inference log (token usage, tool calls, skills)."
  type        = bool
  default     = true
}

variable "enable_model_armor_audit_logs" {
  description = "Turn on Data Access (DATA_READ) audit logs for the Model Armor API in every log source project."
  type        = bool
  default     = false
}

variable "exclude_content_logs_from_default_bucket" {
  description = "Exclude Gemini Enterprise and Antigravity logs that carry prompt or response text from the _Default log bucket."
  type        = bool
  default     = false
}
