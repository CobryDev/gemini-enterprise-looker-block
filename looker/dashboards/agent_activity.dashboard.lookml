dashboard: agent_activity {
  title: "Gemini Enterprise Agent Activity"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: agent_sessions_trend {
    title: "Agent Sessions Over Time"
    type: looker_line
    model: gemini_enterprise
    explore: agents
    fields: [agents.metric_date, agents.agent_sessions, agents.agent_active_users]
    filters: {
      field: agents.metric_date
      value: "{{ _filters['date_filter'] }}"
    }
    width: 12
    height: 8
  }

  element: distinct_agents {
    title: "Distinct Agents Used"
    type: single_value
    model: gemini_enterprise
    explore: agents
    fields: [agents.agent_count]
    filters: {
      field: agents.metric_date
      value: "{{ _filters['date_filter'] }}"
    }
    width: 6
    height: 4
  }

  element: new_agents {
    title: "New Agents Created"
    type: single_value
    model: gemini_enterprise
    explore: agents
    fields: [agents.new_agents]
    filters: {
      field: agents.metric_date
      value: "{{ _filters['date_filter'] }}"
    }
    width: 6
    height: 4
  }

  element: top_agents {
    title: "Top Agents by Sessions"
    type: looker_grid
    model: gemini_enterprise
    explore: agents
    fields: [agents.agent_name, agents.agent_type, agents.agent_ownership, agents.agent_sessions, agents.agent_active_users]
    sorts: [agents.agent_sessions desc]
    limit: 50
    filters: {
      field: agents.metric_date
      value: "{{ _filters['date_filter'] }}"
    }
    width: 12
    height: 8
  }

  element: sessions_by_agent_type {
    title: "Sessions by Agent Type"
    type: looker_column
    model: gemini_enterprise
    explore: agents
    fields: [agents.metric_date, agents.agent_type, agents.agent_sessions]
    pivots: [agents.agent_type]
    filters: {
      field: agents.metric_date
      value: "{{ _filters['date_filter'] }}"
    }
    width: 12
    height: 8
  }
}
