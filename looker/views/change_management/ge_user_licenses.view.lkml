view: ge_user_licenses {
  label: "Licences"
  # Daily snapshot of per-user licence assignment and last login from the
  # Gemini Enterprise userLicenses API. Filter Is Latest Snapshot = Yes for
  # current state; use Snapshot Date for licence growth over time.
  # user_email is the person's current address; see person_identity.
  derived_table: {
    sql:
      SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email)
      FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses` AS source
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = LOWER(source.user_email)
        AND TIMESTAMP(source.snapshot_date) >= person_identity.valid_from
        AND TIMESTAMP(source.snapshot_date) < person_identity.valid_to ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.snapshot_date AS STRING), '|', ${TABLE}.location, '|', ${TABLE}.user_email) ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: is_latest_snapshot {
    type: yesno
    sql: ${TABLE}.snapshot_date = (SELECT MAX(snapshot_date) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`) ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: location {
    label: "User Store Location"
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: license_state {
    description: "ASSIGNED, NO_LICENSE, NO_LICENSE_ATTEMPTED_LOGIN (tried to sign in without a licence: unmet demand) or BLOCKED."
    type: string
    sql: ${TABLE}.license_state ;;
  }

  dimension: license_config {
    label: "Licence Type"
    type: string
    sql: ${TABLE}.license_config ;;
  }

  dimension_group: assigned {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.create_time ;;
  }

  dimension_group: last_login {
    type: time
    timeframes: [raw, date, week, month]
    sql: ${TABLE}.last_login_time ;;
  }

  dimension: days_since_last_login {
    type: number
    sql: DATE_DIFF(${TABLE}.snapshot_date, DATE(${TABLE}.last_login_time), DAY) ;;
  }

  measure: licensed_users {
    type: count_distinct
    sql: CASE WHEN ${license_state} = 'ASSIGNED' THEN ${user_email} END ;;
    drill_fields: [user_email, license_config, assigned_date, last_login_date]
  }

  measure: unlicensed_login_attempts {
    label: "Users Wanting a Licence"
    description: "Users who tried to sign in without a licence."
    type: count_distinct
    sql: CASE WHEN ${license_state} = 'NO_LICENSE_ATTEMPTED_LOGIN' THEN ${user_email} END ;;
    drill_fields: [user_email, last_login_date]
  }

  measure: licensed_never_logged_in {
    type: count_distinct
    sql: CASE WHEN ${license_state} = 'ASSIGNED' AND ${TABLE}.last_login_time IS NULL THEN ${user_email} END ;;
    drill_fields: [user_email, license_config, assigned_date]
  }
}
