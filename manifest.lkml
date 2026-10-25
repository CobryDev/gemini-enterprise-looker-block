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

# Optional employee population scope. Leave employee_domains blank to include
# every domain, then use the exclusion settings for service accounts, guests and
# external org units.
constant: employee_domains {
  value: ""
  export: override_optional
}

constant: excluded_org_units {
  value: ""
  export: override_optional
}

constant: excluded_email_pattern {
  value: "gserviceaccount\\.com$|^noreply"
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

# Monthly cost per seat, for licence-spend and value tiles. 0 hides the cost figures.
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

constant: time_saved_low_factor {
  value: "0.5"
  export: override_optional
}

constant: time_saved_high_factor {
  value: "1.5"
  export: override_optional
}

# Comma-separated feature=Use Case pairs. Product defaults cover common
# feature names and can be overridden by exact feature/source names.
constant: use_case_mapping {
  value: "help_me_write=Drafting & Editing,take_notes_for_me=Summarisation,conversation_summaries=Summarisation,summarize=Summarisation,Search=Research & Retrieval,Deep Research=Research & Retrieval,Assistant chat=Research & Retrieval,Workflows=Workflow Automation,Scheduled and triggered agents=Workflow Automation,Actions=Workflow Automation,Custom agents=Workflow Automation,Code Assist=Coding,default=Unclassified"
  export: override_optional
}

# How many org-unit path segments make a department: 1 for /Sales, 2 for
# /EMEA/Sales and so on.
constant: org_unit_depth {
  value: "1"
  export: override_optional
}

# Optional tables for validated value and change-management follow-up. Terraform
# creates managed tables with these names by default.
constant: interventions_table {
  value: "ai_interventions"
  export: override_optional
}

constant: value_outcomes_table {
  value: "ai_value_outcomes"
  export: override_optional
}
