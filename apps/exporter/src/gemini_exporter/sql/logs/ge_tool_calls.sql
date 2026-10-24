-- One row per tool call in the model output of the gen_ai inference log.
--
-- Output messages hold only the calls made in this inference (history is in
-- the input messages), and each call carries a unique id, which is the merge
-- key. Tool arguments are search queries, file IDs and code, so the only
-- argument read is skill_name on load_skill calls.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING>.
MERGE `{analytics_dataset}.ge_tool_calls` AS target
USING (
  WITH app_names AS (
    SELECT engine_id, @app_display_names[SAFE_OFFSET(i)] AS app_name
    FROM UNNEST(@app_engine_ids) AS engine_id WITH OFFSET AS i
  ),

  trace_users AS (
    SELECT trace_id, ANY_VALUE(user_email) AS user_email
    FROM `{analytics_dataset}.ge_user_activity`
    WHERE event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
      AND trace_id IS NOT NULL
      AND user_email IS NOT NULL
    GROUP BY trace_id
  ),

  raw AS (
    SELECT
      insert_id,
      timestamp AS event_ts,
      JSON_VALUE(resource.labels.engine_id) AS engine_id,
      REGEXP_EXTRACT(trace, r'([^/]+)$') AS trace_id,
      json_payload AS p
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'discoveryengine.googleapis.com/gen_ai.client.inference.operation.details'
      AND json_payload IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  ),

  calls AS (
    SELECT
      raw.insert_id,
      raw.event_ts,
      raw.engine_id,
      raw.trace_id,
      JSON_VALUE(raw.p['gen_ai.agent.name']) AS agent_name,
      message_index * 1000 + part_index AS call_index,
      JSON_VALUE(part.id) AS call_id,
      JSON_VALUE(part.name) AS tool_name,
      IF(
        JSON_VALUE(part.name) IN ('load_skill', 'load_skill_resource'),
        JSON_VALUE(part.arguments.skill_name),
        NULL
      ) AS skill_name
    FROM raw,
      UNNEST(JSON_QUERY_ARRAY(raw.p['gen_ai.output.messages'])) AS message
        WITH OFFSET AS message_index,
      UNNEST(JSON_QUERY_ARRAY(message.parts)) AS part WITH OFFSET AS part_index
    WHERE JSON_VALUE(part.type) = 'tool_call'
  )

  SELECT
    COALESCE(call_id, CONCAT(insert_id, ':', CAST(call_index AS STRING))) AS row_key,
    insert_id,
    call_index,
    event_ts,
    DATE(event_ts) AS event_date,
    calls.engine_id,
    COALESCE(app_names.app_name, calls.engine_id) AS app_name,
    calls.trace_id,
    trace_users.user_email,
    agent_name,
    tool_name,
    IF(STRPOS(tool_name, '__') > 0, SPLIT(tool_name, '__')[OFFSET(0)], tool_name) AS tool_family,
    skill_name,
    tool_name IN ('load_skill', 'load_skill_resource', 'list_skills') AS is_skill_call,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM calls
  LEFT JOIN app_names USING (engine_id)
  LEFT JOIN trace_users USING (trace_id)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY row_key ORDER BY event_ts, insert_id) = 1
) AS source
ON target.row_key = source.row_key
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN MATCHED AND target.user_email IS NULL AND source.user_email IS NOT NULL THEN
  UPDATE SET user_email = source.user_email
WHEN NOT MATCHED THEN
  INSERT (
    row_key, insert_id, call_index, event_ts, event_date, engine_id, app_name, trace_id,
    user_email, agent_name, tool_name, tool_family, skill_name, is_skill_call, ingested_at
  )
  VALUES (
    row_key, insert_id, call_index, event_ts, event_date, engine_id, app_name, trace_id,
    user_email, agent_name, tool_name, tool_family, skill_name, is_skill_call, ingested_at
  )
