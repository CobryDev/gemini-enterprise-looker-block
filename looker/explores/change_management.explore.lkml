# Explores over the redacted log tables and the AI adoption PDTs.
#
# Only the self-service starting points are visible: AI Activity (every
# action), People (one row per person) and the Gemini Enterprise detail.
# Everything else is a single-purpose table the dashboards already show in
# full, so it stays hidden; hidden explores still run dashboard tiles, drills
# and filter suggestions.

# ---------------------------------------------------------------- visible

explore: ai_activity_hourly {
  group_label: "Gemini AI Adoption"
  label: "AI Activity"
  description: "Start here. Every AI action across Gemini Enterprise, Gemini for Workspace and Antigravity, by person, department, product, feature, day and hour. Use it for usage trends, product split, time of day, leaderboards and estimated time saved."
  persist_with: gemini_change_management_datagroup

  join: ai_user_profile {
    view_label: "Person"
    fields: [ai_user_profile.person*]
    sql_on: ${ai_user_profile.user_email} = ${ai_activity_hourly.user_email} ;;
    relationship: many_to_one
  }

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${ai_activity_hourly.user_email} ;;
    relationship: many_to_one
  }
}

explore: ai_user_profile {
  group_label: "Gemini AI Adoption"
  label: "People and Activation"
  description: "One row per person: their AI cohort (Power, Normal, Casual, Non-AI), which products they use, whether they have a licence, and activation rates. Always the last 28 days."
  persist_with: gemini_change_management_datagroup

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${ai_user_profile.user_email} ;;
    relationship: one_to_one
  }
}

explore: ge_user_activity {
  group_label: "Gemini AI Adoption"
  label: "Gemini Enterprise Activity"
  description: "Every Gemini Enterprise interaction by person, feature, agent, model and app. Use it for feature and agent adoption, model choice and answer quality. No prompt or response text."
  persist_with: gemini_change_management_datagroup

  join: ge_user_activity__proposed_actions {
    view_label: "Gemini Enterprise Activity"
    sql: LEFT JOIN UNNEST(${ge_user_activity.proposed_actions}) AS ge_user_activity__proposed_actions ;;
    relationship: one_to_many
  }

  join: ge_user_activity__grounding_domains {
    view_label: "Gemini Enterprise Activity"
    sql: LEFT JOIN UNNEST(${ge_user_activity.grounding_domains}) AS ge_user_activity__grounding_domains ;;
    relationship: one_to_many
  }

  join: ge_user_activity__data_store_ids {
    view_label: "Gemini Enterprise Activity"
    sql: LEFT JOIN UNNEST(${ge_user_activity.data_store_ids}) AS ge_user_activity__data_store_ids ;;
    relationship: one_to_many
  }

  join: ai_user_profile {
    view_label: "Person"
    fields: [ai_user_profile.person*]
    sql_on: ${ai_user_profile.user_email} = ${ge_user_activity.user_email} ;;
    relationship: many_to_one
  }

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${ge_user_activity.user_email} ;;
    relationship: many_to_one
  }
}

# ---------------------------------------------------------------- hidden

explore: ai_user_cohort_weekly {
  hidden: yes
  label: "Cohorts Over Time"
  description: "Each person's AI cohort week by week, and whether they moved up or down."
  persist_with: gemini_change_management_datagroup

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${ai_user_cohort_weekly.user_email} ;;
    relationship: many_to_one
  }
}

explore: antigravity_usage {
  hidden: yes
  label: "Antigravity Activity"
  description: "Antigravity requests by person, client, model and experience."
  persist_with: gemini_change_management_datagroup

  join: ai_user_profile {
    view_label: "Person"
    fields: [ai_user_profile.person*]
    sql_on: ${ai_user_profile.user_email} = ${antigravity_usage.user_email} ;;
    relationship: many_to_one
  }

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${antigravity_usage.user_email} ;;
    relationship: many_to_one
  }
}

explore: ge_safety_events {
  hidden: yes
  label: "Safety and Model Armor"
  description: "Prompts and responses Model Armor screened or flagged, by person and category."
  persist_with: gemini_change_management_datagroup

  join: ai_user_profile {
    view_label: "Person"
    fields: [ai_user_profile.person*]
    sql_on: ${ai_user_profile.user_email} = ${ge_safety_events.user_email} ;;
    relationship: many_to_one
  }

  join: user_org_unit {
    view_label: "Person"
    sql_on: ${user_org_unit.user_email} = ${ge_safety_events.user_email} ;;
    relationship: many_to_one
  }
}

