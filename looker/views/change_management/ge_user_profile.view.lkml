view: ge_user_profile {
  label: "User Profile"
  # One row per person: everyone with a Gemini Enterprise licence in the
  # latest snapshot, plus anyone seen in the activity or Antigravity logs.
  # The segment is based on engaged days (days with a prompt or search) in the
  # last 28 days:
  #   Power       power_user_min_days+ engaged days (default 12, about three days a week)
  #   Normal      normal_user_min_days+ (default 4, about weekly)
  #   Casual      at least one
  #   Dormant     no engaged days in 28 days, but used it before or has logged in
  #   Never used  licensed, never seen in the logs and never logged in
  # Activity history starts when the log pipeline was enabled; licence last
  # login fills the gap for earlier users.
  derived_table: {
    datagroup_trigger: gemini_change_management_datagroup
    sql:
      WITH latest_licenses AS (
        SELECT user_email, license_state, license_config, last_login_time, create_time
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`
        WHERE snapshot_date = (
          SELECT MAX(snapshot_date) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`
        )
          AND user_email IS NOT NULL
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY user_email
          ORDER BY license_state = 'ASSIGNED' DESC, last_login_time DESC
        ) = 1
      ),

      activity AS (
        SELECT
          user_email,
          MIN(event_date) AS first_active_date,
          MAX(event_date) AS last_active_date,
          MIN(IF(is_user_prompt, event_date, NULL)) AS first_prompt_date,
          COUNT(DISTINCT IF(is_user_prompt OR is_user_search, event_date, NULL)) AS engaged_days_total,
          COUNT(DISTINCT IF((is_user_prompt OR is_user_search) AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), event_date, NULL)) AS engaged_days_28d,
          COUNTIF(is_user_prompt AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)) AS prompts_28d,
          COUNTIF(is_user_search AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)) AS searches_28d,
          COUNT(DISTINCT IF(feature NOT IN ('Assistant grounding', 'Navigation', 'Other') AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), feature, NULL)) AS features_used_28d,
          COUNT(DISTINCT IF(agent_id IS NOT NULL AND NOT IFNULL(is_core_assistant, FALSE) AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), agent_id, NULL)) AS agents_used_28d,
          COUNTIF(feature = 'Agent builder') AS agent_builder_actions,
          COUNTIF(is_blocked) AS blocked_prompts,
          APPROX_TOP_COUNT(IF(is_user_prompt, app_name, NULL), 2)[SAFE_OFFSET(0)].value AS top_app_candidate,
          APPROX_TOP_COUNT(IF(is_user_prompt, app_name, NULL), 2)[SAFE_OFFSET(1)].value AS second_app_candidate
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
        WHERE user_email IS NOT NULL
        GROUP BY user_email
      ),

      skills AS (
        SELECT user_email, COUNT(DISTINCT skill_name) AS skills_used_28d
        FROM `@{gemini_project}.@{gemini_dataset}.ge_tool_calls`
        WHERE skill_name IS NOT NULL
          AND user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
        GROUP BY user_email
      ),

      antigravity AS (
        SELECT
          user_email,
          COUNTIF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)) AS antigravity_requests_28d,
          MAX(event_date) AS last_antigravity_date
        FROM `@{gemini_project}.@{gemini_dataset}.antigravity_usage`
        WHERE user_email IS NOT NULL
        GROUP BY user_email
      ),

      people AS (
        SELECT user_email FROM latest_licenses
        UNION DISTINCT
        SELECT user_email FROM activity
        UNION DISTINCT
        SELECT user_email FROM antigravity
      )

      SELECT
        people.user_email,
        latest_licenses.license_state,
        latest_licenses.license_config,
        latest_licenses.license_state = 'ASSIGNED' AS is_licensed,
        latest_licenses.last_login_time,
        activity.first_active_date,
        activity.last_active_date,
        activity.first_prompt_date,
        IFNULL(activity.engaged_days_total, 0) AS engaged_days_total,
        IFNULL(activity.engaged_days_28d, 0) AS engaged_days_28d,
        IFNULL(activity.prompts_28d, 0) AS prompts_28d,
        IFNULL(activity.searches_28d, 0) AS searches_28d,
        IFNULL(activity.features_used_28d, 0) AS features_used_28d,
        IFNULL(activity.agents_used_28d, 0) AS agents_used_28d,
        IFNULL(skills.skills_used_28d, 0) AS skills_used_28d,
        IFNULL(activity.agent_builder_actions, 0) AS agent_builder_actions,
        IFNULL(activity.blocked_prompts, 0) AS blocked_prompts,
        COALESCE(activity.top_app_candidate, activity.second_app_candidate) AS primary_app,
        IFNULL(antigravity.antigravity_requests_28d, 0) AS antigravity_requests_28d,
        antigravity.last_antigravity_date,
        CASE
          WHEN IFNULL(activity.engaged_days_28d, 0) >= @{power_user_min_days} THEN 'Power'
          WHEN IFNULL(activity.engaged_days_28d, 0) >= @{normal_user_min_days} THEN 'Normal'
          WHEN IFNULL(activity.engaged_days_28d, 0) >= 1 THEN 'Casual'
          WHEN activity.last_active_date IS NOT NULL
            OR latest_licenses.last_login_time IS NOT NULL THEN 'Dormant'
          ELSE 'Never used'
        END AS segment
      FROM people
      LEFT JOIN latest_licenses USING (user_email)
      LEFT JOIN activity USING (user_email)
      LEFT JOIN skills USING (user_email)
      LEFT JOIN antigravity USING (user_email) ;;
  }

  dimension: user_email {
    primary_key: yes
    label: "User"
    type: string
    sql: ${TABLE}.user_email ;;
  }

  dimension: user_domain {
    label: "User Domain"
    type: string
    sql: REGEXP_EXTRACT(${TABLE}.user_email, r'@(.+)$') ;;
  }

  dimension: segment {
    label: "Adoption Segment"
    description: "Gemini Enterprise only. Power (12+ engaged days in the last 28 by default), Normal (4+), Casual (1+), Dormant (none in 28 days but used before or has logged in), Never used. For a cross-product cohort use AI User Profile > AI Cohort."
    type: string
    sql: ${TABLE}.segment ;;
    order_by_field: segment_order
  }

  dimension: segment_order {
    hidden: yes
    type: number
    sql: CASE ${TABLE}.segment
      WHEN 'Power' THEN 1 WHEN 'Normal' THEN 2 WHEN 'Casual' THEN 3
      WHEN 'Dormant' THEN 4 ELSE 5 END ;;
  }

  dimension: license_state {
    description: "ASSIGNED, NO_LICENSE, NO_LICENSE_ATTEMPTED_LOGIN or BLOCKED in the latest licence snapshot. Null for people seen only in the logs."
    type: string
    sql: ${TABLE}.license_state ;;
  }

  dimension: license_config {
    label: "Licence Type"
    type: string
    sql: ${TABLE}.license_config ;;
  }

  dimension: is_licensed {
    type: yesno
    sql: IFNULL(${TABLE}.is_licensed, FALSE) ;;
  }

  dimension: primary_app {
    description: "App the user prompts in most."
    type: string
    sql: ${TABLE}.primary_app ;;
  }

  dimension_group: last_login {
    description: "Last Gemini Enterprise sign-in, from the licence API."
    type: time
    timeframes: [raw, date, week, month]
    sql: ${TABLE}.last_login_time ;;
  }

  dimension_group: first_active {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.first_active_date ;;
  }

  dimension_group: last_active {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.last_active_date ;;
  }

  dimension: days_since_last_active {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${TABLE}.last_active_date, DAY) ;;
  }

  dimension: engaged_days_28d {
    label: "Engaged Days (28d)"
    type: number
    sql: ${TABLE}.engaged_days_28d ;;
  }

  dimension: prompts_28d {
    label: "Prompts (28d)"
    type: number
    sql: ${TABLE}.prompts_28d ;;
  }

  dimension: searches_28d {
    label: "Searches (28d)"
    type: number
    sql: ${TABLE}.searches_28d ;;
  }

  dimension: features_used_28d {
    label: "Features Used (28d)"
    description: "Distinct user-facing features used in the last 28 days. A breadth-of-adoption signal."
    type: number
    sql: ${TABLE}.features_used_28d ;;
  }

  dimension: agents_used_28d {
    label: "Agents Used (28d)"
    type: number
    sql: ${TABLE}.agents_used_28d ;;
  }

  dimension: skills_used_28d {
    label: "Skills Used (28d)"
    type: number
    sql: ${TABLE}.skills_used_28d ;;
  }

  dimension: is_agent_builder {
    description: "Has created, edited, shared or deleted an agent."
    type: yesno
    sql: ${TABLE}.agent_builder_actions > 0 ;;
  }

  dimension: antigravity_requests_28d {
    label: "Antigravity Requests (28d)"
    type: number
    sql: ${TABLE}.antigravity_requests_28d ;;
  }

  dimension: is_antigravity_user {
    type: yesno
    sql: ${TABLE}.last_antigravity_date IS NOT NULL ;;
  }

  dimension: blocked_prompts {
    hidden: yes
    type: number
    sql: ${TABLE}.blocked_prompts ;;
  }

  measure: people {
    description: "Licensed or active people."
    type: count
    drill_fields: [detail*]
  }

  measure: licensed_users {
    type: count
    filters: [is_licensed: "yes"]
    drill_fields: [detail*]
  }

  measure: engaged_users_28d {
    label: "Engaged Users (28d)"
    description: "People with at least one engaged day in the last 28 days."
    type: count
    filters: [engaged_days_28d: ">0"]
    drill_fields: [detail*]
  }

  measure: engaged_licensed_users_28d {
    label: "Engaged Licensed Users (28d)"
    type: count
    filters: [engaged_days_28d: ">0", is_licensed: "yes"]
  }

  measure: licence_activation_rate {
    label: "Licence Activation Rate (28d)"
    description: "Licensed users who prompted or searched in the last 28 days, divided by licensed users."
    type: number
    sql: SAFE_DIVIDE(${engaged_licensed_users_28d}, NULLIF(${licensed_users}, 0)) ;;
    value_format_name: percent_1
  }

  measure: power_users {
    type: count
    filters: [segment: "Power"]
    drill_fields: [detail*]
  }

  measure: dormant_or_unused_licensed_users {
    label: "Dormant or Unused Licences"
    description: "Licensed users in the Dormant or Never used segments: candidates for nudges or reclaiming the licence."
    type: count
    filters: [segment: "Dormant,Never used", is_licensed: "yes"]
    drill_fields: [detail*]
  }

  measure: average_features_used_28d {
    label: "Avg Features Used (28d)"
    type: average
    sql: ${TABLE}.features_used_28d ;;
    filters: [engaged_days_28d: ">0"]
    value_format_name: decimal_1
  }

  measure: average_prompts_28d {
    label: "Avg Prompts per Engaged User (28d)"
    type: average
    sql: ${TABLE}.prompts_28d ;;
    filters: [engaged_days_28d: ">0"]
    value_format_name: decimal_1
  }

  set: detail {
    fields: [user_email, segment, license_state, engaged_days_28d, prompts_28d, features_used_28d, agents_used_28d, skills_used_28d, last_active_date, last_login_date]
  }
}
