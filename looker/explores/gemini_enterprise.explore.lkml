explore: active_users {
  label: "Active Users & Retention"
  description: "Daily/weekly/monthly active users plus retention, growth and churn, broken down by product surface (Total, Search, Assistant, Other)."
}

explore: activity {
  label: "Activity & Engagement"
  description: "Searches, clicks, Assistant answers, feedback and page visits, broken down by device."
}

explore: seats {
  label: "Seats & Licensing"
  description: "Seats purchased vs claimed and seat utilisation over time."
}

explore: agents {
  label: "Agents"
  description: "Per-agent sessions and active users. Populates once there is agent activity on the engine."
}

explore: search_queries {
  label: "Search Queries"
  description: "What people are querying. Populates once search volume exceeds Google's privacy suppression threshold."
}

explore: documents {
  label: "Documents"
  description: "Which documents are surfaced and viewed. Populates above the suppression threshold."
}

explore: export_history {
  label: "Export History (raw)"
  description: "Raw export rows preserving the full grain. Use for ad-hoc analysis across every dimension and metric."
  hidden: yes
}
