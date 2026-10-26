- dashboard: gemini_ai_change
  title: Gemini | AI Change Management
  preferred_viewer: dashboards-next
  description: "Operational dashboard for adoption opportunities, cohorts, use cases, coaching and intervention measurement."
  layout: newspaper
  layout_granularity: granular
  tabs:
  - name: opportunities
    label: "Opportunities"
  - name: adoption_cohorts
    label: "Adoption & Cohorts"
  - name: use_cases
    label: "Use Cases"
  - name: people_coaching
    label: "People & Coaching"
  - name: interventions
    label: "Interventions"
  elements:
  - name: header_change
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background:#137333;border-radius:8px;padding:18px 24px;font-family:'Google Sans',Arial,sans-serif;color:#fff;">
        <div style="font-size:12px;text-transform:uppercase;letter-spacing:1.5px;opacity:.75;">Gemini AI Adoption</div>
        <div style="font-size:26px;font-weight:600;">Change Management</div>
        <div style="font-size:13px;opacity:.85;">Where adoption is struggling, what to do next, and whether interventions helped.</div>
        <div style="margin-top:8px;font-size:12px;"><a style="color:#CEEAD6;" href="/dashboards/gemini_enterprise::gemini_ai_executive">Executive dashboard</a> &nbsp;|&nbsp; <a style="color:#CEEAD6;" href="/dashboards/gemini_enterprise::gemini_ai_admin">Admin dashboard</a></div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: opportunities

  - name: opportunity_queue
    title: "Prioritised Opportunity Queue"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_opportunities
    fields: [ai_opportunities.priority_label, ai_opportunities.category, ai_opportunities.action_title, ai_opportunities.evidence, ai_opportunities.impact, ai_opportunities.next_step, ai_interventions.owner_or_unassigned, ai_interventions.status_or_not_started, ai_interventions.follow_up_date, ai_opportunities.priority, ai_opportunities.size]
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
      ai_interventions.owner_or_unassigned: "Owner"
      ai_interventions.status_or_not_started: "Status"
      ai_interventions.follow_up_date: "Follow-up due"
    note_state: collapsed
    note_display: hover
    note_text: "Owner, status and follow-up come from interventions logged with a matching opportunity_type (and department, for department opportunities). See the Interventions tab for how to log one."
    sorts: ["ai_opportunities.priority", "ai_opportunities.size desc"]
    limit: 50
    row: 5
    col: 0
    width: 72
    height: 13
    tab_name: opportunities

  - name: room_to_grow
    title: "Casual or Non-AI Share"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.casual_or_non_ai_share, ai_user_profile.casual_users, ai_user_profile.non_ai_users, ai_user_profile.people]
    row: 18
    col: 0
    width: 18
    height: 7
    tab_name: opportunities

  - name: idle_licences
    title: "Idle Gemini Enterprise Licences"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licences, ai_user_profile.ge_licensed_users]
    row: 18
    col: 18
    width: 18
    height: 7
    tab_name: opportunities

  - name: workspace_only
    title: "Workspace Gemini Only"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.gws_active_users, ai_user_profile.ge_active_licensed_users]
    row: 18
    col: 36
    width: 18
    height: 7
    tab_name: opportunities

  - name: licence_requests
    title: "Users Asking for a Licence"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_licenses
    fields: [ge_user_licenses.unlicensed_login_attempts]
    filters:
      ge_user_licenses.is_latest_snapshot: "yes"
    row: 18
    col: 54
    width: 18
    height: 7
    tab_name: opportunities

  - name: department_room
    title: "Departments with the Most Room to Grow"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.people, ai_user_profile.ai_active_users, ai_user_profile.ai_activation_rate, ai_user_profile.casual_users, ai_user_profile.non_ai_users]
    sorts: ["ai_user_profile.non_ai_users desc"]
    limit: 30
    listen:
      Department: user_org_unit.department
    row: 25
    col: 0
    width: 36
    height: 13
    tab_name: opportunities

  - name: idle_licence_list
    title: "Idle Gemini Enterprise Licences | validate before reclaiming"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.licence_assigned_date, ai_user_profile.days_since_last_ai_use, ai_user_profile.ge_days_28d]
    filters:
      ai_user_profile.is_ge_licensed: "yes"
      ai_user_profile.ge_days_28d: "0"
    sorts: ["ai_user_profile.licence_assigned_date desc"]
    limit: 50
    listen:
      Department: user_org_unit.department
    row: 25
    col: 36
    width: 36
    height: 13
    tab_name: opportunities

  - name: cohorts_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Adoption & Cohorts</h2><p>Cohorts use AI-active days in a trailing 28-day window: Power, Normal, Casual and Non-AI. Movement compares each person with the week before, using complete weeks only. Read movement only when Admin > Data Health shows enough history.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: adoption_cohorts

  - name: newly_active_kpi
    title: "Newly active | last complete week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.newly_active]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
    note_state: collapsed
    note_display: hover
    note_text: "People who were Non-AI or new the week before and are now Casual or above. Cohorts use the trailing 28 days up to the week end."
    listen:
      Department: user_org_unit.department
    row: 4
    col: 0
    width: 18
    height: 5
    tab_name: adoption_cohorts

  - name: moved_up_kpi
    title: "Moved up | last complete week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.moved_up]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
    note_state: collapsed
    note_display: hover
    note_text: "Already-active people who moved to a higher cohort than the week before."
    listen:
      Department: user_org_unit.department
    row: 4
    col: 18
    width: 18
    height: 5
    tab_name: adoption_cohorts

  - name: moved_down_kpi
    title: "Moved down | last complete week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.moved_down]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
    note_state: collapsed
    note_display: hover
    note_text: "People who moved to a lower cohort, including lapsing to Non-AI. See People & Coaching for names."
    listen:
      Department: user_org_unit.department
    row: 4
    col: 36
    width: 18
    height: 5
    tab_name: adoption_cohorts

  - name: unchanged_kpi
    title: "No change | last complete week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.unchanged]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
    note_state: collapsed
    note_display: hover
    note_text: "People whose cohort was the same as the week before."
    listen:
      Department: user_org_unit.department
    row: 4
    col: 54
    width: 18
    height: 5
    tab_name: adoption_cohorts

  - name: cohort_cards
    title: "Current cohort mix | eligible people, last 28 days"
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
    listen:
      Department: user_org_unit.department
    row: 9
    col: 0
    width: 36
    height: 10
    tab_name: adoption_cohorts

  - name: cohort_trend
    title: "Cohorts per week | share of eligible people"
    type: looker_area
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
    pivots: [ai_user_cohort_weekly.cohort]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week", "ai_user_cohort_weekly.cohort"]
    limit: 52
    stacking: percent
    show_view_names: false
    y_axis_gridlines: false
    legend_position: center
    series_colors:
      Power - ai_user_cohort_weekly.people: "#174EA6"
      Normal - ai_user_cohort_weekly.people: "#1A73E8"
      Casual - ai_user_cohort_weekly.people: "#8AB4F8"
      Non-AI - ai_user_cohort_weekly.people: "#BDC1C6"
    listen:
      Department: user_org_unit.department
    row: 9
    col: 36
    width: 36
    height: 10
    tab_name: adoption_cohorts

  - name: cohort_movement
    title: "Cohort movement per week | people who changed cohort"
    type: looker_column
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.newly_active, ai_user_cohort_weekly.moved_up, ai_user_cohort_weekly.moved_down]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week"]
    limit: 26
    show_view_names: false
    y_axis_gridlines: false
    legend_position: center
    series_colors:
      ai_user_cohort_weekly.newly_active: "#1A73E8"
      ai_user_cohort_weekly.moved_up: "#188038"
      ai_user_cohort_weekly.moved_down: "#D93025"
    series_labels:
      ai_user_cohort_weekly.newly_active: "Newly active"
      ai_user_cohort_weekly.moved_up: "Moved up"
      ai_user_cohort_weekly.moved_down: "Moved down"
    listen:
      Department: user_org_unit.department
    row: 19
    col: 0
    width: 36
    height: 11
    tab_name: adoption_cohorts

  - name: cohort_by_department
    title: "Cohort mix by department | share of eligible people"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.cohort, ai_user_profile.people]
    pivots: [ai_user_profile.cohort]
    sorts: ["ai_user_profile.cohort", "ai_user_profile.people desc 0"]
    limit: 20
    stacking: percent
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: false
    legend_position: center
    series_colors:
      Power - ai_user_profile.people: "#174EA6"
      Normal - ai_user_profile.people: "#1A73E8"
      Casual - ai_user_profile.people: "#8AB4F8"
      Non-AI - ai_user_profile.people: "#BDC1C6"
    listen:
      Department: user_org_unit.department
    row: 19
    col: 36
    width: 36
    height: 11
    tab_name: adoption_cohorts

  - name: use_cases_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Use Cases</h2><p>Feature telemetry is grouped into a business-facing taxonomy. Unclassified activity is explicit so gaps in event mapping are visible. Use cases count active actions only: automated workflow runs and proactive suggestions are shown separately as passive events.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: use_cases

  - name: use_case_actions
    title: "AI actions by use case | hands-on only"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_case, ai_activity_hourly.ai_actions]
    sorts: ["ai_activity_hourly.ai_actions desc"]
    limit: 15
    show_value_labels: true
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: false
    legend_position: none
    series_colors:
      ai_activity_hourly.ai_actions: "#1a73e8"
    note_state: collapsed
    note_display: hover
    note_text: "Hands-on AI actions by eligible people in the selected dates. Automated Flow runs and proactive suggestions are excluded."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 9
    col: 0
    width: 36
    height: 11
    tab_name: use_cases

  - name: use_case_people
    title: "People per use case | hands-on only"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_case, ai_activity_hourly.ai_users]
    sorts: ["ai_activity_hourly.ai_users desc"]
    limit: 15
    show_value_labels: true
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: false
    legend_position: none
    series_colors:
      ai_activity_hourly.ai_users: "#174EA6"
    note_state: collapsed
    note_display: hover
    note_text: "Distinct eligible people with at least one hands-on action in each use case in the selected dates. One person can appear in several use cases."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 9
    col: 36
    width: 36
    height: 11
    tab_name: use_cases

  - name: unclassified_share
    title: "Unclassified Action Share"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.unclassified_action_share, ai_activity_hourly.unclassified_actions, ai_activity_hourly.ai_actions]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 0
    width: 18
    height: 5
    tab_name: use_cases

  - name: use_cases_used
    title: "Use Cases Used"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.use_cases_used]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 18
    width: 18
    height: 5
    tab_name: use_cases

  - name: passive_share
    title: "Passive Share of AI Events"
    note_display: hover
    note_text: "Automated workflow and agent runs plus proactive suggestions, as a share of all Gemini events. These are excluded from adoption metrics."
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.passive_event_share]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 36
    width: 18
    height: 5
    tab_name: use_cases

  - name: automation_users
    title: "People Using Automation"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.automation_users]
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 4
    col: 54
    width: 18
    height: 5
    tab_name: use_cases

  - name: interaction_mode_trend
    title: "Weekly AI Events | active vs passive"
    note_display: hover
    note_text: "Active: a person asked Gemini. Automated: workflows and scheduled or triggered agents. Proactive: suggestions Gemini made unprompted."
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.interaction_mode, ai_activity_hourly.ai_events]
    filters:
      ai_activity_hourly.is_complete_week: "Yes"
    pivots: [ai_activity_hourly.interaction_mode]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: ["ai_activity_hourly.event_week", "ai_activity_hourly.interaction_mode"]
    limit: 26
    stacking: normal
    series_colors:
      Active: "#1a73e8"
      Automated: "#9aa0a6"
      Proactive: "#dadce0"
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 31
    col: 0
    width: 72
    height: 10
    tab_name: use_cases

  - name: use_case_trend
    title: "Weekly AI Actions by Use Case"
    type: looker_area
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.use_case, ai_activity_hourly.ai_actions]
    filters:
      ai_activity_hourly.is_complete_week: "Yes"
    pivots: [ai_activity_hourly.use_case]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: ["ai_activity_hourly.event_week"]
    limit: 26
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 20
    col: 0
    width: 36
    height: 11
    tab_name: use_cases

  - name: feature_mapping
    title: "Feature to Use-Case Mapping"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.product, ai_activity_hourly.feature_label, ai_activity_hourly.feature, ai_activity_hourly.use_case, ai_activity_hourly.use_case_confidence, ai_activity_hourly.ai_actions]
    hidden_fields: [ai_activity_hourly.feature]
    show_view_names: false
    sorts: ["ai_activity_hourly.ai_actions desc"]
    limit: 50
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 20
    col: 36
    width: 36
    height: 11
    tab_name: use_cases

  - name: people_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>People & Coaching</h2><p>Use individual rows only for authorised coaching and change-management follow-up. Activity volume is not a productivity score.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: people_coaching

  - name: potential_champions
    title: "Potential Champions"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.cohort, ai_user_profile.ai_days_28d, ai_user_profile.ai_actions_28d, ai_user_profile.product_mix]
    filters:
      ai_user_profile.cohort: "Power,Normal"
    sorts: ["ai_user_profile.ai_days_28d desc"]
    limit: 50
    listen:
      Department: user_org_unit.department
    row: 4
    col: 0
    width: 36
    height: 12
    tab_name: people_coaching

  - name: ready_to_move_up
    title: "Ready to Move Up | casual users"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.cohort, ai_user_profile.ai_days_28d, ai_user_profile.ai_actions_28d, ai_user_profile.last_ai_date]
    filters:
      ai_user_profile.cohort: "Casual"
    sorts: ["ai_user_profile.ai_days_28d desc"]
    limit: 50
    listen:
      Department: user_org_unit.department
    row: 4
    col: 36
    width: 36
    height: 12
    tab_name: people_coaching

  - name: moved_down
    title: "At Risk | moved down a cohort"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.user_email, user_org_unit.department, ai_user_cohort_weekly.previous_cohort, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.ai_days]
    filters:
      ai_user_cohort_weekly.is_latest_week: "yes"
      ai_user_cohort_weekly.cohort_movement: "Moved down"
    sorts: ["ai_user_cohort_weekly.ai_days"]
    limit: 50
    listen:
      Department: user_org_unit.department
    row: 16
    col: 0
    width: 36
    height: 12
    tab_name: people_coaching

  - name: licence_request_list
    title: "Users Asking for a Licence"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_licenses
    fields: [ge_user_licenses.user_email, ge_user_licenses.location, ge_user_licenses.last_login_date, ge_user_licenses.license_state]
    filters:
      ge_user_licenses.is_latest_snapshot: "yes"
      ge_user_licenses.license_state: "NO_LICENSE_ATTEMPTED_LOGIN"
    sorts: ["ge_user_licenses.last_login_date desc"]
    limit: 50
    row: 16
    col: 36
    width: 36
    height: 12
    tab_name: people_coaching

  - name: interventions_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Interventions</h2><p>Measure, intervene, then re-measure. Log each action as a row in the <code>ai_interventions</code> BigQuery table: name, start_date, target_scope_type (department, email_list or organisation), target_scope, owner, status (planned, active, complete or cancelled) and follow_up_date. Set <code>opportunity_type</code> to the code from the opportunity queue (for example <code>expand_department_adoption</code>) so the queue shows its owner and status. After the follow-up, record <code>outcome</code> (improved, no_change, worse or too_early) and <code>outcome_notes</code>. Before/after comparisons are directional, not causal proof. The block README describes loading rows from a Google Sheet.</p>"
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: interventions

  - name: open_interventions
    title: "Open Interventions"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_interventions
    fields: [ai_interventions.name, ai_interventions.owner_or_unassigned, ai_interventions.target_scope, ai_interventions.status, ai_interventions.follow_up_date, ai_interventions.is_overdue]
    show_view_names: false
    show_row_numbers: false
    size_to_fit: true
    series_labels:
      ai_interventions.owner_or_unassigned: "Owner"
      ai_interventions.target_scope: "Target"
      ai_interventions.follow_up_date: "Follow-up due"
      ai_interventions.is_overdue: "Overdue"
    filters:
      ai_interventions.status: "planned,active"
    sorts: ["ai_interventions.follow_up_date"]
    limit: 50
    row: 5
    col: 0
    width: 36
    height: 12
    tab_name: interventions

  - name: impact_comparison
    title: "Before/After Intervention Comparison"
    type: looker_grid
    model: gemini_enterprise
    explore: intervention_impact
    fields: [intervention_impact.intervention_id, intervention_impact.comparison_group, intervention_impact.period, intervention_impact.people, intervention_impact.activation_rate, intervention_impact.regular_adoption_rate, intervention_impact.ai_active_days, intervention_impact.ai_actions, intervention_impact.caution]
    sorts: ["intervention_impact.intervention_id", "intervention_impact.comparison_group", "intervention_impact.period"]
    limit: 100
    row: 5
    col: 36
    width: 36
    height: 12
    tab_name: interventions

  - name: validated_outcomes
    title: "Validated Business Outcomes"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_value_outcomes
    fields: [ai_value_outcomes.scope, ai_value_outcomes.metric, ai_value_outcomes.unit, ai_value_outcomes.outcome_value, ai_value_outcomes.source]
    sorts: ["ai_value_outcomes.outcome_value desc"]
    limit: 50
    row: 17
    col: 0
    width: 36
    height: 12
    tab_name: interventions

  - name: intervention_timeline
    title: "Interventions and outcomes"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_interventions
    fields: [ai_interventions.name, ai_interventions.start_date, ai_interventions.follow_up_date, ai_interventions.status, ai_interventions.outcome, ai_interventions.outcome_notes]
    show_view_names: false
    show_row_numbers: false
    size_to_fit: true
    sorts: ["ai_interventions.start_date desc"]
    limit: 100
    row: 17
    col: 36
    width: 36
    height: 12
    tab_name: interventions

  - name: intervention_start_markers
    title: "Intervention Start Markers"
    type: looker_column
    model: gemini_enterprise
    explore: ai_interventions
    fields: [ai_interventions.start_week, ai_interventions.interventions]
    fill_fields: [ai_interventions.start_week]
    sorts: ["ai_interventions.start_week"]
    limit: 52
    row: 29
    col: 0
    width: 36
    height: 9
    tab_name: interventions

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
