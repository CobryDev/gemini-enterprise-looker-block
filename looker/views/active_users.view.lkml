view: active_users {
  label: "Active Users"
  # Active-user counts are reported per product (Total, Search, Assistant, Other),
  # one row per day per product. Filter to product_type = "Total" for headline
  # numbers, or break down by product_type to compare surfaces.
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        product_type,
        daily_active_user_count,
        weekly_active_user_count,
        monthly_active_user_count,
        user_retention_ratio_for7d,
        user_retention_ratio_for28d,
        user_growth_rate_for7d,
        user_growth_rate_for28d,
        user_churn_rate_for7d,
        user_churn_rate_for28d
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE data_source = 'DATA_SOURCE_GWS_LOG'
        AND product_type IS NOT NULL ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.metric_date, '|', ${TABLE}.product_type) ;;
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

  dimension: product_type {
    description: "Total, Search, Assistant, or Other. Use Total for headline active users."
    type: string
    sql: ${TABLE}.product_type ;;
  }

  measure: daily_active_users {
    label: "Daily Active Users"
    type: sum
    sql: ${TABLE}.daily_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: weekly_active_users {
    label: "Weekly Active Users"
    type: sum
    sql: ${TABLE}.weekly_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: monthly_active_users {
    label: "Monthly Active Users"
    type: sum
    sql: ${TABLE}.monthly_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: peak_daily_active_users {
    label: "Peak Daily Active Users"
    type: max
    sql: ${TABLE}.daily_active_user_count ;;
    value_format_name: decimal_0
  }

  # Retention / growth / churn are reported as percentages already (e.g. 80 = 80%),
  # so they use a "%" suffix format rather than percent_* (which would multiply by 100).
  measure: retention_7d {
    label: "7-Day Retention"
    type: average
    sql: ${TABLE}.user_retention_ratio_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: retention_28d {
    label: "28-Day Retention"
    type: average
    sql: ${TABLE}.user_retention_ratio_for28d ;;
    value_format: "0.0\"%\""
  }

  measure: growth_rate_7d {
    label: "7-Day Growth Rate"
    type: average
    sql: ${TABLE}.user_growth_rate_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: growth_rate_28d {
    label: "28-Day Growth Rate"
    type: average
    sql: ${TABLE}.user_growth_rate_for28d ;;
    value_format: "0.0\"%\""
  }

  measure: churn_rate_7d {
    label: "7-Day Churn Rate"
    type: average
    sql: ${TABLE}.user_churn_rate_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: churn_rate_28d {
    label: "28-Day Churn Rate"
    type: average
    sql: ${TABLE}.user_churn_rate_for28d ;;
    value_format: "0.0\"%\""
  }
}
