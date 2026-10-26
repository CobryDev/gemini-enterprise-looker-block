# Each explore below carves a logical slice out of the single wide export_history
# table via sql_always_where. Keeping the slice here (rather than in a per-view
# derived table) lets BigQuery prune partitions and columns on the base table
# natively. sql_always_where is mandatory and hidden from users, so the slice is
# always applied and never shows up as a removable filter.
#
# Only Adoption and Seats is visible: it works without the log pipeline and
# carries the seat counts. The other slices feed Admin dashboard tiles, and AI
# Activity covers per-person usage in more detail.

explore: adoption {
  group_label: "Gemini AI Adoption"
  label: "Gemini Enterprise Seats"
  description: "Daily active users against seats claimed and purchased, per app per day, as reported by Google's Gemini Enterprise analytics export. Works without the log pipeline."
}

explore: active_users {
  hidden: yes
  label: "Active Users and Retention"
  description: "Daily/weekly/monthly active users plus retention, growth and churn, broken down by product surface (Total, Search, Assistant, Other)."
  sql_always_where: ${active_users.data_source} = 'DATA_SOURCE_GWS_LOG'
    AND ${active_users.product_type} IS NOT NULL ;;
}

explore: activity {
  hidden: yes
  label: "Search and Assistant Activity"
  description: "Searches, clicks, Assistant answers, feedback and page visits, broken down by device."
  sql_always_where: ${activity.data_source} IN ('DATA_SOURCE_USER_EVENT', 'DATA_SOURCE_GWS_LOG')
    AND ${activity.device_type} IS NOT NULL ;;
}

explore: seats {
  hidden: yes
  label: "Seats & Licensing"
  description: "Seats purchased vs claimed and seat utilisation over time."
  sql_always_where: ${seats.data_source} = 'DATA_SOURCE_AGGREGATED_METRIC' ;;
}

explore: agents {
  hidden: yes
  label: "Agents"
  description: "Per-agent sessions and active users. Populates once there is agent activity on the engine."
  sql_always_where: ${agents.agent_name} IS NOT NULL ;;
}

explore: export_history {
  label: "Export History (raw)"
  description: "Raw export rows preserving the full grain. Use for ad-hoc analysis across every dimension and metric."
  hidden: yes
}
