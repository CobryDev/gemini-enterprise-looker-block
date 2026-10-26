view: ge_model_calls {
  label: "Model Calls"
  # One row per model inference from the gen_ai inference log: token counts
  # and tool-call counts, attributed to a user through the trace.
  # user_email is the person's current address; see person_identity.
  derived_table: {
    sql:
      SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email)
      FROM `@{gemini_project}.@{gemini_dataset}.ge_model_calls` AS source
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = LOWER(source.user_email)
        AND source.event_ts >= person_identity.valid_from
        AND source.event_ts < person_identity.valid_to ;;
  }

  dimension: insert_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.insert_id ;;
  }

  dimension_group: event {
    label: "Event"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: trace_id {
    hidden: yes
    type: string
    sql: ${TABLE}.trace_id ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: agent_name {
    label: "Agent"
    description: "Agent in the assistant's agent tree that made the model call."
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: agent_label {
    label: "Agent (Readable)"
    description: "Agent name in plain words. root_agent shows as Main assistant."
    type: string
    sql: IF(${TABLE}.agent_name = 'root_agent', 'Main assistant',
      INITCAP(REPLACE(REGEXP_REPLACE(${TABLE}.agent_name, r'^llm_agent_|_agent$', ''), '_', ' '))) ;;
  }

  dimension: agent_id {
    label: "Agent ID"
    type: string
    sql: ${TABLE}.agent_id ;;
  }

  dimension: conversation_id {
    hidden: yes
    type: string
    sql: ${TABLE}.conversation_id ;;
  }

  measure: model_calls {
    type: count
  }

  measure: conversations {
    type: count_distinct
    sql: ${conversation_id} ;;
  }

  measure: input_tokens {
    type: sum
    sql: ${TABLE}.input_tokens ;;
    value_format_name: decimal_0
  }

  measure: output_tokens {
    type: sum
    sql: ${TABLE}.output_tokens ;;
    value_format_name: decimal_0
  }

  measure: cached_input_tokens {
    type: sum
    sql: ${TABLE}.cached_input_tokens ;;
    value_format_name: decimal_0
  }

  measure: reasoning_tokens {
    type: sum
    sql: ${TABLE}.reasoning_tokens ;;
    value_format_name: decimal_0
  }

  measure: total_tokens {
    description: "Input plus output tokens."
    type: number
    sql: IFNULL(${input_tokens}, 0) + IFNULL(${output_tokens}, 0) ;;
    value_format_name: decimal_0
  }

  measure: cache_hit_rate {
    description: "Share of input tokens served from the context cache."
    type: number
    sql: SAFE_DIVIDE(${cached_input_tokens}, NULLIF(${input_tokens}, 0)) ;;
    value_format_name: percent_1
  }

  measure: tokens_per_user {
    type: number
    sql: SAFE_DIVIDE(${total_tokens}, NULLIF(COUNT(DISTINCT ${user_email}), 0)) ;;
    value_format_name: decimal_0
  }

  measure: tool_calls {
    type: sum
    sql: ${TABLE}.tool_call_count ;;
  }
}
