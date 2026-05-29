view: workspace_gemini_activity {
  derived_table: {
    sql:
      SELECT
        DATE(TIMESTAMP_MICROS(time_usec)) AS event_date,
        email,
        gemini_for_workspace.app_name AS app_name,
        gemini_for_workspace.feature_source AS feature_source,
        COUNT(*) AS event_count
      FROM `@{gemini_project}.@{workspace_dataset}.activity`
      WHERE gemini_for_workspace.app_name IS NOT NULL
      GROUP BY event_date, email, app_name, feature_source ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: feature_source {
    type: string
    sql: ${TABLE}.feature_source ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  measure: events {
    type: sum
    sql: ${TABLE}.event_count ;;
  }

  measure: active_users {
    type: count_distinct
    sql: ${email} ;;
  }
}
