view: ge_connector_activity {
  label: "Connector Errors"
  # Connector tool failures from the connector_activity log (Gemini Enterprise
  # only logs errors here). The raw error message isn't stored; it is
  # bucketed into error_category by the exporter.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.ge_connector_activity` ;;

  dimension: insert_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.insert_id ;;
  }

  dimension_group: event {
    label: "Event"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: connector_type {
    description: "google_drive, slack, hubspot and so on."
    type: string
    sql: ${TABLE}.connector_type ;;
  }

  dimension: connector_id {
    hidden: yes
    type: string
    sql: ${TABLE}.connector_id ;;
  }

  dimension: tool {
    type: string
    sql: ${TABLE}.tool ;;
  }

  dimension: agent {
    type: string
    sql: ${TABLE}.agent ;;
  }

  dimension: error_category {
    description: "Reconnect required, Authorisation or consent, Download blocked, Permission denied, Unsupported query, Invalid request, Not found, Rate limited, Timeout, Other."
    type: string
    sql: ${TABLE}.error_category ;;
  }

  dimension: is_user_fixable {
    description: "Errors the user can fix themselves by reconnecting or granting consent. Good candidates for a how-to nudge."
    type: yesno
    sql: ${TABLE}.error_category IN ('Reconnect required', 'Authorisation or consent') ;;
  }

  measure: connector_errors {
    type: count
    drill_fields: [event_date, user_email, connector_type, tool, error_category]
  }

  measure: affected_users {
    type: count_distinct
    sql: ${user_email} ;;
    drill_fields: [user_email, connector_type, connector_errors]
  }
}
