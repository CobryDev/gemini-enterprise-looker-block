MERGE `${project_id}.${analytics_dataset_id}.metrics_history` AS target
USING (
  WITH daily_metrics AS (
    SELECT
      COALESCE(engine_id, REGEXP_EXTRACT(_TABLE_SUFFIX, r'export_(.+)')) AS engine_id,
      SAFE_CAST(date AS DATE) AS metric_date,
      SUM(search_count) AS search_count,
      SUM(answer_count) AS answer_count,
      SUM(action_count) AS action_count,
      SUM(search_click_count) AS search_click_count,
      SUM(feedback_like_count) AS feedback_like_count,
      SUM(feedback_dislike_count) AS feedback_dislike_count,
      MAX(daily_active_user_count) AS daily_active_user_count,
      MAX(weekly_active_user_count) AS weekly_active_user_count,
      MAX(monthly_active_user_count) AS monthly_active_user_count,
      AVG(user_retention_ratio_for7d) AS user_retention_ratio_for7d,
      AVG(user_retention_ratio_for28d) AS user_retention_ratio_for28d,
      AVG(user_growth_rate_for7d) AS user_growth_rate_for7d,
      AVG(user_growth_rate_for28d) AS user_growth_rate_for28d,
      AVG(user_churn_rate_for7d) AS user_churn_rate_for7d,
      AVG(user_churn_rate_for28d) AS user_churn_rate_for28d,
      MAX(seats_purchased) AS seats_purchased,
      MAX(seats_claimed) AS seats_claimed,
      SUM(agent_session_count) AS agent_session_count,
      MAX(monthly_agent_active_user_count) AS monthly_agent_active_user_count,
      CAST(COUNT(DISTINCT IF(agent_session_count > 0, agent_name, NULL)) AS FLOAT64) AS agents_used,
      SUM(monthly_new_agent_count) AS monthly_new_agent_count
    FROM `${staging_project_id}.${staging_dataset_id}.export_*`
    WHERE date IS NOT NULL
    GROUP BY engine_id, metric_date
  )
  SELECT engine_id, metric_date, metric_type, metric_value, CURRENT_TIMESTAMP() AS ingested_at
  FROM daily_metrics
  UNPIVOT (
    metric_value FOR metric_type IN (
      search_count AS 'SEARCH_COUNT',
      answer_count AS 'ANSWER_COUNT',
      action_count AS 'ACTION_COUNT',
      search_click_count AS 'SEARCH_CLICK_COUNT',
      feedback_like_count AS 'LIKE_COUNT',
      feedback_dislike_count AS 'DISLIKE_COUNT',
      daily_active_user_count AS 'DAU',
      weekly_active_user_count AS 'WAU',
      monthly_active_user_count AS 'MAU',
      user_retention_ratio_for7d AS 'RETENTION_7_DAY',
      user_retention_ratio_for28d AS 'RETENTION_28_DAY',
      user_growth_rate_for7d AS 'GROWTH_RATE',
      user_growth_rate_for28d AS 'GROWTH_RATE_28_DAY',
      user_churn_rate_for7d AS 'CHURN_RATE',
      user_churn_rate_for28d AS 'CHURN_RATE_28_DAY',
      seats_purchased AS 'SEATS_PURCHASED',
      seats_claimed AS 'SEATS_CLAIMED',
      agent_session_count AS 'MONTHLY_CHAT_SESSIONS',
      monthly_agent_active_user_count AS 'MONTHLY_ACTIVE_AGENT_USERS',
      agents_used AS 'MONTHLY_AGENTS_USED',
      monthly_new_agent_count AS 'MONTHLY_AGENTS_CREATED'
    )
  )
  WHERE metric_date IS NOT NULL
    AND metric_value IS NOT NULL
) AS source
ON target.engine_id = source.engine_id
  AND target.metric_date = source.metric_date
  AND target.metric_type = source.metric_type
WHEN MATCHED AND IFNULL(target.metric_value, -1) != IFNULL(source.metric_value, -1) THEN
  UPDATE SET
    metric_value = source.metric_value,
    ingested_at = source.ingested_at
WHEN NOT MATCHED THEN
  INSERT (engine_id, metric_date, metric_type, metric_value, ingested_at)
  VALUES (source.engine_id, source.metric_date, source.metric_type, source.metric_value, source.ingested_at);
