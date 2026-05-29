view: seats {
  label: "Seats & Licensing"
  # Seat counts come from the engine-wide aggregated metric rows, one per day.
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        seats_purchased,
        seats_claimed
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE data_source = 'DATA_SOURCE_AGGREGATED_METRIC' ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.metric_date ;;
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

  measure: seats_purchased {
    type: max
    sql: ${TABLE}.seats_purchased ;;
    value_format_name: decimal_0
  }

  measure: seats_claimed {
    type: max
    sql: ${TABLE}.seats_claimed ;;
    value_format_name: decimal_0
  }

  measure: seat_utilisation {
    label: "Seat Utilisation"
    type: number
    sql: SAFE_DIVIDE(${seats_claimed}, ${seats_purchased}) ;;
    value_format_name: percent_1
  }

  measure: unclaimed_seats {
    type: number
    sql: ${seats_purchased} - ${seats_claimed} ;;
    value_format_name: decimal_0
  }
}
