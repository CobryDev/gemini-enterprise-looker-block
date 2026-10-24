view: ge_user_daily {
  label: "User Daily"
  # One row per user per app per day, rolled up from ge_user_activity. Trend
  # tiles (daily/weekly/monthly active users, prompts per user) read this
  # instead of the event table.
  derived_table: {
    datagroup_trigger: gemini_change_management_datagroup
    partition_keys: ["event_date"]
    cluster_keys: ["user_email"]
    sql:
      SELECT
        CONCAT(user_email, '|', IFNULL(engine_id, ''), '|', CAST(event_date AS STRING)) AS pk,
        event_date,
        user_email,
        engine_id,
        ANY_VALUE(app_name) AS app_name,
        COUNTIF(is_user_prompt) AS prompts,
        COUNTIF(is_user_search) AS searches,
        COUNTIF(feature NOT IN ('Assistant grounding', 'Navigation', 'Other')) AS feature_uses,
        COUNT(DISTINCT IF(feature NOT IN ('Assistant grounding', 'Navigation', 'Other'), feature, NULL)) AS features_used,
        COUNT(DISTINCT IF(agent_id IS NOT NULL AND NOT IFNULL(is_core_assistant, FALSE), agent_id, NULL)) AS agents_used,
        COUNT(DISTINCT session_id) AS sessions,
        COUNTIF(is_blocked) AS blocked_prompts,
        LOGICAL_OR(is_user_prompt OR is_user_search) AS is_engaged
      FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
      WHERE user_email IS NOT NULL
      GROUP BY event_date, user_email, engine_id ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension_group: event {
    label: "Activity"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    sql: ${TABLE}.user_email ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: is_engaged {
    label: "Is Engaged Day"
    description: "The user prompted or searched that day (not just browsed)."
    type: yesno
    sql: ${TABLE}.is_engaged ;;
  }

  measure: active_users {
    description: "Distinct users active in the period. At day grain this is DAU, at week grain WAU, at month grain MAU."
    type: count_distinct
    sql: ${user_email} ;;
    drill_fields: [user_email, total_prompts, total_searches, active_days]
  }

  measure: engaged_users {
    description: "Distinct users who prompted or searched in the period."
    type: count_distinct
    sql: CASE WHEN ${is_engaged} THEN ${user_email} END ;;
  }

  measure: active_days {
    description: "User-days with any activity."
    type: count
  }

  measure: average_daily_active_users {
    label: "Avg Daily Active Users"
    description: "Active user-days divided by the number of distinct days in the period."
    type: number
    sql: SAFE_DIVIDE(COUNT(DISTINCT CONCAT(${user_email}, CAST(${TABLE}.event_date AS STRING))), NULLIF(COUNT(DISTINCT ${TABLE}.event_date), 0)) ;;
    value_format_name: decimal_1
  }

  measure: stickiness {
    label: "Stickiness (DAU/MAU)"
    description: "Average daily active users divided by distinct active users in the period. Use over a month-long window: 20% means the typical user is active about one working day in five."
    type: number
    sql: SAFE_DIVIDE(${average_daily_active_users}, NULLIF(${active_users}, 0)) ;;
    value_format_name: percent_1
  }

  measure: total_prompts {
    label: "Prompts"
    type: sum
    sql: ${TABLE}.prompts ;;
  }

  measure: total_searches {
    label: "Searches"
    type: sum
    sql: ${TABLE}.searches ;;
  }

  measure: total_feature_uses {
    label: "Feature Uses"
    type: sum
    sql: ${TABLE}.feature_uses ;;
  }

  measure: prompts_per_active_user {
    type: number
    sql: SAFE_DIVIDE(${total_prompts}, NULLIF(${active_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: active_days_per_user {
    type: number
    sql: SAFE_DIVIDE(${active_days}, NULLIF(${active_users}, 0)) ;;
    value_format_name: decimal_1
  }
}
