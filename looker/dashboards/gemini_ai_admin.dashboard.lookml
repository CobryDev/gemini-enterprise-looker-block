- dashboard: gemini_ai_admin
  title: Gemini | Admin AI Telemetry
  preferred_viewer: dashboards-next
  description: "Administrative product telemetry, governance and setup health for Gemini AI Adoption."
  layout: newspaper
  layout_granularity: granular
  tabs:
  - name: ge_analytics
    label: "Gemini Enterprise"
  - name: workspace
    label: "Workspace Gemini"
  - name: antigravity
    label: "Antigravity"
  - name: governance
    label: "Governance"
  - name: data_health
    label: "Data Health"
  elements:
  - name: header_admin
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background:#174EA6;border-radius:8px;padding:18px 24px;font-family:'Google Sans',Arial,sans-serif;color:#fff;">
        <div style="font-size:12px;text-transform:uppercase;letter-spacing:1.5px;opacity:.75;">Gemini AI Adoption</div>
        <div style="font-size:26px;font-weight:600;">Admin AI Telemetry</div>
        <div style="font-size:13px;opacity:.85;">Product analytics, technical diagnostics, governance and data health.</div>
        <div style="margin-top:8px;font-size:12px;"><a style="color:#D2E3FC;" href="/dashboards/gemini_ai_executive">Executive dashboard</a> &nbsp;|&nbsp; <a style="color:#D2E3FC;" href="/dashboards/gemini_ai_change">Change dashboard</a></div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: ge_analytics

  - name: ge_daily_active_seats
    title: "Daily Active / Seats Claimed (Google export)"
    type: single_value
    model: gemini_enterprise
    explore: adoption
    fields: [adoption.adoption_rate, adoption.metric_month]
    fill_fields: [adoption.metric_month]
    sorts: ["adoption.metric_month desc"]
    limit: 12
    listen:
      Date: adoption.metric_date
    row: 5
    col: 0
    width: 18
    height: 7
    tab_name: ge_analytics

  - name: ge_answers
    title: "Assistant Answers"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.answers]
    listen:
      Date: activity.metric_date
    row: 5
    col: 18
    width: 18
    height: 7
    tab_name: ge_analytics

  - name: ge_searches
    title: "Searches"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.searches]
    listen:
      Date: activity.metric_date
    row: 5
    col: 36
    width: 18
    height: 7
    tab_name: ge_analytics

  - name: ge_agents
    title: "Distinct Agents Used"
    type: single_value
    model: gemini_enterprise
    explore: agents
    fields: [agents.agent_count]
    listen:
      Date: agents.metric_date
    row: 5
    col: 54
    width: 18
    height: 7
    tab_name: ge_analytics

  - name: ge_active_trend
    title: "Daily, Weekly and Monthly Active Users"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.daily_active_users, active_users.weekly_active_users, active_users.monthly_active_users]
    sorts: ["active_users.metric_date"]
    limit: 180
    listen:
      Date: active_users.metric_date
    row: 12
    col: 0
    width: 36
    height: 11
    tab_name: ge_analytics

  - name: ge_seats_trend
    title: "Seats Purchased vs Claimed"
    type: looker_area
    model: gemini_enterprise
    explore: seats
    fields: [seats.metric_date, seats.seats_purchased, seats.seats_claimed]
    sorts: ["seats.metric_date"]
    limit: 180
    listen:
      Date: seats.metric_date
    row: 12
    col: 36
    width: 36
    height: 11
    tab_name: ge_analytics

  - name: ws_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Workspace Gemini</h2><p>Workspace event telemetry. The active-share metric is event-based, not a people activation rate.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: workspace

  - name: ws_users
    title: "Gemini Users"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_users]
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 0
    width: 18
    height: 7
    tab_name: workspace

  - name: ws_engaged
    title: "Engaged Users"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.engaged_users]
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 18
    width: 18
    height: 7
    tab_name: workspace

  - name: ws_active_share
    title: "Active Share of Workspace Gemini Events"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_usage_rate]
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 36
    width: 18
    height: 7
    tab_name: workspace

  - name: ws_by_app
    title: "Usage by App"
    type: looker_bar
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.events, workspace_gemini_activity.active_events]
    sorts: ["workspace_gemini_activity.events desc"]
    limit: 20
    listen:
      Date: workspace_gemini_activity.event_date
    row: 11
    col: 0
    width: 36
    height: 11
    tab_name: workspace

  - name: ws_features
    title: "Top Features"
    type: looker_grid
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.feature_source, workspace_gemini_activity.events, workspace_gemini_activity.active_events, workspace_gemini_activity.active_users]
    sorts: ["workspace_gemini_activity.events desc"]
    limit: 50
    listen:
      Date: workspace_gemini_activity.event_date
    row: 11
    col: 36
    width: 36
    height: 11
    tab_name: workspace

  - name: models_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Agents & Models</h2><p>Technical diagnostic measures for model routing, agents, tools and tokens.</p>"
    row: 23
    col: 0
    width: 72
    height: 4
    tab_name: ge_analytics

  - name: prompts_by_model
    title: "Prompts by Model"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.model, ge_user_activity.prompts]
    sorts: ["ge_user_activity.prompts desc"]
    limit: 20
    listen:
      Date: ge_user_activity.event_date
      App: ge_user_activity.app_name
    row: 27
    col: 0
    width: 36
    height: 10
    tab_name: ge_analytics

  - name: tools_called
    title: "Tools the Assistant Calls"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.tool_name, ge_tool_calls.tool_calls]
    sorts: ["ge_tool_calls.tool_calls desc"]
    limit: 20
    listen:
      Date: ge_tool_calls.event_date
    row: 27
    col: 36
    width: 36
    height: 10
    tab_name: ge_analytics

  - name: tokens_by_agent
    title: "Tokens by Agent"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.agent_name, ge_model_calls.total_tokens]
    sorts: ["ge_model_calls.total_tokens desc"]
    limit: 20
    listen:
      Date: ge_model_calls.event_date
    row: 37
    col: 0
    width: 36
    height: 10
    tab_name: ge_analytics

  - name: hourly_actions
    title: "AI Actions by Local Hour"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_local_hour_of_day, ai_activity_hourly.ai_actions]
    sorts: ["ai_activity_hourly.event_local_hour_of_day"]
    limit: 24
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
    row: 37
    col: 36
    width: 36
    height: 10
    tab_name: ge_analytics

  - name: ag_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Antigravity</h2><p>Shown as an administrative view because many tenants will have no activity until Antigravity telemetry is configured and used.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: antigravity

  - name: ag_requests
    title: "Inference Requests"
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.requests]
    listen:
      Date: antigravity_usage.event_date
    row: 4
    col: 0
    width: 18
    height: 7
    tab_name: antigravity

  - name: ag_users
    title: "Antigravity Users"
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.users]
    listen:
      Date: antigravity_usage.event_date
    row: 4
    col: 18
    width: 18
    height: 7
    tab_name: antigravity

  - name: ag_by_experience
    title: "Requests by Experience"
    type: looker_bar
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.experience, antigravity_usage.requests]
    sorts: ["antigravity_usage.requests desc"]
    limit: 20
    listen:
      Date: antigravity_usage.event_date
    row: 11
    col: 0
    width: 36
    height: 10
    tab_name: antigravity

  - name: governance_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Governance</h2><p>Zero flags mean no flags were recorded by configured sources; they do not prove zero risk.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: governance

  - name: safety_flags
    title: "Safety Flags"
    type: single_value
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.flagged_interactions]
    listen:
      Date: ge_safety_events.event_date
    row: 4
    col: 0
    width: 18
    height: 7
    tab_name: governance

  - name: safety_by_category
    title: "Flags by Category"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.category, ge_safety_events.category_matches]
    sorts: ["ge_safety_events.category_matches desc"]
    limit: 20
    listen:
      Date: ge_safety_events.event_date
    row: 11
    col: 0
    width: 36
    height: 10
    tab_name: governance

  - name: admin_changes
    title: "Recent Admin Changes"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_admin_events
    fields: [ge_admin_events.event_time_time, ge_admin_events.principal_email, ge_admin_events.method, ge_admin_events.resource_name]
    sorts: ["ge_admin_events.event_time_time desc"]
    limit: 50
    listen:
      Date: ge_admin_events.event_date
    row: 4
    col: 36
    width: 36
    height: 17
    tab_name: governance

  - name: health_header
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: "<h2>Data Health</h2><p>Source freshness, setup state, population scoping and install settings.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: data_health

  - name: data_state_grid
    title: "Reporting Readiness"
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
    tab_name: data_health

  - name: setup_tables
    title: "Gemini Analytics Tables"
    type: looker_grid
    model: gemini_enterprise
    explore: setup_health_tables
    fields: [setup_health_tables.table_id, setup_health_tables.status, setup_health_tables.row_count, setup_health_tables.last_modified_time, setup_health_tables.next_step]
    sorts: ["setup_health_tables.sort_order"]
    limit: 20
    row: 4
    col: 36
    width: 36
    height: 12
    tab_name: data_health

  - name: population_scope
    title: "Population Scope"
    type: looker_grid
    model: gemini_enterprise
    explore: population_scope
    fields: [population_scope.scope_reason, population_scope.people_seen]
    sorts: ["population_scope.people_seen desc"]
    limit: 20
    row: 16
    col: 0
    width: 36
    height: 10
    tab_name: data_health

  - name: setup_settings
    title: "Install Settings"
    type: looker_grid
    model: gemini_enterprise
    explore: setup_settings
    fields: [setup_settings.setting, setup_settings.value]
    sorts: ["setup_settings.sort_order"]
    limit: 50
    row: 16
    col: 36
    width: 36
    height: 10
    tab_name: data_health

  - name: definitions_card
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family:'Google Sans',Arial,sans-serif;line-height:1.55;">
        <h2>Definitions</h2>
        <p><strong>Activation:</strong> eligible people with at least one AI-active day in the last 28 days, divided by eligible people in scope.</p>
        <p><strong>Regular adoption:</strong> eligible people with at least the Normal user threshold of AI-active days (default 4) in the last 28 days, divided by eligible people in scope.</p>
        <p><strong>Engagement:</strong> distinct AI-active days per active user.</p>
        <p><strong>Retention:</strong> people active in the previous 28-day window who returned in the current 28-day window.</p>
        <p><strong>Google export metric:</strong> Daily Active / Seats Claimed is product telemetry from the Gemini Enterprise export and has a different denominator from employee activation.</p>
        <p><strong>Estimated value:</strong> value actions multiplied by configured minutes-saved assumptions. It is not a validated financial return.</p>
      </div>
    row: 26
    col: 0
    width: 72
    height: 20
    tab_name: data_health

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
  - name: App
    title: "Gemini Enterprise App"
    type: field_filter
    model: gemini_enterprise
    explore: ge_user_activity
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    listens_to_filters: []
    field: ge_user_activity.app_name
