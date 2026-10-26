import json
import re
from datetime import UTC, datetime
from pathlib import Path

import pytest

from gemini_exporter.transform_logs import (
    TRANSFORMS,
    LogTransformConfig,
    config_from_env,
    load_transform_sql,
    query_parameters,
    render_transform_sql,
)

FIXTURES = Path(__file__).parent / "fixtures"
LOGS_TF = (
    Path(__file__).resolve().parents[3]
    / "infra/terraform/modules/gemini_analytics_pipeline/logs.tf"
)

CONFIG = LogTransformConfig(
    project_id="analytics-project",
    analytics_project_id="analytics-project",
    analytics_dataset="gemini_analytics",
    raw_logs_view="analytics-project.gemini_logs_raw._AllLogs",
    lookback_hours=3,
    app_names={"support-engine": "Support Copilot", "hr-engine": "HR Assistant"},
)

# JSON paths that hold prompt, response, grounding, file or argument content.
# The transforms must never read them, even to copy a fragment.
FORBIDDEN_SQL_PATTERNS = {
    r"\.text\b": "prompt or answer text parts",
    r"\.content\b|\['content'\]": "message or grounding content",
    r"serviceTextReply": "assistant reply text",
    r"searchQuery": "search query text",
    r"JSON_VALUE\(p\.request\.query\)": "search query text",
    r"request\.query(?!\.parts\b|\s+IS NOT NULL)": "prompt object",
    r"\.title\b": "document or event titles",
    r"\.uri\b": "document URIs",
    r"\.description\b": "agent instructions",
    r"fileName": "file names",
    r"\.comment\b": "feedback comments",
    r"\.args\b": "action arguments",
    r"\.arguments(?!\.skill_name\b)": "tool arguments other than skill_name",
    r"gen_ai\.input\.messages": "replayed conversation",
    r"gen_ai\.user\.message|gen_ai\.choice": "content-only gen_ai logs",
    r"\.members\b": "IAM policy members",
    r"InferenceRequestLog": "Antigravity prompts",
    r"audit\.request\b": "audit request bodies",
    r"audit\.response\.(?!sanitizationResult\b|sanitization_result\b)": "audit response bodies",
    r"TO_JSON_STRING|JSON_QUERY\(": "copying whole JSON subtrees",
}

# Curated column names that would suggest content is being stored.
CONTENT_COLUMN_PATTERN = re.compile(
    r"prompt|query|text|content|message|title|uri|snippet|argument|comment|reply|response"
)
CONTENT_COLUMN_ALLOWED = {"is_user_prompt", "screened_content"}


def strip_comments(sql):
    return re.sub(r"--[^\n]*", "", sql)


def curated_schemas():
    if not LOGS_TF.exists():
        pytest.skip("Terraform module not present alongside the exporter")
    text = LOGS_TF.read_text()
    schemas = {}
    for block in re.finditer(
        r"\n    (\w+) = \{\n      description.*?\n      schema = \[\n(.*?)\n      \]", text, re.S
    ):
        schemas[block.group(1)] = re.findall(
            r'name = "(\w+)", type = "(\w+)", mode = "(\w+)"', block.group(2)
        )
    return schemas


def insert_columns(sql):
    match = re.search(r"INSERT \((.*?)\)\s*VALUES", sql, re.S)
    return [column.strip() for column in match.group(1).split(",")]


def payload_paths(sql, *, include_presence_checks=True):
    """Dotted paths read from the payload alias p, with [0] kept as a segment."""
    sql = strip_comments(sql)
    if not include_presence_checks:
        sql = re.sub(r"\bp\.[\w.\[\]]+\s+IS NOT NULL", "", sql)
    return set(re.findall(r"\bp\.([A-Za-z_]\w*(?:\.[A-Za-z_@]\w*|\[0\])*)", sql))


