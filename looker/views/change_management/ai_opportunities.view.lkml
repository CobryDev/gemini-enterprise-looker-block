view: ai_opportunities {
  label: "AI Opportunities"
  # Rule-based queue that turns adoption signals into change-management actions.
  # People without a department ('(Top level)' or 'Unknown') are a directory problem,
  # so they get one data-quality item instead of a department training target.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH people AS (
        SELECT
          profile.*,
          COALESCE(user_org_unit.department, 'Unknown') AS department
        FROM ${ai_user_profile.SQL_TABLE_NAME} AS profile
        LEFT JOIN ${user_org_unit.SQL_TABLE_NAME} AS user_org_unit USING (user_email)
      ),

      department_summary AS (
        SELECT
          department,
          COUNT(*) AS people,
          COUNTIF(ai_days_28d > 0) AS active_people,
          COUNTIF(ai_days_28d = 0) AS inactive_people
        FROM people
        WHERE department NOT IN ('(Top level)', 'Unknown')
        GROUP BY department
      ),

      unassigned AS (
        SELECT
          COUNT(*) AS people,
          COUNTIF(ai_days_28d = 0) AS inactive_people,
          (SELECT COUNT(*) FROM people) AS eligible_people
        FROM people
        WHERE department IN ('(Top level)', 'Unknown')
      ),

      latest_licence_requests AS (
        SELECT COUNT(DISTINCT LOWER(user_email)) AS requesters
        FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`
        WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM `@{gemini_project}.@{gemini_dataset}.ge_user_licenses`)
          AND license_state = 'NO_LICENSE_ATTEMPTED_LOGIN'
          AND user_email IS NOT NULL
      ),

      classification AS (
        SELECT
          SUM(ai_actions) AS actions,
          SUM(IF(use_case = 'Unclassified', ai_actions, 0)) AS unclassified_actions
        FROM ${ai_activity_hourly.SQL_TABLE_NAME}
        WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 27 DAY)
      ),

      rules AS (
        SELECT
          'build_repeat_usage' AS opportunity_type,
          'Organisation' AS scope_type,
          'All employees' AS scope,
          'Turn casual users into regular users' AS action_title,
          COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS size,
          CONCAT(CAST(COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS STRING), ' casual users and ', CAST(COUNTIF(ai_days_28d >= @{normal_user_min_days}) AS STRING), ' regular users in the last 28 days') AS evidence,
          CONCAT(CAST(COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) AS STRING), IF(COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) = 1, ' person', ' people'), ' could move to regular use') AS impact,
          'Follow up with short, task-specific coaching to help interested users repeat successful workflows.' AS recommended_action,
          'Send casual users two role-specific prompts and check back in 2 weeks.' AS next_step,
          'Adoption' AS category,
          CASE WHEN COUNTIF(ai_days_28d BETWEEN 1 AND @{normal_user_min_days} - 1) = 0 THEN 4
            WHEN COUNTIF(ai_days_28d >= @{normal_user_min_days}) = 0 THEN 1 ELSE 3 END AS priority
        FROM people

        UNION ALL
        SELECT
          'review_idle_licences',
          'Organisation',
          'Gemini Enterprise',
          'Review unused Gemini Enterprise licences',
          COUNTIF(is_ge_licensed AND ge_days_28d = 0),
          CONCAT(CAST(COUNTIF(is_ge_licensed AND ge_days_28d = 0) AS STRING), ' assigned licences had no Gemini Enterprise use in the last 28 days'),
          IF(@{ge_seat_cost_monthly} > 0,
            CONCAT('@{currency_symbol}', FORMAT("%'d", CAST(ROUND(COUNTIF(is_ge_licensed AND ge_days_28d = 0) * @{ge_seat_cost_monthly}) AS INT64)), ' per month in unused seats'),
            CONCAT(CAST(COUNTIF(is_ge_licensed AND ge_days_28d = 0) AS STRING), ' seats to review; set the seat cost to see spend')),
          'Validate rollout timing and need, then reassign or reclaim unnecessary licences.',
          'Ask the managers of these licence holders whether the seat is still needed, then reassign or reclaim.',
          'Licences',
          CASE WHEN COUNTIF(is_ge_licensed AND ge_days_28d = 0) > 0 THEN 1 ELSE 4 END
        FROM people

        UNION ALL
        SELECT
          'expand_department_adoption',
          'Department',
          department,
          CONCAT('Reach non-users in ', department),
          inactive_people,
          CONCAT(CAST(active_people AS STRING), ' of ', CAST(people AS STRING), ' active (', CAST(CAST(ROUND(100 * SAFE_DIVIDE(active_people, people)) AS INT64) AS STRING), '%)'),
          CONCAT(CAST(inactive_people AS STRING), IF(inactive_people = 1, ' person', ' people'), ' not yet using AI'),
          'Run a team-specific use-case session with early adopters and follow up after 28 days.',
          'Book a 30-minute team session led by an active colleague, then re-check in 28 days.',
          'Adoption',
          CASE WHEN inactive_people >= 5 THEN 2 ELSE 3 END
        FROM department_summary
        WHERE people > 0 AND inactive_people > 0

        UNION ALL
        SELECT
          'assign_departments',
          'Data quality',
          'People without a department',
          'Assign people to departments in the directory',
          people,
          CONCAT(CAST(people AS STRING), ' of ', CAST(eligible_people AS STRING), ' eligible people sit in the top-level org unit or have no org unit; ', CAST(inactive_people AS STRING), ' of them are inactive'),
          'Department views and targeting miss these people',
          'Move these people into the right org units before targeting training at them.',
          'Ask the Workspace admin to place these users in department org units.',
          'Data quality',
          CASE WHEN people >= 3 AND SAFE_DIVIDE(people, eligible_people) >= 0.1 THEN 2 WHEN people > 0 THEN 3 ELSE 4 END
        FROM unassigned

        UNION ALL
        SELECT
          'workspace_to_enterprise',
          'Organisation',
          'Workspace-only users',
          'Offer Gemini Enterprise to Workspace-only users',
          COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0),
          CONCAT(CAST(COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0) AS STRING), ' people used Workspace Gemini but not Gemini Enterprise in the last 28 days'),
          CONCAT(CAST(COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0) AS STRING), ' people already use AI and may benefit from Gemini Enterprise'),
          'Check whether these users need Gemini Enterprise access or a product-specific enablement path.',
          'Check whether they have access, then share one Gemini Enterprise use case for their role.',
          'Adoption',
          IF(COUNTIF(gws_days_28d > 0 AND ge_days_28d = 0) > 0, 3, 4)
        FROM people

        UNION ALL
        SELECT
          'address_access_friction',
          'Organisation',
          'Licence requests',
          'Respond to people asking for access',
          requesters,
          CONCAT(CAST(requesters AS STRING), IF(requesters = 1, ' person', ' people'), ' tried to use Gemini Enterprise without a licence'),
          CONCAT(CAST(requesters AS STRING), IF(requesters = 1, ' person wants', ' people want'), ' access now'),
          'Review eligibility and licence-request handling.',
          'Decide on each request; reassign idle licences first.',
          'Access',
          CASE WHEN requesters > 0 THEN 1 ELSE 4 END
        FROM latest_licence_requests

        UNION ALL
        SELECT
          'improve_classification',
          'Data quality',
          'Use-case mapping',
          'Classify more AI activity by use case',
          IFNULL(unclassified_actions, 0),
          CONCAT(CAST(IFNULL(unclassified_actions, 0) AS STRING), ' of ', CAST(IFNULL(actions, 0) AS STRING), ' active AI actions are unclassified in the last 28 days'),
          'Use-case and time-saved figures under-count this activity',
          'Investigate Workspace feature_source coverage and update the use-case mapping.',
          'Add the unclassified features shown on Admin > Data Health to the use-case mapping.',
          'Data quality',
          CASE WHEN SAFE_DIVIDE(unclassified_actions, NULLIF(actions, 0)) > 0.25 THEN 2 WHEN SAFE_DIVIDE(unclassified_actions, NULLIF(actions, 0)) >= 0.02 THEN 3 ELSE 4 END
        FROM classification
      )

      SELECT * FROM rules ;;
  }

  dimension: opportunity_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.opportunity_type, '|', ${TABLE}.scope_type, '|', ${TABLE}.scope) ;;
  }

  dimension: opportunity_type {
    label: "Opportunity Code"
    type: string
    sql: ${TABLE}.opportunity_type ;;
  }

  dimension: action_title {
    label: "Action"
    description: "Plain-English name of the opportunity."
    type: string
    sql: ${TABLE}.action_title ;;
    html: <span title="{{ ai_opportunities.evidence._value }}">{{ value }}</span> ;;
  }

  dimension: category {
    description: "Adoption, Licences, Access or Data quality."
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: scope_type {
    type: string
    sql: ${TABLE}.scope_type ;;
  }

  dimension: scope {
    type: string
    sql: ${TABLE}.scope ;;
  }

  dimension: evidence {
    type: string
    sql: ${TABLE}.evidence ;;
  }

  dimension: impact {
    description: "What acting on this opportunity could change."
    type: string
    sql: ${TABLE}.impact ;;
  }

  dimension: recommended_action {
    label: "Recommended Action"
    type: string
    sql: ${TABLE}.recommended_action ;;
  }

  dimension: next_step {
    label: "Next Step"
    description: "A concrete first step an owner can take this week."
    type: string
    sql: ${TABLE}.next_step ;;
  }

  dimension: priority {
    description: "1 = High, 2 = Medium, 3 = Low, 4 = No action needed."
    type: number
    sql: ${TABLE}.priority ;;
  }

  dimension: priority_label {
    label: "Priority"
    type: string
    sql: CASE ${TABLE}.priority WHEN 1 THEN 'High' WHEN 2 THEN 'Medium' WHEN 3 THEN 'Low' ELSE 'None' END ;;
    order_by_field: priority
    html:
      {% if value == 'High' %}<span style="background:#fce8e6;color:#c5221f;padding:2px 8px;border-radius:10px;font-weight:600;">High</span>
      {% elsif value == 'Medium' %}<span style="background:#fef7e0;color:#b06000;padding:2px 8px;border-radius:10px;font-weight:600;">Medium</span>
      {% elsif value == 'Low' %}<span style="background:#e8f0fe;color:#1967d2;padding:2px 8px;border-radius:10px;">Low</span>
      {% else %}<span style="color:#80868b;">None</span>{% endif %} ;;
  }

  dimension: is_actionable {
    description: "Yes when the opportunity has people affected and a priority above None."
    type: yesno
    sql: ${TABLE}.priority < 4 AND ${TABLE}.size > 0 ;;
  }

  dimension: size {
    label: "People or Items Affected"
    type: number
    sql: ${TABLE}.size ;;
  }

  measure: opportunities {
    type: count
  }

  measure: next_decisions_card {
    hidden: yes
    label: "Next Decisions"
    description: "The three highest-priority actionable opportunities as a compact list."
    type: string
    sql: ARRAY_TO_STRING(ARRAY_AGG(
      IF(${is_actionable}, CONCAT(${priority_label}, '~', ${action_title}, '~', ${impact}), NULL)
      IGNORE NULLS ORDER BY ${priority}, ${size} DESC LIMIT 3), '^') ;;
    html: <div style="font-family:'Plus Jakarta Sans','Google Sans',Roboto,Arial,sans-serif;text-align:left;padding:2px 6px;line-height:1.35;white-space:normal;">{% assign rows = value | split: "^" %}<div style="display:flex;justify-content:space-between;align-items:baseline;margin-bottom:6px;"><div style="font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;color:#5f6368;">Next decisions</div><a href="/dashboards/gemini_enterprise::gemini_ai_change" style="font-size:12px;color:#1a73e8;text-decoration:none;">Open the opportunity queue</a></div>{% if value == blank %}<div style="font-size:14px;color:#5f6368;">No open decisions.</div>{% endif %}{% for r in rows %}{% assign c = r | split: "~" %}<div style="display:flex;gap:10px;align-items:baseline;padding:6px 0;border-top:1px solid #F1F3F4;"><span style="flex:none;font-size:11px;font-weight:600;padding:1px 8px;border-radius:10px;{% if c[0] == 'High' %}background:#FCE8E6;color:#C5221F;{% elsif c[0] == 'Medium' %}background:#FEF7E0;color:#B06000;{% else %}background:#E8F0FE;color:#1967D2;{% endif %}">{{ c[0] }}</span><span style="font-size:14px;font-weight:600;color:#202124;">{{ c[1] }}</span><span style="font-size:12px;color:#5f6368;">{{ c[2] }}</span></div>{% endfor %}</div> ;;
  }
}
