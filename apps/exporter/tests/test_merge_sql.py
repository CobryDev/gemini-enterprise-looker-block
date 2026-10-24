import re

from gemini_exporter.main import (
    EngineConfig,
    PipelineConfig,
    load_merge_sql,
    render_merge_sql,
)

PIPELINE = PipelineConfig(
    project_id="analytics-project",
    engine_project_id="engine-project",
    staging_project_id="engine-project",
    staging_dataset="gemini_analytics_staging",
    analytics_project_id="analytics-project",
    analytics_dataset="gemini_analytics",
    analytics_table="export_history",
)

ENGINE = EngineConfig(
    engine_id="customer-support-engine",
    display_name="Support Copilot",
    location="eu",
    endpoint_location="eu",
    table_id_prefix="export_customer_support_engine",
)


def test_template_only_uses_known_placeholders():
    placeholders = set(re.findall(r"\{(\w+)\}", load_merge_sql()))
    assert placeholders == {"staging_table_wildcard", "history_table"}


def test_rendered_sql_targets_engine_tables():
    sql = render_merge_sql(PIPELINE, ENGINE)

    assert "`engine-project.gemini_analytics_staging.export_customer_support_engine*`" in sql
    assert "MERGE `analytics-project.gemini_analytics.export_history` AS target" in sql
    assert "{" not in sql and "}" not in sql


def test_rendered_sql_binds_values_as_parameters():
    sql = render_merge_sql(PIPELINE, ENGINE)

    for parameter in ("@engine_id", "@app_name", "@window_start", "@window_end"):
        assert parameter in sql
    # Engine identity must never be inlined into the SQL text.
    assert "customer-support-engine" not in sql
    assert "Support Copilot" not in sql
