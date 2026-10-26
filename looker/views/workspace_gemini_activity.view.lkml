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
        ROW_NUMBER() OVER (ORDER BY activity.time_usec, activity.email) AS pk,
        TIMESTAMP_MICROS(activity.time_usec) AS event_ts,
        DATE(TIMESTAMP_MICROS(activity.time_usec)) AS event_date,
        {% if '@{workspace_export}' == 'same_region' %}COALESCE(person_identity.person_email, LOWER(activity.email)){% else %}LOWER(activity.email){% endif %} AS email,
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
        STARTS_WITH(gemini_for_workspace.event_category, 'active') AS is_active_usage,
        CASE
          WHEN NOT STARTS_WITH(IFNULL(gemini_for_workspace.event_category, ''), 'active') THEN 'Proactive'
          WHEN gemini_for_workspace.app_name = 'workflows' AND IFNULL(gemini_for_workspace.feature_source, '') != 'workflows_creation' THEN 'Automated'
          ELSE 'Active'
        END AS interaction_mode
      FROM `@{gemini_project}.@{workspace_dataset}.activity` AS activity
      {% if '@{workspace_export}' == 'same_region' %}
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = LOWER(activity.email)
        AND TIMESTAMP_MICROS(activity.time_usec) >= person_identity.valid_from
        AND TIMESTAMP_MICROS(activity.time_usec) < person_identity.valid_to
      {% endif %}
      WHERE activity.gemini_for_workspace.app_name IS NOT NULL
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
        CAST(NULL AS BOOL) AS is_active_usage,
        CAST(NULL AS STRING) AS interaction_mode
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
    required_access_grants: [can_see_individuals]
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

  dimension: feature_label {
    label: "Feature (Readable)"
    description: "Feature name for display. Events where Google did not record a feature show as '<app> (feature not recorded)'."
    type: string
    sql: IF(IFNULL(${TABLE}.feature_source, 'feature_source_unspecified') IN ('feature_source_unspecified', 'unspecified'),
      CONCAT(${TABLE}.app_name, ' (feature not recorded)'),
      INITCAP(REPLACE(${TABLE}.feature_source, '_', ' '))) ;;
  }

  dimension: app_feature_label {
    label: "App and Feature"
    description: "App and readable feature together, for example Gmail: Help Me Write. The same feature name can appear in several apps."
    type: string
    sql: CONCAT(INITCAP(REPLACE(${TABLE}.app_name, '_', ' ')), ': ', ${feature_label}) ;;
  }

  dimension: interaction_mode {
    label: "Interaction Mode"
    description: "Active: the person asked Gemini to do something. Automated: a Workspace Flow ran on its own. Proactive: Gemini surfaced a suggestion or feature without being asked. Same rule as the change-management dashboards."
    type: string
    sql: ${TABLE}.interaction_mode ;;
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
    description: "True for any active_* audit category, including automated Workspace Flow runs. Use Interaction Mode to separate hands-on use from automation."
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
    label: "Hands-on Gemini Events"
    description: "Events where a person asked Gemini to do something. Excludes automated Workspace Flow runs and proactive suggestions."
    type: count
    filters: [interaction_mode: "Active"]
  }

  measure: automated_events {
    label: "Automated Gemini Events"
    description: "Workspace Flow runs and steps that ran without a person in the loop."
    type: count
    filters: [interaction_mode: "Automated"]
  }

  measure: surfaced_events {
    label: "Proactive Gemini Events"
    description: "Times Gemini surfaced a suggestion or feature without being asked."
    type: count
    filters: [interaction_mode: "Proactive"]
  }

  measure: active_usage_rate {
    label: "Hands-on Share of Workspace Gemini Events"
    description: "Hands-on events divided by all Workspace Gemini events (hands-on, automated and proactive) in the selected dates. Most events are proactive, so this share is low even when people use Gemini daily."
    type: number
    sql: SAFE_DIVIDE(${active_events}, NULLIF(${events}, 0)) ;;
    value_format_name: percent_1
  }

  measure: surfaced_users {
    label: "People Shown the Feature"
    description: "Distinct people Gemini proactively surfaced this feature to in the selected dates."
    type: count_distinct
    sql: IF(${TABLE}.interaction_mode = 'Proactive', ${TABLE}.email, NULL) ;;
  }

  measure: acting_users {
    label: "People Who Used It"
    description: "Distinct people with at least one hands-on event for this feature in the selected dates."
    type: count_distinct
    sql: IF(${TABLE}.interaction_mode = 'Active', ${TABLE}.email, NULL) ;;
  }

  measure: uptake_rate {
    label: "Uptake"
    description: "People who used the feature divided by people it was shown to, in the selected dates. Can exceed 100% when people open the feature directly without being prompted."
    type: number
    sql: SAFE_DIVIDE(${acting_users}, NULLIF(${surfaced_users}, 0)) ;;
    value_format_name: percent_0
  }

  measure: active_users {
    label: "Gemini Users"
    description: "Distinct users with any Workspace Gemini event in the selected dates, including people who were only shown suggestions. Not filtered by the population scope used on the Executive and Change dashboards."
    type: count_distinct
    sql: ${email} ;;
    drill_fields: [email, events]
  }

  measure: engaged_users {
    label: "Engaged Gemini Users"
    description: "Distinct users with at least one hands-on event in the selected dates. Automated Flow runs and proactive suggestions do not count."
    type: count_distinct
    sql: IF(${TABLE}.interaction_mode = 'Active', ${TABLE}.email, NULL) ;;
    drill_fields: [email, active_events]
  }

  measure: events_per_user {
    description: "Average Gemini events per user (total events divided by distinct users). A usage-intensity signal."
    type: number
    sql: SAFE_DIVIDE(${events}, NULLIF(${active_users}, 0)) ;;
    value_format_name: decimal_1
  }
}
