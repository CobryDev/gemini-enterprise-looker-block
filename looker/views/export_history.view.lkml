view: export_history {
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.export_history` ;;
  label: "Export History (raw)"

  dimension: row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.row_key ;;
  }

  dimension: engine_id {
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension_group: metric {
    label: "Metric"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: data_source {
    description: "AGGREGATED_METRIC, GWS_LOG, or USER_EVENT."
    type: string
    sql: ${TABLE}.data_source ;;
  }

  dimension: product_type {
    description: "Total, Search, Assistant, Other."
    type: string
    sql: ${TABLE}.product_type ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: serving_config_id {
    type: string
    sql: ${TABLE}.serving_config_id ;;
  }

  dimension: original_search_query {
    type: string
    sql: ${TABLE}.original_search_query ;;
  }

  dimension: document_name {
    type: string
    sql: ${TABLE}.document_name ;;
  }

  dimension: agent_name {
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: agent_type {
    type: string
    sql: ${TABLE}.agent_type ;;
  }

  dimension: agent_ownership {
    type: string
    sql: ${TABLE}.agent_ownership ;;
  }

  dimension: dislike_reasons {
    type: string
    sql: ${TABLE}.dislike_reasons ;;
  }

  dimension_group: ingested {
    type: time
    timeframes: [time, date, week]
    sql: ${TABLE}.ingested_at ;;
  }

  measure: row_count {
    type: count
    label: "Export Rows"
  }
}
