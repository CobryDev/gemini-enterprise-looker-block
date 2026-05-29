-- Merge the rolling Gemini Enterprise export window into full-fidelity history.
-- The export overwrites a ~30-day rolling window in staging on every run, so we
-- upsert each row by a stable hash of its dimension columns. This preserves the
-- original grain (data_source x product_type x device x query x document x agent)
-- and keeps history beyond the export's retention window.

MERGE `${project_id}.${analytics_dataset_id}.export_history` AS target
USING (
  -- Aggregate staging to one row per dimension key. Additive counts are summed;
  -- snapshot metrics and ratios are maxed (they repeat per key, not accumulate).
  SELECT
    TO_HEX(MD5(ARRAY_TO_STRING([
      COALESCE(engine_id, ''),
      CAST(metric_date AS STRING),
      COALESCE(data_source, ''),
      COALESCE(product_type, ''),
      COALESCE(device_type, ''),
      COALESCE(serving_config_id, ''),
      COALESCE(original_search_query, ''),
      COALESCE(document_name, ''),
      COALESCE(agent_name, ''),
      COALESCE(agent_type, ''),
      COALESCE(agent_ownership, ''),
      COALESCE(dislike_reasons, '')
    ], '|'))) AS row_key,
    engine_id,
    metric_date,
    data_source,
    product_type,
    device_type,
    serving_config_id,
    original_search_query,
    document_name,
    agent_name,
    agent_type,
    agent_ownership,
    dislike_reasons,
    ANY_VALUE(project_number) AS project_number,
    SUM(search_count) AS search_count,
    SUM(search_click_count) AS search_click_count,
    SUM(answer_count) AS answer_count,
    SUM(action_count) AS action_count,
    SUM(total_search_contents) AS total_search_contents,
    SUM(total_view_contents) AS total_view_contents,
    SUM(feedback_like_count) AS feedback_like_count,
    SUM(feedback_dislike_count) AS feedback_dislike_count,
    MAX(daily_active_user_count) AS daily_active_user_count,
    MAX(weekly_active_user_count) AS weekly_active_user_count,
    MAX(monthly_active_user_count) AS monthly_active_user_count,
    MAX(user_retention_ratio_for7d) AS user_retention_ratio_for7d,
    MAX(user_retention_ratio_for28d) AS user_retention_ratio_for28d,
    MAX(user_churn_rate_for7d) AS user_churn_rate_for7d,
    MAX(user_churn_rate_for28d) AS user_churn_rate_for28d,
    MAX(user_growth_rate_for7d) AS user_growth_rate_for7d,
    MAX(user_growth_rate_for28d) AS user_growth_rate_for28d,
    SUM(total_home_page_visit_count) AS total_home_page_visit_count,
    SUM(total_agent_gallery_page_visit_count) AS total_agent_gallery_page_visit_count,
    SUM(total_prompts_page_visit_count) AS total_prompts_page_visit_count,
    SUM(total_people_page_visit_count) AS total_people_page_visit_count,
    SUM(total_notebook_lm_page_visit_count) AS total_notebook_lm_page_visit_count,
    SUM(total_deep_research_page_visit_count) AS total_deep_research_page_visit_count,
    SUM(total_idea_generation_page_visit_count) AS total_idea_generation_page_visit_count,
    SUM(total_agent_page_visit_count) AS total_agent_page_visit_count,
    MAX(seats_purchased) AS seats_purchased,
    MAX(seats_claimed) AS seats_claimed,
    MAX(monthly_new_agent_count) AS monthly_new_agent_count,
    SUM(agent_session_count) AS agent_session_count,
    SUM(agent_active_user_count) AS agent_active_user_count,
    MAX(monthly_agent_active_user_count) AS monthly_agent_active_user_count
  FROM (
    SELECT
      COALESCE(engine_id, REGEXP_EXTRACT(_TABLE_SUFFIX, r'(.+)')) AS engine_id,
      SAFE_CAST(date AS DATE) AS metric_date,
      * EXCEPT (engine_id, date)
    FROM `${staging_project_id}.${staging_dataset_id}.export_*`
    WHERE date IS NOT NULL
  )
  GROUP BY
    engine_id, metric_date, data_source, product_type, device_type, serving_config_id,
    original_search_query, document_name, agent_name, agent_type, agent_ownership, dislike_reasons
) AS source
ON target.row_key = source.row_key
WHEN MATCHED THEN UPDATE SET
  project_number = source.project_number,
  search_count = source.search_count,
  search_click_count = source.search_click_count,
  answer_count = source.answer_count,
  action_count = source.action_count,
  total_search_contents = source.total_search_contents,
  total_view_contents = source.total_view_contents,
  feedback_like_count = source.feedback_like_count,
  feedback_dislike_count = source.feedback_dislike_count,
  daily_active_user_count = source.daily_active_user_count,
  weekly_active_user_count = source.weekly_active_user_count,
  monthly_active_user_count = source.monthly_active_user_count,
  user_retention_ratio_for7d = source.user_retention_ratio_for7d,
  user_retention_ratio_for28d = source.user_retention_ratio_for28d,
  user_churn_rate_for7d = source.user_churn_rate_for7d,
  user_churn_rate_for28d = source.user_churn_rate_for28d,
  user_growth_rate_for7d = source.user_growth_rate_for7d,
  user_growth_rate_for28d = source.user_growth_rate_for28d,
  total_home_page_visit_count = source.total_home_page_visit_count,
  total_agent_gallery_page_visit_count = source.total_agent_gallery_page_visit_count,
  total_prompts_page_visit_count = source.total_prompts_page_visit_count,
  total_people_page_visit_count = source.total_people_page_visit_count,
  total_notebook_lm_page_visit_count = source.total_notebook_lm_page_visit_count,
  total_deep_research_page_visit_count = source.total_deep_research_page_visit_count,
  total_idea_generation_page_visit_count = source.total_idea_generation_page_visit_count,
  total_agent_page_visit_count = source.total_agent_page_visit_count,
  seats_purchased = source.seats_purchased,
  seats_claimed = source.seats_claimed,
  monthly_new_agent_count = source.monthly_new_agent_count,
  agent_session_count = source.agent_session_count,
  agent_active_user_count = source.agent_active_user_count,
  monthly_agent_active_user_count = source.monthly_agent_active_user_count,
  ingested_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  row_key, engine_id, metric_date, project_number, data_source, product_type, device_type,
  serving_config_id, original_search_query, document_name, agent_name, agent_type, agent_ownership,
  dislike_reasons, search_count, search_click_count, answer_count, action_count,
  total_search_contents, total_view_contents, feedback_like_count, feedback_dislike_count,
  daily_active_user_count, weekly_active_user_count, monthly_active_user_count,
  user_retention_ratio_for7d, user_retention_ratio_for28d, user_churn_rate_for7d, user_churn_rate_for28d,
  user_growth_rate_for7d, user_growth_rate_for28d, total_home_page_visit_count,
  total_agent_gallery_page_visit_count, total_prompts_page_visit_count, total_people_page_visit_count,
  total_notebook_lm_page_visit_count, total_deep_research_page_visit_count,
  total_idea_generation_page_visit_count, total_agent_page_visit_count,
  seats_purchased, seats_claimed, monthly_new_agent_count, agent_session_count,
  agent_active_user_count, monthly_agent_active_user_count, ingested_at
) VALUES (
  source.row_key, source.engine_id, source.metric_date, source.project_number, source.data_source,
  source.product_type, source.device_type, source.serving_config_id, source.original_search_query,
  source.document_name, source.agent_name, source.agent_type, source.agent_ownership,
  source.dislike_reasons, source.search_count, source.search_click_count, source.answer_count,
  source.action_count, source.total_search_contents, source.total_view_contents,
  source.feedback_like_count, source.feedback_dislike_count, source.daily_active_user_count,
  source.weekly_active_user_count, source.monthly_active_user_count, source.user_retention_ratio_for7d,
  source.user_retention_ratio_for28d, source.user_churn_rate_for7d, source.user_churn_rate_for28d,
  source.user_growth_rate_for7d, source.user_growth_rate_for28d, source.total_home_page_visit_count,
  source.total_agent_gallery_page_visit_count, source.total_prompts_page_visit_count,
  source.total_people_page_visit_count, source.total_notebook_lm_page_visit_count,
  source.total_deep_research_page_visit_count, source.total_idea_generation_page_visit_count,
  source.total_agent_page_visit_count, source.seats_purchased, source.seats_claimed,
  source.monthly_new_agent_count, source.agent_session_count, source.agent_active_user_count,
  source.monthly_agent_active_user_count, CURRENT_TIMESTAMP()
);
