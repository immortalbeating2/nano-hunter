#!/usr/bin/env python3
"""Audit first-pass VFX anchor/blend rule sidecars."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_RULE_DIR = "assets/art/vfx/vfx_rules"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit generated VFX rules.")
    parser.add_argument("--rule-dir", default=DEFAULT_RULE_DIR)
    parser.add_argument("--strict", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def audit_rule_file(root: Path, path: Path) -> tuple[dict[str, Any], list[str]]:
    data = load_json(path)
    asset_id = str(data.get("asset_id", path.stem))
    errors: list[str] = []
    source_texture = str(data.get("source_texture", ""))
    if not source_texture or not resolve_path(root, source_texture).exists():
        errors.append(f"{asset_id}: missing source_texture")
    rules = data.get("rules", [])
    if int(data.get("frame_count", -1)) != len(rules):
        errors.append(f"{asset_id}: frame_count mismatch")
    collision_disabled = 0
    damage_disabled = 0
    for rule in rules:
        index = rule.get("index", "?")
        anchor = rule.get("anchor_px", [])
        normalized = rule.get("anchor_normalized", [])
        region = rule.get("region", [])
        if len(region) != 4 or int(region[2]) <= 0 or int(region[3]) <= 0:
            errors.append(f"{asset_id}:{index}: invalid region")
        if len(anchor) != 2:
            errors.append(f"{asset_id}:{index}: missing anchor_px")
        if len(normalized) != 2:
            errors.append(f"{asset_id}:{index}: missing anchor_normalized")
        if not rule.get("recommended_blend"):
            errors.append(f"{asset_id}:{index}: missing recommended_blend")
        if bool(rule.get("gameplay_collision", True)) is False:
            collision_disabled += 1
        else:
            errors.append(f"{asset_id}:{index}: gameplay_collision must be false")
        if bool(rule.get("damage_source", True)) is False:
            damage_disabled += 1
        else:
            errors.append(f"{asset_id}:{index}: damage_source must be false")
    return (
        {
            "asset_id": asset_id,
            "path": path.as_posix(),
            "frame_count": len(rules),
            "collision_disabled_count": collision_disabled,
            "damage_disabled_count": damage_disabled,
            "manual_review_required": bool(data.get("manual_review_required", False)),
        },
        errors,
    )


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    rule_dir = resolve_path(root, args.rule_dir)
    index_path = rule_dir / "vfx_rules.index.json"
    errors: list[str] = []
    if not index_path.exists():
        errors.append(f"missing index: {index_path.as_posix()}")
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    index = load_json(index_path)
    rows: list[dict[str, Any]] = []
    for entry in index.get("assets", []):
        path = resolve_path(root, entry["path"])
        if not path.exists():
            errors.append(f"missing rule file: {entry['path']}")
            continue
        row, row_errors = audit_rule_file(root, path)
        rows.append(row)
        errors.extend(row_errors)

    expected_assets = int(index.get("asset_count", -1))
    expected_frames = int(index.get("frame_rule_count", -1))
    actual_assets = len(rows)
    actual_frames = sum(int(row["frame_count"]) for row in rows)
    collision_disabled = sum(int(row["collision_disabled_count"]) for row in rows)
    damage_disabled = sum(int(row["damage_disabled_count"]) for row in rows)
    if actual_assets != expected_assets:
        errors.append(f"asset_count mismatch expected {expected_assets} got {actual_assets}")
    if actual_frames != expected_frames:
        errors.append(f"frame_rule_count mismatch expected {expected_frames} got {actual_frames}")
    if collision_disabled != actual_frames:
        errors.append("not all VFX rules disable gameplay_collision")
    if damage_disabled != actual_frames:
        errors.append("not all VFX rules disable damage_source")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "VFX rules OK: "
        f"{actual_assets} assets, {actual_frames} frame rules, "
        f"{collision_disabled} collision-disabled rules."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
