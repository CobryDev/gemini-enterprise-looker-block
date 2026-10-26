view: person_identity {
  label: "Person Identity"
  # Maps every email address a person has used to their current one, so a
  # renamed account counts as one person. Built from Workspace RENAME_USER
  # admin events, plus the person_email_overrides constant for anything the
  # audit log can't show.
  #
  # Each row is a segment: a period during which one account held an address.
  # A segment opens when the address is first seen, renamed into or created,
  # and runs until the next of those events for the same address, so segments
  # for one address never overlap and joining on (address, time) can't
  # duplicate rows. A segment's person is found by following renames forward
  # until the account's latest address. An address freed by a rename and later
  # given to a new account (CREATE_USER) starts a new segment, so the two
  # people stay separate.
  #
  # Without workspace_export = same_region only the overrides apply.
  derived_table: {
    datagroup_trigger: gemini_change_management_daily_datagroup
    sql:
      WITH RECURSIVE
      admin_events AS (
        {% if '@{workspace_export}' == 'same_region' %}
        SELECT
          TIMESTAMP_MICROS(time_usec) AS ts,
          event_name,
          LOWER(TRIM(admin.user_email)) AS old_email,
          LOWER(TRIM(admin.new_value)) AS new_email
        FROM `@{gemini_project}.@{workspace_dataset}.activity`
        WHERE record_type = 'admin'
          AND event_name IN ('RENAME_USER', 'CREATE_USER')
          AND admin.user_email IS NOT NULL
        {% else %}
        SELECT
          CAST(NULL AS TIMESTAMP) AS ts,
          CAST(NULL AS STRING) AS event_name,
          CAST(NULL AS STRING) AS old_email,
          CAST(NULL AS STRING) AS new_email
        FROM UNNEST(ARRAY<INT64>[])
        {% endif %}
      ),

      renames AS (
        SELECT ts, old_email, new_email
        FROM admin_events
        WHERE event_name = 'RENAME_USER' AND new_email IS NOT NULL AND new_email != old_email
      ),

      starts AS (
        SELECT old_email AS source_email, TIMESTAMP('1970-01-01') AS valid_from FROM renames
        UNION DISTINCT
        SELECT new_email, ts FROM renames
        UNION DISTINCT
        SELECT old_email, ts FROM admin_events WHERE event_name = 'CREATE_USER'
      ),

      segments AS (
        SELECT
          source_email,
          valid_from,
          LEAD(valid_from, 1, TIMESTAMP('9999-12-31')) OVER (PARTITION BY source_email ORDER BY valid_from) AS valid_to
        FROM starts
      ),

      hops AS (
        SELECT segments.source_email, segments.valid_from, renames.new_email AS next_email, renames.ts AS next_from
        FROM segments
        JOIN renames
          ON renames.old_email = segments.source_email
          AND renames.ts >= segments.valid_from
          AND renames.ts < segments.valid_to
        WHERE TRUE
        QUALIFY ROW_NUMBER() OVER (PARTITION BY segments.source_email, segments.valid_from ORDER BY renames.ts) = 1
      ),

      chain AS (
        SELECT source_email, valid_from, source_email AS current_email, valid_from AS current_from, 0 AS depth
        FROM segments
        UNION ALL
        SELECT chain.source_email, chain.valid_from, hops.next_email, hops.next_from, chain.depth + 1
        FROM chain
        JOIN hops ON hops.source_email = chain.current_email AND hops.valid_from = chain.current_from
        WHERE chain.depth < 100
      ),

      resolved AS (
        SELECT source_email, valid_from, current_email AS person_email
        FROM chain
        WHERE TRUE
        QUALIFY ROW_NUMBER() OVER (PARTITION BY source_email, valid_from ORDER BY depth DESC) = 1
      ),

      overrides AS (
        SELECT
          LOWER(TRIM(SPLIT(pair, '=')[SAFE_OFFSET(0)])) AS alias_email,
          LOWER(TRIM(SPLIT(pair, '=')[SAFE_OFFSET(1)])) AS person_email
        FROM UNNEST(SPLIT('@{person_email_overrides}', ',')) AS pair
        WHERE STRPOS(pair, '=') > 0
      ),

      mapped AS (
        SELECT segments.source_email, segments.valid_from, segments.valid_to, resolved.person_email
        FROM segments
        JOIN resolved USING (source_email, valid_from)
        UNION ALL
        SELECT alias_email, TIMESTAMP('1970-01-01'), TIMESTAMP('9999-12-31'), alias_email
        FROM overrides
        WHERE alias_email NOT IN (SELECT source_email FROM segments)
      )

      SELECT
        mapped.source_email,
        mapped.valid_from,
        mapped.valid_to,
        COALESCE(overrides.person_email, mapped.person_email) AS person_email
      FROM mapped
      LEFT JOIN overrides ON overrides.alias_email = mapped.person_email ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.source_email, '|', CAST(${TABLE}.valid_from AS STRING)) ;;
  }

  dimension: source_email {
    label: "Address Used"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.source_email ;;
  }

  dimension: person_email {
    label: "Current Address"
    type: string
    required_access_grants: [can_see_individuals]
    sql: ${TABLE}.person_email ;;
  }

  dimension_group: valid_from {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.valid_from ;;
  }

  dimension_group: valid_to {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.valid_to ;;
  }

  measure: merged_addresses {
    label: "Merged Addresses"
    description: "Addresses that resolve to a different, current address."
    type: count_distinct
    sql: CASE WHEN ${TABLE}.source_email != ${TABLE}.person_email THEN ${TABLE}.source_email END ;;
  }
}
