view: ai_user_profile {
  label: "Person"
  # One row per person in the current population: anyone with a Workspace
  # audit event in the last 28 days (workspace_export = same_region), an
  # assigned Gemini Enterprise licence, or an AI action in the last 28 days.
  # Cohorts use the same thresholds as ai_user_cohort_weekly, over the
  # rolling last 28 days, so these tiles ignore dashboard date filters.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH daily AS (
        SELECT event_date, user_email, product, SUM(ai_actions) AS ai_actions
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE ai_actions > 0
        GROUP BY 1, 2, 3
      ),

      ai AS (
        SELECT
          user_email,
          MIN(event_date) AS first_ai_date,
          MAX(event_date) AS last_ai_date,
          MIN(IF(product = 'Gemini Enterprise', event_date, NULL)) AS first_ge_date,
          COUNT(DISTINCT IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), event_date, NULL)) AS ai_days_28d,
          COUNT(DISTINCT IF(event_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 55 DAY) AND DATE_SUB(CURRENT_DATE(), INTERVAL 28 DAY), event_date, NULL)) AS ai_days_prev_28d,
          COUNT(DISTINCT IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Gemini Enterprise', event_date, NULL)) AS ge_days_28d,
          COUNT(DISTINCT IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Gemini for Workspace', event_date, NULL)) AS gws_days_28d,
          COUNT(DISTINCT IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Antigravity', event_date, NULL)) AS antigravity_days_28d,
          SUM(IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), ai_actions, 0)) AS ai_actions_28d,
          SUM(IF(event_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 55 DAY) AND DATE_SUB(CURRENT_DATE(), INTERVAL 28 DAY), ai_actions, 0)) AS ai_actions_prev_28d,
          SUM(IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Gemini Enterprise', ai_actions, 0)) AS ge_actions_28d,
          SUM(IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Gemini for Workspace', ai_actions, 0)) AS gws_actions_28d,
          SUM(IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY) AND product = 'Antigravity', ai_actions, 0)) AS antigravity_actions_28d
        FROM daily
        GROUP BY user_email
      ),

      peak AS (
        SELECT
          user_email,
          APPROX_TOP_SUM(EXTRACT(HOUR FROM DATETIME(event_hour, '@{reporting_time_zone}')), ai_actions, 1)[SAFE_OFFSET(0)].value AS peak_local_hour
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE ai_actions > 0
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
        GROUP BY user_email
      ),

      models AS (
        SELECT
          user_email,
          APPROX_TOP_COUNT(model, 1)[SAFE_OFFSET(0)].value AS top_model,
          COUNT(DISTINCT model) AS models_used_28d,
          COUNTIF(REGEXP_CONTAINS(UPPER(IFNULL(model_selection_mode, '')), r'AUTO')) AS auto_prompts_28d,
          COUNTIF(
            REGEXP_CONTAINS(UPPER(IFNULL(model_selection_mode, '')), r'AUTO')
            AND REGEXP_CONTAINS(LOWER(model), r'pro|ultra|thinking')
            AND NOT REGEXP_CONTAINS(LOWER(model), r'image|imagen|veo')
          ) AS auto_advanced_prompts_28d
        FROM ${ge_user_activity.SQL_TABLE_NAME}
        WHERE is_user_prompt
          AND model IS NOT NULL
          AND user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
        GROUP BY user_email
      ),

      token_user AS (
        SELECT
          LOWER(user_email) AS user_email,
          SUM(IFNULL(input_tokens, 0) + IFNULL(output_tokens, 0)) AS total_tokens_28d,
          SUM(IFNULL(reasoning_tokens, 0)) AS reasoning_tokens_28d,
          COUNT(*) AS model_calls_28d
        FROM ${ge_model_calls.SQL_TABLE_NAME}
        WHERE user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
        GROUP BY user_email
      ),

      licenses AS (
        SELECT
          LOWER(user_email) AS user_email,
          license_state,
          DATE(create_time) AS licence_assigned_date
        FROM ${ge_user_licenses.SQL_TABLE_NAME}
        WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`)
          AND user_email IS NOT NULL
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY LOWER(user_email)
          ORDER BY license_state = 'ASSIGNED' DESC, last_login_time DESC
        ) = 1
      ),

      workspace AS (
        SELECT user_email, workspace_active_days_28d
        FROM ${user_org_unit.SQL_TABLE_NAME}
      ),

      people AS (
        SELECT user_email FROM ai WHERE ai_days_28d > 0
        UNION DISTINCT
        SELECT user_email FROM licenses WHERE license_state = 'ASSIGNED'
        UNION DISTINCT
        SELECT user_email FROM workspace WHERE workspace_active_days_28d > 0
      ),

      scoped_people AS (
        SELECT people.user_email
        FROM people
        JOIN ${population_scope.SQL_TABLE_NAME} AS population_scope USING (user_email)
        WHERE population_scope.in_scope
      ),

      profile AS (
        SELECT
          scoped_people.user_email,
          IFNULL(workspace.workspace_active_days_28d, 0) > 0 AS is_workspace_user,
          IFNULL(licenses.license_state = 'ASSIGNED', FALSE) AS is_ge_licensed,
          licenses.license_state,
          licenses.licence_assigned_date,
          ai.first_ai_date,
          ai.last_ai_date,
          ai.first_ge_date,
          IF(DATE_DIFF(ai.first_ge_date, licenses.licence_assigned_date, DAY) >= 0,
            DATE_DIFF(ai.first_ge_date, licenses.licence_assigned_date, DAY), NULL) AS days_to_first_ge_use,
          IFNULL(ai.ai_days_28d, 0) AS ai_days_28d,
          IFNULL(ai.ai_days_prev_28d, 0) AS ai_days_prev_28d,
          IFNULL(ai.ge_days_28d, 0) AS ge_days_28d,
          IFNULL(ai.gws_days_28d, 0) AS gws_days_28d,
          IFNULL(ai.antigravity_days_28d, 0) AS antigravity_days_28d,
          IFNULL(ai.ai_actions_28d, 0) AS ai_actions_28d,
          IFNULL(ai.ai_actions_prev_28d, 0) AS ai_actions_prev_28d,
          IFNULL(ai.ge_actions_28d, 0) AS ge_actions_28d,
          IFNULL(ai.gws_actions_28d, 0) AS gws_actions_28d,
          IFNULL(ai.antigravity_actions_28d, 0) AS antigravity_actions_28d,
          peak.peak_local_hour,
          models.top_model,
          IFNULL(models.models_used_28d, 0) AS models_used_28d,
          IFNULL(models.auto_prompts_28d, 0) AS auto_prompts_28d,
          IFNULL(models.auto_advanced_prompts_28d, 0) AS auto_advanced_prompts_28d,
          IFNULL(token_user.total_tokens_28d, 0) AS total_tokens_28d,
          IFNULL(token_user.reasoning_tokens_28d, 0) AS reasoning_tokens_28d,
          IFNULL(token_user.model_calls_28d, 0) AS model_calls_28d
        FROM scoped_people
        LEFT JOIN ai USING (user_email)
        LEFT JOIN peak USING (user_email)
        LEFT JOIN models USING (user_email)
        LEFT JOIN token_user USING (user_email)
        LEFT JOIN licenses USING (user_email)
        LEFT JOIN workspace USING (user_email)
      )

      SELECT
        profile.*,
        NTILE(10) OVER (ORDER BY ai_actions_28d DESC, user_email) AS ai_action_decile
      FROM profile ;;
  }

  dimension: user_email {
    primary_key: yes
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: effective_period {
    label: "Effective Period"
    description: "The canonical adoption metrics use this fixed rolling window, independent of dashboard date filters."
    type: string
    sql: CONCAT('Last 28 days, ends ', CAST(CURRENT_DATE() AS STRING)) ;;
  }

  dimension: cohort {
    label: "AI Cohort"
    description: "Power, Normal, Casual or Non-AI, from AI-active days across all products in the last 28 days."
    type: string
    sql: CASE
      WHEN ${TABLE}.ai_days_28d >= @{power_user_min_days} THEN 'Power'
      WHEN ${TABLE}.ai_days_28d >= @{normal_user_min_days} THEN 'Normal'
      WHEN ${TABLE}.ai_days_28d >= 1 THEN 'Casual'
      ELSE 'Non-AI'
    END ;;
    order_by_field: cohort_order
  }

  dimension: cohort_order {
    hidden: yes
    type: number
    sql: CASE
      WHEN ${TABLE}.ai_days_28d >= @{power_user_min_days} THEN 1
      WHEN ${TABLE}.ai_days_28d >= @{normal_user_min_days} THEN 2
      WHEN ${TABLE}.ai_days_28d >= 1 THEN 3
      ELSE 4
    END ;;
  }

  dimension: product_mix {
    label: "Product Mix (28d)"
    description: "Whether the person used Gemini Enterprise, Gemini for Workspace, both or neither in the last 28 days. Antigravity is tracked separately."
    type: string
    sql: CASE
      WHEN ${TABLE}.ge_days_28d > 0 AND ${TABLE}.gws_days_28d > 0 THEN 'Both'
      WHEN ${TABLE}.ge_days_28d > 0 THEN 'Gemini Enterprise only'
      WHEN ${TABLE}.gws_days_28d > 0 THEN 'Workspace Gemini only'
      ELSE 'Neither'
    END ;;
    order_by_field: product_mix_order
  }

  dimension: product_mix_order {
    hidden: yes
    type: number
    sql: CASE
      WHEN ${TABLE}.ge_days_28d > 0 AND ${TABLE}.gws_days_28d > 0 THEN 1
      WHEN ${TABLE}.ge_days_28d > 0 THEN 2
      WHEN ${TABLE}.gws_days_28d > 0 THEN 3
      ELSE 4
    END ;;
  }

  dimension: is_workspace_user {
    label: "Is Workspace User (28d)"
    description: "Had any Workspace audit event in the last 28 days. Needs workspace_export = same_region."
    type: yesno
    sql: ${TABLE}.is_workspace_user ;;
  }

  dimension: is_ge_licensed {
    label: "Is Gemini Enterprise Licensed"
    type: yesno
    sql: ${TABLE}.is_ge_licensed ;;
  }

  dimension: license_state {
    type: string
    sql: ${TABLE}.license_state ;;
  }

  dimension_group: licence_assigned {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.licence_assigned_date ;;
  }

  dimension_group: first_ai {
    label: "First AI Use"
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.first_ai_date ;;
  }

  dimension_group: last_ai {
    label: "Last AI Use"
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.last_ai_date ;;
  }

  dimension: days_since_last_ai_use {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${TABLE}.last_ai_date, DAY) ;;
  }

  dimension: days_to_first_ge_use {
    label: "Days to First Gemini Enterprise Use"
    description: "Days from licence assignment to the first Gemini Enterprise prompt or search."
    type: number
    sql: ${TABLE}.days_to_first_ge_use ;;
  }

  dimension: ai_days_28d {
    label: "AI Days (28d)"
    type: number
    sql: ${TABLE}.ai_days_28d ;;
  }

  dimension: ai_days_prev_28d {
    label: "AI Days (Previous 28d)"
    description: "Distinct AI-active days in the 28-day period before the current 28-day window."
    type: number
    sql: ${TABLE}.ai_days_prev_28d ;;
  }

  dimension: ge_days_28d {
    label: "Gemini Enterprise Days (28d)"
    type: number
    sql: ${TABLE}.ge_days_28d ;;
  }

  dimension: gws_days_28d {
    label: "Workspace Gemini Days (28d)"
    type: number
    sql: ${TABLE}.gws_days_28d ;;
  }

  dimension: antigravity_days_28d {
    label: "Antigravity Days (28d)"
    type: number
    sql: ${TABLE}.antigravity_days_28d ;;
  }

  dimension: ai_actions_28d {
    label: "AI Actions (28d)"
    type: number
    sql: ${TABLE}.ai_actions_28d ;;
  }

  dimension: ai_actions_prev_28d {
    label: "AI Actions (Previous 28d)"
    type: number
    sql: ${TABLE}.ai_actions_prev_28d ;;
  }

  dimension: ai_action_decile {
    hidden: yes
    label: "AI Action Decile"
    description: "Decile of people by current 28-day AI actions, where 1 is the most active 10%."
    type: number
    sql: ${TABLE}.ai_action_decile ;;
  }

  dimension: ge_actions_28d {
    label: "Gemini Enterprise Actions (28d)"
    type: number
    sql: ${TABLE}.ge_actions_28d ;;
  }

  dimension: gws_actions_28d {
    label: "Workspace Gemini Actions (28d)"
    type: number
    sql: ${TABLE}.gws_actions_28d ;;
  }

  dimension: antigravity_actions_28d {
    label: "Antigravity Requests (28d)"
    type: number
    sql: ${TABLE}.antigravity_actions_28d ;;
  }

  dimension: peak_local_hour {
    description: "Hour of day (reporting time zone) with the most AI actions in the last 28 days."
    type: number
    sql: ${TABLE}.peak_local_hour ;;
  }

  dimension: top_model {
    description: "Model behind most of the user's Gemini Enterprise prompts in the last 28 days."
    type: string
    sql: ${TABLE}.top_model ;;
  }

  dimension: models_used_28d {
    label: "Models Used (28d)"
    type: number
    sql: ${TABLE}.models_used_28d ;;
  }

  dimension: auto_prompts_28d {
    label: "Auto Prompts (28d)"
    type: number
    sql: ${TABLE}.auto_prompts_28d ;;
  }

  dimension: complex_query_rate_28d {
    label: "Complex Query Rate (28d)"
    description: "Share of the user's Auto-mode prompts that Gemini Enterprise routed to an advanced (Pro, Ultra or Thinking) model."
    type: number
    sql: SAFE_DIVIDE(${TABLE}.auto_advanced_prompts_28d, NULLIF(${TABLE}.auto_prompts_28d, 0)) ;;
    value_format_name: percent_0
  }

  dimension: total_tokens_28d {
    label: "Tokens (28d)"
    description: "Input plus output tokens from Gemini Enterprise model calls in the last 28 days."
    type: number
    sql: ${TABLE}.total_tokens_28d ;;
    value_format_name: decimal_0
  }

  dimension: reasoning_tokens_28d {
    label: "Reasoning Tokens (28d)"
    type: number
    sql: ${TABLE}.reasoning_tokens_28d ;;
    value_format_name: decimal_0
  }

  dimension: model_calls_28d {
    label: "Model Calls (28d)"
    type: number
    sql: ${TABLE}.model_calls_28d ;;
    value_format_name: decimal_0
  }

  measure: people {
    description: "People in the current population."
    type: count
    drill_fields: [detail*]
  }

  measure: ai_days_28d_value {
    hidden: yes
    type: max
    sql: ${TABLE}.ai_days_28d ;;
    value_format_name: decimal_0
  }

  measure: ai_actions_28d_value {
    hidden: yes
    type: max
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: median_ai_days {
    label: "Median AI Days"
    description: "Median AI-active days in the last 28 days, among people with at least one."
    type: median
    sql: ${TABLE}.ai_days_28d ;;
    filters: [ai_days_28d: ">0"]
    value_format_name: decimal_0
  }

  measure: median_actions_active {
    label: "Median Actions per Active Person"
    type: median
    sql: ${TABLE}.ai_actions_28d ;;
    filters: [ai_days_28d: ">0"]
    value_format_name: decimal_0
  }

  measure: min_actions_28d {
    hidden: yes
    type: min
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: p25_actions_28d {
    hidden: yes
    type: percentile
    percentile: 25
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: median_actions_28d {
    hidden: yes
    type: median
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: p75_actions_28d {
    hidden: yes
    type: percentile
    percentile: 75
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: max_actions_28d {
    hidden: yes
    type: max
    sql: ${TABLE}.ai_actions_28d ;;
    value_format_name: decimal_0
  }

  measure: models_per_ge_user {
    label: "Models per GE User"
    type: number
    sql: SAFE_DIVIDE(SUM(${TABLE}.models_used_28d), NULLIF(COUNT(DISTINCT IF(${TABLE}.ge_days_28d > 0, ${TABLE}.user_email, NULL)), 0)) ;;
    value_format_name: decimal_1
  }

  measure: median_tokens_per_ge_user {
    label: "Median Tokens per GE User"
    type: median
    sql: ${TABLE}.total_tokens_28d ;;
    filters: [total_tokens_28d: ">0"]
    value_format_name: decimal_0
  }

  measure: workspace_users {
    label: "Workspace Users (28d)"
    description: "People with any Workspace audit event in the last 28 days: the Workspace activation denominator."
    type: count
    filters: [is_workspace_user: "yes"]
  }

  measure: ai_active_users {
    label: "AI Active Users (28d)"
    type: count
    filters: [ai_days_28d: ">0"]
    drill_fields: [detail*]
  }

  measure: previous_ai_active_users {
    hidden: yes
    label: "AI Active Users (Previous 28d)"
    type: count
    filters: [ai_days_prev_28d: ">0"]
  }

  measure: retained_ai_users {
    label: "Retained AI Users"
    description: "People active in both the current 28-day window and the previous 28-day window."
    type: count
    filters: [ai_days_28d: ">0", ai_days_prev_28d: ">0"]
    drill_fields: [detail*]
  }

  measure: gws_active_users {
    label: "Workspace Gemini Active Users (28d)"
    type: count
    filters: [gws_days_28d: ">0"]
    drill_fields: [detail*]
  }

  measure: gws_active_workspace_users {
    hidden: yes
    type: count
    filters: [gws_days_28d: ">0", is_workspace_user: "yes"]
  }

  measure: gws_activation_rate {
    label: "Workspace Gemini Activation (28d)"
    description: "Workspace users with an active Gemini for Workspace event in the last 28 days, divided by Workspace users seen in the audit log in the last 28 days."
    type: number
    sql: SAFE_DIVIDE(${gws_active_workspace_users}, NULLIF(${workspace_users}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ gws_active_workspace_users._rendered_value }} of {{ workspace_users._rendered_value }}) ;;
  }

  measure: ge_licensed_users {
    label: "Gemini Enterprise Licensed Users"
    type: count
    filters: [is_ge_licensed: "yes"]
    drill_fields: [detail*]
  }

  measure: ge_active_licensed_users {
    hidden: yes
    type: count
    filters: [is_ge_licensed: "yes", ge_days_28d: ">0"]
  }

  measure: ge_activation_rate {
    label: "Gemini Enterprise Licence Activation (28d)"
    description: "Licensed users who prompted or searched in Gemini Enterprise in the last 28 days, divided by licensed users."
    type: number
    sql: SAFE_DIVIDE(${ge_active_licensed_users}, NULLIF(${ge_licensed_users}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ ge_active_licensed_users._rendered_value }} of {{ ge_licensed_users._rendered_value }}) ;;
  }

  measure: ge_active_workspace_users {
    hidden: yes
    type: count
    filters: [ge_days_28d: ">0", is_workspace_user: "yes"]
  }

  measure: ge_reach_rate {
    label: "Gemini Enterprise Reach (28d)"
    description: "Workspace users active in Gemini Enterprise in the last 28 days, divided by all Workspace users: how far Gemini Enterprise has spread across the workforce, licensed or not."
    type: number
    sql: SAFE_DIVIDE(${ge_active_workspace_users}, NULLIF(${workspace_users}, 0)) ;;
    value_format_name: percent_1
  }

  measure: ai_activation_rate {
    label: "AI Activation (28d)"
    description: "Eligible people with at least one AI-active day in the last 28 days, divided by eligible people in scope."
    type: number
    sql: SAFE_DIVIDE(${ai_active_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ ai_active_users._rendered_value }} of {{ people._rendered_value }}) ;;
  }

  measure: power_users {
    type: count
    filters: [ai_days_28d: ">=@{power_user_min_days}"]
    drill_fields: [detail*]
  }

  measure: normal_users {
    type: count
    filters: [ai_days_28d: ">=@{normal_user_min_days}", power_users_flag: "no"]
    drill_fields: [detail*]
  }

  measure: casual_users {
    type: count
    filters: [ai_days_28d: ">=1", normal_or_power_flag: "no"]
    drill_fields: [detail*]
  }

  measure: non_ai_users {
    label: "Non-AI Users"
    type: count
    filters: [ai_days_28d: "0"]
    drill_fields: [detail*]
  }

  dimension: power_users_flag {
    hidden: yes
    type: yesno
    sql: ${TABLE}.ai_days_28d >= @{power_user_min_days} ;;
  }

  dimension: normal_or_power_flag {
    hidden: yes
    type: yesno
    sql: ${TABLE}.ai_days_28d >= @{normal_user_min_days} ;;
  }

  measure: adopter_share {
    label: "Regular Adoption (28d)"
    description: "Eligible people using AI on at least normal_user_min_days separate days in the last 28 days, divided by eligible people in scope."
    type: number
    sql: SAFE_DIVIDE(${power_users} + ${normal_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ normal_users._rendered_value }} normal, {{ power_users._rendered_value }} power) ;;
  }

  measure: regular_adoption_rate {
    label: "Regular Adoption (28d)"
    description: "Eligible people using AI on at least normal_user_min_days separate days in the last 28 days, divided by eligible people in scope."
    type: number
    sql: SAFE_DIVIDE(${power_users} + ${normal_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ normal_users._rendered_value }} normal, {{ power_users._rendered_value }} power) ;;
  }

  measure: ai_engagement_days_per_active_user {
    label: "Engagement: AI Days per Active User"
    description: "Distinct AI-active days per AI active user in the last 28 days."
    type: number
    sql: SAFE_DIVIDE(SUM(${TABLE}.ai_days_28d), NULLIF(${ai_active_users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: ai_retention_rate {
    label: "AI Retention"
    description: "Of eligible people active 29 to 56 days ago, the share also active in the last 28 days. Always these two fixed 28-day windows; the Date filter does not change it."
    type: number
    sql: SAFE_DIVIDE(${retained_ai_users}, NULLIF(${previous_ai_active_users}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ retained_ai_users._rendered_value }} of {{ previous_ai_active_users._rendered_value }} returned) ;;
  }

  measure: top_user_action_share {
    label: "Top User Action Share"
    description: "Share of hands-on AI actions in the last 28 days generated by the single most active eligible person."
    type: number
    sql: SAFE_DIVIDE(MAX(${TABLE}.ai_actions_28d), NULLIF(SUM(${TABLE}.ai_actions_28d), 0)) ;;
    value_format_name: percent_0
  }

  measure: top_decile_action_share {
    label: "Top 10% Action Share"
    description: "Share of hands-on AI actions in the last 28 days generated by the most active 10% of eligible people (including people with no actions)."
    type: number
    sql: SAFE_DIVIDE(SUM(IF(${TABLE}.ai_action_decile = 1, ${TABLE}.ai_actions_28d, 0)), NULLIF(SUM(${TABLE}.ai_actions_28d), 0)) ;;
    value_format_name: percent_0
  }

  measure: non_ai_share {
    label: "Non-AI Share"
    description: "Eligible people with no AI-active day in the last 28 days, divided by eligible people in scope."
    type: number
    sql: SAFE_DIVIDE(${non_ai_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_1
  }

  measure: casual_or_non_ai_share {
    label: "Casual or Non-AI Share"
    description: "Eligible people using AI on fewer than normal_user_min_days separate days in the last 28 days (Casual plus Non-AI), divided by eligible people in scope. The change-training target."
    type: number
    sql: SAFE_DIVIDE(${casual_users} + ${non_ai_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_1
  }

  # Dashboard cohort cards: the share renders large, with the head count and
  # threshold underneath. The count must be in the same query (hidden on the
  # tile) for the html to read it.
  measure: idle_ge_licences {
    label: "Idle Gemini Enterprise Licences"
    description: "Licensed users with no Gemini Enterprise prompt or search in the last 28 days."
    type: count
    filters: [is_ge_licensed: "yes", ge_days_28d: "0"]
    drill_fields: [detail*]
  }

  measure: average_days_to_first_ge_use {
    label: "Avg Days to First Gemini Enterprise Use"
    type: average
    sql: ${TABLE}.days_to_first_ge_use ;;
    value_format_name: decimal_1
  }

  measure: monthly_ge_spend {
    label: "Monthly Gemini Enterprise Spend"
    description: "Licensed users times the ge_seat_cost_monthly constant."
    type: number
    sql: ${ge_licensed_users} * @{ge_seat_cost_monthly} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
  }

  measure: monthly_gws_spend {
    label: "Monthly Workspace Gemini Spend"
    description: "Workspace users times the gws_seat_cost_monthly constant."
    type: number
    sql: ${workspace_users} * @{gws_seat_cost_monthly} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
  }

  measure: monthly_ai_spend {
    label: "Monthly AI Spend"
    type: number
    sql: ${monthly_ge_spend} + ${monthly_gws_spend} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{ge_seat_cost_monthly} == 0 and @{gws_seat_cost_monthly} == 0 %}<span style="font-size:14px">Set seat costs in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: cost_per_ai_active_user {
    label: "Monthly Cost per AI Active User"
    type: number
    sql: SAFE_DIVIDE(${monthly_ai_spend}, NULLIF(${ai_active_users}, 0)) ;;
    value_format: "\"@{currency_symbol}\"#,##0.00"
    html: {% if @{ge_seat_cost_monthly} == 0 and @{gws_seat_cost_monthly} == 0 %}<span style="font-size:14px">Set seat costs in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: idle_ge_licence_spend {
    label: "Monthly Licence Spend to Review"
    type: number
    sql: ${idle_ge_licences} * @{ge_seat_cost_monthly} ;;
    value_format: "\"@{currency_symbol}\"#,##0"
    html: {% if @{ge_seat_cost_monthly} == 0 %}<span style="font-size:14px">Set the Gemini Enterprise seat cost in Marketplace &gt; Manage</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  measure: tracking_since {
    label: "Tracking Since"
    description: "Earliest AI activity date among people currently in scope."
    type: min
    sql: ${TABLE}.first_ai_date ;;
  }

  # Executive Overview cards. Each card renders its own label and supporting
  # counts; include the referenced measures in the tile query (as hidden fields).
  measure: regular_users {
    label: "Regular AI Users (28d)"
    description: "Normal plus Power users."
    type: number
    sql: ${normal_users} + ${power_users} ;;
  }

  measure: regular_among_active_rate {
    label: "Regular Among Active Users (28d)"
    description: "Normal or Power users divided by people with at least one AI-active day, both over the last 28 days and among eligible people. How habitual use is among people who use AI at all."
    type: number
    sql: SAFE_DIVIDE(${regular_users}, NULLIF(${ai_active_users}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} ({{ regular_users._rendered_value }} of {{ ai_active_users._rendered_value }}) ;;
  }

  measure: adoption_card {
    hidden: yes
    type: number
    sql: ${ai_activation_rate} ;;
    value_format_name: percent_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.25;white-space:normal;border-left:4px solid #1A73E8;"><div style="font-size:32px;font-weight:600;color:#202124;letter-spacing:-0.5px;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;margin-top:2px;">Adoption</div><div style="font-size:12px;color:#5f6368;margin-top:2px;">{{ ai_active_users._rendered_value }} of {{ people._rendered_value }} eligible people</div></div> ;;
  }

  measure: habit_card {
    hidden: yes
    type: number
    sql: ${regular_among_active_rate} ;;
    value_format_name: percent_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.25;white-space:normal;border-left:4px solid #174EA6;"><div style="font-size:32px;font-weight:600;color:#202124;letter-spacing:-0.5px;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;margin-top:2px;">Regular use</div><div style="font-size:12px;color:#5f6368;margin-top:2px;">{{ regular_users._rendered_value }} of {{ ai_active_users._rendered_value }} active people use AI weekly or more</div></div> ;;
  }

  measure: retention_card {
    hidden: yes
    type: number
    sql: ${ai_retention_rate} ;;
    value_format_name: percent_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.25;white-space:normal;border-left:4px solid #1A73E8;"><div style="font-size:32px;font-weight:600;color:#202124;letter-spacing:-0.5px;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;margin-top:2px;">Retention</div><div style="font-size:12px;color:#5f6368;margin-top:2px;">{{ retained_ai_users._rendered_value }} of {{ previous_ai_active_users._rendered_value }} came back from the previous 28 days</div></div> ;;
  }

  measure: not_yet_active_card {
    hidden: yes
    type: number
    sql: ${non_ai_users} ;;
    value_format_name: decimal_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.25;white-space:normal;border-left:4px solid #9AA0A6;"><div style="font-size:32px;font-weight:600;color:#202124;letter-spacing:-0.5px;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;margin-top:2px;">Not yet active</div><div style="font-size:12px;color:#5f6368;margin-top:2px;">of {{ people._rendered_value }} eligible people, no AI use yet</div></div> ;;
  }

  measure: licence_decision_card {
    hidden: yes
    type: number
    sql: ${idle_ge_licences} ;;
    value_format_name: decimal_0
    label: "Licence Decision"
    description: "Include idle_ge_licence_spend in the tile query."
    html: {% if value == 0 %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;background:#E6F4EA;border-radius:12px;padding:18px 20px;white-space:normal;line-height:1.3;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#188038;">Licences</div><div style="font-size:34px;font-weight:600;color:#202124;margin:6px 0 4px;letter-spacing:-0.5px;">None idle</div><div style="font-size:14px;font-weight:600;color:#202124;">No unused Gemini Enterprise licences</div><div style="font-size:12px;color:#5f6368;margin-top:6px;">Every assigned licence was used in the last 28 days.</div></div>{% elsif @{ge_seat_cost_monthly} == 0 %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;background:#FEF7E0;border-radius:12px;padding:18px 20px;white-space:normal;line-height:1.3;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#B06000;">Decision to make</div><div style="font-size:34px;font-weight:600;color:#202124;margin:6px 0 4px;letter-spacing:-0.5px;">{{ rendered_value }} licences</div><div style="font-size:14px;font-weight:600;color:#202124;">Review unused Gemini Enterprise licences</div><div style="font-size:12px;color:#5f6368;margin-top:6px;">No use in 28 days. Set the seat cost to see spend. <a href="/dashboards/gemini_enterprise::gemini_ai_change" style="color:#1a73e8;text-decoration:none;">See the licence list</a></div></div>{% else %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;background:#FEF7E0;border-radius:12px;padding:18px 20px;white-space:normal;line-height:1.3;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#B06000;">Decision to make</div><div style="font-size:34px;font-weight:600;color:#202124;margin:6px 0 4px;letter-spacing:-0.5px;">{{ idle_ge_licence_spend._rendered_value }}<span style="font-size:18px;font-weight:500;color:#5f6368;">/mo</span></div><div style="font-size:14px;font-weight:600;color:#202124;">Review {{ rendered_value }} unused Gemini Enterprise licences</div><div style="font-size:12px;color:#5f6368;margin-top:6px;">No use in the last 28 days. <a href="/dashboards/gemini_enterprise::gemini_ai_change" style="color:#1a73e8;text-decoration:none;">See the licence list</a></div></div>{% endif %} ;;
  }

  measure: story_card {
    hidden: yes
    type: number
    sql: ${ai_activation_rate} ;;
    value_format_name: percent_0
    description: "Executive headline. Include ai_activation_rate, regular_among_active_rate, ai_active_users, people, non_ai_users and ai_retention_rate in the tile query."
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;background:#E8F0FE;border-radius:12px;padding:18px 22px;white-space:normal;line-height:1.3;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#174EA6;">The main story: last 28 days</div><div style="font-size:24px;font-weight:600;color:#202124;margin:8px 0 10px;">{% assign act = ai_activation_rate._value | times: 1.0 %}{% assign hab = regular_among_active_rate._value | times: 1.0 %}{% if act < 0.5 and hab >= 0.7 %}AI use is habitual among adopters. The opportunity is reaching {{ non_ai_users._rendered_value }} non-users.{% elsif act >= 0.5 and hab >= 0.7 %}AI use is broad and habitual. The opportunity is deeper use and measured value.{% elsif act >= 0.5 %}Many people have tried AI, but few use it regularly. The opportunity is building habits.{% else %}AI adoption is early. {{ non_ai_users._rendered_value }} eligible people have not started yet.{% endif %}</div><div style="font-size:14px;color:#3c4043;">{{ ai_active_users._rendered_value }} of {{ people._rendered_value }} eligible people are active. {{ regular_among_active_rate._rendered_value }} of them use it regularly, and {{ ai_retention_rate._rendered_value }} came back from the previous 28 days.</div></div> ;;
  }

  measure: concentration_card {
    hidden: yes
    type: number
    sql: ${top_decile_action_share} ;;
    value_format_name: percent_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.25;white-space:normal;border-left:4px solid #8AB4F8;"><div style="font-size:32px;font-weight:600;color:#202124;letter-spacing:-0.5px;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;margin-top:2px;">Top 10% share</div><div style="font-size:12px;color:#5f6368;margin-top:2px;">of hands-on actions come from the most active 10% of people</div></div> ;;
  }

  measure: activation_summary {
    label: "Active of Eligible"
    description: "For example: 2 of 21 active (10%)."
    type: string
    sql: CONCAT(CAST(${ai_active_users} AS STRING), ' of ', CAST(${people} AS STRING), ' active (',
      CAST(CAST(ROUND(100 * SAFE_DIVIDE(${ai_active_users}, NULLIF(${people}, 0))) AS INT64) AS STRING), '%)') ;;
  }

  # What other explores show about a person when they join this view: the
  # attributes, not this view's population counts.
  set: person {
    fields: [cohort, cohort_order, product_mix, product_mix_order, is_ge_licensed, is_workspace_user,
      license_state, ai_days_28d, top_model, peak_local_hour, complex_query_rate_28d, first_ai_date, last_ai_date]
  }

  set: detail {
    fields: [user_email, user_org_unit.department, cohort, product_mix, ai_days_28d, ge_actions_28d, gws_actions_28d, antigravity_actions_28d, last_ai_date]
  }
}
