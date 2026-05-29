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

variable "analytics_dataset_id" {
  description = "BigQuery dataset for longitudinal analytics tables consumed by Looker."
  type        = string
  default     = "gemini_analytics"
}

variable "exporter_image" {
  description = "Container image for the Cloud Run exporter job."
  type        = string
}

variable "metric_filter" {
  description = "Metric filter passed to analytics:exportMetrics."
  type        = string
  default     = "metric_types: (TOTAL_USERS, DAU, WAU, MAU, SEARCH_COUNT, ANSWER_COUNT)"
}

variable "engines" {
  description = "Gemini Enterprise engines to export. Stagger schedules to stay below org-level API limits."
  type = list(object({
    engine_id         = string
    location          = string
    endpoint_location = optional(string)
    schedule          = string
    time_zone         = optional(string, "Etc/UTC")
    table_id_prefix   = optional(string)
  }))
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
