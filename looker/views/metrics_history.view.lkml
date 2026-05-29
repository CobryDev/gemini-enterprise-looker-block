view: metrics_history {
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.metrics_history` ;;

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

  dimension: metric_type {
    type: string
    sql: ${TABLE}.metric_type ;;
  }

  dimension: metric_value {
    type: number
    sql: ${TABLE}.metric_value ;;
  }

  dimension_group: ingested {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.ingested_at ;;
  }

  measure: total_metric_value {
    type: sum
    sql: ${metric_value} ;;
  }

  measure: average_metric_value {
    type: average
    sql: ${metric_value} ;;
  }

  measure: metric_rows {
    type: count
  }
}
