connection: "@{connection_name}"

include: "/looker/views/*.view.lkml"
include: "/looker/explores/gemini_enterprise.explore.lkml"
include: "/looker/dashboards/adoption_overview.dashboard.lookml"
include: "/looker/dashboards/usage_and_quality.dashboard.lookml"
include: "/looker/dashboards/agent_activity.dashboard.lookml"
include: "/looker/dashboards/value_realised.dashboard.lookml"

datagroup: gemini_enterprise_default_datagroup {
  sql_trigger: SELECT MAX(ingested_at) FROM `@{gemini_project}.@{gemini_dataset}.metrics_history` ;;
  max_cache_age: "6 hours"
}

persist_with: gemini_enterprise_default_datagroup
