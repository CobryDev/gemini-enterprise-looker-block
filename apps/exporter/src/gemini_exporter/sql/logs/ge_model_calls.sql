-- One row per model inference from the gen_ai inference log: token counts,
-- finish reasons and how many tools the model called.
--
-- The entry replays the conversation (gen_ai.input.messages) and the model
-- output (gen_ai.output.messages); only counts are derived from them. The
-- entry's own user.id is redacted, so the user comes from the
-- ge_user_activity row that shares the trace.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING>.
MERGE `{analytics_dataset}.ge_model_calls` AS target
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
      REGEXP_EXTRACT(log_name, r'^projects/([^/]+)/') AS project_id,
      JSON_VALUE(resource.labels.location) AS location,
      JSON_VALUE(resource.labels.engine_id) AS engine_id,
      JSON_VALUE(resource.labels.agent_id) AS agent_id,
      REGEXP_EXTRACT(trace, r'([^/]+)$') AS trace_id,
      json_payload AS p
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'discoveryengine.googleapis.com/gen_ai.client.inference.operation.details'
      AND json_payload IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  )

  SELECT
    insert_id,
    event_ts,
    DATE(event_ts) AS event_date,
    project_id,
    location,
    raw.engine_id,
    COALESCE(app_names.app_name, raw.engine_id) AS app_name,
    raw.trace_id,
    trace_users.user_email,
    agent_id,
    JSON_VALUE(p['gen_ai.agent.name']) AS agent_name,
    JSON_VALUE(p['gen_ai.conversation.id']) AS conversation_id,
    LAX_INT64(p['gen_ai.usage.input_tokens']) AS input_tokens,
    LAX_INT64(p['gen_ai.usage.output_tokens']) AS output_tokens,
    LAX_INT64(p['gen_ai.usage.cache_read.input_tokens']) AS cached_input_tokens,
    LAX_INT64(p['gen_ai.usage.reasoning.output_tokens']) AS reasoning_tokens,
    ARRAY(
      SELECT reason
      FROM UNNEST(JSON_VALUE_ARRAY(p['gen_ai.response.finish_reasons'])) AS reason
      WHERE reason IS NOT NULL
    ) AS finish_reasons,
    (
      SELECT COUNT(*)
      FROM UNNEST(JSON_QUERY_ARRAY(p['gen_ai.output.messages'])) AS message,
        UNNEST(JSON_QUERY_ARRAY(message.parts)) AS part
      WHERE JSON_VALUE(part.type) = 'tool_call'
    ) AS tool_call_count,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM raw
  LEFT JOIN app_names USING (engine_id)
  LEFT JOIN trace_users USING (trace_id)
) AS source
ON target.insert_id = source.insert_id
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN MATCHED AND target.user_email IS NULL AND source.user_email IS NOT NULL THEN
  UPDATE SET user_email = source.user_email
WHEN NOT MATCHED THEN
  INSERT (
    insert_id, event_ts, event_date, project_id, location, engine_id, app_name, trace_id,
    user_email, agent_id, agent_name, conversation_id, input_tokens, output_tokens,
    cached_input_tokens, reasoning_tokens, finish_reasons, tool_call_count, ingested_at
  )
  VALUES (
    insert_id, event_ts, event_date, project_id, location, engine_id, app_name, trace_id,
    user_email, agent_id, agent_name, conversation_id, input_tokens, output_tokens,
    cached_input_tokens, reasoning_tokens, finish_reasons, tool_call_count, ingested_at
  )
