view: gemini_health_issues {
  label: "Gemini Service Health Issues"
  # One row per issue (signal, integration and reason) in the filtered period,
  # with its share of that signal's failures. The card lists each signal's top
  # issue and any issue with 10% or more of its signal. Not persisted: the templated
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
          AND {% condition agent_filter %} health.agent_name {% endcondition %}
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

  measure: needs_attention_card {
    hidden: yes
    label: "Needs Attention"
    description: "The largest prompt, connector and Model Armor issues as an actionable list."
    type: string
    sql: ARRAY_TO_STRING(ARRAY_AGG(
      IF(${TABLE}.signal_rank = 1 OR SAFE_DIVIDE(${TABLE}.failures, ${TABLE}.signal_failures) >= 0.1, CONCAT(
        ${TABLE}.signal, '~',
        ${issue}, '~',
        IFNULL(${TABLE}.failure_class, 'Other'), '~',
        CAST(${TABLE}.failures AS STRING), '~',
        CAST(${TABLE}.signal_failures AS STRING), '~',
        FORMAT('%.1f', 100 * SAFE_DIVIDE(${TABLE}.failures, ${TABLE}.signal_failures)), '~',
        CAST(${TABLE}.people AS STRING), '~',
        IFNULL(${TABLE}.explanation, '-'), '~',
        IFNULL(${TABLE}.next_step, '-'), '~',
        IFNULL(${TABLE}.reason, '-'), '~',
        IFNULL(${TABLE}.integration, '-')
      ), NULL)
      IGNORE NULLS ORDER BY ${TABLE}.signal_rank, ${TABLE}.failures DESC LIMIT 4), '^') ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 8px;line-height:1.4;white-space:normal;">{% assign rows = value | split: "^" %}<div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;margin-bottom:4px;">Needs attention{% if value != blank %}: {{ rows.size }} main issues{% endif %}</div>{% if value == blank %}<div style="font-size:14px;color:#188038;padding:8px 0;">No failures in this period.</div>{% endif %}{% for r in rows %}{% assign c = r | split: "~" %}<div style="display:flex;gap:16px;align-items:flex-start;padding:8px 0;border-top:1px solid #F1F3F4;"><div style="flex:none;width:150px;"><div style="font-size:24px;font-weight:600;color:#202124;line-height:1.1;">{{ c[3] }}<span style="font-size:13px;font-weight:500;color:#5f6368;"> / {{ c[4] }}</span></div><div style="font-size:12px;color:#5f6368;">{{ c[5] }}% of {% if c[0] == 'Prompt' %}failed prompts{% elsif c[0] == 'Connector' %}connector errors{% else %}Model Armor rejections{% endif %}</div></div><div style="flex:1;min-width:0;"><div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;"><span style="font-size:15px;font-weight:600;color:#202124;">{{ c[1] }}</span><span style="font-size:11px;font-weight:600;padding:1px 8px;border-radius:10px;{% if c[2] == 'Service' %}background:#FCE8E6;color:#C5221F;{% elsif c[2] == 'Capacity' %}background:#FEF7E0;color:#B06000;{% elsif c[2] == 'Policy' %}background:#F1F3F4;color:#3C4043;{% else %}background:#E8F0FE;color:#1967D2;{% endif %}">{{ c[2] }}</span><span style="font-size:12px;color:#5f6368;">{% if c[6] == '0' %}People not identified{% elsif c[6] == '1' %}1 person affected{% else %}{{ c[6] }} people affected{% endif %}</span></div><div style="font-size:13px;color:#3c4043;margin-top:2px;">{{ c[7] }}</div><div style="font-size:12px;color:#5f6368;margin-top:2px;"><b style="color:#202124;">Next step:</b> {{ c[8] }} <a href="/dashboards/gemini_enterprise::gemini_ai_health?Reason={{ c[9] | url_encode }}{% if c[10] != '-' %}&Integration={{ c[10] | url_encode }}{% endif %}" style="color:#1a73e8;text-decoration:none;font-weight:600;margin-left:6px;">Investigate</a></div></div></div>{% endfor %}</div> ;;
  }
}
