view: workspace_gemini_activity {
  label: "Workspace Gemini Activity"
  # Gemini-for-Workspace usage from the Google Workspace audit log BigQuery export.
  # One row per Gemini event. event_category distinguishes active usage
  # (active_generate / active_conversations / active_summarize) from passive
  # surfacing (inactive).
  #
  # Persisted (PDT) and rebuilt daily by the model datagroup: the raw audit
  # export grows continuously and an unpersisted derived table would rescan the
  # whole `activity` table on every dashboard query.
  #
  # Empty when the workspace_export constant is none, so the dashboard
  # renders (with no data) before the Workspace export is set up.
  derived_table: {
    datagroup_trigger: workspace_gemini_default_datagroup
    sql:
      {% if '@{workspace_export}' != 'none' %}
      SELECT
        ROW_NUMBER() OVER (ORDER BY time_usec, email) AS pk,
        TIMESTAMP_MICROS(time_usec) AS event_ts,
        DATE(TIMESTAMP_MICROS(time_usec)) AS event_date,
        LOWER(email) AS email,
        domain_name,
        -- The export stores the org-unit path as an array that starts with
        -- the organisation itself: [org, 'Sales', 'EMEA'] becomes /Sales/EMEA.
        IF(ARRAY_LENGTH(org_unit_name_path) = 0, NULL, CONCAT('/', ARRAY_TO_STRING(ARRAY(
          SELECT part FROM UNNEST(org_unit_name_path) AS part WITH OFFSET AS depth
          WHERE depth > 0 ORDER BY depth
        ), '/'))) AS org_unit_name_path,
        gemini_for_workspace.app_name AS app_name,
        gemini_for_workspace.feature_source AS feature_source,
        gemini_for_workspace.action AS action,
        gemini_for_workspace.event_category AS event_category,
        STARTS_WITH(gemini_for_workspace.event_category, 'active') AS is_active_usage
      FROM `@{gemini_project}.@{workspace_dataset}.activity`
      WHERE gemini_for_workspace.app_name IS NOT NULL
      {% else %}
      SELECT
        CAST(NULL AS INT64) AS pk,
        CAST(NULL AS TIMESTAMP) AS event_ts,
        CAST(NULL AS DATE) AS event_date,
        CAST(NULL AS STRING) AS email,
        CAST(NULL AS STRING) AS domain_name,
        CAST(NULL AS STRING) AS org_unit_name_path,
        CAST(NULL AS STRING) AS app_name,
        CAST(NULL AS STRING) AS feature_source,
        CAST(NULL AS STRING) AS action,
        CAST(NULL AS STRING) AS event_category,
        CAST(NULL AS BOOL) AS is_active_usage
      FROM UNNEST(ARRAY<INT64>[])
      {% endif %} ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.pk ;;
  }

  dimension_group: event {
    label: "Event"
    description: "Date (UTC) the Gemini event occurred, derived from the audit log timestamp."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension_group: event_local {
    label: "Local Time"
    description: "Event time in the reporting_time_zone constant, for time-of-day patterns."
    type: time
    timeframes: [time, hour_of_day, day_of_week, day_of_week_index]
    convert_tz: no
    datatype: datetime
    sql: DATETIME(${TABLE}.event_ts, '@{reporting_time_zone}') ;;
  }

  dimension: email {
    label: "User Email"
    description: "Email address of the user who triggered the Gemini event."
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: domain_name {
    label: "Domain"
    description: "Workspace domain the user belongs to."
    type: string
    sql: ${TABLE}.domain_name ;;
  }

  dimension: org_unit_name_path {
    label: "Org Unit"
    description: "Full org-unit path of the user in the Workspace directory. Use to break adoption down by department or team."
    type: string
    sql: ${TABLE}.org_unit_name_path ;;
  }

  dimension: app_name {
    label: "App"
    description: "Workspace surface, e.g. gmail, chat, meet, drive, docs, sheets, gemini_app."
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: feature_source {
    label: "Feature"
    description: "Gemini feature, e.g. help_me_write, take_notes_for_me, conversation_summaries."
    type: string
    sql: ${TABLE}.feature_source ;;
  }

  dimension: action {
    description: "Specific Gemini action recorded by the audit log for the event."
    type: string
    sql: ${TABLE}.action ;;
  }

  dimension: event_category {
    description: "active_generate, active_conversations, active_summarize, inactive, or unknown."
    type: string
    sql: ${TABLE}.event_category ;;
  }

  dimension: is_active_usage {
    label: "Is Active Usage"
    description: "True when the user actively generated, conversed, or summarised (vs passive surfacing)."
    type: yesno
    sql: ${TABLE}.is_active_usage ;;
  }

  measure: events {
    label: "Gemini Events"
    description: "Total Gemini-for-Workspace events (active and passive)."
    type: count
    drill_fields: [event_date, email, app_name, feature_source, event_category]
  }

  measure: active_events {
    label: "Active Gemini Events"
    description: "Events where the user actively used Gemini (generate, converse, or summarise), excluding passive surfacing."
    type: count
    filters: [is_active_usage: "yes"]
  }

  measure: active_usage_rate {
    label: "Active Usage Rate"
    description: "Share of Gemini events that were active usage rather than passive surfacing."
    type: number
    sql: SAFE_DIVIDE(${active_events}, ${events}) ;;
    value_format_name: percent_1
  }

  measure: active_users {
    label: "Gemini Users"
    description: "Distinct users with any Gemini event."
    type: count_distinct
    sql: ${email} ;;
    drill_fields: [email, events]
  }

  measure: engaged_users {
    label: "Engaged Gemini Users"
    description: "Distinct users with at least one active usage event."
    type: count_distinct
    sql: CASE WHEN ${is_active_usage} THEN ${email} END ;;
    drill_fields: [email, active_events]
  }

  measure: events_per_user {
    description: "Average Gemini events per user (total events divided by distinct users). A usage-intensity signal."
    type: number
    sql: SAFE_DIVIDE(${events}, NULLIF(${active_users}, 0)) ;;
    value_format_name: decimal_1
  }
}
