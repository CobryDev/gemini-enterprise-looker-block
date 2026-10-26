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
        <div style="margin-top:8px;font-size:12px;"><a style="color:#D2E3FC;" href="/dashboards/gemini_enterprise::gemini_ai_change">Change dashboard</a> &nbsp;|&nbsp; <a style="color:#D2E3FC;" href="/dashboards/gemini_enterprise::gemini_ai_admin">Admin dashboard</a></div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: overview

  - name: executive_narrative
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.executive_narrative_v2, ai_user_profile.ai_activation_rate, ai_user_profile.regular_among_active_rate, ai_user_profile.ai_active_users, ai_user_profile.people, ai_user_profile.regular_users, ai_user_profile.non_ai_users, ai_user_profile.ai_retention_rate, ai_user_profile.top_decile_action_share, ai_user_profile.normal_users, ai_user_profile.power_users, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
    hidden_fields: [ai_user_profile.ai_activation_rate, ai_user_profile.regular_among_active_rate, ai_user_profile.ai_active_users, ai_user_profile.people, ai_user_profile.regular_users, ai_user_profile.non_ai_users, ai_user_profile.ai_retention_rate, ai_user_profile.top_decile_action_share, ai_user_profile.normal_users, ai_user_profile.power_users, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 5
    col: 0
    width: 36
    height: 10
    tab_name: overview

  - name: data_trust
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: data_state
    fields: [data_state.data_trust_card, data_state.attention_checks, data_state.checks]
    hidden_fields: [data_state.attention_checks, data_state.checks]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 5
    col: 36
    width: 18
    height: 10
    tab_name: overview

  - name: top_decision
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.licence_decision_card, ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
    hidden_fields: [ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 5
    col: 54
    width: 18
    height: 10
    tab_name: overview

  - name: activation_kpi
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.adoption_card, ai_user_profile.ai_active_users, ai_user_profile.people]
    hidden_fields: [ai_user_profile.ai_active_users, ai_user_profile.people]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 15
    col: 0
    width: 18
    height: 6
    tab_name: overview

  - name: habit_kpi
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.habit_card, ai_user_profile.regular_users, ai_user_profile.ai_active_users, ai_user_profile.normal_users, ai_user_profile.power_users]
    hidden_fields: [ai_user_profile.regular_users, ai_user_profile.ai_active_users, ai_user_profile.normal_users, ai_user_profile.power_users]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 15
    col: 18
    width: 18
    height: 6
    tab_name: overview

  - name: retention_kpi
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.retention_card, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
    hidden_fields: [ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 15
    col: 36
    width: 18
    height: 6
    tab_name: overview

  - name: not_active_kpi
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.not_yet_active_card, ai_user_profile.people]
    hidden_fields: [ai_user_profile.people]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 15
    col: 54
    width: 18
    height: 6
    tab_name: overview

  - name: recommended_actions
    title: "Recommended actions | top 3"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_opportunities
    fields: [ai_opportunities.priority_label, ai_opportunities.action_title, ai_opportunities.evidence, ai_opportunities.impact, ai_opportunities.next_step, ai_opportunities.priority, ai_opportunities.size]
    hidden_fields: [ai_opportunities.priority, ai_opportunities.size]
    filters:
      ai_opportunities.is_actionable: "Yes"
    sorts: ["ai_opportunities.priority", "ai_opportunities.size desc"]
    limit: 3
    show_view_names: false
    show_row_numbers: false
    truncate_text: false
    size_to_fit: true
    series_labels:
      ai_opportunities.priority_label: "Priority"
      ai_opportunities.action_title: "Action"
      ai_opportunities.next_step: "Next step"
    row: 21
    col: 0
    width: 72
    height: 9
    tab_name: overview

  - name: adoption_trend
    title: "Weekly active AI users | complete weeks"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.ai_users]
    filters:
      ai_activity_hourly.is_complete_week: "Yes"
    fill_fields: [ai_activity_hourly.event_week]
    sorts: ["ai_activity_hourly.event_week"]
    limit: 26
    show_value_labels: true
    show_view_names: false
    y_axis_gridlines: false
    legend_position: none
    series_colors:
      ai_activity_hourly.ai_users: "#1a73e8"
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 30
    col: 0
    width: 36
    height: 10
    tab_name: overview

  - name: department_adoption
    title: "Where the adoption gap is | inactive eligible people"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.non_ai_users, ai_user_profile.activation_summary]
    sorts: ["ai_user_profile.non_ai_users desc"]
    limit: 12
    show_view_names: false
    show_row_numbers: false
    truncate_text: false
    size_to_fit: true
    series_labels:
      user_org_unit.department: "Department"
      ai_user_profile.non_ai_users: "Not yet active"
      ai_user_profile.activation_summary: "Active of eligible"
    series_cell_visualizations:
      ai_user_profile.non_ai_users:
        is_active: true
        palette:
          palette_id: gap-bars
          collection_id: google
          custom_colors: ["#fce8e6", "#d93025"]
    listen:
      Department: user_org_unit.department
    row: 30
    col: 36
    width: 36
    height: 10
    tab_name: overview

  - name: cohort_mix
    title: "Employee adoption distribution | eligible people, last 28 days"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.cohort, ai_user_profile.people]
    pivots: [ai_user_profile.cohort]
    sorts: ["ai_user_profile.cohort"]
    limit: 10
    stacking: percent
    show_value_labels: true
    label_type: labPer
    show_view_names: false
    show_x_axis_label: false
    show_x_axis_ticks: false
    show_y_axis_labels: false
    show_y_axis_ticks: false
    x_axis_gridlines: false
    y_axis_gridlines: false
    legend_position: center
    series_colors:
      Power - ai_user_profile.people: "#174EA6"
      Normal - ai_user_profile.people: "#1A73E8"
      Casual - ai_user_profile.people: "#8AB4F8"
      Non-AI - ai_user_profile.people: "#BDC1C6"
    row: 40
    col: 0
    width: 36
    height: 7
    tab_name: overview

  - name: concentration
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.concentration_card, ai_user_profile.top_user_action_share]
    hidden_fields: [ai_user_profile.top_user_action_share]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 40
    col: 36
    width: 18
    height: 7
    tab_name: overview

  - name: effective_period
    title: ""
    title_hidden: true
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.metric_window_card, ai_user_profile.tracking_since]
    hidden_fields: [ai_user_profile.tracking_since]
    show_single_value_title: false
    show_comparison: false
    limit: 1
    row: 40
    col: 54
    width: 18
    height: 7
    tab_name: overview

  - name: header_value
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family:'Google Sans',Arial,sans-serif;line-height:1.5;">
        <h2 style="margin:0 0 4px 0">Estimated time benefit</h2>
        <p style="margin:0;color:#3c4043">An estimate of time benefit, <strong>not realised ROI</strong>. The headline counts only actions a person asked Gemini to do, times the minutes-saved setting for each feature. Automated workflow and agent runs are shown separately with lower confidence. Proactive suggestions earn nothing. Figures are scaled to an average month from the selected date range. Validated outcomes appear on the Interventions tab of the Change dashboard once loaded.</p>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: business_value

  - name: hours_month
    title: "Time benefit | hours per month"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved_per_month, ai_activity_hourly.hours_saved_low_per_month, ai_activity_hourly.hours_saved_high_per_month]
    hidden_fields: [ai_activity_hourly.hours_saved_low_per_month, ai_activity_hourly.hours_saved_high_per_month]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 5
    col: 0
    width: 18
    height: 7
    tab_name: business_value

  - name: value_month
    title: "Time benefit | value per month"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.value_per_month, ai_activity_hourly.value_low_per_month, ai_activity_hourly.value_high_per_month]
    hidden_fields: [ai_activity_hourly.value_low_per_month, ai_activity_hourly.value_high_per_month]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 5
    col: 18
    width: 18
    height: 7
    tab_name: business_value

  - name: automation_month
    title: "Automation | hours per month, lower confidence"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.automation_hours_per_month, ai_activity_hourly.automation_runs_per_month]
    hidden_fields: [ai_activity_hourly.automation_runs_per_month]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 5
    col: 36
    width: 18
    height: 7
    tab_name: business_value

  - name: licence_review
    title: "Licence spend to review | per month"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
    row: 5
    col: 54
    width: 18
    height: 7
    tab_name: business_value

  - name: hours_by_use_case
    title: "Estimated hours by use case | active actions"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_case, ai_activity_hourly.hours_saved]
    filters:
      ai_activity_hourly.hours_saved: ">0"
    sorts: ["ai_activity_hourly.hours_saved desc"]
    limit: 10
    show_value_labels: true
    label_density: 25
    x_axis_gridlines: false
    y_axis_gridlines: false
    show_view_names: false
    legend_position: none
    series_colors:
      ai_activity_hourly.hours_saved: "#1a73e8"
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 12
    col: 0
    width: 36
    height: 10
    tab_name: business_value

  - name: value_trend
    title: "Estimated hours per complete week"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.hours_saved, ai_activity_hourly.automation_hours_saved]
    filters:
      ai_activity_hourly.is_complete_week: "Yes"
    fill_fields: [ai_activity_hourly.event_week]
    sorts: ["ai_activity_hourly.event_week"]
    limit: 26
    stacking: normal
    show_view_names: false
    y_axis_gridlines: false
    series_labels:
      ai_activity_hourly.hours_saved: "Active (headline)"
      ai_activity_hourly.automation_hours_saved: "Automation (lower confidence)"
    series_colors:
      ai_activity_hourly.hours_saved: "#1a73e8"
      ai_activity_hourly.automation_hours_saved: "#dadce0"
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 12
    col: 36
    width: 36
    height: 10
    tab_name: business_value

  - name: credit_assumptions
    title: "What earns time-saving credit | top features"
    note_display: hover
    note_text: "Minutes per action come from the Minutes saved per AI action setting. Change them in Marketplace > Manage if they don't match how your people work."
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_case, ai_activity_hourly.feature, ai_activity_hourly.interaction_mode, ai_activity_hourly.minutes_saved_per_action, ai_activity_hourly.credited_actions, ai_activity_hourly.credited_hours]
    filters:
      ai_activity_hourly.credited_hours: ">0"
    sorts: ["ai_activity_hourly.credited_hours desc"]
    limit: 12
    show_view_names: false
    show_row_numbers: false
    series_labels:
      ai_activity_hourly.minutes_saved_per_action: "Minutes per action"
      ai_activity_hourly.credited_actions: "Credited actions"
      ai_activity_hourly.credited_hours: "Hours"
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 22
    col: 0
    width: 72
    height: 10
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
    fields: [ai_opportunities.priority_label, ai_opportunities.category, ai_opportunities.action_title, ai_opportunities.evidence, ai_opportunities.impact, ai_opportunities.next_step, ai_opportunities.priority, ai_opportunities.size]
    hidden_fields: [ai_opportunities.priority, ai_opportunities.size]
    filters:
      ai_opportunities.is_actionable: "Yes"
    show_view_names: false
    show_row_numbers: false
    truncate_text: false
    size_to_fit: true
    series_labels:
      ai_opportunities.priority_label: "Priority"
      ai_opportunities.action_title: "Action"
      ai_opportunities.next_step: "Next step"
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
