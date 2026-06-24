#!/usr/bin/env python3
"""Audit first-pass character animation rule sidecars."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_RULE_DIR = "assets/art/characters/animation_rules"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit generated character animation rules.")
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
    sprite_frames = str(data.get("sprite_frames", ""))
    if not source_texture or not resolve_path(root, source_texture).exists():
        errors.append(f"{asset_id}: missing source_texture")
    if not sprite_frames or not resolve_path(root, sprite_frames).exists():
        errors.append(f"{asset_id}: missing sprite_frames")
    rules = data.get("rules", [])
    if int(data.get("frame_count", -1)) != len(rules):
        errors.append(f"{asset_id}: frame_count mismatch")
    if float(data.get("speed_fps", 0)) <= 0:
        errors.append(f"{asset_id}: speed_fps must be positive")
    if len(data.get("default_pivot_px", [])) != 2:
        errors.append(f"{asset_id}: missing default_pivot_px")
    if int(data.get("default_foot_baseline_y", 0)) <= 0:
        errors.append(f"{asset_id}: invalid default_foot_baseline_y")
    for rule in rules:
        index = rule.get("index", "?")
        if len(rule.get("region", [])) != 4:
            errors.append(f"{asset_id}:{index}: invalid region")
        if len(rule.get("pivot_px", [])) != 2:
            errors.append(f"{asset_id}:{index}: missing pivot_px")
        if float(rule.get("frame_duration_sec", 0)) <= 0:
            errors.append(f"{asset_id}:{index}: invalid frame_duration_sec")
        if not rule.get("phase"):
            errors.append(f"{asset_id}:{index}: missing phase")
    return (
        {
            "asset_id": asset_id,
            "path": path.as_posix(),
            "frame_count": len(rules),
            "animation_name": data.get("animation_name", ""),
            "speed_fps": data.get("speed_fps", 0),
            "loop": data.get("loop", False),
            "manual_review_required": bool(data.get("manual_review_required", False)),
        },
        errors,
    )


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    rule_dir = resolve_path(root, args.rule_dir)
    index_path = rule_dir / "animation_rules.index.json"
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
    if actual_assets != expected_assets:
        errors.append(f"asset_count mismatch expected {expected_assets} got {actual_assets}")
    if actual_frames != expected_frames:
        errors.append(f"frame_rule_count mismatch expected {expected_frames} got {actual_frames}")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(f"Animation rules OK: {actual_assets} assets, {actual_frames} frame rules.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
