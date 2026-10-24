view: ge_admin_events {
  label: "Admin Changes"
  # Gemini Enterprise Admin Activity audit events: agent, connector and app
  # configuration changes, and who made them.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.ge_admin_events` ;;

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

  dimension_group: event_time {
    label: "Event Time"
    type: time
    timeframes: [raw, time]
    sql: ${TABLE}.event_ts ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: principal_email {
    label: "Changed By"
    type: string
    sql: ${TABLE}.principal_email ;;
  }

  dimension: method {
    label: "Change"
    description: "Short method name, for example CreateAgent, UpdateEngine, SetUpDataConnector."
    type: string
    sql: ${TABLE}.method ;;
  }

  dimension: resource_type {
    type: string
    sql: ${TABLE}.resource_type ;;
  }

  dimension: resource_name {
    type: string
    sql: ${TABLE}.resource_name ;;
  }

  dimension: is_failed {
    type: yesno
    sql: IFNULL(${TABLE}.status_code, 0) != 0 ;;
  }

  measure: changes {
    type: count
    drill_fields: [event_time_time, principal_email, method, resource_type, resource_name]
  }

  measure: admins {
    label: "People Making Changes"
    type: count_distinct
    sql: ${principal_email} ;;
  }
}
