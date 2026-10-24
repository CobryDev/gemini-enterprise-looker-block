-- One row per Antigravity inference from InferenceResponseLog entries, which
-- carry usage metadata only. InferenceRequestLog (the prompt) is never routed
-- to the raw bucket.
--
-- Parameters: @window_start TIMESTAMP (the app-name parameters are unused).
MERGE `{analytics_dataset}.antigravity_usage` AS target
USING (
  SELECT
    insert_id,
    timestamp AS event_ts,
    DATE(timestamp) AS event_date,
    REGEXP_EXTRACT(log_name, r'^projects/([^/]+)/') AS project_id,
    LOWER(REGEXP_REPLACE(JSON_VALUE(labels.user_id), r'^user:', '')) AS user_email,
    JSON_VALUE(labels.client_name) AS client_name,
    JSON_VALUE(labels.client_version) AS client_version,
    JSON_VALUE(labels.model) AS model,
    JSON_VALUE(json_payload.experience) AS experience,
    LAX_INT64(json_payload.metadata.totalTokenCount) AS total_tokens,
    JSON_VALUE(labels.request_id) AS request_id,
    JSON_VALUE(labels.trajectory_id) AS trajectory_id,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM `{raw_logs_view}`
  WHERE timestamp >= @window_start
    AND resource.type = 'businessaicode.googleapis.com/BAICInstance'
    AND JSON_VALUE(json_payload['@type'])
      = 'type.googleapis.com/google.cloud.businessaicode.logging.v1.InferenceResponseLog'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
) AS source
ON target.insert_id = source.insert_id
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN NOT MATCHED THEN
  INSERT (
    insert_id, event_ts, event_date, project_id, user_email, client_name, client_version, model,
    experience, total_tokens, request_id, trajectory_id, ingested_at
  )
  VALUES (
    insert_id, event_ts, event_date, project_id, user_email, client_name, client_version, model,
    experience, total_tokens, request_id, trajectory_id, ingested_at
  )
