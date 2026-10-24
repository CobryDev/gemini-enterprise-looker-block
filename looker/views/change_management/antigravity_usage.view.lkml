view: antigravity_usage {
  label: "Antigravity"
  # One row per Antigravity inference, from metadata-only
  # InferenceResponseLog entries. Prompts are never logged here.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.antigravity_usage` ;;

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
    timeframes: [raw, time, hour_of_day, day_of_week]
    sql: ${TABLE}.event_ts ;;
  }

  dimension_group: event_local {
    label: "Local Time"
    description: "Request time in the reporting_time_zone constant."
    type: time
    timeframes: [hour_of_day, day_of_week, day_of_week_index]
    convert_tz: no
    datatype: datetime
    sql: DATETIME(${TABLE}.event_ts, '@{reporting_time_zone}') ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    sql: ${TABLE}.user_email ;;
  }

  dimension: client_name {
    label: "Client"
    description: "IDE or CLI that made the request."
    type: string
    sql: ${TABLE}.client_name ;;
  }

  dimension: client_version {
    type: string
    sql: ${TABLE}.client_version ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: experience {
    description: "Antigravity surface, for example agent or autocomplete."
    type: string
    sql: ${TABLE}.experience ;;
  }

  dimension: trajectory_id {
    hidden: yes
    type: string
    sql: ${TABLE}.trajectory_id ;;
  }

  measure: requests {
    label: "Inference Requests"
    type: count
    drill_fields: [event_date, user_email, client_name, model, experience]
  }

  measure: users {
    label: "Antigravity Users"
    type: count_distinct
    sql: ${user_email} ;;
    drill_fields: [user_email, requests, total_tokens]
  }

  measure: agent_tasks {
    description: "Distinct agent trajectories (multi-step tasks)."
    type: count_distinct
    sql: ${trajectory_id} ;;
  }

  measure: total_tokens {
    type: sum
    sql: ${TABLE}.total_tokens ;;
    value_format_name: decimal_0
  }

  measure: requests_per_user {
    type: number
    sql: SAFE_DIVIDE(${requests}, NULLIF(${users}, 0)) ;;
    value_format_name: decimal_1
  }

  measure: tokens_per_user {
    type: number
    sql: SAFE_DIVIDE(${total_tokens}, NULLIF(${users}, 0)) ;;
    value_format_name: decimal_0
  }
}
