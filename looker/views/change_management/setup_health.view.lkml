view: setup_health_tables {
  label: "Setup Health"
  # One row per table the block reads from gemini_dataset, from the dataset's
  # __TABLES__ metadata, so it works even when tables are missing. Not
  # persisted: it should always show the current state.
  derived_table: {
    sql:
      WITH expected AS (
        SELECT * FROM UNNEST([
          STRUCT(1 AS sort_order, 'export_history' AS table_id, 'core' AS kind, 'Gemini Enterprise Analytics tab' AS feeds, 'Deploy the Terraform pipeline and check the exporter Cloud Run job logs for merge_completed.' AS fix),
          STRUCT(2, 'ge_user_activity', 'core', 'Every user-level tab', 'Set enable_log_pipeline = true in Terraform. Rows appear after the first hourly transform following real usage.'),
          STRUCT(3, 'ge_user_licenses', 'core', 'Licence activation, idle licences, Non-AI cohort', 'Set enable_log_pipeline = true; the licence snapshot runs daily. Check user_store_locations matches your app locations.'),
          STRUCT(4, 'ge_model_calls', 'event', 'Tokens and reasoning per user', 'Needs route_inference_logs = true. Empty until the assistant makes model calls.'),
          STRUCT(5, 'ge_tool_calls', 'event', 'Skills and tools', 'Needs route_inference_logs = true. Empty until the assistant calls tools.'),
          STRUCT(6, 'ge_connector_activity', 'event', 'Connector errors', 'Empty until a connector fails, which is normal.'),
          STRUCT(7, 'ge_safety_events', 'event', 'Safety and Model Armor', 'Needs Model Armor on the app and enable_model_armor_audit_logs = true. Empty until something is screened.'),
          STRUCT(8, 'ge_admin_events', 'event', 'Admin changes', 'Empty until someone changes an agent, connector or app.'),
          STRUCT(9, 'antigravity_usage', 'event', 'Antigravity usage', 'Add the Antigravity subscription project to log_source_project_ids. Empty if nobody uses Antigravity.'),
          STRUCT(10, '@{interventions_table}', 'optional', 'Intervention tracking and before/after measurement', 'Terraform creates this table. Load rows when you want to measure change-management interventions.'),
          STRUCT(11, '@{value_outcomes_table}', 'optional', 'Validated business outcome reporting', 'Terraform creates this table. Load externally validated outcomes when available.')
        ])
      ),

      actual AS (
        SELECT table_id, row_count, TIMESTAMP_MILLIS(last_modified_time) AS last_modified
        FROM `@{gemini_project}.@{gemini_dataset}.__TABLES__`
      )

      SELECT
        expected.*,
        actual.row_count,
        actual.last_modified,
        CASE
          WHEN actual.table_id IS NULL THEN 'Missing'
          WHEN actual.row_count = 0 AND expected.kind = 'core' THEN 'Empty'
          WHEN actual.row_count = 0 AND expected.kind = 'optional' THEN 'No records yet'
          WHEN actual.row_count = 0 THEN 'No events yet'
          WHEN expected.kind = 'core' AND actual.last_modified < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 DAY) THEN 'Stale'
          ELSE 'OK'
        END AS status
      FROM expected
      LEFT JOIN actual USING (table_id) ;;
  }

  dimension: table_id {
    primary_key: yes
    label: "Table"
    type: string
    sql: ${TABLE}.table_id ;;
    order_by_field: sort_order
  }

  dimension: sort_order {
    hidden: yes
    type: number
    sql: ${TABLE}.sort_order ;;
  }

  dimension: feeds {
    label: "Feeds"
    type: string
    sql: ${TABLE}.feeds ;;
  }

  dimension: status {
    description: "OK, Missing, Empty, Stale (core table not updated in 3 days), No events yet (normal for event tables) or No records yet (normal for optional tables)."
    type: string
    sql: ${TABLE}.status ;;
    html: {% if value == 'OK' or value == 'No events yet' or value == 'No records yet' %}<span style="color:#188038">{{ value }}</span>{% else %}<span style="color:#d93025;font-weight:bold">{{ value }}</span>{% endif %} ;;
  }

  dimension: next_step {
    type: string
    sql: CASE WHEN ${TABLE}.status IN ('OK', 'No events yet', 'No records yet') AND ${TABLE}.kind != 'core' THEN '' WHEN ${TABLE}.status = 'OK' THEN '' ELSE ${TABLE}.fix END ;;
  }

  dimension: row_count {
    type: number
    sql: ${TABLE}.row_count ;;
    value_format_name: decimal_0
  }

  dimension_group: last_modified {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.last_modified ;;
  }

  measure: tables_with_problems {
    type: count
    filters: [status: "Missing,Empty,Stale"]
  }
}

