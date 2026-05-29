view: adoption {
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        MAX(IF(metric_type = 'TOTAL_USERS', metric_value, NULL)) AS total_users,
        MAX(IF(metric_type = 'DAU', metric_value, NULL)) AS dau,
        MAX(IF(metric_type = 'WAU', metric_value, NULL)) AS wau,
        MAX(IF(metric_type = 'MAU', metric_value, NULL)) AS mau,
        MAX(IF(metric_type = 'RETENTION_7_DAY', metric_value, NULL)) AS retention_7_day,
        MAX(IF(metric_type = 'RETENTION_28_DAY', metric_value, NULL)) AS retention_28_day,
        MAX(IF(metric_type = 'GROWTH_RATE', metric_value, NULL)) AS growth_rate,
        MAX(IF(metric_type = 'CHURN_RATE', metric_value, NULL)) AS churn_rate,
        MAX(IF(metric_type = 'SEATS_PURCHASED', metric_value, NULL)) AS seats_purchased,
        MAX(IF(metric_type = 'SEATS_CLAIMED', metric_value, NULL)) AS seats_claimed
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

  measure: total_users {
    type: max
    sql: ${TABLE}.total_users ;;
  }

  measure: dau {
    type: max
    sql: ${TABLE}.dau ;;
    description: "Daily active users"
  }

  measure: wau {
    type: max
    sql: ${TABLE}.wau ;;
    description: "Weekly active users"
  }

  measure: mau {
    type: max
    sql: ${TABLE}.mau ;;
    description: "Monthly active users"
  }

  measure: retention_7_day {
    type: max
    sql: ${TABLE}.retention_7_day ;;
    value_format_name: percent_1
  }

  measure: retention_28_day {
    type: max
    sql: ${TABLE}.retention_28_day ;;
    value_format_name: percent_1
  }

  measure: growth_rate {
    type: max
    sql: ${TABLE}.growth_rate ;;
    value_format_name: percent_1
  }

  measure: churn_rate {
    type: max
    sql: ${TABLE}.churn_rate ;;
    value_format_name: percent_1
  }

  measure: seats_purchased {
    type: max
    sql: ${TABLE}.seats_purchased ;;
  }

  measure: seats_claimed {
    type: max
    sql: ${TABLE}.seats_claimed ;;
  }

  measure: seat_utilisation {
    type: number
    sql: SAFE_DIVIDE(${seats_claimed}, ${seats_purchased}) ;;
    value_format_name: percent_1
  }
}
