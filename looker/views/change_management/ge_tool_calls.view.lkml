view: ge_tool_calls {
  label: "Tools and Skills"
  # One row per tool call the model made, from the gen_ai inference log.
  # Skill loads carry the skill name; no other tool arguments are stored.
  # user_email is the person's current address; see person_identity.
  derived_table: {
    sql:
      SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email)
      FROM `@{gemini_project}.@{gemini_dataset}.ge_tool_calls` AS source
      LEFT JOIN ${person_identity.SQL_TABLE_NAME} AS person_identity
        ON person_identity.source_email = LOWER(source.user_email)
        AND source.event_ts >= person_identity.valid_from
        AND source.event_ts < person_identity.valid_to ;;
  }

  dimension: row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.row_key ;;
  }

  dimension_group: event {
    label: "Event"
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: app_name {
    label: "App"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: user_email {
    label: "User"
    description: "Attributed through the trace shared with the user-activity log."
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: agent_name {
    label: "Calling Agent"
    description: "Agent in the assistant's agent tree that made the call (root_agent is the main assistant)."
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: tool_name {
    label: "Tool"
    type: string
    sql: ${TABLE}.tool_name ;;
  }

  dimension: connector {
    description: "Connector or agent that owns the tool, for example Asana or Google Chat. Built-in tools show as Built-in."
    type: string
    sql: CASE
      WHEN STARTS_WITH(${TABLE}.tool_name, 'custom_mcp_') THEN 'Custom MCP'
      WHEN STRPOS(${TABLE}.tool_name, '__') > 0 THEN INITCAP(REPLACE(REGEXP_REPLACE(SPLIT(${TABLE}.tool_name, '__')[OFFSET(0)], r'_agent$', ''), '_', ' '))
      WHEN STARTS_WITH(${TABLE}.tool_name, 'googlesheets_') THEN 'Google Sheets'
      WHEN STARTS_WITH(${TABLE}.tool_name, 'googledocs_') THEN 'Google Docs'
      WHEN STARTS_WITH(${TABLE}.tool_name, 'googleslides_') THEN 'Google Slides'
      ELSE 'Built-in'
    END ;;
  }

  dimension: tool_label {
    label: "Tool (Readable)"
    description: "Connector and action in plain words, for example Asana: Search Tasks."
    type: string
    sql: CONCAT(${connector}, ': ', INITCAP(REPLACE(REGEXP_REPLACE(
      IF(STRPOS(${TABLE}.tool_name, '__') > 0, SPLIT(${TABLE}.tool_name, '__')[SAFE_OFFSET(1)], ${TABLE}.tool_name),
      r'^(googlesheets|googledocs|googleslides)_|_tool$', ''), '_', ' '))) ;;
  }

  dimension: tool_family {
    label: "Tool Family"
    description: "Connector or sub-agent that owns the tool, for example email_agent, google_drive_agent, or the tool name itself for built-ins."
    type: string
    sql: ${TABLE}.tool_family ;;
  }

  dimension: skill_name {
    label: "Skill"
    description: "Skill loaded by load_skill / load_skill_resource."
    type: string
    sql: ${TABLE}.skill_name ;;
  }

  dimension: is_first_party_skill {
    description: "Google-provided skill (1p-skill-*) rather than one your organisation authored."
    type: yesno
    sql: STARTS_WITH(${TABLE}.skill_name, '1p-') ;;
  }

  dimension: is_skill_call {
    type: yesno
    sql: ${TABLE}.is_skill_call ;;
  }

  measure: tool_calls {
    type: count
    drill_fields: [event_date, user_email, tool_family, tool_name, skill_name]
  }

  measure: tool_users {
    description: "Distinct users whose prompts triggered a tool call."
    type: count_distinct
    sql: ${user_email} ;;
  }

  measure: skill_loads {
    description: "Times a skill was loaded into a conversation."
    type: count
    filters: [skill_name: "-NULL"]
    drill_fields: [event_date, user_email, skill_name]
  }

  measure: skills_used {
    description: "Distinct skills loaded."
    type: count_distinct
    sql: ${skill_name} ;;
  }

  measure: skill_users {
    description: "Distinct users whose conversations loaded a skill."
    type: count_distinct
    sql: CASE WHEN ${skill_name} IS NOT NULL THEN ${user_email} END ;;
    drill_fields: [user_email, skill_loads, skills_used]
  }
}
