view: ai_activity_hourly {
  label: "AI Activity"
  # One row per user, product, surface, feature, interaction mode and UTC hour
  # across Gemini Enterprise, Gemini for Workspace and Antigravity, over the
  # last 400 days.
  #   Interaction    Active: a person asked Gemini for something.
  #   mode           Automated: a workflow or scheduled/triggered agent ran on
  #                  their behalf. Proactive: Gemini offered output nobody
  #                  asked for (Workspace "inactive" events).
  #   AI actions     what counts as using AI: Active events only, so
  #                  automation and suggestions never inflate adoption
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
          IF(invocation_mode IN ('Scheduled', 'Triggered'), 'Automated', 'Active') AS interaction_mode,
          COUNT(*) AS events,
          COUNTIF(is_user_prompt OR is_user_search) AS ai_actions,
          COUNTIF(
            is_user_prompt OR is_user_search
            OR invocation_mode IN ('Scheduled', 'Triggered')
            OR executed_action IS NOT NULL
          ) AS value_actions,
          COUNTIF(is_user_prompt) AS prompts,
          CAST(0 AS INT64) AS tokens
        FROM (SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity` AS source LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity ON person_identity.source_email = LOWER(source.user_email) AND source.event_ts >= person_identity.valid_from AND source.event_ts < person_identity.valid_to)
        WHERE user_email IS NOT NULL
          AND feature NOT IN ('Assistant grounding', 'Navigation', 'Other')
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)
        GROUP BY 1, 2, 3, 4, 5, 6
      ),

      gws AS (
        {% if '@{workspace_export}' == 'same_region' %}
        SELECT
          TIMESTAMP_TRUNC(TIMESTAMP_MICROS(activity.time_usec), HOUR) AS event_hour,
          COALESCE(person_identity.person_email, LOWER(activity.email)) AS user_email,
          'Gemini for Workspace' AS product,
          gemini_for_workspace.app_name AS surface,
          IF(IFNULL(gemini_for_workspace.feature_source, 'feature_source_unspecified') IN ('feature_source_unspecified', 'unspecified'),
            CONCAT(gemini_for_workspace.app_name, '_unspecified'),
            gemini_for_workspace.feature_source) AS feature,
          CASE
            WHEN NOT STARTS_WITH(IFNULL(gemini_for_workspace.event_category, ''), 'active') THEN 'Proactive'
            WHEN gemini_for_workspace.app_name = 'workflows'
              AND IFNULL(gemini_for_workspace.feature_source, '') != 'workflows_creation' THEN 'Automated'
            ELSE 'Active'
          END AS interaction_mode,
          COUNT(*) AS events,
          COUNTIF(STARTS_WITH(IFNULL(gemini_for_workspace.event_category, ''), 'active')
            AND NOT (gemini_for_workspace.app_name = 'workflows'
              AND IFNULL(gemini_for_workspace.feature_source, '') != 'workflows_creation')) AS ai_actions,
          COUNTIF(STARTS_WITH(IFNULL(gemini_for_workspace.event_category, ''), 'active')) AS value_actions,
          CAST(0 AS INT64) AS prompts,
          CAST(0 AS INT64) AS tokens
        FROM `@{gemini_project}.@{workspace_dataset}.activity` AS activity
        LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
          ON person_identity.source_email = LOWER(activity.email)
          AND TIMESTAMP_MICROS(activity.time_usec) >= person_identity.valid_from
          AND TIMESTAMP_MICROS(activity.time_usec) < person_identity.valid_to
        WHERE activity.gemini_for_workspace.app_name IS NOT NULL
          AND activity.email IS NOT NULL
          AND activity.time_usec >= UNIX_MICROS(TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)))
          AND activity._PARTITIONTIME >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY))
        GROUP BY 1, 2, 3, 4, 5, 6
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
          'Active' AS interaction_mode,
          COUNT(*) AS events,
          COUNT(*) AS ai_actions,
          COUNT(DISTINCT trajectory_id) AS value_actions,
          CAST(0 AS INT64) AS prompts,
          SUM(IFNULL(total_tokens, 0)) AS tokens
        FROM (SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email) FROM `@{gemini_project}.@{gemini_dataset}.antigravity_usage` AS source LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity ON person_identity.source_email = LOWER(source.user_email) AND source.event_ts >= person_identity.valid_from AND source.event_ts < person_identity.valid_to)
        WHERE user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)
        GROUP BY 1, 2, 3, 4, 5, 6
      ),

      unioned AS (
        SELECT * FROM ge
        UNION ALL
        SELECT * FROM gws
        UNION ALL
        SELECT * FROM antigravity
      ),

      scoped AS (
      SELECT
        CONCAT(
          unioned.user_email, '|', unioned.product, '|', IFNULL(unioned.surface, ''), '|', IFNULL(unioned.feature, ''), '|', unioned.interaction_mode, '|',
          FORMAT_TIMESTAMP('%Y%m%d%H', unioned.event_hour)
        ) AS pk,
        DATE(unioned.event_hour) AS event_date,
        unioned.*,
        {% assign pairs = '@{use_case_mapping}' | split: ',' %}{% assign fallback = 'Unclassified' %}CASE LOWER(unioned.feature)
        {% for pair in pairs %}{% assign kv = pair | split: '=' %}{% assign key = kv[0] | strip | downcase %}{% if key == 'default' %}{% assign fallback = kv[1] | strip %}{% elsif key != '' %}
        WHEN '{{ key }}' THEN '{{ kv[1] | strip }}'{% endif %}{% endfor %}
        ELSE '{{ fallback }}'
        END AS use_case
      FROM unioned
      JOIN ${population_scope.SQL_TABLE_NAME} AS population_scope
        ON population_scope.user_email = unioned.user_email
      WHERE population_scope.in_scope
      ),

      use_case_totals AS (
        SELECT
          scoped.*,
          SUM(IF(use_case != 'Unclassified' AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY), ai_actions, 0))
            OVER (PARTITION BY use_case) AS use_case_actions_90d
        FROM scoped
      ),

      use_case_ranks AS (
        SELECT
          use_case_totals.*,
          DENSE_RANK() OVER (ORDER BY use_case_actions_90d DESC, use_case) AS use_case_rank
        FROM use_case_totals
      )

      SELECT
        use_case_ranks.* EXCEPT (use_case_actions_90d, use_case_rank),
        IF(use_case_rank <= 3 AND use_case_actions_90d > 0, use_case, 'Other') AS use_case_group,
        IF(use_case_rank <= 3 AND use_case_actions_90d > 0, use_case_rank, 4) AS use_case_group_order
      FROM use_case_ranks ;;
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

  dimension: is_complete_week {
    label: "Is Complete Week"
    description: "Yes for activity before the start of the current Monday-to-Sunday week. Filter weekly trends on this so the unfinished current week doesn't look like a drop."
    type: yesno
    sql: ${TABLE}.event_date < DATE_TRUNC(CURRENT_DATE('@{reporting_time_zone}'), WEEK(MONDAY)) ;;
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

  dimension: feature_label {
    label: "Feature (Readable)"
    description: "Feature name for display. Workspace events where Google did not record a feature show as '<app> (feature not recorded)'; the raw value is <app>_unspecified."
    type: string
    sql: IF(ENDS_WITH(${TABLE}.feature, '_unspecified'),
      CONCAT(REGEXP_REPLACE(${TABLE}.feature, r'_unspecified$', ''), ' (feature not recorded)'),
      INITCAP(REPLACE(${TABLE}.feature, '_', ' '))) ;;
  }

  dimension: interaction_mode {
    label: "Interaction Mode"
    description: "Active: a person asked Gemini for something. Automated: a workflow or scheduled/triggered agent ran on their behalf. Proactive: Gemini offered output nobody asked for, such as suggestions or automatic meeting-note extracts. Only Active counts towards adoption."
    type: string
    sql: ${TABLE}.interaction_mode ;;
  }

  dimension: interaction_type {
    label: "Active or Passive"
    description: "Active (a person asked) or Passive (Automated or Proactive)."
    type: string
    sql: IF(${TABLE}.interaction_mode = 'Active', 'Active', 'Passive') ;;
  }

  dimension: use_case {
    label: "AI Use Case"
    description: "Business-facing use-case group mapped from product and feature. Unclassified is explicit when the source event does not identify a meaningful feature."
    type: string
    sql: ${TABLE}.use_case ;;
  }

  dimension: use_case_group {
    label: "AI Use Case (Top 3)"
    description: "The three use cases with the most hands-on actions in the last 90 days, with everything else as Other. Fixed at each daily rebuild so trend colours stay stable."
    type: string
    sql: ${TABLE}.use_case_group ;;
    order_by_field: use_case_group_order
  }

  dimension: use_case_group_order {
    hidden: yes
    type: number
    sql: ${TABLE}.use_case_group_order ;;
  }

  dimension: use_case_confidence {
    label: "Use Case Confidence"
    description: "High when a specific feature/source was mapped, Low when the event source is unspecified or otherwise unclassified."
    type: string
    sql: CASE
      WHEN LOWER(${TABLE}.feature) IN ('unspecified', 'unknown') OR ENDS_WITH(LOWER(${TABLE}.feature), '_unspecified') THEN 'Low'
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
    description: "Things a person asked Gemini to do: Gemini Enterprise prompts and searches, active Workspace Gemini events (excluding workflow runs) and Antigravity requests. Excludes automated and proactive events."
    type: sum
    sql: ${TABLE}.ai_actions ;;
    drill_fields: [user_email, product, feature, ai_actions]
  }

  measure: ai_events {
    label: "All AI Events"
    description: "Every Gemini event, active and passive. Split by Interaction Mode to see how much is automation or proactive suggestions."
    type: sum
    sql: ${TABLE}.events ;;
  }

  measure: automated_events {
    label: "Automated AI Events"
    description: "Workflow steps and runs, and scheduled or triggered agent runs. One workflow run can log several events."
    type: sum
    sql: ${TABLE}.events ;;
    filters: [interaction_mode: "Automated"]
  }

  measure: proactive_events {
    label: "Proactive AI Events"
    description: "Suggestions and output Gemini produced without being asked."
    type: sum
    sql: ${TABLE}.events ;;
    filters: [interaction_mode: "Proactive"]
  }

  measure: passive_event_share {
    label: "Passive Share of AI Events"
    description: "Automated Flow runs plus proactive suggestions, divided by all AI events (hands-on, automated and proactive) by eligible people in the selected dates. Event-based, not a share of people."
    type: number
    sql: SAFE_DIVIDE(${automated_events} + ${proactive_events}, NULLIF(${ai_events}, 0)) ;;
    value_format_name: percent_0
  }

  measure: automation_users {
    label: "People Using Automation"
    description: "People with at least one automated workflow or agent run."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.interaction_mode = 'Automated' AND ${TABLE}.events > 0 THEN ${TABLE}.user_email END ;;
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
    description: "Hands-on AI actions by eligible people in the selected dates whose feature has no business use case in the use_case_mapping constant, divided by all hands-on AI actions."
    type: number
    sql: SAFE_DIVIDE(${unclassified_actions}, NULLIF(${ai_actions}, 0)) ;;
    value_format_name: percent_0
  }

  # Estimated time benefit. The headline counts Active actions only: things a
  # person asked for. Automated runs are a separate, lower-confidence estimate
  # because a run can fire on every incoming item without replacing any work.
  # Proactive events never earn credit.
  measure: hours_saved {
    label: "Estimated Hours Saved"
    description: "Active value actions times the minutes in the Minutes saved per AI action setting, in hours. Excludes automated runs and proactive suggestions. An assumption-based estimate, not a measurement."
    type: sum
    sql: IF(${TABLE}.interaction_mode = 'Active', ${TABLE}.value_actions * ${minutes_saved_per_action} / 60, 0) ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_low {
    label: "Estimated Hours Saved (Low)"
    description: "Low scenario for estimated hours saved, using the low scenario factor."
    type: number
    sql: ${hours_saved} * @{time_saved_low_factor} ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_high {
    label: "Estimated Hours Saved (High)"
    description: "High scenario for estimated hours saved, using the high scenario factor."
    type: number
    sql: ${hours_saved} * @{time_saved_high_factor} ;;
    value_format_name: decimal_0
  }

  measure: automation_hours_saved {
    label: "Estimated Automation Hours (lower confidence)"
    description: "Automated workflow and agent runs times their minutes-saved setting. Lower confidence: a run is not proof that work was replaced. Kept out of the headline estimate."
    type: sum
    sql: IF(${TABLE}.interaction_mode = 'Automated', ${TABLE}.value_actions * ${minutes_saved_per_action} / 60, 0) ;;
    value_format_name: decimal_0
  }

  measure: credited_hours {
    label: "Credited Hours (all modes)"
    description: "Active plus automated estimated hours. Use it to audit which features earn time-saving credit."
    type: number
    sql: ${hours_saved} + ${automation_hours_saved} ;;
    value_format_name: decimal_0
  }

  measure: credited_actions {
    label: "Credited Actions"
    description: "Actions that earn time-saving credit: active value actions plus automated runs."
    type: sum
    sql: IF(${TABLE}.interaction_mode IN ('Active', 'Automated'), ${TABLE}.value_actions, 0) ;;
  }

  measure: window_days {
    hidden: yes
    type: number
    sql: DATE_DIFF(MAX(${TABLE}.event_date), MIN(${TABLE}.event_date), DAY) + 1 ;;
  }

  measure: hours_saved_per_month {
    label: "Estimated Hours Saved per Month"
    description: "Estimated hours saved scaled to an average month (30.4 days) from the days covered by the selection."
    type: number
    sql: SAFE_DIVIDE(${hours_saved}, NULLIF(${window_days}, 0)) * 30.4 ;;
    value_format_name: decimal_0
    html: <div style="font-size:40px;font-weight:700;line-height:1.1">{{ rendered_value }} h</div><div style="font-size:13px;color:#5f6368">Range {{ hours_saved_low_per_month._rendered_value }} to {{ hours_saved_high_per_month._rendered_value }} h, hands-on actions only</div> ;;
  }

  measure: hours_saved_low_per_month {
    label: "Estimated Hours Saved per Month (Low)"
    type: number
    sql: ${hours_saved_per_month} * @{time_saved_low_factor} ;;
    value_format_name: decimal_0
  }

  measure: hours_saved_high_per_month {
    label: "Estimated Hours Saved per Month (High)"
    type: number
    sql: ${hours_saved_per_month} * @{time_saved_high_factor} ;;
    value_format_name: decimal_0
  }

  measure: automation_hours_per_month {
    label: "Estimated Automation Hours per Month (lower confidence)"
    type: number
    sql: SAFE_DIVIDE(${automation_hours_saved}, NULLIF(${window_days}, 0)) * 30.4 ;;
    value_format_name: decimal_0
    html: <div style="font-size:40px;font-weight:700;line-height:1.1;color:#5f6368">{{ rendered_value }} h</div><div style="font-size:13px;color:#5f6368">{{ automation_runs_per_month._rendered_value }} automated runs a month, excluded from the headline</div> ;;
  }

  measure: automation_runs_per_month {
    hidden: yes
    type: number
    sql: SAFE_DIVIDE(SUM(IF(${TABLE}.interaction_mode = 'Automated' AND ${minutes_saved_per_action} > 0, ${TABLE}.value_actions, 0)), NULLIF(${window_days}, 0)) * 30.4 ;;
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
    description: "Estimated hours saved times the loaded hourly rate setting."
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

  measure: value_per_month {
    label: "Estimated Time Benefit per Month"
    description: "Estimated hours saved per month times the loaded hourly rate. An estimate of time benefit, not realised ROI."
    type: number
    sql: ${hours_saved_per_month} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{loaded_hourly_rate} == 0 %}<span style="font-size:14px">Set the loaded hourly rate in Marketplace &gt; Manage</span>{% else %}<div style="font-size:40px;font-weight:700;line-height:1.1">{{ rendered_value }}</div><div style="font-size:13px;color:#5f6368">Range {{ value_low_per_month._rendered_value }} to {{ value_high_per_month._rendered_value }} at @{currency_symbol}@{loaded_hourly_rate} an hour</div>{% endif %} ;;
  }

  measure: value_low_per_month {
    hidden: yes
    type: number
    sql: ${hours_saved_low_per_month} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
  }

  measure: value_high_per_month {
    hidden: yes
    type: number
    sql: ${hours_saved_high_per_month} * @{loaded_hourly_rate} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
  }

  measure: tracking_since {
    label: "Tracking Since"
    description: "Earliest activity date in the selected data."
    type: min
    sql: ${TABLE}.event_date ;;
  }
}