def resolve(payload, path):
    segments = re.findall(r"[A-Za-z_@]\w*|\[0\]", path)
    nodes = [payload]
    for segment in segments:
        next_nodes = []
        for node in nodes:
            if segment == "[0]":
                if isinstance(node, list) and node:
                    next_nodes.append(node[0])
            elif isinstance(node, dict) and segment in node:
                next_nodes.append(node[segment])
        nodes = next_nodes
    return nodes


def content_leaves(payload, prefix=""):
    if isinstance(payload, dict):
        for key, value in payload.items():
            yield from content_leaves(value, f"{prefix}.{key}" if prefix else key)
    elif isinstance(payload, list):
        for value in payload:
            yield from content_leaves(value, prefix)
    elif isinstance(payload, str) and payload.startswith("<"):
        yield prefix


@pytest.mark.parametrize("name", TRANSFORMS)
def test_every_transform_has_sql_with_known_placeholders(name):
    placeholders = set(re.findall(r"\{(\w+)\}", load_transform_sql(name)))
    assert placeholders == {"raw_logs_view", "analytics_dataset"}


@pytest.mark.parametrize("name", TRANSFORMS)
def test_rendered_sql_targets_curated_table(name):
    sql = render_transform_sql(CONFIG, name)

    assert f"MERGE `analytics-project.gemini_analytics.{name}` AS target" in sql
    assert "FROM `analytics-project.gemini_logs_raw._AllLogs`" in sql
    assert "{" not in sql and "}" not in sql
    assert "@window_start" in sql
    # App names are bound as parameters, never inlined.
    assert "Support Copilot" not in sql


@pytest.mark.parametrize("name", TRANSFORMS)
def test_insert_columns_match_terraform_schema(name):
    schema = curated_schemas()[name]
    assert insert_columns(load_transform_sql(name)) == [column for column, _, _ in schema]


def test_curated_schemas_hold_no_content_columns():
    for table, schema in curated_schemas().items():
        for column, column_type, _ in schema:
            assert column_type != "JSON", f"{table}.{column} would copy a JSON subtree"
            if column in CONTENT_COLUMN_ALLOWED:
                continue
            assert not CONTENT_COLUMN_PATTERN.search(column), f"{table}.{column}"


@pytest.mark.parametrize("name", TRANSFORMS)
def test_sql_never_reads_content_paths(name):
    sql = strip_comments(load_transform_sql(name))
    for pattern, reason in FORBIDDEN_SQL_PATTERNS.items():
        assert not re.search(pattern, sql), f"{name} reads {reason} ({pattern})"


@pytest.mark.parametrize(
    "leak",
    [
        "JSON_VALUE(p.request.query.parts[0].text)",
        "JSON_VALUE(p.request.query)",
        "JSON_VALUE(reply.groundedContent.content.text)",
        "JSON_VALUE(p.serviceTextReply)",
        "JSON_VALUE(ref.documentMetadata.uri)",
        "JSON_VALUE(part.arguments.queries)",
        "JSON_VALUE(p.request.actionExecutionParams.args.body)",
        "TO_JSON_STRING(p.request)",
        "p['gen_ai.input.messages']",
    ],
)
def test_privacy_guard_catches_common_leaks(leak):
    assert any(re.search(pattern, leak) for pattern in FORBIDDEN_SQL_PATTERNS)


def test_connector_message_is_only_pattern_matched():
    sql = strip_comments(load_transform_sql("ge_connector_activity"))
    total = len(re.findall(r"json_payload\.message\b", sql))
    matched = len(re.findall(r"REGEXP_CONTAINS\(JSON_VALUE\(json_payload\.message\)", sql))
    null_checks = len(re.findall(r"json_payload\.message IS NULL", sql))
    assert total == matched + null_checks
    assert "AS message" not in sql


STATUS_MESSAGE_MATCH = re.compile(r"REGEXP_CONTAINS\(JSON_VALUE\(p\.status\.message\), r'[^']*'\)")


