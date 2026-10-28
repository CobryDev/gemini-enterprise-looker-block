- dashboard: gemini_ai_health
  title: Gemini | Service Health
  preferred_viewer: dashboards-next
  description: Operational view of Gemini Enterprise reliability, Model Armor rejections and connector failures.
  layout: newspaper
  layout_granularity: granular
  elements:
    - name: header_health
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Health</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Service Health</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Prompt failures, connector errors, Model Armor rejections and the people most affected.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a><a href="/dashboards/gemini_enterprise::gemini_ai_health" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Health</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
    - name: health_status
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.health_status_card]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: false
      show_comparison: false
      row: 5
      col: 0
      width: 32
      height: 8
    - name: health_prompt_failure_rate
      title: Prompt failure rate
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.prompt_failure_rate]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#EE675C'
      row: 5
      col: 32
      width: 14
      height: 4
    - name: health_failed_prompts
      title: Failed prompts
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.failed_prompts]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 46
      width: 13
      height: 4
    - name: health_people_affected
      title: People affected
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.people_affected]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 59
      width: 13
      height: 4
    - name: health_armor_rejection_rate
      title: Model Armor rejection rate
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.armor_rejection_rate]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#5F6368'
      row: 9
      col: 32
      width: 14
      height: 4
    - name: health_connector_errors
      title: Connector errors
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.connector_errors]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 9
      col: 46
      width: 13
      height: 4
    - name: health_service_errors
      title: Service errors
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.total_errors]
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 9
      col: 59
      width: 13
      height: 4
    - name: errors_last_30_days
      title: Errors per day | last 30 days
      type: looker_column
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_date, gemini_health.signal, gemini_health.affected_events]
      pivots: [gemini_health.signal]
      filters:
        gemini_health.health_window: '30'
        gemini_health.affected_events: '>0'
      sorts: [gemini_health.event_date]
      limit: 30
      listen:
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 13
      col: 0
      width: 36
      height: 10
      stacking: normal
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_value_labels: false
      series_colors:
        Prompt: '#EE675C'
        Connector: '#F9AB00'
        Model Armor: '#5F6368'
      note_state: collapsed
      note_display: hover
      note_text: Daily failed prompts, connector errors and distinct Model Armor rejections. This trend is fixed to the last 30 days so you can see whether the selected window is unusual.
    - name: prompt_outcomes_health
      title: Prompt outcomes per day
      type: looker_column
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_date, gemini_health.outcome, gemini_health.prompts]
      pivots: [gemini_health.outcome]
      filters:
        gemini_health.prompts: '>0'
      sorts: [gemini_health.event_date]
      limit: 90
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 13
      col: 36
      width: 36
      height: 10
      stacking: normal
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_value_labels: false
      series_colors:
        Answered: '#1A73E8'
        Failed: '#EE675C'
        Blocked: '#5F6368'
        No answer recorded: '#DADCE0'
      note_state: collapsed
      note_display: hover
      note_text: Gemini Enterprise prompts by what happened in the selected window. Failed means the request returned an error; Blocked means Gemini Enterprise skipped the answer for policy or safety reasons.
    - name: prompt_failure_reasons_health
      title: What are the errors? | prompt failures
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.reason, gemini_health.detail, gemini_health.failed_prompts]
      filters:
        gemini_health.failed_prompts: '>0'
      sorts: [gemini_health.failed_prompts desc]
      limit: 10
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 23
      col: 0
      width: 24
      height: 10
      series_colors:
        gemini_health.failed_prompts: '#EE675C'
      legend_position: none
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      show_value_labels: true
      note_state: collapsed
      note_display: hover
      note_text: Failed prompts by returned error code and non-sensitive failure detail.
    - name: armor_rejections_health
      title: What are the errors? | Model Armor rejections
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.reason, gemini_health.screened_content, gemini_health.armor_rejections]
      pivots: [gemini_health.screened_content]
      filters:
        gemini_health.armor_rejections: '>0'
      sorts: [gemini_health.armor_rejections desc]
      limit: 10
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 23
      col: 24
      width: 24
      height: 10
      series_colors:
        PROMPT: '#5F6368'
        RESPONSE: '#9AA0A6'
      legend_position: center
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      show_value_labels: true
      note_state: collapsed
      note_display: hover
      note_text: Distinct screened prompts or responses rejected by Model Armor, split by category and screened content.
    - name: connector_errors_health
      title: What are the errors? | connectors
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.reason, gemini_health.detail, gemini_health.connector_errors]
      filters:
        gemini_health.connector_errors: '>0'
      sorts: [gemini_health.connector_errors desc]
      limit: 10
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 23
      col: 48
      width: 24
      height: 10
      series_colors:
        gemini_health.connector_errors: '#F9AB00'
      legend_position: none
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      show_value_labels: true
      note_state: collapsed
      note_display: hover
      note_text: Connector tool failures by category and connector type. The raw connector error message is not stored.
    - name: most_affected_people
      title: Most affected people
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.user_email, user_org_unit.department, gemini_health.failed_prompts, gemini_health.connector_errors, gemini_health.armor_rejections, gemini_health.affected_events, gemini_health.last_error_time]
      filters:
        gemini_health.affected_events: '>0'
      sorts: [gemini_health.affected_events desc]
      limit: 25
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 33
      col: 0
      width: 44
      height: 12
      series_labels:
        gemini_health.user_email: User
        user_org_unit.department: Department
        gemini_health.failed_prompts: Failed prompts
        gemini_health.connector_errors: Connector errors
        gemini_health.armor_rejections: Model Armor rejections
        gemini_health.affected_events: Total
        gemini_health.last_error_time: Last error
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 80
      note_state: collapsed
      note_display: hover
      note_text: People with the most failed prompts, connector errors and Model Armor rejections in the selected window.
    - name: failure_detail_health
      title: Failures by reason and agent
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.reason, gemini_health.agent_name, gemini_health.failed_prompts, gemini_health.people_affected]
      filters:
        gemini_health.failed_prompts: '>0'
      sorts: [gemini_health.failed_prompts desc]
      limit: 50
      listen:
        Window: gemini_health.health_window
        App: gemini_health.app_name
        Department: user_org_unit.department
      row: 33
      col: 44
      width: 28
      height: 12
      series_labels:
        gemini_health.reason: Reason
        gemini_health.agent_name: Agent
        gemini_health.failed_prompts: Failed prompts
        gemini_health.people_affected: People
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 80
      note_state: collapsed
      note_display: hover
      note_text: Where prompt failures cluster. Drill into Failed prompts for the individual requests, people and times.
  filters:
    - name: Window
      title: Window
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: '1'
      allow_multiple_values: false
      required: true
      ui_config:
        type: button_toggles
        display: inline
      listens_to_filters: []
      field: gemini_health.health_window
    - name: App
      title: Gemini Enterprise App
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: ''
      allow_multiple_values: true
      required: false
      ui_config:
        type: dropdown_menu
        display: popover
      listens_to_filters: []
      field: gemini_health.app_name
    - name: Department
      title: Department
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: ''
      allow_multiple_values: true
      required: false
      ui_config:
        type: dropdown_menu
        display: popover
      listens_to_filters: []
      field: user_org_unit.department
