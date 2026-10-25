view: user_org_unit {
  label: "Org Unit"
  # One row per Workspace user: latest org unit and recent Workspace presence,
  # rolled up from workspace_user_daily. Empty (so the Org Unit fields show no
  # values) unless the workspace_export constant is same_region.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      SELECT
        *,
        COALESCE(NULLIF(ARRAY_TO_STRING(ARRAY(
          SELECT part
          FROM UNNEST(SPLIT(TRIM(org_unit, '/'), '/')) AS part WITH OFFSET AS depth
          WHERE depth < @{org_unit_depth}
          ORDER BY depth
        ), '/'), ''), IF(org_unit IS NULL, 'Unknown', '(Top level)')) AS department
      FROM (
        SELECT
          user_email,
          ARRAY_AGG(org_unit IGNORE NULLS ORDER BY event_date DESC LIMIT 1)[SAFE_OFFSET(0)] AS org_unit,
          ANY_VALUE(domain_name) AS domain_name,
          MAX(event_date) AS last_workspace_seen_date,
          COUNT(DISTINCT IF(event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY), event_date, NULL)) AS workspace_active_days_28d
        FROM ${workspace_user_daily.SQL_TABLE_NAME}
        GROUP BY user_email
      ) ;;
  }

  dimension: user_email {
    primary_key: yes
    hidden: yes
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: org_unit {
    label: "Org Unit"
    description: "User's latest Workspace org-unit path. Needs the Workspace audit export in the same BigQuery location and workspace_export = same_region."
    type: string
    sql: ${TABLE}.org_unit ;;
  }

  dimension: top_level_org_unit {
    label: "Top-Level Org Unit"
    description: "First segment of the org-unit path."
    type: string
    sql: NULLIF(SPLIT(TRIM(${TABLE}.org_unit, '/'), '/')[SAFE_OFFSET(0)], '') ;;
  }

  dimension: department {
    description: "The first N segments of the org-unit path, where N is the org_unit_depth constant. Users without a Workspace org unit show as Unknown."
    type: string
    sql: COALESCE(${TABLE}.department, 'Unknown') ;;
  }

  dimension: domain_name {
    label: "Workspace Domain"
    type: string
    sql: ${TABLE}.domain_name ;;
  }

  dimension_group: last_workspace_seen {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.last_workspace_seen_date ;;
  }

  dimension: workspace_active_days_28d {
    label: "Workspace Active Days (28d)"
    description: "Days with any Workspace audit event in the last 28 days."
    type: number
    sql: ${TABLE}.workspace_active_days_28d ;;
  }
}
