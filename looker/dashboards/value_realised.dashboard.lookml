dashboard: value_realised {
  title: "Gemini Enterprise Value Realised"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: value_saved {
    title: "Value Saved"
    type: single_value
    model: gemini_enterprise
    explore: value
    fields: [value.value_saved]
    filters: [value.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: hours_saved {
    title: "Employee Hours Saved"
    type: single_value
    model: gemini_enterprise
    explore: value
    fields: [value.employee_hours_saved]
    filters: [value.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: projected_annual_value {
    title: "Projected Annual Value"
    type: single_value
    model: gemini_enterprise
    explore: value
    fields: [value.projected_annual_value_saved]
    filters: [value.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: successful_outcomes {
    title: "Successful Searches and Answers"
    type: looker_column
    model: gemini_enterprise
    explore: value
    fields: [value.metric_date, value.successful_searches, value.successful_answers]
    filters: [value.metric_date: "{{ _filters['date_filter'] }}"]
  }
}
