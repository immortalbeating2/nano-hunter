#!/usr/bin/env python3
"""Audit the P0 target-scene replacement matrix."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REPORT_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.json")
MARKDOWN_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.md")
PLAN_PATH = Path("docs/assets/p0-runtime-replacement-plan.json")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit P0 target-scene replacement matrix.")
    parser.add_argument("--strict", action="store_true", help="Return failure when the matrix is incomplete.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(report: dict[str, Any], plan: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    summary = report.get("summary", {})
    scenes = report.get("scenes", [])
    plan_entries = plan.get("entries", [])
    expected_asset_ids = {str(entry.get("asset_id", "")) for entry in plan_entries if entry.get("asset_id")}
    expected_reference_count = sum(len(entry.get("target_scene_status", [])) for entry in plan_entries)
    expected_planned_count = sum(
        1
        for entry in plan_entries
        for scene in entry.get("target_scene_status", [])
        if not scene.get("already_references_resource", False)
    )
    matrix_asset_ids = {
        str(asset.get("asset_id", ""))
        for scene in scenes
        for asset in scene.get("assets", [])
        if asset.get("asset_id")
    }
    if int(summary.get("scene_count", -1)) != len(scenes):
        errors.append("scene_count mismatch")
    if matrix_asset_ids != expected_asset_ids:
        errors.append("unique asset ids do not match P0 runtime plan")
    if int(summary.get("unique_asset_count", -1)) != len(expected_asset_ids):
        errors.append(f"unique_asset_count expected {len(expected_asset_ids)}")
    if int(summary.get("missing_scene_count", -1)) != 0:
        errors.append("missing_scene_count expected 0")
    if int(summary.get("scene_asset_reference_count", -1)) != expected_reference_count:
        errors.append(f"scene_asset_reference_count expected {expected_reference_count}")
    if int(summary.get("planned_scene_asset_replacement_count", -1)) != expected_planned_count:
        errors.append(f"planned_scene_asset_replacement_count expected {expected_planned_count}")
    if not MARKDOWN_PATH.exists():
        errors.append("markdown_missing")
    for scene in scenes:
        scene_path = str(scene.get("scene", ""))
        if not scene.get("exists"):
            errors.append(f"{scene_path}: scene missing")
        if int(scene.get("asset_count", 0)) <= 0:
            errors.append(f"{scene_path}: asset_count missing")
        if not scene.get("validation_commands"):
            errors.append(f"{scene_path}: validation_commands missing")
        for asset in scene.get("assets", []):
            if not asset.get("asset_id"):
                errors.append(f"{scene_path}: empty asset_id")
            if not asset.get("resource_path"):
                errors.append(f"{scene_path}: empty resource_path")
            if not asset.get("replacement_risk"):
                errors.append(f"{scene_path}: replacement_risk missing for {asset.get('asset_id')}")
    return errors


def main() -> int:
    args = parse_args()
    if not REPORT_PATH.exists():
        print("P0 target scene replacement matrix missing")
        return 1 if args.strict else 0
    if not PLAN_PATH.exists():
        print("P0 runtime replacement plan missing")
        return 1 if args.strict else 0
    report = load_json(REPORT_PATH)
    plan = load_json(PLAN_PATH)
    errors = audit(report, plan)
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    summary = report["summary"]
    print(
        "P0 target scene replacement matrix OK: "
        f"{summary['scene_count']} scenes, "
        f"{summary['unique_asset_count']} assets, "
        f"{summary['scene_asset_reference_count']} scene-asset references."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
