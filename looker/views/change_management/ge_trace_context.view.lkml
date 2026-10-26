view: ge_trace_context {
  label: "Trace Context"
  # One row per Gemini Enterprise trace, used to attribute model-call token
  # counts back to the model, feature and event that produced them.
  derived_table: {
    datagroup_trigger: gemini_change_management_datagroup
    sql:
      SELECT
        trace_id,
        ANY_VALUE(app_name) AS app_name,
        ANY_VALUE(user_email) AS user_email,
        COALESCE(ANY_VALUE(NULLIF(model, '')), 'Unattributed') AS model,
        COALESCE(ANY_VALUE(NULLIF(feature, '')), 'Unattributed') AS feature,
        COALESCE(ANY_VALUE(NULLIF(event_type, '')), 'Unattributed') AS event_type,
        COALESCE(ANY_VALUE(NULLIF(invocation_mode, '')), 'Unattributed') AS invocation_mode,
        COALESCE(ANY_VALUE(NULLIF(agent_display_name, '')), ANY_VALUE(NULLIF(agent_id, '')), 'Main assistant') AS agent_label
      FROM `@{gemini_project}.@{gemini_dataset}.ge_user_activity`
      WHERE trace_id IS NOT NULL
      GROUP BY trace_id ;;
  }

  dimension: trace_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.trace_id ;;
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

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: model_family {
    label: "Model Family"
    type: string
    sql: CASE
      WHEN ${TABLE}.model = 'Unattributed' THEN 'Unattributed'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'image|imagen|veo') THEN 'Image and video'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'thinking') THEN 'Thinking'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'ultra') THEN 'Ultra'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'pro') THEN 'Pro'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'lite') THEN 'Flash-Lite'
      WHEN REGEXP_CONTAINS(LOWER(${TABLE}.model), r'flash') THEN 'Flash'
      ELSE 'Other'
    END ;;
  }

  dimension: feature {
    type: string
    sql: ${TABLE}.feature ;;
  }

  dimension: event_type {
    label: "Event Type"
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: invocation_mode {
    label: "Invocation Mode"
    type: string
    sql: ${TABLE}.invocation_mode ;;
  }

  dimension: token_context {
    label: "Token Context"
    description: "Feature when recorded, otherwise event type or invocation mode."
    type: string
    sql: CASE
      WHEN ${TABLE}.feature != 'Unattributed' THEN ${TABLE}.feature
      WHEN ${TABLE}.event_type != 'Unattributed' THEN ${TABLE}.event_type
      ELSE ${TABLE}.invocation_mode
    END ;;
  }

  dimension: agent_label {
    label: "Agent"
    type: string
    sql: ${TABLE}.agent_label ;;
  }
}
