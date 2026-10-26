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
        <div style="margin-top:8px;font-size:12px;"><a style="color:#D2E3FC;" href="/dashboards/gemini_enterprise::gemini_ai_executive">Executive dashboard</a> &nbsp;|&nbsp; <a style="color:#D2E3FC;" href="/dashboards/gemini_enterprise::gemini_ai_change">Change dashboard</a></div>
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
    body_text: "<h2>Workspace Gemini</h2><p>Raw Workspace audit telemetry for the selected dates, not limited to the eligible population. <b>Active</b> means a person asked Gemini to do something, <b>Automated</b> means a Workspace Flow ran on its own, and <b>Proactive</b> means Gemini surfaced a suggestion unprompted. Shares here are event-based, not people activation rates.</p>"
    row: 0
    col: 0
    width: 72
    height: 4
    tab_name: workspace

  - name: ws_users
    title: "People with any Workspace Gemini event"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_users]
    note_state: collapsed
    note_display: hover
    note_text: "Distinct people with any Workspace Gemini event in the selected dates, including people who were only shown suggestions."
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 0
    width: 18
    height: 6
    tab_name: workspace

  - name: ws_engaged
    title: "People using it hands-on"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.engaged_users]
    note_state: collapsed
    note_display: hover
    note_text: "Distinct people with at least one Active event in the selected dates. Automated Flow runs and proactive suggestions do not count."
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 18
    width: 18
    height: 6
    tab_name: workspace

  - name: ws_active_share
    title: "Hands-on share of events"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_usage_rate]
    note_state: collapsed
    note_display: hover
    note_text: "Active events divided by all Workspace Gemini events in the selected dates. Most events are proactive suggestions, so this is low even when people use Gemini daily."
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 36
    width: 18
    height: 6
    tab_name: workspace

  - name: ws_automated
    title: "Automated Flow events"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.automated_events]
    note_state: collapsed
    note_display: hover
    note_text: "Workspace Flow runs and steps in the selected dates. Reported separately because they run without a person."
    listen:
      Date: workspace_gemini_activity.event_date
    row: 4
    col: 54
    width: 18
    height: 6
    tab_name: workspace

  - name: ws_by_app
    title: "Events by app | active, automated, proactive"
    type: looker_bar
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.interaction_mode, workspace_gemini_activity.events]
    pivots: [workspace_gemini_activity.interaction_mode]
    sorts: ["workspace_gemini_activity.interaction_mode", "workspace_gemini_activity.events desc 0"]
    limit: 15
    stacking: normal
    show_view_names: false
    y_axis_gridlines: false
    legend_position: center
    series_colors:
      Active - workspace_gemini_activity.events: "#1a73e8"
      Automated - workspace_gemini_activity.events: "#9aa0a6"
      Proactive - workspace_gemini_activity.events: "#dadce0"
    listen:
      Date: workspace_gemini_activity.event_date
    row: 10
    col: 0
    width: 36
    height: 12
    tab_name: workspace

  - name: ws_funnel
    title: "Shown vs used | people per feature"
    type: looker_grid
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.feature_label, workspace_gemini_activity.surfaced_users, workspace_gemini_activity.acting_users, workspace_gemini_activity.uptake_rate]
    filters:
      workspace_gemini_activity.surfaced_users: ">0"
    sorts: ["workspace_gemini_activity.surfaced_users desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    size_to_fit: true
    series_labels:
      workspace_gemini_activity.app_name: "App"
      workspace_gemini_activity.feature_label: "Feature"
      workspace_gemini_activity.surfaced_users: "Shown to"
      workspace_gemini_activity.acting_users: "Used by"
    series_cell_visualizations:
      workspace_gemini_activity.uptake_rate:
        is_active: true
    note_state: collapsed
    note_display: hover
    note_text: "People Gemini proactively showed each feature to, and people who then used it hands-on, in the selected dates. Uptake can exceed 100% when people open the feature directly."
    listen:
      Date: workspace_gemini_activity.event_date
    row: 10
    col: 36
    width: 36
    height: 12
    tab_name: workspace

  - name: ws_features
    title: "Most-used features | hands-on"
    type: looker_grid
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.feature_label, workspace_gemini_activity.active_events, workspace_gemini_activity.engaged_users]
    filters:
      workspace_gemini_activity.active_events: ">0"
    sorts: ["workspace_gemini_activity.active_events desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    size_to_fit: true
    series_labels:
      workspace_gemini_activity.app_name: "App"
      workspace_gemini_activity.feature_label: "Feature"
      workspace_gemini_activity.active_events: "Hands-on events"
      workspace_gemini_activity.engaged_users: "People"
    listen:
      Date: workspace_gemini_activity.event_date
    row: 22
    col: 0
    width: 72
    height: 10
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
    fields: [ge_user_activity.model_label, ge_user_activity.prompts]
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
    title: "Tools the assistant calls | by connector"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.tool_label, ge_tool_calls.tool_calls]
    sorts: ["ge_tool_calls.tool_calls desc"]
    limit: 15
    show_view_names: false
    legend_position: none
    listen:
      Date: ge_tool_calls.event_date
    row: 27
    col: 36
    width: 36
    height: 10
    tab_name: ge_analytics

  - name: tokens_by_agent
    title: "Tokens by agent | main assistant and sub-agents"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.agent_label, ge_model_calls.total_tokens]
    sorts: ["ge_model_calls.total_tokens desc"]
    limit: 15
    show_view_names: false
    legend_position: none
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
        <p><strong>Active vs passive:</strong> an active action is something a person asked Gemini to do. Passive events are automated (workflow and scheduled or triggered agent runs) or proactive (suggestions Gemini made unprompted). AI-active days, cohorts and every adoption rate count active actions only. Time saved also counts automated runs, once per run.</p>
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

  - name: methodology_log
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family:'Google Sans',Arial,sans-serif;line-height:1.5;">
        <h2>Methodology changes</h2>
        <p style="color:#5f6368">Changes to how the block calculates its metrics. If a figure moved sharply after an update, check here before reading it as a real change in adoption. Your own install settings are listed in the Setup settings table above.</p>
        <table style="border-collapse:collapse;width:100%;font-size:13px">
          <tr style="text-align:left;border-bottom:1px solid #dadce0"><th style="padding:4px 8px">Date</th><th style="padding:4px 8px">Change</th><th style="padding:4px 8px">Effect on figures</th></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Cohort movement separates Newly active (Non-AI or new, now active) from Moved up (already active, now a higher cohort).</td><td style="padding:4px 8px">Moved up falls. People starting to use AI are counted as Newly active instead.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Workspace admin tab counts automated Flow runs separately. Hands-on share and Engaged users exclude them.</td><td style="padding:4px 8px">Hands-on share and Engaged users fall where Flows run.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">People in the top-level org unit or with no org unit are one data-quality item in the opportunity queue, not a department.</td><td style="padding:4px 8px">The "(Top level)" group no longer appears as a training target.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Time benefit headline counts active actions only. Automated runs moved to a separate, lower-confidence estimate. Figures shown per month.</td><td style="padding:4px 8px">Headline hours fall where workflows are used. Totals over long windows no longer look larger simply because the window is longer.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Events split into Active, Automated and Proactive. AI actions, AI-active days, cohorts and adoption rates count Active only.</td><td style="padding:4px 8px">AI action counts fall sharply where workflows run. People-based rates usually move little.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Weekly trends show complete weeks only.</td><td style="padding:4px 8px">The current week no longer appears as a drop.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">26 Oct 2026</td><td style="padding:4px 8px">Default use-case and minutes-saved mappings cover Workspace feature names. Unnamed Workspace events are labelled by app (for example workflows_unspecified).</td><td style="padding:4px 8px">Unclassified share falls. Time benefit for Workspace features starts counting.</td></tr>
          <tr style="border-bottom:1px solid #f1f3f4"><td style="padding:4px 8px">25 Oct 2026</td><td style="padding:4px 8px">Employee scope (employee domains, excluded org units, excluded email pattern) applied to every adoption rate.</td><td style="padding:4px 8px">Denominators change: guests, external users and service accounts drop out.</td></tr>
          <tr><td style="padding:4px 8px">25 Oct 2026</td><td style="padding:4px 8px">Cross-product adoption includes Gemini for Workspace when the Workspace audit export is configured.</td><td style="padding:4px 8px">Active people and actions rise sharply once the export is set up. Before that, adoption reflected Gemini Enterprise only.</td></tr>
        </table>
      </div>
    row: 46
    col: 0
    width: 72
    height: 18
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
