dashboard: value_realised {
  title: "Gemini Enterprise Engagement and Content"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: page_visits {
    title: "Page Visits by Surface"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [
      activity.metric_date,
      activity.home_page_visits,
      activity.agent_page_visits,
      activity.prompts_page_visits,
      activity.notebook_lm_page_visits,
      activity.deep_research_page_visits,
      activity.idea_generation_page_visits
    ]
    listen: {
      date_filter: activity.metric_date
    }
    width: 24
    height: 8
  }

  element: top_queries {
    title: "Top Search Queries"
    type: looker_grid
    model: gemini_enterprise
    explore: search_queries
    fields: [search_queries.query, search_queries.searches, search_queries.search_clicks]
    sorts: [search_queries.searches desc]
    limit: 50
    listen: {
      date_filter: search_queries.metric_date
    }
    note_state: collapsed
    note_display: hover
    note_text: "Populates once search volume exceeds Google's privacy suppression threshold."
    width: 12
    height: 8
  }

  element: top_documents {
    title: "Top Documents Surfaced"
    type: looker_grid
    model: gemini_enterprise
    explore: documents
    fields: [documents.document_name, documents.times_surfaced_in_search, documents.times_viewed]
    sorts: [documents.times_surfaced_in_search desc]
    limit: 50
    listen: {
      date_filter: documents.metric_date
    }
    note_state: collapsed
    note_display: hover
    note_text: "Populates above the suppression threshold."
    width: 12
    height: 8
  }
}
