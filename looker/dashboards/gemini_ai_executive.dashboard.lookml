- dashboard: gemini_ai_executive
  title: Gemini | Executive AI Adoption
  preferred_viewer: dashboards-next
  description: Executive view of AI adoption health, value scenarios and decisions.
  layout: newspaper
  layout_granularity: granular
  tabs:
    - name: overview
      label: Overview
    - name: business_value
      label: Business Value
    - name: risks_decisions
      label: Risks & Decisions
  elements:
    - name: header_overview
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Executive</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Overview</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Is AI adoption healthy, and what needs a decision?</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: overview
    - name: executive_narrative
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.story_card, ai_user_profile.ai_activation_rate, ai_user_profile.regular_among_active_rate, ai_user_profile.ai_active_users, ai_user_profile.people, ai_user_profile.non_ai_users, ai_user_profile.ai_retention_rate, ai_user_profile.regular_users, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
      hidden_fields: [ai_user_profile.ai_activation_rate, ai_user_profile.regular_among_active_rate, ai_user_profile.ai_active_users, ai_user_profile.people, ai_user_profile.non_ai_users, ai_user_profile.ai_retention_rate, ai_user_profile.regular_users, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 5
      col: 0
      width: 48
      height: 9
      tab_name: overview
    - name: top_decision
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.licence_decision_card, ai_user_profile.idle_ge_licence_spend]
      hidden_fields: [ai_user_profile.idle_ge_licence_spend]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 5
      col: 48
      width: 24
      height: 9
      tab_name: overview
    - name: activation_kpi
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.adoption_card, ai_user_profile.ai_active_users, ai_user_profile.people]
      hidden_fields: [ai_user_profile.ai_active_users, ai_user_profile.people]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 14
      col: 0
      width: 18
      height: 6
      tab_name: overview
    - name: habit_kpi
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.habit_card, ai_user_profile.regular_users, ai_user_profile.ai_active_users]
      hidden_fields: [ai_user_profile.regular_users, ai_user_profile.ai_active_users]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 14
      col: 18
      width: 18
      height: 6
      tab_name: overview
    - name: retention_kpi
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.retention_card, ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
      hidden_fields: [ai_user_profile.retained_ai_users, ai_user_profile.previous_ai_active_users]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 14
      col: 36
      width: 18
      height: 6
      tab_name: overview
    - name: not_active_kpi
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.not_yet_active_card, ai_user_profile.people]
      hidden_fields: [ai_user_profile.people]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      listen:
        Department: user_org_unit.department
      row: 14
      col: 54
      width: 18
      height: 6
      tab_name: overview
    - name: adoption_trend
      title: Is adoption growing? | weekly active people, complete weeks
      type: looker_area
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.event_week, ai_activity_hourly.ai_users]
      filters:
        ai_activity_hourly.is_complete_week: 'Yes'
      sorts: [ai_activity_hourly.event_week]
      limit: 26
      show_value_labels: true
      show_view_names: false
      y_axis_gridlines: true
      legend_position: none
      series_colors:
        ai_activity_hourly.ai_users: '#1A73E8'
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 20
      col: 0
      width: 36
      height: 11
      tab_name: overview
      x_axis_gridlines: false
      show_x_axis_label: false
      show_y_axis_labels: false
      show_y_axis_ticks: false
      point_style: none
      interpolation: monotone
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
            "tickColor": "#DADCE0"
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
              }
            }
          },
          "legend": {
            "align": "left",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6
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
              },
              "fillColor": {
                "linearGradient": {
                  "x1": 0,
                  "y1": 0,
                  "x2": 0,
                  "y2": 1
                },
                "stops": [
                  [
                    0,
                    "rgba(26,115,232,0.28)"
                  ],
                  [
                    1,
                    "rgba(26,115,232,0.02)"
                  ]
                ]
              }
            }
          }
        }
    - name: adoption_gap
      title: Where's the adoption gap? | people not yet active, by department
      type: looker_bar
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [user_org_unit.department, ai_user_profile.non_ai_users]
      filters:
        ai_user_profile.non_ai_users: '>0'
      sorts: [ai_user_profile.non_ai_users desc]
      limit: 8
      series_colors:
        ai_user_profile.non_ai_users: '#9AA0A6'
      legend_position: none
      note_state: collapsed
      note_display: hover
      note_text: Eligible people with no AI-active day in the last 28 days. (Top level) means people sit in the root org unit. Fix that in the Workspace directory.
      listen:
        Department: user_org_unit.department
      show_view_names: false
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_x_axis_label: false
      show_value_labels: true
      show_y_axis_labels: false
      show_y_axis_ticks: false
      row: 20
      col: 36
      width: 36
      height: 11
      tab_name: overview
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
            "tickColor": "#DADCE0"
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
              }
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "left",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6
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
    - name: next_decisions
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: ai_opportunities
      fields: [ai_opportunities.next_decisions_card]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      row: 31
      col: 0
      width: 48
      height: 8
      tab_name: overview
    - name: data_trust
      title: ''
      title_hidden: true
      type: single_value
      model: gemini_enterprise
      explore: data_state
      fields: [data_state.trust_status_card, data_state.checks]
      hidden_fields: [data_state.checks]
      limit: 1
      show_single_value_title: false
      show_comparison: false
      row: 31
      col: 48
      width: 24
      height: 8
      tab_name: overview
    - name: header_value
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Executive</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Business value</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Estimated time saved, before any validated ROI. Hands-on actions times the minutes saved per feature. Automation is a separate, lower-confidence line.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: business_value
    - name: hours_month
      title: Hours saved / month
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
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: value_month
      title: Value / month
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
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: automation_month
      title: Automation / month
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
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
    - name: licence_review
      title: Idle licence spend / month
      type: single_value
      model: gemini_enterprise
      explore: ai_user_profile
      fields: [ai_user_profile.idle_ge_licence_spend, ai_user_profile.idle_ge_licences]
      row: 5
      col: 54
      width: 18
      height: 7
      tab_name: business_value
      show_single_value_title: true
      show_comparison: false
      custom_color_enabled: true
      custom_color: '#202124'
      hidden_fields: [ai_user_profile.idle_ge_licences]
    - name: hours_by_use_case
      title: Hours by use case | selected dates, hands-on only
      type: looker_waterfall
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.use_case, ai_activity_hourly.hours_saved]
      filters:
        ai_activity_hourly.hours_saved: '>0'
      sorts: [ai_activity_hourly.hours_saved desc]
      limit: 10
      show_value_labels: true
      label_density: 25
      x_axis_gridlines: false
      y_axis_gridlines: false
      show_view_names: false
      legend_position: none
      series_colors:
        ai_activity_hourly.hours_saved: '#1A73E8'
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 12
      col: 0
      width: 36
      height: 10
      tab_name: business_value
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
            "tickColor": "#DADCE0"
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
              }
            }
          },
          "legend": {
            "align": "left",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6
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
    - name: value_trend
      title: Hours per complete week | hands-on and automation
      type: looker_column
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.event_week, ai_activity_hourly.hours_saved, ai_activity_hourly.automation_hours_saved]
      filters:
        ai_activity_hourly.is_complete_week: 'Yes'
      sorts: [ai_activity_hourly.event_week]
      limit: 26
      stacking: normal
      show_view_names: false
      y_axis_gridlines: false
      series_labels:
        ai_activity_hourly.hours_saved: Active (headline)
        ai_activity_hourly.automation_hours_saved: Automation (lower confidence)
      series_colors:
        ai_activity_hourly.hours_saved: '#1a73e8'
        ai_activity_hourly.automation_hours_saved: '#dadce0'
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 12
      col: 36
      width: 36
      height: 10
      tab_name: business_value
      x_axis_gridlines: false
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
            "tickColor": "#DADCE0"
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
              }
            },
            "gridLineWidth": 0
          },
          "legend": {
            "align": "left",
            "verticalAlign": "top",
            "itemStyle": {
              "fontFamily": "'Plus Jakarta Sans', 'Google Sans', Roboto, Arial, sans-serif",
              "fontWeight": "500",
              "color": "#3C4043"
            },
            "symbolRadius": 6
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
    - name: credit_assumptions
      title: Credit assumptions | minutes saved per action, selected dates
      note_display: hover
      note_text: Minutes per action come from the Minutes saved per AI action setting. Change them in Marketplace > Manage if they don't match how your people work.
      type: looker_grid
      model: gemini_enterprise
      explore: ai_activity_hourly
      fields: [ai_activity_hourly.use_case, ai_activity_hourly.feature, ai_activity_hourly.interaction_mode, ai_activity_hourly.minutes_saved_per_action, ai_activity_hourly.credited_actions, ai_activity_hourly.credited_hours]
      filters:
        ai_activity_hourly.credited_hours: '>0'
      sorts: [ai_activity_hourly.credited_hours desc]
      limit: 12
      show_view_names: false
      show_row_numbers: false
      series_labels:
        ai_activity_hourly.minutes_saved_per_action: Minutes per action
        ai_activity_hourly.credited_actions: Credited actions
        ai_activity_hourly.credited_hours: Hours
      listen:
        Date: ai_activity_hourly.event_date
        Product: ai_activity_hourly.product
        Department: user_org_unit.department
      row: 22
      col: 0
      width: 72
      height: 10
      tab_name: business_value
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      truncate_text: true
      size_to_fit: true
      minimum_column_width: 80
    - name: header_risks
      type: text
      title_text: ''
      subtitle_text: ''
      body_text: |-
        <div style="font-family:'Google Sans',Roboto,Arial,sans-serif;display:flex;align-items:center;justify-content:space-between;gap:24px;padding:2px 4px;">
          <div style="min-width:0;">
            <div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#1A73E8;">Gemini AI adoption | Executive</div>
            <div style="font-size:20px;font-weight:600;color:#202124;line-height:1.35;">Risks & decisions</div>
            <div style="font-size:13px;color:#5f6368;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">The decisions that need an owner, and whether the data is ready to report.</div>
          </div>
          <div style="flex:none;display:flex;gap:4px;font-size:12px;font-weight:600;"><a href="/dashboards/gemini_enterprise::gemini_ai_executive" style="padding:6px 12px;border-radius:16px;text-decoration:none;background:#E8F0FE;color:#174EA6;">Executive</a><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Change management</a><a href="/dashboards/gemini_enterprise::gemini_ai_admin" style="padding:6px 12px;border-radius:16px;text-decoration:none;color:#5f6368;">Admin</a></div>
        </div>
      row: 0
      col: 0
      width: 72
      height: 5
      tab_name: risks_decisions
    - name: data_states
      title: Reporting readiness
      type: looker_grid
      model: gemini_enterprise
      explore: data_state
      fields: [data_state.feature, data_state.state, data_state.message]
      sorts: [data_state.sort_order]
      limit: 20
      row: 14
      col: 0
      width: 72
      height: 8
      tab_name: risks_decisions
      series_labels:
        data_state.feature: Check
        data_state.state: State
        data_state.message: Detail
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
    - name: decisions
      title: Decision queue
      type: looker_grid
      model: gemini_enterprise
      explore: ai_opportunities
      fields: [ai_opportunities.priority_label, ai_opportunities.action_title, ai_opportunities.impact, ai_opportunities.next_step, ai_opportunities.evidence, ai_opportunities.priority, ai_opportunities.size]
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
        ai_opportunities.next_step: Next step
      sorts: [ai_opportunities.priority, ai_opportunities.size desc]
      limit: 20
      row: 5
      col: 0
      width: 72
      height: 9
      tab_name: risks_decisions
      table_theme: white
      header_background_color: '#F8F9FA'
      header_text_alignment: left
      header_font_size: '12'
      rows_font_size: '12'
      minimum_column_width: 80
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
