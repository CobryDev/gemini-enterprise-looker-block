view: value {
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        MAX(IF(metric_type = 'SUCCESSFUL_SEARCHES', metric_value, NULL)) AS successful_searches,
        MAX(IF(metric_type = 'SUCCESSFUL_ANSWERS', metric_value, NULL)) AS successful_answers,
        MAX(IF(metric_type = 'EMPLOYEE_HOURS_SAVED', metric_value, NULL)) AS employee_hours_saved,
        MAX(IF(metric_type = 'VALUE_SAVED', metric_value, NULL)) AS value_saved,
        MAX(IF(metric_type = 'PROJECTED_ANNUAL_HOURS_SAVED', metric_value, NULL)) AS projected_annual_hours_saved,
        MAX(IF(metric_type = 'PROJECTED_ANNUAL_VALUE_SAVED', metric_value, NULL)) AS projected_annual_value_saved
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

  measure: successful_searches {
    type: sum
    sql: ${TABLE}.successful_searches ;;
  }

  measure: successful_answers {
    type: sum
    sql: ${TABLE}.successful_answers ;;
  }

  measure: employee_hours_saved {
    type: sum
    sql: ${TABLE}.employee_hours_saved ;;
    value_format_name: decimal_1
  }

  measure: value_saved {
    type: sum
    sql: ${TABLE}.value_saved ;;
    value_format_name: gbp
  }

  measure: projected_annual_hours_saved {
    type: max
    sql: ${TABLE}.projected_annual_hours_saved ;;
    value_format_name: decimal_1
  }

  measure: projected_annual_value_saved {
    type: max
    sql: ${TABLE}.projected_annual_value_saved ;;
    value_format_name: gbp
  }
}
