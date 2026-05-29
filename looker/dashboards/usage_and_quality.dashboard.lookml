dashboard: usage_and_quality {
  title: "Gemini Enterprise Usage and Quality"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: usage_volume {
    title: "Usage Volume"
    type: looker_column
    model: gemini_enterprise
    explore: usage_quality
    fields: [usage_quality.metric_date, usage_quality.searches, usage_quality.answers, usage_quality.actions]
    filters: [usage_quality.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: success_rates {
    title: "Success Rates"
    type: looker_line
    model: gemini_enterprise
    explore: usage_quality
    fields: [
      usage_quality.metric_date,
      usage_quality.successful_search_rate,
      usage_quality.successful_answer_rate
    ]
    filters: [usage_quality.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: feedback {
    title: "Feedback"
    type: looker_column
    model: gemini_enterprise
    explore: usage_quality
    fields: [usage_quality.metric_date, usage_quality.likes, usage_quality.dislikes]
    filters: [usage_quality.metric_date: "{{ _filters['date_filter'] }}"]
  }
}
