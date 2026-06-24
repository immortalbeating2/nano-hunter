#!/usr/bin/env python3
"""Audit the P0 target-scene replacement matrix."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REPORT_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.json")
MARKDOWN_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.md")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit P0 target-scene replacement matrix.")
    parser.add_argument("--strict", action="store_true", help="Return failure when the matrix is incomplete.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(report: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    summary = report.get("summary", {})
    scenes = report.get("scenes", [])
    if int(summary.get("scene_count", -1)) != len(scenes):
        errors.append("scene_count mismatch")
    if int(summary.get("unique_asset_count", -1)) != 30:
        errors.append("unique_asset_count expected 30")
    if int(summary.get("missing_scene_count", -1)) != 0:
        errors.append("missing_scene_count expected 0")
    if int(summary.get("scene_asset_reference_count", -1)) < 30:
        errors.append("scene_asset_reference_count must be >= 30")
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
    report = load_json(REPORT_PATH)
    errors = audit(report)
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
