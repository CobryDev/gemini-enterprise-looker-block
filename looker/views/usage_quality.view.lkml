view: usage_quality {
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        MAX(IF(metric_type = 'SEARCH_COUNT', metric_value, NULL)) AS search_count,
        MAX(IF(metric_type = 'ANSWER_COUNT', metric_value, NULL)) AS answer_count,
        MAX(IF(metric_type = 'ACTION_COUNT', metric_value, NULL)) AS action_count,
        MAX(IF(metric_type = 'CLICK_THROUGH_RATE', metric_value, NULL)) AS click_through_rate,
        MAX(IF(metric_type = 'LIKE_COUNT', metric_value, NULL)) AS like_count,
        MAX(IF(metric_type = 'DISLIKE_COUNT', metric_value, NULL)) AS dislike_count,
        MAX(IF(metric_type = 'SUCCESSFUL_SEARCH_RATE', metric_value, NULL)) AS successful_search_rate,
        MAX(IF(metric_type = 'SUCCESSFUL_ANSWER_RATE', metric_value, NULL)) AS successful_answer_rate
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

  measure: searches {
    type: sum
    sql: ${TABLE}.search_count ;;
  }

  measure: answers {
    type: sum
    sql: ${TABLE}.answer_count ;;
  }

  measure: actions {
    type: sum
    sql: ${TABLE}.action_count ;;
  }

  measure: click_through_rate {
    type: average
    sql: ${TABLE}.click_through_rate ;;
    value_format_name: percent_1
  }

  measure: likes {
    type: sum
    sql: ${TABLE}.like_count ;;
  }

  measure: dislikes {
    type: sum
    sql: ${TABLE}.dislike_count ;;
  }

  measure: successful_search_rate {
    type: average
    sql: ${TABLE}.successful_search_rate ;;
    value_format_name: percent_1
  }

  measure: successful_answer_rate {
    type: average
    sql: ${TABLE}.successful_answer_rate ;;
    value_format_name: percent_1
  }
}
