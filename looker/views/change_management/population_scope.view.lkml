view: population_scope {
  label: "Population Scope"
  # One row per person the block has seen in any configured source. This is the
  # only place where employee-domain and exclusion settings are applied.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH candidates AS (
        SELECT DISTINCT LOWER(user_email) AS user_email
        FROM (SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity` AS source LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity ON person_identity.source_email = LOWER(source.user_email) AND source.event_ts >= person_identity.valid_from AND source.event_ts < person_identity.valid_to)
        WHERE user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)

        UNION DISTINCT
        SELECT DISTINCT LOWER(user_email) AS user_email
        FROM (SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses` AS source LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity ON person_identity.source_email = LOWER(source.user_email) AND TIMESTAMP(source.snapshot_date) >= person_identity.valid_from AND TIMESTAMP(source.snapshot_date) < person_identity.valid_to)
        WHERE user_email IS NOT NULL

        UNION DISTINCT
        SELECT DISTINCT LOWER(user_email) AS user_email
        FROM (SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email) FROM `@{gemini_project}.@{gemini_dataset}.antigravity_usage` AS source LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity ON person_identity.source_email = LOWER(source.user_email) AND source.event_ts >= person_identity.valid_from AND source.event_ts < person_identity.valid_to)
        WHERE user_email IS NOT NULL
          AND event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 400 DAY)

        UNION DISTINCT
        SELECT DISTINCT LOWER(user_email) AS user_email
        FROM ${workspace_user_daily.SQL_TABLE_NAME}
        WHERE user_email IS NOT NULL
      ),

      enriched AS (
        SELECT
          candidates.user_email,
          REGEXP_EXTRACT(candidates.user_email, r'@(.+)$') AS user_domain,
          user_org_unit.org_unit
        FROM candidates
        LEFT JOIN ${user_org_unit.SQL_TABLE_NAME} AS user_org_unit USING (user_email)
      ),

      scoped AS (
        SELECT
          *,
          {% if '@{employee_domains}' == '' %}
          TRUE
          {% else %}
          user_domain IN UNNEST(ARRAY(
            SELECT TRIM(domain)
            FROM UNNEST(SPLIT(LOWER('@{employee_domains}'), ',')) AS domain
            WHERE TRIM(domain) != ''
          ))
          {% endif %} AS domain_allowed,
          {% if '@{excluded_org_units}' == '' %}
          FALSE
          {% else %}
          REGEXP_CONTAINS(IFNULL(org_unit, ''), r'@{excluded_org_units}')
          {% endif %} AS org_unit_excluded,
          {% if '@{excluded_email_pattern}' == '' %}
          FALSE
          {% else %}
          REGEXP_CONTAINS(user_email, r'@{excluded_email_pattern}')
          {% endif %} AS email_excluded
        FROM enriched
      )

      SELECT
        user_email,
        user_domain,
        org_unit,
        domain_allowed AND NOT org_unit_excluded AND NOT email_excluded AS in_scope,
        CASE
          WHEN NOT domain_allowed THEN 'Domain not in employee_domains'
          WHEN org_unit_excluded THEN 'Excluded org unit'
          WHEN email_excluded THEN 'Excluded email pattern'
          ELSE 'Included'
        END AS scope_reason
      FROM scoped ;;
  }

  dimension: user_email {
    primary_key: yes
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: user_domain {
    label: "User Domain"
    type: string
    sql: ${TABLE}.user_domain ;;
  }

  dimension: org_unit {
    label: "Org Unit"
    type: string
    sql: ${TABLE}.org_unit ;;
  }

  dimension: in_scope {
    label: "In Employee Scope"
    type: yesno
    sql: ${TABLE}.in_scope ;;
  }

  dimension: scope_reason {
    label: "Scope Reason"
    type: string
    sql: ${TABLE}.scope_reason ;;
  }

  measure: people_seen {
    type: count
  }

  measure: included_people {
    type: count
    filters: [in_scope: "yes"]
  }

  measure: excluded_people {
    type: count
    filters: [in_scope: "no"]
  }
}
