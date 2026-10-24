project_name: "gemini_enterprise_looker_block"

# Connection and project are set per Looker instance during install.
# Dataset names default to what the Terraform pipeline creates, so most
# instances only need to set the connection and the BigQuery project.

constant: connection_name {
  value: "bigquery"
  export: override_required
}

constant: gemini_project {
  value: "your-gcp-project-id"
  export: override_required
}

constant: gemini_dataset {
  value: "gemini_analytics"
  export: override_optional
}

constant: workspace_dataset {
  value: "workspace_audit"
  export: override_optional
}

# Where the Workspace audit export lives, relative to gemini_dataset:
#   none             no Workspace export; Workspace tiles stay empty
#   separate_region  export exists in another BigQuery location; only the
#                    Workspace Gemini dashboard tab uses it
#   same_region      export is in the same location (or copied there), so
#                    Workspace usage, org units and the Workspace population
#                    join the Gemini Enterprise data
# BigQuery can't join datasets across locations, so the cross-product
# dashboards need same_region.
constant: workspace_export {
  value: "none"
  export: override_optional
}

# IANA time zone for hour-of-day and day-of-week charts.
constant: reporting_time_zone {
  value: "UTC"
  export: override_optional
}

# AI-active days in the trailing 28 days that make someone a Power or Normal
# user. One or more days below the Normal threshold is Casual; zero is Non-AI.
constant: power_user_min_days {
  value: "12"
  export: override_optional
}

constant: normal_user_min_days {
  value: "4"
  export: override_optional
}

# Monthly cost per seat, for the ROI tiles. 0 hides the cost figures.
constant: ge_seat_cost_monthly {
  value: "0"
  export: override_optional
}

constant: gws_seat_cost_monthly {
  value: "0"
  export: override_optional
}

# Fully loaded cost of an hour of employee time. 0 hides the value figures.
constant: loaded_hourly_rate {
  value: "0"
  export: override_optional
}

constant: currency_symbol {
  value: "$"
  export: override_optional
}

# Estimated minutes saved per AI action, as comma-separated feature=minutes
# pairs. Keys match the Feature field of the AI Activity explore (Gemini
# Enterprise feature, Workspace feature_source or Antigravity experience),
# case-insensitive. "default" covers any feature not listed.
constant: time_saved_minutes {
  value: "default=2,Assistant chat=4,Search=2,Deep Research=30,Idea Generation=15,Custom agents=8,Workflows=10,Scheduled and triggered agents=10,Actions=3,Image generation=5,Agent builder=0,File upload=0,Feedback=0,Skill authoring=0,Agent designer=0,help_me_write=5,take_notes_for_me=15,conversation_summaries=3,summarize=3"
  export: override_optional
}

# How many org-unit path segments make a department: 1 for /Sales, 2 for
# /EMEA/Sales and so on.
constant: org_unit_depth {
  value: "1"
  export: override_optional
}
