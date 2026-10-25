view: intervention_impact {
  label: "Intervention Impact"
  # Before/after comparison for each intervention target and a simple comparison
  # group. This is directional evidence, not proof of causation.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH interventions AS (
        SELECT *
        FROM `@{gemini_project}.@{gemini_dataset}.@{interventions_table}`
        WHERE status IS NULL OR LOWER(status) != 'cancelled'
      ),

      population AS (
        SELECT
          profile.user_email,
          COALESCE(user_org_unit.department, 'Unknown') AS department
        FROM ${ai_user_profile.SQL_TABLE_NAME} AS profile
        LEFT JOIN ${user_org_unit.SQL_TABLE_NAME} AS user_org_unit USING (user_email)
      ),

      participants AS (
        SELECT
          interventions.intervention_id,
          'Target' AS comparison_group,
          population.user_email,
          interventions.start_date
        FROM interventions
        JOIN population
          ON (
            LOWER(interventions.target_scope_type) = 'organisation'
            OR (LOWER(interventions.target_scope_type) = 'department' AND population.department = interventions.target_scope)
            OR (
              LOWER(interventions.target_scope_type) = 'email_list'
              AND population.user_email IN UNNEST(ARRAY(
                SELECT TRIM(LOWER(email))
                FROM UNNEST(SPLIT(interventions.target_scope, ',')) AS email
                WHERE TRIM(email) != ''
              ))
            )
          )

        UNION ALL
        SELECT
          interventions.intervention_id,
          'Comparison' AS comparison_group,
          population.user_email,
          interventions.start_date
        FROM interventions
        JOIN population
          ON NOT (
            LOWER(interventions.target_scope_type) = 'organisation'
            OR (LOWER(interventions.target_scope_type) = 'department' AND population.department = interventions.target_scope)
            OR (
              LOWER(interventions.target_scope_type) = 'email_list'
              AND population.user_email IN UNNEST(ARRAY(
                SELECT TRIM(LOWER(email))
                FROM UNNEST(SPLIT(interventions.target_scope, ',')) AS email
                WHERE TRIM(email) != ''
              ))
            )
          )
      ),

      user_period AS (
        SELECT
          participants.intervention_id,
          participants.comparison_group,
          CASE
            WHEN activity.event_date BETWEEN DATE_SUB(participants.start_date, INTERVAL 28 DAY) AND DATE_SUB(participants.start_date, INTERVAL 1 DAY) THEN 'Before'
            WHEN activity.event_date BETWEEN participants.start_date AND DATE_ADD(participants.start_date, INTERVAL 27 DAY) THEN 'After'
          END AS period,
          participants.user_email,
          COUNT(DISTINCT activity.event_date) AS ai_days,
          SUM(IFNULL(activity.ai_actions, 0)) AS ai_actions,
          COUNT(DISTINCT IF(activity.ai_actions > 0, activity.feature, NULL)) AS feature_breadth
        FROM participants
        LEFT JOIN ${ai_activity_hourly.SQL_TABLE_NAME} AS activity
          ON activity.user_email = participants.user_email
          AND activity.event_date BETWEEN DATE_SUB(participants.start_date, INTERVAL 28 DAY) AND DATE_ADD(participants.start_date, INTERVAL 27 DAY)
        GROUP BY 1, 2, 3, 4
      )

      SELECT
        CONCAT(intervention_id, '|', comparison_group, '|', IFNULL(period, 'No activity')) AS pk,
        intervention_id,
        comparison_group,
        IFNULL(period, 'No activity') AS period,
        COUNT(DISTINCT user_email) AS people,
        COUNT(DISTINCT IF(ai_days > 0, user_email, NULL)) AS active_people,
        COUNT(DISTINCT IF(ai_days >= @{normal_user_min_days}, user_email, NULL)) AS regular_people,
        SUM(ai_days) AS ai_active_days,
        SUM(ai_actions) AS ai_actions,
        SUM(feature_breadth) AS feature_breadth
      FROM user_period
      GROUP BY 1, 2, 3, 4 ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension: intervention_id {
    type: string
    sql: ${TABLE}.intervention_id ;;
  }

  dimension: comparison_group {
    type: string
    sql: ${TABLE}.comparison_group ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}.period ;;
  }

  dimension: caution {
    label: "Caution"
    type: string
    sql: 'Comparison, not proof of causation' ;;
  }

  measure: people {
    type: sum
    sql: ${TABLE}.people ;;
  }

  measure: active_people {
    type: sum
    sql: ${TABLE}.active_people ;;
  }

  measure: activation_rate {
    type: number
    sql: SAFE_DIVIDE(${active_people}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
  }

  measure: regular_people {
    type: sum
    sql: ${TABLE}.regular_people ;;
  }

  measure: regular_adoption_rate {
    type: number
    sql: SAFE_DIVIDE(${regular_people}, NULLIF(${people}, 0)) ;;
    value_format_name: percent_0
  }

  measure: ai_active_days {
    type: sum
    sql: ${TABLE}.ai_active_days ;;
    value_format_name: decimal_0
  }

  measure: ai_actions {
    type: sum
    sql: ${TABLE}.ai_actions ;;
    value_format_name: decimal_0
  }

  measure: feature_breadth {
    type: sum
    sql: ${TABLE}.feature_breadth ;;
    value_format_name: decimal_0
  }
}
