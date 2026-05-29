view: search_queries {
  label: "Search Queries"
  # Query-level rows. Google only emits query text above a k-anonymity threshold,
  # so low-volume queries are suppressed and this view stays empty until there is
  # enough search traffic.
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        original_search_query,
        serving_config_id,
        document_name,
        search_count,
        search_click_count
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE original_search_query IS NOT NULL ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.metric_date, '|', ${TABLE}.original_search_query, '|', COALESCE(${TABLE}.document_name, '')) ;;
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

  dimension: query {
    label: "Search Query"
    type: string
    sql: ${TABLE}.original_search_query ;;
  }

  dimension: serving_config_id {
    type: string
    sql: ${TABLE}.serving_config_id ;;
  }

  dimension: document_name {
    type: string
    sql: ${TABLE}.document_name ;;
  }

  measure: searches {
    type: sum
    sql: ${TABLE}.search_count ;;
    value_format_name: decimal_0
  }

  measure: search_clicks {
    type: sum
    sql: ${TABLE}.search_click_count ;;
    value_format_name: decimal_0
  }

  measure: distinct_queries {
    type: count_distinct
    sql: ${query} ;;
  }
}