view: setup_health_workspace {
  label: "Setup Health"
  # State of the Workspace audit export, driven by the workspace_export
  # constant. With same_region it also reads gemini_dataset in the same
  # query, so a location mismatch surfaces here as a "not found in location"
  # error instead of breaking the adoption tabs silently.
  derived_table: {
    sql:
      {% if '@{workspace_export}' == 'none' %}
      SELECT
        'none' AS setting,
        'Not configured' AS status,
        CAST(NULL AS INT64) AS row_count,
        CAST(NULL AS TIMESTAMP) AS last_modified,
        CAST(NULL AS INT64) AS gemini_events_7d,
        'Optional. For Gemini for Workspace adoption, org units and the Workspace population, turn on the BigQuery export in the Workspace Admin console, then set Workspace audit export to same_region (or separate_region) in Marketplace > Manage.' AS next_step
      {% else %}
      SELECT
        '@{workspace_export}' AS setting,
        CASE
          WHEN tables.table_id IS NULL THEN 'Missing'
          WHEN tables.row_count = 0 THEN 'Empty'
          WHEN gemini.events = 0 THEN 'No Gemini events'
          WHEN TIMESTAMP_MILLIS(tables.last_modified_time) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 DAY) THEN 'Stale'
          ELSE 'OK'
        END AS status,
        tables.row_count,
        TIMESTAMP_MILLIS(tables.last_modified_time) AS last_modified,
        gemini.events AS gemini_events_7d,
        CASE
          WHEN tables.table_id IS NULL THEN 'No activity table in @{workspace_dataset}. Check the dataset name, and that the export has run (it can take 24 hours).'
          WHEN gemini.events = 0 THEN 'The export has no Gemini events in the last 7 days. Check that Gemini audit logging is on in the Admin console and that people use Gemini in Workspace.'
          {% if '@{workspace_export}' == 'separate_region' %}
          ELSE 'Only the Workspace Gemini tab uses this export. To add Workspace to the AI adoption tabs, copy it into the same location as @{gemini_dataset} (Terraform workspace_audit_dataset_id does this) and set Workspace audit export to same_region.'
          {% else %}
          ELSE ''
          {% endif %}
        END AS next_step
      FROM (SELECT 'activity' AS table_id) AS wanted
      LEFT JOIN `@{gemini_project}.@{workspace_dataset}.__TABLES__` AS tables USING (table_id)
      CROSS JOIN (
        SELECT COUNT(*) AS events
        FROM `@{gemini_project}.@{workspace_dataset}.activity`
        WHERE gemini_for_workspace.app_name IS NOT NULL
          AND time_usec >= UNIX_MICROS(TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY))
          AND _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY)
      ) AS gemini
      {% if '@{workspace_export}' == 'same_region' %}
      CROSS JOIN (SELECT COUNT(*) AS gemini_tables FROM `@{gemini_project}.@{gemini_dataset}.__TABLES__`) AS location_check
      {% endif %}
      {% endif %} ;;
  }

  dimension: setting {
    primary_key: yes
    label: "Workspace Export Setting"
    type: string
    sql: ${TABLE}.setting ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    html: {% if value == 'OK' or value == 'Not configured' %}<span style="color:#188038">{{ value }}</span>{% else %}<span style="color:#d93025;font-weight:bold">{{ value }}</span>{% endif %} ;;
  }

  dimension: row_count {
    type: number
    sql: ${TABLE}.row_count ;;
    value_format_name: decimal_0
  }

  dimension_group: last_modified {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.last_modified ;;
  }

  dimension: gemini_events_7d {
    label: "Gemini Events (7d)"
    type: number
    sql: ${TABLE}.gemini_events_7d ;;
    value_format_name: decimal_0
  }

  dimension: next_step {
    type: string
    sql: ${TABLE}.next_step ;;
  }
}

view: setup_settings {
  label: "Setup Health"
  # The block's install settings, so whoever reads the dashboard can see the
  # assumptions behind cohorts, time zones and ROI figures.
  derived_table: {
    sql:
      SELECT * FROM UNNEST([
        STRUCT(1 AS sort_order, 'Workspace audit export' AS setting, '@{workspace_export}' AS value),
        STRUCT(2, 'Workspace audit dataset', '@{workspace_dataset}'),
        STRUCT(3, 'Gemini analytics dataset', '@{gemini_project}.@{gemini_dataset}'),
        STRUCT(4, 'Reporting time zone', '@{reporting_time_zone}'),
        STRUCT(5, 'Power user threshold (AI days in 28)', '@{power_user_min_days}'),
        STRUCT(6, 'Normal user threshold (AI days in 28)', '@{normal_user_min_days}'),
        STRUCT(7, 'Gemini Enterprise monthly seat cost', '@{currency_symbol}@{ge_seat_cost_monthly}'),
        STRUCT(8, 'Workspace Gemini monthly seat cost', '@{currency_symbol}@{gws_seat_cost_monthly}'),
        STRUCT(9, 'Loaded hourly rate', '@{currency_symbol}@{loaded_hourly_rate}'),
        STRUCT(10, 'Minutes saved per AI action', '@{time_saved_minutes}'),
        STRUCT(11, 'Low time-saved scenario factor', '@{time_saved_low_factor}'),
        STRUCT(12, 'High time-saved scenario factor', '@{time_saved_high_factor}'),
        STRUCT(13, 'Use-case mapping', '@{use_case_mapping}'),
        STRUCT(14, 'Employee domains', '@{employee_domains}'),
        STRUCT(15, 'Excluded org units', '@{excluded_org_units}'),
        STRUCT(16, 'Excluded email pattern', '@{excluded_email_pattern}'),
        STRUCT(17, 'Org-unit depth for departments', '@{org_unit_depth}'),
        STRUCT(18, 'Interventions table', '@{interventions_table}'),
        STRUCT(19, 'Value outcomes table', '@{value_outcomes_table}')
      ]) ;;
  }

  dimension: setting {
    primary_key: yes
    type: string
    sql: ${TABLE}.setting ;;
    order_by_field: sort_order
  }

  dimension: sort_order {
    hidden: yes
    type: number
    sql: ${TABLE}.sort_order ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }
}
