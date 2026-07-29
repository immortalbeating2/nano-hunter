#!/usr/bin/env python3
"""Audit the P0 runtime replacement plan."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REPORT_PATH = Path("docs/assets/p0-runtime-replacement-plan.json")
MARKDOWN_PATH = Path("docs/assets/p0-runtime-replacement-plan.md")
RUNTIME_MAP_PATH = Path("docs/assets/asset-runtime-integration-map.json")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit P0 runtime replacement plan.")
    parser.add_argument("--strict", action="store_true", help="Return failure when the plan is incomplete.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(report: dict[str, Any], runtime_map: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    entries = report.get("entries", [])
    summary = report.get("summary", {})
    expected_ids = {
        str(entry.get("asset_id", ""))
        for entry in runtime_map.get("entries", [])
        if entry.get("priority") == "P0" and str(entry.get("track", "")).startswith("runtime_")
    }
    actual_ids = {str(entry.get("asset_id", "")) for entry in entries}
    if actual_ids != expected_ids:
        errors.append(f"entry asset ids mismatch: expected {len(expected_ids)} got {len(actual_ids)}")
    if int(summary.get("asset_count", -1)) != len(expected_ids):
        errors.append("summary asset_count mismatch")
    if int(summary.get("missing_resource_count", -1)) != 0:
        errors.append("missing_resource_count expected 0")
    if int(summary.get("missing_target_scene_count", -1)) != 0:
        errors.append("missing_target_scene_count expected 0")
    if not MARKDOWN_PATH.exists():
        errors.append("markdown_missing")
    for entry in entries:
        asset_id = str(entry.get("asset_id", "unknown"))
        if not entry.get("resource_exists"):
            errors.append(f"{asset_id}: resource missing")
        if not entry.get("output_exists"):
            errors.append(f"{asset_id}: output missing")
        if not entry.get("target_scene_status"):
            errors.append(f"{asset_id}: target scenes missing")
        for scene in entry.get("target_scene_status", []):
            if not scene.get("exists"):
                errors.append(f"{asset_id}: target scene missing {scene.get('scene')}")
        if not entry.get("replacement_mode"):
            errors.append(f"{asset_id}: replacement mode missing")
        if not entry.get("validation_commands"):
            errors.append(f"{asset_id}: validation commands missing")
    return errors


def main() -> int:
    args = parse_args()
    if not REPORT_PATH.exists():
        print("P0 runtime replacement plan missing")
        return 1 if args.strict else 0
    if not RUNTIME_MAP_PATH.exists():
        print("asset runtime integration map missing")
        return 1 if args.strict else 0
    report = load_json(REPORT_PATH)
    runtime_map = load_json(RUNTIME_MAP_PATH)
    errors = audit(report, runtime_map)
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    summary = report["summary"]
    print(
        "P0 runtime replacement plan OK: "
        f"{summary['asset_count']} entries, "
        f"{summary['planned_manual_replacement_count']} planned replacements, "
        f"{summary['already_referenced_count']} already referenced."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
