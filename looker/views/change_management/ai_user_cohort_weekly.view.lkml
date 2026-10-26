view: ai_user_cohort_weekly {
  label: "AI Cohorts"
  # One row per person per completed week (Monday to Sunday) over the last
  # 52 weeks, with the cohort they were in at the end of that week, based on
  # AI-active days across all products in the trailing 28 days:
  #   Power   power_user_min_days or more (default 12, about three days a week)
  #   Normal  normal_user_min_days or more (default 4, about weekly)
  #   Casual  at least one day
  #   Non-AI  none
  # The population each week is everyone with an AI action, a Workspace audit
  # event (when workspace_export is same_region) or an assigned Gemini
  # Enterprise licence in the window. Weeks before activity history starts
  # undercount, because their 28-day window reaches back before the data.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    partition_keys: ["week_end"]
    cluster_keys: ["user_email"]
    sql:
      WITH daily AS (
        SELECT event_date, user_email, product
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE ai_actions > 0
        GROUP BY 1, 2, 3
      ),

      weeks AS (
        SELECT week_end
        FROM (SELECT MIN(event_date) AS first_date FROM daily) AS bounds,
          UNNEST(GENERATE_DATE_ARRAY(
            DATE_ADD(DATE_TRUNC(GREATEST(bounds.first_date, DATE_SUB(CURRENT_DATE(), INTERVAL 52 WEEK)), WEEK(MONDAY)), INTERVAL 6 DAY),
            DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
            INTERVAL 1 WEEK
          )) AS week_end
      ),

      ai_week AS (
        SELECT
          weeks.week_end,
          daily.user_email,
          COUNT(DISTINCT daily.event_date) AS ai_days,
          COUNT(DISTINCT IF(daily.product = 'Gemini Enterprise', daily.event_date, NULL)) AS ge_days,
          COUNT(DISTINCT IF(daily.product = 'Gemini for Workspace', daily.event_date, NULL)) AS gws_days,
          COUNT(DISTINCT IF(daily.product = 'Antigravity', daily.event_date, NULL)) AS antigravity_days
        FROM weeks
        JOIN daily
          ON daily.event_date BETWEEN DATE_SUB(weeks.week_end, INTERVAL 27 DAY) AND weeks.week_end
        GROUP BY 1, 2
      ),

      workspace_week AS (
        SELECT DISTINCT weeks.week_end, workspace.user_email
        FROM weeks
        JOIN ${workspace_user_daily.SQL_TABLE_NAME} AS workspace
          ON workspace.event_date BETWEEN DATE_SUB(weeks.week_end, INTERVAL 27 DAY) AND weeks.week_end
      ),

      licensed_week AS (
        SELECT DISTINCT weeks.week_end, LOWER(licenses.user_email) AS user_email
        FROM weeks
        JOIN ${ge_user_licenses.SQL_TABLE_NAME} AS licenses
          ON licenses.snapshot_date BETWEEN DATE_SUB(weeks.week_end, INTERVAL 6 DAY) AND weeks.week_end
        WHERE licenses.license_state = 'ASSIGNED'
          AND licenses.user_email IS NOT NULL
      ),

      population AS (
        SELECT week_end, user_email FROM ai_week
        UNION DISTINCT
        SELECT week_end, user_email FROM workspace_week
        UNION DISTINCT
        SELECT week_end, user_email FROM licensed_week
      ),

      scoped_population AS (
        SELECT population.week_end, population.user_email
        FROM population
        JOIN ${population_scope.SQL_TABLE_NAME} AS population_scope
          ON population_scope.user_email = population.user_email
        WHERE population_scope.in_scope
      ),

      cohorts AS (
        SELECT
          scoped_population.week_end,
          scoped_population.user_email,
          IFNULL(ai_week.ai_days, 0) AS ai_days,
          IFNULL(ai_week.ge_days, 0) AS ge_days,
          IFNULL(ai_week.gws_days, 0) AS gws_days,
          IFNULL(ai_week.antigravity_days, 0) AS antigravity_days,
          workspace_week.user_email IS NOT NULL AS is_workspace_user,
          licensed_week.user_email IS NOT NULL AS is_ge_licensed
        FROM scoped_population
        LEFT JOIN ai_week USING (week_end, user_email)
        LEFT JOIN workspace_week USING (week_end, user_email)
        LEFT JOIN licensed_week USING (week_end, user_email)
      ),

      labelled AS (
        SELECT
          *,
          CASE
            WHEN ai_days >= @{power_user_min_days} THEN 'Power'
            WHEN ai_days >= @{normal_user_min_days} THEN 'Normal'
            WHEN ai_days >= 1 THEN 'Casual'
            ELSE 'Non-AI'
          END AS cohort,
          CASE
            WHEN ge_days >= @{power_user_min_days} THEN 'Power'
            WHEN ge_days >= @{normal_user_min_days} THEN 'Normal'
            WHEN ge_days >= 1 THEN 'Casual'
            ELSE 'Non-AI'
          END AS ge_cohort,
          CASE
            WHEN gws_days >= @{power_user_min_days} THEN 'Power'
            WHEN gws_days >= @{normal_user_min_days} THEN 'Normal'
            WHEN gws_days >= 1 THEN 'Casual'
            ELSE 'Non-AI'
          END AS gws_cohort,
          LAG(week_end) OVER (PARTITION BY user_email ORDER BY week_end) AS previous_week_end,
          LAG(ai_days) OVER (PARTITION BY user_email ORDER BY week_end) AS previous_ai_days
        FROM cohorts
      )

      SELECT
        CONCAT(user_email, '|', CAST(week_end AS STRING)) AS pk,
        labelled.* EXCEPT (previous_week_end, previous_ai_days),
        week_end = MAX(week_end) OVER () AS is_latest_week,
        IF(DATE_DIFF(week_end, previous_week_end, DAY) = 7,
          CASE
            WHEN previous_ai_days >= @{power_user_min_days} THEN 'Power'
            WHEN previous_ai_days >= @{normal_user_min_days} THEN 'Normal'
            WHEN previous_ai_days >= 1 THEN 'Casual'
            ELSE 'Non-AI'
          END,
          NULL) AS previous_cohort
      FROM labelled ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension_group: week_end {
    label: "Week Ending"
    description: "Sunday the week ends on. The cohort is based on the 28 days up to and including that day."
    type: time
    timeframes: [date, week, month, quarter]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.week_end ;;
  }

  dimension: is_latest_week {
    description: "The most recent completed week. Filter on this for a current snapshot."
    type: yesno
    sql: ${TABLE}.is_latest_week ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: cohort {
    label: "AI Cohort"
    description: "Power, Normal, Casual or Non-AI, from AI-active days across all products in the trailing 28 days."
    type: string
    sql: ${TABLE}.cohort ;;
    order_by_field: cohort_order
  }

  dimension: cohort_order {
    hidden: yes
    type: number
    sql: CASE ${TABLE}.cohort WHEN 'Power' THEN 1 WHEN 'Normal' THEN 2 WHEN 'Casual' THEN 3 ELSE 4 END ;;
  }

  dimension: ge_cohort {
    label: "Gemini Enterprise Cohort"
    type: string
    sql: ${TABLE}.ge_cohort ;;
  }

  dimension: gws_cohort {
    label: "Workspace Gemini Cohort"
    type: string
    sql: ${TABLE}.gws_cohort ;;
  }

  dimension: previous_cohort {
    description: "Cohort the week before. Null for someone new to the population."
    type: string
    sql: ${TABLE}.previous_cohort ;;
  }

  dimension: cohort_movement {
    description: "Compared with the week before. Newly active: Non-AI or new to the population, now Casual or above. Moved up or Moved down: changed cohort while already active (Moved down includes lapsing to Non-AI). No change. New, not active: joined the population without using AI."
    type: string
    sql: CASE
      WHEN ${TABLE}.cohort != 'Non-AI' AND IFNULL(${TABLE}.previous_cohort, 'Non-AI') = 'Non-AI' THEN 'Newly active'
      WHEN ${TABLE}.previous_cohort IS NULL THEN 'New, not active'
      WHEN ${cohort_order} < CASE ${TABLE}.previous_cohort WHEN 'Power' THEN 1 WHEN 'Normal' THEN 2 WHEN 'Casual' THEN 3 ELSE 4 END THEN 'Moved up'
      WHEN ${cohort_order} > CASE ${TABLE}.previous_cohort WHEN 'Power' THEN 1 WHEN 'Normal' THEN 2 WHEN 'Casual' THEN 3 ELSE 4 END THEN 'Moved down'
      ELSE 'No change'
    END ;;
  }

  dimension: ai_days {
    label: "AI Days (28d)"
    type: number
    sql: ${TABLE}.ai_days ;;
  }

  dimension: is_workspace_user {
    type: yesno
    sql: ${TABLE}.is_workspace_user ;;
  }

  dimension: is_ge_licensed {
    label: "Is Gemini Enterprise Licensed"
    type: yesno
    sql: ${TABLE}.is_ge_licensed ;;
  }

  measure: people {
    description: "People in the population. Group by week or filter Is Latest Week, otherwise each person counts once per week."
    type: count
    drill_fields: [detail*]
  }

  measure: power_users {
    type: count
    filters: [cohort: "Power"]
    drill_fields: [detail*]
  }

  measure: normal_users {
    type: count
    filters: [cohort: "Normal"]
    drill_fields: [detail*]
  }

  measure: casual_users {
    type: count
    filters: [cohort: "Casual"]
    drill_fields: [detail*]
  }

  measure: non_ai_users {
    label: "Non-AI Users"
    type: count
    filters: [cohort: "Non-AI"]
    drill_fields: [detail*]
  }

  measure: adopter_share {
    label: "Power + Normal Share"
    description: "Share of the population using AI at least about weekly."
    type: number
    sql: SAFE_DIVIDE(${power_users} + ${normal_users}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_1
  }

  measure: moved_up {
    description: "Already-active people who moved to a higher cohort than the week before."
    type: count
    filters: [cohort_movement: "Moved up"]
    drill_fields: [detail*]
  }

  measure: moved_down {
    type: count
    filters: [cohort_movement: "Moved down"]
    drill_fields: [detail*]
  }

  measure: moved_down_negative {
    label: "Moved down"
    description: "Moved down as a negative value, for diverging movement charts."
    type: number
    sql: -1 * ${moved_down} ;;
    value_format_name: decimal_0
  }

  measure: newly_active {
    description: "People who were Non-AI or new the week before and are now Casual or above."
    type: count
    filters: [cohort_movement: "Newly active"]
    drill_fields: [detail*]
  }

  measure: unchanged {
    label: "No Change"
    type: count
    filters: [cohort_movement: "No change"]
  }

  measure: average_ai_days {
    label: "Avg AI Days (28d)"
    type: average
    sql: ${TABLE}.ai_days ;;
    value_format_name: decimal_1
  }

  set: detail {
    fields: [week_end_date, user_email, user_org_unit.department, cohort, previous_cohort, ai_days]
  }
}
