view: ai_opportunities {
  label: "AI Opportunities"
  # Rule-based queue that turns adoption signals into change-management actions.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH people AS (
        SELECT
          profile.*,
          COALESCE(user_org_unit.department, 'Unknown') AS department
        FROM ${ai_user_profile.SQL_TABLE_NAME} AS profile
        LEFT JOIN ${user_org_unit.SQL_TABLE_NAME} AS user_org_unit USING (user_email)
      ),

      department_summary AS (
        SELECT
          department,
          COUNT(*) AS people,
          COUNTIF(ai_days_28d > 0) AS active_people,
          COUNTIF(ai_days_28d = 0) AS inactive_people,
          COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS casual_people,
          COUNTIF(ai_days_28d >= @{normal_user_min_days}) AS regular_people
        FROM people
        GROUP BY department
      ),

      latest_licence_requests AS (
        SELECT COUNT(DISTINCT LOWER(user_email)) AS requesters
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`
        WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`)
          AND license_state = 'NO_LICENSE_ATTEMPTED_LOGIN'
          AND user_email IS NOT NULL
      ),

      classification AS (
        SELECT
          SUM(ai_actions) AS actions,
          SUM(IF(LOWER(feature) IN ('unspecified', 'unknown'), ai_actions, 0)) AS unclassified_actions
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
      )

      SELECT
        'build_repeat_usage' AS opportunity_type,
        'Organisation' AS scope_type,
        'All employees' AS scope,
        COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS size,
        CONCAT(CAST(COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS STRING), ' casual users and ', CAST(COUNTIF(ai_days_28d >= @{normal_user_min_days}) AS STRING), ' regular users in the last 28 days') AS evidence,
        'Follow up with short, task-specific coaching to help interested users repeat successful workflows.' AS recommended_action,
        CASE WHEN COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) > 0 AND COUNTIF(ai_days_28d >= @{normal_user_min_days}) = 0 THEN 1 ELSE 3 END AS priority
      FROM people

      UNION ALL
      SELECT
        'review_idle_licences',
        'Organisation',
        'Gemini Enterprise',
        COUNTIF(is_ge_licensed AND ge_days_28d = 0),
        CONCAT(CAST(COUNTIF(is_ge_licensed AND ge_days_28d = 0) AS STRING), ' assigned Gemini Enterprise licences had no Gemini Enterprise use in the last 28 days'),
        'Validate rollout timing and need, then reassign or reclaim unnecessary licences.',
        CASE WHEN COUNTIF(is_ge_licensed AND ge_days_28d = 0) > 0 THEN 1 ELSE 4 END
      FROM people

      UNION ALL
      SELECT
        'expand_department_adoption',
        'Department',
        department,
        inactive_people,
        CONCAT(CAST(active_people AS STRING), ' active of ', CAST(people AS STRING), ' eligible people; ', CAST(inactive_people AS STRING), ' inactive'),
        'Run a team-specific use-case session with early adopters and follow up after 28 days.',
        CASE WHEN inactive_people >= 5 THEN 2 ELSE 3 END
      FROM department_summary
      WHERE people > 0 AND inactive_people > 0

      UNION ALL
      SELECT
        'workspace_to_enterprise',
        'Organisation',
        'Workspace-only users',
        COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0),
        CONCAT(CAST(COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0) AS STRING), ' people used Workspace Gemini but not Gemini Enterprise in the last 28 days'),
        'Check whether these users need Gemini Enterprise access or a product-specific enablement path.',
        3
      FROM people

      UNION ALL
      SELECT
        'address_access_friction',
        'Organisation',
        'Licence requests',
        requesters,
        CONCAT(CAST(requesters AS STRING), ' users attempted to access Gemini Enterprise without a licence'),
        'Review eligibility and licence-request handling.',
        CASE WHEN requesters > 0 THEN 1 ELSE 4 END
      FROM latest_licence_requests

      UNION ALL
      SELECT
        'improve_classification',
        'Data quality',
        'Use-case mapping',
        IFNULL(unclassified_actions, 0),
        CONCAT(CAST(IFNULL(unclassified_actions, 0) AS STRING), ' of ', CAST(IFNULL(actions, 0) AS STRING), ' AI actions are unclassified in the last 28 days'),
        'Investigate Workspace feature_source coverage and update the use-case mapping.',
        CASE WHEN SAFE_DIVIDE(unclassified_actions, NULLIF(actions, 0)) > 0.25 THEN 2 ELSE 4 END
      FROM classification ;;
  }

  dimension: opportunity_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.opportunity_type, '|', ${TABLE}.scope_type, '|', ${TABLE}.scope) ;;
  }

  dimension: opportunity_type {
    label: "Opportunity"
    type: string
    sql: ${TABLE}.opportunity_type ;;
  }

  dimension: scope_type {
    type: string
    sql: ${TABLE}.scope_type ;;
  }

  dimension: scope {
    type: string
    sql: ${TABLE}.scope ;;
  }

  dimension: evidence {
    type: string
    sql: ${TABLE}.evidence ;;
  }

  dimension: recommended_action {
    label: "Recommended Action"
    type: string
    sql: ${TABLE}.recommended_action ;;
  }

  dimension: priority {
    type: number
    sql: ${TABLE}.priority ;;
  }

  dimension: size {
    type: number
    sql: ${TABLE}.size ;;
  }

  measure: opportunities {
    type: count
  }
}
