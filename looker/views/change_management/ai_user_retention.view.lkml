view: ai_user_retention {
  label: "AI Retention"
  # One row per user, product and month the user had an AI action, tagged
  # with their first AI month for that product. "Any AI" rows combine all
  # products. Read as a triangle: First Month down the side, Months Since
  # First across the top, Retention Rate in the cells. History is limited to
  # the 400 days in ai_activity_hourly, so first months near the start of
  # that window include returning users.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH monthly AS (
        SELECT user_email, product, DATE_TRUNC(event_date, MONTH) AS activity_month
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE ai_actions > 0
        GROUP BY 1, 2, 3
        UNION DISTINCT
        SELECT user_email, 'Any AI' AS product, DATE_TRUNC(event_date, MONTH) AS activity_month
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE ai_actions > 0
        GROUP BY 1, 2, 3
      ),

      firsts AS (
        SELECT user_email, product, MIN(activity_month) AS first_month
        FROM monthly
        GROUP BY 1, 2
      ),

      sizes AS (
        SELECT product, first_month, COUNT(*) AS cohort_size
        FROM firsts
        GROUP BY 1, 2
      )

      SELECT
        CONCAT(monthly.user_email, '|', monthly.product, '|', CAST(monthly.activity_month AS STRING)) AS pk,
        monthly.user_email,
        monthly.product,
        firsts.first_month,
        monthly.activity_month,
        DATE_DIFF(monthly.activity_month, firsts.first_month, MONTH) AS months_since_first,
        sizes.cohort_size
      FROM monthly
      JOIN firsts USING (user_email, product)
      JOIN sizes USING (product, first_month) ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: product {
    description: "Gemini Enterprise, Gemini for Workspace, Antigravity, or Any AI."
    type: string
    sql: ${TABLE}.product ;;
  }

  dimension_group: first {
    label: "First AI"
    type: time
    timeframes: [month, quarter]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.first_month ;;
  }

  dimension_group: activity {
    type: time
    timeframes: [month, quarter]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.activity_month ;;
  }

  dimension: months_since_first {
    type: number
    sql: ${TABLE}.months_since_first ;;
  }

  measure: retained_users {
    description: "Users active in the month."
    type: count_distinct
    sql: CONCAT(${user_email}, '|', ${product}, '|', CAST(${TABLE}.first_month AS STRING)) ;;
  }

  measure: new_users {
    description: "Users whose first AI month is in the group."
    type: sum_distinct
    sql_distinct_key: CONCAT(${product}, '|', CAST(${TABLE}.first_month AS STRING)) ;;
    sql: ${TABLE}.cohort_size ;;
  }

  measure: retention_rate {
    description: "Retained users divided by the size of their first-month cohort."
    type: number
    sql: SAFE_DIVIDE(${retained_users}, NULLIF(${new_users}, 0)) ;;
    value_format_name: percent_0
  }
}
