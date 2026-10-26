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
          COUNTIF(REGEXP_CONTAINS(UPPER(IFNULL(model_selection_mode, '')), r'AUTO')) AS auto_prompts_28d,
          COUNTIF(
            REGEXP_CONTAINS(UPPER(IFNULL(model_selection_mode, '')), r'AUTO')
            AND REGEXP_CONTAINS(LOWER(model), r'pro|ultra|thinking')
            AND NOT REGEXP_CONTAINS(LOWER(model), r'image|imagen|veo')
          ) AS auto_advanced_prompts_28d
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
        WHERE is_user_prompt
          AND model IS NOT NULL
          AND user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
        GROUP BY user_email
      ),

      licenses AS (
        SELECT
          LOWER(user_email) AS user_email,
          license_state,
          DATE(create_time) AS licence_assigned_date
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`
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
          IFNULL(models.auto_prompts_28d, 0) AS auto_prompts_28d,
          IFNULL(models.auto_advanced_prompts_28d, 0) AS auto_advanced_prompts_28d
        FROM scoped_people
        LEFT JOIN ai USING (user_email)
        LEFT JOIN peak USING (user_email)
        LEFT JOIN models USING (user_email)
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

  measure: people {
    description: "People in the current population."
    type: count
    drill_fields: [detail*]
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
    html: {{ rendered_value }} &middot; {{ gws_active_workspace_users._rendered_value }} of {{ workspace_users._rendered_value }} ;;
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
    html: {{ rendered_value }} &middot; {{ ge_active_licensed_users._rendered_value }} of {{ ge_licensed_users._rendered_value }} ;;
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
    html: {{ rendered_value }} &middot; {{ ai_active_users._rendered_value }} of {{ people._rendered_value }} ;;
  }

  measure: executive_narrative_card {
    hidden: yes
    label: "Executive Narrative"
    description: "Narrative summary for the executive dashboard. Include the supporting count measures in the same tile query."
    type: number
    sql: ${ai_activation_rate} ;;
    value_format_name: percent_0
    html:
      <div style="font-family:'Google Sans',Arial,sans-serif;text-align:left;line-height:1.45;">
        <div style="font-size:12px;font-weight:600;letter-spacing:1px;text-transform:uppercase;color:#5f6368;">Last 28 days</div>
        <div style="font-size:24px;font-weight:600;color:#202124;margin:4px 0 10px;">AI adoption is {{ rendered_value }}.</div>
        <div style="font-size:14px;color:#3c4043;">{{ ai_active_users._rendered_value }} of {{ people._rendered_value }} eligible people used AI. {{ normal_users._rendered_value }} normal and {{ power_users._rendered_value }} power users show habitual use.</div>
        <div style="font-size:14px;color:#3c4043;margin-top:6px;">{{ idle_ge_licences._rendered_value }} Gemini Enterprise licences had no Enterprise activity, and the top user generated {{ top_user_action_share._rendered_value }} of AI actions.</div>
      </div> ;;
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
    html: {{ rendered_value }} &middot; {{ normal_users._rendered_value }} normal + {{ power_users._rendered_value }} power ;;
  }

  measure: regular_adoption_rate {
    label: "Regular Adoption (28d)"
    description: "Eligible people using AI on at least normal_user_min_days separate days in the last 28 days, divided by eligible people in scope."
    type: number
    sql: SAFE_DIVIDE(${power_users} + ${normal_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} &middot; {{ normal_users._rendered_value }} normal + {{ power_users._rendered_value }} power ;;
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
    description: "People active in the previous 28-day window who also returned in the current 28-day window."
    type: number
    sql: SAFE_DIVIDE(${retained_ai_users}, NULLIF(${previous_ai_active_users}, 0)) ;;
    value_format_name: percent_0
    html: {{ rendered_value }} &middot; {{ retained_ai_users._rendered_value }} of {{ previous_ai_active_users._rendered_value }} returned ;;
  }

  measure: top_user_action_share {
    label: "Top User Action Share"
    description: "Share of current 28-day AI actions generated by the single most active user."
    type: number
    sql: SAFE_DIVIDE(MAX(${TABLE}.ai_actions_28d), NULLIF(SUM(${TABLE}.ai_actions_28d), 0)) ;;
    value_format_name: percent_0
  }

  measure: top_decile_action_share {
    label: "Top 10% Action Share"
    description: "Share of current 28-day AI actions generated by the most active decile of people."
    type: number
    sql: SAFE_DIVIDE(SUM(IF(${TABLE}.ai_action_decile = 1, ${TABLE}.ai_actions_28d, 0)), NULLIF(SUM(${TABLE}.ai_actions_28d), 0)) ;;
    value_format_name: percent_0
  }

  measure: non_ai_share {
    label: "Non-AI Share"
    type: number
    sql: SAFE_DIVIDE(${non_ai_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_1
  }

  measure: casual_or_non_ai_share {
    label: "Casual or Non-AI Share"
    description: "Share of the population using AI less than about weekly: the change-training target."
    type: number
    sql: SAFE_DIVIDE(${casual_users} + ${non_ai_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_1
  }

  # Dashboard cohort cards: the share renders large, with the head count and
  # threshold underneath. The count must be in the same query (hidden on the
  # tile) for the html to read it.
  measure: power_users_card {
    hidden: yes
    label: "Power Users Card"
    type: number
    sql: SAFE_DIVIDE(${power_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html:
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; text-align: left; padding: 10px 18px; border-left: 6px solid #174EA6;">
        <div style="font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; color: #5f6368;">Power users</div>
        <div style="font-size: 34px; font-weight: 600; color: #202124; line-height: 1.25;">{{ rendered_value }}</div>
        <div style="font-size: 13px; color: #5f6368;">{{ power_users._rendered_value }} people &middot; @{power_user_min_days}+ AI days in the last 28</div>
      </div> ;;
  }

  measure: normal_users_card {
    hidden: yes
    label: "Normal Users Card"
    type: number
    sql: SAFE_DIVIDE(${normal_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html:
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; text-align: left; padding: 10px 18px; border-left: 6px solid #1A73E8;">
        <div style="font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; color: #5f6368;">Normal users</div>
        <div style="font-size: 34px; font-weight: 600; color: #202124; line-height: 1.25;">{{ rendered_value }}</div>
        <div style="font-size: 13px; color: #5f6368;">{{ normal_users._rendered_value }} people &middot; @{normal_user_min_days}+ AI days in the last 28</div>
      </div> ;;
  }

  measure: casual_users_card {
    hidden: yes
    label: "Casual Users Card"
    type: number
    sql: SAFE_DIVIDE(${casual_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html:
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; text-align: left; padding: 10px 18px; border-left: 6px solid #8AB4F8;">
        <div style="font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; color: #5f6368;">Casual users</div>
        <div style="font-size: 34px; font-weight: 600; color: #202124; line-height: 1.25;">{{ rendered_value }}</div>
        <div style="font-size: 13px; color: #5f6368;">{{ casual_users._rendered_value }} people &middot; tried AI, under @{normal_user_min_days} days</div>
      </div> ;;
  }

  measure: non_ai_users_card {
    hidden: yes
    label: "Non-AI Users Card"
    type: number
    sql: SAFE_DIVIDE(${non_ai_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
    html:
      <div style="font-family: 'Google Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; text-align: left; padding: 10px 18px; border-left: 6px solid #BDC1C6;">
        <div style="font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; color: #5f6368;">Non-AI users</div>
        <div style="font-size: 34px; font-weight: 600; color: #202124; line-height: 1.25;">{{ rendered_value }}</div>
        <div style="font-size: 13px; color: #5f6368;">{{ non_ai_users._rendered_value }} people &middot; licensed or in Workspace, no AI use</div>
      </div> ;;
  }

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
