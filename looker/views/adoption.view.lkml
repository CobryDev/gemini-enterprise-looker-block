view: adoption {
  label: "Adoption"
  # Headline adoption-rate view: combines the GWS_LOG active-user slice and the
  # AGGREGATED_METRIC seat slice of export_history into one row per engine per
  # day, so DAU can be divided by seats claimed. The two metrics live on rows
  # with different data_source values, which is why neither the active_users
  # nor the seats explore can compute this on its own.
  derived_table: {
    sql:
      SELECT
        engine_id,
        ANY_VALUE(app_name) AS app_name,
        metric_date,
        MAX(IF(data_source = 'DATA_SOURCE_GWS_LOG' AND product_type = 'Total', daily_active_user_count, NULL)) AS daily_active_users,
        MAX(IF(data_source = 'DATA_SOURCE_AGGREGATED_METRIC', seats_claimed, NULL)) AS seats_claimed,
        MAX(IF(data_source = 'DATA_SOURCE_AGGREGATED_METRIC', seats_purchased, NULL)) AS seats_purchased
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE data_source IN ('DATA_SOURCE_GWS_LOG', 'DATA_SOURCE_AGGREGATED_METRIC')
      GROUP BY engine_id, metric_date ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the adoption figures belong to."
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
    description: "Date (UTC) the adoption figures were recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  measure: average_daily_active_users {
    label: "Avg Daily Active Users"
    description: "Daily active users (Total surface) averaged over the selected dates."
    type: average
    sql: ${TABLE}.daily_active_users ;;
    value_format_name: decimal_1
  }

  measure: seats_claimed {
    description: "Licenses assigned to users. A daily snapshot, so this takes the max over the selected period."
    type: max
    sql: ${TABLE}.seats_claimed ;;
    value_format_name: decimal_0
  }

  measure: seats_purchased {
    description: "Licenses purchased. A daily snapshot, so this takes the max over the selected period."
    type: max
    sql: ${TABLE}.seats_purchased ;;
    value_format_name: decimal_0
  }

  measure: adoption_rate {
    label: "Daily Active / Seats Claimed"
    description: "Google export metric: average daily active Gemini Enterprise users divided by seats claimed over the selected period. This is product telemetry, not the canonical employee activation rate."
    type: number
    sql: SAFE_DIVIDE(${average_daily_active_users}, ${seats_claimed}) ;;
    value_format_name: percent_1
  }

  measure: licence_utilisation {
    label: "Licence Utilisation"
    description: "Average daily active users divided by seats purchased. Shows usage against everything that is being paid for, not just assigned seats."
    type: number
    sql: SAFE_DIVIDE(${average_daily_active_users}, ${seats_purchased}) ;;
    value_format_name: percent_1
  }
}
