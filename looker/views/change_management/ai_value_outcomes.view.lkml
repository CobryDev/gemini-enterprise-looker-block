view: ai_value_outcomes {
  label: "Validated Value Outcomes"
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.@{value_outcomes_table}` ;;

  dimension_group: outcome {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.outcome_date ;;
  }

  dimension: scope {
    type: string
    sql: ${TABLE}.scope ;;
  }

  dimension: metric {
    type: string
    sql: ${TABLE}.metric ;;
  }

  dimension: unit {
    type: string
    sql: ${TABLE}.unit ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  measure: outcome_records {
    type: count
  }

  measure: outcome_value {
    label: "Validated Outcome Value"
    type: sum
    sql: ${TABLE}.value ;;
    value_format_name: decimal_1
  }
}
