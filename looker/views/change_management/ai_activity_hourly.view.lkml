view: ai_activity_hourly {
  label: "AI Activity"
  # One row per user, product, surface, feature and UTC hour across Gemini
  # Enterprise, Gemini for Workspace and Antigravity, over the last 400 days.
  #   AI actions     what counts as using AI: a Gemini Enterprise prompt or
  #                  search, an active Workspace Gemini event (generate,
  #                  converse, summarise), or an Antigravity request
  #   Value actions  what the time-saved estimate multiplies: AI actions plus
  #                  scheduled agent runs and executed actions for Gemini
  #                  Enterprise; agent tasks (trajectories) for Antigravity
  # Workspace rows need workspace_export = same_region.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    partition_keys: ["event_date"]
    cluster_keys: ["user_email", "product"]
    sql:
      WITH ge AS (
        SELECT
          TIMESTAMP_TRUNC(event_ts, HOUR) AS event_hour,
          LOWER(user_email) AS user_email,
          'Gemini Enterprise' AS product,
          app_name AS surface,
          feature,
          COUNT(*) AS events,
          COUNTIF(is_user_prompt OR is_user_search) AS ai_actions,
          COUNTIF(
            is_user_prompt OR is_user_search
            OR invocation_mode IN ('Scheduled', 'Triggered')
            OR executed_action IS NOT NULL
          ) AS value_actions,
          COUNTIF(is_user_prompt) AS prompts,
          CAST(0 AS INT64) AS tokens
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
        WHERE user_email IS NOT NULL
          AND feature NOT IN ('Assistant grounding', 'Navigation', 'Other')
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)
        GROUP BY 1, 2, 3, 4, 5
      ),

      gws AS (
        {% if '@{workspace_export}' == 'same_region' %}
        SELECT
          TIMESTAMP_TRUNC(TIMESTAMP_MICROS(time_usec), HOUR) AS event_hour,
          LOWER(email) AS user_email,
          'Gemini for Workspace' AS product,
          gemini_for_workspace.app_name AS surface,
          COALESCE(gemini_for_workspace.feature_source, 'unspecified') AS feature,
          COUNT(*) AS events,
          COUNTIF(STARTS_WITH(gemini_for_workspace.event_category, 'active')) AS ai_actions,
          COUNTIF(STARTS_WITH(gemini_for_workspace.event_category, 'active')) AS value_actions,
          CAST(0 AS INT64) AS prompts,
          CAST(0 AS INT64) AS tokens
        FROM `@{gemini_project}.@{workspace_dataset}.activity`
        WHERE gemini_for_workspace.app_name IS NOT NULL
          AND email IS NOT NULL
          AND time_usec >= UNIX_MICROS(TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)))
          AND _PARTITIONTIME >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY))
        GROUP BY 1, 2, 3, 4, 5
        {% else %}
        SELECT * FROM ge WHERE FALSE
        {% endif %}
      ),

      antigravity AS (
        SELECT
          TIMESTAMP_TRUNC(event_ts, HOUR) AS event_hour,
          LOWER(user_email) AS user_email,
          'Antigravity' AS product,
          COALESCE(client_name, 'Unknown') AS surface,
          COALESCE(experience, 'Unknown') AS feature,
          COUNT(*) AS events,
          COUNT(*) AS ai_actions,
          COUNT(DISTINCT trajectory_id) AS value_actions,
          CAST(0 AS INT64) AS prompts,
          SUM(IFNULL(total_tokens, 0)) AS tokens
        FROM `@{gemini_project}.@{gemini_dataset}.antigravity_usage`
        WHERE user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)
        GROUP BY 1, 2, 3, 4, 5
      ),

      unioned AS (
        SELECT * FROM ge
        UNION ALL
        SELECT * FROM gws
        UNION ALL
        SELECT * FROM antigravity
      )

      SELECT
        CONCAT(
          unioned.user_email, '|', unioned.product, '|', IFNULL(unioned.surface, ''), '|', IFNULL(unioned.feature, ''), '|',
          FORMAT_TIMESTAMP('%Y%m%d%H', unioned.event_hour)
        ) AS pk,
        DATE(unioned.event_hour) AS event_date,
        unioned.*
      FROM unioned
      JOIN ${population_scope.SQL_TABLE_NAME} AS population_scope
        ON population_scope.user_email = unioned.user_email
      WHERE population_scope.in_scope ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension_group: event {
    label: "Activity"
    description: "Date (UTC) of the activity. Filter on this to limit the partitions scanned."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension_group: event_local {
    label: "Local Time"
    description: "Activity hour in the reporting time zone (the reporting_time_zone constant), for time-of-day patterns."
    type: time
    timeframes: [hour_of_day, day_of_week, day_of_week_index]
    convert_tz: no
    datatype: datetime
    sql: DATETIME(${TABLE}.event_hour, '@{reporting_time_zone}') ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: user_domain {
    type: string
    sql: REGEXP_EXTRACT(${TABLE}.user_email, r'@(.+)$') ;;
  }

  dimension: product {
    description: "Gemini Enterprise, Gemini for Workspace or Antigravity."
    type: string
    sql: ${TABLE}.product ;;
  }

  dimension: surface {
    description: "Gemini Enterprise app, Workspace app (gmail, docs, meet...) or Antigravity client."
    type: string
    sql: ${TABLE}.surface ;;
  }

  dimension: feature {
    description: "Gemini Enterprise feature, Workspace feature_source (help_me_write, take_notes_for_me...) or Antigravity experience."
    type: string
    sql: ${TABLE}.feature ;;
  }

  dimension: use_case {
    label: "AI Use Case"
    description: "Business-facing use-case group mapped from product and feature. Unclassified is explicit when the source event does not identify a meaningful feature."
    type: string
    sql: {% assign pairs = '@{use_case_mapping}' | split: ',' %}CASE LOWER(${TABLE}.feature)
      {% for pair in pairs %}{% assign kv = pair | split: '=' %}{% assign key = kv[0] | strip | downcase %}{% if key != 'default' %}
      WHEN '{{ key }}' THEN '{{ kv[1] | strip }}'{% endif %}{% endfor %}
      ELSE {% for pair in pairs %}{% assign kv = pair | split: '=' %}{% assign key = kv[0] | strip | downcase %}{% if key == 'default' %}'{{ kv[1] | strip }}'{% endif %}{% endfor %}
      END ;;
  }

  dimension: use_case_confidence {
    label: "Use Case Confidence"
    description: "High when a specific feature/source was mapped, Low when the event source is unspecified or otherwise unclassified."
    type: string
    sql: CASE
      WHEN LOWER(${TABLE}.feature) IN ('unspecified', 'unknown') THEN 'Low'
      WHEN ${use_case} = 'Unclassified' THEN 'Low'
      WHEN ${TABLE}.product = 'Gemini Enterprise' THEN 'Medium'
      ELSE 'High'
    END ;;
  }

  dimension: minutes_saved_per_action {
    description: "Estimated minutes saved per value action, from the time_saved_minutes constant."
    type: number
    sql: {% assign pairs = '@{time_saved_minutes}' | split: ',' %}CASE LOWER(${TABLE}.feature)
      {% for pair in pairs %}{% assign kv = pair | split: '=' %}{% assign key = kv[0] | strip | downcase %}{% if key != 'default' %}
      WHEN '{{ key }}' THEN IFNULL(SAFE_CAST('{{ kv[1] | strip }}' AS FLOAT64), 0){% endif %}{% endfor %}
      ELSE {% for pair in pairs %}{% assign kv = pair | split: '=' %}{% assign key = kv[0] | strip | downcase %}{% if key == 'default' %}IFNULL(SAFE_CAST('{{ kv[1] | strip }}' AS FLOAT64), 0) + {% endif %}{% endfor %}0
      END ;;
  }

  measure: ai_actions {
    label: "AI Actions"
    description: "Gemini Enterprise prompts and searches, active Workspace Gemini events and Antigravity requests."
    type: sum
    sql: ${TABLE}.ai_actions ;;
    drill_fields: [user_email, product, feature, ai_actions]
  }

  measure: value_actions {
    description: "AI actions plus scheduled agent runs and executed actions; Antigravity counts agent tasks. The basis of the time-saved estimate."
    type: sum
    sql: ${TABLE}.value_actions ;;
  }

  measure: prompts {
    label: "Gemini Enterprise Prompts"
    type: sum
    sql: ${TABLE}.prompts ;;
  }

  measure: tokens {
    label: "Antigravity Tokens"
    type: sum
    sql: ${TABLE}.tokens ;;
    value_format_name: decimal_0
  }

  measure: ge_actions {
    label: "Gemini Enterprise Actions"
    type: sum
    sql: ${TABLE}.ai_actions ;;
    filters: [product: "Gemini Enterprise"]
  }

  measure: gws_actions {
    label: "Workspace Gemini Actions"
    type: sum
    sql: ${TABLE}.ai_actions ;;
    filters: [product: "Gemini for Workspace"]
  }

  measure: antigravity_actions {
    label: "Antigravity Requests"
    type: sum
    sql: ${TABLE}.ai_actions ;;
    filters: [product: "Antigravity"]
  }

  measure: ai_users {
    label: "AI Users"
    description: "Distinct users with at least one AI action in the period. At week grain this is weekly active AI users."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 THEN ${user_email} END ;;
    drill_fields: [user_email, ai_actions, ai_active_days]
  }

  measure: ge_users {
    label: "Gemini Enterprise Users"
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 AND ${TABLE}.product = 'Gemini Enterprise' THEN ${user_email} END ;;
  }

  measure: gws_users {
    label: "Workspace Gemini Users"
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 AND ${TABLE}.product = 'Gemini for Workspace' THEN ${user_email} END ;;
  }

  measure: antigravity_users {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 AND ${TABLE}.product = 'Antigravity' THEN ${user_email} END ;;
  }

  measure: ge_or_gws_users {
    hidden: yes
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 AND ${TABLE}.product IN ('Gemini Enterprise', 'Gemini for Workspace') THEN ${user_email} END ;;
  }

  measure: users_ge_and_gws {
    label: "Users of Both"
    description: "Users active in both Gemini Enterprise and Gemini for Workspace in the period."
    type: number
    sql: ${ge_users} + ${gws_users} - ${ge_or_gws_users} ;;
  }

  measure: users_ge_only {
    label: "Gemini Enterprise Only Users"
    type: number
    sql: ${ge_or_gws_users} - ${gws_users} ;;
  }

  measure: users_gws_only {
    label: "Workspace Gemini Only Users"
    type: number
    sql: ${ge_or_gws_users} - ${ge_users} ;;
  }

  measure: ai_active_days {
    label: "AI Active Days"
    description: "User-days with at least one AI action."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 THEN CONCAT(${user_email}, '|', CAST(${TABLE}.event_date AS STRING)) END ;;
  }

  measure: average_daily_ai_users {
    label: "Avg Daily AI Users"
    type: number
    sql: SAFE_DIVIDE(${ai_active_days}, NULLIF(COUNT(DISTINCT CASE WHEN ${TABLE}.ai_actions > 0 THEN ${TABLE}.event_date END), 0)) ;;
    value_format_name: decimal_1
  }

  measure: stickiness {
    label: "Stickiness (DAU/MAU)"
    description: "Average daily AI users divided by distinct AI users in the period. Read it over a month: 20% means the typical user uses AI about one day in five."
    type: number
    sql: SAFE_DIVIDE(${average_daily_ai_users}, NULLIF(${ai_users}, 0)) ;;
    value_format_name: percent_1
  }

  measure: actions_per_ai_user {
    label: "AI Actions per User"
    type: number
    sql: SAFE_DIVIDE(${ai_actions}, NULLIF(${ai_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: active_days_per_ai_user {
    label: "Active Days per AI User"
    type: number
    sql: SAFE_DIVIDE(${ai_active_days}, NULLIF(${ai_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: features_used {
    description: "Distinct features with at least one AI action."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 THEN CONCAT(${TABLE}.product, '|', ${TABLE}.feature) END ;;
  }

  measure: use_cases_used {
    label: "Use Cases Used"
    description: "Distinct business-facing use-case groups with at least one AI action."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.ai_actions > 0 THEN ${use_case} END ;;
  }

  measure: unclassified_actions {
    label: "Unclassified AI Actions"
    description: "AI actions where the source feature maps to Unclassified."
    type: sum
    sql: CASE WHEN ${use_case} = 'Unclassified' THEN ${TABLE}.ai_actions ELSE 0 END ;;
  }

  measure: unclassified_action_share {
    label: "Unclassified Action Share"
    description: "Share of AI actions that cannot be mapped to a business-facing use case."
    type: number
    sql: SAFE_DIVIDE(${unclassified_actions}, NULLIF(${ai_actions}, 0)) ;;
    value_format_name: percent_0
  }

  measure: hours_saved {
    label: "Estimated Hours Saved"
    description: "Value actions times the minutes in the time_saved_minutes constant, in hours. An assumption-based estimate, not a measurement."
    type: sum
    sql: ${TABLE}.value_actions * ${minutes_saved_per_action} / 60 ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_low {
    label: "Estimated Hours Saved (Low)"
    description: "Low scenario for estimated hours saved, using time_saved_low_factor."
    type: number
    sql: ${hours_saved} * @{time_saved_low_factor} ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_high {
    label: "Estimated Hours Saved (High)"
    description: "High scenario for estimated hours saved, using time_saved_high_factor."
    type: number
    sql: ${hours_saved} * @{time_saved_high_factor} ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_per_ai_user {
    label: "Estimated Hours Saved per AI User"
    type: number
    sql: SAFE_DIVIDE(${hours_saved}, NULLIF(${ai_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: value_of_time_saved {
    label: "Estimated Value of Time Saved"
    description: "Estimated hours saved times the loaded_hourly_rate constant."
    type: number
    sql: ${hours_saved} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{loaded_hourly_rate} == 0 %}<span style="font-size:14px">Set the loaded hourly rate in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: value_of_time_saved_low {
    label: "Estimated Value of Time Saved (Low)"
    type: number
    sql: ${hours_saved_low} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{loaded_hourly_rate} == 0 %}<span style="font-size:14px">Set the loaded hourly rate in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: value_of_time_saved_high {
    label: "Estimated Value of Time Saved (High)"
    type: number
    sql: ${hours_saved_high} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{loaded_hourly_rate} == 0 %}<span style="font-size:14px">Set the loaded hourly rate in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: tracking_since {
    label: "Tracking Since"
    description: "Earliest activity date in the selected data."
    type: min
    sql: ${TABLE}.event_date ;;
  }
}
