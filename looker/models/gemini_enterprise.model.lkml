connection: "@{connection_name}"

include: "/looker/views/active_users.view.lkml"
include: "/looker/views/activity.view.lkml"
include: "/looker/views/seats.view.lkml"
include: "/looker/views/agents.view.lkml"
include: "/looker/views/search_queries.view.lkml"
include: "/looker/views/documents.view.lkml"
include: "/looker/views/export_history.view.lkml"
include: "/looker/explores/gemini_enterprise.explore.lkml"
include: "/looker/dashboards/adoption_overview.dashboard.lookml"
include: "/looker/dashboards/usage_and_quality.dashboard.lookml"
include: "/looker/dashboards/agent_activity.dashboard.lookml"
include: "/looker/dashboards/value_realised.dashboard.lookml"

datagroup: gemini_enterprise_default_datagroup {
  sql_trigger: SELECT MAX(ingested_at) FROM `@{gemini_project}.@{gemini_dataset}.export_history` ;;
  max_cache_age: "6 hours"
}

persist_with: gemini_enterprise_default_datagroup
