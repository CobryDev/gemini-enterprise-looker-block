view: documents {
  label: "Documents"
  # Per-document surfacing. Populated once documents are returned/viewed in search
  # and answer results above the suppression threshold.
  derived_table: {
    sql:
      SELECT
        engine_id,
        app_name,
        metric_date,
        document_name,
        total_search_contents,
        total_view_contents
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE document_name IS NOT NULL ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date, '|', ${TABLE}.document_name) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the document was surfaced in."
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension: app_name {
    label: "App"
    description: "Friendly name of the Gemini Enterprise app, mapped from engine_id."
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension_group: metric {
    label: "Metric"
    description: "Date (UTC) the document activity was recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: document_name {
    description: "Resource name of the document surfaced or viewed in search and answer results."
    type: string
    sql: ${TABLE}.document_name ;;
  }

  measure: times_surfaced_in_search {
    description: "Total times the document was returned in search or answer results."
    type: sum
    sql: ${TABLE}.total_search_contents ;;
    value_format_name: decimal_0
  }

  measure: times_viewed {
    description: "Total times the document was opened/viewed from results."
    type: sum
    sql: ${TABLE}.total_view_contents ;;
    value_format_name: decimal_0
  }

  measure: distinct_documents {
    description: "Number of distinct documents surfaced in the selected period."
    type: count_distinct
    sql: ${document_name} ;;
  }
}
