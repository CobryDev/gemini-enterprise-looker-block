view: workspace_user_daily {
  label: "Workspace Population"
  # One row per Workspace user per day with any audit event (sign-ins, Drive,
  # Meet, Gemini and so on) over the last 400 days. It is the denominator for
  # Workspace activation and the Non-AI cohort, and the source of org units.
  # Only users with an org unit somewhere in the window are kept, which drops
  # external collaborators and service accounts that appear as actors.
  # The audit export is ingestion-time partitioned, and an event always lands
  # in a partition at or after its own time, so the _PARTITIONTIME filter
  # prunes without dropping events. Empty unless workspace_export is
  # same_region.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    partition_keys: ["event_date"]
    cluster_keys: ["user_email"]
    sql:
      {% if '@{workspace_export}' == 'same_region' %}
      WITH events AS (
        SELECT
          time_usec,
          LOWER(email) AS user_email,
          domain_name,
          -- org_unit_name_path is the path as an array whose first element is
          -- the organisation itself: [org, 'Sales', 'EMEA'] becomes /Sales/EMEA.
          IF(ARRAY_LENGTH(org_unit_name_path) = 0, NULL, CONCAT('/', ARRAY_TO_STRING(ARRAY(
            SELECT part FROM UNNEST(org_unit_name_path) AS part WITH OFFSET AS depth
            WHERE depth > 0 ORDER BY depth
          ), '/'))) AS org_unit
        FROM `@{gemini_project}.@{workspace_dataset}.activity`
        WHERE email IS NOT NULL
          AND time_usec >= UNIX_MICROS(TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)))
          AND _PARTITIONTIME >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY))
      ),

      daily AS (
        SELECT
          DATE(TIMESTAMP_MICROS(time_usec)) AS event_date,
          user_email,
          ARRAY_AGG(org_unit IGNORE NULLS ORDER BY time_usec DESC LIMIT 1)[SAFE_OFFSET(0)] AS org_unit,
          ANY_VALUE(domain_name) AS domain_name,
          COUNT(*) AS events
        FROM events
        GROUP BY 1, 2
      ),

      internal_users AS (
        SELECT user_email
        FROM daily
        GROUP BY user_email
        HAVING LOGICAL_OR(org_unit IS NOT NULL)
      )

      SELECT daily.*
      FROM daily
      JOIN internal_users USING (user_email)
      {% else %}
      SELECT
        CAST(NULL AS DATE) AS event_date,
        CAST(NULL AS STRING) AS user_email,
        CAST(NULL AS STRING) AS org_unit,
        CAST(NULL AS STRING) AS domain_name,
        CAST(NULL AS INT64) AS events
      FROM UNNEST(ARRAY<INT64>[])
      {% endif %} ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.user_email, '|', CAST(${TABLE}.event_date AS STRING)) ;;
  }

  dimension_group: event {
    label: "Workspace Activity"
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    sql: ${TABLE}.user_email ;;
  }

  measure: workspace_users {
    description: "Distinct Workspace users with any audit event in the period."
    type: count_distinct
    sql: ${user_email} ;;
  }
}
