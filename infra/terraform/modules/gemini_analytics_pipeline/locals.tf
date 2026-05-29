locals {
  engine_project_id  = coalesce(var.engine_project_id, var.project_id)
  staging_project_id = coalesce(var.staging_project_id, local.engine_project_id)

  pipeline_project_services = toset([
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
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

  engine_config = {
    engines = [
      for engine in values(local.engines_by_id) : {
        engine_id         = engine.engine_id
        display_name      = engine.display_name
        location          = engine.location
        endpoint_location = engine.endpoint_location
        table_id_prefix   = engine.table_id_prefix
      }
    ]
  }

  # engine_id -> friendly app name, injected into the merge query so every row in
  # export_history carries a readable app_name alongside the raw engine_id.
  engine_app_names = {
    for engine in values(local.engines_by_id) : engine.engine_id => engine.display_name
  }
}
