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
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:0 4px;">
          <div style="min-width:0;font-size:13px;color:#5F6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><b style="color:#202124;">Service Health.</b> What is failing, who it affects and what to do next. Click a person, reason or connector in any tile to filter the page.</div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:4px 12px;border-radius:16px;text-decoration:none;color:#5F6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:4px 12px;border-radius:16px;text-decoration:none;color:#5F6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:4px 12px;border-radius:16px;text-decoration:none;color:#5F6368;">Admin</a><a href="/dashboards/gemini_enterprise::gemini_ai_health" style="padding:4px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Health</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 3

    - name: section_overview
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;padding:0 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">01</span><span style="font-size:15px;font-weight:600;color:#202124;">Service overview</span></div>
      row: 3
      col: 0
      width: 72
      height: 3
    - name: health_status
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.health_status, gemini_health.prompts, gemini_health.failed_prompts, gemini_health.prompt_failure_rate, gemini_health.service_failed_prompts, gemini_health.service_failure_rate, gemini_health.connector_errors, gemini_health.connector_error_rate, gemini_health.armor_screened, gemini_health.armor_rejection_rate, gemini_health.top_prompt_issue, gemini_health.top_connector_issue, gemini_health.latest_event_time]
      hidden_fields: [gemini_health.prompts, gemini_health.failed_prompts, gemini_health.prompt_failure_rate, gemini_health.service_failed_prompts, gemini_health.service_failure_rate, gemini_health.connector_errors, gemini_health.connector_error_rate, gemini_health.armor_screened, gemini_health.armor_rejection_rate, gemini_health.top_prompt_issue, gemini_health.top_connector_issue, gemini_health.latest_event_time]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Department: user_org_unit.department
      show_single_value_title: false
      show_comparison: false
      row: 6
      col: 0
      width: 26
      height: 11
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
      row: 6
      col: 26
      width: 16
      height: 11
    - name: kpi_people_affected
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.people_affected_card]
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
      row: 6
      col: 42
      width: 11
      height: 11
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
      row: 6
      col: 53
      width: 11
      height: 11
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
      row: 6
      col: 64
      width: 8
      height: 11

    - name: section_fix
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;padding:0 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">02</span><span style="font-size:15px;font-weight:600;color:#202124;">What needs fixing?</span><span style="font-size:13px;color:#5F6368;margin-left:8px;">the three largest issues; hover the next step for what it means</span></div>
      row: 17
      col: 0
      width: 72
      height: 3
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
      row: 20
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
      limit: 8
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
          "yAxis": {"title": {"text": null}, "labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "plotOptions": {
            "series": {"dataLabels": {"style": {"fontSize": "13px", "fontWeight": "600", "textOutline": "none"}}},
            "bar": {"borderRadius": {"radius": 4, "where": "end"}, "pointPadding": 0.08, "groupPadding": 0.12}
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Click a reason to filter the page. Hover Details in Recent failures for what each reason means and the next step.
      row: 32
      col: 0
      width: 36
      height: 9
    - name: connector_errors_by_issue
      title: Connector errors by integration and reason
      type: looker_bar
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.connector_issue, gemini_health.connector_errors]
      filters:
        gemini_health.signal: Connector
      sorts: [gemini_health.connector_errors desc]
      limit: 8
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
          "yAxis": {"title": {"text": null}, "labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "plotOptions": {
            "series": {"dataLabels": {"style": {"fontSize": "13px", "fontWeight": "600", "textOutline": "none"}}},
            "bar": {"borderRadius": {"radius": 4, "where": "end"}, "pointPadding": 0.08, "groupPadding": 0.12}
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Connector tool failures by integration and error reason. The raw error message is not stored.
      row: 32
      col: 36
      width: 36
      height: 9

    - name: section_trend
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;padding:0 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">03</span><span style="font-size:15px;font-weight:600;color:#202124;">How is it changing?</span><span style="font-size:13px;color:#5F6368;margin-left:8px;">per day, for the selected dates; the Connector view filter switches the right chart between integration and reason</span></div>
      row: 41
      col: 0
      width: 72
      height: 3
    - name: prompt_failure_trend
      title: Share of prompts that failed, per day
      type: looker_line
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.event_date, gemini_health.prompt_failure_rate, gemini_health.prompts]
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
        gemini_health.prompts: column
      series_colors:
        gemini_health.prompt_failure_rate: '#C5221F'
        gemini_health.prompts: '#E8EAED'
      series_labels:
        gemini_health.prompt_failure_rate: Failed (% of prompts)
        gemini_health.prompts: Prompts sent
      y_axes:
        - label: ''
          orientation: left
          series:
            - id: gemini_health.prompt_failure_rate
              name: Failed (% of prompts)
              axisId: gemini_health.prompt_failure_rate
          showLabels: true
          showValues: true
          valueFormat: 0%
          unpinAxis: false
          type: linear
        - label: ''
          orientation: right
          series:
            - id: gemini_health.prompts
              name: Prompts sent
              axisId: gemini_health.prompts
          showLabels: true
          showValues: true
          unpinAxis: false
          type: linear
      x_axis_datetime_label: '%b %d'
      legend_position: center
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_x_axis_label: false
      show_value_labels: false
      point_style: circle
      interpolation: linear
      advanced_vis_config: |-
        {
          "chart": {"style": {"fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"}},
          "xAxis": {"labels": {"style": {"fontSize": "12px", "color": "#3C4043"}}},
          "yAxis": [{"title": {"text": null}}, {"title": {"text": null}}],
          "legend": {"itemStyle": {"fontSize": "12px", "fontWeight": "500", "color": "#3C4043"}},
          "plotOptions": {"line": {"lineWidth": 2.5, "marker": {"enabled": true, "radius": 3}, "zIndex": 2}, "column": {"borderRadius": 3}}
        }
      note_state: collapsed
      note_display: hover
      note_text: The red line is the share of that day's prompts that failed, so it isn't skewed by usage going up or down. The grey bars are prompt volume for context. A gap means no prompts that day. Days before the log pipeline started have no data.
      row: 44
      col: 0
      width: 36
      height: 10
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
      x_axis_datetime_label: '%b %d'
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
          "yAxis": {"title": {"text": null}, "labels": {"style": {"fontSize": "12px", "color": "#5F6368"}}},
          "legend": {"itemStyle": {"fontSize": "12px", "fontWeight": "500", "color": "#3C4043"}},
          "plotOptions": {"column": {"borderRadius": 3, "pointPadding": 0.08, "groupPadding": 0.12}}
        }
      note_state: collapsed
      note_display: hover
      note_text: Stacked by integration or by reason; switch with the Connector view filter at the end of the filter bar.
      row: 44
      col: 36
      width: 36
      height: 10

    - name: section_affected
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;padding:0 4px;"><span style="font-size:12px;font-weight:700;color:#1A73E8;margin-right:8px;">04</span><span style="font-size:15px;font-weight:600;color:#202124;">Who and what is affected?</span><span style="font-size:13px;color:#5F6368;margin-left:8px;">click a person or agent to filter the page; click a column header to sort</span></div>
      row: 54
      col: 0
      width: 72
      height: 3
    - name: most_affected_people
      title: Most affected people
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.user_email, user_org_unit.department, gemini_health.total_errors, gemini_health.failed_prompts, gemini_health.connector_errors, gemini_health.last_error_time]
      filters:
        gemini_health.is_failure: 'Yes'
        gemini_health.is_attributed: 'Yes'
      sorts: [gemini_health.total_errors desc]
      limit: 10
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
      note_text: The ten identified people with the most errors (failed prompts plus connector errors). Errors not linked to a person are summarised on the right, not here.
      row: 57
      col: 0
      width: 44
      height: 14
    - name: unattributed_errors
      title: ''
      type: single_value
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.unattributed_card, gemini_health.top_unattributed_issue, gemini_health.total_errors]
      hidden_fields: [gemini_health.top_unattributed_issue, gemini_health.total_errors]
      listen:
        Date: gemini_health.event_time
        App: gemini_health.app_name
        Agent: gemini_health.agent_name
        Integration: gemini_health.integration
        Reason: gemini_health.reason
      show_single_value_title: false
      show_comparison: false
      row: 57
      col: 44
      width: 28
      height: 7
    - name: affected_agents
      title: Failures by agent
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.agent_name, gemini_health.total_errors, gemini_health.failed_prompts, gemini_health.connector_errors, gemini_health.people_affected]
      filters:
        gemini_health.is_failure: 'Yes'
      sorts: [gemini_health.total_errors desc]
      limit: 5
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
        gemini_health.failed_prompts: Prompts
        gemini_health.connector_errors: Connector
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
      minimum_column_width: 60
      note_state: collapsed
      note_display: hover
      note_text: Not recorded means the prompt failed before an agent was chosen, usually a configuration or access failure.
      row: 64
      col: 44
      width: 28
      height: 7
    - name: recent_failures
      title: Recent failures
      type: looker_grid
      model: gemini_enterprise
      explore: gemini_health
      fields: [gemini_health.last_error_time, gemini_health.user_email, gemini_health.source, gemini_health.reason, gemini_health.occurrences, gemini_health.details, gemini_health.next_step]
      hidden_fields: [gemini_health.next_step]
      filters:
        gemini_health.is_failure: 'Yes'
      sorts: [gemini_health.last_error_time desc]
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
        gemini_health.last_error_time: Last seen (UTC)
        gemini_health.user_email: Person
        gemini_health.source: Source
        gemini_health.reason: Reason
        gemini_health.occurrences: Occurrences
        gemini_health.details: Details
      series_cell_visualizations:
        gemini_health.occurrences:
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
      note_text: Identical failures for the same person, source and reason are grouped, newest first. Hover Details for what it means and the next step; click Occurrences to see each event.
      row: 71
      col: 0
      width: 72
      height: 12
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
        display: popover
      listens_to_filters: []
      field: gemini_health.event_time
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
