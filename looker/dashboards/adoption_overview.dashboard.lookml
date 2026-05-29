dashboard: adoption_overview {
  title: "Gemini Enterprise Adoption Overview"
  layout: newspaper

  filter: date_filter {
    title: "Date"
    type: date_filter
    default_value: "90 days"
  }

  element: active_users_total {
    title: "Active Users (Total)"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.daily_active_users, active_users.weekly_active_users, active_users.monthly_active_users]
    filters: {
      active_users.product_type: "Total"
    }
    listen: {
      date_filter: active_users.metric_date
    }
    width: 12
    height: 8
  }

  element: active_users_by_product {
    title: "Daily Active Users by Surface"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.product_type, active_users.daily_active_users]
    pivots: [active_users.product_type]
    filters: {
      active_users.product_type: "-Total"
    }
    listen: {
      date_filter: active_users.metric_date
    }
    width: 12
    height: 8
  }

  element: seats_purchased {
    title: "Seats Purchased"
    type: single_value
    model: gemini_enterprise
    explore: seats
    fields: [seats.seats_purchased]
    listen: {
      date_filter: seats.metric_date
    }
    width: 6
    height: 4
  }

  element: seat_utilisation {
    title: "Seat Utilisation"
    type: single_value
    model: gemini_enterprise
    explore: seats
    fields: [seats.seat_utilisation]
    listen: {
      date_filter: seats.metric_date
    }
    width: 6
    height: 4
  }

  element: seats_trend {
    title: "Seats Purchased vs Claimed"
    type: looker_area
    model: gemini_enterprise
    explore: seats
    fields: [seats.metric_date, seats.seats_purchased, seats.seats_claimed]
    listen: {
      date_filter: seats.metric_date
    }
    width: 12
    height: 8
  }

  element: retention {
    title: "Retention (Total)"
    type: looker_line
    model: gemini_enterprise
    explore: active_users
    fields: [active_users.metric_date, active_users.retention_7d, active_users.retention_28d]
    filters: {
      active_users.product_type: "Total"
    }
    listen: {
      date_filter: active_users.metric_date
    }
    width: 12
    height: 8
  }
}
