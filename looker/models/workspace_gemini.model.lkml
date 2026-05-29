connection: "@{connection_name}"

include: "/looker/views/workspace_gemini_activity.view.lkml"
include: "/looker/explores/workspace_gemini.explore.lkml"

datagroup: workspace_gemini_default_datagroup {
  max_cache_age: "24 hours"
}

persist_with: workspace_gemini_default_datagroup
