view: search_queries {
  label: "Search Queries"
  # Query-level rows. Google only emits query text above a k-anonymity threshold,
  # so low-volume queries are suppressed and this view stays empty until there is
  # enough search traffic.
  # Query-row slice of export_history (original_search_query IS NOT NULL), applied
  # as a sql_always_where on the explore so the partitioned base table is read directly.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.export_history` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date, '|', ${TABLE}.original_search_query, '|', COALESCE(${TABLE}.document_name, '')) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the query belongs to."
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
    description: "Date (UTC) the query activity was recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: query {
    label: "Search Query"
    description: "Raw query text as typed by the user. Only emitted above Google's k-anonymity threshold, so low-volume queries are suppressed."
    type: string
    sql: ${TABLE}.original_search_query ;;
  }

  dimension: serving_config_id {
    description: "Search serving config that handled the query."
    type: string
    sql: ${TABLE}.serving_config_id ;;
  }

  dimension: document_name {
    description: "Resource name of the document associated with the query (e.g. a result returned for it)."
    type: string
    sql: ${TABLE}.document_name ;;
  }

  measure: searches {
    description: "Total times the query was searched."
    type: sum
    sql: ${TABLE}.search_count ;;
    value_format_name: decimal_0
  }

  measure: search_clicks {
    description: "Total result clicks following the query."
    type: sum
    sql: ${TABLE}.search_click_count ;;
    value_format_name: decimal_0
  }

  measure: distinct_queries {
    description: "Number of distinct query strings in the selected period."
    type: count_distinct
    sql: ${query} ;;
  }
}
