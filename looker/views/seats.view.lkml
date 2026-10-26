view: seats {
  label: "Seats & Licensing"
  # Seat counts come from the engine-wide aggregated metric rows, one per day.
  # AGGREGATED_METRIC slice of export_history, applied as a sql_always_where on
  # the explore so the partitioned base table is read directly.
  sql_table_name: `@{gemini_project}.@{gemini_dataset}.export_history` ;;

  dimension: data_source {
    hidden: yes
    description: "AGGREGATED_METRIC, GWS_LOG, or USER_EVENT. Used to slice this view at the explore level."
    type: string
    sql: ${TABLE}.data_source ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.engine_id, '|', ${TABLE}.metric_date) ;;
  }

  dimension: engine_id {
    description: "Gemini Enterprise engine (app) the seat counts belong to."
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
    description: "Date (UTC) the seat snapshot was recorded for."
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.metric_date ;;
  }

  measure: seats_purchased {
    description: "Licenses purchased for the app. A daily snapshot, so this takes the max over the selected period rather than summing."
    type: max
    sql: ${TABLE}.seats_purchased ;;
    value_format_name: decimal_0
  }

  measure: seats_claimed {
    description: "Licenses actually assigned to users. A daily snapshot, so this takes the max over the selected period rather than summing."
    type: max
    sql: ${TABLE}.seats_claimed ;;
    value_format_name: decimal_0
  }

  measure: seat_utilisation {
    label: "Seat Utilisation"
    description: "Seats claimed divided by seats purchased. Shows how much of the purchased capacity is in use."
    type: number
    sql: SAFE_DIVIDE(${seats_claimed}, ${seats_purchased}) ;;
    value_format_name: percent_1
  }

  measure: seat_utilisation_card {
    hidden: yes
    description: "Claimed out of purchased with a progress bar. Include seats_claimed, seats_purchased and unclaimed_seats in the tile query."
    type: number
    sql: ${seat_utilisation} ;;
    value_format_name: percent_0
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;line-height:1.35;white-space:normal;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;">Seat utilisation</div><div style="font-size:32px;font-weight:600;color:#202124;margin:4px 0;">{{ rendered_value }}</div><div style="font-size:13px;color:#3c4043;">{{ seats_claimed._rendered_value }} of {{ seats_purchased._rendered_value }} seats claimed, {{ unclaimed_seats._rendered_value }} available</div><div style="margin-top:10px;height:10px;border-radius:5px;background:#E8EAED;overflow:hidden;"><div style="height:10px;width:{{ value | times: 100 | round }}%;background:#1A73E8;border-radius:5px;"></div></div></div> ;;
  }

  measure: unclaimed_seats {
    description: "Purchased seats not yet assigned to a user (seats purchased minus seats claimed)."
    type: number
    sql: ${seats_purchased} - ${seats_claimed} ;;
    value_format_name: decimal_0
  }
}
