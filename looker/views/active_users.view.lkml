view: active_users {
  label: "Active Users"
  # Active-user counts are reported per product (Total, Search, Assistant, Other),
  # one row per day per product. Filter to product_type = "Total" for headline
  # numbers, or break down by product_type to compare surfaces.
  derived_table: {
    sql:
      SELECT
        engine_id,
        app_name,
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
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date, '|', ${TABLE}.product_type) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the active-user counts belong to."
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
    description: "Date (UTC) the active-user counts were recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: product_type {
    description: "Product surface the counts apply to: Total, Search, Assistant, or Other. Use Total for headline active users; break down by the others to compare surfaces."
    type: string
    sql: ${TABLE}.product_type ;;
  }

  measure: daily_active_users {
    label: "Daily Active Users"
    description: "Distinct users active on a given day. Reported once per product surface per day; filter to a single day (and product_type = Total) for a point-in-time count, since summing across days adds daily figures together."
    type: sum
    sql: ${TABLE}.daily_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: weekly_active_users {
    label: "Weekly Active Users"
    description: "Distinct users active in the trailing 7-day window ending on each date. Best read for a single date rather than summed across days."
    type: sum
    sql: ${TABLE}.weekly_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: monthly_active_users {
    label: "Monthly Active Users"
    description: "Distinct users active in the trailing 28/30-day window ending on each date. Best read for a single date rather than summed across days."
    type: sum
    sql: ${TABLE}.monthly_active_user_count ;;
    value_format_name: decimal_0
  }

  measure: peak_daily_active_users {
    label: "Peak Daily Active Users"
    description: "Highest single-day active-user count in the selected period and product surface."
    type: max
    sql: ${TABLE}.daily_active_user_count ;;
    value_format_name: decimal_0
  }

  # Retention / growth / churn are reported as percentages already (e.g. 80 = 80%),
  # so they use a "%" suffix format rather than percent_* (which would multiply by 100).
  measure: retention_7d {
    label: "7-Day Retention"
    description: "Share of users active 7 days earlier who are active again, averaged over the selected dates. Reported on a 0-100 scale."
    type: average
    sql: ${TABLE}.user_retention_ratio_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: retention_28d {
    label: "28-Day Retention"
    description: "Share of users active 28 days earlier who are active again, averaged over the selected dates. Reported on a 0-100 scale."
    type: average
    sql: ${TABLE}.user_retention_ratio_for28d ;;
    value_format: "0.0\"%\""
  }

  measure: growth_rate_7d {
    label: "7-Day Growth Rate"
    description: "Week-over-week change in active users, averaged over the selected dates. Can be negative. Reported on a 0-100 (percentage-point) scale."
    type: average
    sql: ${TABLE}.user_growth_rate_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: growth_rate_28d {
    label: "28-Day Growth Rate"
    description: "Period-over-period change in active users over 28 days, averaged over the selected dates. Can be negative. Reported on a 0-100 (percentage-point) scale."
    type: average
    sql: ${TABLE}.user_growth_rate_for28d ;;
    value_format: "0.0\"%\""
  }

  measure: churn_rate_7d {
    label: "7-Day Churn Rate"
    description: "Share of users active 7 days earlier who did not return, averaged over the selected dates. Reported on a 0-100 scale."
    type: average
    sql: ${TABLE}.user_churn_rate_for7d ;;
    value_format: "0.0\"%\""
  }

  measure: churn_rate_28d {
    label: "28-Day Churn Rate"
    description: "Share of users active 28 days earlier who did not return, averaged over the selected dates. Reported on a 0-100 scale."
    type: average
    sql: ${TABLE}.user_churn_rate_for28d ;;
    value_format: "0.0\"%\""
  }
}
