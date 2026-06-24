#!/usr/bin/env python3
"""审计 image gen 图集产物是否达到 manifest 的目标数量。"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit selected source counts, built atlas metadata, and SpriteFrames coverage.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail unless every output reaches expected_target and has matching metadata.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def count_sources(root: Path, item: dict[str, Any]) -> int:
    source_dir = resolve_path(root, item["source_dir"])
    if not source_dir.exists():
        return 0
    return sum(1 for path in source_dir.glob(item.get("source_glob", "*.png")) if path.is_file())


def count_duplicate_sources(root: Path, item: dict[str, Any]) -> int:
    source_dir = resolve_path(root, item["source_dir"])
    if not source_dir.exists():
        return 0
    return sum(1 for path in source_dir.glob("*_duplicate_*.png") if path.is_file())


def metadata_count(path: Path) -> int | None:
    if not path.exists():
        return None
    data = load_json(path)
    if "frames" in data:
        return len(data["frames"])
    if "regions" in data:
        return len(data["regions"])
    return None


def image_size(path: Path) -> tuple[int, int] | None:
    if not path.exists():
        return None
    with Image.open(path) as image:
        return image.size


def audit_item(root: Path, item: dict[str, Any]) -> tuple[str, bool]:
    asset_id = item["id"]
    expected_target = int(item.get("expected_target", item.get("expected_min", 1)))
    selected_count = count_sources(root, item)
    duplicate_count = count_duplicate_sources(root, item)
    output_path = resolve_path(root, item["output"])
    metadata_path = resolve_path(root, item["metadata"])
    sprite_path = resolve_path(root, item["sprite_frames"]) if item.get("sprite_frames") else None
    meta_count = metadata_count(metadata_path)
    size = image_size(output_path)

    ok = (
        selected_count >= expected_target
        and output_path.exists()
        and metadata_path.exists()
        and meta_count == selected_count
        and size is not None
        and (sprite_path is None or sprite_path.exists())
    )
    sprite_status = "spriteframes=n/a"
    if sprite_path is not None:
        sprite_status = "spriteframes=ok" if sprite_path.exists() else "spriteframes=missing"
    size_status = "size=missing" if size is None else f"size={size[0]}x{size[1]}"
    status = "OK" if ok else "FAIL"
    message = (
        f"{asset_id}: {status} selected={selected_count}/{expected_target} "
        f"duplicates={duplicate_count} metadata={meta_count} {size_status} {sprite_status}"
    )
    return message, ok


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest = load_json(resolve_path(repo_root, args.manifest))
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()

    failed = False
    total = 0
    for item in manifest["outputs"]:
        total += 1
        message, ok = audit_item(root, item)
        print(message)
        failed = failed or not ok

    print(f"Audited {total} atlas-linked outputs.")
    if failed and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
