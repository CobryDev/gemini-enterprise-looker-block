dashboard: adoption_overview {
  title: "Gemini Enterprise Adoption Overview"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: active_users_trend {
    title: "Active Users"
    type: looker_line
    model: gemini_enterprise
    explore: adoption
    fields: [adoption.metric_date, adoption.dau, adoption.wau, adoption.mau]
    filters: [adoption.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: seat_utilisation {
    title: "Seat Utilisation"
    type: single_value
    model: gemini_enterprise
    explore: adoption
    fields: [adoption.seat_utilisation]
    filters: [adoption.metric_date: "{{ _filters['date_filter'] }}"]
  }

  element: retention {
    title: "Retention"
    type: looker_line
    model: gemini_enterprise
    explore: adoption
    fields: [adoption.metric_date, adoption.retention_7_day, adoption.retention_28_day]
    filters: [adoption.metric_date: "{{ _filters['date_filter'] }}"]
  }
}
