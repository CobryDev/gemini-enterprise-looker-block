view: data_state {
  label: "Data State"
  # Compact status rows used by dashboards to distinguish missing setup,
  # empty sources, short history and genuine zero activity.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH source_status AS (
        SELECT
          table_id AS feature,
          status,
          row_count,
          last_modified,
          next_step
        FROM ${setup_health_tables.SQL_TABLE_NAME}
      ),

      workspace_status AS (
        SELECT
          'workspace_export' AS feature,
          status,
          row_count,
          last_modified,
          next_step
        FROM ${setup_health_workspace.SQL_TABLE_NAME}
      ),

      activity_history AS (
        SELECT
          MIN(event_date) AS first_event_date,
          COUNTIF(ai_actions > 0) AS action_rows,
          SUM(ai_actions) AS ai_actions,
          SUM(IF(LOWER(feature) IN ('unspecified', 'unknown'), ai_actions, 0)) AS unclassified_actions
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
      ),

      cohort_history AS (
        SELECT COUNT(DISTINCT week_end) AS completed_weeks
        FROM ${ai_user_cohort_weekly.SQL_TABLE_NAME}
      )

      SELECT 1 AS sort_order, 'Core Gemini Enterprise logs' AS feature,
        CASE
          WHEN status = 'Missing' THEN 'Not configured'
          WHEN status = 'Empty' THEN 'No records'
          WHEN status = 'Stale' THEN 'Stale'
          ELSE 'OK'
        END AS state,
        CASE
          WHEN status IN ('Missing', 'Empty', 'Stale') THEN next_step
          ELSE 'Gemini Enterprise log pipeline is available.'
        END AS message,
        CASE WHEN status IN ('Missing', 'Empty', 'Stale') THEN 'Attention' ELSE 'OK' END AS severity
      FROM source_status
      WHERE feature = 'ge_user_activity'

      UNION ALL
      SELECT 2, 'Workspace Gemini export',
        CASE
          WHEN status = 'Not configured' THEN 'Not configured'
          WHEN status IN ('Missing', 'Empty') THEN 'No records'
          WHEN status = 'No Gemini events' THEN 'Zero activity'
          WHEN status = 'Stale' THEN 'Stale'
          ELSE 'OK'
        END,
        CASE
          WHEN status = 'OK' THEN 'Workspace export is available and contains Gemini events.'
          ELSE next_step
        END,
        CASE WHEN status IN ('OK', 'Not configured') THEN 'OK' ELSE 'Attention' END
      FROM workspace_status

      UNION ALL
      SELECT 3, 'Cohort movement',
        CASE
          WHEN completed_weeks = 0 THEN 'No records'
          WHEN completed_weeks < 8 THEN 'Insufficient history'
          ELSE 'OK'
        END,
        CASE
          WHEN completed_weeks = 0 THEN 'No cohort rows yet. They appear after AI activity, Workspace presence or licences enter the population.'
          WHEN completed_weeks < 8 THEN CONCAT('Cohort movement has ', CAST(completed_weeks AS STRING), ' completed weeks. Show movement carefully until at least 8 weeks are available.')
          ELSE 'Enough completed weeks are available for cohort movement.'
        END,
        CASE WHEN completed_weeks < 8 THEN 'Attention' ELSE 'OK' END
      FROM cohort_history

      UNION ALL
      SELECT 4, 'Retention',
        CASE
          WHEN first_event_date IS NULL THEN 'No records'
          WHEN DATE_DIFF(CURRENT_DATE(), first_event_date, DAY) < 56 THEN 'Insufficient history'
          ELSE 'OK'
        END,
        CASE
          WHEN first_event_date IS NULL THEN 'No AI activity rows are available for retention.'
          WHEN DATE_DIFF(CURRENT_DATE(), first_event_date, DAY) < 56 THEN CONCAT('Retention needs two 28-day windows. Tracking began ', CAST(first_event_date AS STRING), '.')
          ELSE 'Two 28-day windows are available for retention.'
        END,
        CASE WHEN first_event_date IS NULL OR DATE_DIFF(CURRENT_DATE(), first_event_date, DAY) < 56 THEN 'Attention' ELSE 'OK' END
      FROM activity_history

      UNION ALL
      SELECT 5, 'Use-case classification',
        CASE
          WHEN IFNULL(ai_actions, 0) = 0 THEN 'Zero activity'
          WHEN SAFE_DIVIDE(unclassified_actions, NULLIF(ai_actions, 0)) > 0.25 THEN 'Needs classification'
          ELSE 'OK'
        END,
        CASE
          WHEN IFNULL(ai_actions, 0) = 0 THEN 'No AI actions are available to classify.'
          WHEN SAFE_DIVIDE(unclassified_actions, NULLIF(ai_actions, 0)) > 0.25 THEN CONCAT(CAST(ROUND(SAFE_DIVIDE(unclassified_actions, ai_actions) * 100) AS STRING), '% of AI actions are Unclassified. Investigate feature mapping and Workspace event sources.')
          ELSE 'Use-case classification coverage is healthy.'
        END,
        CASE WHEN IFNULL(ai_actions, 0) = 0 OR SAFE_DIVIDE(unclassified_actions, NULLIF(ai_actions, 0)) > 0.25 THEN 'Attention' ELSE 'OK' END
      FROM activity_history ;;
  }

  dimension: feature {
    primary_key: yes
    type: string
    sql: ${TABLE}.feature ;;
    order_by_field: sort_order
  }

  dimension: sort_order {
    hidden: yes
    type: number
    sql: ${TABLE}.sort_order ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    html: {% if value == 'OK' %}<span style="color:#188038">{{ value }}</span>{% elsif value == 'Not configured' %}<span style="color:#5f6368">{{ value }}</span>{% else %}<span style="color:#d93025;font-weight:bold">{{ value }}</span>{% endif %} ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}.message ;;
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.severity ;;
  }

  measure: checks {
    type: count
  }

  measure: attention_checks {
    label: "Data Checks Needing Attention"
    type: count
    filters: [severity: "Attention"]
  }

  measure: data_trust_card {
    hidden: yes
    label: "Data Trust"
    type: number
    sql: SAFE_DIVIDE(${checks} - ${attention_checks}, NULLIF(${checks}, 0)) ;;
    value_format_name: percent_0
    html:
      <div style="font-family: 'Google Sans', Arial, sans-serif; text-align:left;">
        <div style="font-size:13px;color:#5f6368;">Data trust checks passing</div>
        <div style="font-size:32px;font-weight:600;color:#202124;">{{ rendered_value }}</div>
        <div style="font-size:13px;color:#5f6368;">{{ attention_checks._rendered_value }} checks need attention</div>
      </div> ;;
  }
}
