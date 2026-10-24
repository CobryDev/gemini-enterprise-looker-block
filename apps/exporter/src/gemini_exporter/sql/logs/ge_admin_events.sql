-- Gemini Enterprise Admin Activity audit events: who changed which agent,
-- connector or app. Request and response bodies (agent instructions,
-- connector settings) are not read.
--
-- Log Analytics stores the AuditLog under proto_payload.audit_log with
-- snake_case keys; the camelCase paths are a fallback for the raw proto.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING>.
MERGE `{analytics_dataset}.ge_admin_events` AS target
USING (
  WITH app_names AS (
    SELECT engine_id, @app_display_names[SAFE_OFFSET(i)] AS app_name
    FROM UNNEST(@app_engine_ids) AS engine_id WITH OFFSET AS i
  ),

  raw AS (
    SELECT
      insert_id,
      timestamp AS event_ts,
      REGEXP_EXTRACT(log_name, r'^projects/([^/]+)/') AS project_id,
      COALESCE(proto_payload.audit_log, proto_payload) AS audit
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'cloudaudit.googleapis.com/activity'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  ),

  fields AS (
    SELECT
      insert_id,
      event_ts,
      project_id,
      COALESCE(JSON_VALUE(audit.service_name), JSON_VALUE(audit.serviceName)) AS service_name,
      LOWER(COALESCE(
        JSON_VALUE(audit.authentication_info.principal_email),
        JSON_VALUE(audit.authenticationInfo.principalEmail)
      )) AS principal_email,
      COALESCE(JSON_VALUE(audit.method_name), JSON_VALUE(audit.methodName)) AS full_method_name,
      COALESCE(JSON_VALUE(audit.resource_name), JSON_VALUE(audit.resourceName)) AS resource_name,
      LAX_INT64(audit.status.code) AS status_code
    FROM raw
  ),

  events AS (
    SELECT
      *,
      REGEXP_EXTRACT(full_method_name, r'([^.]+)$') AS method,
      COALESCE(
        REGEXP_EXTRACT(resource_name, r'/([A-Za-z]+)/[^/]+$'),
        REGEXP_EXTRACT(resource_name, r'/([A-Za-z]+)$')
      ) AS resource_type,
      REGEXP_EXTRACT(resource_name, r'/engines/([^/]+)') AS engine_id
    FROM fields
    WHERE service_name = 'discoveryengine.googleapis.com'
  )

  SELECT
    insert_id,
    event_ts,
    DATE(event_ts) AS event_date,
    project_id,
    principal_email,
    method,
    full_method_name,
    resource_type,
    resource_name,
    events.engine_id,
    COALESCE(app_names.app_name, events.engine_id) AS app_name,
    IFNULL(status_code, 0) AS status_code,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM events
  LEFT JOIN app_names USING (engine_id)
) AS source
ON target.insert_id = source.insert_id
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN NOT MATCHED THEN
  INSERT (
    insert_id, event_ts, event_date, project_id, principal_email, method, full_method_name,
    resource_type, resource_name, engine_id, app_name, status_code, ingested_at
  )
  VALUES (
    insert_id, event_ts, event_date, project_id, principal_email, method, full_method_name,
    resource_type, resource_name, engine_id, app_name, status_code, ingested_at
  )
