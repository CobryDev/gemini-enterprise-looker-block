view: agents {
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        MAX(IF(metric_type = 'MONTHLY_ACTIVE_AGENT_USERS', metric_value, NULL)) AS monthly_active_agent_users,
        MAX(IF(metric_type = 'MONTHLY_CHAT_SESSIONS', metric_value, NULL)) AS monthly_chat_sessions,
        MAX(IF(metric_type = 'MONTHLY_AGENTS_USED', metric_value, NULL)) AS monthly_agents_used,
        MAX(IF(metric_type = 'MONTHLY_AGENTS_CREATED', metric_value, NULL)) AS monthly_agents_created,
        MAX(IF(metric_type = 'NOTEBOOKS_CREATED', metric_value, NULL)) AS notebooks_created,
        MAX(IF(metric_type = 'NOTEBOOKS_SHARED', metric_value, NULL)) AS notebooks_shared,
        MAX(IF(metric_type = 'AUDIO_OVERVIEWS_CREATED', metric_value, NULL)) AS audio_overviews_created,
        MAX(IF(metric_type = 'NOTEBOOKLM_ACTIVE_USERS', metric_value, NULL)) AS notebooklm_active_users
      FROM `@{gemini_project}.@{gemini_dataset}.metrics_history`
      GROUP BY engine_id, metric_date ;;
  }

  dimension: engine_id {
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension_group: metric {
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  measure: monthly_active_agent_users {
    type: max
    sql: ${TABLE}.monthly_active_agent_users ;;
  }

  measure: monthly_chat_sessions {
    type: max
    sql: ${TABLE}.monthly_chat_sessions ;;
  }

  measure: monthly_agents_used {
    type: max
    sql: ${TABLE}.monthly_agents_used ;;
  }

  measure: monthly_agents_created {
    type: max
    sql: ${TABLE}.monthly_agents_created ;;
  }

  measure: notebooks_created {
    type: sum
    sql: ${TABLE}.notebooks_created ;;
  }

  measure: notebooks_shared {
    type: sum
    sql: ${TABLE}.notebooks_shared ;;
  }

  measure: audio_overviews_created {
    type: sum
    sql: ${TABLE}.audio_overviews_created ;;
  }

  measure: notebooklm_active_users {
    type: max
    sql: ${TABLE}.notebooklm_active_users ;;
  }
}
