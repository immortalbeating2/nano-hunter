#!/usr/bin/env python3
"""Audit generated AtlasTexture editor resources before Godot import."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate editor AtlasTexture index and generated .tres files.",
    )
    parser.add_argument(
        "--index",
        default="assets/art/editor_resources/editor_atlas_textures.index.json",
        help="Path to generated editor AtlasTexture index.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail on any missing resource or malformed region.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def res_to_path(root: Path, value: str) -> Path:
    if not value.startswith("res://"):
        raise ValueError(f"Expected res:// path: {value}")
    return root / value.removeprefix("res://")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    index_path = (root / args.index).resolve()
    if not index_path.exists():
        print(f"Missing editor AtlasTexture index: {index_path}")
        return 1 if args.strict else 0

    index = load_json(index_path)
    errors: list[str] = []
    checked = 0
    for asset in index.get("assets", []):
        source_texture = res_to_path(root, asset["source_texture"])
        if not source_texture.exists():
            errors.append(f"{asset['id']}: missing source texture {source_texture}")
        for resource in asset.get("resources", []):
            checked += 1
            resource_path = res_to_path(root, resource["resource"])
            if not resource_path.exists():
                errors.append(f"{asset['id']}: missing resource {resource_path}")
                continue
            region = resource.get("region", [])
            if len(region) != 4 or int(region[2]) <= 0 or int(region[3]) <= 0:
                errors.append(f"{asset['id']}: malformed region {region} in {resource_path}")
            text = resource_path.read_text(encoding="utf-8")
            if 'type="AtlasTexture"' not in text:
                errors.append(f"{asset['id']}: resource is not AtlasTexture {resource_path}")
            if "atlas = ExtResource(\"1\")" not in text or "region = Rect2(" not in text:
                errors.append(f"{asset['id']}: missing atlas or region property {resource_path}")

    expected = int(index.get("resource_count", -1))
    if expected != checked:
        errors.append(f"index resource_count={expected}, checked={checked}")

    for error in errors:
        print(f"ERROR: {error}")
    print(f"Audited {checked} editor AtlasTexture resources across {len(index.get('assets', []))} assets.")
    if errors and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
