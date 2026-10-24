locals {
  engine_project_id  = coalesce(var.engine_project_id, var.project_id)
  staging_project_id = coalesce(var.staging_project_id, local.engine_project_id)

  pipeline_project_services = toset([
    "bigquery.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
  ])

  engine_project_services = toset([
    "bigquery.googleapis.com",
    "discoveryengine.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  engines_by_id = {
    for engine in var.engines : engine.engine_id => merge(engine, {
      endpoint_location = coalesce(engine.endpoint_location, engine.location)
      table_id_prefix   = coalesce(engine.table_id_prefix, "export_${replace(engine.engine_id, "-", "_")}")
      display_name      = coalesce(engine.display_name, engine.engine_id)
    })
  }

  # An engine's analytics export writes BigQuery output in the region of the
  # app's data: eu apps export in the EU, global/us apps in the US. The staging
  # and analytics datasets must live in that same location or the export fails
  # with a cross-region "dataset not found" error.
  expected_dataset_location = {
    eu     = "EU"
    global = "US"
    us     = "US"
  }

  engine_locations_consistent = alltrue([
    for engine in var.engines :
    upper(var.dataset_location) == lookup(local.expected_dataset_location, lower(engine.location), upper(var.dataset_location))
  ])
}
