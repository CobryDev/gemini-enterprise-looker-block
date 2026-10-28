view: gemini_health {
  label: "Gemini Service Health"
  # Unified reliability stream for the Service Health dashboard. Prompt errors
  # and connector failures are service health signals; Model Armor rejections
  # are policy/safety signals and can only move the headline status to Degraded.
  derived_table: {
    datagroup_trigger: gemini_change_management_datagroup
    sql:
      SELECT events.* REPLACE (COALESCE(person_identity.person_email, LOWER(events.user_email)) AS user_email)
      FROM (
        SELECT
          CONCAT('prompt:', insert_id) AS row_key,
          insert_id AS event_id,
          event_ts,
          event_date,
          project_id,
          app_name,
          LOWER(user_email) AS user_email,
          'Prompt' AS signal,
          status_code,
          CASE
            WHEN IFNULL(status_code, 0) = 0 THEN NULL
            WHEN status_code = 1 THEN 'Cancelled'
            WHEN status_code = 3 THEN 'Invalid request'
            WHEN status_code = 4 THEN 'Timed out'
            WHEN status_code = 5 THEN 'Not found'
            WHEN status_code = 7 THEN 'Permission denied'
            WHEN status_code = 8 THEN 'Quota or rate limit'
            WHEN status_code = 9 THEN 'Not enabled for this project'
            WHEN status_code = 10 THEN 'Aborted'
            WHEN status_code = 13 THEN 'Internal error'
            WHEN status_code = 14 THEN 'Service unavailable'
            WHEN status_code = 16 THEN 'Not signed in'
            ELSE CONCAT('Error code ', CAST(status_code AS STRING))
          END AS reason,
          CAST(NULL AS STRING) AS detail,
          COALESCE(agent_display_name, agent_id) AS agent_name,
          CAST(NULL AS STRING) AS screened_content,
          CAST(NULL AS STRING) AS attribution_method,
          IFNULL(status_code, 0) != 0 AS is_failure,
          is_blocked,
          answer_state
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 35 DAY)
          AND is_user_prompt

        UNION ALL
        SELECT
          CONCAT('armor:', row_key) AS row_key,
          event_id,
          event_ts,
          event_date,
          project_id,
          app_name,
          LOWER(user_email) AS user_email,
          'Model Armor' AS signal,
          CAST(NULL AS INT64) AS status_code,
          category AS reason,
          screened_content AS detail,
          CAST(NULL AS STRING) AS agent_name,
          screened_content,
          attribution_method,
          is_match AS is_failure,
          FALSE AS is_blocked,
          CAST(NULL AS STRING) AS answer_state
        FROM `@{gemini_project}.@{gemini_dataset}.ge_safety_events`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 35 DAY)
          AND source = 'MODEL_ARMOR'

        UNION ALL
        SELECT
          CONCAT('connector:', insert_id) AS row_key,
          insert_id AS event_id,
          event_ts,
          event_date,
          project_id,
          app_name,
          LOWER(user_email) AS user_email,
          'Connector' AS signal,
          CAST(NULL AS INT64) AS status_code,
          error_category AS reason,
          connector_type AS detail,
          agent AS agent_name,
          CAST(NULL AS STRING) AS screened_content,
          CAST(NULL AS STRING) AS attribution_method,
          TRUE AS is_failure,
          FALSE AS is_blocked,
          CAST(NULL AS STRING) AS answer_state
        FROM `@{gemini_project}.@{gemini_dataset}.ge_connector_activity`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 35 DAY)
      ) AS events
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = LOWER(events.user_email)
        AND events.event_ts >= person_identity.valid_from
        AND events.event_ts < person_identity.valid_to ;;
  }

  parameter: health_window {
    label: "Window"
    type: unquoted
    default_value: "1"
    allowed_value: {
      label: "Last day"
      value: "1"
    }
    allowed_value: {
      label: "Last week"
      value: "7"
    }
    allowed_value: {
      label: "Last month"
      value: "30"
    }
  }

  dimension: row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.row_key ;;
  }

  dimension: event_id {
    hidden: yes
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension_group: event {
    label: "Event"
    type: time
    timeframes: [raw, date, week, month]
    convert_tz: no
    sql: ${TABLE}.event_ts ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: user_email {
    label: "User"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: signal {
    description: "Health signal: prompt, Model Armor or connector."
    type: string
    sql: ${TABLE}.signal ;;
  }

  dimension: reason {
    description: "Failure reason, Model Armor category or connector error category."
    type: string
    sql: COALESCE(${TABLE}.reason, '(not categorised)') ;;
  }

  dimension: detail {
    label: "Error Detail"
    description: "Additional non-sensitive detail: prompt failure cause, screened content or connector type."
    type: string
    sql: COALESCE(${TABLE}.detail, '(not recorded)') ;;
  }

  dimension: agent_name {
    label: "Agent"
    type: string
    sql: COALESCE(${TABLE}.agent_name, '(not recorded)') ;;
  }

  dimension: screened_content {
    description: "For Model Armor, whether the screened content was a prompt or response."
    type: string
    sql: ${TABLE}.screened_content ;;
  }

  dimension: attribution_method {
    description: "For Model Armor, how the user was attributed: log, trace, time_window or unattributed."
    type: string
    sql: ${TABLE}.attribution_method ;;
  }

  dimension: is_failure {
    label: "Is Health Event"
    type: yesno
    sql: ${TABLE}.is_failure ;;
  }

  dimension: outcome {
    label: "Prompt Outcome"
    description: "Prompt result for prompt rows. Non-prompt health rows are labelled by signal."
    type: string
    sql: CASE
      WHEN ${TABLE}.signal = 'Connector' THEN 'Connector error'
      WHEN ${TABLE}.signal = 'Model Armor' AND ${TABLE}.is_failure THEN 'Model Armor rejection'
      WHEN ${TABLE}.signal = 'Model Armor' THEN 'Model Armor pass'
      WHEN IFNULL(${TABLE}.status_code, 0) != 0 THEN 'Failed'
      WHEN ${TABLE}.is_blocked THEN 'Blocked'
      WHEN ${TABLE}.answer_state = 'SUCCEEDED' THEN 'Answered'
      ELSE 'No answer recorded'
    END ;;
  }

  measure: events {
    type: count
    drill_fields: [event_date, signal, user_email, app_name, reason, detail, agent_name]
  }

  measure: prompts {
    description: "Prompts users sent interactively."
    type: count
    filters: [signal: "Prompt"]
  }

  measure: failed_prompts {
    label: "Failed Prompts"
    description: "Prompts that returned an error, so the person got no answer."
    type: count
    filters: [signal: "Prompt", is_failure: "yes"]
    drill_fields: [event_date, user_email, app_name, reason, detail, agent_name]
  }

  measure: successful_prompts {
    hidden: yes
    type: count
    filters: [signal: "Prompt", is_failure: "no"]
  }

  measure: prompt_failure_rate {
    label: "Prompt Failure Rate"
    description: "Failed prompts divided by all prompts."
    type: number
    sql: SAFE_DIVIDE(${failed_prompts}, NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: armor_screened {
    label: "Model Armor Screened"
    description: "Distinct prompts or responses screened by Model Armor."
    type: count_distinct
    sql: CASE WHEN ${signal} = 'Model Armor' THEN ${event_id} END ;;
  }

  measure: armor_rejections {
    label: "Model Armor Rejections"
    description: "Distinct prompts or responses rejected by Model Armor."
    type: count_distinct
    sql: CASE WHEN ${signal} = 'Model Armor' AND ${is_failure} THEN ${event_id} END ;;
    drill_fields: [event_date, user_email, app_name, reason, detail, attribution_method]
  }

  measure: armor_rejection_rate {
    label: "Model Armor Rejection Rate"
    type: number
    sql: SAFE_DIVIDE(${armor_rejections}, NULLIF(${armor_screened}, 0)) ;;
    value_format_name: percent_1
  }

  measure: connector_errors {
    description: "Connector tool failures."
    type: count
    filters: [signal: "Connector"]
    drill_fields: [event_date, user_email, app_name, reason, detail, agent_name]
  }

  measure: connector_error_rate {
    label: "Connector Errors / Prompts"
    description: "Connector failures divided by prompts in the same window."
    type: number
    sql: SAFE_DIVIDE(${connector_errors}, NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: total_errors {
    description: "Service errors: failed prompts plus connector failures."
    type: number
    sql: ${failed_prompts} + ${connector_errors} ;;
    drill_fields: [event_date, signal, user_email, app_name, reason, detail, agent_name]
  }

  measure: affected_events {
    label: "Total Health Events"
    description: "Failed prompts, connector failures and Model Armor rejections."
    type: number
    sql: ${failed_prompts} + ${connector_errors} + ${armor_rejections} ;;
    drill_fields: [event_date, signal, user_email, app_name, reason, detail, agent_name]
  }

  measure: people_affected {
    label: "People Affected"
    description: "Distinct people with a failed prompt, connector error or Model Armor rejection."
    type: count_distinct
    sql: CASE WHEN ${is_failure} THEN ${user_email} END ;;
    drill_fields: [user_email, affected_events, failed_prompts, connector_errors, armor_rejections]
  }

  measure: last_error_time {
    label: "Last Error"
    type: date_time
    sql: MAX(CASE WHEN ${is_failure} THEN ${TABLE}.event_ts END) ;;
  }

  measure: health_status {
    label: "Health Status"
    type: string
    sql: CASE
      WHEN ${prompts} >= @{health_min_prompts}
        AND ${prompt_failure_rate} >= @{health_down_failure_rate}
        THEN 'Down'
      WHEN ${prompts} >= 5
        AND ${failed_prompts} = ${prompts}
        THEN 'Down'
      WHEN ${prompt_failure_rate} >= @{health_degraded_failure_rate}
        THEN 'Degraded'
      WHEN ${prompts} < @{health_min_prompts}
        AND ${failed_prompts} >= 3
        THEN 'Degraded'
      WHEN ${connector_error_rate} >= @{health_degraded_connector_rate}
        THEN 'Degraded'
      WHEN ${armor_screened} >= @{health_min_prompts}
        AND ${armor_rejection_rate} >= @{health_degraded_armor_rate}
        THEN 'Degraded'
      ELSE 'Healthy'
    END ;;
  }

  measure: health_status_card {
    hidden: yes
    label: "Health Status Card"
    type: string
    sql: CONCAT(
      ${health_status}, '^',
      CASE
        WHEN ${prompts} = 0 THEN 'No prompts in window'
        WHEN ${health_status} = 'Down' AND ${failed_prompts} = ${prompts}
          THEN 'All prompts failed'
        WHEN ${health_status} = 'Down'
          THEN CONCAT('Prompt failure rate is ', CAST(ROUND(100 * ${prompt_failure_rate}, 1) AS STRING), '%')
        WHEN ${prompt_failure_rate} >= @{health_degraded_failure_rate}
          THEN CONCAT('Prompt failure rate is ', CAST(ROUND(100 * ${prompt_failure_rate}, 1) AS STRING), '%')
        WHEN ${prompts} < @{health_min_prompts} AND ${failed_prompts} >= 3
          THEN CONCAT(CAST(${failed_prompts} AS STRING), ' failed prompts in a low-volume window')
        WHEN ${connector_error_rate} >= @{health_degraded_connector_rate}
          THEN CONCAT('Connector errors equal ', CAST(ROUND(100 * ${connector_error_rate}, 1) AS STRING), '% of prompts')
        WHEN ${armor_screened} >= @{health_min_prompts}
          AND ${armor_rejection_rate} >= @{health_degraded_armor_rate}
          THEN CONCAT('Model Armor rejection rate is ', CAST(ROUND(100 * ${armor_rejection_rate}, 1) AS STRING), '%')
        ELSE 'No threshold breached'
      END, '^',
      IFNULL(FORMAT_TIMESTAMP('%d %b %Y, %H:%M UTC', MAX(${TABLE}.event_ts)), 'No data'), '^',
      CAST(${failed_prompts} AS STRING), '^',
      CAST(${connector_errors} AS STRING), '^',
      CAST(${armor_rejections} AS STRING), '^',
      CAST(${people_affected} AS STRING)
    ) ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:6px 10px;line-height:1.35;white-space:normal;">{% assign c = value | split: "^" %}<div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;">Gemini health</div><div style="display:flex;align-items:center;gap:10px;margin-top:8px;"><span style="display:inline-block;width:14px;height:14px;border-radius:50%;background:{% if c[0] == 'Healthy' %}#188038{% elsif c[0] == 'Degraded' %}#F9AB00{% else %}#D93025{% endif %};"></span><span style="font-size:32px;font-weight:600;color:#202124;">{{ c[0] }}</span></div><div style="font-size:14px;color:#3c4043;margin-top:4px;">{{ c[1] }}</div><div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:12px;padding-top:10px;border-top:1px solid #F1F3F4;font-size:12px;color:#5f6368;"><span><b style="color:#202124;">{{ c[3] }}</b> failed prompts</span><span><b style="color:#202124;">{{ c[4] }}</b> connector errors</span><span><b style="color:#202124;">{{ c[5] }}</b> Model Armor rejections</span><span><b style="color:#202124;">{{ c[6] }}</b> people affected</span></div><div style="font-size:12px;color:#5f6368;margin-top:8px;">Data to {{ c[2] }}. Model Armor can degrade this status but cannot make it down.</div></div> ;;
  }
}
