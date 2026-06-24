#!/usr/bin/env python3
"""Generate Spine-style cutout descriptors from image-gen spine parts atlases."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build Spine-style .atlas, skeleton JSON and project cutout manifests.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--out-dir",
        default="assets/art/spine_parts/spine_exports",
        help="Output directory for generated Spine-style descriptors.",
    )
    parser.add_argument(
        "--only",
        help="Build only one spine parts asset id.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned outputs without writing files.",
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


def as_res_path(root: Path, path: Path) -> str:
    return "res://" + path.resolve().relative_to(root).as_posix()


def safe_part_name(value: str) -> str:
    name = re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("._")
    return name or "part"


def selected_outputs(manifest: dict[str, Any], args: argparse.Namespace) -> list[dict[str, Any]]:
    outputs = [
        item for item in manifest["outputs"]
        if str(item.get("output", "")).replace("\\", "/").startswith("assets/art/spine_parts/")
    ]
    if args.only:
        outputs = [item for item in outputs if item["id"] == args.only]
    return outputs


def atlas_text(texture_name: str, texture_size: tuple[int, int], frames: list[dict[str, Any]]) -> str:
    lines = [
        texture_name,
        f"size: {texture_size[0]},{texture_size[1]}",
        "format: RGBA8888",
        "filter: Linear,Linear",
        "repeat: none",
    ]
    for frame in frames:
        x, y, width, height = [int(value) for value in frame["region"]]
        lines.extend([
            safe_part_name(str(frame["name"])),
            "  rotate: false",
            f"  xy: {x}, {y}",
            f"  size: {width}, {height}",
            f"  orig: {width}, {height}",
            "  offset: 0, 0",
            "  index: -1",
        ])
    return "\n".join(lines) + "\n"


def spine_style_json(asset_id: str, texture_path: Path, texture_size: tuple[int, int], frames: list[dict[str, Any]]) -> dict[str, Any]:
    slots: list[dict[str, str]] = []
    attachments: dict[str, dict[str, Any]] = {}
    for frame in frames:
        part_name = safe_part_name(str(frame["name"]))
        x, y, width, height = [int(value) for value in frame["region"]]
        slots.append({
            "name": part_name,
            "bone": "root",
            "attachment": part_name,
        })
        attachments[part_name] = {
            part_name: {
                "type": "region",
                "path": part_name,
                "x": x + width / 2,
                "y": texture_size[1] - y - height / 2,
                "width": width,
                "height": height,
            }
        }

    return {
        "skeleton": {
            "spine": "spine-style-cutout-descriptor",
            "hash": asset_id,
            "images": "./",
            "audio": "",
            "width": texture_size[0],
            "height": texture_size[1],
            "source_texture": texture_path.name,
            "note": "Descriptor only; pivots, bones, mesh weights and animation must be authored manually.",
        },
        "bones": [{"name": "root"}],
        "slots": slots,
        "skins": [{
            "name": "default",
            "attachments": attachments,
        }],
        "animations": {},
    }


def cutout_manifest(
    root: Path,
    asset_id: str,
    texture_path: Path,
    metadata_path: Path,
    texture_size: tuple[int, int],
    frames: list[dict[str, Any]],
) -> dict[str, Any]:
    parts: list[dict[str, Any]] = []
    for frame in frames:
        x, y, width, height = [int(value) for value in frame["region"]]
        parts.append({
            "index": int(frame["index"]),
            "name": safe_part_name(str(frame["name"])),
            "source_name": frame["name"],
            "region": [x, y, width, height],
            "pivot": [width / 2, height / 2],
            "source": frame.get("source", ""),
            "role": "unclassified_cutout_part",
        })

    return {
        "version": 1,
        "asset_id": asset_id,
        "kind": "spine_style_cutout_manifest",
        "source_texture": as_res_path(root, texture_path),
        "source_metadata": as_res_path(root, metadata_path),
        "texture_size": list(texture_size),
        "part_count": len(parts),
        "parts": parts,
        "status": "placeholder_ready",
        "boundary": (
            "Auto-generated from image-gen cutout atlas regions. "
            "Parts still need semantic naming, pivot cleanup, overlap padding review, "
            "manual bone hierarchy and animation authoring before runtime use."
        ),
    }


def build_for_item(root: Path, out_root: Path, item: dict[str, Any], dry_run: bool) -> dict[str, Any]:
    asset_id = item["id"]
    texture_path = resolve_path(root, item["output"])
    metadata_path = resolve_path(root, item["metadata"])
    if not texture_path.exists():
        raise FileNotFoundError(f"Missing spine parts texture for {asset_id}: {texture_path}")
    if not metadata_path.exists():
        raise FileNotFoundError(f"Missing spine parts metadata for {asset_id}: {metadata_path}")

    metadata = load_json(metadata_path)
    frames = metadata.get("frames", [])
    if not frames:
        raise ValueError(f"No frames in spine parts metadata: {metadata_path}")
    with Image.open(texture_path) as image:
        texture_size = image.size

    out_dir = out_root / asset_id
    atlas_path = out_dir / f"{asset_id}.atlas"
    spine_json_path = out_dir / f"{asset_id}.spine_style.json"
    cutout_manifest_path = out_dir / f"{asset_id}.cutout_manifest.json"

    if not dry_run:
        out_dir.mkdir(parents=True, exist_ok=True)
        atlas_path.write_text(
            atlas_text(texture_path.name, texture_size, frames),
            encoding="utf-8",
        )
        spine_json_path.write_text(
            json.dumps(spine_style_json(asset_id, texture_path, texture_size, frames), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        cutout_manifest_path.write_text(
            json.dumps(cutout_manifest(root, asset_id, texture_path, metadata_path, texture_size, frames), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    return {
        "asset_id": asset_id,
        "part_count": len(frames),
        "atlas": as_res_path(root, atlas_path),
        "spine_style_json": as_res_path(root, spine_json_path),
        "cutout_manifest": as_res_path(root, cutout_manifest_path),
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
        print(f"No spine parts output matched: {args.only}")
        return 2

    entries = []
    total_parts = 0
    for item in outputs:
        entry = build_for_item(root, out_root, item, args.dry_run)
        entries.append(entry)
        total_parts += entry["part_count"]
        print(f"{entry['asset_id']}: planned {entry['part_count']} cutout parts")

    if not args.dry_run:
        out_root.mkdir(parents=True, exist_ok=True)
        index = {
            "version": 1,
            "source_manifest": as_res_path(root, manifest_path),
            "asset_count": len(entries),
            "part_count": total_parts,
            "assets": entries,
        }
        index_path = out_root / "spine_cutout_exports.index.json"
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {index_path.as_posix()}")
    print(f"Spine-style cutout exports: {len(entries)} assets, {total_parts} parts")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
