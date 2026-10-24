connection: "@{connection_name}"
label: "Gemini AI Adoption"

# One model for the whole block, so an install adds a single entry to the
# instance's model list. The explores read three independent sources, each
# with its own refresh schedule:
#   - the Gemini Enterprise analytics export (export_history), always present
#   - the redacted log tables the exporter builds when the Terraform log
#     pipeline is on (ge_*, antigravity_usage), plus the AI adoption PDTs
#   - the Workspace audit export, when workspace_export isn't none
# A missing source only breaks the tiles that read it.

include: "/looker/views/*.view.lkml"
include: "/looker/views/change_management/*.view.lkml"
include: "/looker/explores/*.explore.lkml"
include: "/looker/dashboards/*.dashboard.lookml"

datagroup: gemini_enterprise_default_datagroup {
  sql_trigger: SELECT MAX(ingested_at) FROM `@{gemini_project}.@{gemini_dataset}.export_history` ;;
  max_cache_age: "6 hours"
}

# The exporter merges new log rows hourly; rebuild PDTs and expire the cache
# when it has.
datagroup: gemini_change_management_datagroup {
  sql_trigger: SELECT MAX(ingested_at) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity` ;;
  max_cache_age: "2 hours"
}

# The Workspace audit export appends continuously, so the PDTs over it and
# the 400-day AI adoption rollups rebuild once a day.
datagroup: gemini_change_management_daily_datagroup {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

datagroup: workspace_gemini_default_datagroup {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

persist_with: gemini_enterprise_default_datagroup
