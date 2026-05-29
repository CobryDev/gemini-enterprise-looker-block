dashboard: usage_and_quality {
  title: "Gemini Enterprise Usage and Quality"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: search_volume {
    title: "Searches and Clicks"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.searches, activity.search_clicks]
    listen: {
      date_filter: activity.metric_date
    }
    width: 12
    height: 8
  }

  element: ctr {
    title: "Search Click-Through Rate"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.click_through_rate]
    listen: {
      date_filter: activity.metric_date
    }
    width: 6
    height: 4
  }

  element: answers_total {
    title: "Assistant Answers"
    type: single_value
    model: gemini_enterprise
    explore: activity
    fields: [activity.answers]
    listen: {
      date_filter: activity.metric_date
    }
    width: 6
    height: 4
  }

  element: answers_trend {
    title: "Assistant Answers Over Time"
    type: looker_line
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.answers]
    listen: {
      date_filter: activity.metric_date
    }
    width: 12
    height: 8
  }

  element: activity_by_device {
    title: "Searches by Device"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.device_type, activity.searches]
    pivots: [activity.device_type]
    listen: {
      date_filter: activity.metric_date
    }
    width: 12
    height: 8
  }

  element: feedback {
    title: "Feedback (Likes vs Dislikes)"
    type: looker_column
    model: gemini_enterprise
    explore: activity
    fields: [activity.metric_date, activity.likes, activity.dislikes]
    listen: {
      date_filter: activity.metric_date
    }
    width: 12
    height: 8
  }
}
