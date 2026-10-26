view: ge_safety_events {
  label: "Safety"
  # Prompt and response screening. MODEL_ARMOR rows come from Model Armor
  # Data Access audit logs (one row per matched filter category, or one row
  # with no category when the content passed). GEMINI_ENTERPRISE rows are
  # answers Gemini Enterprise skipped for a policy reason. Count distinct
  # event_id for interactions; count rows for category matches.
  # user_email is the person's current address; see person_identity.
  derived_table: {
    sql:
      SELECT source.* REPLACE (COALESCE(person_identity.person_email, LOWER(source.user_email)) AS user_email)
      FROM `@{gemini_project}.@{gemini_dataset}.ge_safety_events` AS source
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

  dimension: event_id {
    hidden: yes
    type: string
    sql: ${TABLE}.event_id ;;
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
    description: "Model Armor is called by the Gemini Enterprise service agent, so the user is matched through the trace or the nearest assistant call; see Attribution Method."
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.user_email ;;
  }

  dimension: source {
    description: "MODEL_ARMOR (per-category verdicts) or GEMINI_ENTERPRISE (answer skipped for a policy reason)."
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: screened_content {
    description: "PROMPT or RESPONSE."
    type: string
    sql: ${TABLE}.screened_content ;;
  }

  dimension: template {
    label: "Model Armor Template"
    type: string
    sql: ${TABLE}.template ;;
  }

  dimension: category {
    description: "Model Armor filter (harassment, hate_speech, dangerous, sexually_explicit, pi_and_jailbreak, malicious_uris, sensitive_data, csam, virus_scan) or Gemini Enterprise skip reason."
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: is_match {
    label: "Is Flagged"
    description: "A filter matched, or Gemini Enterprise skipped the answer."
    type: yesno
    sql: ${TABLE}.is_match ;;
  }

  dimension: invocation_result {
    hidden: yes
    type: string
    sql: ${TABLE}.invocation_result ;;
  }

  dimension: attribution_method {
    description: "How the user was identified: log (direct), trace (shared trace ID), time_window (nearest assistant call within 10 seconds, less certain), unattributed."
    type: string
    sql: ${TABLE}.attribution_method ;;
  }

  measure: screened_interactions {
    description: "Distinct prompts or responses screened."
    type: count_distinct
    sql: ${event_id} ;;
  }

  measure: flagged_interactions {
    description: "Distinct prompts or responses where a filter matched or the answer was skipped."
    type: count_distinct
    sql: CASE WHEN ${is_match} THEN ${event_id} END ;;
    drill_fields: [event_date, user_email, app_name, source, screened_content, category, attribution_method]
  }

  measure: flag_rate {
    type: number
    sql: SAFE_DIVIDE(${flagged_interactions}, NULLIF(${screened_interactions}, 0)) ;;
    value_format_name: percent_2
  }

  measure: category_matches {
    description: "Filter-category matches. One flagged prompt can match several categories."
    type: count
    filters: [is_match: "yes", category: "-NULL"]
    drill_fields: [event_date, user_email, category, screened_content]
  }

  measure: flagged_users {
    description: "Distinct users with at least one flagged prompt or response."
    type: count_distinct
    sql: CASE WHEN ${is_match} THEN ${user_email} END ;;
    drill_fields: [user_email, flagged_interactions, category_matches]
  }
}
