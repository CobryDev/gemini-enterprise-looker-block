-- Redacted copy of the Gemini Enterprise user-activity log.
--
-- Entries carry the full request and response (prompt text, answer text,
-- grounding snippets, file names, action arguments). Only the metadata paths
-- named below are read; none of those content fields are selected.
--
-- Parameters: @window_start TIMESTAMP, @app_engine_ids ARRAY<STRING>,
-- @app_display_names ARRAY<STRING> (parallel to @app_engine_ids).
MERGE `{analytics_dataset}.ge_user_activity` AS target
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
      JSON_VALUE(resource.labels.location) AS location,
      JSON_VALUE(resource.labels.method) AS resource_method,
      REGEXP_EXTRACT(trace, r'([^/]+)$') AS trace_id,
      json_payload AS p
    FROM `{raw_logs_view}`
    WHERE timestamp >= @window_start
      AND log_id = 'discoveryengine.googleapis.com/gemini_enterprise_user_activity'
      AND json_payload IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY insert_id ORDER BY timestamp) = 1
  ),

  fields AS (
    SELECT
      insert_id,
      event_ts,
      project_id,
      location,
      trace_id,
      LOWER(JSON_VALUE(p.userIamPrincipal)) AS user_email,
      REGEXP_EXTRACT(
        COALESCE(JSON_VALUE(p.logMetadata.methodName), resource_method), r'([^./]+)$'
      ) AS method,
      COALESCE(
        REGEXP_EXTRACT(JSON_VALUE(p.logMetadata.name), r'/engines/([^/]+)'),
        REGEXP_EXTRACT(JSON_VALUE(p.request.userEvent.engine), r'/engines/([^/]+)'),
        REGEXP_EXTRACT(JSON_VALUE(p.request.parent), r'/engines/([^/]+)'),
        REGEXP_EXTRACT(JSON_VALUE(p.request.name), r'/engines/([^/]+)')
      ) AS engine_id,
      COALESCE(
        REGEXP_EXTRACT(JSON_VALUE(p.response.answer.name), r'/sessions/([^/]+)'),
        REGEXP_EXTRACT(JSON_VALUE(p.request.name), r'/sessions/([^/]+)'),
        REGEXP_EXTRACT(
          JSON_VALUE(p.request.userEvent.feedback.conversationInfo.session), r'/sessions/([^/]+)'
        )
      ) AS session_id,
      COALESCE(
        JSON_VALUE(p.response.assistToken),
        JSON_VALUE(p.assistToken),
        JSON_VALUE(p.request.userEvent.feedback.conversationInfo.assistToken)
      ) AS assist_token,
      p.request.query IS NOT NULL AS has_query,
      JSON_VALUE(p.request.userInfo.userId) IS NOT NULL AS has_search_user,
      CASE
        WHEN JSON_VALUE(p.request.agentsSpec.agentSpecs[0].scheduleId) IS NOT NULL THEN 'Scheduled'
        WHEN JSON_VALUE(p.request.agentsSpec.agentSpecs[0].triggerId) IS NOT NULL THEN 'Triggered'
        WHEN p.request.agentsSpec IS NOT NULL OR p.request.query IS NOT NULL
          OR p.request.actionExecutionParams IS NOT NULL THEN 'Interactive'
      END AS invocation_mode,
      COALESCE(
        REGEXP_EXTRACT(JSON_VALUE(p.response.agentInfo.agent), r'([^/]+)$'),
        JSON_VALUE(p.request.agentsSpec.agentSpecs[0].agentId),
        JSON_VALUE(p.request.userEvent.agentspaceInfo.agentInfo.agentId),
        REGEXP_EXTRACT(JSON_VALUE(p.response.name), r'/agents/([^/]+)$'),
        REGEXP_EXTRACT(JSON_VALUE(p.request.agent.name), r'/agents/([^/]+)$'),
        REGEXP_EXTRACT(JSON_VALUE(p.logMetadata.name), r'/agents/([^/]+)$')
      ) AS agent_id,
      TRIM(COALESCE(
        JSON_VALUE(p.response.agentInfo.displayName),
        JSON_VALUE(p.request.userEvent.agentspaceInfo.agentInfo.name),
        JSON_VALUE(p.response.displayName),
        JSON_VALUE(p.request.agent.displayName)
      )) AS agent_display_name,
      JSON_VALUE(p.response.agentInfo.agentKind) AS agent_kind,
      LAX_BOOL(p.response.agentInfo.coreAssistant) AS is_core_assistant,
      JSON_VALUE(p.response.modelInfo.model) AS model,
      JSON_VALUE(p.response.modelInfo.modelSelectionMode) AS model_selection_mode,
      JSON_VALUE(p.response.modelInfo.requestedModel) AS requested_model,
      JSON_VALUE(p.response.dataSourceInfo.selectionMode) AS data_store_selection_mode,
      ARRAY(
        SELECT DISTINCT COALESCE(REGEXP_EXTRACT(data_store, r'/dataStores/([^/]+)$'), data_store)
        FROM UNNEST(JSON_VALUE_ARRAY(p.response.dataSourceInfo.dataStores)) AS data_store
        WHERE data_store IS NOT NULL
      ) AS data_store_ids,
      ARRAY(
        SELECT DISTINCT JSON_VALUE(reply.actionInvocation.actionName)
        FROM UNNEST(JSON_QUERY_ARRAY(p.response.answer.replies)) AS reply
        WHERE JSON_VALUE(reply.actionInvocation.actionName) IS NOT NULL
      ) AS proposed_actions,
      JSON_VALUE(p.request.actionExecutionParams.actionName) AS executed_action,
      (
        SELECT COUNT(*)
        FROM UNNEST(JSON_QUERY_ARRAY(p.response.answer.replies)) AS reply,
          UNNEST(JSON_QUERY_ARRAY(reply.groundedContent.textGroundingMetadata.references)) AS ref
      ) AS grounding_reference_count,
      ARRAY(
        SELECT DISTINCT JSON_VALUE(ref.documentMetadata.domain)
        FROM UNNEST(JSON_QUERY_ARRAY(p.response.answer.replies)) AS reply,
          UNNEST(JSON_QUERY_ARRAY(reply.groundedContent.textGroundingMetadata.references)) AS ref
        WHERE IFNULL(JSON_VALUE(ref.documentMetadata.domain), '') != ''
      ) AS grounding_domains,
      ARRAY(
        SELECT DISTINCT JSON_VALUE(part.mimeType)
        FROM UNNEST(JSON_QUERY_ARRAY(p.request.query.parts)) AS part
        WHERE JSON_VALUE(part.mimeType) IS NOT NULL
      ) AS attachment_mime_types,
      JSON_VALUE(p.response.answer.state) AS answer_state,
      ARRAY(
        SELECT DISTINCT reason
        FROM UNNEST(ARRAY_CONCAT(
          IFNULL(JSON_VALUE_ARRAY(p.response.answer.assistSkippedReasons), []),
          IFNULL(JSON_VALUE_ARRAY(p.response.answer.skippedReasons), [])
        )) AS reason
        WHERE reason IS NOT NULL
      ) AS skipped_reasons,
      LAX_INT64(p.status.code) AS status_code,
      -- The status message is only pattern matched into fixed labels, never copied.
      CASE
        WHEN IFNULL(LAX_INT64(p.status.code), 0) = 0 OR p.status.message IS NULL THEN NULL
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)billing overages')
          THEN 'Billing overages not enabled'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)free trial')
          THEN 'Model not available on free trial'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)no supported model is enabled')
          THEN 'No model enabled for the app'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)quota|rate limit|resource.exhausted')
          THEN 'Quota or rate limit'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)permission|forbidden')
          THEN 'Permission denied'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)deadline|timed out|timeout')
          THEN 'Timed out'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)internal error')
          THEN 'Internal error'
        ELSE 'Other'
      END AS failure_cause,
      CASE
        WHEN IFNULL(LAX_INT64(p.status.code), 0) = 0 OR p.status.message IS NULL THEN NULL
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)\bclaude\b') THEN 'Claude'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)gemini-4-argon') THEN 'Gemini 4 (Argon)'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)gemini-[0-9.]+-pro') THEN 'Gemini Pro'
        WHEN REGEXP_CONTAINS(JSON_VALUE(p.status.message), r'(?i)gemini-[0-9.]+-flash') THEN 'Gemini Flash'
      END AS failure_model,
      ARRAY_LENGTH(JSON_QUERY_ARRAY(p.response.results)) AS result_count,
      REGEXP_EXTRACT(JSON_VALUE(p.request.servingConfig), r'servingConfigs/([^/]+)$')
        AS serving_config,
      JSON_VALUE(p.request.userEvent.eventType) AS event_type,
      JSON_VALUE(p.request.userEvent.agentspaceInfo.agentspacePageType) AS page_type,
      JSON_VALUE(p.request.userEvent.feedback.feedbackType) AS feedback_type,
      ARRAY(
        SELECT reason
        FROM UNNEST(JSON_VALUE_ARRAY(p.request.userEvent.feedback.reasons)) AS reason
        WHERE reason IS NOT NULL
      ) AS feedback_reasons,
      JSON_VALUE(p.request.userEvent.userInfo.userAgent) AS user_agent,
      JSON_VALUE(p.request.userInfo.timeZone) AS time_zone,
      JSON_VALUE(p.response.mimeType) AS file_mime_type,
      LAX_INT64(p.response.byteCount) AS file_byte_count
    FROM raw
  ),

  classified AS (
    SELECT
      *,
      method IN ('StreamAssist', 'Assist')
        AND invocation_mode = 'Interactive'
        AND executed_action IS NULL
        AND has_query AS is_user_prompt,
      method = 'Search' AND has_search_user AS is_user_search,
      EXISTS (
        SELECT 1
        FROM UNNEST(skipped_reasons) AS reason
        WHERE reason IN (
          'CUSTOMER_POLICY_VIOLATION',
          'POTENTIAL_POLICY_VIOLATION',
          'ADVERSARIAL_QUERY_IGNORED',
          'JAIL_BREAKING_QUERY_IGNORED'
        )
      ) AS is_blocked,
      CASE
        WHEN user_agent IS NULL THEN NULL
        WHEN REGEXP_CONTAINS(user_agent, r'iPhone|iPad|Android') THEN 'Mobile'
        WHEN REGEXP_CONTAINS(user_agent, r'CrOS') THEN 'ChromeOS'
        WHEN REGEXP_CONTAINS(user_agent, r'Macintosh|Mac OS') THEN 'Mac'
        WHEN REGEXP_CONTAINS(user_agent, r'Windows') THEN 'Windows'
        WHEN REGEXP_CONTAINS(user_agent, r'Linux|X11') THEN 'Linux'
        ELSE 'Other'
      END AS device_class
    FROM fields
  )

  SELECT
    insert_id,
    event_ts,
    DATE(event_ts) AS event_date,
    project_id,
    location,
    classified.engine_id,
    COALESCE(app_names.app_name, classified.engine_id) AS app_name,
    user_email,
    method,
    CASE
      WHEN method IN ('CreateAgent', 'UpdateAgent', 'DeleteAgent', 'SetIamPolicy')
        THEN 'Agent builder'
      WHEN method IN ('UploadSessionFile', 'AddContextFile') THEN 'File upload'
      WHEN method = 'WriteUserEvent' AND feedback_type IS NOT NULL THEN 'Feedback'
      WHEN method = 'WriteUserEvent' AND page_type = 'notebook-lm' THEN 'NotebookLM'
      WHEN method = 'WriteUserEvent' AND page_type = 'agent_gallery' THEN 'Agent gallery'
      WHEN method = 'WriteUserEvent' THEN 'Navigation'
      WHEN method = 'Search' AND is_user_search THEN 'Search'
      WHEN method = 'Search' THEN 'Assistant grounding'
      WHEN method IN ('StreamAssist', 'Assist') THEN
        CASE
          WHEN invocation_mode IN ('Scheduled', 'Triggered') THEN 'Scheduled and triggered agents'
          WHEN agent_id = 'deep_research' THEN 'Deep Research'
          WHEN agent_id = 'idea_generation' THEN 'Idea Generation'
          WHEN agent_id = 'skill_generation_agent' THEN 'Skill authoring'
          WHEN STARTS_WITH(agent_id, 'app_catalyst') THEN 'Agent designer'
          WHEN agent_id = 'workflow_summary_agent' THEN 'Workflows'
          WHEN executed_action IS NOT NULL THEN 'Actions'
          WHEN LOWER(model) LIKE '%image%' THEN 'Image generation'
          WHEN agent_id IS NOT NULL AND NOT IFNULL(is_core_assistant, FALSE) THEN 'Custom agents'
          ELSE 'Assistant chat'
        END
      ELSE 'Other'
    END AS feature,
    trace_id,
    session_id,
    assist_token,
    is_user_prompt,
    is_user_search,
    invocation_mode,
    agent_id,
    agent_display_name,
    agent_kind,
    is_core_assistant,
    model,
    model_selection_mode,
    requested_model,
    data_store_selection_mode,
    data_store_ids,
    proposed_actions,
    executed_action,
    grounding_reference_count,
    grounding_domains,
    attachment_mime_types,
    answer_state,
    skipped_reasons,
    is_blocked,
    status_code,
    failure_cause,
    failure_model,
    IF(method = 'Search', IFNULL(result_count, 0), NULL) AS search_result_count,
    serving_config,
    event_type,
    page_type,
    feedback_type,
    feedback_reasons,
    device_class,
    time_zone,
    file_mime_type,
    file_byte_count,
    CURRENT_TIMESTAMP() AS ingested_at
  FROM classified
  LEFT JOIN app_names USING (engine_id)
) AS source
ON target.insert_id = source.insert_id
  AND target.event_date >= DATE_SUB(DATE(@window_start), INTERVAL 1 DAY)
