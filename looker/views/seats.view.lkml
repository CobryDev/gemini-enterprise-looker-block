view: seats {
  label: "Seats & Licensing"
  # Seat counts come from the engine-wide aggregated metric rows, one per day.
  derived_table: {
    sql:
      SELECT
        engine_id,
        app_name,
        metric_date,
        seats_purchased,
        seats_claimed
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE data_source = 'DATA_SOURCE_AGGREGATED_METRIC' ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the seat counts belong to."
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
    description: "Date (UTC) the seat snapshot was recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  measure: seats_purchased {
    description: "Licenses purchased for the app. A daily snapshot, so this takes the max over the selected period rather than summing."
    type: max
    sql: ${TABLE}.seats_purchased ;;
    value_format_name: decimal_0
  }

  measure: seats_claimed {
    description: "Licenses actually assigned to users. A daily snapshot, so this takes the max over the selected period rather than summing."
    type: max
    sql: ${TABLE}.seats_claimed ;;
    value_format_name: decimal_0
  }

  measure: seat_utilisation {
    label: "Seat Utilisation"
    description: "Seats claimed divided by seats purchased. Shows how much of the purchased capacity is in use."
    type: number
    sql: SAFE_DIVIDE(${seats_claimed}, ${seats_purchased}) ;;
    value_format_name: percent_1
  }

  measure: unclaimed_seats {
    description: "Purchased seats not yet assigned to a user (seats purchased minus seats claimed)."
    type: number
    sql: ${seats_purchased} - ${seats_claimed} ;;
    value_format_name: decimal_0
  }
}
