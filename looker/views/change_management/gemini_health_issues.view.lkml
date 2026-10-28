view: gemini_health_issues {
  label: "Gemini Service Health Issues"
  # One row per issue (signal, integration and reason) in the filtered period,
  # with its share of that signal's failures. The card shows three issues: each
  # signal's largest first, then the next largest. Not persisted: the templated
  # filters below take the Service Health dashboard filters.
  derived_table: {
    sql:
      WITH scoped AS (
        SELECT health.*
        FROM ${gemini_health.SQL_TABLE_NAME} AS health
        LEFT JOIN ${user_org_unit.SQL_TABLE_NAME} AS org
          ON org.user_email = health.user_email
        WHERE {% condition date_filter %} health.event_ts {% endcondition %}
          AND {% condition app_filter %} health.app_name {% endcondition %}
          AND {% condition department_filter %} COALESCE(org.department, 'Unknown') {% endcondition %}
          AND {% condition person_filter %} health.user_email {% endcondition %}
          AND {% condition agent_filter %} COALESCE(health.agent_name, 'Not recorded') {% endcondition %}
          AND {% condition integration_filter %} health.integration {% endcondition %}
          AND {% condition reason_filter %} health.reason {% endcondition %}
      ),

      totals AS (
        SELECT signal, COUNT(DISTINCT IF(is_failure, event_id, NULL)) AS signal_failures
        FROM scoped
        GROUP BY signal
      ),

      issues AS (
        SELECT
          signal,
          integration,
          reason,
          ANY_VALUE(failure_class) AS failure_class,
          ANY_VALUE(explanation) AS explanation,
          ANY_VALUE(next_step) AS next_step,
          COUNT(DISTINCT event_id) AS failures,
          COUNT(DISTINCT user_email) AS people,
          MAX(event_ts) AS last_seen
        FROM scoped
        WHERE is_failure
        GROUP BY signal, integration, reason
      )

      SELECT
        issues.*,
        totals.signal_failures,
        ROW_NUMBER() OVER (PARTITION BY issues.signal ORDER BY issues.failures DESC) AS signal_rank
      FROM issues
      JOIN totals USING (signal) ;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: app_filter {
    type: string
    suggest_explore: gemini_health
    suggest_dimension: gemini_health.app_name
  }

  filter: department_filter {
    type: string
    suggest_explore: gemini_health
    suggest_dimension: user_org_unit.department
  }

  filter: person_filter {
    type: string
    required_access_grants: [can_see_individuals]
  }

  filter: agent_filter {
    type: string
    suggest_explore: gemini_health
    suggest_dimension: gemini_health.agent_name
  }

  filter: integration_filter {
    type: string
    suggest_explore: gemini_health
    suggest_dimension: gemini_health.integration
  }

  filter: reason_filter {
    type: string
    suggest_explore: gemini_health
    suggest_dimension: gemini_health.reason
  }

  dimension: issue_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.signal, '|', IFNULL(${TABLE}.integration, ''), '|', IFNULL(${TABLE}.reason, '')) ;;
  }

  dimension: signal {
    type: string
    sql: ${TABLE}.signal ;;
  }

  dimension: issue {
    description: "Reason, with the integration for connector errors."
    type: string
    sql: CASE
      WHEN ${TABLE}.signal = 'Connector' THEN CONCAT(${TABLE}.integration, ': ', ${TABLE}.reason)
      WHEN ${TABLE}.signal = 'Model Armor' THEN CONCAT('Model Armor: ', ${TABLE}.reason)
      ELSE ${TABLE}.reason
    END ;;
  }

  dimension: failure_class {
    label: "Failure Type"
    type: string
    sql: ${TABLE}.failure_class ;;
  }

  dimension: explanation {
    type: string
    sql: ${TABLE}.explanation ;;
  }

  dimension: next_step {
    type: string
    sql: ${TABLE}.next_step ;;
  }

  dimension: failures {
    type: number
    sql: ${TABLE}.failures ;;
  }

  dimension: share_of_signal {
    description: "This issue's share of its signal's failures, such as 72.5% of failed prompts."
    type: number
    sql: SAFE_DIVIDE(${TABLE}.failures, ${TABLE}.signal_failures) ;;
    value_format_name: percent_1
  }

  measure: issue_count {
    type: count
  }

  dimension: headline {
    description: "Short issue name, such as Asana access or Project not enabled."
    type: string
    sql: CASE
      WHEN ${TABLE}.signal = 'Connector' THEN CONCAT(${TABLE}.integration, ' ', LOWER(IFNULL(${TABLE}.failure_class, 'other')))
      WHEN ${TABLE}.signal = 'Model Armor' THEN 'Model Armor'
      ELSE ${TABLE}.reason
    END ;;
  }

  measure: needs_attention_card {
    hidden: yes
    label: "Needs Attention"
    description: "The three largest issues as cards: each signal's top issue first, then the next largest."
    type: string
    sql: ARRAY_TO_STRING(ARRAY_AGG(
      CONCAT(
        ${TABLE}.signal, '~',
        ${headline}, '~',
        IFNULL(${TABLE}.failure_class, 'Other'), '~',
        CAST(${TABLE}.failures AS STRING), '~',
        CAST(${TABLE}.signal_failures AS STRING), '~',
        CAST(${TABLE}.people AS STRING), '~',
        IFNULL(${TABLE}.explanation, '-'), '~',
        IFNULL(${TABLE}.next_step, '-'), '~',
        IFNULL(${TABLE}.reason, '-'), '~',
        IFNULL(${TABLE}.integration, '-'), '~',
        IF(${TABLE}.signal = 'Prompt', IFNULL(${TABLE}.failure_class, 'Other'), IFNULL(${TABLE}.reason, '-'))
      )
      ORDER BY IF(${TABLE}.signal_rank = 1, 0, 1), ${TABLE}.failures DESC LIMIT 3), '^') ;;
    html: {% assign rows = value | split: "^" %}{% assign date = _filters['gemini_health_issues.date_filter'] %}<div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;letter-spacing:normal;word-spacing:normal;text-align:left;white-space:normal;padding:2px 0;line-height:1.4;">{% if value == blank %}<div style="letter-spacing:normal;word-spacing:normal;font-size:14px;color:#188038;padding:12px 4px;">No failures in the selected period.</div>{% else %}<table style="width:100%;table-layout:fixed;border-collapse:separate;border-spacing:10px 0;"><tr>{% for r in rows %}{% assign c = r | split: "~" %}<td style="vertical-align:top;border:1px solid #DADCE0;border-radius:8px;padding:10px 12px;"><div style="letter-spacing:normal;word-spacing:normal;font-size:11px;font-weight:700;text-transform:uppercase;color:#5F6368;">{{ c[0] }} &middot; {{ c[2] }} &middot; <span style="text-transform:none;font-weight:500;">{% if c[5] == '0' %}no person linked{% elsif c[5] == '1' %}1 person{% else %}{{ c[5] }} people{% endif %}</span></div><div style="letter-spacing:normal;word-spacing:normal;font-size:16px;font-weight:600;color:#202124;margin-top:4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ c[1] }}</div><div style="letter-spacing:normal;word-spacing:normal;margin-top:2px;"><span style="letter-spacing:normal;word-spacing:normal;font-size:30px;font-weight:600;color:#202124;line-height:1.15;">{{ c[3] }}</span>&nbsp;<span style="letter-spacing:normal;word-spacing:normal;font-size:12px;color:#5F6368;">of {{ c[4] }} {% if c[0] == 'Prompt' %}prompt failures{% elsif c[0] == 'Connector' %}connector errors{% else %}rejections{% endif %}</span></div><div style="letter-spacing:normal;word-spacing:normal;font-size:13px;font-weight:500;color:#3C4043;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ c[10] }}</div><div style="letter-spacing:normal;word-spacing:normal;font-size:12px;color:#5F6368;margin-top:4px;height:34px;overflow:hidden;">{{ c[7] }}</div><div style="letter-spacing:normal;word-spacing:normal;margin-top:6px;"><a href="/dashboards/gemini_enterprise::gemini_ai_health?Reason={{ c[8] | url_encode }}{% if c[9] != '-' %}&Integration={{ c[9] | url_encode }}{% endif %}{% if date != blank %}&Date={{ date | url_encode }}{% endif %}" style="letter-spacing:normal;word-spacing:normal;font-size:12px;font-weight:600;color:#1A73E8;text-decoration:none;">Investigate &rarr;</a></div></td>{% endfor %}</tr></table>{% endif %}</div> ;;
  }
}
