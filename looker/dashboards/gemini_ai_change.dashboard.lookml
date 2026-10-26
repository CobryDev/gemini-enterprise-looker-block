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
        Power: '#174EA6'
        Normal: '#1A73E8'
        Casual: '#8AB4F8'
        Non-AI: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 10
      col: 0
      width: 24
      height: 10
      tab_name: adoption_cohorts
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: 'Share of eligible people in each cohort today. Cohorts count AI-active days in the trailing 28 days: Power 12 or more, Normal 4 or more, Casual 1 to 3, Non-AI none (thresholds are install settings).'
    - name: cohort_trend
      title: Cohort share per week | last 12 complete weeks
      type: looker_column
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
      pivots: [ai_user_cohort_weekly.cohort]
      sorts: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort]
      limit: 52
      stacking: percent
      show_view_names: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        Power: '#174EA6'
        Normal: '#1A73E8'
        Casual: '#8AB4F8'
        Non-AI: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 10
      col: 24
      width: 24
      height: 10
      tab_name: adoption_cohorts
      filters:
        ai_user_cohort_weekly.week_end_date: 12 weeks
      x_axis_gridlines: false
      show_x_axis_label: false
      point_style: none
      interpolation: monotone
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: 'Share of eligible people in each cohort at the end of each of the last 12 complete weeks. Cohorts count AI-active days in the trailing 28 days: Power 12 or more, Normal 4 or more, Casual 1 to 3, Non-AI none (thresholds are install settings).'
      show_y_axis_labels: false
    - name: cohort_movement
      title: Cohort movement | last 12 complete weeks
      type: looker_column
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.newly_active, ai_user_cohort_weekly.moved_up, ai_user_cohort_weekly.moved_down_negative]
      sorts: [ai_user_cohort_weekly.week_end_week]
      limit: 12
      show_view_names: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        ai_user_cohort_weekly.newly_active: '#1A73E8'
        ai_user_cohort_weekly.moved_up: '#188038'
        ai_user_cohort_weekly.moved_down_negative: '#D93025'
      series_labels:
        ai_user_cohort_weekly.newly_active: Newly active
        ai_user_cohort_weekly.moved_up: Moved up
        ai_user_cohort_weekly.moved_down: Moved down
      listen:
        Department: user_org_unit.department
      row: 20
      col: 0
      width: 36
      height: 13
      tab_name: adoption_cohorts
      filters:
        ai_user_cohort_weekly.week_end_date: 12 weeks
      show_value_labels: false
      x_axis_gridlines: false
      show_x_axis_label: false
      stacking: normal
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0,
            "plotLines": [
              {
                "value": 0,
                "color": "#5F6368",
                "width": 1,
                "zIndex": 4
              }
            ]
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: People who changed cohort compared with the week before. Newly active were Non-AI or new; Moved up went to a higher cohort; Moved down (below the line) went lower, including lapsing to Non-AI.
      show_y_axis_labels: false
    - name: cohort_by_department
      title: Cohort mix by department | eligible people, last 28 days
      type: looker_bar
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.cohort, ai_user_profile.people]
      pivots: [ai_user_profile.cohort]
      sorts: [ai_user_profile.cohort, ai_user_profile.people desc 0]
      limit: 15
      stacking: percent
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        Power: '#174EA6'
        Normal: '#1A73E8'
        Casual: '#8AB4F8'
        Non-AI: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 20
      col: 36
      width: 36
      height: 13
      tab_name: adoption_cohorts
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: 'Share of each department''s eligible people in each cohort today. Cohorts count AI-active days in the trailing 28 days: Power 12 or more, Normal 4 or more, Casual 1 to 3, Non-AI none (thresholds are install settings).'
      show_y_axis_labels: false
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
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
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
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
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
        Active: '#1A73E8'
        Automated: '#9AA0A6'
        Proactive: '#DADCE0'
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
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      show_y_axis_labels: false
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
          label: use-case-top3
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#9AA0A6']
        options: {}
      series_colors:
        Other: '#9AA0A6'
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      legend_position: center
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Hands-on AI actions per complete week, for the three use cases with the most actions in the last 90 days. Everything else is grouped as Other.
      show_y_axis_labels: false
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
      row: 75
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
      row: 75
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
      row: 87
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
      row: 87
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
      type: looker_column
      model: gemini_enterprise
      explore: ai_user_cohort_weekly
      fields: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort, ai_user_cohort_weekly.people]
      pivots: [ai_user_cohort_weekly.cohort]
      sorts: [ai_user_cohort_weekly.week_end_week, ai_user_cohort_weekly.cohort]
      limit: 52
      stacking: percent
      show_view_names: false
      y_axis_gridlines: false
      legend_position: center
      series_colors:
        Power: '#174EA6'
        Normal: '#1A73E8'
        Casual: '#8AB4F8'
        Non-AI: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 33
      col: 0
      width: 72
      height: 10
      tab_name: adoption_cohorts
      x_axis_gridlines: false
      show_x_axis_label: false
      point_style: none
      interpolation: monotone
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: 'Weekly cohort share for up to 52 weeks. Early weeks can undercount because their 28-day window reaches back before activity history starts. Cohorts count AI-active days in the trailing 28 days: Power 12 or more, Normal 4 or more, Casual 1 to 3, Non-AI none (thresholds are install settings).'
      show_y_axis_labels: false
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
    - name: department_bubble
      title: Department adoption map | activation vs AI days per active person
      type: looker_scatter
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.ai_engagement_days_per_active_user, ai_user_profile.ai_activation_rate, ai_user_profile.people]
      sorts: [ai_user_profile.people desc]
      limit: 30
      listen:
        Department: user_org_unit.department
      row: 10
      col: 48
      width: 24
      height: 10
      tab_name: adoption_cohorts
      series_colors:
        ai_user_profile.ai_engagement_days_per_active_user: '#1A73E8'
      x_axis_label: Activation (28d)
      note_state: collapsed
      note_display: hover
      note_text: 'Each bubble is a department, sized by eligible people. Across is activation: the share of eligible people with at least one AI-active day in the last 28 days. Up is the average number of AI-active days per active person. The dashed line marks 50% activation, so departments to its left need help getting started, and low bubbles on the right have started but not built a habit.'
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: none
      show_x_axis_label: true
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": "Activation (28d)",
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              }
            },
            "plotLines": [
              {
                "value": 0.5,
                "color": "#9AA0A6",
                "dashStyle": "Dash",
                "width": 1,
                "zIndex": 3
              }
            ]
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "text": "AI days per active person",
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              }
            },
            "min": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "scatter": {
              "marker": {
                "symbol": "circle",
                "lineWidth": 1,
                "lineColor": "#FFFFFF",
                "fillOpacity": 0.7
              }
            }
          }
        }
      hidden_fields: [user_org_unit.department]
      size_by_field: ai_user_profile.people
      show_value_labels: false
      show_y_axis_labels: true
    - name: median_days
      title: Median AI days
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.median_ai_days]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 0
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: median_actions
      title: Median actions
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.median_actions_active]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 12
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: models_per_ge_user
      title: Models / GE user
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.models_per_ge_user]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 24
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: median_tokens
      title: Median GE tokens
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.median_tokens_per_ge_user]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 36
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: top_10_share
      title: Top 10% share
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.top_decile_action_share]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 48
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: active_people
      title: Active people
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.ai_active_users]
      limit: 1
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      row: 5
      col: 60
      width: 12
      height: 5
      tab_name: people_coaching
      listen:
        Department: user_org_unit.department
    - name: ai_days_histogram
      title: AI-active days distribution | people, last 28 days
      type: looker_column
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.ai_days_28d, ai_user_profile.cohort, ai_user_profile.people]
      pivots: [ai_user_profile.cohort]
      sorts: [ai_user_profile.ai_days_28d, ai_user_profile.cohort]
      limit: 100
      stacking: normal
      series_colors:
        Power: '#174EA6'
        Normal: '#1A73E8'
        Casual: '#8AB4F8'
        Non-AI: '#DADCE0'
      listen:
        Department: user_org_unit.department
      row: 10
      col: 0
      width: 24
      height: 10
      tab_name: people_coaching
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: How many eligible people used AI on each number of days in the last 28, coloured by cohort. A tall bar at 0 means many people haven't started; bars further right mean habitual use.
      show_y_axis_labels: false
    - name: people_scatter
      title: People map | AI days vs AI actions, last 28 days
      type: looker_scatter
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.ai_days_28d, ai_user_profile.user_email, ai_user_profile.cohort, ai_user_profile.ai_actions_28d_value, power, normal, casual]
      sorts: [ai_user_profile.ai_days_28d]
      limit: 500
      hidden_fields: [ai_user_profile.user_email, ai_user_profile.cohort, ai_user_profile.ai_actions_28d_value]
      listen:
        Department: user_org_unit.department
      row: 10
      col: 24
      width: 24
      height: 10
      tab_name: people_coaching
      series_colors:
        power: '#174EA6'
        normal: '#1A73E8'
        casual: '#8AB4F8'
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: true
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": "AI-active days (28d)",
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              }
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "text": "AI actions (28d, log scale)",
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              }
            },
            "type": "logarithmic",
            "min": 1
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              },
              "marker": {
                "enabled": true,
                "radius": 4
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "scatter": {
              "marker": {
                "radius": 4,
                "symbol": "circle",
                "lineWidth": 0
              }
            }
          }
        }
      filters:
        ai_user_profile.ai_actions_28d: '>0'
      note_state: collapsed
      note_display: hover
      note_text: Each dot is one person with at least one AI action in the last 28 days, coloured by cohort. Across is AI-active days and up is AI actions on a log scale, so the heaviest users don't flatten everyone else. High and left means many actions on a few days; low and right means AI is part of most days but used lightly.
      dynamic_fields:
        - category: table_calculation
          expression: if(${ai_user_profile.cohort}="Power", ${ai_user_profile.ai_actions_28d_value}, null)
          label: Power
          value_format: null
          value_format_name: decimal_0
          _kind_hint: measure
          table_calculation: power
          _type_hint: number
        - category: table_calculation
          expression: if(${ai_user_profile.cohort}="Normal", ${ai_user_profile.ai_actions_28d_value}, null)
          label: Normal
          value_format: null
          value_format_name: decimal_0
          _kind_hint: measure
          table_calculation: normal
          _type_hint: number
        - category: table_calculation
          expression: if(${ai_user_profile.cohort}="Casual", ${ai_user_profile.ai_actions_28d_value}, null)
          label: Casual
          value_format: null
          value_format_name: decimal_0
          _kind_hint: measure
          table_calculation: casual
          _type_hint: number
      show_null_points: false
      y_axes:
        - label: AI actions (28d, log scale)
          orientation: left
          showLabels: true
          showValues: true
          type: log
      x_axis_label: AI-active days (28d)
      show_y_axis_labels: true
    - name: department_action_boxplot
      title: Action distribution | by department
      type: looker_boxplot
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.min_actions_28d, ai_user_profile.p25_actions_28d, ai_user_profile.median_actions_28d, ai_user_profile.p75_actions_28d, ai_user_profile.max_actions_28d]
      sorts: [ai_user_profile.max_actions_28d desc]
      limit: 2000
      listen:
        Department: user_org_unit.department
      row: 10
      col: 48
      width: 24
      height: 10
      tab_name: people_coaching
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_x_axis_label: false
      legend_position: none
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            }
          },
          "legend": {
            "enabled": false,
            "layout": "horizontal",
            "align": "center",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "boxplot": {
              "fillColor": "rgba(26,115,232,0.08)",
              "lineWidth": 1,
              "medianColor": "#174EA6",
              "medianWidth": 2,
              "stemColor": "#1A73E8",
              "whiskerColor": "#1A73E8"
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Spread of hands-on AI actions per person in the last 28 days, by department. The box covers the middle half of people, the line inside is the median, and the whiskers show the lowest and highest.
      show_y_axis_labels: false
    - name: who_uses_what
      title: Who uses what? | top people by use case
      type: looker_bar
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.user_email, ai_activity_hourly.use_case_group, ai_activity_hourly.ai_actions]
      pivots: [ai_activity_hourly.use_case_group]
      filters:
        ai_activity_hourly.ai_actions: '>0'
      sorts: [ai_activity_hourly.ai_actions desc 0]
      limit: 15
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 20
      col: 0
      width: 36
      height: 14
      tab_name: people_coaching
      stacking: normal
      series_colors:
        Other: '#9AA0A6'
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: The 25 people with the most hands-on AI actions in the selected dates, split by use case. Shows what each heavy user relies on AI for.
      show_y_axis_labels: false
      color_application:
        collection_id: google
        custom:
          id: use-case-top3
          label: use-case-top3
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#9AA0A6']
        options: {}
    - name: user_model_mix
      title: Model choice by person | top GE users
      type: looker_bar
      model: gemini_enterprise
      explore: ge_user_activity
      fields: [ge_user_activity.user_email, ge_user_activity.model_label, ge_user_activity.prompts]
      pivots: [ge_user_activity.model_label]
      filters:
        ge_user_activity.prompts: '>0'
      sorts: [ge_user_activity.prompts desc 0]
      limit: 15
      listen:
        Date: ge_user_activity.event_date
        Department: user_org_unit.department
      row: 20
      col: 36
      width: 36
      height: 14
      tab_name: people_coaching
      stacking: percent
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Share of each person's Gemini Enterprise prompts handled by each model in the selected dates, for the 25 people who prompted most. (not recorded) means the log carried no model.
      show_y_axis_labels: false
      series_colors:
        (not recorded): '#DADCE0'
        Unattributed: '#DADCE0'
      color_application:
        collection_id: google
        custom:
          id: gemini-series
          label: gemini-series
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#5F6368', '#9AA0A6', '#C6DAFC', '#DADCE0', '#0B3D91']
        options: {}
    - name: department_model_mix
      title: Model choice by department | prompt mix
      type: looker_bar
      model: gemini_enterprise
      explore: ge_user_activity
      fields: [user_org_unit.department, ge_user_activity.model_label, ge_user_activity.prompts]
      pivots: [ge_user_activity.model_label]
      filters:
        ge_user_activity.prompts: '>0'
      sorts: [ge_user_activity.prompts desc 0]
      limit: 25
      listen:
        Date: ge_user_activity.event_date
        Department: user_org_unit.department
      row: 34
      col: 0
      width: 36
      height: 12
      tab_name: people_coaching
      stacking: percent
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Share of each department's Gemini Enterprise prompts handled by each model in the selected dates.
      show_y_axis_labels: false
      series_colors:
        (not recorded): '#DADCE0'
        Unattributed: '#DADCE0'
      color_application:
        collection_id: google
        custom:
          id: gemini-series
          label: gemini-series
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#5F6368', '#9AA0A6', '#C6DAFC', '#DADCE0', '#0B3D91']
        options: {}
    - name: user_hour_heatmap
      title: When do people use AI? | top people by hour
      type: looker_grid
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.user_email, ai_activity_hourly.event_local_hour_of_day, ai_activity_hourly.ai_actions, actions]
      pivots: [ai_activity_hourly.event_local_hour_of_day]
      filters:
        ai_activity_hourly.ai_actions: '>0'
      sorts: [ai_activity_hourly.ai_actions desc 0, ai_activity_hourly.event_local_hour_of_day]
      limit: 15
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 46
      col: 0
      width: 72
      height: 12
      tab_name: people_coaching
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      truncate_text: true
      series_cell_visualizations:
        actions:
          is_active: false
      dynamic_fields:
        - category: table_calculation
          expression: coalesce(${ai_activity_hourly.ai_actions}, 0)
          label: Actions
          value_format: null
          value_format_name: decimal_0
          _kind_hint: measure
          table_calculation: actions
          _type_hint: number
      hidden_fields: [ai_activity_hourly.ai_actions]
      header_text_alignment: center
      header_font_size: '11'
      rows_font_size: '11'
      size_to_fit: true
      series_labels:
        actions: ' '
      series_column_widths:
        ai_activity_hourly.user_email: 220
      enable_conditional_formatting: true
      conditional_formatting:
        - type: along a scale...
          value: null
          background_color: null
          font_color: null
          color_application:
            collection_id: google
            custom:
              id: gemini-heat
              label: Gemini heat
              type: continuous
              stops:
                - color: '#FFFFFF'
                  offset: 0
                - color: '#1A73E8'
                  offset: 100
            options:
              steps: 5
          bold: false
          italic: false
          strikethrough: false
          fields: [actions]
      conditional_formatting_include_totals: false
      conditional_formatting_include_nulls: false
    - name: day_hour_heatmap
      title: When does work happen? | day and local hour
      type: looker_grid
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.event_local_day_of_week_index, ai_activity_hourly.event_local_day_of_week, ai_activity_hourly.event_local_hour_of_day, ai_activity_hourly.ai_actions, actions]
      pivots: [ai_activity_hourly.event_local_hour_of_day]
      sorts: [ai_activity_hourly.event_local_day_of_week_index, ai_activity_hourly.event_local_hour_of_day]
      limit: 7
      hidden_fields: [ai_activity_hourly.event_local_day_of_week_index, ai_activity_hourly.ai_actions]
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 58
      col: 0
      width: 72
      height: 7
      tab_name: people_coaching
      show_view_names: false
      show_row_numbers: false
      table_theme: white
      header_background_color: '#F8F9FA'
      series_cell_visualizations:
        actions:
          is_active: false
      dynamic_fields:
        - category: table_calculation
          expression: coalesce(${ai_activity_hourly.ai_actions}, 0)
          label: Actions
          value_format: null
          value_format_name: decimal_0
          _kind_hint: measure
          table_calculation: actions
          _type_hint: number
      header_text_alignment: center
      header_font_size: '11'
      rows_font_size: '11'
      truncate_text: true
      size_to_fit: true
      series_labels:
        actions: ' '
      series_column_widths:
        ai_activity_hourly.event_local_day_of_week: 110
      enable_conditional_formatting: true
      conditional_formatting:
        - type: along a scale...
          value: null
          background_color: null
          font_color: null
          color_application:
            collection_id: google
            custom:
              id: gemini-heat
              label: Gemini heat
              type: continuous
              stops:
                - color: '#FFFFFF'
                  offset: 0
                - color: '#1A73E8'
                  offset: 100
            options:
              steps: 5
          bold: false
          italic: false
          strikethrough: false
          fields: [actions]
      conditional_formatting_include_totals: false
      conditional_formatting_include_nulls: false
    - name: tokens_by_person
      title: Tokens by person | stacked by agent
      type: looker_bar
      model: gemini_enterprise
      explore: ge_model_calls
      fields: [ge_model_calls.user_email, ge_trace_context.agent_label, ge_model_calls.total_tokens]
      pivots: [ge_trace_context.agent_label]
      sorts: [ge_model_calls.total_tokens desc 0]
      limit: 15
      listen:
        Date: ge_model_calls.event_date
        Department: user_org_unit.department
      row: 34
      col: 36
      width: 36
      height: 12
      tab_name: people_coaching
      stacking: normal
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Input plus output tokens from Gemini Enterprise model calls in the selected dates, for the 25 heaviest users, split by the agent that made the call. Workspace Gemini doesn't report tokens.
      show_y_axis_labels: false
      series_colors:
        (not recorded): '#DADCE0'
        Unattributed: '#DADCE0'
      color_application:
        collection_id: google
        custom:
          id: gemini-series
          label: gemini-series
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#5F6368', '#9AA0A6', '#C6DAFC', '#DADCE0', '#0B3D91']
        options: {}
    - name: tokens_by_context
      title: Tokens by workflow/event | Gemini Enterprise
      type: looker_pie
      model: gemini_enterprise
      explore: ge_model_calls
      fields: [ge_trace_context.token_context, ge_model_calls.total_tokens]
      sorts: [ge_model_calls.total_tokens desc]
      limit: 10
      listen:
        Date: ge_model_calls.event_date
        Department: user_org_unit.department
      row: 65
      col: 0
      width: 24
      height: 10
      tab_name: people_coaching
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            }
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "pie": {
              "innerSize": "60%",
              "borderWidth": 0,
              "dataLabels": {
                "enabled": false
              },
              "showInLegend": true
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Gemini Enterprise tokens in the selected dates by the feature, workflow or event that started the call. Unattributed means the call couldn't be matched to an interaction.
      value_labels: legend
      label_type: labPer
      show_y_axis_labels: false
      series_colors:
        Unattributed: '#DADCE0'
      color_application:
        collection_id: google
        custom:
          id: gemini-series
          label: gemini-series
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#5F6368', '#9AA0A6', '#C6DAFC', '#DADCE0', '#0B3D91']
        options: {}
    - name: tokens_by_day_context
      title: Daily tokens by workflow or event | Gemini Enterprise
      type: looker_column
      model: gemini_enterprise
      explore: ge_model_calls
      fields: [ge_model_calls.event_date, ge_trace_context.token_context, ge_model_calls.total_tokens]
      pivots: [ge_trace_context.token_context]
      sorts: [ge_trace_context.token_context, ge_model_calls.event_date]
      limit: 90
      listen:
        Date: ge_model_calls.event_date
        Department: user_org_unit.department
      row: 65
      col: 24
      width: 48
      height: 10
      tab_name: people_coaching
      stacking: normal
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      legend_position: center
      show_x_axis_label: false
      show_value_labels: false
      advanced_vis_config: |-
        {
          "chart": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif"
            },
            "borderRadius": 10,
            "spacing": [
              8,
              8,
              8,
              8
            ]
          },
          "title": {
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontSize": "16px",
              "fontWeight": "600",
              "color": "#202124"
            }
          },
          "xAxis": {
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "lineColor": "#DADCE0",
            "tickColor": "#DADCE0",
            "title": {
              "text": null
            }
          },
          "yAxis": {
            "gridLineColor": "#E8EAED",
            "gridLineDashStyle": "ShortDash",
            "labels": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "11px"
              }
            },
            "title": {
              "style": {
                "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                "color": "#5F6368",
                "fontSize": "12px"
              },
              "text": null
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "center",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6,
            "layout": "horizontal",
            "itemDistance": 16
          },
          "tooltip": {
            "backgroundColor": "#FFFFFF",
            "borderColor": "#DADCE0",
            "borderRadius": 8,
            "shadow": true,
            "style": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "color": "#202124"
            }
          },
          "plotOptions": {
            "series": {
              "dataLabels": {
                "style": {
                  "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
                  "fontWeight": "600",
                  "textOutline": "none"
                }
              }
            },
            "column": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "bar": {
              "borderRadius": {
                "radius": 4,
                "where": "end"
              },
              "pointPadding": 0.08,
              "groupPadding": 0.12
            },
            "line": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            },
            "area": {
              "lineWidth": 2.5,
              "marker": {
                "enabled": false
              }
            }
          }
        }
      note_state: collapsed
      note_display: hover
      note_text: Gemini Enterprise model tokens per day, stacked by the feature that made the call. Where no feature is recorded, the event type or invocation mode is used instead. Unattributed means the model call could not be matched to an activity record.
      column_limit: 8
      show_y_axis_labels: false
      series_colors:
        (not recorded): '#DADCE0'
        Unattributed: '#DADCE0'
      color_application:
        collection_id: google
        custom:
          id: gemini-series
          label: gemini-series
          type: discrete
          colors: ['#174EA6', '#1A73E8', '#8AB4F8', '#5F6368', '#9AA0A6', '#C6DAFC', '#DADCE0', '#0B3D91']
        options: {}
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
