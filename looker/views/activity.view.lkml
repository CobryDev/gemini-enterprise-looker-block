view: activity {
  label: "Activity & Engagement"
  # Search, answer, click, feedback and page-visit activity. These arrive on the
  # USER_EVENT and GWS_LOG rows, broken down by device. Slice by device_type to
  # compare desktop vs other clients.
  derived_table: {
    sql:
      SELECT
        engine_id,
        metric_date,
        data_source,
        device_type,
        search_count,
        search_click_count,
        answer_count,
        action_count,
        feedback_like_count,
        feedback_dislike_count,
        total_home_page_visit_count,
        total_agent_gallery_page_visit_count,
        total_prompts_page_visit_count,
        total_people_page_visit_count,
        total_notebook_lm_page_visit_count,
        total_deep_research_page_visit_count,
        total_idea_generation_page_visit_count,
        total_agent_page_visit_count
      FROM `@{gemini_project}.@{gemini_dataset}.export_history`
      WHERE data_source IN ('DATA_SOURCE_USER_EVENT', 'DATA_SOURCE_GWS_LOG')
        AND device_type IS NOT NULL ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.metric_date, '|', ${TABLE}.data_source, '|', ${TABLE}.device_type) ;;
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

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
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

  measure: click_through_rate {
    label: "Search Click-Through Rate"
    type: number
    sql: SAFE_DIVIDE(${search_clicks}, ${searches}) ;;
    value_format_name: percent_1
  }

  measure: answers {
    label: "Assistant Answers"
    type: sum
    sql: ${TABLE}.answer_count ;;
    value_format_name: decimal_0
  }

  measure: actions {
    type: sum
    sql: ${TABLE}.action_count ;;
    value_format_name: decimal_0
  }

  measure: likes {
    type: sum
    sql: ${TABLE}.feedback_like_count ;;
    value_format_name: decimal_0
  }

  measure: dislikes {
    type: sum
    sql: ${TABLE}.feedback_dislike_count ;;
    value_format_name: decimal_0
  }

  measure: positive_feedback_rate {
    type: number
    sql: SAFE_DIVIDE(${likes}, NULLIF(${likes} + ${dislikes}, 0)) ;;
    value_format_name: percent_1
  }

  measure: home_page_visits {
    type: sum
    sql: ${TABLE}.total_home_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: agent_page_visits {
    type: sum
    sql: ${TABLE}.total_agent_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: agent_gallery_page_visits {
    type: sum
    sql: ${TABLE}.total_agent_gallery_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: prompts_page_visits {
    type: sum
    sql: ${TABLE}.total_prompts_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: notebook_lm_page_visits {
    label: "NotebookLM Page Visits"
    type: sum
    sql: ${TABLE}.total_notebook_lm_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: deep_research_page_visits {
    type: sum
    sql: ${TABLE}.total_deep_research_page_visit_count ;;
    value_format_name: decimal_0
  }

  measure: idea_generation_page_visits {
    type: sum
    sql: ${TABLE}.total_idea_generation_page_visit_count ;;
    value_format_name: decimal_0
  }
}
