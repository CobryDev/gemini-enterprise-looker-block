view: agents {
  label: "Agents"
  # Per-agent usage. The export only emits these rows once agents are created and
  # used, so this view is empty until there is agent activity on the engine.
  derived_table: {
    sql:
      SELECT
        engine_id,
        app_name,
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
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date, '|', ${TABLE}.agent_name) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the agent belongs to."
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension: app_name {
    label: "App"
    description: "Friendly name of the Gemini Enterprise app, mapped from engine_id."
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension_group: metric {
    label: "Metric"
    description: "Date (UTC) the agent usage was recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: agent_name {
    description: "Resource name of the agent."
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: agent_type {
    description: "Category of the agent as classified by Gemini Enterprise."
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
    description: "Number of distinct agents with activity in the selected period."
    type: count_distinct
    sql: ${agent_name} ;;
  }

  measure: agent_sessions {
    description: "Total agent sessions (conversations) started across the selected agents and period."
    type: sum
    sql: ${TABLE}.agent_session_count ;;
    value_format_name: decimal_0
  }

  measure: agent_active_users {
    description: "Total daily active users of agents, summed across the selected period. Best read for a single day to avoid double-counting across days."
    type: sum
    sql: ${TABLE}.agent_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: monthly_agent_active_users {
    description: "Distinct users of agents in the trailing 28/30-day window. A snapshot, so this takes the max over the selected period rather than summing."
    type: max
    sql: ${TABLE}.monthly_agent_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: new_agents {
    label: "New Agents Created"
    description: "Number of agents newly created in the month."
    type: sum
    sql: ${TABLE}.monthly_new_agent_count ;;
    value_format_name: decimal_0
  }
}
