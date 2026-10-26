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
    description: "planned, active, complete or cancelled."
    type: string
    sql: LOWER(${TABLE}.status) ;;
  }

  dimension: status_or_not_started {
    label: "Action Status"
    description: "Intervention status, or Not started when no intervention is logged for the opportunity."
    type: string
    sql: COALESCE(INITCAP(${TABLE}.status), 'Not started') ;;
  }

  dimension: owner_or_unassigned {
    label: "Action Owner"
    description: "Intervention owner, or Unassigned when no intervention is logged for the opportunity or it has no owner."
    type: string
    sql: COALESCE(NULLIF(${TABLE}.owner, ''), 'Unassigned') ;;
  }

  dimension: is_overdue {
    description: "Planned or active, and the follow-up date has passed."
    type: yesno
    sql: LOWER(${TABLE}.status) IN ('planned', 'active') AND ${TABLE}.follow_up_date < CURRENT_DATE() ;;
  }

  # outcome and outcome_notes were added to the table after the first release. Reading
  # them through JSON keeps the view working on tables created before the columns existed.
  dimension: outcome {
    description: "Result recorded after the follow-up: improved, no_change, worse or too_early."
    type: string
    sql: INITCAP(REPLACE(JSON_VALUE(TO_JSON_STRING(${TABLE}), '$.outcome'), '_', ' ')) ;;
  }

  dimension: outcome_notes {
    description: "What changed, with the evidence used."
    type: string
    sql: JSON_VALUE(TO_JSON_STRING(${TABLE}), '$.outcome_notes') ;;
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

  measure: overdue_interventions {
    type: count
    filters: [is_overdue: "yes"]
  }

  measure: completed_interventions {
    type: count
    filters: [status: "complete"]
  }
}
