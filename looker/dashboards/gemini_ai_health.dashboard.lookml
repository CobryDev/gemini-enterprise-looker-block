- dashboard: gemini_ai_health
  title: Gemini | Service Health
  preferred_viewer: dashboards-next
  description: Operational view for finding and fixing Gemini Enterprise failures. What is wrong, why it matters, who is affected and where to investigate.
  layout: newspaper
  layout_granularity: granular
  crossfilter_enabled: true
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
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">What is failing, who it affects and what to do next. Click a person, reason or connector to filter the page.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a><a href="/dashboards/gemini_enterprise::gemini_ai_health" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Health</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5

    - name: section_overview
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;padding:2px 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">01</span><span style="font-size:15px;font-weight:600;color:#202124;">Service overview</span></div>
      row: 5
      col: 0
      width: 72
      height: 2
    - name: health_status
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.health_status, gemini_health.prompts, gemini_health.failed_prompts, gemini_health.prompt_failure_rate, gemini_health.service_failed_prompts, gemini_health.service_failure_rate, gemini_health.connector_errors, gemini_health.connector_error_rate, gemini_health.armor_screened, gemini_health.armor_rejection_rate, gemini_health.first_event_time, gemini_health.latest_event_time]
      hidden_fields: [gemini_health.prompts, gemini_health.failed_prompts, gemini_health.prompt_failure_rate, gemini_health.service_failed_prompts, gemini_health.service_failure_rate, gemini_health.connector_errors, gemini_health.connector_error_rate, gemini_health.armor_screened, gemini_health.armor_rejection_rate, gemini_health.first_event_time, gemini_health.latest_event_time]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: false
      show_comparison: false
      note_state: collapsed
      note_display: hover
      note_text: Unknown means too few prompts to judge. Down needs service-side failures (timeouts, internal errors, the service unavailable); configuration and access failures such as a model not enabled or an expired connector sign-in make the status Degraded, because the service itself is still responding. Thresholds are set in Marketplace > Manage.
      row: 7
      col: 0
      width: 28
      height: 9
    - name: kpi_failed_prompts
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.failed_prompts_card, gemini_health.failed_prompts, gemini_health.prompts]
      hidden_fields: [gemini_health.failed_prompts, gemini_health.prompts]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
      show_single_value_title: false
      show_comparison: false
      row: 7
      col: 28
      width: 11
      height: 9
    - name: kpi_people_affected
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.people_affected_card, gemini_health.unattributed_errors]
      hidden_fields: [gemini_health.unattributed_errors]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      show_single_value_title: false
      show_comparison: false
      row: 7
      col: 39
      width: 11
      height: 9
    - name: kpi_total_errors
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.total_errors_card, gemini_health.failed_prompts, gemini_health.connector_errors]
      hidden_fields: [gemini_health.failed_prompts, gemini_health.connector_errors]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      show_single_value_title: false
      show_comparison: false
      note_state: collapsed
      note_display: hover
      note_text: Failed prompts plus connector errors, combined. It is not a separate error category. Model Armor rejections are counted separately.
      row: 7
      col: 50
      width: 11
      height: 9
    - name: kpi_model_armor
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.armor_card, gemini_health.armor_screened, gemini_health.armor_rejection_rate]
      hidden_fields: [gemini_health.armor_screened, gemini_health.armor_rejection_rate]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
      show_single_value_title: false
      show_comparison: false
      note_state: collapsed
      note_display: hover
      note_text: No data means Model Armor screened nothing in this period, usually because no template is attached to the app. It is not the same as zero rejections.
      row: 7
      col: 61
      width: 11
      height: 9

    - name: section_fix
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;padding:2px 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">02</span><span style="font-size:15px;font-weight:600;color:#202124;">What needs fixing?</span><span style="font-size:13px;color:#5f6368;margin-left:8px;">the largest issues, what they mean and the next step</span></div>
      row: 16
      col: 0
      width: 72
      height: 2
    - name: needs_attention
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health_issues
      fields: [gemini_health_issues.needs_attention_card]
      listen:
        Date: gemini_health_issues.date_filter
        App: gemini_health_issues.app_filter
        Department: gemini_health_issues.department_filter
        Person: gemini_health_issues.person_filter
        Agent: gemini_health_issues.agent_filter
        Integration: gemini_health_issues.integration_filter
        Reason: gemini_health_issues.reason_filter
      show_single_value_title: false
      show_comparison: false
      note_state: collapsed
      note_display: hover
      note_text: Each signal's largest issue, plus any issue with at least 10% of that signal's failures, up to four. Investigate filters the page to that reason. "People not identified" means the log couldn't be matched to a person, which is common for connector errors.
      row: 18
      col: 0
      width: 72
      height: 12
    - name: prompt_failures_by_reason
      title: Prompt failures by reason
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.reason, gemini_health.failed_prompts]
      filters:
        gemini_health.failed_prompts: '>0'
      sorts: [gemini_health.failed_prompts desc]
      limit: 10
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Reason: gemini_health.reason
      series_colors:
        gemini_health.failed_prompts: '#EE675C'
      series_labels:
        gemini_health.failed_prompts: Failed prompts
      legend_position: none
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      show_value_labels: true
      advanced_vis_config: |-
        {
          "chart": {"style": {"fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"}},
          "xAxis": {"labels": {"style": {"fontSize": "13px", "color": "#3C4043"}}},
          "yAxis": {"labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "plotOptions": {
            "series": {"dataLabels": {"style": {"fontSize": "13px", "fontWeight": "600", "textOutline": "none"}}},
            "bar": {"borderRadius": {"radius": 4, "where": "end"}, "pointPadding": 0.08, "groupPadding": 0.12}
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Click a reason to filter the page. See Recent failures for what each reason means and the next step.
      row: 30
      col: 0
      width: 36
      height: 10
    - name: connector_errors_by_issue
      title: Connector errors by integration and reason
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.connector_issue, gemini_health.connector_errors]
      filters:
        gemini_health.signal: Connector
      sorts: [gemini_health.connector_errors desc]
      limit: 10
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      series_colors:
        gemini_health.connector_errors: '#F9AB00'
      series_labels:
        gemini_health.connector_errors: Connector errors
      legend_position: none
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      show_value_labels: true
      advanced_vis_config: |-
        {
          "chart": {"style": {"fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"}},
          "xAxis": {"labels": {"style": {"fontSize": "13px", "color": "#3C4043"}}},
          "yAxis": {"labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "plotOptions": {
            "series": {"dataLabels": {"style": {"fontSize": "13px", "fontWeight": "600", "textOutline": "none"}}},
            "bar": {"borderRadius": {"radius": 4, "where": "end"}, "pointPadding": 0.08, "groupPadding": 0.12}
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Connector tool failures by integration and error reason. The raw error message is not stored.
      row: 30
      col: 36
      width: 36
      height: 10

    - name: section_trend
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;padding:2px 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">03</span><span style="font-size:15px;font-weight:600;color:#202124;">How is it changing?</span><span style="font-size:13px;color:#5f6368;margin-left:8px;">per day, for the selected dates</span></div>
      row: 40
      col: 0
      width: 72
      height: 2
    - name: prompt_failure_trend
      title: Prompt failure rate per day
      type: looker_column
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_date, gemini_health.failed_prompts, gemini_health.prompt_failure_rate]
      fill_fields: [gemini_health.event_date]
      filters:
        gemini_health.signal: Prompt
      sorts: [gemini_health.event_date]
      limit: 500
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
      series_types:
        gemini_health.prompt_failure_rate: line
      series_colors:
        gemini_health.failed_prompts: '#F6AEA9'
        gemini_health.prompt_failure_rate: '#C5221F'
      series_labels:
        gemini_health.failed_prompts: Failed prompts
        gemini_health.prompt_failure_rate: Failure rate
      y_axes:
        - label: Failed prompts
          orientation: left
          series:
            - id: gemini_health.failed_prompts
              name: Failed prompts
              axisId: gemini_health.failed_prompts
          showLabels: true
          showValues: true
          type: linear
        - label: Failure rate
          orientation: right
          series:
            - id: gemini_health.prompt_failure_rate
              name: Failure rate
              axisId: gemini_health.prompt_failure_rate
          showLabels: true
          showValues: true
          type: linear
      legend_position: center
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {"style": {"fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"}},
          "xAxis": {"labels": {"style": {"fontSize": "12px", "color": "#3C4043"}}},
          "legend": {"itemStyle": {"fontSize": "12px", "fontWeight": "500", "color": "#3C4043"}},
          "plotOptions": {"line": {"lineWidth": 2.5, "marker": {"enabled": true, "radius": 3}}}
        }
      note_state: collapsed
      note_display: hover
      note_text: The line is the share of prompts that failed; the bars are the failed-prompt count. A gap in the line means no prompts that day. Days before the log pipeline started have no data and are not shown, so a short chart means short history, not zero errors (see Data from on the status card).
      row: 42
      col: 0
      width: 36
      height: 11
    - name: connector_error_trend
      title: Connector errors per day
      type: looker_column
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_date, gemini_health.connector_group, gemini_health.connector_errors]
      pivots: [gemini_health.connector_group]
      fill_fields: [gemini_health.event_date]
      filters:
        gemini_health.signal: Connector
      sorts: [gemini_health.event_date, gemini_health.connector_group]
      limit: 500
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
        Connector view: gemini_health.connector_breakdown
      stacking: normal
      legend_position: center
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {"style": {"fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"}},
          "xAxis": {"labels": {"style": {"fontSize": "12px", "color": "#3C4043"}}},
          "yAxis": {"labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "legend": {"itemStyle": {"fontSize": "12px", "fontWeight": "500", "color": "#3C4043"}},
          "plotOptions": {"column": {"borderRadius": 3, "pointPadding": 0.08, "groupPadding": 0.12}}
        }
      note_state: collapsed
      note_display: hover
      note_text: Stacked by integration or by reason; switch with the Connector view filter.
      row: 42
      col: 36
      width: 36
      height: 11

    - name: section_affected
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;padding:2px 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">04</span><span style="font-size:15px;font-weight:600;color:#202124;">Who and what is affected?</span><span style="font-size:13px;color:#5f6368;margin-left:8px;">click a person or agent to filter the page; click a column header to sort</span></div>
      row: 53
      col: 0
      width: 72
      height: 2
    - name: most_affected_people
      title: Most affected people
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.user_email, user_org_unit.department, gemini_health.total_errors, gemini_health.failed_prompts, gemini_health.connector_errors, gemini_health.armor_rejections, gemini_health.last_error_time]
      filters:
        gemini_health.is_failure: 'Yes'
        gemini_health.user_email: '-NULL'
      sorts: [gemini_health.total_errors desc]
      limit: 25
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      series_labels:
        gemini_health.user_email: Person
        user_org_unit.department: Department
        gemini_health.total_errors: Total errors
        gemini_health.failed_prompts: Failed prompts
        gemini_health.connector_errors: Connector errors
        gemini_health.armor_rejections: Model Armor
        gemini_health.last_error_time: Last failure (UTC)
      series_cell_visualizations:
        gemini_health.total_errors:
          is_active: true
          palette:
            palette_id: gemini-health-errors
            collection_id: legacy
            custom_colors: ['#EE675C', '#EE675C']
        gemini_health.failed_prompts:
          is_active: false
        gemini_health.connector_errors:
          is_active: false
        gemini_health.armor_rejections:
          is_active: false
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '13'
      rows_font_size: '13'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 80
      note_state: collapsed
      note_display: hover
      note_text: Who to help first, sorted by total errors (failed prompts plus connector errors). Sort by any column, including Last failure. Errors that couldn't be matched to a person are left out; the People affected card counts them.
      row: 55
      col: 0
      width: 44
      height: 12
    - name: affected_agents
      title: Failures by agent
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.agent_name, gemini_health.total_errors, gemini_health.failed_prompts, gemini_health.connector_errors, gemini_health.people_affected]
      filters:
        gemini_health.is_failure: 'Yes'
        gemini_health.agent_name: '-NULL'
      sorts: [gemini_health.total_errors desc]
      limit: 25
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      series_labels:
        gemini_health.agent_name: Agent
        gemini_health.total_errors: Total errors
        gemini_health.failed_prompts: Failed prompts
        gemini_health.connector_errors: Connector errors
        gemini_health.people_affected: People
      series_cell_visualizations:
        gemini_health.total_errors:
          is_active: true
          palette:
            palette_id: gemini-health-errors
            collection_id: legacy
            custom_colors: ['#EE675C', '#EE675C']
        gemini_health.failed_prompts:
          is_active: false
        gemini_health.connector_errors:
          is_active: false
        gemini_health.people_affected:
          is_active: false
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '13'
      rows_font_size: '13'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 70
      row: 55
      col: 44
      width: 28
      height: 12
    - name: recent_failures
      title: Recent failures | what each means and what to do
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_time, gemini_health.user_email, gemini_health.signal, gemini_health.failure_class, gemini_health.integration, gemini_health.reason, gemini_health.explanation, gemini_health.next_step, gemini_health.agent_name]
      filters:
        gemini_health.is_failure: 'Yes'
      sorts: [gemini_health.event_time desc]
      limit: 200
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
        Person: gemini_health.user_email
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      series_labels:
        gemini_health.event_time: Time (UTC)
        gemini_health.user_email: Person
        gemini_health.signal: Signal
        gemini_health.failure_class: Type
        gemini_health.integration: Integration
        gemini_health.reason: Reason
        gemini_health.explanation: What it means
        gemini_health.next_step: Next step
        gemini_health.agent_name: Agent
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '13'
      rows_font_size: '12'
      truncate_text: false
      size_to_fit: true
      minimum_column_width: 80
      note_state: collapsed
      note_display: hover
      note_text: The latest 200 failures in the selected dates. Use the filters above, or click a person, reason or connector in any tile, to narrow it down.
      row: 67
      col: 0
      width: 72
      height: 14
  filters:
    - name: Date
      title: Date
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: 7 day
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      listens_to_filters: []
      field: gemini_health.event_time
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
    - name: Person
      title: Person
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: ''
      allow_multiple_values: true
      required: false
      ui_config:
        type: tag_list
        display: popover
      listens_to_filters: []
      field: gemini_health.user_email
    - name: Agent
      title: Agent
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
      field: gemini_health.agent_name
    - name: Integration
      title: Integration
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
      field: gemini_health.integration
    - name: Reason
      title: Reason
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
      field: gemini_health.reason
    - name: Connector view
      title: Connector view
      type: field_filter
      model: gemini_enterprise
      explore: gemini_health
      default_value: integration
      allow_multiple_values: false
      required: true
      ui_config:
        type: button_toggles
        display: inline
      listens_to_filters: []
      field: gemini_health.connector_breakdown
