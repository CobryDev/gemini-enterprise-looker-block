- dashboard: gemini_ai_adoption
  title: Gemini | AI Adoption
  preferred_viewer: dashboards-next
  description: "AI adoption across Gemini Enterprise, Gemini for Workspace and Antigravity: activation, cohorts, leaderboards, models, ROI and change-management target lists."
  layout: newspaper
  layout_granularity: granular
  tabs:
  - name: overview
    label: "Executive Overview"
  - name: cohorts
    label: "Cohorts & Movement"
  - name: people
    label: "People & Leaderboards"
  - name: models
    label: "Models & Time of Day"
  - name: features
    label: "Features & Agents"
  - name: roi
    label: "ROI & Value"
  - name: targeting
    label: "Change Targeting"
  - name: safety
    label: "Safety & Governance"
  - name: antigravity
    label: Antigravity
  - name: ge_analytics
    label: "Gemini Enterprise Analytics"
  - name: workspace
    label: "Workspace Gemini"
  - name: setup
    label: "Setup Health"
  - name: about
    label: "About this Dashboard"
  elements:

  # ---------- Tab: overview ----------
  - name: header_overview
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Executive Overview</div>
          <div style="font-size: 13px; opacity: 0.85;">Who uses AI, in which products, and is it growing?</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: overview

  - name: ov_ai_users
    title: "AI Active Users"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.ai_users, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People with at least one AI action in Gemini Enterprise, Gemini for Workspace or Antigravity in the period. Bars show each month."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: overview

  - name: ov_ai_actions
    title: "AI Actions"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.ai_actions, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Prompts and searches in Gemini Enterprise, active Gemini events in Workspace apps, and Antigravity requests."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: overview

  - name: ov_hours_saved
    title: "Estimated Hours Saved"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "AI actions times the minutes-saved-per-action install setting. An estimate, not a measurement."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: overview

  - name: ov_daily_users
    title: "Avg Daily AI Users"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.average_daily_ai_users, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: overview

  - name: ov_ai_activation
    title: "AI Activation (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.ai_activation_rate, ai_user_profile.ai_active_users]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "AI active users"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "AI active users divided by everyone in the population: Workspace users seen in the last 28 days, licensed Gemini Enterprise users and anyone who used AI. Rolling 28 days."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 0
    width: 18
    height: 8
    tab_name: overview

  - name: ov_gws_activation
    title: "Workspace Gemini Activation (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.gws_activation_rate, ai_user_profile.gws_active_users]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "Workspace Gemini users"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Workspace users with an active Gemini event (generate, converse, summarise) divided by Workspace users seen in the audit log. Needs workspace_export = same_region."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 18
    width: 18
    height: 8
    tab_name: overview

  - name: ov_ge_activation
    title: "Gemini Enterprise Activation (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.ge_activation_rate, ai_user_profile.ge_licensed_users]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "licensed users"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Licensed Gemini Enterprise users who prompted or searched in the last 28 days, divided by licensed users."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 36
    width: 18
    height: 8
    tab_name: overview

  - name: ov_adopter_share
    title: "Power + Normal Users (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.adopter_share, ai_user_profile.people]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "people in scope"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Share of the population using AI on 4 or more days in the last 28 (the Normal threshold install setting)."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 54
    width: 18
    height: 8
    tab_name: overview

  - name: ov_weekly_overlap
    title: "Weekly AI Users | Gemini Enterprise Only, Workspace Only, Both"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.users_ge_only, ai_activity_hourly.users_gws_only, ai_activity_hourly.users_ge_and_gws]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: [ai_activity_hourly.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      ai_activity_hourly.users_ge_only: "#1A73E8"
      ai_activity_hourly.users_gws_only: "#12B5CB"
      ai_activity_hourly.users_ge_and_gws: "#174EA6"
    series_labels:
      ai_activity_hourly.users_ge_only: "Gemini Enterprise only"
      ai_activity_hourly.users_gws_only: "Workspace Gemini only"
      ai_activity_hourly.users_ge_and_gws: Both
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People who used AI each week, split by whether they used Gemini Enterprise, Gemini for Workspace or both. Antigravity-only users aren't in this split."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 21
    col: 0
    width: 72
    height: 15
    tab_name: overview

  - name: ov_product_mix
    title: "Product Mix (28d)"
    type: looker_pie
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.product_mix, ai_user_profile.people]
    sorts: [ai_user_profile.product_mix]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    series_colors:
      Both: "#174EA6"
      "Gemini Enterprise only": "#1A73E8"
      "Workspace Gemini only": "#12B5CB"
      Neither: "#DADCE0"
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People by which products they used in the last 28 days. Neither is licensed or Workspace users with no AI use."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 36
    col: 0
    width: 18
    height: 15
    tab_name: overview

  - name: ov_actions_by_product
    title: "Weekly AI Actions by Product"
    type: looker_area
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.product, ai_activity_hourly.ai_actions]
    pivots: [ai_activity_hourly.product]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: [ai_activity_hourly.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Gemini Enterprise - ai_activity_hourly.ai_actions": "#1A73E8"
      "Gemini for Workspace - ai_activity_hourly.ai_actions": "#12B5CB"
      "Antigravity - ai_activity_hourly.ai_actions": "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 36
    col: 18
    width: 54
    height: 15
    tab_name: overview

  - name: ov_cohort_trend
    title: "AI Cohorts per Week"
    type: looker_area
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
    pivots: [ai_user_cohort_weekly.cohort]
    sorts: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.cohort]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Power - ai_user_cohort_weekly.people": "#174EA6"
      "Normal - ai_user_cohort_weekly.people": "#1A73E8"
      "Casual - ai_user_cohort_weekly.people": "#8AB4F8"
      "Non-AI - ai_user_cohort_weekly.people": "#DADCE0"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Cohort of each person at the end of each week from their trailing 28 days. Power: 12+ AI days by default. Normal: 4+. Casual: 1+. Non-AI: none. Thresholds are install settings."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 51
    col: 0
    width: 36
    height: 15
    tab_name: overview

  - name: ov_depth
    title: "Monthly Stickiness and Actions per AI User"
    type: looker_line
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_month, ai_activity_hourly.stickiness, ai_activity_hourly.actions_per_ai_user]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: [ai_activity_hourly.event_month]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ai_activity_hourly.stickiness: "#1A73E8"
      ai_activity_hourly.actions_per_ai_user: "#9334E6"
    series_labels:
      ai_activity_hourly.stickiness: "Stickiness (avg daily / monthly users)"
      ai_activity_hourly.actions_per_ai_user: "Actions per AI user"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ai_activity_hourly.stickiness, id: ai_activity_hourly.stickiness, name: "Stickiness (avg daily / monthly users)"}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ai_activity_hourly.actions_per_ai_user, id: ai_activity_hourly.actions_per_ai_user, name: "Actions per AI user"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 51
    col: 36
    width: 36
    height: 15
    tab_name: overview

  - name: ov_department_scorecard
    title: "Department Scorecard | Last 28 Days"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.people, ai_user_profile.ai_active_users, ai_user_profile.ai_activation_rate, ai_user_profile.power_users, ai_user_profile.normal_users, ai_user_profile.casual_users, ai_user_profile.non_ai_users, ai_user_profile.adopter_share]
    sorts: ["ai_user_profile.people desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: true
    show_row_totals: true
    show_sql_query_menu_options: false
    series_labels:
      user_org_unit.department: Department
      ai_user_profile.people: People
      ai_user_profile.ai_active_users: "AI Active"
      ai_user_profile.ai_activation_rate: "AI Activation"
      ai_user_profile.power_users: Power
      ai_user_profile.normal_users: Normal
      ai_user_profile.casual_users: Casual
      ai_user_profile.non_ai_users: "Non-AI"
      ai_user_profile.adopter_share: "Power + Normal"
    series_cell_visualizations:
      ai_user_profile.people:
        is_active: true
      ai_user_profile.ai_activation_rate:
        is_active: true
      ai_user_profile.adopter_share:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Departments come from the Workspace org unit (workspace_export = same_region); otherwise everyone shows as Unknown."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 66
    col: 0
    width: 72
    height: 15
    tab_name: overview


  # ---------- Tab: cohorts ----------
  - name: header_cohorts
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Cohorts & Movement</div>
          <div style="font-size: 13px; opacity: 0.85;">How many Power, Normal, Casual and Non-AI users there are, and who is moving between them.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: cohorts

  - name: co_adopter_share
    title: "Power + Normal Share | Latest Week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.adopter_share, ai_user_cohort_weekly.week_end_week]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week desc"]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "The big number is the latest completed week; the bars are the weekly history."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: cohorts

  - name: co_moved_up
    title: "Moved Up | Latest Week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.moved_up, ai_user_cohort_weekly.week_end_week]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week desc"]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1E8E3E"
    show_x_axis: true
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People in a higher cohort than the week before."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: cohorts

  - name: co_moved_down
    title: "Moved Down | Latest Week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.moved_down, ai_user_cohort_weekly.week_end_week]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week desc"]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#D93025"
    show_x_axis: true
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People in a lower cohort than the week before: the first sign of someone drifting away."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: cohorts

  - name: co_avg_days
    title: "Avg AI Days in 28 | Latest Week"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.average_ai_days, ai_user_cohort_weekly.week_end_week]
    fill_fields: [ai_user_cohort_weekly.week_end_week]
    sorts: ["ai_user_cohort_weekly.week_end_week desc"]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: cohorts

  - name: co_power_card
    title: "Power Users (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.power_users_card, ai_user_profile.power_users]
    hidden_fields: [ai_user_profile.power_users]
    custom_color_enabled: true
    show_single_value_title: false
    show_comparison: false
    smart_single_value_size: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 0
    width: 18
    height: 9
    tab_name: cohorts

  - name: co_normal_card
    title: "Normal Users (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.normal_users_card, ai_user_profile.normal_users]
    hidden_fields: [ai_user_profile.normal_users]
    custom_color_enabled: true
    show_single_value_title: false
    show_comparison: false
    smart_single_value_size: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 18
    width: 18
    height: 9
    tab_name: cohorts

  - name: co_casual_card
    title: "Casual Users (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.casual_users_card, ai_user_profile.casual_users]
    hidden_fields: [ai_user_profile.casual_users]
    custom_color_enabled: true
    show_single_value_title: false
    show_comparison: false
    smart_single_value_size: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 36
    width: 18
    height: 9
    tab_name: cohorts

  - name: co_non_ai_card
    title: "Non-AI Users (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.non_ai_users_card, ai_user_profile.non_ai_users]
    hidden_fields: [ai_user_profile.non_ai_users]
    custom_color_enabled: true
    show_single_value_title: false
    show_comparison: false
    smart_single_value_size: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 54
    width: 18
    height: 9
    tab_name: cohorts

  - name: co_cohort_trend
    title: "AI Cohorts per Week"
    type: looker_area
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
    pivots: [ai_user_cohort_weekly.cohort]
    sorts: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.cohort]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Power - ai_user_cohort_weekly.people": "#174EA6"
      "Normal - ai_user_cohort_weekly.people": "#1A73E8"
      "Casual - ai_user_cohort_weekly.people": "#8AB4F8"
      "Non-AI - ai_user_cohort_weekly.people": "#DADCE0"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Cohort of each person at the end of each week, from their trailing 28 days. The first four weeks of history undercount."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 22
    col: 0
    width: 72
    height: 15
    tab_name: cohorts

  - name: co_movement
    title: "Cohort Movement per Week"
    type: looker_column
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.moved_up, ai_user_cohort_weekly.moved_down]
    sorts: [ai_user_cohort_weekly.week_end_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ai_user_cohort_weekly.moved_up: "#1E8E3E"
      ai_user_cohort_weekly.moved_down: "#D93025"
    series_labels:
      ai_user_cohort_weekly.moved_up: "Moved up"
      ai_user_cohort_weekly.moved_down: "Moved down"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 37
    col: 0
    width: 36
    height: 15
    tab_name: cohorts

  - name: co_share_trend
    title: "Power + Normal Share and Avg AI Days per Week"
    type: looker_line
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.adopter_share, ai_user_cohort_weekly.average_ai_days]
    sorts: [ai_user_cohort_weekly.week_end_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ai_user_cohort_weekly.adopter_share: "#1A73E8"
      ai_user_cohort_weekly.average_ai_days: "#9334E6"
    series_labels:
      ai_user_cohort_weekly.adopter_share: "Power + Normal share"
      ai_user_cohort_weekly.average_ai_days: "Avg AI days in 28"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ai_user_cohort_weekly.adopter_share, id: ai_user_cohort_weekly.adopter_share, name: "Power + Normal share"}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ai_user_cohort_weekly.average_ai_days, id: ai_user_cohort_weekly.average_ai_days, name: "Avg AI days in 28"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 37
    col: 36
    width: 36
    height: 15
    tab_name: cohorts

  - name: co_by_department
    title: "AI Cohorts by Department (28d)"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.cohort, ai_user_profile.people]
    pivots: [ai_user_profile.cohort]
    sorts: [ai_user_profile.cohort, "ai_user_profile.people desc 0"]
    limit: 25
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: percent
    series_colors:
      "Power - ai_user_profile.people": "#174EA6"
      "Normal - ai_user_profile.people": "#1A73E8"
      "Casual - ai_user_profile.people": "#8AB4F8"
      "Non-AI - ai_user_profile.people": "#DADCE0"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Needs workspace_export = same_region for departments; otherwise everyone shows as Unknown."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 52
    col: 0
    width: 72
    height: 15
    tab_name: cohorts

  - name: co_changes
    title: "Cohort Changes | Latest Week"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.user_email, user_org_unit.department, ai_user_cohort_weekly.cohort_movement, ai_user_cohort_weekly.previous_cohort, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.ai_days]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
      ai_user_cohort_weekly.cohort_movement: "Moved up,Moved down"
    sorts: [ai_user_cohort_weekly.cohort_movement, "ai_user_cohort_weekly.ai_days desc"]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_cohort_weekly.user_email: User
      user_org_unit.department: Department
      ai_user_cohort_weekly.cohort_movement: Movement
      ai_user_cohort_weekly.previous_cohort: "Last Week"
      ai_user_cohort_weekly.cohort: "This Week"
      ai_user_cohort_weekly.ai_days: "AI Days (28d)"
    series_cell_visualizations:
      ai_user_cohort_weekly.ai_days:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Moved up: recognise them. Moved down: check in before they drop off."
    listen:
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 67
    col: 0
    width: 72
    height: 24
    tab_name: cohorts


  # ---------- Tab: people ----------
  - name: header_people
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">People & Leaderboards</div>
          <div style="font-size: 13px; opacity: 0.85;">The most engaged AI users and teams, and how deep their use goes.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: people

  - name: pe_actions_per_user
    title: "Actions per AI User"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.actions_per_ai_user, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: people

  - name: pe_days_per_user
    title: "Active Days per AI User"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.active_days_per_ai_user, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: people

  - name: pe_stickiness
    title: Stickiness
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.stickiness, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Average daily AI users divided by AI users in the period."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: people

  - name: pe_features
    title: "Features Used"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.features_used, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Distinct AI features used across all products."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: people

  - name: pe_department_leaderboard
    title: "Department Leaderboard"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [user_org_unit.department, ai_activity_hourly.ai_users, ai_activity_hourly.ai_actions, ai_activity_hourly.actions_per_ai_user, ai_activity_hourly.active_days_per_ai_user, ai_activity_hourly.hours_saved]
    sorts: ["ai_activity_hourly.actions_per_ai_user desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      user_org_unit.department: Department
      ai_activity_hourly.ai_users: "AI Users"
      ai_activity_hourly.ai_actions: "AI Actions"
      ai_activity_hourly.actions_per_ai_user: "Actions per User"
      ai_activity_hourly.active_days_per_ai_user: "Active Days per User"
      ai_activity_hourly.hours_saved: "Est. Hours Saved"
    series_cell_visualizations:
      ai_activity_hourly.ai_users:
        is_active: true
      ai_activity_hourly.actions_per_ai_user:
        is_active: true
      ai_activity_hourly.hours_saved:
        is_active: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 13
    col: 0
    width: 72
    height: 15
    tab_name: people

  - name: pe_rising
    title: "Moved Up a Cohort | Latest Week"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.user_email, user_org_unit.department, ai_user_cohort_weekly.previous_cohort, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.ai_days]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
      ai_user_cohort_weekly.cohort_movement: "Moved up"
    sorts: ["ai_user_cohort_weekly.ai_days desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_cohort_weekly.user_email: User
      user_org_unit.department: Department
      ai_user_cohort_weekly.previous_cohort: From
      ai_user_cohort_weekly.cohort: To
      ai_user_cohort_weekly.ai_days: "AI Days (28d)"
    series_cell_visualizations:
      ai_user_cohort_weekly.ai_days:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "People to recognise: they moved to a higher cohort in the latest week."
    listen:
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 28
    col: 0
    width: 36
    height: 15
    tab_name: people

  - name: pe_history
    title: "AI Days in Trailing 28 per Week"
    type: looker_line
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.week_end_date, ai_user_cohort_weekly.average_ai_days]
    sorts: [ai_user_cohort_weekly.week_end_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ai_user_cohort_weekly.average_ai_days: "#1A73E8"
    series_labels:
      ai_user_cohort_weekly.average_ai_days: "Avg AI days in 28"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Pick a person in the User filter to see their trajectory. Power starts at 12 days and Normal at 4 by default."
    listen:
      Date: ai_user_cohort_weekly.week_end_date
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 28
    col: 36
    width: 36
    height: 15
    tab_name: people

  - name: pe_user_leaderboard
    title: "AI Leaderboard | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.user_email, user_org_unit.department, ai_user_profile.cohort, ai_activity_hourly.ai_active_days, ai_activity_hourly.features_used, ai_activity_hourly.ge_actions, ai_activity_hourly.gws_actions, ai_activity_hourly.antigravity_actions, ai_activity_hourly.hours_saved, ai_activity_hourly.ai_actions]
    sorts: ["ai_activity_hourly.ai_actions desc"]
    limit: 50
    dynamic_fields:
    - {category: table_calculation, table_calculation: rank, label: Rank, expression: "row()", value_format_name: decimal_0, _kind_hint: measure, _type_hint: number}
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_activity_hourly.user_email: User
      user_org_unit.department: Department
      ai_user_profile.cohort: "Cohort (28d)"
      ai_activity_hourly.ai_active_days: "Active Days"
      ai_activity_hourly.features_used: Features
      ai_activity_hourly.ge_actions: "Gemini Enterprise"
      ai_activity_hourly.gws_actions: "Workspace Gemini"
      ai_activity_hourly.antigravity_actions: Antigravity
      ai_activity_hourly.hours_saved: "Est. Hours Saved"
      ai_activity_hourly.ai_actions: "AI Actions"
    series_cell_visualizations:
      ai_activity_hourly.ai_active_days:
        is_active: true
      ai_activity_hourly.hours_saved:
        is_active: true
      ai_activity_hourly.ai_actions:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Ranked by AI actions in the period. Sort by Active Days for consistency or Features for breadth."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 43
    col: 0
    width: 72
    height: 24
    tab_name: people

  - name: pe_user_profiles
    title: "User Profiles | Last 28 Days"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.cohort, ai_user_profile.product_mix, ai_user_profile.top_model, ai_user_profile.complex_query_rate_28d, ai_user_profile.peak_local_hour, ai_user_profile.last_ai_date, ai_user_profile.ai_days_28d]
    filters:
      ai_user_profile.ai_days_28d: ">0"
    sorts: ["ai_user_profile.ai_days_28d desc"]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_profile.user_email: User
      user_org_unit.department: Department
      ai_user_profile.cohort: Cohort
      ai_user_profile.product_mix: Products
      ai_user_profile.top_model: "Top Model"
      ai_user_profile.complex_query_rate_28d: "Complex Query Rate"
      ai_user_profile.peak_local_hour: "Peak Hour"
      ai_user_profile.last_ai_date: "Last AI Use"
      ai_user_profile.ai_days_28d: "AI Days"
    series_cell_visualizations:
      ai_user_profile.ai_days_28d:
        is_active: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 67
    col: 0
    width: 72
    height: 24
    tab_name: people


  # ---------- Tab: models ----------
  - name: header_models
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Models & Time of Day</div>
          <div style="font-size: 13px; opacity: 0.85;">Which models people use, who asks the complex questions, and when AI gets used.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: models

  - name: mo_prompts
    title: Prompts
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.prompts, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: models

  - name: mo_models_used
    title: "Models Used"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.models_used, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: models

  - name: mo_complex_rate
    title: "Complex Query Rate (Auto)"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.complex_query_rate, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Share of Auto-mode prompts that Gemini Enterprise routed to an advanced model (Pro, Ultra, Thinking)."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: models

  - name: mo_reasoning
    title: "Reasoning Tokens"
    type: single_value
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.reasoning_tokens, ge_model_calls.event_month]
    fill_fields: [ge_model_calls.event_month]
    sorts: ["ge_model_calls.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Tokens the model spent thinking. Needs route_inference_logs = true in Terraform."
    listen:
      Date: ge_model_calls.event_date
      Department: user_org_unit.department
      User: ge_model_calls.user_email
      App: ge_model_calls.app_name
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: models

  - name: mo_model_choice
    title: "Auto vs User-Selected Model"
    type: looker_pie
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.model_choice, ge_user_activity.prompts]
    filters:
      ge_user_activity.model_choice: "-NULL"
    sorts: ["ge_user_activity.prompts desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    series_colors:
      Auto: "#1A73E8"
      "User selected": "#9334E6"
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 13
    col: 0
    width: 18
    height: 15
    tab_name: models

  - name: mo_prompts_by_model
    title: "Prompts by Model"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.model, ge_user_activity.prompts, ge_user_activity.prompting_users]
    filters:
      ge_user_activity.model: "-NULL"
    sorts: ["ge_user_activity.prompts desc"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.prompts: "#1A73E8"
      ge_user_activity.prompting_users: "#12B5CB"
    series_labels:
      ge_user_activity.prompts: Prompts
      ge_user_activity.prompting_users: Users
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 13
    col: 18
    width: 54
    height: 15
    tab_name: models

  - name: mo_auto_models
    title: "Models Chosen on Auto"
    type: looker_pie
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.model_family, ge_user_activity.prompts]
    filters:
      ge_user_activity.is_auto_selected: "Yes"
      ge_user_activity.model_family: "-NULL"
    sorts: ["ge_user_activity.prompts desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "With the model on Auto, Gemini Enterprise picks a fast model for simple requests and an advanced one for harder ones."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 28
    col: 0
    width: 36
    height: 15
    tab_name: models

  - name: mo_choice_by_cohort
    title: "Auto vs User-Selected Model by Cohort"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ai_user_profile.cohort, ge_user_activity.model_choice, ge_user_activity.prompts]
    pivots: [ge_user_activity.model_choice]
    filters:
      ge_user_activity.model_choice: "-NULL"
    sorts: [ai_user_profile.cohort, ge_user_activity.model_choice]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: percent
    series_colors:
      "Auto - ge_user_activity.prompts": "#1A73E8"
      "User selected - ge_user_activity.prompts": "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 28
    col: 36
    width: 36
    height: 15
    tab_name: models

  - name: mo_heatmap
    title: "AI Actions by Weekday and Hour | Local Time"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_local_day_of_week, ai_activity_hourly.event_local_hour_of_day, ai_activity_hourly.ai_actions]
    pivots: [ai_activity_hourly.event_local_hour_of_day]
    sorts: [ai_activity_hourly.event_local_day_of_week, ai_activity_hourly.event_local_hour_of_day]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_activity_hourly.event_local_day_of_week: Weekday
    conditional_formatting:
    - {type: "along a scale...", value: null, background_color: null, font_color: null, color_application: {collection_id: looker_2026, custom: {id: "ai-heat", label: Custom, type: continuous, stops: [{color: "#FFFFFF", offset: 0}, {color: "#8AB4F8", offset: 50}, {color: "#174EA6", offset: 100}]}, options: {steps: 5}}, bold: false, italic: false, strikethrough: false, fields: null}
    conditional_formatting_include_totals: false
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Hours are in the reporting time zone install setting. Darker cells are busier hours."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 43
    col: 0
    width: 72
    height: 15
    tab_name: models

  - name: mo_hour_by_product
    title: "AI Actions by Hour and Product | Local Time"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_local_hour_of_day, ai_activity_hourly.product, ai_activity_hourly.ai_actions]
    pivots: [ai_activity_hourly.product]
    sorts: [ai_activity_hourly.event_local_hour_of_day]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Gemini Enterprise - ai_activity_hourly.ai_actions": "#1A73E8"
      "Gemini for Workspace - ai_activity_hourly.ai_actions": "#12B5CB"
      "Antigravity - ai_activity_hourly.ai_actions": "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 58
    col: 0
    width: 72
    height: 15
    tab_name: models

  - name: mo_complex_leaderboard
    title: "Complex Query Leaderboard | Auto Mode"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.user_email, user_org_unit.department, ge_user_activity.auto_prompts, ge_user_activity.auto_advanced_prompts, ge_user_activity.complex_query_rate]
    filters:
      ge_user_activity.auto_prompts: ">=5"
    sorts: ["ge_user_activity.complex_query_rate desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_activity.user_email: User
      user_org_unit.department: Department
      ge_user_activity.auto_prompts: "Auto Prompts"
      ge_user_activity.auto_advanced_prompts: "Routed to Advanced"
      ge_user_activity.complex_query_rate: "Complex Query Rate"
    series_cell_visualizations:
      ge_user_activity.complex_query_rate:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Users with at least 5 Auto-mode prompts, ranked by the share Auto routed to an advanced model: the people asking the hardest questions."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 73
    col: 0
    width: 36
    height: 24
    tab_name: models

  - name: mo_reasoning_leaderboard
    title: "Reasoning Tokens per User"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.user_email, ge_model_calls.model_calls, ge_model_calls.tool_calls, ge_model_calls.total_tokens, ge_model_calls.reasoning_tokens]
    filters:
      ge_model_calls.user_email: "-NULL"
    sorts: ["ge_model_calls.reasoning_tokens desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_model_calls.user_email: User
      ge_model_calls.model_calls: "Model Calls"
      ge_model_calls.tool_calls: "Tool Calls"
      ge_model_calls.total_tokens: "Total Tokens"
      ge_model_calls.reasoning_tokens: "Reasoning Tokens"
    series_cell_visualizations:
      ge_model_calls.reasoning_tokens:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Needs route_inference_logs = true in Terraform."
    listen:
      Date: ge_model_calls.event_date
      Department: user_org_unit.department
      User: ge_model_calls.user_email
      App: ge_model_calls.app_name
    row: 73
    col: 36
    width: 36
    height: 24
    tab_name: models

  - name: mo_models_per_user
    title: "Prompts per User by Model Family | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.user_email, ge_user_activity.model_family, ge_user_activity.prompts]
    pivots: [ge_user_activity.model_family]
    filters:
      ge_user_activity.model_family: "-NULL"
    sorts: [ge_user_activity.model_family, "ge_user_activity.prompts desc 0"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_activity.user_email: User
    conditional_formatting:
    - {type: "along a scale...", value: null, background_color: null, font_color: null, color_application: {collection_id: looker_2026, custom: {id: "ai-heat", label: Custom, type: continuous, stops: [{color: "#FFFFFF", offset: 0}, {color: "#8AB4F8", offset: 50}, {color: "#174EA6", offset: 100}]}, options: {steps: 5}}, bold: false, italic: false, strikethrough: false, fields: null}
    conditional_formatting_include_totals: false
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 97
    col: 0
    width: 72
    height: 24
    tab_name: models


  # ---------- Tab: features ----------
  - name: header_features
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Features & Agents</div>
          <div style="font-size: 13px; opacity: 0.85;">Which Gemini Enterprise features, agents and skills people use, and what gets in their way.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: features

  - name: fe_feature_users
    title: "Feature Users"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.feature_users, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: features

  - name: fe_agent_runs
    title: "Agent Runs"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.agent_runs, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: features

  - name: fe_actions
    title: "Actions Executed"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.actions_executed, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Emails sent, events created and other actions users confirmed."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: features

  - name: fe_satisfaction
    title: Satisfaction
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.satisfaction_rate, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Thumbs up divided by all thumbs feedback."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: features

  - name: fe_agents_used
    title: "Agents Used"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.agents_used, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 13
    col: 0
    width: 18
    height: 8
    tab_name: features

  - name: fe_agents_created
    title: "Agents Created"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.agents_created, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 13
    col: 18
    width: 18
    height: 8
    tab_name: features

  - name: fe_skills_used
    title: "Skills Used"
    type: single_value
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.skills_used, ge_tool_calls.event_month]
    fill_fields: [ge_tool_calls.event_month]
    sorts: ["ge_tool_calls.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_tool_calls.event_date
      Department: user_org_unit.department
      User: ge_tool_calls.user_email
      App: ge_tool_calls.app_name
    row: 13
    col: 36
    width: 18
    height: 8
    tab_name: features

  - name: fe_file_uploads
    title: "File Uploads"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.file_uploads, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 13
    col: 54
    width: 18
    height: 8
    tab_name: features

  - name: fe_users_by_feature
    title: "Users by Feature"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.feature, ge_user_activity.feature_users, ge_user_activity.feature_uses]
    filters:
      ge_user_activity.is_user_facing_feature: "Yes"
    sorts: ["ge_user_activity.feature_users desc"]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.feature_users: "#1A73E8"
      ge_user_activity.feature_uses: "#12B5CB"
    series_labels:
      ge_user_activity.feature_users: Users
      ge_user_activity.feature_uses: Uses
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_user_activity.feature_users, id: ge_user_activity.feature_users, name: Users}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_user_activity.feature_uses, id: ge_user_activity.feature_uses, name: Uses}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 21
    col: 0
    width: 36
    height: 15
    tab_name: features

  - name: fe_feature_trend
    title: "Weekly Users by Feature"
    type: looker_line
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.event_week, ge_user_activity.feature, ge_user_activity.feature_users]
    pivots: [ge_user_activity.feature]
    filters:
      ge_user_activity.is_user_facing_feature: "Yes"
    sorts: [ge_user_activity.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 21
    col: 36
    width: 36
    height: 15
    tab_name: features

  - name: fe_breadth
    title: "Feature Breadth (28d)"
    type: looker_column
    model: gemini_enterprise
    explore: ge_user_profile
    fields: [ge_user_profile.features_used_28d, ge_user_profile.people]
    filters:
      ge_user_profile.engaged_days_28d: ">0"
    sorts: [ge_user_profile.features_used_28d]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_profile.people: "#1A73E8"
    series_labels:
      ge_user_profile.people: People
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "How many distinct features each engaged user touched in the last 28 days."
    listen:
      Department: user_org_unit.department
      User: ge_user_profile.user_email
    row: 36
    col: 0
    width: 36
    height: 15
    tab_name: features

  - name: fe_by_cohort
    title: "Feature Users by AI Cohort"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.feature, ai_user_profile.cohort, ge_user_activity.feature_users]
    pivots: [ai_user_profile.cohort]
    filters:
      ge_user_activity.is_user_facing_feature: "Yes"
    sorts: [ai_user_profile.cohort, "ge_user_activity.feature_users desc 0"]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Power - ge_user_activity.feature_users": "#174EA6"
      "Normal - ge_user_activity.feature_users": "#1A73E8"
      "Casual - ge_user_activity.feature_users": "#8AB4F8"
      "Non-AI - ge_user_activity.feature_users": "#DADCE0"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Cohort is the person's current AI cohort (last 28 days)."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 36
    col: 36
    width: 36
    height: 15
    tab_name: features

  - name: fe_agent_runs_trend
    title: "Agent Runs by Invocation"
    type: looker_column
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.event_week, ge_user_activity.invocation_mode, ge_user_activity.agent_runs]
    pivots: [ge_user_activity.invocation_mode]
    sorts: [ge_user_activity.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 51
    col: 0
    width: 36
    height: 15
    tab_name: features

  - name: fe_skill_trend
    title: "Weekly Skill Loads and Users"
    type: looker_line
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.event_week, ge_tool_calls.skill_loads, ge_tool_calls.skill_users]
    sorts: [ge_tool_calls.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_tool_calls.skill_loads: "#1A73E8"
      ge_tool_calls.skill_users: "#9334E6"
    series_labels:
      ge_tool_calls.skill_loads: "Skill loads"
      ge_tool_calls.skill_users: "Skill users"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_tool_calls.skill_loads, id: ge_tool_calls.skill_loads, name: "Skill loads"}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_tool_calls.skill_users, id: ge_tool_calls.skill_users, name: "Skill users"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_tool_calls.event_date
      Department: user_org_unit.department
      User: ge_tool_calls.user_email
      App: ge_tool_calls.app_name
    row: 51
    col: 36
    width: 36
    height: 15
    tab_name: features

  - name: fe_proposed
    title: "Actions Proposed"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity__proposed_actions.proposed_action, ge_user_activity.interactions]
    filters:
      ge_user_activity__proposed_actions.proposed_action: "-NULL"
    sorts: ["ge_user_activity.interactions desc"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.interactions: "#1A73E8"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 66
    col: 0
    width: 24
    height: 15
    tab_name: features

  - name: fe_executed
    title: "Actions Executed"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.executed_action, ge_user_activity.interactions]
    filters:
      ge_user_activity.executed_action: "-NULL"
    sorts: ["ge_user_activity.interactions desc"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.interactions: "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 66
    col: 24
    width: 24
    height: 15
    tab_name: features

  - name: fe_grounding
    title: "Top Grounding Sources"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity__grounding_domains.grounding_domain, ge_user_activity.interactions]
    filters:
      ge_user_activity__grounding_domains.grounding_domain: "-NULL"
    sorts: ["ge_user_activity.interactions desc"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.interactions: "#12B5CB"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Domains of cited sources. No URIs or titles are stored."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 66
    col: 48
    width: 24
    height: 15
    tab_name: features

  - name: fe_devices
    title: "Users by Device"
    type: looker_pie
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.device_class, ge_user_activity.active_users]
    filters:
      ge_user_activity.device_class: "-NULL"
    sorts: ["ge_user_activity.active_users desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 81
    col: 0
    width: 18
    height: 15
    tab_name: features

  - name: fe_tools
    title: "Tools the Assistant Calls"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.tool_family, ge_tool_calls.tool_calls, ge_tool_calls.tool_users]
    sorts: ["ge_tool_calls.tool_calls desc"]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_tool_calls.tool_calls: "#1A73E8"
      ge_tool_calls.tool_users: "#12B5CB"
    series_labels:
      ge_tool_calls.tool_calls: "Tool calls"
      ge_tool_calls.tool_users: Users
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_tool_calls.tool_calls, id: ge_tool_calls.tool_calls, name: "Tool calls"}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_tool_calls.tool_users, id: ge_tool_calls.tool_users, name: Users}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_tool_calls.event_date
      Department: user_org_unit.department
      User: ge_tool_calls.user_email
      App: ge_tool_calls.app_name
    row: 81
    col: 18
    width: 54
    height: 15
    tab_name: features

  - name: fe_tokens_by_agent
    title: "Tokens by Agent"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.agent_name, ge_model_calls.total_tokens, ge_model_calls.model_calls]
    sorts: ["ge_model_calls.total_tokens desc"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_model_calls.total_tokens: "#1A73E8"
      ge_model_calls.model_calls: "#9334E6"
    series_labels:
      ge_model_calls.total_tokens: Tokens
      ge_model_calls.model_calls: "Model calls"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_model_calls.total_tokens, id: ge_model_calls.total_tokens, name: Tokens}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_model_calls.model_calls, id: ge_model_calls.model_calls, name: "Model calls"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_model_calls.event_date
      Department: user_org_unit.department
      User: ge_model_calls.user_email
      App: ge_model_calls.app_name
    row: 96
    col: 0
    width: 36
    height: 15
    tab_name: features

  - name: fe_tokens_trend
    title: "Weekly Tokens and Cache Hit Rate"
    type: looker_line
    model: gemini_enterprise
    explore: ge_model_calls
    fields: [ge_model_calls.event_week, ge_model_calls.total_tokens, ge_model_calls.cache_hit_rate]
    sorts: [ge_model_calls.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_types:
      ge_model_calls.total_tokens: column
    series_colors:
      ge_model_calls.total_tokens: "#1A73E8"
      ge_model_calls.cache_hit_rate: "#F9AB00"
    series_labels:
      ge_model_calls.total_tokens: Tokens
      ge_model_calls.cache_hit_rate: "Cache hit rate"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_model_calls.total_tokens, id: ge_model_calls.total_tokens, name: Tokens}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_model_calls.cache_hit_rate, id: ge_model_calls.cache_hit_rate, name: "Cache hit rate"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_model_calls.event_date
      Department: user_org_unit.department
      User: ge_model_calls.user_email
      App: ge_model_calls.app_name
    row: 96
    col: 36
    width: 36
    height: 15
    tab_name: features

  - name: fe_connector_errors
    title: "Connector Errors by Category"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_connector_activity
    fields: [ge_connector_activity.connector_type, ge_connector_activity.error_category, ge_connector_activity.connector_errors]
    pivots: [ge_connector_activity.error_category]
    sorts: ["ge_connector_activity.connector_errors desc 0"]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_connector_activity.event_date
      Department: user_org_unit.department
      User: ge_connector_activity.user_email
      App: ge_connector_activity.app_name
    row: 111
    col: 0
    width: 36
    height: 15
    tab_name: features

  - name: fe_reconnect
    title: "Users Who Need to Reconnect a Connector"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_connector_activity
    fields: [ge_connector_activity.user_email, ge_connector_activity.connector_type, ge_connector_activity.error_category, ge_connector_activity.connector_errors]
    filters:
      ge_connector_activity.is_user_fixable: "Yes"
      ge_connector_activity.user_email: "-NULL"
    sorts: ["ge_connector_activity.connector_errors desc"]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_connector_activity.user_email: User
      ge_connector_activity.connector_type: Connector
      ge_connector_activity.error_category: Error
      ge_connector_activity.connector_errors: Errors
    series_cell_visualizations:
      ge_connector_activity.connector_errors:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_connector_activity.event_date
      Department: user_org_unit.department
      User: ge_connector_activity.user_email
      App: ge_connector_activity.app_name
    row: 111
    col: 36
    width: 36
    height: 15
    tab_name: features

  - name: fe_top_agents
    title: "Top Agents | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.agent_name, ge_user_activity.agent_kind, ge_user_activity.feature, ge_user_activity.agent_users, ge_user_activity.agent_runs]
    filters:
      ge_user_activity.agent_id: "-NULL"
      ge_user_activity.is_core_assistant: "No"
    sorts: ["ge_user_activity.agent_runs desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_activity.agent_name: Agent
      ge_user_activity.agent_kind: Kind
      ge_user_activity.feature: Feature
      ge_user_activity.agent_users: Users
      ge_user_activity.agent_runs: Runs
    series_cell_visualizations:
      ge_user_activity.agent_users:
        is_active: true
      ge_user_activity.agent_runs:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 126
    col: 0
    width: 72
    height: 24
    tab_name: features

  - name: fe_top_skills
    title: "Top Skills"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_tool_calls
    fields: [ge_tool_calls.skill_name, ge_tool_calls.is_first_party_skill, ge_tool_calls.skill_users, ge_tool_calls.skill_loads]
    filters:
      ge_tool_calls.skill_name: "-NULL"
    sorts: ["ge_tool_calls.skill_loads desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_tool_calls.skill_name: Skill
      ge_tool_calls.is_first_party_skill: "Google Skill"
      ge_tool_calls.skill_users: Users
      ge_tool_calls.skill_loads: Loads
    series_cell_visualizations:
      ge_tool_calls.skill_users:
        is_active: true
      ge_tool_calls.skill_loads:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_tool_calls.event_date
      Department: user_org_unit.department
      User: ge_tool_calls.user_email
      App: ge_tool_calls.app_name
    row: 150
    col: 0
    width: 36
    height: 24
    tab_name: features

  - name: fe_agent_builders
    title: "Agent Builders"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.user_email, user_org_unit.department, ge_user_activity.agents_created, ge_user_activity.interactions]
    filters:
      ge_user_activity.feature: "Agent builder"
    sorts: ["ge_user_activity.interactions desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_activity.user_email: User
      user_org_unit.department: Department
      ge_user_activity.agents_created: "Agents Created"
      ge_user_activity.interactions: "Builder Sessions"
    series_cell_visualizations:
      ge_user_activity.interactions:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 150
    col: 36
    width: 36
    height: 24
    tab_name: features


  # ---------- Tab: roi ----------
  - name: header_roi
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">ROI & Value</div>
          <div style="font-size: 13px; opacity: 0.85;">What the AI investment costs and what it returns. Seat costs, hourly rate and minutes saved are install settings.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: roi

  - name: roi_hours_saved
    title: "Estimated Hours Saved"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "AI actions times the minutes-saved-per-action install setting. See the assumptions table below."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: roi

  - name: roi_value
    title: "Estimated Value of Time Saved"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.value_of_time_saved, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Hours saved times the loaded hourly rate install setting."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: roi

  - name: roi_hours_per_user
    title: "Hours Saved per AI User"
    type: single_value
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.hours_saved_per_ai_user, ai_activity_hourly.event_month]
    fill_fields: [ai_activity_hourly.event_month]
    sorts: ["ai_activity_hourly.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: roi

  - name: roi_monthly_spend
    title: "Monthly AI Spend"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.monthly_ai_spend]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Licensed Gemini Enterprise users and Workspace users times the seat-cost install settings."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: roi

  - name: roi_cost_per_user
    title: "Monthly Cost per AI Active User"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.cost_per_ai_active_user]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 0
    width: 18
    height: 8
    tab_name: roi

  - name: roi_idle_spend
    title: "Monthly Spend on Idle Licences"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licence_spend]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Gemini Enterprise licences with no prompt or search in 28 days, times the seat cost."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 18
    width: 18
    height: 8
    tab_name: roi

  - name: roi_idle_licences
    title: "Idle Gemini Enterprise Licences"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licences]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Licensed with no Gemini Enterprise prompt or search in the last 28 days."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 36
    width: 18
    height: 8
    tab_name: roi

  - name: roi_days_to_first
    title: "Avg Days from Licence to First Use"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.average_days_to_first_ge_use]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 54
    width: 18
    height: 8
    tab_name: roi

  - name: roi_assumptions
    title: "Estimated Hours Saved by Feature | Assumptions"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.product, ai_activity_hourly.feature, ai_activity_hourly.minutes_saved_per_action, ai_activity_hourly.value_actions, ai_activity_hourly.hours_saved]
    filters:
      ai_activity_hourly.hours_saved: ">0"
    sorts: ["ai_activity_hourly.hours_saved desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: true
    show_row_totals: true
    show_sql_query_menu_options: false
    series_labels:
      ai_activity_hourly.product: Product
      ai_activity_hourly.feature: Feature
      ai_activity_hourly.minutes_saved_per_action: "Minutes per Action"
      ai_activity_hourly.value_actions: Actions
      ai_activity_hourly.hours_saved: "Est. Hours Saved"
    series_cell_visualizations:
      ai_activity_hourly.value_actions:
        is_active: true
      ai_activity_hourly.hours_saved:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Minutes per action come from the time_saved_minutes install setting. Change it to match your own time studies."
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 21
    col: 0
    width: 36
    height: 15
    tab_name: roi

  - name: roi_hours_trend
    title: "Estimated Hours Saved per Week"
    type: looker_column
    model: gemini_enterprise
    explore: ai_activity_hourly
    fields: [ai_activity_hourly.event_week, ai_activity_hourly.product, ai_activity_hourly.hours_saved]
    pivots: [ai_activity_hourly.product]
    fill_fields: [ai_activity_hourly.event_week]
    sorts: [ai_activity_hourly.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    series_colors:
      "Gemini Enterprise - ai_activity_hourly.hours_saved": "#1A73E8"
      "Gemini for Workspace - ai_activity_hourly.hours_saved": "#12B5CB"
      "Antigravity - ai_activity_hourly.hours_saved": "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ai_activity_hourly.event_date
      Product: ai_activity_hourly.product
      Department: user_org_unit.department
      User: ai_activity_hourly.user_email
    row: 21
    col: 36
    width: 36
    height: 15
    tab_name: roi

  - name: roi_retention
    title: "Monthly Retention by First AI Month"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_retention
    fields: [ai_user_retention.first_month, ai_user_retention.months_since_first, ai_user_retention.new_users, ai_user_retention.retention_rate]
    pivots: [ai_user_retention.months_since_first]
    filters:
      ai_user_retention.product: "Any AI"
    sorts: ["ai_user_retention.first_month desc", ai_user_retention.months_since_first]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_retention.first_month: "First AI Month"
      ai_user_retention.new_users: "New Users"
      ai_user_retention.retention_rate: "Still Active"
    conditional_formatting:
    - {type: "along a scale...", value: null, background_color: null, font_color: null, color_application: {collection_id: looker_2026, custom: {id: "ai-heat", label: Custom, type: continuous, stops: [{color: "#FFFFFF", offset: 0}, {color: "#8AB4F8", offset: 50}, {color: "#174EA6", offset: 100}]}, options: {steps: 5}}, bold: false, italic: false, strikethrough: false, fields: null}
    conditional_formatting_include_totals: false
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Share of each month's new AI users still active N months later. Edit the tile's Product filter for a single product."
    listen:
      Department: user_org_unit.department
      User: ai_user_retention.user_email
    row: 36
    col: 0
    width: 72
    height: 15
    tab_name: roi

  - name: roi_time_to_first
    title: "Days from Licence to First Use by Licence Month"
    type: looker_column
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.licence_assigned_month, ai_user_profile.average_days_to_first_ge_use, ai_user_profile.ge_licensed_users]
    filters:
      ai_user_profile.licence_assigned_month: "-NULL"
    sorts: [ai_user_profile.licence_assigned_month]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_types:
      ai_user_profile.ge_licensed_users: line
    series_colors:
      ai_user_profile.average_days_to_first_ge_use: "#1A73E8"
      ai_user_profile.ge_licensed_users: "#9334E6"
    series_labels:
      ai_user_profile.average_days_to_first_ge_use: "Avg days to first use"
      ai_user_profile.ge_licensed_users: "Licences assigned"
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ai_user_profile.average_days_to_first_ge_use, id: ai_user_profile.average_days_to_first_ge_use, name: "Avg days to first use"}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ai_user_profile.ge_licensed_users, id: ai_user_profile.ge_licensed_users, name: "Licences assigned"}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Time to first value: how quickly people use a new licence. Long gaps mean onboarding needs work."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 51
    col: 0
    width: 36
    height: 15
    tab_name: roi

  - name: roi_licence_growth
    title: "Licences Over Time"
    type: looker_line
    model: gemini_enterprise
    explore: ge_user_licenses
    fields: [ge_user_licenses.snapshot_date, ge_user_licenses.licensed_users, ge_user_licenses.unlicensed_login_attempts]
    sorts: [ge_user_licenses.snapshot_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_licenses.licensed_users: "#1A73E8"
      ge_user_licenses.unlicensed_login_attempts: "#F9AB00"
    series_labels:
      ge_user_licenses.licensed_users: "Licensed users"
      ge_user_licenses.unlicensed_login_attempts: "Asking for a licence"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_licenses.snapshot_date
      Department: user_org_unit.department
      User: ge_user_licenses.user_email
    row: 51
    col: 36
    width: 36
    height: 15
    tab_name: roi

  - name: roi_advanced_features
    title: "Advanced Feature Adoption | Gemini Enterprise"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.feature, ge_user_activity.feature_users, ge_user_activity.feature_uses]
    filters:
      ge_user_activity.feature: "Deep Research,Idea Generation,Custom agents,Agent designer,Workflows,Scheduled and triggered agents,Actions,Skill authoring,NotebookLM"
    sorts: ["ge_user_activity.feature_users desc"]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.feature_users: "#1A73E8"
      ge_user_activity.feature_uses: "#12B5CB"
    series_labels:
      ge_user_activity.feature_users: Users
      ge_user_activity.feature_uses: Uses
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_user_activity.feature_users, id: ge_user_activity.feature_users, name: Users}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_user_activity.feature_uses, id: ge_user_activity.feature_uses, name: Uses}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Features that go beyond chat and search. Depth of use is a stronger value signal than headcount."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 66
    col: 0
    width: 36
    height: 15
    tab_name: roi

  - name: roi_quality
    title: "Answer Quality per Week | Gemini Enterprise"
    type: looker_line
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.event_week, ge_user_activity.satisfaction_rate, ge_user_activity.grounded_answer_rate, ge_user_activity.error_rate]
    sorts: [ge_user_activity.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_user_activity.satisfaction_rate: "#1E8E3E"
      ge_user_activity.grounded_answer_rate: "#1A73E8"
      ge_user_activity.error_rate: "#D93025"
    series_labels:
      ge_user_activity.satisfaction_rate: Satisfaction
      ge_user_activity.grounded_answer_rate: "Grounded answers"
      ge_user_activity.error_rate: Errors
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 66
    col: 36
    width: 36
    height: 15
    tab_name: roi


  # ---------- Tab: targeting ----------
  - name: header_targeting
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Change Targeting</div>
          <div style="font-size: 13px; opacity: 0.85;">Who to train, nudge, recognise or license next. Lists are a rolling 28 days.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: targeting

  - name: tg_room_to_grow
    title: "Casual or Non-AI Share (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.casual_or_non_ai_share, ai_user_profile.people]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "people in scope"
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Share of people using AI on fewer than 4 days in the last 28 (the Normal threshold install setting)."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: targeting

  - name: tg_idle
    title: "Idle Gemini Enterprise Licences (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.idle_ge_licences]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: targeting

  - name: tg_workspace_only
    title: "Workspace Gemini Only (28d)"
    type: single_value
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.people]
    filters:
      ai_user_profile.product_mix: "Workspace Gemini only"
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Using AI in Gmail and Docs but not Gemini Enterprise: the warmest audience for Gemini Enterprise training or a licence."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: targeting

  - name: tg_licence_demand
    title: "Users Asking for a Licence"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_licenses
    fields: [ge_user_licenses.unlicensed_login_attempts]
    filters:
      ge_user_licenses.is_latest_snapshot: "Yes"
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Tried to sign in to Gemini Enterprise without a licence (latest snapshot): unmet demand."
    listen:
      Department: user_org_unit.department
      User: ge_user_licenses.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: targeting

  - name: tg_department_room
    title: "Departments with the Most Room to Grow | Last 28 Days"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.people, ai_user_profile.power_users, ai_user_profile.normal_users, ai_user_profile.casual_users, ai_user_profile.non_ai_users, ai_user_profile.casual_or_non_ai_share]
    sorts: ["ai_user_profile.casual_or_non_ai_share desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      user_org_unit.department: Department
      ai_user_profile.people: People
      ai_user_profile.power_users: Power
      ai_user_profile.normal_users: Normal
      ai_user_profile.casual_users: Casual
      ai_user_profile.non_ai_users: "Non-AI"
      ai_user_profile.casual_or_non_ai_share: "Casual or Non-AI"
    series_cell_visualizations:
      ai_user_profile.people:
        is_active: true
      ai_user_profile.casual_or_non_ai_share:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Start training where this share and headcount are both high."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 13
    col: 0
    width: 72
    height: 15
    tab_name: targeting

  - name: tg_champions
    title: "Power Users by Department | Champion Network (28d)"
    type: looker_bar
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [user_org_unit.department, ai_user_profile.power_users, ai_user_profile.people]
    sorts: ["ai_user_profile.power_users desc"]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ai_user_profile.power_users: "#174EA6"
      ai_user_profile.people: "#DADCE0"
    series_labels:
      ai_user_profile.power_users: "Power users"
      ai_user_profile.people: People
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Recruit Power users as peer champions. Departments with people but no Power users need one."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 28
    col: 0
    width: 36
    height: 15
    tab_name: targeting

  - name: tg_at_risk
    title: "At Risk: Moved Down a Cohort | Latest Week"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_cohort_weekly
    fields: [ai_user_cohort_weekly.user_email, user_org_unit.department, ai_user_cohort_weekly.previous_cohort, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.ai_days]
    filters:
      ai_user_cohort_weekly.is_latest_week: "Yes"
      ai_user_cohort_weekly.cohort_movement: "Moved down"
    sorts: [ai_user_cohort_weekly.previous_cohort]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_cohort_weekly.user_email: User
      user_org_unit.department: Department
      ai_user_cohort_weekly.previous_cohort: From
      ai_user_cohort_weekly.cohort: To
      ai_user_cohort_weekly.ai_days: "AI Days (28d)"
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_cohort_weekly.user_email
    row: 28
    col: 36
    width: 36
    height: 15
    tab_name: targeting

  - name: tg_idle_licences
    title: "Idle Gemini Enterprise Licences | Nudge or Reclaim"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.licence_assigned_date, ai_user_profile.last_ai_date, ai_user_profile.gws_days_28d]
    filters:
      ai_user_profile.is_ge_licensed: "Yes"
      ai_user_profile.ge_days_28d: "0"
    sorts: [ai_user_profile.licence_assigned_date]
    limit: 200
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_profile.user_email: User
      user_org_unit.department: Department
      ai_user_profile.licence_assigned_date: "Licence Assigned"
      ai_user_profile.last_ai_date: "Last AI Use"
      ai_user_profile.gws_days_28d: "Workspace Gemini Days"
    series_cell_visualizations:
      ai_user_profile.gws_days_28d:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Workspace Gemini days show who already uses AI elsewhere and needs a Gemini Enterprise introduction."
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 43
    col: 0
    width: 36
    height: 24
    tab_name: targeting

  - name: tg_cross_sell
    title: "Workspace Gemini Users Not Yet on Gemini Enterprise"
    type: looker_grid
    model: gemini_enterprise
    explore: ai_user_profile
    fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.is_ge_licensed, ai_user_profile.gws_actions_28d, ai_user_profile.gws_days_28d]
    filters:
      ai_user_profile.product_mix: "Workspace Gemini only"
    sorts: ["ai_user_profile.gws_days_28d desc"]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ai_user_profile.user_email: User
      user_org_unit.department: Department
      ai_user_profile.is_ge_licensed: "Has Licence"
      ai_user_profile.gws_actions_28d: "Workspace Actions"
      ai_user_profile.gws_days_28d: "Workspace Gemini Days"
    series_cell_visualizations:
      ai_user_profile.gws_days_28d:
        is_active: true
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ai_user_profile.user_email
    row: 43
    col: 36
    width: 36
    height: 24
    tab_name: targeting

  - name: tg_narrow
    title: "Single-Feature Gemini Enterprise Users"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_profile
    fields: [ge_user_profile.user_email, user_org_unit.department, ge_user_profile.primary_app, ge_user_profile.prompts_28d, ge_user_profile.engaged_days_28d]
    filters:
      ge_user_profile.features_used_28d: "1"
    sorts: ["ge_user_profile.engaged_days_28d desc"]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_profile.user_email: User
      user_org_unit.department: Department
      ge_user_profile.primary_app: App
      ge_user_profile.prompts_28d: Prompts
      ge_user_profile.engaged_days_28d: "Engaged Days"
    series_cell_visualizations:
      ge_user_profile.engaged_days_28d:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Regular users who only use one feature (usually chat): ready for training on Deep Research, agents and actions."
    listen:
      Department: user_org_unit.department
      User: ge_user_profile.user_email
    row: 67
    col: 0
    width: 36
    height: 24
    tab_name: targeting

  - name: tg_skills_gap
    title: "Prompting Skills Gaps"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.user_email, user_org_unit.department, ge_user_activity.prompts, ge_user_activity.blocked_prompts, ge_user_activity.zero_result_searches, ge_user_activity.negative_feedback]
    filters:
      ge_user_activity.prompts: ">=5"
    sorts: ["ge_user_activity.negative_feedback desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_activity.user_email: User
      user_org_unit.department: Department
      ge_user_activity.prompts: Prompts
      ge_user_activity.blocked_prompts: Blocked
      ge_user_activity.zero_result_searches: "Empty Searches"
      ge_user_activity.negative_feedback: "Thumbs Down"
    series_cell_visualizations:
      ge_user_activity.negative_feedback:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Users who give thumbs-down, hit policy blocks or get empty searches: candidates for prompting and search training."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 67
    col: 36
    width: 36
    height: 24
    tab_name: targeting

  - name: tg_licence_requests
    title: "Users Asking for a Licence"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_licenses
    fields: [ge_user_licenses.user_email, user_org_unit.department, ge_user_licenses.last_login_date]
    filters:
      ge_user_licenses.is_latest_snapshot: "Yes"
      ge_user_licenses.license_state: NO_LICENSE_ATTEMPTED_LOGIN
    sorts: ["ge_user_licenses.last_login_date desc"]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_licenses.user_email: User
      user_org_unit.department: Department
      ge_user_licenses.last_login_date: "Last Sign-in Attempt"
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ge_user_licenses.user_email
    row: 91
    col: 0
    width: 36
    height: 24
    tab_name: targeting

  - name: tg_nudge
    title: "Nudge List: Dormant or Unused Licences"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_user_profile
    fields: [ge_user_profile.user_email, user_org_unit.department, ge_user_profile.segment, ge_user_profile.last_active_date, ge_user_profile.last_login_date]
    filters:
      ge_user_profile.segment: "Dormant,Never used"
      ge_user_profile.is_licensed: "Yes"
    sorts: [ge_user_profile.last_active_date]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_user_profile.user_email: User
      user_org_unit.department: Department
      ge_user_profile.segment: Segment
      ge_user_profile.last_active_date: "Last Active"
      ge_user_profile.last_login_date: "Last Sign-in"
    defaults_version: 1
    listen:
      Department: user_org_unit.department
      User: ge_user_profile.user_email
    row: 91
    col: 36
    width: 36
    height: 24
    tab_name: targeting


  # ---------- Tab: safety ----------
  - name: header_safety
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Safety & Governance</div>
          <div style="font-size: 13px; opacity: 0.85;">What Model Armor flags, who triggers it, and who changed the configuration.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: safety

  - name: sa_screened
    title: "Screened Interactions"
    type: single_value
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.screened_interactions, ge_safety_events.event_month]
    fill_fields: [ge_safety_events.event_month]
    sorts: ["ge_safety_events.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Needs Model Armor Data Access audit logs (enable_model_armor_audit_logs = true)."
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: safety

  - name: sa_flagged
    title: "Flagged Interactions"
    type: single_value
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.flagged_interactions, ge_safety_events.event_month]
    fill_fields: [ge_safety_events.event_month]
    sorts: ["ge_safety_events.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#D93025"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: safety

  - name: sa_flag_rate
    title: "Flag Rate"
    type: single_value
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.flag_rate, ge_safety_events.event_month]
    fill_fields: [ge_safety_events.event_month]
    sorts: ["ge_safety_events.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.00%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#F9AB00"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: safety

  - name: sa_blocked
    title: "Answers Blocked by Policy"
    type: single_value
    model: gemini_enterprise
    explore: ge_user_activity
    fields: [ge_user_activity.blocked_prompts, ge_user_activity.event_month]
    fill_fields: [ge_user_activity.event_month]
    sorts: ["ge_user_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Answers Gemini Enterprise skipped for a policy or safety reason."
    listen:
      Date: ge_user_activity.event_date
      Department: user_org_unit.department
      User: ge_user_activity.user_email
      App: ge_user_activity.app_name
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: safety

  - name: sa_by_category
    title: "Flags by Category"
    type: looker_bar
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.category, ge_safety_events.category_matches, ge_safety_events.flagged_users]
    filters:
      ge_safety_events.is_match: "Yes"
      ge_safety_events.category: "-NULL"
    sorts: ["ge_safety_events.category_matches desc"]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      ge_safety_events.category_matches: "#D93025"
      ge_safety_events.flagged_users: "#F9AB00"
    series_labels:
      ge_safety_events.category_matches: Matches
      ge_safety_events.flagged_users: Users
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: ge_safety_events.category_matches, id: ge_safety_events.category_matches, name: Matches}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: ge_safety_events.flagged_users, id: ge_safety_events.flagged_users, name: Users}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 13
    col: 0
    width: 36
    height: 15
    tab_name: safety

  - name: sa_trend
    title: "Weekly Flags by Source"
    type: looker_column
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.event_week, ge_safety_events.source, ge_safety_events.flagged_interactions]
    pivots: [ge_safety_events.source]
    sorts: [ge_safety_events.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 13
    col: 36
    width: 36
    height: 15
    tab_name: safety

  - name: sa_prompt_vs_response
    title: "Prompt vs Response Flags"
    type: looker_pie
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.screened_content, ge_safety_events.flagged_interactions]
    filters:
      ge_safety_events.source: MODEL_ARMOR
    sorts: ["ge_safety_events.flagged_interactions desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 28
    col: 0
    width: 24
    height: 15
    tab_name: safety

  - name: sa_attribution
    title: "User Attribution Quality"
    type: looker_pie
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.attribution_method, ge_safety_events.flagged_interactions]
    sorts: ["ge_safety_events.flagged_interactions desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "time_window matches are the nearest assistant call within 10 seconds and less certain than trace."
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 28
    col: 24
    width: 24
    height: 15
    tab_name: safety

  - name: sa_templates
    title: "Flag Rate by Model Armor Template"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.template, ge_safety_events.screened_interactions, ge_safety_events.flagged_interactions, ge_safety_events.flag_rate]
    filters:
      ge_safety_events.source: MODEL_ARMOR
    sorts: ["ge_safety_events.flagged_interactions desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_safety_events.template: Template
      ge_safety_events.screened_interactions: Screened
      ge_safety_events.flagged_interactions: Flagged
      ge_safety_events.flag_rate: "Flag Rate"
    series_cell_visualizations:
      ge_safety_events.flag_rate:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 28
    col: 48
    width: 24
    height: 15
    tab_name: safety

  - name: sa_most_flagged
    title: "Users with the Most Flagged Prompts"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.user_email, user_org_unit.department, ge_safety_events.category_matches, ge_safety_events.flagged_interactions]
    filters:
      ge_safety_events.is_match: "Yes"
      ge_safety_events.user_email: "-NULL"
    sorts: ["ge_safety_events.flagged_interactions desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_safety_events.user_email: User
      user_org_unit.department: Department
      ge_safety_events.category_matches: "Category Matches"
      ge_safety_events.flagged_interactions: Flagged
    series_cell_visualizations:
      ge_safety_events.flagged_interactions:
        is_active: true
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 43
    col: 0
    width: 36
    height: 24
    tab_name: safety

  - name: sa_user_by_category
    title: "Flagged Users by Category"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_safety_events
    fields: [ge_safety_events.user_email, ge_safety_events.category, ge_safety_events.category_matches]
    pivots: [ge_safety_events.category]
    filters:
      ge_safety_events.is_match: "Yes"
      ge_safety_events.category: "-NULL"
      ge_safety_events.user_email: "-NULL"
    sorts: ["ge_safety_events.category_matches desc 0"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_safety_events.user_email: User
    conditional_formatting:
    - {type: "along a scale...", value: null, background_color: null, font_color: null, color_application: {collection_id: looker_2026, custom: {id: "ai-heat", label: Custom, type: continuous, stops: [{color: "#FFFFFF", offset: 0}, {color: "#8AB4F8", offset: 50}, {color: "#174EA6", offset: 100}]}, options: {steps: 5}}, bold: false, italic: false, strikethrough: false, fields: null}
    conditional_formatting_include_totals: false
    defaults_version: 1
    listen:
      Date: ge_safety_events.event_date
      Department: user_org_unit.department
      User: ge_safety_events.user_email
      App: ge_safety_events.app_name
    row: 43
    col: 36
    width: 36
    height: 24
    tab_name: safety

  - name: sa_admin_trend
    title: "Admin Changes per Week"
    type: looker_column
    model: gemini_enterprise
    explore: ge_admin_events
    fields: [ge_admin_events.event_week, ge_admin_events.method, ge_admin_events.changes]
    pivots: [ge_admin_events.method]
    sorts: [ge_admin_events.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: ge_admin_events.event_date
      Department: user_org_unit.department
      User: ge_admin_events.principal_email
      App: ge_admin_events.app_name
    row: 67
    col: 0
    width: 72
    height: 15
    tab_name: safety

  - name: sa_admin_log
    title: "Recent Admin Changes"
    type: looker_grid
    model: gemini_enterprise
    explore: ge_admin_events
    fields: [ge_admin_events.event_time_time, ge_admin_events.principal_email, ge_admin_events.method, ge_admin_events.resource_type, ge_admin_events.app_name]
    sorts: ["ge_admin_events.event_time_time desc"]
    limit: 200
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      ge_admin_events.event_time_time: Time
      ge_admin_events.principal_email: Admin
      ge_admin_events.method: Change
      ge_admin_events.resource_type: Resource
      ge_admin_events.app_name: App
    defaults_version: 1
    listen:
      Date: ge_admin_events.event_date
      Department: user_org_unit.department
      User: ge_admin_events.principal_email
      App: ge_admin_events.app_name
    row: 82
    col: 0
    width: 72
    height: 24
    tab_name: safety


  # ---------- Tab: antigravity ----------
  - name: header_antigravity
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Antigravity</div>
          <div style="font-size: 13px; opacity: 0.85;">Adoption of agentic coding in Antigravity.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: antigravity

  - name: ag_users
    title: "Antigravity Users"
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.users, antigravity_usage.event_month]
    fill_fields: [antigravity_usage.event_month]
    sorts: ["antigravity_usage.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: antigravity

  - name: ag_requests
    title: "Inference Requests"
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.requests, antigravity_usage.event_month]
    fill_fields: [antigravity_usage.event_month]
    sorts: ["antigravity_usage.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: antigravity

  - name: ag_tasks
    title: "Agent Tasks"
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.agent_tasks, antigravity_usage.event_month]
    fill_fields: [antigravity_usage.event_month]
    sorts: ["antigravity_usage.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Distinct agent trajectories."
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: antigravity

  - name: ag_tokens
    title: Tokens
    type: single_value
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.total_tokens, antigravity_usage.event_month]
    fill_fields: [antigravity_usage.event_month]
    sorts: ["antigravity_usage.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: antigravity

  - name: ag_weekly
    title: "Weekly Users and Requests"
    type: looker_column
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.event_week, antigravity_usage.requests, antigravity_usage.users]
    fill_fields: [antigravity_usage.event_week]
    sorts: [antigravity_usage.event_week]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_types:
      antigravity_usage.users: line
    series_colors:
      antigravity_usage.requests: "#1A73E8"
      antigravity_usage.users: "#9334E6"
    series_labels:
      antigravity_usage.requests: Requests
      antigravity_usage.users: Users
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: antigravity_usage.requests, id: antigravity_usage.requests, name: Requests}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: antigravity_usage.users, id: antigravity_usage.users, name: Users}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 13
    col: 0
    width: 54
    height: 15
    tab_name: antigravity

  - name: ag_experience
    title: "Requests by Experience"
    type: looker_pie
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.experience, antigravity_usage.requests]
    sorts: ["antigravity_usage.requests desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 13
    col: 54
    width: 18
    height: 15
    tab_name: antigravity

  - name: ag_hour
    title: "Requests by Hour | Local Time"
    type: looker_column
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.event_local_hour_of_day, antigravity_usage.requests]
    sorts: [antigravity_usage.event_local_hour_of_day]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      antigravity_usage.requests: "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 28
    col: 0
    width: 36
    height: 15
    tab_name: antigravity

  - name: ag_by_cohort
    title: "Antigravity Users by AI Cohort"
    type: looker_bar
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [ai_user_profile.cohort, antigravity_usage.users]
    sorts: [ai_user_profile.cohort]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: false
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      antigravity_usage.users: "#9334E6"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Cross-product adoption: how often Antigravity users use AI overall. Cohort is the last 28 days."
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 28
    col: 36
    width: 36
    height: 15
    tab_name: antigravity

  - name: ag_model
    title: "Requests by Model"
    type: looker_pie
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.model, antigravity_usage.requests]
    sorts: ["antigravity_usage.requests desc"]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 55
    start_angle: 0
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 43
    col: 0
    width: 18
    height: 15
    tab_name: antigravity

  - name: ag_clients
    title: "Users by Client and Version"
    type: looker_bar
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.client_name, antigravity_usage.client_version, antigravity_usage.users]
    pivots: [antigravity_usage.client_name]
    sorts: ["antigravity_usage.client_version desc"]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 43
    col: 18
    width: 54
    height: 15
    tab_name: antigravity

  - name: ag_top_users
    title: "Top Antigravity Users | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: antigravity_usage
    fields: [antigravity_usage.user_email, user_org_unit.department, antigravity_usage.agent_tasks, antigravity_usage.total_tokens, antigravity_usage.requests]
    sorts: ["antigravity_usage.requests desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      antigravity_usage.user_email: User
      user_org_unit.department: Department
      antigravity_usage.agent_tasks: "Agent Tasks"
      antigravity_usage.total_tokens: Tokens
      antigravity_usage.requests: Requests
    series_cell_visualizations:
      antigravity_usage.agent_tasks:
        is_active: true
      antigravity_usage.total_tokens:
        is_active: true
      antigravity_usage.requests:
        is_active: true
    defaults_version: 1
    listen:
      Date: antigravity_usage.event_date
      Department: user_org_unit.department
      User: antigravity_usage.user_email
    row: 58
    col: 0
    width: 72
    height: 24
    tab_name: antigravity


  # ---------- Tab: ge_analytics ----------
  - name: header_ge_analytics
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Gemini Enterprise Analytics</div>
          <div style="font-size: 13px; opacity: 0.85;">App-level totals from the Gemini Enterprise analytics export. Works without the log pipeline; follows the Date and App filters.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: ge_analytics

  - name: ex_adoption_rate
    title: "Adoption Rate"
    type: single_value
    model: gemini_enterprise
    explore: adoption
    fields: [adoption.adoption_rate, adoption.metric_month]
    fill_fields: [adoption.metric_month]
    sorts: ["adoption.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Average daily active users divided by seats claimed."
    listen:
      Date: adoption.metric_date
      App: adoption.app_name
    row: 5
    col: 0
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_seats_claimed
    title: "Seats Claimed"
    type: single_value
    model: gemini_enterprise
    explore: seats
    fields: [seats.seats_claimed, seats.metric_month]
    fill_fields: [seats.metric_month]
    sorts: ["seats.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: seats.metric_date
      App: seats.app_name
    row: 5
    col: 18
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_seat_utilisation
    title: "Seat Utilisation"
    type: single_value
    model: gemini_enterprise
    explore: seats
    fields: [seats.seat_utilisation, seats.metric_month]
    fill_fields: [seats.metric_month]
    sorts: ["seats.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Seats claimed divided by seats purchased."
    listen:
      Date: seats.metric_date
      App: seats.app_name
    row: 5
    col: 36
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_answers
    title: "Assistant Answers"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.answers, activity.metric_month]
    fill_fields: [activity.metric_month]
    sorts: ["activity.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_searches
    title: Searches
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.searches, activity.metric_month]
    fill_fields: [activity.metric_month]
    sorts: ["activity.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 13
    col: 0
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_ctr
    title: "Search Click-Through Rate"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.click_through_rate, activity.metric_month]
    fill_fields: [activity.metric_month]
    sorts: ["activity.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 13
    col: 18
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_agents
    title: "Distinct Agents Used"
    type: single_value
    model: gemini_enterprise
    explore: agents
    fields: [agents.agent_count, agents.metric_month]
    fill_fields: [agents.metric_month]
    sorts: ["agents.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#9334E6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: agents.metric_date
      App: agents.app_name
    row: 13
    col: 36
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_new_agents
    title: "New Agents Created"
    type: single_value
    model: gemini_enterprise
    explore: agents
    fields: [agents.new_agents, agents.metric_month]
    fill_fields: [agents.metric_month]
    sorts: ["agents.metric_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: agents.metric_date
      App: agents.app_name
    row: 13
    col: 54
    width: 18
    height: 8
    tab_name: ge_analytics

  - name: ex_active_users
    title: "Daily, Weekly and Monthly Active Users"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.daily_active_users, active_users.weekly_active_users, active_users.monthly_active_users]
    filters:
      active_users.product_type: Total
    sorts: [active_users.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      active_users.daily_active_users: "#1A73E8"
      active_users.weekly_active_users: "#12B5CB"
      active_users.monthly_active_users: "#174EA6"
    series_labels:
      active_users.daily_active_users: Daily
      active_users.weekly_active_users: "Weekly (7-day)"
      active_users.monthly_active_users: "Monthly (28-day)"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: active_users.metric_date
      App: active_users.app_name
    row: 21
    col: 0
    width: 72
    height: 15
    tab_name: ge_analytics

  - name: ex_dau_by_surface
    title: "Daily Active Users by Surface"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.product_type, active_users.daily_active_users]
    pivots: [active_users.product_type]
    filters:
      active_users.product_type: "-Total"
    sorts: [active_users.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: active_users.metric_date
      App: active_users.app_name
    row: 36
    col: 0
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_retention
    title: Retention
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.retention_7d, active_users.retention_28d]
    filters:
      active_users.product_type: Total
    sorts: [active_users.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      active_users.retention_7d: "#1A73E8"
      active_users.retention_28d: "#9334E6"
    series_labels:
      active_users.retention_7d: "7-day retention"
      active_users.retention_28d: "28-day retention"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: active_users.metric_date
      App: active_users.app_name
    row: 36
    col: 36
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_seats_trend
    title: "Seats Purchased vs Claimed"
    type: looker_area
    model: gemini_enterprise
    explore: seats
    fields: [seats.metric_date, seats.seats_purchased, seats.seats_claimed]
    sorts: [seats.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      seats.seats_purchased: "#DADCE0"
      seats.seats_claimed: "#1A73E8"
    series_labels:
      seats.seats_purchased: Purchased
      seats.seats_claimed: Claimed
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: seats.metric_date
      App: seats.app_name
    row: 51
    col: 0
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_agent_sessions
    title: "Agent Sessions and Users"
    type: looker_line
    model: gemini_enterprise
    explore: agents
    fields: [agents.metric_date, agents.agent_sessions, agents.agent_active_users]
    sorts: [agents.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      agents.agent_sessions: "#1A73E8"
      agents.agent_active_users: "#9334E6"
    series_labels:
      agents.agent_sessions: Sessions
      agents.agent_active_users: Users
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: agents.agent_sessions, id: agents.agent_sessions, name: Sessions}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: agents.agent_active_users, id: agents.agent_active_users, name: Users}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: agents.metric_date
      App: agents.app_name
    row: 51
    col: 36
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_search_volume
    title: "Searches and Clicks"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.searches, activity.search_clicks]
    sorts: [activity.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      activity.searches: "#1A73E8"
      activity.search_clicks: "#12B5CB"
    series_labels:
      activity.searches: Searches
      activity.search_clicks: Clicks
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 66
    col: 0
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_feedback
    title: "Feedback | Likes vs Dislikes"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.likes, activity.dislikes]
    sorts: [activity.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      activity.likes: "#1E8E3E"
      activity.dislikes: "#D93025"
    series_labels:
      activity.likes: Likes
      activity.dislikes: Dislikes
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 66
    col: 36
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_by_device
    title: "Searches by Device"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.device_type, activity.searches]
    pivots: [activity.device_type]
    sorts: [activity.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 81
    col: 0
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_page_visits
    title: "Page Visits by Surface"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.home_page_visits, activity.agent_page_visits, activity.prompts_page_visits, activity.notebook_lm_page_visits, activity.deep_research_page_visits, activity.idea_generation_page_visits]
    sorts: [activity.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 81
    col: 36
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_agent_types
    title: "Agent Sessions by Agent Type"
    type: looker_column
    model: gemini_enterprise
    explore: agents
    fields: [agents.metric_date, agents.agent_type, agents.agent_sessions]
    pivots: [agents.agent_type]
    sorts: [agents.metric_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    stacking: normal
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: agents.metric_date
      App: agents.app_name
    row: 96
    col: 0
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_dislike_reasons
    title: "Top Dislike Reasons"
    type: looker_grid
    model: gemini_enterprise
    explore: activity
    fields: [activity.dislike_reasons, activity.dislikes]
    filters:
      activity.dislike_reasons: "-NULL"
    sorts: ["activity.dislikes desc"]
    limit: 25
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      activity.dislike_reasons: Reason
      activity.dislikes: Dislikes
    series_cell_visualizations:
      activity.dislikes:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Reason codes users chose when giving negative feedback on Assistant answers."
    listen:
      Date: activity.metric_date
      App: activity.app_name
    row: 96
    col: 36
    width: 36
    height: 15
    tab_name: ge_analytics

  - name: ex_top_agents
    title: "Top Agents by Sessions | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: agents
    fields: [agents.agent_name, agents.agent_type, agents.agent_ownership, agents.agent_active_users, agents.agent_sessions]
    sorts: ["agents.agent_sessions desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      agents.agent_name: Agent
      agents.agent_type: Type
      agents.agent_ownership: Ownership
      agents.agent_active_users: Users
      agents.agent_sessions: Sessions
    series_cell_visualizations:
      agents.agent_active_users:
        is_active: true
      agents.agent_sessions:
        is_active: true
    defaults_version: 1
    listen:
      Date: agents.metric_date
      App: agents.app_name
    row: 111
    col: 0
    width: 72
    height: 24
    tab_name: ge_analytics

  - name: ex_top_queries
    title: "Top Search Queries | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: search_queries
    fields: [search_queries.query, search_queries.search_clicks, search_queries.searches]
    sorts: ["search_queries.searches desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      search_queries.query: Query
      search_queries.search_clicks: Clicks
      search_queries.searches: Searches
    series_cell_visualizations:
      search_queries.searches:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Populates once search volume exceeds Google's privacy suppression threshold."
    listen:
      Date: search_queries.metric_date
      App: search_queries.app_name
    row: 135
    col: 0
    width: 36
    height: 24
    tab_name: ge_analytics

  - name: ex_top_documents
    title: "Top Documents Surfaced | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: documents
    fields: [documents.document, documents.times_viewed, documents.times_surfaced_in_search]
    sorts: ["documents.times_surfaced_in_search desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      documents.document: Document
      documents.times_viewed: Views
      documents.times_surfaced_in_search: Surfaced
    series_cell_visualizations:
      documents.times_surfaced_in_search:
        is_active: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Populates above the suppression threshold."
    listen:
      Date: documents.metric_date
      App: documents.app_name
    row: 135
    col: 36
    width: 36
    height: 24
    tab_name: ge_analytics


  # ---------- Tab: workspace ----------
  - name: header_workspace
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Workspace Gemini</div>
          <div style="font-size: 13px; opacity: 0.85;">Gemini in Gmail, Docs, Meet and the Gemini app, from the Workspace audit export. Needs workspace_export set to separate_region or same_region.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: workspace

  - name: ws_users
    title: "Gemini Users"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_users, workspace_gemini_activity.event_month]
    fill_fields: [workspace_gemini_activity.event_month]
    sorts: ["workspace_gemini_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#12B5CB"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 5
    col: 0
    width: 24
    height: 8
    tab_name: workspace

  - name: ws_engaged
    title: "Engaged Users (Active Usage)"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.engaged_users, workspace_gemini_activity.event_month]
    fill_fields: [workspace_gemini_activity.event_month]
    sorts: ["workspace_gemini_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "#,##0"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#1A73E8"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Users with an active Gemini event: generate, converse or summarise, rather than a passive suggestion."
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 5
    col: 24
    width: 24
    height: 8
    tab_name: workspace

  - name: ws_active_rate
    title: "Active Usage Rate"
    type: single_value
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_usage_rate, workspace_gemini_activity.event_month]
    fill_fields: [workspace_gemini_activity.event_month]
    sorts: ["workspace_gemini_activity.event_month desc"]
    limit: 500
    total: true
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    value_format: "0.0%"
    show_chart_component: true
    kpi_chart_type: looker_column
    chart_color: "#174EA6"
    show_x_axis: true
    primary_row: total
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 5
    col: 48
    width: 24
    height: 8
    tab_name: workspace

  - name: ws_usage_trend
    title: "Gemini Events per Day"
    type: looker_area
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.event_date, workspace_gemini_activity.events, workspace_gemini_activity.active_events]
    sorts: [workspace_gemini_activity.event_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      workspace_gemini_activity.events: "#DADCE0"
      workspace_gemini_activity.active_events: "#12B5CB"
    series_labels:
      workspace_gemini_activity.events: "All events"
      workspace_gemini_activity.active_events: "Active usage"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 13
    col: 0
    width: 36
    height: 15
    tab_name: workspace

  - name: ws_users_trend
    title: "Gemini Users per Day"
    type: looker_line
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.event_date, workspace_gemini_activity.active_users, workspace_gemini_activity.engaged_users]
    sorts: [workspace_gemini_activity.event_date]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      workspace_gemini_activity.active_users: "#12B5CB"
      workspace_gemini_activity.engaged_users: "#1A73E8"
    series_labels:
      workspace_gemini_activity.active_users: Users
      workspace_gemini_activity.engaged_users: "Engaged users"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 13
    col: 36
    width: 36
    height: 15
    tab_name: workspace

  - name: ws_by_app
    title: "Usage by App"
    type: looker_bar
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.events, workspace_gemini_activity.active_users]
    sorts: ["workspace_gemini_activity.events desc"]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      workspace_gemini_activity.events: "#12B5CB"
      workspace_gemini_activity.active_users: "#174EA6"
    series_labels:
      workspace_gemini_activity.events: Events
      workspace_gemini_activity.active_users: Users
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: workspace_gemini_activity.events, id: workspace_gemini_activity.events, name: Events}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: workspace_gemini_activity.active_users, id: workspace_gemini_activity.active_users, name: Users}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 28
    col: 0
    width: 36
    height: 15
    tab_name: workspace

  - name: ws_by_org_unit
    title: "Adoption by Org Unit"
    type: looker_bar
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.org_unit_name_path, workspace_gemini_activity.active_users, workspace_gemini_activity.events]
    sorts: ["workspace_gemini_activity.active_users desc"]
    limit: 25
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_x_axis_label: false
    show_y_axis_labels: true
    show_value_labels: false
    x_axis_zoom: true
    y_axis_zoom: true
    show_legend: true
    legend_position: center
    point_style: none
    interpolation: monotone
    series_colors:
      workspace_gemini_activity.active_users: "#174EA6"
      workspace_gemini_activity.events: "#12B5CB"
    series_labels:
      workspace_gemini_activity.active_users: Users
      workspace_gemini_activity.events: Events
    y_axes:
    - {label: "", orientation: left, showLabels: true, showValues: true, series: [{axisId: workspace_gemini_activity.active_users, id: workspace_gemini_activity.active_users, name: Users}]}
    - {label: "", orientation: right, showLabels: true, showValues: true, series: [{axisId: workspace_gemini_activity.events, id: workspace_gemini_activity.events, name: Events}]}
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026_categorical_1
    modern2026: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 28
    col: 36
    width: 36
    height: 15
    tab_name: workspace

  - name: ws_top_features
    title: "Top Features | Top 50"
    type: looker_grid
    model: gemini_enterprise
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.feature_source, workspace_gemini_activity.active_users, workspace_gemini_activity.active_events, workspace_gemini_activity.events]
    sorts: ["workspace_gemini_activity.events desc"]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      workspace_gemini_activity.app_name: App
      workspace_gemini_activity.feature_source: Feature
      workspace_gemini_activity.active_users: Users
      workspace_gemini_activity.active_events: "Active Events"
      workspace_gemini_activity.events: Events
    series_cell_visualizations:
      workspace_gemini_activity.active_users:
        is_active: true
      workspace_gemini_activity.events:
        is_active: true
    defaults_version: 1
    listen:
      Date: workspace_gemini_activity.event_date
      User: workspace_gemini_activity.email
    row: 43
    col: 0
    width: 72
    height: 24
    tab_name: workspace


  # ---------- Tab: setup ----------
  - name: header_setup
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">Setup Health</div>
          <div style="font-size: 13px; opacity: 0.85;">Start here after installing: which sources the block can read, whether they are fresh, and what to do about any that aren't.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: setup

  - name: setup_intro
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; border-left: 4px solid #1A73E8; padding: 4px 14px;">
        <div style="font-size: 16px; font-weight: 600; color: #202124;">Is the block getting data?</div>
        <div style="font-size: 13px; color: #5f6368;">Red rows need action. Event tables (safety, connectors, admin changes, Antigravity) stay empty until those things happen, which is normal. Tabs that read a missing source show a table-not-found error until it exists.</div>
      </div>
    row: 5
    col: 0
    width: 54
    height: 8
    tab_name: setup

  - name: setup_problems
    title: "Tables Needing Attention"
    type: single_value
    model: gemini_enterprise
    explore: setup_health_tables
    fields: [setup_health_tables.tables_with_problems]
    custom_color_enabled: true
    show_single_value_title: true
    smart_single_value_size: false
    show_comparison: false
    table_theme: modern
    modern2026: true
    defaults_version: 1
    listen: {}
    row: 5
    col: 54
    width: 18
    height: 8
    tab_name: setup

  - name: setup_tables
    title: "Gemini Analytics Tables"
    type: looker_grid
    model: gemini_enterprise
    explore: setup_health_tables
    fields: [setup_health_tables.table_id, setup_health_tables.status, setup_health_tables.row_count, setup_health_tables.last_modified_time, setup_health_tables.feeds, setup_health_tables.next_step]
    sorts: [setup_health_tables.table_id]
    limit: 100
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      setup_health_tables.table_id: Table
      setup_health_tables.status: Status
      setup_health_tables.row_count: Rows
      setup_health_tables.last_modified_time: "Last Updated"
      setup_health_tables.feeds: Feeds
      setup_health_tables.next_step: "Next Step"
    defaults_version: 1
    listen: {}
    row: 13
    col: 0
    width: 72
    height: 15
    tab_name: setup

  - name: setup_workspace
    title: "Workspace Audit Export"
    type: looker_grid
    model: gemini_enterprise
    explore: setup_health_workspace
    fields: [setup_health_workspace.setting, setup_health_workspace.status, setup_health_workspace.row_count, setup_health_workspace.gemini_events_7d, setup_health_workspace.last_modified_time, setup_health_workspace.next_step]
    limit: 10
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      setup_health_workspace.setting: Setting
      setup_health_workspace.status: Status
      setup_health_workspace.row_count: Rows
      setup_health_workspace.gemini_events_7d: "Gemini Events (7d)"
      setup_health_workspace.last_modified_time: "Last Updated"
      setup_health_workspace.next_step: "Next Step"
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "A 'not found in location' error means the Workspace dataset is in a different BigQuery location from the Gemini analytics dataset: copy it (Terraform workspace_audit_dataset_id) or set Workspace audit export to separate_region. A 'Not found: Table' error means the activity table doesn't exist yet."
    listen: {}
    row: 28
    col: 0
    width: 72
    height: 9
    tab_name: setup

  - name: setup_settings
    title: "Install Settings"
    type: looker_grid
    model: gemini_enterprise
    explore: setup_settings
    fields: [setup_settings.setting, setup_settings.value]
    sorts: [setup_settings.setting]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    truncate_text: true
    size_to_fit: true
    table_theme: modern
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    header_background_color: "#E1EBFD"
    cell_bar_color: "#1A73E8"
    is_modern_theme: true
    modern2026: true
    show_totals: false
    show_row_totals: false
    show_sql_query_menu_options: false
    series_labels:
      setup_settings.setting: Setting
      setup_settings.value: Value
    defaults_version: 1
    note_state: collapsed
    note_display: hover
    note_text: "Change these in Marketplace > Manage on the block's listing."
    listen: {}
    row: 37
    col: 0
    width: 72
    height: 12
    tab_name: setup


  # ---------- Tab: about ----------
  - name: header_about
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="background-color: #0B1F3A; background-image: linear-gradient(120deg, #0B1F3A 0%, #174EA6 55%, #1A73E8 100%); border-radius: 8px; padding: 16px 28px; display: flex; align-items: center; justify-content: space-between; box-sizing: border-box; width: 100%; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15); font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #ffffff;">
        <div>
          <div style="font-size: 11px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; opacity: 0.75;">Gemini AI Adoption</div>
          <div style="font-size: 24px; font-weight: 600; line-height: 1.3;">About this Dashboard</div>
          <div style="font-size: 13px; opacity: 0.85;">What each tab answers, how the numbers are defined, and where to change the settings.</div>
        </div>
        <div style="font-size: 12px; text-align: right; line-height: 1.7; opacity: 0.85;">
          <span style="color: #8AB4F8;">&#9679;</span> Gemini Enterprise&nbsp;&nbsp;
          <span style="color: #12B5CB;">&#9679;</span> Gemini for Workspace&nbsp;&nbsp;
          <span style="color: #C58AF9;">&#9679;</span> Antigravity
        </div>
      </div>
    row: 0
    col: 0
    width: 72
    height: 5
    tab_name: about

  - name: about_card
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333; text-align: left; padding: 20px; background-color: #f9f9f9; border-radius: 8px; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15);">
        <h2 style="color: #1A73E8; margin-top: 0; margin-bottom: 15px;">About this dashboard</h2>
        <p style="margin-top: 0;"><strong>Main purpose:</strong><br>
        AI programme owners, change managers and IT use this dashboard to see how Gemini is being adopted, what it returns, and who to support next. Data comes from the Gemini Enterprise analytics export and logs, the Google Workspace audit export and Antigravity inference logs, all in BigQuery.</p>
        <p><strong>Tabs:</strong></p>
        <ul style="padding-left: 20px; margin-bottom: 15px;">
          <li style="margin-bottom: 5px;"><strong>Executive Overview:</strong> AI active users, actions, hours saved, activation per product and the department scorecard.</li>
          <li style="margin-bottom: 5px;"><strong>Cohorts &amp; Movement and People &amp; Leaderboards:</strong> Power, Normal, Casual and Non-AI users over time, who moved, and the most engaged people and teams.</li>
          <li style="margin-bottom: 5px;"><strong>Models &amp; Time of Day, Features &amp; Agents:</strong> model choice, Auto routing to advanced models, when AI gets used, and feature, agent and skill adoption.</li>
          <li style="margin-bottom: 5px;"><strong>ROI &amp; Value and Change Targeting:</strong> spend, estimated time saved, retention, and lists of people to train, nudge or license.</li>
          <li style="margin-bottom: 5px;"><strong>Safety &amp; Governance, Antigravity:</strong> Model Armor flags, admin changes and agentic coding.</li>
          <li><strong>Gemini Enterprise Analytics, Workspace Gemini, Setup Health:</strong> the app-level export (works without the log pipeline), the standalone Workspace view, and the install check.</li>
        </ul>
        <p style="margin-bottom: 0;"><strong>Filters:</strong><br>
        Date, Product, Department, User and App apply wherever the data supports them. Tiles marked (28d) or Latest Week are rolling windows and ignore Date. Hover a tile's info icon for its definition.</p>
      </div>
    row: 5
    col: 0
    width: 36
    height: 26
    tab_name: about

  - name: about_definitions
    type: text
    title_text: ""
    subtitle_text: ""
    body_text: |-
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333; text-align: left; padding: 20px; background-color: #f9f9f9; border-radius: 8px; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.15);">
        <h2 style="color: #1A73E8; margin-top: 0; margin-bottom: 15px;">How the numbers work</h2>
        <ul style="padding-left: 20px; margin-bottom: 15px;">
          <li style="margin-bottom: 5px;"><strong>AI action:</strong> a Gemini Enterprise prompt or search, an active Gemini event in a Workspace app (generate, converse, summarise), or an Antigravity request.</li>
          <li style="margin-bottom: 5px;"><strong>Cohorts:</strong> AI-active days in the trailing 28. Power 12+, Normal 4+, Casual 1+, Non-AI none but licensed or seen in Workspace. The thresholds are install settings.</li>
          <li style="margin-bottom: 5px;"><strong>Activation:</strong> AI active users over the population. Workspace Gemini divides by Workspace users seen in the audit log; Gemini Enterprise divides by licensed users.</li>
          <li style="margin-bottom: 5px;"><strong>Complex query rate:</strong> the share of Auto-mode prompts Gemini Enterprise routed to an advanced model (Pro, Ultra, Thinking).</li>
          <li style="margin-bottom: 5px;"><strong>Hours saved:</strong> actions times the minutes-saved-per-action setting. It's an estimate to calibrate with your own time studies, not a measurement.</li>
          <li><strong>Departments:</strong> the top level(s) of the Workspace org unit (org-unit depth install setting), when the Workspace export is in the same region.</li>
        </ul>
        <p style="margin-bottom: 0;"><strong>Settings:</strong><br>
        Seat costs, hourly rate, time zone, cohort thresholds and minutes saved are install settings (Marketplace &gt; Manage). The Setup Health tab lists the current values.</p>
      </div>
    row: 5
    col: 36
    width: 36
    height: 26
    tab_name: about

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
  - name: User
    title: User
    type: field_filter
    model: gemini_enterprise
    explore: ai_user_profile
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    listens_to_filters: [Department]
    field: ai_user_profile.user_email
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
