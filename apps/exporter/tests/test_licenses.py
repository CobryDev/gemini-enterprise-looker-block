from datetime import UTC, date, datetime

import pytest

from gemini_exporter import licenses, main


class FakeResponse:
    def __init__(self, body):
        self._body = body
        self.ok = True
        self.status_code = 200
        self.text = ""

    def json(self):
        return self._body

    def raise_for_status(self):
        pass


class FakeSession:
    def __init__(self, pages):
        self.pages = list(pages)
        self.calls = []

    def get(self, url, params, headers, timeout):
        self.calls.append((url, dict(params), headers))
        return FakeResponse(self.pages.pop(0))


def test_user_store_base_url():
    assert licenses.user_store_base_url("global") == "https://discoveryengine.googleapis.com/v1"
    assert licenses.user_store_base_url("eu") == "https://eu-discoveryengine.googleapis.com/v1"


def test_list_user_licenses_follows_pages():
    session = FakeSession([
        {"userLicenses": [{"userPrincipal": "a@example.com"}], "nextPageToken": "next"},
        {"userLicenses": [{"userPrincipal": "b@example.com"}]},
    ])

    rows = list(licenses.list_user_licenses(session, project_id="engine-project", location="eu"))

    assert [row["userPrincipal"] for row in rows] == ["a@example.com", "b@example.com"]
    url, first_params, headers = session.calls[0]
    assert url == (
        "https://eu-discoveryengine.googleapis.com/v1/projects/engine-project/locations/eu"
        "/userStores/default_user_store/userLicenses"
    )
    assert "pageToken" not in first_params
    assert session.calls[1][1]["pageToken"] == "next"
    assert headers == {"X-Goog-User-Project": "engine-project"}


def test_license_row_normalises_fields():
    ingested_at = datetime(2026, 9, 30, 5, tzinfo=UTC)
    row = licenses.license_row(
        {
            "userPrincipal": "Ada.Lovelace@Example.com",
            "licenseAssignmentState": "ASSIGNED",
            "licenseConfig": "projects/123/locations/global/licenseConfigs/enterprise-plus",
            "createTime": "2026-01-01T00:00:00Z",
            "lastLoginTime": "2026-09-29T08:00:00Z",
        },
        snapshot_date=date(2026, 9, 30),
        location="global",
        ingested_at=ingested_at,
    )

    assert row["snapshot_date"] == "2026-09-30"
    assert row["user_email"] == "ada.lovelace@example.com"
    assert row["license_state"] == "ASSIGNED"
    assert row["license_config"] == "enterprise-plus"
    assert row["update_time"] is None
    assert row["last_login_time"] == "2026-09-29T08:00:00Z"


def test_user_store_locations(monkeypatch):
    monkeypatch.setenv("USER_STORE_LOCATIONS", "global, eu,")
    assert licenses.user_store_locations() == ["global", "eu"]

    monkeypatch.delenv("USER_STORE_LOCATIONS")
    assert licenses.user_store_locations() == ["global"]


@pytest.mark.parametrize(
    ("mode", "target"),
    [("transform_logs", "gemini_exporter.transform_logs.run"),
     ("snapshot_licenses", "gemini_exporter.licenses.run")],
)
def test_main_dispatches_by_mode(monkeypatch, mode, target):
    calls = []
    monkeypatch.setenv("MODE", mode)
    monkeypatch.setattr(target, lambda: calls.append(mode))
    monkeypatch.setattr(main, "run_export", lambda: calls.append("export"))

    main.main()

    assert calls == [mode]


def test_main_defaults_to_export(monkeypatch):
    calls = []
    monkeypatch.delenv("MODE", raising=False)
    monkeypatch.setattr(main, "run_export", lambda: calls.append("export"))

    main.main()

    assert calls == ["export"]


def test_main_rejects_unknown_mode(monkeypatch):
    monkeypatch.setenv("MODE", "backfill")
    with pytest.raises(ValueError, match="Unknown MODE"):
        main.main()
