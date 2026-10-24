import pytest

from gemini_exporter.main import engine_from_env, pipeline_from_env

REQUIRED_ENGINE_ENV = {
    "ENGINE_ID": "customer-support-engine",
    "ENGINE_LOCATION": "eu",
}

REQUIRED_PIPELINE_ENV = {
    "PROJECT_ID": "analytics-project",
    "STAGING_DATASET": "gemini_analytics_staging",
    "ANALYTICS_DATASET": "gemini_analytics",
}


def set_env(monkeypatch, values):
    for name in [
        "ENGINE_ID", "ENGINE_LOCATION", "ENDPOINT_LOCATION", "TABLE_ID_PREFIX", "DISPLAY_NAME",
        "PROJECT_ID", "ENGINE_PROJECT_ID", "STAGING_PROJECT_ID", "STAGING_DATASET",
        "ANALYTICS_PROJECT_ID", "ANALYTICS_DATASET", "ANALYTICS_TABLE",
    ]:
        monkeypatch.delenv(name, raising=False)
    for name, value in values.items():
        monkeypatch.setenv(name, value)


def test_engine_defaults(monkeypatch):
    set_env(monkeypatch, REQUIRED_ENGINE_ENV)
    engine = engine_from_env()

    assert engine.engine_id == "customer-support-engine"
    assert engine.display_name == "customer-support-engine"
    assert engine.endpoint_location == "eu"
    assert engine.table_id_prefix == "export_customer_support_engine"


def test_engine_overrides(monkeypatch):
    set_env(monkeypatch, {
        **REQUIRED_ENGINE_ENV,
        "DISPLAY_NAME": "Support Copilot",
        "ENDPOINT_LOCATION": "global",
        "TABLE_ID_PREFIX": "export_custom",
    })
    engine = engine_from_env()

    assert engine.display_name == "Support Copilot"
    assert engine.endpoint_location == "global"
    assert engine.table_id_prefix == "export_custom"


def test_engine_id_required(monkeypatch):
    set_env(monkeypatch, {"ENGINE_LOCATION": "eu"})
    with pytest.raises(ValueError, match="ENGINE_ID"):
        engine_from_env()


def test_pipeline_defaults(monkeypatch):
    set_env(monkeypatch, REQUIRED_PIPELINE_ENV)
    pipeline = pipeline_from_env()

    assert pipeline.engine_project_id == "analytics-project"
    assert pipeline.staging_project_id == "analytics-project"
    assert pipeline.analytics_project_id == "analytics-project"
    assert pipeline.analytics_table == "export_history"


def test_pipeline_staging_defaults_to_engine_project(monkeypatch):
    set_env(monkeypatch, {**REQUIRED_PIPELINE_ENV, "ENGINE_PROJECT_ID": "engine-project"})
    pipeline = pipeline_from_env()

    assert pipeline.staging_project_id == "engine-project"
    assert pipeline.analytics_project_id == "analytics-project"


def test_pipeline_analytics_dataset_required(monkeypatch):
    set_env(monkeypatch, {"PROJECT_ID": "p", "STAGING_DATASET": "s"})
    with pytest.raises(ValueError, match="ANALYTICS_DATASET"):
        pipeline_from_env()