explore: setup_health_tables {
  hidden: yes
  label: "Setup Health"
  description: "Whether each source table exists, has rows and is fresh."
  persist_with: gemini_change_management_datagroup
}

explore: setup_health_workspace {
  hidden: yes
  label: "Setup Health: Workspace"
  description: "State of the Workspace audit export for the workspace_export setting."
  persist_with: gemini_change_management_datagroup
}

explore: setup_settings {
  hidden: yes
  label: "Setup Settings"
  description: "The block's install settings."
  persist_with: gemini_change_management_datagroup
}

explore: data_state {
  hidden: yes
  label: "Data State"
  description: "Compact source and history state cards for dashboards."
  persist_with: gemini_change_management_datagroup
}

explore: ai_opportunities {
  hidden: yes
  label: "AI Opportunities"
  description: "Prioritised queue of adoption, licence, access and data-quality opportunities with recommended next steps, and the interventions logged against them."
  persist_with: gemini_change_management_datagroup

  # An intervention addresses an opportunity when its opportunity_type matches and,
  # for department opportunities, its target_scope names the same department.
  join: ai_interventions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${ai_interventions.opportunity_type} = ${ai_opportunities.opportunity_type}
      AND (${ai_opportunities.scope_type} != 'Department' OR ${ai_interventions.target_scope} = ${ai_opportunities.scope})
      AND IFNULL(${ai_interventions.status}, '') != 'cancelled' ;;
  }
}

explore: ai_interventions {
  hidden: yes
  label: "AI Interventions"
  description: "Optional training, campaign, coaching and licence-review interventions."
  persist_with: gemini_change_management_datagroup
}

explore: intervention_impact {
  hidden: yes
  label: "Intervention Impact"
  description: "Before/after intervention comparison against a simple comparison group. Directional, not causal proof."
  persist_with: gemini_change_management_datagroup
}

explore: ai_value_outcomes {
  hidden: yes
  label: "Validated Value Outcomes"
  description: "Optional externally validated business outcomes loaded into the analytics dataset."
  persist_with: gemini_change_management_datagroup
}

explore: population_scope {
  hidden: yes
  label: "Population Scope"
  description: "People included or excluded from employee adoption metrics."
  persist_with: gemini_change_management_datagroup
}

explore: ge_tool_calls {
  hidden: yes
  label: "Tools and Skills"
  description: "Tool calls and skill loads made by the assistant on behalf of users."
  persist_with: gemini_change_management_datagroup

  join: user_org_unit {
    sql_on: ${user_org_unit.user_email} = ${ge_tool_calls.user_email} ;;
    relationship: many_to_one
  }
}

explore: ge_model_calls {
  hidden: yes
  label: "Model Calls and Tokens"
  description: "Model inferences with token counts, by user and agent."
  persist_with: gemini_change_management_datagroup

  join: ge_trace_context {
    view_label: "Trace Context"
    sql_on: ${ge_trace_context.trace_id} = ${ge_model_calls.trace_id} ;;
    relationship: many_to_one
  }

  join: user_org_unit {
    sql_on: ${user_org_unit.user_email} = ${ge_model_calls.user_email} ;;
    relationship: many_to_one
  }
}

explore: ge_user_licenses {
  hidden: yes
  label: "Licences"
  description: "Daily licence snapshots: assigned, unassigned and users asking for access."
  persist_with: gemini_change_management_datagroup

  join: user_org_unit {
    sql_on: ${user_org_unit.user_email} = ${ge_user_licenses.user_email} ;;
    relationship: many_to_one
  }
}

explore: ge_admin_events {
  hidden: yes
  label: "Admin Changes"
  description: "Agent, connector and app configuration changes from the Admin Activity audit log."
  persist_with: gemini_change_management_datagroup

  join: user_org_unit {
    sql_on: ${user_org_unit.user_email} = ${ge_admin_events.principal_email} ;;
    relationship: many_to_one
  }
}
