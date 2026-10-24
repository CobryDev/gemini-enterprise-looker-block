-- Connector tool failures from the connector_activity log.
--
-- The error message can echo the user's request, so it is only matched
-- against patterns to produce error_category and is never copied. The user
-- comes from the ge_user_activity row with the same assist token or trace.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING>.
MERGE `{analytics_dataset}.ge_connector_activity` AS target
USING (
  WITH app_names AS (
    SELECT engine_id, @app_display_names[SAFE_OFFSET(i)] AS app_name
    FROM UNNEST(@app_engine_ids) AS engine_id WITH OFFSET AS i
  ),

  activity AS (
    SELECT assist_token, trace_id, user_email, engine_id
    FROM `{analytics_dataset}.ge_user_activity`
    WHERE event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
      AND user_email IS NOT NULL
  ),

  token_users AS (
    SELECT assist_token, ANY_VALUE(user_email) AS user_email, ANY_VALUE(engine_id) AS engine_id
    FROM activity
    WHERE assist_token IS NOT NULL
    GROUP BY assist_token
  ),

  trace_users AS (
    SELECT trace_id, ANY_VALUE(user_email) AS user_email, ANY_VALUE(engine_id) AS engine_id
    FROM activity
    WHERE trace_id IS NOT NULL
    GROUP BY trace_id
  ),

  raw AS (
    SELECT
      insert_id,
      timestamp AS event_ts,
      REGEXP_EXTRACT(log_name, r'^projects/([^/]+)/') AS project_id,
      JSON_VALUE(resource.labels.location) AS location,
      JSON_VALUE(resource.labels.connector_id) AS connector_id,
      severity,
      REGEXP_EXTRACT(trace, r'([^/]+)$') AS trace_id,
      JSON_VALUE(json_payload.dataConnectorInfo.connectorType) AS connector_type,
      JSON_VALUE(json_payload.dataConnectorInfo.tool) AS tool,
      JSON_VALUE(json_payload.dataConnectorInfo.agent) AS agent,
      JSON_VALUE(json_payload.assistToken) AS assist_token,
      CASE
        WHEN json_payload.message IS NULL THEN NULL
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)reconnect')
          THEN 'Reconnect required'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)authori[sz]ation|consent|oauth|unauthenticated|401')
          THEN 'Authorisation or consent'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)download not allowed')
          THEN 'Download blocked'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)permission|forbidden|403')
          THEN 'Permission denied'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)unsupported query field')
          THEN 'Unsupported query'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)parameter_validation|missing required|invalid')
          THEN 'Invalid request'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)not.found|404')
          THEN 'Not found'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)rate limit|quota|429|too many')
          THEN 'Rate limited'
        WHEN REGEXP_CONTAINS(JSON_VALUE(json_payload.message), r'(?i)timeout|timed out|deadline')
          THEN 'Timeout'
        ELSE 'Other'
      END AS error_category
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'discoveryengine.googleapis.com/connector_activity'
      AND json_payload IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  ),

  attributed AS (
    SELECT
      raw.*,
      COALESCE(token_users.user_email, trace_users.user_email) AS user_email,
      COALESCE(token_users.engine_id, trace_users.engine_id) AS engine_id
    FROM raw
    LEFT JOIN token_users USING (assist_token)
    LEFT JOIN trace_users USING (trace_id)
  )

  SELECT
    insert_id,
    event_ts,
    DATE(event_ts) AS event_date,
    project_id,
    location,
    connector_id,
    connector_type,
    tool,
    agent,
    severity,
    error_category,
    assist_token,
    trace_id,
    user_email,
    attributed.engine_id,
    COALESCE(app_names.app_name, attributed.engine_id) AS app_name,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM attributed
  LEFT JOIN app_names USING (engine_id)
) AS source
ON target.insert_id = source.insert_id
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN MATCHED AND target.user_email IS NULL AND source.user_email IS NOT NULL THEN
  UPDATE SET
    user_email = source.user_email,
    engine_id = source.engine_id,
    app_name = source.app_name
WHEN NOT MATCHED THEN
  INSERT (
    insert_id, event_ts, event_date, project_id, location, connector_id, connector_type, tool,
    agent, severity, error_category, assist_token, trace_id, user_email, engine_id, app_name,
    ingested_at
  )
  VALUES (
    insert_id, event_ts, event_date, project_id, location, connector_id, connector_type, tool,
    agent, severity, error_category, assist_token, trace_id, user_email, engine_id, app_name,
    ingested_at
  )
