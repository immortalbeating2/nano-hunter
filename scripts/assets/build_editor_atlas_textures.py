#!/usr/bin/env python3
"""Generate Godot AtlasTexture resources for image-gen atlas regions."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


ATLAS_KINDS = {"atlas", "tileset_sheet", "ninepatch_sheet"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build per-region AtlasTexture .tres files from atlas metadata.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--out-dir",
        default="assets/art/editor_resources",
        help="Output directory for generated editor resources.",
    )
    parser.add_argument(
        "--only",
        help="Build only one output id.",
    )
    parser.add_argument(
        "--include-sprite-sheets",
        action="store_true",
        help="Also generate AtlasTexture resources for sprite_sheet frames.",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove previously generated .atlas_texture.tres files for selected assets first.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate inputs and print planned outputs without writing files.",
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


def safe_slug(value: str) -> str:
    slug = re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("._")
    return slug[:80] or "region"


def as_res_path(root: Path, path: Path) -> str:
    return "res://" + path.resolve().relative_to(root).as_posix()


def selected_outputs(manifest: dict[str, Any], args: argparse.Namespace) -> list[dict[str, Any]]:
    outputs = manifest["outputs"]
    if args.only:
        outputs = [item for item in outputs if item["id"] == args.only]
    if not args.include_sprite_sheets:
        outputs = [item for item in outputs if item.get("kind") in ATLAS_KINDS]
    return outputs


def clean_asset_dir(asset_dir: Path, out_root: Path) -> int:
    asset_dir = asset_dir.resolve()
    out_root = out_root.resolve()
    if out_root not in [asset_dir, *asset_dir.parents]:
        raise RuntimeError(f"Refusing to clean outside output root: {asset_dir}")
    count = 0
    if asset_dir.exists():
        for path in asset_dir.glob("*.atlas_texture.tres"):
            path.unlink()
            count += 1
    return count


def write_atlas_texture(path: Path, texture_res_path: str, region: list[int]) -> None:
    x, y, width, height = region
    body = "\n".join([
        '[gd_resource type="AtlasTexture" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{texture_res_path}" id="1"]',
        "",
        "[resource]",
        'atlas = ExtResource("1")',
        f"region = Rect2({x}, {y}, {width}, {height})",
        "",
    ])
    path.write_text(body, encoding="utf-8")


def build_for_item(root: Path, out_root: Path, item: dict[str, Any], args: argparse.Namespace) -> dict[str, Any]:
    metadata_path = resolve_path(root, item["metadata"])
    output_path = resolve_path(root, item["output"])
    if not metadata_path.exists():
        raise FileNotFoundError(f"Missing metadata for {item['id']}: {metadata_path}")
    if not output_path.exists():
        raise FileNotFoundError(f"Missing texture for {item['id']}: {output_path}")

    metadata = load_json(metadata_path)
    regions = metadata.get("frames", [])
    asset_dir = out_root / safe_slug(item["id"])
    if args.clean and not args.dry_run:
        clean_asset_dir(asset_dir, out_root)
    texture_res_path = as_res_path(root, output_path)

    resource_entries: list[dict[str, Any]] = []
    for index, frame in enumerate(regions):
        name = safe_slug(str(frame.get("name") or f"region_{index:03d}"))
        resource_name = f"{index:03d}_{name}.atlas_texture.tres"
        resource_path = asset_dir / resource_name
        region = [int(value) for value in frame["region"]]
        if not args.dry_run:
            asset_dir.mkdir(parents=True, exist_ok=True)
            write_atlas_texture(resource_path, texture_res_path, region)
        resource_entries.append({
            "index": index,
            "name": frame.get("name", f"region_{index:03d}"),
            "resource": as_res_path(root, resource_path),
            "region": region,
        })

    return {
        "id": item["id"],
        "kind": item["kind"],
        "source_texture": texture_res_path,
        "metadata": as_res_path(root, metadata_path),
        "count": len(resource_entries),
        "resources": resource_entries,
    }


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest_path = resolve_path(repo_root, args.manifest).resolve()
    manifest = load_json(manifest_path)
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()
    out_root = resolve_path(root, args.out_dir)

    outputs = selected_outputs(manifest, args)
    if args.only and not outputs:
        print(f"No output id matched or selected: {args.only}")
        return 2

    index_entries: list[dict[str, Any]] = []
    total = 0
    for item in outputs:
        entry = build_for_item(root, out_root, item, args)
        index_entries.append(entry)
        total += entry["count"]
        print(f"{item['id']}: planned {entry['count']} AtlasTexture resources")

    if not args.dry_run:
        out_root.mkdir(parents=True, exist_ok=True)
        index_path = out_root / "editor_atlas_textures.index.json"
        index = {
            "version": 1,
            "source_manifest": as_res_path(root, manifest_path),
            "include_sprite_sheets": bool(args.include_sprite_sheets),
            "asset_count": len(index_entries),
            "resource_count": total,
            "assets": index_entries,
        }
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {index_path.as_posix()}")
    print(f"AtlasTexture resources: {total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
