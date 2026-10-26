- dashboard: gemini_ai_change
  title: Gemini | AI Change Management
  preferred_viewer: dashboards-next
  description: Operational dashboard for adoption opportunities, cohorts, use cases, coaching and intervention measurement.
  layout: newspaper
  layout_granularity: granular
  tabs:
    - name: opportunities
      label: Opportunities
    - name: adoption_cohorts
      label: Adoption & Cohorts
    - name: use_cases
      label: Use Cases
    - name: people_coaching
      label: People & Coaching
    - name: interventions
      label: Interventions
  elements:
    - name: header_change
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Change management</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Opportunities</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Where adoption is struggling and who owns the next step.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: opportunities
    - name: opportunity_queue
      title: Opportunity queue | hover an opportunity for the evidence
      type: looker_grid
      model: gemini_enterprise
      explore: ai_opportunities
      fields: [ai_opportunities.priority_label, ai_opportunities.action_title, ai_opportunities.impact, ai_interventions.owner_or_unassigned, ai_interventions.status_or_not_started, ai_opportunities.next_step, ai_opportunities.evidence, ai_opportunities.priority, ai_opportunities.size]
      hidden_fields: [ai_opportunities.evidence, ai_opportunities.priority, ai_opportunities.size]
      filters:
        ai_opportunities.is_actionable: 'Yes'
      show_view_names: false
      show_row_numbers: false
      truncate_text: true
      size_to_fit: true
      series_labels:
        ai_opportunities.priority_label: Priority
        ai_opportunities.action_title: Opportunity
        ai_opportunities.impact: Impact
        ai_interventions.owner_or_unassigned: Owner
        ai_interventions.status_or_not_started: Status
        ai_opportunities.next_step: Next step
      note_state: collapsed
      note_display: hover
      note_text: Owner, status and follow-up come from interventions logged with a matching opportunity_type (and department, for department opportunities). See the Interventions tab for how to log one.
      sorts: [ai_opportunities.priority, ai_opportunities.size desc]
      limit: 50
      row: 5
      col: 0
      width: 72
      height: 11
      tab_name: opportunities
      series_column_widths:
        ai_opportunities.priority_label: 90
        ai_interventions.owner_or_unassigned: 130
        ai_interventions.status_or_not_started: 110
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      minimum_column_width: 80
    - name: room_to_grow
      title: Casual or non-AI
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.casual_or_non_ai_share, ai_user_profile.casual_users, ai_user_profile.non_ai_users, ai_user_profile.people]
      row: 16
      col: 0
      width: 18
      height: 5
      tab_name: opportunities
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      hidden_fields: [ai_user_profile.casual_users, ai_user_profile.non_ai_users, ai_user_profile.people]
    - name: idle_licences
      title: Idle licences
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.idle_ge_licences, ai_user_profile.ge_licensed_users]
      row: 16
      col: 18
      width: 18
      height: 5
      tab_name: opportunities
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      hidden_fields: [ai_user_profile.ge_licensed_users]
    - name: workspace_only
      title: Workspace-only users
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.gws_active_users, ai_user_profile.ge_active_licensed_users]
      row: 16
      col: 36
      width: 18
      height: 5
      tab_name: opportunities
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      hidden_fields: [ai_user_profile.ge_active_licensed_users]
    - name: licence_requests
      title: Licence requests
      type: single_value
      model: gemini_enterprise
      explore: ge_user_licenses
      fields: [ge_user_licenses.unlicensed_login_attempts]
      filters:
        ge_user_licenses.is_latest_snapshot: 'yes'
      row: 16
      col: 54
      width: 18
      height: 5
      tab_name: opportunities
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: department_room
      title: Departments | most room to grow
      type: looker_grid
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.people, ai_user_profile.ai_active_users, ai_user_profile.ai_activation_rate, ai_user_profile.casual_users, ai_user_profile.non_ai_users]
      sorts: [ai_user_profile.non_ai_users desc]
      limit: 30
      listen:
        Department: user_org_unit.department
      row: 21
      col: 0
      width: 36
      height: 12
      tab_name: opportunities
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
    - name: idle_licence_list
      title: Idle licences | check before reclaiming
      type: looker_grid
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.licence_assigned_date, ai_user_profile.days_since_last_ai_use, ai_user_profile.ge_days_28d]
      filters:
        ai_user_profile.is_ge_licensed: 'yes'
        ai_user_profile.ge_days_28d: '0'
      sorts: [ai_user_profile.licence_assigned_date desc]
      limit: 50
      listen:
        Department: user_org_unit.department
      row: 21
      col: 36
      width: 36
      height: 12
      tab_name: opportunities
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
    - name: cohorts_header
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Change management</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Adoption & cohorts</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Who uses AI habitually. Cohorts count AI-active days in the last 28 days; movement compares complete weeks.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: adoption_cohorts
    - name: newly_active_kpi
      title: Newly active | last week
      type: single_value
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.newly_active]
      filters:
        ai_user_cohort_weekly.is_latest_week: 'Yes'
      note_state: collapsed
      note_display: hover
      note_text: People who were Non-AI or new the week before and are now Casual or above. Cohorts use the trailing 28 days up to the week end.
      listen:
        Department: user_org_unit.department
      row: 5
      col: 0
      width: 18
      height: 5
      tab_name: adoption_cohorts
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#1A73E8'
    - name: moved_up_kpi
      title: Moved up | last week
      type: single_value
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.moved_up]
      filters:
        ai_user_cohort_weekly.is_latest_week: 'Yes'
      note_state: collapsed
      note_display: hover
      note_text: Already-active people who moved to a higher cohort than the week before.
      listen:
        Department: user_org_unit.department
      row: 5
      col: 18
      width: 18
      height: 5
      tab_name: adoption_cohorts
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#188038'
    - name: moved_down_kpi
      title: Moved down | last week
      type: single_value
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.moved_down]
      filters:
        ai_user_cohort_weekly.is_latest_week: 'Yes'
      note_state: collapsed
      note_display: hover
      note_text: People who moved to a lower cohort, including lapsing to Non-AI. See People & Coaching for names.
      listen:
        Department: user_org_unit.department
      row: 5
      col: 36
      width: 18
      height: 5
      tab_name: adoption_cohorts
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#D93025'
    - name: unchanged_kpi
      title: No change | last week
      type: single_value
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.unchanged]
      filters:
        ai_user_cohort_weekly.is_latest_week: 'Yes'
      note_state: collapsed
      note_display: hover
      note_text: People whose cohort was the same as the week before.
      listen:
        Department: user_org_unit.department
      row: 5
      col: 54
      width: 18
      height: 5
      tab_name: adoption_cohorts
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#5f6368'
    - name: cohort_cards
      title: Cohort mix now | eligible people, last 28 days
      type: looker_bar
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.cohort, ai_user_profile.people]
      pivots: [ai_user_profile.cohort]
      sorts: [ai_user_profile.cohort]
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
        Power|FIELD|1 - ai_user_profile.people: '#174EA6'
        Power - ai_user_profile.people: '#174EA6'
        Normal|FIELD|2 - ai_user_profile.people: '#1A73E8'
        Normal - ai_user_profile.people: '#1A73E8'
        Casual|FIELD|3 - ai_user_profile.people: '#8AB4F8'
        Casual - ai_user_profile.people: '#8AB4F8'
        Non-AI|FIELD|4 - ai_user_profile.people: '#DADCE0'
        Non-AI - ai_user_profile.people: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 10
      col: 0
      width: 36
      height: 9
      tab_name: adoption_cohorts
    - name: cohort_trend
      title: Cohort share per week | last 12 complete weeks
      type: looker_area
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
      pivots: [ai_user_cohort_weekly.cohort]
      sorts: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort]
      limit: 52
      stacking: percent
      show_view_names: false
      y_axis_gridlines: true
      legend_position: center
      series_colors:
        Power|FIELD|1 - ai_user_cohort_weekly.people: '#174EA6'
        Power - ai_user_cohort_weekly.people: '#174EA6'
        Normal|FIELD|2 - ai_user_cohort_weekly.people: '#1A73E8'
        Normal - ai_user_cohort_weekly.people: '#1A73E8'
        Casual|FIELD|3 - ai_user_cohort_weekly.people: '#8AB4F8'
        Casual - ai_user_cohort_weekly.people: '#8AB4F8'
        Non-AI|FIELD|4 - ai_user_cohort_weekly.people: '#DADCE0'
        Non-AI - ai_user_cohort_weekly.people: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 10
      col: 36
      width: 36
      height: 9
      tab_name: adoption_cohorts
      filters:
        ai_user_cohort_weekly.week_end_date: 12 weeks
      x_axis_gridlines: false
      show_x_axis_label: false
      point_style: none
      interpolation: monotone
    - name: cohort_movement
      title: Cohort movement | last 12 complete weeks
      type: looker_column
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.newly_active, ai_user_cohort_weekly.moved_up, ai_user_cohort_weekly.moved_down]
      sorts: [ai_user_cohort_weekly.week_end_week]
      limit: 12
      show_view_names: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        ai_user_cohort_weekly.newly_active: '#1A73E8'
        ai_user_cohort_weekly.moved_up: '#188038'
        ai_user_cohort_weekly.moved_down: '#D93025'
      series_labels:
        ai_user_cohort_weekly.newly_active: Newly active
        ai_user_cohort_weekly.moved_up: Moved up
        ai_user_cohort_weekly.moved_down: Moved down
      listen:
        Department: user_org_unit.department
      row: 19
      col: 0
      width: 36
      height: 10
      tab_name: adoption_cohorts
      filters:
        ai_user_cohort_weekly.week_end_date: 12 weeks
      show_value_labels: true
      x_axis_gridlines: false
      show_x_axis_label: false
    - name: cohort_by_department
      title: Cohort mix by department | eligible people, last 28 days
      type: looker_bar
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.cohort, ai_user_profile.people]
      pivots: [ai_user_profile.cohort]
      sorts: [ai_user_profile.cohort, ai_user_profile.people desc 0]
      limit: 20
      stacking: percent
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        Power|FIELD|1 - ai_user_profile.people: '#174EA6'
        Power - ai_user_profile.people: '#174EA6'
        Normal|FIELD|2 - ai_user_profile.people: '#1A73E8'
        Normal - ai_user_profile.people: '#1A73E8'
        Casual|FIELD|3 - ai_user_profile.people: '#8AB4F8'
        Casual - ai_user_profile.people: '#8AB4F8'
        Non-AI|FIELD|4 - ai_user_profile.people: '#DADCE0'
        Non-AI - ai_user_profile.people: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 19
      col: 36
      width: 36
      height: 10
      tab_name: adoption_cohorts
      show_x_axis_label: false
    - name: use_cases_header
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Change management</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Use cases</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">What people use AI for. Hands-on actions only; automated runs and suggestions are shown separately.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: use_cases
    - name: use_case_actions
      title: Volume by use case | hands-on actions
      type: looker_bar
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.use_case, ai_activity_hourly.ai_actions]
      sorts: [ai_activity_hourly.ai_actions desc]
      limit: 15
      show_value_labels: true
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: none
      series_colors:
        ai_activity_hourly.ai_actions: '#8AB4F8'
      note_state: collapsed
      note_display: hover
      note_text: Hands-on AI actions by eligible people in the selected dates. Automated Flow runs and proactive suggestions are excluded.
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 10
      col: 42
      width: 30
      height: 12
      tab_name: use_cases
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
    - name: use_case_people
      title: How widely is each use case adopted? | people with a hands-on action
      type: looker_bar
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.use_case, ai_activity_hourly.ai_users]
      sorts: [ai_activity_hourly.ai_users desc]
      limit: 15
      show_value_labels: true
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: none
      series_colors:
        ai_activity_hourly.ai_users: '#1A73E8'
      note_state: collapsed
      note_display: hover
      note_text: Distinct eligible people with at least one hands-on action in each use case in the selected dates. One person can appear in several use cases.
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 10
      col: 0
      width: 42
      height: 12
      tab_name: use_cases
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
    - name: unclassified_share
      title: Unclassified share
      type: single_value
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.unclassified_action_share, ai_activity_hourly.unclassified_actions, ai_activity_hourly.ai_actions]
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 5
      col: 0
      width: 18
      height: 5
      tab_name: use_cases
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      hidden_fields: [ai_activity_hourly.unclassified_actions, ai_activity_hourly.ai_actions]
    - name: use_cases_used
      title: Use cases in use
      type: single_value
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.use_cases_used]
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 5
      col: 18
      width: 18
      height: 5
      tab_name: use_cases
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: passive_share
      title: Passive share of events
      note_display: hover
      note_text: Automated workflow and agent runs plus proactive suggestions, as a share of all Gemini events. These are excluded from adoption metrics.
      type: single_value
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.passive_event_share]
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 5
      col: 36
      width: 18
      height: 5
      tab_name: use_cases
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: automation_users
      title: People using automation
      type: single_value
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.automation_users]
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 5
      col: 54
      width: 18
      height: 5
      tab_name: use_cases
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: interaction_mode_trend
      title: Weekly AI events | hands-on vs automated vs proactive, complete weeks
      note_display: hover
      note_text: 'Active: a person asked Gemini. Automated: workflows and scheduled or triggered agents. Proactive: suggestions Gemini made unprompted.'
      type: looker_column
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.event_week, ai_activity_hourly.interaction_mode, ai_activity_hourly.ai_events]
      filters:
        ai_activity_hourly.is_complete_week: 'Yes'
      pivots: [ai_activity_hourly.interaction_mode]
      sorts: [ai_activity_hourly.event_week, ai_activity_hourly.interaction_mode]
      limit: 26
      stacking: normal
      series_colors:
        Active - ai_activity_hourly.ai_events: '#1A73E8'
        Automated - ai_activity_hourly.ai_events: '#9AA0A6'
        Proactive - ai_activity_hourly.ai_events: '#DADCE0'
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 33
      col: 0
      width: 72
      height: 9
      tab_name: use_cases
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      legend_position: center
    - name: use_case_trend
      title: Weekly actions by use case | top 3 and other, complete weeks
      type: looker_column
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.event_week, ai_activity_hourly.use_case_group, ai_activity_hourly.ai_actions]
      filters:
        ai_activity_hourly.is_complete_week: 'Yes'
      pivots: [ai_activity_hourly.use_case_group]
      sorts: [ai_activity_hourly.use_case_group, ai_activity_hourly.event_week]
      limit: 26
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 22
      col: 0
      width: 36
      height: 11
      tab_name: use_cases
      stacking: normal
      color_application:
        collection_id: google
        custom:
          id: use-case-top3
          label: Use case top 3
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#DADCE0']
      series_colors:
        Other|FIELD|4 - ai_activity_hourly.ai_actions: '#DADCE0'
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      legend_position: center
    - name: feature_mapping
      title: Feature to use-case mapping | detail
      type: looker_grid
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.product, ai_activity_hourly.feature_label, ai_activity_hourly.feature, ai_activity_hourly.use_case, ai_activity_hourly.use_case_confidence, ai_activity_hourly.ai_actions]
      hidden_fields: [ai_activity_hourly.feature]
      show_view_names: false
      sorts: [ai_activity_hourly.ai_actions desc]
      limit: 50
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 22
      col: 36
      width: 36
      height: 11
      tab_name: use_cases
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 80
    - name: people_header
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Change management</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">People & coaching</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Named people for authorised coaching follow-up. Use activity counts to find people to support, and never to rate their productivity.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: people_coaching
    - name: potential_champions
      title: Potential champions
      type: looker_grid
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.cohort, ai_user_profile.ai_days_28d, ai_user_profile.ai_actions_28d, ai_user_profile.product_mix]
      filters:
        ai_user_profile.cohort: Power,Normal
      sorts: [ai_user_profile.ai_days_28d desc]
      limit: 50
      listen:
        Department: user_org_unit.department
      row: 5
      col: 0
      width: 36
      height: 12
      tab_name: people_coaching
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
    - name: ready_to_move_up
      title: Ready to move up | casual users
      type: looker_grid
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.user_email, user_org_unit.department, ai_user_profile.cohort, ai_user_profile.ai_days_28d, ai_user_profile.ai_actions_28d, ai_user_profile.last_ai_date]
      filters:
        ai_user_profile.cohort: Casual
      sorts: [ai_user_profile.ai_days_28d desc]
      limit: 50
      listen:
        Department: user_org_unit.department
      row: 5
      col: 36
      width: 36
      height: 12
      tab_name: people_coaching
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
    - name: moved_down
      title: At risk | moved down a cohort
      type: looker_grid
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.user_email, user_org_unit.department, ai_user_cohort_weekly.previous_cohort, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.ai_days]
      filters:
        ai_user_cohort_weekly.is_latest_week: 'yes'
        ai_user_cohort_weekly.cohort_movement: Moved down
      sorts: [ai_user_cohort_weekly.ai_days]
      limit: 50
      listen:
        Department: user_org_unit.department
      row: 17
      col: 0
      width: 36
      height: 12
      tab_name: people_coaching
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
    - name: licence_request_list
      title: People asking for a licence
      type: looker_grid
      model: gemini_enterprise
      explore: ge_user_licenses
      fields: [ge_user_licenses.user_email, ge_user_licenses.location, ge_user_licenses.last_login_date, ge_user_licenses.license_state]
      filters:
        ge_user_licenses.is_latest_snapshot: 'yes'
        ge_user_licenses.license_state: NO_LICENSE_ATTEMPTED_LOGIN
      sorts: [ge_user_licenses.last_login_date desc]
      limit: 50
      row: 17
      col: 36
      width: 36
      height: 12
      tab_name: people_coaching
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
    - name: interventions_header
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Change management</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Interventions</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Did training, campaigns and coaching work? Before and after comparisons show direction only, because other changes happen at the same time.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: interventions
    - name: open_interventions
      title: Open interventions
      type: looker_grid
      model: gemini_enterprise
      explore: ai_interventions
      fields: [ai_interventions.name, ai_interventions.owner_or_unassigned, ai_interventions.target_scope, ai_interventions.status, ai_interventions.follow_up_date, ai_interventions.is_overdue]
      show_view_names: false
      show_row_numbers: false
      size_to_fit: true
      series_labels:
        ai_interventions.owner_or_unassigned: Owner
        ai_interventions.target_scope: Target
        ai_interventions.follow_up_date: Follow-up due
        ai_interventions.is_overdue: Overdue
      filters:
        ai_interventions.status: planned,active
      sorts: [ai_interventions.follow_up_date]
      limit: 50
      row: 11
      col: 0
      width: 36
      height: 10
      tab_name: interventions
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      minimum_column_width: 80
    - name: impact_comparison
      title: Before and after | 28 days either side
      type: looker_grid
      model: gemini_enterprise
      explore: intervention_impact
      fields: [intervention_impact.intervention_id, intervention_impact.comparison_group, intervention_impact.period, intervention_impact.people, intervention_impact.activation_rate, intervention_impact.regular_adoption_rate, intervention_impact.ai_active_days, intervention_impact.ai_actions, intervention_impact.caution]
      sorts: [intervention_impact.intervention_id, intervention_impact.comparison_group, intervention_impact.period]
      limit: 100
      row: 21
      col: 0
      width: 36
      height: 10
      tab_name: interventions
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
    - name: validated_outcomes
      title: Validated business outcomes
      type: looker_grid
      model: gemini_enterprise
      explore: ai_value_outcomes
      fields: [ai_value_outcomes.scope, ai_value_outcomes.metric, ai_value_outcomes.unit, ai_value_outcomes.outcome_value, ai_value_outcomes.source]
      sorts: [ai_value_outcomes.outcome_value desc]
      limit: 50
      row: 21
      col: 36
      width: 36
      height: 10
      tab_name: interventions
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
    - name: intervention_timeline
      title: Outcomes
      type: looker_grid
      model: gemini_enterprise
      explore: ai_interventions
      fields: [ai_interventions.name, ai_interventions.start_date, ai_interventions.follow_up_date, ai_interventions.status, ai_interventions.outcome, ai_interventions.outcome_notes]
      show_view_names: false
      show_row_numbers: false
      size_to_fit: true
      sorts: [ai_interventions.start_date desc]
      limit: 100
      row: 11
      col: 36
      width: 36
      height: 10
      tab_name: interventions
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      minimum_column_width: 80
    - name: cohort_history
      title: Cohort share history | up to 52 weeks
      type: looker_area
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
      pivots: [ai_user_cohort_weekly.cohort]
      sorts: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort]
      limit: 52
      stacking: percent
      show_view_names: false
      y_axis_gridlines: true
      legend_position: center
      series_colors:
        Power|FIELD|1 - ai_user_cohort_weekly.people: '#174EA6'
        Power - ai_user_cohort_weekly.people: '#174EA6'
        Normal|FIELD|2 - ai_user_cohort_weekly.people: '#1A73E8'
        Normal - ai_user_cohort_weekly.people: '#1A73E8'
        Casual|FIELD|3 - ai_user_cohort_weekly.people: '#8AB4F8'
        Casual - ai_user_cohort_weekly.people: '#8AB4F8'
        Non-AI|FIELD|4 - ai_user_cohort_weekly.people: '#DADCE0'
        Non-AI - ai_user_cohort_weekly.people: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 29
      col: 0
      width: 72
      height: 8
      tab_name: adoption_cohorts
      x_axis_gridlines: false
      show_x_axis_label: false
      point_style: none
      interpolation: monotone
    - name: interventions_state
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_interventions
      fields: [ai_interventions.interventions_state_card, ai_interventions.open_interventions, ai_interventions.overdue_interventions, ai_interventions.completed_interventions]
      hidden_fields: [ai_interventions.open_interventions, ai_interventions.overdue_interventions, ai_interventions.completed_interventions]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      row: 5
      col: 0
      width: 72
      height: 6
      tab_name: interventions
  filters:
    - name: Date
      title: Date
      type: field_filter
      model: gemini_enterprise
      explore: ai_activity_hourly
      default_value: 90 day
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: popover
      listens_to_filters: []
      field: ai_activity_hourly.event_date
    - name: Product
      title: Product
      type: field_filter
      model: gemini_enterprise
      explore: ai_activity_hourly
      default_value: ''
      allow_multiple_values: true
      required: false
      ui_config:
        type: button_toggles
        display: inline
      listens_to_filters: []
      field: ai_activity_hourly.product
    - name: Department
      title: Department
      type: field_filter
      model: gemini_enterprise
      explore: ai_user_profile
      default_value: ''
      allow_multiple_values: true
      required: false
      ui_config:
        type: dropdown_menu
        display: popover
      listens_to_filters: []
      field: user_org_unit.department
