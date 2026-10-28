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
  value: "gserviceaccount[.]com$|^noreply"
  export: override_optional
}

# Renamed accounts are merged automatically from Workspace rename events (needs
# workspace_export = same_region). For addresses the audit log can't link,
# list comma-separated pairs of old address, an equals sign and the current
# address.
constant: person_email_overrides {
  value: ""
  export: override_optional
}

# IANA time zone for hour-of-day and day-of-week charts.
constant: reporting_time_zone {
  value: "UTC"
  export: override_optional
}

# Service Health dashboard thresholds. Rates are decimals: 0.05 means 5%.
constant: health_min_prompts {
  value: "20"
  export: override_optional
}

constant: health_down_failure_rate {
  value: "0.25"
  export: override_optional
}

constant: health_degraded_failure_rate {
  value: "0.05"
  export: override_optional
}

constant: health_degraded_connector_rate {
  value: "0.10"
  export: override_optional
}

constant: health_degraded_armor_rate {
  value: "0.10"
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
  value: "default=2,Assistant chat=4,Search=2,Deep Research=30,Idea Generation=15,Custom agents=8,Workflows=10,Scheduled and triggered agents=10,Actions=3,Image generation=5,Agent builder=0,File upload=0,Feedback=0,Skill authoring=0,Agent designer=0,help_me_write=5,take_notes_for_me=15,conversation_summaries=3,summarize=3,summarize_responses=5,chat_with_gemini=3,ask_gemini=2,side_panel=3,proofread=2,help_me_schedule=3,help_me_visualize=5,help_me_design=5,help_me_create=10,ai_function=5,notebooklm=5,workflows_execution=0,workflows_unspecified=3"
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
  value: "help_me_write=Drafting & Editing,take_notes_for_me=Summarisation,conversation_summaries=Summarisation,summarize=Summarisation,Search=Research & Retrieval,Deep Research=Research & Retrieval,Assistant chat=Research & Retrieval,Workflows=Workflow Automation,Scheduled and triggered agents=Workflow Automation,Actions=Workflow Automation,Custom agents=Workflow Automation,Code Assist=Coding,proofread=Drafting & Editing,help_me_create=Drafting & Editing,summarize_responses=Summarisation,chat_with_gemini=Research & Retrieval,ask_gemini=Research & Retrieval,search_ai_overview=Research & Retrieval,notebooklm=Research & Retrieval,drive_gemini_shelf=Research & Retrieval,Idea Generation=Research & Retrieval,side_panel=In-app Assistant,help_me_schedule=Planning & Scheduling,drive_help_me_organize=Planning & Scheduling,project_creation_dialog=Planning & Scheduling,ai_function=Analysis,enhanced_smart_fill=Analysis,help_me_visualize=Creative & Design,help_me_design=Creative & Design,remove_image_background=Creative & Design,ai_image=Creative & Design,ai_voiceover=Creative & Design,generate_background=Creative & Design,Image generation=Creative & Design,workflows_execution=Workflow Automation,workflows_creation=Workflow Automation,workflows_unspecified=Workflow Automation,default=Unclassified"
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

# Link to the form or app your change team uses to record interventions (for
# example a Google Form or AppSheet app that writes to interventions_table).
# "none" hides the Record an intervention button.
constant: interventions_form_url {
  value: "none"
  export: override_optional
}
