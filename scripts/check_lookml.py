#!/usr/bin/env python3
"""Parse-check every LookML file in the repo.

Model/view/explore/manifest files use brace LookML (parsed with the `lkml`
package); dashboard files use YAML and get structural sanity checks on top of
the parse. Every field a dashboard references (fields, pivots, sorts, filters,
listen targets) must exist in the explore it names, as resolved through the
model's includes and the explore's joins. This does not replace Looker's own
content validation, but it catches syntax errors, malformed dashboards and
mistyped field names in CI before install time.
"""

from __future__ import annotations

import glob
import re
import sys
from pathlib import Path

import lkml
import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent


def check_lkml_files() -> list[str]:
    failures = []
    paths = sorted(
        path
        for path in glob.glob(str(REPO_ROOT / "looker" / "**" / "*.lkml"), recursive=True)
        if not path.endswith(".dashboard.lookml")
    )
    paths.append(str(REPO_ROOT / "manifest.lkml"))

    for path in paths:
        try:
            lkml.load(Path(path).read_text())
        except Exception as exc:  # noqa: BLE001 - report every parser failure
            failures.append(f"{path}: {exc}")
    return failures


def view_fields(view: dict) -> set[str]:
    fields = {d["name"] for d in view.get("dimensions", []) + view.get("measures", [])}
    fields |= {f["name"] for f in view.get("filters", []) + view.get("parameters", [])}
    for group in view.get("dimension_groups", []):
        if group.get("type") == "duration":
            fields |= {f"{interval}s_{group['name']}" for interval in group.get("intervals", [])}
        else:
            fields |= {f"{group['name']}_{timeframe}" for timeframe in group.get("timeframes", [])}
    return fields


def load_explore_fields() -> dict[tuple[str, str], set[str]]:
    """Map (model, explore) to every `view.field` the explore exposes."""
    views, explores = {}, {}
    for path in glob.glob(str(REPO_ROOT / "looker" / "**" / "*.lkml"), recursive=True):
        parsed = lkml.load(Path(path).read_text())
        for view in parsed.get("views", []):
            views[view["name"]] = view_fields(view)
        for explore in parsed.get("explores", []):
            explores[(Path(path).resolve(), explore["name"])] = explore

    result = {}
    for model_path in glob.glob(str(REPO_ROOT / "looker" / "models" / "*.model.lkml")):
        model = Path(model_path).name.removesuffix(".model.lkml")
        included = set()
        for pattern in lkml.load(Path(model_path).read_text()).get("includes", []):
            included |= {Path(p).resolve() for p in glob.glob(str(REPO_ROOT / pattern.lstrip("/")))}
        for (explore_path, name), explore in explores.items():
            if explore_path not in included:
                continue
            aliases = {name: explore.get("from") or explore.get("view_name") or name}
            for join in explore.get("joins", []):
                aliases[join["name"]] = join.get("from") or join["name"]
            result[(model, name)] = {
                f"{alias}.{field}" for alias, view in aliases.items() for field in views.get(view, set())
            }
    return result


def dashboard_field_refs(dashboard: dict):
    for dash_filter in dashboard.get("filters", []):
        if "field" in dash_filter:
            yield dash_filter.get("model"), dash_filter.get("explore"), dash_filter["field"], "filter"
    for element in dashboard.get("elements", []):
        model, explore = element.get("model"), element.get("explore")
        refs = list(element.get("fields", [])) + list(element.get("pivots", []))
        refs += [sort.split()[0] for sort in element.get("sorts", [])]
        refs += list((element.get("filters") or {}).keys())
        refs += list((element.get("listen") or {}).values())
        for ref in refs:
            yield model, explore, ref, element["name"]


def check_dashboard_fields(explore_fields: dict[tuple[str, str], set[str]], dashboard: dict) -> None:
    for model, explore, ref, where in dashboard_field_refs(dashboard):
        known = explore_fields.get((model, explore))
        if known is None:
            raise ValueError(f"{where}: unknown explore {model}::{explore}")
        if ref not in known:
            raise ValueError(f"{where}: {ref} is not a field of {model}::{explore}")


def check_dashboard_files() -> list[str]:
    failures = []
    explore_fields = load_explore_fields()
    for path in sorted(glob.glob(str(REPO_ROOT / "looker" / "dashboards" / "*.dashboard.lookml"))):
        try:
            data = yaml.safe_load(Path(path).read_text())
            if not (isinstance(data, list) and data and "dashboard" in data[0]):
                raise ValueError("expected a YAML list starting with '- dashboard:'")
            dashboard = data[0]
            tabs = {t["name"] for t in dashboard.get("tabs", [])}
            if len(tabs) > 5:
                raise ValueError(f"{len(tabs)} tabs; Looker allows at most 5")
            for element in dashboard.get("elements", []):
                if tabs and element.get("tab_name") not in tabs:
                    raise ValueError(f"element {element.get('name', '?')} has unknown tab_name {element.get('tab_name')}")
            names = set()
            for element in dashboard.get("elements", []):
                required = ("name", "type") if element.get("type") == "text" else ("name", "title", "type", "model", "explore")
                for key in required:
                    if key not in element:
                        raise ValueError(f"element {element.get('name', '?')} missing '{key}'")
                if element["name"] in names:
                    raise ValueError(f"duplicate element name {element['name']}")
                names.add(element["name"])
            filter_names = {f["name"] for f in dashboard.get("filters", [])}
            for element in dashboard.get("elements", []):
                unknown = set(element.get("listen", {})) - filter_names
                if unknown:
                    raise ValueError(f"element {element['name']} listens to unknown filters {unknown}")
            check_dashboard_fields(explore_fields, dashboard)
        except Exception as exc:  # noqa: BLE001 - report every parser failure
            failures.append(f"{path}: {exc}")
    return failures


HARDCODED_TABLE = re.compile(r"`(?!@\{)[A-Za-z0-9_-]+\.[A-Za-z0-9_]+")
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@(?!example\.com\b)[A-Za-z0-9-]+\.[A-Za-z.]{2,}")


def check_portability() -> list[str]:
    """The block installs into any tenant, so LookML must not name a specific
    project, dataset or person: every table goes through the manifest
    constants and no email addresses appear outside example.com."""
    failures = []
    paths = glob.glob(str(REPO_ROOT / "looker" / "**" / "*.lkml"), recursive=True)
    paths += glob.glob(str(REPO_ROOT / "looker" / "**" / "*.lookml"), recursive=True)
    paths += [str(REPO_ROOT / "manifest.lkml"), str(REPO_ROOT / "marketplace.json")]
    for path in sorted(paths):
        for number, line in enumerate(Path(path).read_text().splitlines(), start=1):
            if HARDCODED_TABLE.search(line):
                failures.append(f"{path}:{number}: table reference must use @{{gemini_project}} constants")
            if EMAIL.search(line):
                failures.append(f"{path}:{number}: hardcoded email address")
    return failures


def main() -> int:
    failures = check_lkml_files() + check_dashboard_files() + check_portability()
    if failures:
        print("\n".join(failures))
        return 1
    print("All LookML and dashboard files parse OK and are tenant-neutral")
    return 0


if __name__ == "__main__":
    sys.exit(main())