def strip_status_message_matches(sql):
    """Drop the pattern matches that turn the error message into fixed labels."""
    sql = STATUS_MESSAGE_MATCH.sub("", strip_comments(sql))
    return sql.replace("p.status.message IS NULL", "")


def test_status_message_is_only_pattern_matched():
    sql = strip_comments(load_transform_sql("ge_user_activity"))
    total = len(re.findall(r"p\.status\.message\b", sql))
    matched = len(STATUS_MESSAGE_MATCH.findall(sql))
    null_checks = len(re.findall(r"p\.status\.message IS NULL", sql))
    assert matched
    assert total == matched + null_checks
    assert "status_message" not in sql
    assert "p.status.message" not in strip_status_message_matches(sql)


def test_user_activity_paths_exist_in_real_payload_shapes():
    payloads = json.loads((FIXTURES / "user_activity_payloads.json").read_text())
    for path in payload_paths(load_transform_sql("ge_user_activity")):
        assert any(resolve(payload, path) for payload in payloads), path


def test_user_activity_never_reads_fixture_content():
    payloads = json.loads((FIXTURES / "user_activity_payloads.json").read_text())
    leaves = {leaf for payload in payloads for leaf in content_leaves(payload)}
    assert leaves, "fixture should carry content placeholders"

    sql = strip_status_message_matches(load_transform_sql("ge_user_activity"))
    for path in payload_paths(sql, include_presence_checks=False):
        assert path.replace("[0]", "") not in leaves, f"ge_user_activity reads {path}"


def test_gen_ai_keys_exist_in_real_payload_shape():
    payload = json.loads((FIXTURES / "gen_ai_payload.json").read_text())
    for name in ("ge_model_calls", "ge_tool_calls"):
        for key in re.findall(r"\['(gen_ai\.[\w.]+)'\]", load_transform_sql(name)):
            assert key in payload, f"{name}: {key}"


def test_query_parameters_pass_app_names_as_parallel_arrays():
    window_start = datetime(2026, 9, 30, 12, tzinfo=UTC)
    params = {param.name: param for param in query_parameters(CONFIG, window_start)}

    assert params["window_start"].value == window_start
    assert params["app_engine_ids"].values == ["hr-engine", "support-engine"]
    assert params["app_display_names"].values == ["HR Assistant", "Support Copilot"]


def test_query_parameters_allow_no_app_names():
    config = LogTransformConfig(**{**CONFIG.__dict__, "app_names": {}})
    params = {param.name: param for param in query_parameters(config, datetime.now(UTC))}

    assert params["app_engine_ids"].values == []
    assert params["app_display_names"].values == []


def test_config_from_env(monkeypatch):
    monkeypatch.setenv("PROJECT_ID", "analytics-project")
    monkeypatch.setenv("ANALYTICS_DATASET", "gemini_analytics")
    monkeypatch.setenv("RAW_LOGS_VIEW", "analytics-project.gemini_logs_raw._AllLogs")
    monkeypatch.setenv("APP_NAMES_JSON", '{"support-engine": "Support Copilot"}')
    monkeypatch.delenv("ANALYTICS_PROJECT_ID", raising=False)
    monkeypatch.delenv("LOOKBACK_HOURS", raising=False)

    config = config_from_env()

    assert config.analytics_project_id == "analytics-project"
    assert config.lookback_hours == 3
    assert config.app_names == {"support-engine": "Support Copilot"}


def test_config_rejects_non_object_app_names(monkeypatch):
    monkeypatch.setenv("PROJECT_ID", "analytics-project")
    monkeypatch.setenv("ANALYTICS_DATASET", "gemini_analytics")
    monkeypatch.setenv("RAW_LOGS_VIEW", "analytics-project.gemini_logs_raw._AllLogs")
    monkeypatch.setenv("APP_NAMES_JSON", '["support-engine"]')

    with pytest.raises(ValueError, match="APP_NAMES_JSON"):
        config_from_env()
