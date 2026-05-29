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
