-- Prompt and response screening, from two sources:
--
-- MODEL_ARMOR: Model Armor Data Access audit entries (SanitizeUserPrompt,
--   SanitizeModelResponse). One row per matched filter category, or one row
--   with a null category when the content passed. The audit entry carries the
--   verdict, not the screened text. Gemini Enterprise calls Model Armor as its
--   service agent, so the user is taken from the ge_user_activity row with the
--   same trace, else the nearest assistant call within 10 seconds (preferring
--   a blocked answer when the verdict was a match).
-- GEMINI_ENTERPRISE: answers Gemini Enterprise skipped for a policy reason,
--   one row per skip reason, attributed directly from the activity log.
--
-- Log Analytics types the AuditLog fields; only the response body is JSON.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING>.
MERGE `{analytics_dataset}.ge_safety_events` AS target
USING (
  WITH app_names AS (
    SELECT engine_id, @app_display_names[SAFE_OFFSET(i)] AS app_name
    FROM UNNEST(@app_engine_ids) AS engine_id WITH OFFSET AS i
  ),

  activity AS (
    SELECT insert_id, event_ts, event_date, project_id, engine_id, trace_id, user_email,
      method, is_blocked, skipped_reasons
    FROM `{analytics_dataset}.ge_user_activity`
    WHERE event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
      AND event_ts >= TIMESTAMP_SUB(@window_start, INTERVAL 1 MINUTE)
  ),

  trace_users AS (
    SELECT trace_id, ANY_VALUE(user_email) AS user_email, ANY_VALUE(engine_id) AS engine_id
    FROM activity
    WHERE trace_id IS NOT NULL AND user_email IS NOT NULL
    GROUP BY trace_id
  ),

  audit_raw AS (
    SELECT
      insert_id,
      timestamp AS event_ts,
      REGEXP_EXTRACT(log_name, r'^projects/([^/]+)/') AS project_id,
      REGEXP_EXTRACT(trace, r'([^/]+)$') AS trace_id,
      proto_payload.audit_log AS audit
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'cloudaudit.googleapis.com/data_access'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  ),

  audit_fields AS (
    SELECT
      insert_id,
      event_ts,
      project_id,
      trace_id,
      audit.service_name,
      audit.method_name,
      audit.resource_name,
      LOWER(audit.authentication_info.principal_email) AS principal_email,
      COALESCE(
        audit.response.sanitizationResult, audit.response.sanitization_result
      ) AS result
    FROM audit_raw
  ),

  verdicts AS (
    SELECT
      insert_id,
      event_ts,
      project_id,
      trace_id,
      principal_email,
      IF(ENDS_WITH(method_name, 'SanitizeModelResponse'), 'RESPONSE', 'PROMPT')
        AS screened_content,
      REGEXP_EXTRACT(resource_name, r'/templates/([^/]+)') AS template,
      JSON_VALUE(result.filterMatchState) AS filter_match_state,
      JSON_VALUE(result.invocationResult) AS invocation_result,
      ARRAY(
        SELECT filter.category
        FROM UNNEST([
          STRUCT(
            'sexually_explicit' AS category,
            JSON_VALUE(result.filterResults.rai.raiFilterResult.raiFilterTypeResults.sexually_explicit.matchState) AS match_state
          ),
          STRUCT(
            'hate_speech',
            JSON_VALUE(result.filterResults.rai.raiFilterResult.raiFilterTypeResults.hate_speech.matchState)
          ),
          STRUCT(
            'harassment',
            JSON_VALUE(result.filterResults.rai.raiFilterResult.raiFilterTypeResults.harassment.matchState)
          ),
          STRUCT(
            'dangerous',
            JSON_VALUE(result.filterResults.rai.raiFilterResult.raiFilterTypeResults.dangerous.matchState)
          ),
          STRUCT(
            'pi_and_jailbreak',
            JSON_VALUE(result.filterResults.pi_and_jailbreak.piAndJailbreakFilterResult.matchState)
          ),
          STRUCT(
            'malicious_uris',
            JSON_VALUE(result.filterResults.malicious_uris.maliciousUriFilterResult.matchState)
          ),
          STRUCT(
            'csam',
            JSON_VALUE(result.filterResults.csam.csamFilterFilterResult.matchState)
          ),
          STRUCT(
            'sensitive_data',
            JSON_VALUE(result.filterResults.sdp.sdpFilterResult.inspectResult.matchState)
          ),
          STRUCT(
            'virus_scan',
            JSON_VALUE(result.filterResults.virus_scan.virusScanFilterResult.matchState)
          )
        ]) AS filter
        WHERE filter.match_state = 'MATCH_FOUND'
      ) AS matched_categories
    FROM audit_fields
    WHERE service_name = 'modelarmor.googleapis.com'
      AND method_name LIKE '%Sanitize%'
  ),

  model_armor AS (
    SELECT
      CONCAT(insert_id, ':', IFNULL(category, 'none')) AS row_key,
      insert_id AS event_id,
      event_ts,
      project_id,
      screened_content,
      template,
      category,
      category IS NOT NULL OR filter_match_state = 'MATCH_FOUND' AS is_match,
      filter_match_state,
      invocation_result,
      trace_id,
      principal_email
    FROM verdicts
    LEFT JOIN UNNEST(
      IF(ARRAY_LENGTH(matched_categories) = 0, [CAST(NULL AS STRING)], matched_categories)
    ) AS category
  ),

  window_matches AS (
    SELECT
      model_armor.row_key,
      activity.user_email,
      activity.engine_id,
      activity.trace_id
    FROM model_armor
    JOIN activity
      ON activity.method IN ('StreamAssist', 'Assist')
      AND activity.user_email IS NOT NULL
      AND activity.event_ts BETWEEN TIMESTAMP_SUB(model_armor.event_ts, INTERVAL 10 SECOND)
        AND TIMESTAMP_ADD(model_armor.event_ts, INTERVAL 10 SECOND)
    WHERE model_armor.principal_email LIKE '%@gcp-sa-discoveryengine.iam.gserviceaccount.com'
    QUALIFY ROW_NUMBER() OVER (
      PARTITION BY model_armor.row_key
      ORDER BY
        IF(IFNULL(activity.is_blocked, FALSE) = model_armor.is_match, 0, 1),
        ABS(TIMESTAMP_DIFF(activity.event_ts, model_armor.event_ts, MILLISECOND))
    ) = 1
  ),

  model_armor_attributed AS (
    SELECT
      model_armor.row_key,
      model_armor.event_id,
      model_armor.event_ts,
      model_armor.project_id,
      'MODEL_ARMOR' AS source,
      model_armor.screened_content,
      model_armor.template,
      model_armor.category,
      model_armor.is_match,
      model_armor.filter_match_state,
      model_armor.invocation_result,
      COALESCE(trace_users.engine_id, window_matches.engine_id) AS engine_id,
      COALESCE(model_armor.trace_id, window_matches.trace_id) AS trace_id,
      CASE
        WHEN NOT ENDS_WITH(model_armor.principal_email, 'gserviceaccount.com')
          THEN model_armor.principal_email
        ELSE COALESCE(trace_users.user_email, window_matches.user_email)
      END AS user_email,
      CASE
        WHEN NOT ENDS_WITH(model_armor.principal_email, 'gserviceaccount.com') THEN 'log'
        WHEN trace_users.user_email IS NOT NULL THEN 'trace'
        WHEN window_matches.user_email IS NOT NULL THEN 'time_window'
        ELSE 'unattributed'
      END AS attribution_method
    FROM model_armor
    LEFT JOIN trace_users USING (trace_id)
    LEFT JOIN window_matches USING (row_key)
  ),

  gemini_enterprise AS (
    SELECT
      CONCAT(activity.insert_id, ':', reason) AS row_key,
      activity.insert_id AS event_id,
      activity.event_ts,
      activity.project_id,
      'GEMINI_ENTERPRISE' AS source,
      CAST(NULL AS STRING) AS screened_content,
      CAST(NULL AS STRING) AS template,
      LOWER(reason) AS category,
      TRUE AS is_match,
      CAST(NULL AS STRING) AS filter_match_state,
      CAST(NULL AS STRING) AS invocation_result,
      activity.engine_id,
      activity.trace_id,
      activity.user_email,
      'log' AS attribution_method
    FROM activity, UNNEST(activity.skipped_reasons) AS reason
    WHERE activity.is_blocked
      AND activity.event_ts >= @window_start
  ),

  combined AS (
    SELECT * FROM model_armor_attributed
    UNION ALL
    SELECT * FROM gemini_enterprise
  )

  SELECT
    row_key,
    event_id,
    event_ts,
    DATE(event_ts) AS event_date,
    project_id,
    source,
    screened_content,
    template,
    category,
    is_match,
    filter_match_state,
    invocation_result,
    combined.engine_id,
    COALESCE(app_names.app_name, combined.engine_id) AS app_name,
    trace_id,
    user_email,
    attribution_method,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM combined
  LEFT JOIN app_names USING (engine_id)
) AS src
ON target.row_key = src.row_key
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN MATCHED AND target.user_email IS NULL AND src.user_email IS NOT NULL THEN
  UPDATE SET
    user_email = src.user_email,
    engine_id = src.engine_id,
    app_name = src.app_name,
    trace_id = src.trace_id,
    attribution_method = src.attribution_method
WHEN NOT MATCHED THEN
  INSERT (
    row_key, event_id, event_ts, event_date, project_id, source, screened_content, template,
    category, is_match, filter_match_state, invocation_result, engine_id, app_name, trace_id,
    user_email, attribution_method, ingested_at
  )
  VALUES (
    row_key, event_id, event_ts, event_date, project_id, source, screened_content, template,
    category, is_match, filter_match_state, invocation_result, engine_id, app_name, trace_id,
    user_email, attribution_method, ingested_at
  )
