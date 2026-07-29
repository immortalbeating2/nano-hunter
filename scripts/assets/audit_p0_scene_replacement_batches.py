#!/usr/bin/env python3
"""Audit P0 scene replacement batches."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REPORT_PATH = Path("docs/assets/p0-scene-replacement-batches.json")
MARKDOWN_PATH = Path("docs/assets/p0-scene-replacement-batches.md")
MATRIX_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.json")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit P0 scene replacement batches.")
    parser.add_argument("--strict", action="store_true", help="Return failure when the report is incomplete.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(report: dict[str, Any], matrix: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    summary = report.get("summary", {})
    batches = report.get("batches", [])
    matrix_summary = matrix.get("summary", {})
    if int(summary.get("batch_count", -1)) != len(batches):
        errors.append("batch_count mismatch")
    if not batches:
        errors.append("no replacement batches")
    for key in (
        "scene_count",
        "unique_asset_count",
        "scene_asset_reference_count",
        "planned_scene_asset_replacement_count",
        "already_referenced_scene_asset_count",
    ):
        if int(summary.get(key, -1)) != int(matrix_summary.get(key, -2)):
            errors.append(f"{key} does not match target scene matrix")
    if int(summary.get("missing_scene_count", -1)) != 0:
        errors.append("missing_scene_count expected 0")
    if int(summary.get("unbatched_scene_count", -1)) != 0:
        errors.append("unbatched_scene_count expected 0")
    if not MARKDOWN_PATH.exists():
        errors.append("markdown_missing")

    batch_ids: set[str] = set()
    seen_scenes: set[str] = set()
    seen_assets: set[str] = set()
    reference_total = 0
    for expected_order, batch in enumerate(batches):
        batch_id = str(batch.get("batch_id", ""))
        if not batch_id:
            errors.append("empty batch_id")
        if batch_id in batch_ids:
            errors.append(f"{batch_id}: duplicate batch_id")
        batch_ids.add(batch_id)
        if int(batch.get("recommended_order", -1)) != expected_order:
            errors.append(f"{batch_id}: recommended_order mismatch")
        if not batch.get("validation_commands"):
            errors.append(f"{batch_id}: validation_commands missing")
        if not batch.get("purpose"):
            errors.append(f"{batch_id}: purpose missing")
        if not batch.get("replacement_gate_status"):
            errors.append(f"{batch_id}: replacement_gate_status missing")
        if batch.get("missing_scenes"):
            errors.append(f"{batch_id}: missing_scenes not empty")
        if int(batch.get("scene_count", -1)) != len(batch.get("scenes", [])):
            errors.append(f"{batch_id}: scene_count mismatch")
        if int(batch.get("scene_asset_reference_count", 0)) <= 0:
            errors.append(f"{batch_id}: empty scene_asset_reference_count")
        reference_total += int(batch.get("scene_asset_reference_count", 0))
        for scene in batch.get("scenes", []):
            scene_path = str(scene.get("scene", ""))
            if not scene_path:
                errors.append(f"{batch_id}: empty scene")
            if scene_path in seen_scenes:
                errors.append(f"{scene_path}: scene appears in multiple batches")
            seen_scenes.add(scene_path)
            if not scene.get("exists"):
                errors.append(f"{scene_path}: scene missing")
        for asset in batch.get("assets", []):
            asset_id = str(asset.get("asset_id", ""))
            if not asset_id:
                errors.append(f"{batch_id}: empty asset_id")
            seen_assets.add(asset_id)
            if not asset.get("resource_path"):
                errors.append(f"{batch_id}: {asset_id}: resource_path missing")
            if not asset.get("replacement_risk"):
                errors.append(f"{batch_id}: {asset_id}: replacement_risk missing")

    if reference_total != int(summary.get("scene_asset_reference_count", -1)):
        errors.append("scene_asset_reference_count does not match batch total")
    if len(seen_scenes) != int(summary.get("scene_count", -1)):
        errors.append("scene_count does not match unique scene total")
    if len(seen_assets) != int(summary.get("unique_asset_count", -1)):
        errors.append("unique_asset_count does not match unique asset total")
    return errors


def main() -> int:
    args = parse_args()
    if not REPORT_PATH.exists():
        print("P0 scene replacement batches missing")
        return 1 if args.strict else 0
    if not MATRIX_PATH.exists():
        print("P0 target scene replacement matrix missing")
        return 1 if args.strict else 0
    report = load_json(REPORT_PATH)
    matrix = load_json(MATRIX_PATH)
    errors = audit(report, matrix)
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    summary = report["summary"]
    print(
        "P0 scene replacement batches OK: "
        f"{summary['batch_count']} batches, "
        f"{summary['scene_count']} scenes, "
        f"{summary['unique_asset_count']} assets, "
        f"{summary['scene_asset_reference_count']} scene-asset references."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