WHEN NOT MATCHED THEN
  INSERT (
    insert_id, event_ts, event_date, project_id, location, engine_id, app_name, user_email,
    method, feature, trace_id, session_id, assist_token, is_user_prompt, is_user_search,
    invocation_mode, agent_id, agent_display_name, agent_kind, is_core_assistant, model,
    model_selection_mode, requested_model, data_store_selection_mode, data_store_ids,
    proposed_actions, executed_action, grounding_reference_count, grounding_domains,
    attachment_mime_types, answer_state, skipped_reasons, is_blocked, status_code,
    failure_cause, failure_model,
    search_result_count, serving_config, event_type, page_type, feedback_type, feedback_reasons,
    device_class, time_zone, file_mime_type, file_byte_count, ingested_at
  )
  VALUES (
    insert_id, event_ts, event_date, project_id, location, engine_id, app_name, user_email,
    method, feature, trace_id, session_id, assist_token, is_user_prompt, is_user_search,
    invocation_mode, agent_id, agent_display_name, agent_kind, is_core_assistant, model,
    model_selection_mode, requested_model, data_store_selection_mode, data_store_ids,
    proposed_actions, executed_action, grounding_reference_count, grounding_domains,
    attachment_mime_types, answer_state, skipped_reasons, is_blocked, status_code,
    failure_cause, failure_model,
    search_result_count, serving_config, event_type, page_type, feedback_type, feedback_reasons,
    device_class, time_zone, file_mime_type, file_byte_count, ingested_at
  )
