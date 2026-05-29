view: agents {
  label: "Agents"
  # Per-agent usage. The export only emits these rows once agents are created and
  # used, so this view is empty until there is agent activity on the engine.
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        agent_name,
        agent_type,
        agent_ownership,
        agent_session_count,
        agent_active_user_count,
        monthly_agent_active_user_count,
        monthly_new_agent_count
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE agent_name IS NOT NULL ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.metric_date, '|', ${TABLE}.agent_name) ;;
  }

  dimension: engine_id {
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension_group: metric {
    label: "Metric"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: agent_name {
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: agent_type {
    type: string
    sql: ${TABLE}.agent_type ;;
  }

  dimension: agent_ownership {
    description: "Whether the agent is owned by the customer or provided by Google."
    type: string
    sql: ${TABLE}.agent_ownership ;;
  }

  measure: agent_count {
    label: "Distinct Agents Used"
    type: count_distinct
    sql: ${agent_name} ;;
  }

  measure: agent_sessions {
    type: sum
    sql: ${TABLE}.agent_session_count ;;
    value_format_name: decimal_0
  }

  measure: agent_active_users {
    type: sum
    sql: ${TABLE}.agent_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: monthly_agent_active_users {
    type: max
    sql: ${TABLE}.monthly_agent_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: new_agents {
    label: "New Agents Created"
    type: sum
    sql: ${TABLE}.monthly_new_agent_count ;;
    value_format_name: decimal_0
  }
}
