view: ai_interventions {
  label: "AI Interventions"
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.@{interventions_table}` ;;

  dimension: intervention_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.intervention_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension_group: start {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.start_date ;;
  }

  dimension_group: end {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.end_date ;;
  }

  dimension: target_scope_type {
    type: string
    sql: ${TABLE}.target_scope_type ;;
  }

  dimension: target_scope {
    type: string
    sql: ${TABLE}.target_scope ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}.owner ;;
  }

  dimension: opportunity_type {
    type: string
    sql: ${TABLE}.opportunity_type ;;
  }

  dimension_group: follow_up {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.follow_up_date ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}.notes ;;
  }

  measure: interventions {
    type: count
  }

  measure: open_interventions {
    type: count
    filters: [status: "planned,active"]
  }
}
