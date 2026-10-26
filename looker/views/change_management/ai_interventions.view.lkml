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

  measure: interventions_state_card {
    hidden: yes
    description: "Empty state or summary for the Interventions tab. Include open_interventions, overdue_interventions and completed_interventions in the tile query."
    type: count
    html: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:6px 10px;line-height:1.4;white-space:normal;">{% if value == 0 %}<div style="font-size:20px;font-weight:600;color:#202124;">No interventions recorded yet</div><div style="font-size:14px;color:#3c4043;margin-top:6px;max-width:640px;">Record a training session, adoption campaign or targeted coaching activity to measure its impact over time.</div>{% if "@{interventions_form_url}" != "none" %}<a href="@{interventions_form_url}" target="_blank" style="display:inline-block;margin-top:12px;background:#1a73e8;color:#fff;font-size:13px;font-weight:600;padding:8px 16px;border-radius:18px;text-decoration:none;">Record an intervention</a>{% else %}<div style="font-size:12px;color:#5f6368;margin-top:10px;">Your Looker admin can connect an intervention form; see the block README.</div>{% endif %}{% else %}<div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;">Interventions</div><div style="display:flex;gap:40px;margin-top:8px;"><div><div style="font-size:28px;font-weight:600;color:#202124;">{{ open_interventions._rendered_value }}</div><div style="font-size:12px;color:#5f6368;">open</div></div><div><div style="font-size:28px;font-weight:600;color:{% if overdue_interventions._value > 0 %}#C5221F{% else %}#202124{% endif %};">{{ overdue_interventions._rendered_value }}</div><div style="font-size:12px;color:#5f6368;">follow-up overdue</div></div><div><div style="font-size:28px;font-weight:600;color:#202124;">{{ completed_interventions._rendered_value }}</div><div style="font-size:12px;color:#5f6368;">completed</div></div></div>{% if "@{interventions_form_url}" != "none" %}<a href="@{interventions_form_url}" target="_blank" style="display:inline-block;margin-top:14px;background:#1a73e8;color:#fff;font-size:13px;font-weight:600;padding:8px 16px;border-radius:18px;text-decoration:none;">Record an intervention</a>{% else %}<div style="font-size:12px;color:#5f6368;margin-top:10px;">Your Looker admin can connect an intervention form; see the block README.</div>{% endif %}{% endif %}</div> ;;
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
