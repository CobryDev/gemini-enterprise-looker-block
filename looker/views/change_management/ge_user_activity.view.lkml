view: ge_user_activity {
  label: "Gemini Enterprise Activity"
  # One row per Gemini Enterprise interaction from the user-activity log,
  # redacted to metadata by the exporter's hourly transform. No prompt,
  # response, grounding or file content is stored.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.ge_user_activity` ;;

  dimension: insert_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.insert_id ;;
  }

  dimension_group: event {
    label: "Event"
    description: "Date (UTC) of the interaction. Filter on this to limit the partitions scanned."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension_group: event_time {
    label: "Event Time"
    description: "Timestamp of the interaction, for hour-of-day and day-of-week patterns."
    type: time
    timeframes: [raw, time, hour_of_day, day_of_week, day_of_week_index]
    sql: ${TABLE}.event_ts ;;
  }

  dimension_group: event_local {
    label: "Local Time"
    description: "Interaction time in the user's browser time zone when the log carries it, otherwise the reporting_time_zone constant."
    type: time
    timeframes: [time, hour_of_day, day_of_week, day_of_week_index]
    convert_tz: no
    datatype: datetime
    sql: COALESCE(SAFE.DATETIME(${TABLE}.event_ts, ${TABLE}.time_zone), DATETIME(${TABLE}.event_ts, '@{reporting_time_zone}')) ;;
  }

  dimension: app_name {
    label: "App"
    description: "Gemini Enterprise app (engine) the interaction happened in."
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: engine_id {
    hidden: yes
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension: user_email {
    label: "User"
    description: "Email of the signed-in user."
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: user_domain {
    label: "User Domain"
    description: "Email domain of the user. A quick business-unit split when Workspace org units aren't available."
    type: string
    sql: REGEXP_EXTRACT(${TABLE}.user_email, r'@(.+)$') ;;
  }

  dimension: feature {
    description: "Gemini Enterprise feature: Assistant chat, Search, Deep Research, Idea Generation, Custom agents, Agent designer, Workflows, Skill authoring, Scheduled and triggered agents, Actions, Image generation, File upload, NotebookLM, Agent gallery, Agent builder, Feedback, Navigation, or Assistant grounding (the assistant's own lookups)."
    type: string
    sql: ${TABLE}.feature ;;
  }

  dimension: is_user_facing_feature {
    label: "Is User-Facing Feature"
    description: "Excludes the assistant's own grounding lookups and page navigation, which aren't a feature choice by the user."
    type: yesno
    sql: ${TABLE}.feature NOT IN ('Assistant grounding', 'Navigation', 'Other') ;;
  }

  dimension: method {
    hidden: yes
    label: "API Method"
    type: string
    sql: ${TABLE}.method ;;
  }

  dimension: invocation_mode {
    description: "Interactive, Scheduled or Triggered."
    type: string
    sql: ${TABLE}.invocation_mode ;;
  }

  dimension: is_user_prompt {
    label: "Is User Prompt"
    description: "A prompt the user sent interactively (not a scheduled or triggered run, and not an action confirmation)."
    type: yesno
    sql: ${TABLE}.is_user_prompt ;;
  }

  dimension: is_user_search {
    label: "Is User Search"
    description: "A search the user ran from the search bar, as opposed to the assistant's grounding lookups."
    type: yesno
    sql: ${TABLE}.is_user_search ;;
  }

  dimension: agent_id {
    hidden: yes
    label: "Agent ID"
    type: string
    sql: ${TABLE}.agent_id ;;
  }

  dimension: agent_name {
    label: "Agent"
    description: "Agent display name, or its ID when the log doesn't carry a name."
    type: string
    sql: COALESCE(${TABLE}.agent_display_name, ${TABLE}.agent_id) ;;
  }

  dimension: agent_kind {
    type: string
    sql: ${TABLE}.agent_kind ;;
  }

  dimension: is_core_assistant {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_core_assistant ;;
  }

  dimension: model {
    description: "Model that produced the answer."
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: model_family {
    description: "Model grouped by family (Pro, Flash, Flash-Lite, Thinking, Image and video, Other), matched on the model name so new versions group automatically."
    type: string
    sql: CASE
      WHEN ${TABLE}.model IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'image|imagen|veo') THEN 'Image and video'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'thinking') THEN 'Thinking'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'ultra') THEN 'Ultra'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'pro') THEN 'Pro'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'lite') THEN 'Flash-Lite'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'flash') THEN 'Flash'
      ELSE 'Other'
    END ;;
  }

  dimension: is_advanced_model {
    description: "Pro, Ultra or Thinking model: what Auto mode picks for harder requests."
    type: yesno
    sql: REGEXP_CONTAINS(LOWER(${TABLE}.model), r'pro|ultra|thinking')
      AND NOT REGEXP_CONTAINS(LOWER(${TABLE}.model), r'image|imagen|veo') ;;
  }

  dimension: model_selection_mode {
    hidden: yes
    description: "Whether the user picked the model or Gemini Enterprise chose it automatically."
    type: string
    sql: ${TABLE}.model_selection_mode ;;
  }

  dimension: model_choice {
    description: "Auto or User selected, from the model selection mode."
    type: string
    sql: CASE
      WHEN ${TABLE}.model_selection_mode IS NULL THEN NULL
      WHEN ${is_auto_selected} THEN 'Auto'
      ELSE 'User selected'
    END ;;
  }

  dimension: is_auto_selected {
    label: "Is Auto Model"
    description: "Gemini Enterprise chose the model (Auto mode)."
    type: yesno
    sql: REGEXP_CONTAINS(UPPER(IFNULL(${TABLE}.model_selection_mode, '')), r'AUTO') ;;
  }

  dimension: requested_model {
    hidden: yes
    type: string
    sql: ${TABLE}.requested_model ;;
  }

  dimension: data_store_selection_mode {
    hidden: yes
    label: "Data Source Selection Mode"
    type: string
    sql: ${TABLE}.data_store_selection_mode ;;
  }

  dimension: data_store_ids {
    hidden: yes
    sql: ${TABLE}.data_store_ids ;;
  }

  dimension: proposed_actions {
    hidden: yes
    sql: ${TABLE}.proposed_actions ;;
  }

  dimension: grounding_domains {
    hidden: yes
    sql: ${TABLE}.grounding_domains ;;
  }

  dimension: attachment_mime_types {
    hidden: yes
    sql: ${TABLE}.attachment_mime_types ;;
  }

  dimension: has_proposed_action {
    description: "The assistant proposed an action (send email, create event and so on)."
    type: yesno
    sql: ARRAY_LENGTH(${TABLE}.proposed_actions) > 0 ;;
  }

  dimension: executed_action {
    description: "Action the user confirmed and ran."
    type: string
    sql: ${TABLE}.executed_action ;;
  }

  dimension: has_attachment {
    description: "The prompt included an uploaded file or image."
    type: yesno
    sql: ARRAY_LENGTH(${TABLE}.attachment_mime_types) > 0 ;;
  }

  dimension: grounding_reference_count {
    hidden: yes
    type: number
    sql: ${TABLE}.grounding_reference_count ;;
  }

  dimension: is_grounded {
    description: "The answer cited at least one source."
    type: yesno
    sql: ${TABLE}.grounding_reference_count > 0 ;;
  }

  dimension: answer_state {
    hidden: yes
    type: string
    sql: ${TABLE}.answer_state ;;
  }

  dimension: is_blocked {
    description: "The answer was skipped for a policy or safety reason."
    type: yesno
    sql: ${TABLE}.is_blocked ;;
  }

  dimension: status_code {
    hidden: yes
    type: number
    sql: ${TABLE}.status_code ;;
  }

  dimension: is_error {
    description: "The request returned a non-OK status."
    type: yesno
    sql: IFNULL(${TABLE}.status_code, 0) != 0 ;;
  }

  dimension: search_result_count {
    hidden: yes
    type: number
    sql: ${TABLE}.search_result_count ;;
  }

  dimension: is_zero_result_search {
    type: yesno
    sql: ${TABLE}.is_user_search AND ${TABLE}.search_result_count = 0 ;;
  }

  dimension: page_type {
    hidden: yes
    type: string
    sql: ${TABLE}.page_type ;;
  }

  dimension: event_type {
    hidden: yes
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: feedback_type {
    description: "POSITIVE or NEGATIVE thumbs feedback on an answer."
    type: string
    sql: ${TABLE}.feedback_type ;;
  }

  dimension: device_class {
    label: "Device"
    description: "Mac, Windows, ChromeOS, Linux, Mobile or Other, from the browser user agent (web events only)."
    type: string
    sql: ${TABLE}.device_class ;;
  }

  dimension: time_zone {
    hidden: yes
    type: string
    sql: ${TABLE}.time_zone ;;
  }

  dimension: file_mime_type {
    hidden: yes
    label: "Uploaded File Type"
    type: string
    sql: ${TABLE}.file_mime_type ;;
  }

  dimension: session_id {
    hidden: yes
    type: string
    sql: ${TABLE}.session_id ;;
  }

  measure: interactions {
    description: "Logged interactions of any kind, including the assistant's own grounding lookups."
    type: count
    drill_fields: [detail*]
  }

  measure: active_users {
    description: "Distinct users with any interaction."
    type: count_distinct
    sql: ${user_email} ;;
    drill_fields: [user_email, prompts, searches]
  }

  measure: prompts {
    description: "Prompts users sent interactively."
    type: count
    filters: [is_user_prompt: "yes"]
    drill_fields: [detail*]
  }

  measure: prompting_users {
    description: "Distinct users who sent at least one prompt."
    type: count_distinct
    sql: CASE WHEN ${is_user_prompt} THEN ${user_email} END ;;
    drill_fields: [user_email, prompts]
  }

  measure: searches {
    description: "Searches users ran from the search bar."
    type: count
    filters: [is_user_search: "yes"]
  }

  measure: searching_users {
    type: count_distinct
    sql: CASE WHEN ${is_user_search} THEN ${user_email} END ;;
  }

  measure: feature_users {
    label: "Feature Users"
    description: "Distinct users of user-facing features (excludes grounding lookups and navigation)."
    type: count_distinct
    sql: CASE WHEN ${is_user_facing_feature} THEN ${user_email} END ;;
    drill_fields: [user_email, feature, feature_uses]
  }

  measure: feature_uses {
    description: "Interactions with user-facing features."
    type: count
    filters: [is_user_facing_feature: "yes"]
  }

  measure: sessions {
    description: "Distinct conversations."
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: auto_prompts {
    description: "Prompts where Gemini Enterprise chose the model."
    type: count
    filters: [is_user_prompt: "yes", is_auto_selected: "yes"]
  }

  measure: auto_advanced_prompts {
    label: "Auto Prompts Routed to Advanced Model"
    type: count
    filters: [is_user_prompt: "yes", is_auto_selected: "yes", is_advanced_model: "yes"]
  }

  measure: complex_query_rate {
    description: "Share of Auto-mode prompts routed to an advanced (Pro, Ultra or Thinking) model. A high rate means the user asks harder questions."
    type: number
    sql: SAFE_DIVIDE(${auto_advanced_prompts}, NULLIF(${auto_prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: models_used {
    description: "Distinct models behind the user's prompts."
    type: count_distinct
    sql: CASE WHEN ${is_user_prompt} THEN ${TABLE}.model END ;;
  }

  measure: prompts_per_user {
    type: number
    sql: SAFE_DIVIDE(${prompts}, NULLIF(${prompting_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: blocked_prompts {
    description: "Answers Gemini Enterprise skipped for a policy or safety reason."
    type: count
    filters: [is_blocked: "yes"]
    drill_fields: [event_date, user_email, app_name, agent_name]
  }

  measure: users_blocked {
    type: count_distinct
    sql: CASE WHEN ${is_blocked} THEN ${user_email} END ;;
  }

  measure: positive_feedback {
    type: count
    filters: [feedback_type: "POSITIVE"]
  }

  measure: negative_feedback {
    type: count
    filters: [feedback_type: "NEGATIVE"]
  }

  measure: satisfaction_rate {
    description: "Positive feedback divided by all thumbs feedback."
    type: number
    sql: SAFE_DIVIDE(${positive_feedback}, NULLIF(${positive_feedback} + ${negative_feedback}, 0)) ;;
    value_format_name: percent_1
  }

  measure: actions_proposed {
    description: "Answers that proposed an action."
    type: count
    filters: [has_proposed_action: "yes"]
  }

  measure: actions_executed {
    description: "Actions users confirmed and ran."
    type: count
    filters: [executed_action: "-NULL"]
  }

  measure: grounded_answer_rate {
    description: "Share of prompts whose answer cited at least one source."
    type: number
    sql: SAFE_DIVIDE(COUNT(CASE WHEN ${is_user_prompt} AND ${is_grounded} THEN 1 END), NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: zero_result_searches {
    type: count
    filters: [is_zero_result_search: "yes"]
  }

  measure: file_uploads {
    type: count
    filters: [feature: "File upload"]
  }

  measure: agents_used {
    description: "Distinct agents invoked (excludes the core assistant)."
    type: count_distinct
    sql: CASE WHEN NOT IFNULL(${TABLE}.is_core_assistant, FALSE) THEN ${agent_id} END ;;
  }

  measure: agent_users {
    description: "Distinct users who invoked an agent other than the core assistant."
    type: count_distinct
    sql: CASE WHEN ${agent_id} IS NOT NULL AND NOT IFNULL(${TABLE}.is_core_assistant, FALSE) THEN ${user_email} END ;;
  }

  measure: agent_runs {
    description: "Assistant calls handled by an agent other than the core assistant."
    type: count
    filters: [agent_id: "-NULL", is_core_assistant: "no", method: "StreamAssist,Assist"]
  }

  measure: agents_created {
    type: count
    filters: [method: "CreateAgent"]
  }

  measure: agent_builders {
    description: "Distinct users who created, edited, shared or deleted an agent."
    type: count_distinct
    sql: CASE WHEN ${feature} = 'Agent builder' THEN ${user_email} END ;;
  }

  measure: error_rate {
    type: number
    sql: SAFE_DIVIDE(COUNT(CASE WHEN ${is_error} THEN 1 END), NULLIF(${interactions}, 0)) ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [event_date, user_email, app_name, feature, agent_name, model, answer_state]
  }
}

# Array columns, exposed through UNNEST joins in the explore.
view: ge_user_activity__proposed_actions {
  label: "Gemini Enterprise Activity"
  dimension: proposed_action {
    description: "Action the assistant proposed (for example send_email, create_event)."
    type: string
    sql: ${TABLE} ;;
  }
}

view: ge_user_activity__grounding_domains {
  label: "Gemini Enterprise Activity"
  dimension: grounding_domain {
    description: "Domain of a source the answer cited. No URIs or titles are stored."
    type: string
    sql: ${TABLE} ;;
  }
}

view: ge_user_activity__data_store_ids {
  label: "Gemini Enterprise Activity"
  dimension: data_store_id {
    hidden: yes
    label: "Data Store"
    description: "Data store (connector) the answer could draw on."
    type: string
    sql: ${TABLE} ;;
  }
}
