view: gemini_health {
  label: "Gemini Service Health"
  # One row per prompt, Model Armor verdict or connector failure over the last
  # 90 days, with each failure classified (Service, Capacity, Configuration,
  # Access, Policy, Cancelled, Other) and given a plain-language explanation
  # and next step. Only Service failures can make the status Down.
  derived_table: {
    datagroup_trigger: gemini_change_management_datagroup
    sql:
      SELECT * FROM (
      WITH events AS (
        SELECT
          CONCAT('prompt:', insert_id) AS row_key,
          insert_id AS event_id,
          event_ts,
          event_date,
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
          CAST(NULL AS STRING) AS integration,
          COALESCE(agent_display_name, agent_id) AS agent_name,
          CAST(NULL AS STRING) AS screened_content,
          CAST(NULL AS STRING) AS attribution_method,
          IFNULL(status_code, 0) != 0 AS is_failure
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
          AND is_user_prompt

        UNION ALL
        SELECT
          CONCAT('armor:', row_key),
          event_id,
          event_ts,
          event_date,
          app_name,
          LOWER(user_email),
          'Model Armor',
          CAST(NULL AS INT64),
          IF(is_match, COALESCE(INITCAP(REPLACE(category, '_', ' ')), 'Flagged'), NULL),
          CAST(NULL AS STRING),
          CAST(NULL AS STRING),
          screened_content,
          attribution_method,
          is_match
        FROM `@{gemini_project}.@{gemini_dataset}.ge_safety_events`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
          AND source = 'MODEL_ARMOR'

        UNION ALL
        SELECT
          CONCAT('connector:', insert_id),
          insert_id,
          event_ts,
          event_date,
          app_name,
          LOWER(user_email),
          'Connector',
          CAST(NULL AS INT64),
          COALESCE(error_category, 'Other'),
          COALESCE(REPLACE(INITCAP(REPLACE(connector_type, '_', ' ')), 'Mcp', 'MCP'), 'Unknown connector'),
          agent,
          CAST(NULL AS STRING),
          CAST(NULL AS STRING),
          TRUE
        FROM `@{gemini_project}.@{gemini_dataset}.ge_connector_activity`
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
      ),

      classified AS (
        SELECT
          events.*,
          CASE
            WHEN NOT is_failure THEN NULL
            WHEN signal = 'Model Armor' THEN 'Policy'
            WHEN signal = 'Prompt' THEN CASE
              WHEN status_code = 1 THEN 'Cancelled'
              WHEN status_code IN (3, 5, 9) THEN 'Configuration'
              WHEN status_code IN (7, 16) THEN 'Access'
              WHEN status_code = 8 THEN 'Capacity'
              WHEN status_code IN (4, 10, 13, 14) THEN 'Service'
              ELSE 'Other'
            END
            WHEN reason IN ('Authorisation or consent', 'Reconnect required', 'Permission denied') THEN 'Access'
            WHEN reason IN ('Download blocked', 'Unsupported query', 'Invalid request', 'Not found') THEN 'Configuration'
            WHEN reason = 'Rate limited' THEN 'Capacity'
            WHEN reason = 'Timeout' THEN 'Service'
            ELSE 'Other'
          END AS failure_class,
          CASE
            WHEN NOT is_failure THEN NULL
            WHEN signal = 'Model Armor' THEN 'Model Armor flagged a prompt or response against the template.'
            WHEN signal = 'Prompt' THEN CASE
              WHEN status_code = 1 THEN 'The request was cancelled, usually by the person or their browser.'
              WHEN status_code = 3 THEN 'The request was rejected as invalid, often an unsupported file or agent setting.'
              WHEN status_code = 4 THEN 'Gemini Enterprise took too long to answer.'
              WHEN status_code = 5 THEN 'A referenced agent, data store or session no longer exists.'
              WHEN status_code = 7 THEN 'The person or app lacks permission for what was requested.'
              WHEN status_code = 8 THEN 'The project hit a quota or rate limit.'
              WHEN status_code = 9 THEN 'The model or feature is not enabled for this project, such as Claude without billing overages or a model unavailable on a trial.'
              WHEN status_code = 10 THEN 'The request was interrupted before it finished.'
              WHEN status_code = 13 THEN 'Gemini Enterprise returned an internal error.'
              WHEN status_code = 14 THEN 'Gemini Enterprise was temporarily unavailable.'
              WHEN status_code = 16 THEN 'The request had no valid sign-in.'
              ELSE 'The request failed with an unclassified error.'
            END
            WHEN reason = 'Authorisation or consent' THEN 'The person has not authorised the connector, or their consent has expired.'
            WHEN reason = 'Reconnect required' THEN 'The connector sign-in expired.'
            WHEN reason = 'Permission denied' THEN 'The person cannot access the item in the connected system.'
            WHEN reason = 'Download blocked' THEN 'The connected system blocked a file download.'
            WHEN reason = 'Unsupported query' THEN 'The assistant asked the connector for something it does not support.'
            WHEN reason = 'Invalid request' THEN 'The connector rejected the request as invalid.'
            WHEN reason = 'Not found' THEN 'The item no longer exists, or the link is wrong.'
            WHEN reason = 'Rate limited' THEN 'The connected system rate-limited requests.'
            WHEN reason = 'Timeout' THEN 'The connected system did not respond in time.'
            ELSE 'The connector failed with an unclassified error.'
          END AS explanation,
          CASE
            WHEN NOT is_failure THEN NULL
            WHEN signal = 'Model Armor' THEN 'Review the Model Armor template if these look like false positives.'
            WHEN signal = 'Prompt' THEN CASE
              WHEN status_code = 1 THEN 'Usually no action needed.'
              WHEN status_code IN (3, 5) THEN 'Check the agents, data stores and file types involved.'
              WHEN status_code IN (4, 10, 13, 14) THEN 'Usually clears on retry. Check Google Cloud status if it persists.'
              WHEN status_code = 7 THEN "Check the person's licence and IAM roles on the app."
              WHEN status_code = 8 THEN 'Review quotas in the Cloud console and request an increase if sustained.'
              WHEN status_code = 9 THEN "Check the app's model settings and billing overages in the Gemini Enterprise console."
              WHEN status_code = 16 THEN 'Ask the person to sign in again. Check SSO if it is widespread.'
              ELSE 'Drill into the failures to find a pattern.'
            END
            WHEN reason IN ('Authorisation or consent', 'Reconnect required') THEN "Ask affected people to reconnect the integration. If many are affected, check the connector's OAuth setup."
            WHEN reason = 'Permission denied' THEN "Check the person's access in the connected system."
            WHEN reason = 'Download blocked' THEN 'Check download policies in the connected system.'
            WHEN reason IN ('Unsupported query', 'Invalid request') THEN 'Usually a connector limitation. Review if frequent.'
            WHEN reason = 'Not found' THEN 'Check for moved or deleted items.'
            WHEN reason = 'Rate limited' THEN 'Check API limits in the connected system.'
            WHEN reason = 'Timeout' THEN "Usually clears on retry. Check the connected system's status if it persists."
            ELSE 'Drill into the failures to find a pattern.'
          END AS next_step
        FROM events
      )

      SELECT classified.* REPLACE (COALESCE(person_identity.person_email, classified.user_email) AS user_email)
      FROM classified
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = classified.user_email
        AND classified.event_ts >= person_identity.valid_from
        AND classified.event_ts < person_identity.valid_to
      ) ;;
  }

  parameter: connector_breakdown {
    label: "Connector View"
    type: unquoted
    default_value: "integration"
    allowed_value: {
      label: "By integration"
      value: "integration"
    }
    allowed_value: {
      label: "By reason"
      value: "reason"
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
    description: "When it happened (UTC). Covers the last 90 days."
    type: time
    timeframes: [raw, time, hour, date, week, month]
    convert_tz: no
    sql: ${TABLE}.event_ts ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: user_email {
    label: "Person"
    description: "Blank when the log couldn't be matched to a person, which is common for connector errors."
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: signal {
    description: "Prompt, Connector or Model Armor."
    type: string
    sql: ${TABLE}.signal ;;
  }

  dimension: reason {
    description: "Failure reason, connector error category or Model Armor category. Blank for successful rows."
    type: string
    sql: ${TABLE}.reason ;;
  }

  dimension: failure_class {
    label: "Failure Type"
    description: "Service (timeouts, internal or unavailable), Capacity (quota or rate limit), Configuration, Access, Policy (Model Armor), Cancelled or Other. Only Service failures can make the status Down."
    type: string
    sql: ${TABLE}.failure_class ;;
  }

  dimension: explanation {
    description: "What the failure means, in plain language."
    type: string
    sql: ${TABLE}.explanation ;;
  }

  dimension: next_step {
    label: "Next Step"
    type: string
    sql: ${TABLE}.next_step ;;
  }

  dimension: integration {
    description: "Connector the error came from, such as Asana or Google Drive."
    type: string
    sql: ${TABLE}.integration ;;
  }

  dimension: connector_issue {
    label: "Connector Issue"
    description: "Integration and error reason together."
    type: string
    sql: IF(${TABLE}.signal = 'Connector', CONCAT(${TABLE}.integration, ': ', ${TABLE}.reason), NULL) ;;
  }

  dimension: connector_group {
    label: "Connector Group"
    description: "Integration or reason, following the Connector View filter."
    type: string
    sql: {% if connector_breakdown._parameter_value == 'reason' %}${TABLE}.reason{% else %}${TABLE}.integration{% endif %} ;;
  }

  dimension: agent_name {
    label: "Agent"
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: screened_content {
    description: "For Model Armor, whether a prompt or a response was screened."
    type: string
    sql: ${TABLE}.screened_content ;;
  }

  dimension: attribution_method {
    description: "For Model Armor, how the person was identified: log, trace, time_window (less certain) or unattributed."
    type: string
    sql: ${TABLE}.attribution_method ;;
  }

  dimension: is_failure {
    label: "Is Failure"
    description: "A failed prompt, a connector error or a Model Armor rejection."
    type: yesno
    sql: ${TABLE}.is_failure ;;
  }

  measure: prompts {
    description: "Prompts people sent interactively."
    type: count
    filters: [signal: "Prompt"]
  }

  measure: failed_prompts {
    label: "Failed Prompts"
    description: "Prompts that returned an error, so the person got no answer."
    type: count
    filters: [signal: "Prompt", is_failure: "yes"]
    drill_fields: [failure_detail*]
  }

  measure: service_failed_prompts {
    label: "Service-Side Failed Prompts"
    description: "Failed prompts caused by timeouts, internal errors, aborted requests or the service being unavailable."
    type: count
    filters: [signal: "Prompt", failure_class: "Service"]
    drill_fields: [failure_detail*]
  }

  measure: prompt_failure_rate {
    label: "Prompt Failure Rate"
    type: number
    sql: SAFE_DIVIDE(${failed_prompts}, NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
    drill_fields: [failure_detail*]
  }

  measure: service_failure_rate {
    label: "Service-Side Failure Rate"
    type: number
    sql: SAFE_DIVIDE(${service_failed_prompts}, NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: connector_errors {
    description: "Connector tool failures."
    type: count
    filters: [signal: "Connector"]
    drill_fields: [failure_detail*]
  }

  measure: connector_error_rate {
    label: "Connector Errors per Prompt"
    type: number
    sql: SAFE_DIVIDE(${connector_errors}, NULLIF(${prompts}, 0)) ;;
    value_format_name: percent_1
  }

  measure: armor_screened {
    label: "Model Armor Screened"
    description: "Distinct prompts and responses Model Armor screened."
    type: count_distinct
    sql: CASE WHEN ${signal} = 'Model Armor' THEN ${event_id} END ;;
  }

  measure: armor_rejections {
    label: "Model Armor Rejections"
    description: "Distinct prompts and responses Model Armor rejected."
    type: count_distinct
    sql: CASE WHEN ${signal} = 'Model Armor' AND ${is_failure} THEN ${event_id} END ;;
    drill_fields: [failure_detail*]
  }

  measure: armor_rejection_rate {
    label: "Model Armor Rejection Rate"
    type: number
    sql: SAFE_DIVIDE(${armor_rejections}, NULLIF(${armor_screened}, 0)) ;;
    value_format_name: percent_1
  }

  measure: total_errors {
    label: "Total Errors"
    description: "Failed prompts plus connector errors, combined. Model Armor rejections are counted separately."
    type: number
    sql: ${failed_prompts} + ${connector_errors} ;;
    drill_fields: [failure_detail*]
  }

  measure: people_affected {
    label: "People Affected"
    description: "Distinct identified people with a failed prompt or connector error. Errors that couldn't be matched to a person aren't counted."
    type: count_distinct
    sql: CASE WHEN ${is_failure} AND ${signal} != 'Model Armor' THEN ${TABLE}.user_email END ;;
    drill_fields: [user_email, total_errors, failed_prompts, connector_errors]
  }

  measure: unattributed_errors {
    label: "Unattributed Errors"
    description: "Failed prompts and connector errors that couldn't be matched to a person."
    type: number
    sql: COUNT(CASE WHEN ${is_failure} AND ${signal} != 'Model Armor' AND ${TABLE}.user_email IS NULL THEN 1 END) ;;
  }

  measure: last_error_time {
    label: "Last Error"
    description: "Most recent failure, in UTC."
    type: string
    sql: FORMAT_TIMESTAMP('%Y-%m-%d %H:%M', MAX(CASE WHEN ${is_failure} THEN ${TABLE}.event_ts END)) ;;
  }

  measure: first_event_time {
    hidden: yes
    type: string
    sql: FORMAT_TIMESTAMP('%d %b %Y', MIN(${TABLE}.event_ts)) ;;
  }

  measure: latest_event_time {
    hidden: yes
    type: string
    sql: FORMAT_TIMESTAMP('%d %b %Y, %H:%M UTC', MAX(${TABLE}.event_ts)) ;;
  }

  measure: health_status {
    label: "Health Status"
    description: "Unknown below the minimum prompt volume, Down when service-side failures pass the Down threshold, Degraded when prompt failures, connector errors or Model Armor rejections pass their thresholds, otherwise Healthy. Include the measures the card reads in the tile query."
    type: string
    sql: CASE
      WHEN ${prompts} < @{health_min_prompts} THEN 'Unknown'
      WHEN ${service_failure_rate} >= @{health_down_failure_rate} THEN 'Down'
      WHEN ${prompt_failure_rate} >= @{health_degraded_failure_rate}
        OR ${connector_error_rate} >= @{health_degraded_connector_rate}
        OR (${armor_screened} >= @{health_min_prompts} AND ${armor_rejection_rate} >= @{health_degraded_armor_rate})
        THEN 'Degraded'
      ELSE 'Healthy'
    END ;;
    html: {% assign deg = '@{health_degraded_failure_rate}' | plus: 0 %}{% assign con = '@{health_degraded_connector_rate}' | plus: 0 %}{% assign arm = '@{health_degraded_armor_rate}' | plus: 0 %}{% assign svc2 = service_failed_prompts._value | times: 2 %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 10px;line-height:1.4;white-space:normal;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;">Service status</div><div style="display:flex;align-items:center;gap:10px;margin-top:6px;"><span style="display:inline-block;width:14px;height:14px;border-radius:50%;background:{% if value == 'Healthy' %}#188038{% elsif value == 'Degraded' %}#F9AB00{% elsif value == 'Down' %}#D93025{% else %}#9AA0A6{% endif %};"></span><span style="font-size:30px;font-weight:600;color:#202124;">{{ value }}</span></div><div style="font-size:13px;color:#3c4043;margin-top:6px;">{% if value == 'Unknown' %}{% if prompts._value == 0 %}No prompts were recorded in this period, so health can't be judged.{% else %}Only {{ prompts._rendered_value }} prompts in this period. At least @{health_min_prompts} are needed to judge health; widen the date range.{% endif %}{% elsif value == 'Down' %}{{ service_failure_rate._rendered_value }} of prompts failed with service-side errors (timeouts, internal errors or the service unavailable). Check Google Cloud status.{% elsif value == 'Degraded' %}{% if prompt_failure_rate._value >= deg %}{{ prompt_failure_rate._rendered_value }} of prompts failed ({{ failed_prompts._rendered_value }} of {{ prompts._rendered_value }}). {% if svc2 < failed_prompts._value %}Most are configuration or access problems, so the service itself is responding. {% else %}Most are service-side errors. {% endif %}{% endif %}{% if connector_error_rate._value >= con %}Connectors failed {{ connector_errors._rendered_value }} times. {% endif %}{% if armor_screened._value >= @{health_min_prompts} and armor_rejection_rate._value >= arm %}Model Armor rejected {{ armor_rejection_rate._rendered_value }} of screened content.{% endif %}{% else %}Failure rates are within thresholds{% if failed_prompts._value > 0 %}; {{ failed_prompts._rendered_value }} prompts failed ({{ prompt_failure_rate._rendered_value }}){% endif %}.{% endif %}</div><div style="font-size:11px;color:#5f6368;margin-top:8px;padding-top:6px;border-top:1px solid #F1F3F4;">Degraded at {{ deg | times: 100 | round }}% failed prompts, {{ con | times: 100 | round }}% connector errors per prompt or {{ arm | times: 100 | round }}% Model Armor rejections. Down at {{ '@{health_down_failure_rate}' | times: 100 | round }}% service-side failures. Unknown under @{health_min_prompts} prompts.</div><div style="font-size:11px;color:#5f6368;margin-top:2px;">Data from {{ first_event_time._value }} to {{ latest_event_time._value }}</div></div> ;;
  }

  measure: failed_prompts_card {
    hidden: yes
    description: "Prompt failure rate card. Include failed_prompts and prompts in the tile query."
    type: number
    sql: ${prompt_failure_rate} ;;
    value_format_name: percent_0
    html: {% if prompts._value == 0 %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;"><div style="font-size:30px;font-weight:600;color:#9AA0A6;">No data</div><div style="font-size:13px;color:#5f6368;">No prompts in this period</div></div>{% else %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;"><div style="font-size:30px;font-weight:600;color:#C5221F;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;">Failed prompts</div><div style="font-size:12px;color:#5f6368;">{{ failed_prompts._rendered_value }} of {{ prompts._rendered_value }} prompts</div></div>{% endif %} ;;
  }

  measure: people_affected_card {
    hidden: yes
    description: "People affected card. Include unattributed_errors in the tile query."
    type: number
    sql: ${people_affected} ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;"><div style="font-size:30px;font-weight:600;color:#202124;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;">People affected</div><div style="font-size:12px;color:#5f6368;">{% if unattributed_errors._value > 0 %}Plus {{ unattributed_errors._rendered_value }} errors not matched to a person{% else %}With a failed prompt or connector error{% endif %}</div></div> ;;
  }

  measure: total_errors_card {
    hidden: yes
    description: "Total errors card. Include failed_prompts and connector_errors in the tile query."
    type: number
    sql: ${total_errors} ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;"><div style="font-size:30px;font-weight:600;color:#202124;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;">Total errors</div><div style="font-size:12px;color:#5f6368;">{{ failed_prompts._rendered_value }} failed prompts + {{ connector_errors._rendered_value }} connector errors</div></div> ;;
  }

  measure: armor_card {
    hidden: yes
    description: "Model Armor card. Include armor_screened and armor_rejection_rate in the tile query."
    type: number
    sql: ${armor_rejections} ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:4px 8px;">{% if armor_screened._value == 0 %}<div style="font-size:30px;font-weight:600;color:#9AA0A6;">No data</div><div style="font-size:14px;font-weight:600;color:#202124;">Model Armor</div><div style="font-size:12px;color:#5f6368;">No screening recorded in this period</div>{% else %}<div style="font-size:30px;font-weight:600;color:#202124;">{{ rendered_value }}</div><div style="font-size:14px;font-weight:600;color:#202124;">Model Armor rejections</div><div style="font-size:12px;color:#5f6368;">{{ armor_rejection_rate._rendered_value }} of {{ armor_screened._rendered_value }} screened</div>{% endif %}</div> ;;
  }

  set: failure_detail {
    fields: [event_time, user_email, signal, failure_class, integration, reason, explanation, agent_name, app_name]
  }
}
