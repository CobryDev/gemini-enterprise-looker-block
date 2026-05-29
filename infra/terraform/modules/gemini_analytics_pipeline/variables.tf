variable "project_id" {
  description = "GCP project that hosts the pipeline."
  type        = string
}

variable "engine_project_id" {
  description = "GCP project that owns the Gemini Enterprise engines. Defaults to project_id."
  type        = string
  default     = null
}

variable "staging_project_id" {
  description = "GCP project for raw Gemini Enterprise export tables. Defaults to engine_project_id."
  type        = string
  default     = null
}

variable "region" {
  description = "Region for Cloud Run and Cloud Scheduler."
  type        = string
}

variable "dataset_location" {
  description = "BigQuery dataset location."
  type        = string
}

variable "staging_dataset_id" {
  description = "BigQuery staging dataset ID."
  type        = string
}

variable "analytics_dataset_id" {
  description = "BigQuery analytics dataset ID."
  type        = string
}

variable "exporter_image" {
  description = "Container image for the exporter job."
  type        = string
}

variable "metric_filter" {
  description = "Metric filter passed to analytics:exportMetrics."
  type        = string
}

variable "engines" {
  description = "Gemini Enterprise engines to export."
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
