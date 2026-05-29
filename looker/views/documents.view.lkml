view: documents {
  label: "Documents"
  # Per-document surfacing. Populated once documents are returned/viewed in search
  # and answer results above the suppression threshold.
  derived_table: {
    sql:
      SELECT
        engine_id,
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
    sql: CONCAT(${TABLE}.metric_date, '|', ${TABLE}.document_name) ;;
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

  dimension: document_name {
    type: string
    sql: ${TABLE}.document_name ;;
  }

  measure: times_surfaced_in_search {
    type: sum
    sql: ${TABLE}.total_search_contents ;;
    value_format_name: decimal_0
  }

  measure: times_viewed {
    type: sum
    sql: ${TABLE}.total_view_contents ;;
    value_format_name: decimal_0
  }

  measure: distinct_documents {
    type: count_distinct
    sql: ${document_name} ;;
  }
}
