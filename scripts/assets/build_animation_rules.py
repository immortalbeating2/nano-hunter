#!/usr/bin/env python3
"""Build first-pass animation timing and anchor rules for character sprite sheets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_QUEUE = "docs/assets/image-gen-prompt-queue.json"
DEFAULT_ATLAS_MANIFEST = "docs/assets/asset-atlas-build-manifest.json"
DEFAULT_OUT_DIR = "assets/art/characters/animation_rules"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate animation rule sidecars for character SpriteFrames.")
    parser.add_argument("--queue", default=DEFAULT_QUEUE)
    parser.add_argument("--atlas-manifest", default=DEFAULT_ATLAS_MANIFEST)
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def semantic_path_for(metadata_path: Path) -> Path:
    suffix = metadata_path.suffix
    stem = metadata_path.name.removesuffix(suffix)
    if stem.endswith(".frames"):
        return metadata_path.with_name(stem.removesuffix(".frames") + ".semantics.json")
    return metadata_path.with_name(stem + ".semantics.json")


def semantic_entries_by_index(path: Path) -> dict[int, dict[str, Any]]:
    if not path.exists():
        return {}
    data = load_json(path)
    return {int(item["index"]): item for item in data.get("entries", [])}


def output_manifest_by_id(manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in manifest.get("outputs", [])}


def is_character_sprite_sheet(item: dict[str, Any], manifest_item: dict[str, Any] | None) -> bool:
    if item.get("target_kind") != "sprite_sheet" or not manifest_item:
        return False
    output = str(item.get("output_path", manifest_item.get("output", "")))
    return "/characters/" in output.replace("\\", "/")


def default_pivot(asset_id: str, cell: list[int]) -> list[int]:
    width, height = int(cell[0]), int(cell[1])
    if "seal_guardian" in asset_id:
        return [width // 2, int(height * 0.82)]
    return [width // 2, int(height * 0.88)]


def default_baseline(asset_id: str, cell: list[int]) -> int:
    height = int(cell[1])
    if "seal_guardian" in asset_id:
        return int(height * 0.86)
    return int(height * 0.9)


def phase_for_index(index: int, count: int, animation_name: str) -> str:
    if count <= 1:
        return "single"
    ratio = index / max(1, count - 1)
    if animation_name in {"run", "idle", "enemy_core_cycle"}:
        return "loop_cycle"
    if ratio < 0.2:
        return "anticipation"
    if ratio < 0.6:
        return "active"
    if ratio < 0.85:
        return "follow_through"
    return "recovery"


def build_rules(root: Path, queue_item: dict[str, Any], manifest_item: dict[str, Any]) -> dict[str, Any]:
    asset_id = queue_item["asset_id"]
    metadata_path = resolve_path(root, manifest_item["metadata"])
    metadata = load_json(metadata_path)
    semantics = semantic_entries_by_index(semantic_path_for(metadata_path))
    frames = metadata.get("frames", [])
    animation = manifest_item.get("animation", {})
    animation_name = str(animation.get("name", asset_id))
    speed = float(animation.get("speed", 12.0))
    loop = bool(animation.get("loop", False))
    cell = [int(value) for value in manifest_item.get("cell", metadata.get("cell", [0, 0]))]
    pivot = default_pivot(asset_id, cell)
    baseline_y = default_baseline(asset_id, cell)
    frame_count = len(frames)
    frame_duration = round(1.0 / speed, 6) if speed > 0 else 0
    frame_rules: list[dict[str, Any]] = []
    for frame in frames:
        index = int(frame["index"])
        semantic = semantics.get(index, {})
        frame_rules.append(
            {
                "index": index,
                "source_name": frame.get("name", ""),
                "semantic_name": semantic.get("semantic_name", frame.get("name", "")),
                "phase": phase_for_index(index, frame_count, animation_name),
                "region": [int(value) for value in frame["region"]],
                "pivot_px": pivot,
                "pivot_normalized": [round(pivot[0] / max(1, cell[0]), 4), round(pivot[1] / max(1, cell[1]), 4)],
                "foot_baseline_y": baseline_y,
                "frame_duration_sec": frame_duration,
                "manual_review_required": True,
                "notes": [
                    "first_pass_animation_timing_candidate",
                    "frame_order_and_baseline_manual_review_required",
                    "not_runtime_replacement_without_playtest",
                ],
            }
        )
    return {
        "version": 1,
        "asset_id": asset_id,
        "target_kind": queue_item["target_kind"],
        "status": "placeholder_ready",
        "source_texture": queue_item["output_path"],
        "source_metadata": rel(metadata_path, root),
        "sprite_frames": manifest_item.get("sprite_frames", ""),
        "animation_name": animation_name,
        "speed_fps": speed,
        "loop": loop,
        "frame_count": frame_count,
        "cell": cell,
        "default_pivot_px": pivot,
        "default_foot_baseline_y": baseline_y,
        "rules": frame_rules,
        "manual_review_required": True,
        "boundary": (
            "First-pass animation timing and anchor rules. These rules guide editor/runtime hookup; "
            "they do not prove final frame order, foot baseline, hitbox, timing, or gameplay readability."
        ),
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    manifest = load_json(resolve_path(root, args.atlas_manifest))
    manifest_by_id = output_manifest_by_id(manifest)
    out_dir = resolve_path(root, args.out_dir)
    if not args.dry_run:
        out_dir.mkdir(parents=True, exist_ok=True)

    built: list[dict[str, Any]] = []
    for item in queue.get("items", []):
        asset_id = item["asset_id"]
        manifest_item = manifest_by_id.get(asset_id)
        if not is_character_sprite_sheet(item, manifest_item):
            continue
        rules = build_rules(root, item, manifest_item)
        out_path = out_dir / f"{asset_id}.animation_rules.json"
        built.append(
            {
                "asset_id": asset_id,
                "path": rel(out_path, root),
                "frame_count": int(rules["frame_count"]),
                "animation_name": rules["animation_name"],
                "speed_fps": rules["speed_fps"],
                "loop": rules["loop"],
            }
        )
        if not args.dry_run:
            out_path.write_text(json.dumps(rules, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    index = {
        "version": 1,
        "status": "placeholder_ready",
        "asset_count": len(built),
        "frame_rule_count": sum(int(item["frame_count"]) for item in built),
        "manual_review_required": True,
        "assets": built,
        "boundary": (
            "First-pass animation rule index. Runtime replacement still requires frame-order, "
            "baseline, timing, collision/readability, and playtest review."
        ),
    }
    index_path = out_dir / "animation_rules.index.json"
    if not args.dry_run:
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"Animation rules {'planned' if args.dry_run else 'built'}: "
        f"{index['asset_count']} assets, {index['frame_rule_count']} frame rules."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
