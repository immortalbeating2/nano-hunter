#!/usr/bin/env python3
"""Audit generated Spine-style cutout descriptor files."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit Spine-style cutout exports generated from image-gen parts atlases.",
    )
    parser.add_argument(
        "--index",
        default="assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json",
        help="Path to generated spine cutout export index.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure if any mismatch is found.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_res_path(root: Path, value: str) -> Path:
    if value.startswith("res://"):
        return root / value.removeprefix("res://")
    return Path(value)


def audit_asset(root: Path, asset: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    asset_id = asset["asset_id"]
    atlas_path = resolve_res_path(root, asset["atlas"])
    spine_json_path = resolve_res_path(root, asset["spine_style_json"])
    cutout_manifest_path = resolve_res_path(root, asset["cutout_manifest"])
    for path in (atlas_path, spine_json_path, cutout_manifest_path):
        if not path.exists():
            errors.append(f"{asset_id}: missing export {path}")

    if errors:
        return errors

    cutout_manifest = load_json(cutout_manifest_path)
    spine_json = load_json(spine_json_path)
    part_count = int(asset["part_count"])
    if int(cutout_manifest.get("part_count", -1)) != part_count:
        errors.append(f"{asset_id}: cutout manifest part_count mismatch")
    if len(cutout_manifest.get("parts", [])) != part_count:
        errors.append(f"{asset_id}: cutout manifest parts length mismatch")
    if len(spine_json.get("slots", [])) != part_count:
        errors.append(f"{asset_id}: spine-style slots length mismatch")
    skins = spine_json.get("skins", [])
    if not skins or len(skins[0].get("attachments", {})) != part_count:
        errors.append(f"{asset_id}: spine-style attachments length mismatch")

    atlas_text = atlas_path.read_text(encoding="utf-8")
    for part in cutout_manifest.get("parts", []):
        name = str(part["name"])
        region = part.get("region", [])
        if len(region) != 4 or any(int(value) <= 0 for value in region[2:]):
            errors.append(f"{asset_id}: invalid region for {name}")
        if name not in atlas_text:
            errors.append(f"{asset_id}: missing atlas region text for {name}")
    return errors


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    index_path = (repo_root / args.index).resolve()
    if not index_path.exists():
        print(f"Missing index: {index_path}")
        return 1
    index = load_json(index_path)
    errors: list[str] = []
    total_parts = 0
    for asset in index.get("assets", []):
        total_parts += int(asset.get("part_count", 0))
        errors.extend(audit_asset(repo_root, asset))

    expected_assets = int(index.get("asset_count", -1))
    if len(index.get("assets", [])) != expected_assets:
        errors.append("index asset_count mismatch")
    if total_parts != int(index.get("part_count", -1)):
        errors.append("index part_count mismatch")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    print(f"Audited {expected_assets} Spine-style cutout exports with {total_parts} parts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
