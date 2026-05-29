dashboard: workspace_overview {
  title: "Workspace Gemini Overview"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: gemini_users {
    title: "Gemini Users"
    type: single_value
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_users]
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 8
    height: 4
  }

  element: engaged_users {
    title: "Engaged Users (Active Usage)"
    type: single_value
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.engaged_users]
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 8
    height: 4
  }

  element: active_rate {
    title: "Active Usage Rate"
    type: single_value
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.active_usage_rate]
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 8
    height: 4
  }

  element: usage_trend {
    title: "Gemini Usage Over Time"
    type: looker_line
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.event_date, workspace_gemini_activity.events, workspace_gemini_activity.active_events]
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 24
    height: 8
  }

  element: usage_by_app {
    title: "Usage by App"
    type: looker_bar
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.events, workspace_gemini_activity.active_users]
    sorts: [workspace_gemini_activity.events desc]
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 12
    height: 8
  }

  element: top_features {
    title: "Top Features"
    type: looker_grid
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.app_name, workspace_gemini_activity.feature_source, workspace_gemini_activity.events, workspace_gemini_activity.active_events, workspace_gemini_activity.active_users]
    sorts: [workspace_gemini_activity.events desc]
    limit: 50
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 12
    height: 8
  }

  element: adoption_by_org_unit {
    title: "Adoption by Org Unit"
    type: looker_bar
    model: workspace_gemini
    explore: workspace_gemini_activity
    fields: [workspace_gemini_activity.org_unit_name_path, workspace_gemini_activity.active_users, workspace_gemini_activity.events]
    sorts: [workspace_gemini_activity.active_users desc]
    limit: 25
    listen: {
      date_filter: workspace_gemini_activity.event_date
    }
    width: 24
    height: 8
  }
}
