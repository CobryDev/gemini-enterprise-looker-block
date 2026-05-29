view: export_history {
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.export_history` ;;
  label: "Export History (raw)"

  dimension: row_key {
    primary_key: yes
    hidden: yes
    description: "Stable MD5 hash of every dimension column. Used as the merge upsert key so re-exported rows update in place."
    type: string
    sql: ${TABLE}.row_key ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) resource ID the row belongs to. One engine per tracked app."
    type: string
    sql: ${TABLE}.engine_id ;;
  }

  dimension: app_name {
    label: "App"
    description: "Friendly name of the Gemini Enterprise app, mapped from engine_id by the merge job. Falls back to the raw engine_id if no display name is configured."
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension_group: metric {
    label: "Metric"
    description: "Calendar date (UTC, not time-zone converted) the metrics in the row were recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  dimension: data_source {
    description: "Origin of the row and which metrics it carries: AGGREGATED_METRIC (engine-wide daily snapshots such as seats), GWS_LOG (active-user counts by product surface plus Assistant answers), USER_EVENT (search, click and page-visit events broken down by device)."
    type: string
    sql: ${TABLE}.data_source ;;
  }

  dimension: product_type {
    description: "Product surface the active-user counts apply to: Total, Search, Assistant, or Other. Only set on GWS_LOG active-user rows."
    type: string
    sql: ${TABLE}.product_type ;;
  }

  dimension: device_type {
    description: "Client platform derived from the user agent (e.g. Macintosh, X11, Rest). Set on user-event activity rows."
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: serving_config_id {
    description: "Search serving config that handled the query. Present on query-level search rows."
    type: string
    sql: ${TABLE}.serving_config_id ;;
  }

  dimension: original_search_query {
    description: "Raw search query text as typed by the user. Google only emits this above its k-anonymity threshold, so low-volume queries are suppressed (null)."
    type: string
    sql: ${TABLE}.original_search_query ;;
  }

  dimension: document_name {
    description: "Resource name of a document surfaced in search or answer results. Present on document-level rows above the suppression threshold."
    type: string
    sql: ${TABLE}.document_name ;;
  }

  dimension: agent_name {
    description: "Resource name of the agent the row reports usage for. Present only on per-agent rows once agents are used."
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: agent_type {
    description: "Category of the agent as classified by Gemini Enterprise (e.g. the kind of agent or how it was built)."
    type: string
    sql: ${TABLE}.agent_type ;;
  }

  dimension: agent_ownership {
    description: "Whether the agent is owned by the customer or provided by Google."
    type: string
    sql: ${TABLE}.agent_ownership ;;
  }

  dimension: dislike_reasons {
    description: "Reason codes users selected when giving negative (dislike) feedback on an answer."
    type: string
    sql: ${TABLE}.dislike_reasons ;;
  }

  dimension_group: ingested {
    description: "Timestamp the merge job last wrote (inserted or updated) this row into the history table."
    type: time
    timeframes: [time, date, week]
    sql: ${TABLE}.ingested_at ;;
  }

  measure: row_count {
    type: count
    label: "Export Rows"
    description: "Number of raw export rows matching the current filters, across every grain and data source."
  }
}
