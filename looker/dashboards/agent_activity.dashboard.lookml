dashboard: agent_activity {
  title: "Gemini Enterprise Agent Activity"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: agent_usage {
    title: "Agent Usage"
    type: looker_line
    model: gemini_enterprise
    explore: agents
    fields: [
      agents.metric_date,
      agents.monthly_active_agent_users,
      agents.monthly_chat_sessions,
      agents.monthly_agents_used
    ]
    filters: [agents.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: agent_creation {
    title: "Agents Created"
    type: looker_column
    model: gemini_enterprise
    explore: agents
    fields: [agents.metric_date, agents.monthly_agents_created]
    filters: [agents.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: notebooklm_activity {
    title: "NotebookLM Enterprise Activity"
    type: looker_column
    model: gemini_enterprise
    explore: agents
    fields: [
      agents.metric_date,
      agents.notebooks_created,
      agents.notebooks_shared,
      agents.audio_overviews_created
    ]
    filters: [agents.metric_date: "{{ _filters['date_filter'] }}"]
  }
}
