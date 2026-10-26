- dashboard: gemini_ai_executive
  title: Gemini | Executive AI Adoption
  preferred_viewer: dashboards-next
  description: "Executive view of AI adoption health, value scenarios and decisions."
  layout: newspaper
  layout_granularity: granular
  tabs:
  - name: overview
    label: "Overview"
  - name: business_value
    label: "Business Value"
  - name: risks_decisions
    label: "Risks & Decisions"
  elements:
  - name: header_overview
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background:#0B1F3A;border-radius:8px;padding:18px 24px;font-family:'Google Sans',Arial,sans-serif;color:#fff;">
        <div style="font-size:12px;text-transform:uppercase;letter-spacing:1.5px;opacity:.75;">Gemini AI Adoption</div>
        <div style="font-size:26px;font-weight:600;">Executive Overview</div>
        <div style="font-size:13px;opacity:.85;">Is AI adoption healthy, is it creating value, and what decisions need attention?</div>
        <div style="margin-top:8px;font-size:12px;"><a style="color:#D2E3FC;" href="/dashboards/gemini_ai_change">Change dashboard</a> &nbsp;|&nbsp; <a style="color:#D2E3FC;" href="/dashboards/gemini_ai_admin">Admin dashboard</a></div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: overview

  - name: executive_narrative
    title: "Executive Narrative"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.executive_narrative_card, ai_user_profile.ai_active_users, ai_user_profile.people, ai_user_profile.normal_users, ai_user_profile.power_users, ai_user_profile.idle_ge_licences, ai_user_profile.top_user_action_share]
    limit: 1
    show_single_value_title: false
    row: 5
    col: 0
    width: 36
    height: 8
    tab_name: overview

  - name: data_trust
    title: "Data Trust"
    type: single_value
    model: gemini_enterprise
    explore: data_state
    fields: [data_state.data_trust_card, data_state.attention_checks, data_state.checks]
    limit: 1
    show_single_value_title: false
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: overview

  - name: top_decision
    title: "Top Decision"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
    limit: 1
    show_single_value_title: true
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: overview

  - name: activation_kpi
    title: "Activation | 1+ AI day in last 28 days"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.ai_activation_rate, ai_user_profile.ai_active_users, ai_user_profile.people]
    limit: 1
    row: 13
    col: 0
    width: 18
    height: 6
    tab_name: overview

  - name: regular_kpi
    title: "Regular Adoption | Normal or Power users"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.regular_adoption_rate, ai_user_profile.normal_users, ai_user_profile.power_users, ai_user_profile.people]
    limit: 1
    row: 13
    col: 18
    width: 18
    height: 6
    tab_name: overview

  - name: engagement_kpi
    title: "Engagement | AI days per active user"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.ai_engagement_days_per_active_user, ai_user_profile.ai_active_users]
    limit: 1
    row: 13
    col: 36
    width: 18
    height: 6
    tab_name: overview

  - name: retention_kpi
    title: "Retention | returned from previous 28 days"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.ai_retention_rate, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
    limit: 1
    row: 13
    col: 54
    width: 18
    height: 6
    tab_name: overview

  - name: recommended_actions
    title: "Recommended Actions"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_opportunities
    fields: [ai_opportunities.opportunity_type, ai_opportunities.scope, ai_opportunities.evidence, ai_opportunities.recommended_action, ai_opportunities.priority]
    sorts: ["ai_opportunities.priority", "ai_opportunities.size desc"]
    limit: 3
    row: 19
    col: 0
    width: 72
    height: 9
    tab_name: overview

  - name: adoption_trend
    title: "Weekly AI Users"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.ai_users]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: ["ai_activity_hourly.event_week"]
    limit: 26
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 28
    col: 0
    width: 36
    height: 10
    tab_name: overview

  - name: department_adoption
    title: "Departments by Inactive Eligible People"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.people, ai_user_profile.ai_active_users, ai_user_profile.ai_activation_rate]
    sorts: ["ai_user_profile.people desc"]
    limit: 20
    listen:
      Department: user_org_unit.department
    row: 28
    col: 36
    width: 36
    height: 10
    tab_name: overview

  - name: cohort_mix
    title: "Cohort Mix | last 28 days"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.cohort, ai_user_profile.people]
    sorts: ["ai_user_profile.cohort"]
    limit: 10
    row: 38
    col: 0
    width: 36
    height: 9
    tab_name: overview

  - name: concentration
    title: "Usage Concentration"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.top_user_action_share, ai_user_profile.top_decile_action_share]
    limit: 1
    row: 38
    col: 36
    width: 18
    height: 9
    tab_name: overview

  - name: effective_period
    title: "Metric Window"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.effective_period, ai_user_profile.tracking_since]
    limit: 1
    row: 38
    col: 54
    width: 18
    height: 9
    tab_name: overview

  - name: header_value
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Business Value</h2><p>Estimated productivity benefit is assumption-based. Validated benefit is reported separately when outcome records are loaded.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: business_value

  - name: hours_low
    title: "Estimated Hours Saved | Low"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved_low]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 0
    width: 18
    height: 6
    tab_name: business_value

  - name: hours_base
    title: "Estimated Hours Saved | Base"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 18
    width: 18
    height: 6
    tab_name: business_value

  - name: hours_high
    title: "Estimated Hours Saved | High"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved_high]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 36
    width: 18
    height: 6
    tab_name: business_value

  - name: licence_review
    title: "Licence Spend to Review"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
    row: 4
    col: 54
    width: 18
    height: 6
    tab_name: business_value

  - name: hours_by_use_case
    title: "Estimated Hours Saved by Use Case"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_case, ai_activity_hourly.hours_saved]
    sorts: ["ai_activity_hourly.hours_saved desc"]
    limit: 20
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 10
    col: 0
    width: 36
    height: 11
    tab_name: business_value

  - name: value_trend
    title: "Estimated Hours Saved per Week"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.hours_saved]
    sorts: ["ai_activity_hourly.event_week"]
    limit: 26
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 10
    col: 36
    width: 36
    height: 11
    tab_name: business_value

  - name: header_risks
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Risks & Decisions</h2><p>Use these checks to decide whether data is ready for executive reporting and which adoption decisions need ownership.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: risks_decisions

  - name: data_states
    title: "Data States"
    type: looker_grid
    model: gemini_enterprise
    explore: data_state
    fields: [data_state.feature, data_state.state, data_state.message]
    sorts: ["data_state.sort_order"]
    limit: 20
    row: 4
    col: 0
    width: 36
    height: 12
    tab_name: risks_decisions

  - name: decisions
    title: "Decision Queue"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_opportunities
    fields: [ai_opportunities.opportunity_type, ai_opportunities.scope_type, ai_opportunities.scope, ai_opportunities.size, ai_opportunities.evidence, ai_opportunities.recommended_action, ai_opportunities.priority]
    sorts: ["ai_opportunities.priority", "ai_opportunities.size desc"]
    limit: 20
    row: 4
    col: 36
    width: 36
    height: 12
    tab_name: risks_decisions

  filters:
  - name: Date
    title: Date
    type: field_filter
    model: gemini_enterprise
    explore: ai_activity_hourly
    default_value: "90 day"
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
    listens_to_filters: []
    field: ai_activity_hourly.event_date
  - name: Product
    title: Product
    type: field_filter
    model: gemini_enterprise
    explore: ai_activity_hourly
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: popover
    listens_to_filters: []
    field: ai_activity_hourly.product
  - name: Department
    title: Department
    type: field_filter
    model: gemini_enterprise
    explore: ai_user_profile
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    listens_to_filters: []
    field: user_org_unit.department
