#!/usr/bin/env python3
"""Build first-pass VFX anchor and blend rules for generated Nano Hunter assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_QUEUE = "docs/assets/image-gen-prompt-queue.json"
DEFAULT_ATLAS_MANIFEST = "docs/assets/asset-atlas-build-manifest.json"
DEFAULT_OUT_DIR = "assets/art/vfx/vfx_rules"
VFX_KINDS = {"vfx_atlas", "vfx_sheet", "vfx_direction", "vfx_warning"}
STANDALONE_GRID_SPECS = {
    "stage30_thunder_fang_vfx_ai01": {
        "columns": 4,
        "rows": 4,
        "names": [
            *[f"warning_{index:02d}" for index in range(1, 5)],
            *[f"attack_{index:02d}" for index in range(1, 5)],
            *[f"guard_break_{index:02d}" for index in range(1, 5)],
            *[f"stagger_{index:02d}" for index in range(1, 5)],
        ],
        "boundary": "Stage30 Thunder Fang VFX grid; visual-only with no collision or damage authority.",
    },
    "stage30_kui_boss_combat_vfx_ai01": {
        "columns": 4,
        "rows": 4,
        "names": [
            *[f"close_warning_{index:02d}" for index in range(1, 5)],
            *[f"close_impact_{index:02d}" for index in range(1, 5)],
            *[f"lightning_warning_{index:02d}" for index in range(1, 5)],
            *[f"lightning_impact_{index:02d}" for index in range(1, 5)],
        ],
        "boundary": "Stage30 Kui Thunder Boss combat VFX grid; boss code owns timing, collision and damage.",
    },
    "stage30_kui_boss_state_vfx_ai01": {
        "columns": 4,
        "rows": 4,
        "names": [
            *[f"guard_break_{index:02d}" for index in range(1, 5)],
            *[f"stagger_{index:02d}" for index in range(1, 5)],
            *[f"phase_transition_{index:02d}" for index in range(1, 5)],
            *[f"defeat_{index:02d}" for index in range(1, 5)],
        ],
        "boundary": "Stage30 Kui Thunder Boss state VFX grid; visual-only state feedback.",
    },
    "stage30_thunder_absorption_reward_vfx_ai01": {
        "columns": 4,
        "rows": 4,
        "names": [
            *[f"absorption_unlock_{index:02d}" for index in range(1, 5)],
            *[f"thunder_beast_core_{index:02d}" for index in range(1, 5)],
            *[f"demon_resonance_{index:02d}" for index in range(1, 5)],
            *[f"shortcut_curtain_{index:02d}" for index in range(1, 5)],
        ],
        "boundary": "Stage30 reward and shortcut VFX grid; capability and route state remain code-authoritative.",
    },
    "stage29_thunder_waste_state_vfx_ai01": {
        "columns": 4,
        "rows": 4,
        "names": [
            "storm_startup",
            "storm_active_a",
            "storm_active_b",
            "storm_grounded",
            "relay_active",
            "relay_struck",
            "relay_grounded",
            "relay_disabled",
            "barrier_locked",
            "barrier_unlock",
            "barrier_open",
            "exit_right",
            "outpost_checkpoint",
            "branch_up",
            "cloud_flash",
            "safe_discharge",
        ],
        "boundary": (
            "Stage29 4x4 environment state VFX grid. Runtime nodes consume explicit SpriteFrames or AtlasTexture "
            "regions; every rule is visual-only and owns no collision or damage."
        ),
    },
    "stage16_talisman_relay_ai01": {
        "columns": 3,
        "rows": 2,
        "names": [
            "dormant_seal_circle",
            "cyan_white_pulse",
            "vermilion_talisman_sparks",
            "ink_brush_light_path",
            "relay_confirmation_burst",
            "purified_motes_fade",
        ],
        "boundary": (
            "Reviewed 3x2 standalone VFX grid for Stage16 talisman relay markers. "
            "Runtime scenes must bind explicit Sprite2D regions instead of displaying the full sheet."
        ),
    },
    "stage16_corruption_purge_ai01": {
        "columns": 3,
        "rows": 2,
        "names": [
            "dark_miasma_curl",
            "cyan_white_seal_ignition",
            "vermilion_talisman_ring",
            "corruption_cracking_apart",
            "lotus_seal_purification_burst",
            "moon_white_motes_afterglow",
        ],
        "boundary": (
            "Reviewed 3x2 standalone VFX grid for Stage16 corruption purge feedback. "
            "Runtime scenes must bind explicit Sprite2D regions instead of displaying the full sheet."
        ),
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate VFX anchor/blend rule sidecars.")
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


def output_manifest_by_id(manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in manifest.get("outputs", [])}


def existing_rule_entries(root: Path, out_dir: Path, index_path: Path) -> list[dict[str, Any]]:
    """保留已人工修订的 sidecar；生成器只为尚不存在的资产补规则。"""
    paths: list[Path] = []
    if index_path.exists():
        for item in load_json(index_path).get("assets", []):
            value = str(item.get("path", ""))
            if value:
                paths.append(resolve_path(root, value))
    paths.extend(sorted(out_dir.glob("*.vfx_rules.json")))

    entries: list[dict[str, Any]] = []
    seen: set[str] = set()
    for path in paths:
        if not path.exists():
            continue
        rules = load_json(path)
        asset_id = str(rules.get("asset_id", ""))
        if not asset_id or asset_id in seen:
            continue
        seen.add(asset_id)
        entries.append(
            {
                "asset_id": asset_id,
                "path": rel(path, root),
                "frame_count": int(rules.get("frame_count", 0)),
                "target_kind": str(rules.get("target_kind", "")),
            }
        )
    return entries


def semantic_entries_by_index(path: Path) -> dict[int, dict[str, Any]]:
    if not path.exists():
        return {}
    data = load_json(path)
    return {int(item["index"]): item for item in data.get("entries", [])}


def recommended_blend(asset_id: str) -> str:
    if "warning" in asset_id:
        return "alpha_add"
    if "combat" in asset_id:
        return "additive_alpha"
    if "purge" in asset_id:
        return "additive_soft"
    return "additive"


def recommended_role(asset_id: str, semantic: dict[str, Any] | None = None) -> str:
    text = " ".join(
        [
            asset_id,
            str((semantic or {}).get("semantic_name", "")),
            " ".join(str(tag) for tag in (semantic or {}).get("tags", [])),
        ]
    )
    if "warning" in text:
        return "telegraph"
    if "dash" in text:
        return "movement_feedback"
    if "purge" in text:
        return "completion_feedback"
    if "relay" in text or "seal" in text:
        return "seal_magic_feedback"
    return "combat_feedback"


def frame_rule(asset_id: str, frame: dict[str, Any], semantic: dict[str, Any] | None) -> dict[str, Any]:
    region = [int(value) for value in frame["region"]]
    width = region[2]
    height = region[3]
    return {
        "index": int(frame["index"]),
        "source_name": frame.get("name", ""),
        "semantic_name": (semantic or {}).get("semantic_name", frame.get("name", "")),
        "group": (semantic or {}).get("group", recommended_role(asset_id, semantic)),
        "role": recommended_role(asset_id, semantic),
        "region": region,
        "anchor_px": [width // 2, height // 2],
        "anchor_normalized": [0.5, 0.5],
        "spawn_offset_px": [0, 0],
        "recommended_blend": recommended_blend(asset_id),
        "gameplay_collision": False,
        "damage_source": False,
        "manual_review_required": True,
        "notes": [
            "first_pass_anchor_candidate",
            "mask_and_blend_manual_review_required",
            "do_not_use_as_collision_or_damage_source",
        ],
    }


def build_atlas_rules(root: Path, item: dict[str, Any], manifest_item: dict[str, Any]) -> dict[str, Any]:
    asset_id = item["asset_id"]
    metadata_path = resolve_path(root, manifest_item["metadata"])
    metadata = load_json(metadata_path)
    semantics = semantic_entries_by_index(semantic_path_for(metadata_path))
    frames = [
        frame_rule(asset_id, frame, semantics.get(int(frame["index"])))
        for frame in metadata.get("frames", [])
    ]
    return {
        "version": 1,
        "asset_id": asset_id,
        "target_kind": item["target_kind"],
        "status": "placeholder_ready",
        "source_texture": item["output_path"],
        "source_metadata": rel(metadata_path, root),
        "sprite_frames": manifest_item.get("sprite_frames", ""),
        "frame_count": len(frames),
        "rules": frames,
        "manual_review_required": True,
        "boundary": (
            "First-pass VFX anchor and blend rules. These rules guide editor/runtime hookup; "
            "they do not prove final mask cleanup, timing, hitbox, damage, or gameplay readability."
        ),
    }


def build_standalone_rules(root: Path, item: dict[str, Any]) -> dict[str, Any]:
    asset_id = item["asset_id"]
    output_path = resolve_path(root, item["output_path"])
    with Image.open(output_path) as image:
        width, height = image.size
    grid_spec = STANDALONE_GRID_SPECS.get(asset_id)
    if grid_spec:
        columns = int(grid_spec["columns"])
        rows = int(grid_spec["rows"])
        if width % columns != 0 or height % rows != 0:
            raise ValueError(f"{asset_id}: image size {width}x{height} does not match {columns}x{rows} grid")
        cell_width = width // columns
        cell_height = height // rows
        names = list(grid_spec.get("names", []))
        rules = []
        for index in range(columns * rows):
            column = index % columns
            row = index // columns
            semantic_name = names[index] if index < len(names) else f"{asset_id}_frame_{index + 1:02d}"
            rules.append(
                {
                    "index": index,
                    "source_name": f"{output_path.stem}_{semantic_name}",
                    "semantic_name": semantic_name,
                    "group": recommended_role(asset_id),
                    "role": recommended_role(asset_id),
                    "region": [column * cell_width, row * cell_height, cell_width, cell_height],
                    "anchor_px": [cell_width // 2, cell_height // 2],
                    "anchor_normalized": [0.5, 0.5],
                    "spawn_offset_px": [0, 0],
                    "recommended_blend": recommended_blend(asset_id),
                    "gameplay_collision": False,
                    "damage_source": False,
                    "manual_review_required": True,
                    "notes": [
                        "reviewed_standalone_grid_cell",
                        "runtime_region_binding_required",
                        "do_not_use_as_collision_or_damage_source",
                    ],
                }
            )
        return {
            "version": 1,
            "asset_id": asset_id,
            "target_kind": item["target_kind"],
            "status": "runtime_region_ready",
            "source_texture": item["output_path"],
            "source_metadata": "",
            "sprite_frames": "",
            "frame_count": len(rules),
            "grid": {
                "columns": columns,
                "rows": rows,
                "cell_size": [cell_width, cell_height],
            },
            "rules": rules,
            "manual_review_required": True,
            "boundary": grid_spec.get(
                "boundary",
                "Reviewed standalone VFX grid. Runtime scenes must bind explicit regions.",
            ),
        }
    rule = {
        "index": 0,
        "source_name": output_path.name,
        "semantic_name": asset_id,
        "group": recommended_role(asset_id),
        "role": recommended_role(asset_id),
        "region": [0, 0, width, height],
        "anchor_px": [width // 2, height // 2],
        "anchor_normalized": [0.5, 0.5],
        "spawn_offset_px": [0, 0],
        "recommended_blend": recommended_blend(asset_id),
        "gameplay_collision": False,
        "damage_source": False,
        "manual_review_required": True,
        "notes": [
            "standalone_vfx_texture_candidate",
            "manual_split_or_mask_review_required",
            "do_not_use_as_collision_or_damage_source",
        ],
    }
    return {
        "version": 1,
        "asset_id": asset_id,
        "target_kind": item["target_kind"],
        "status": "placeholder_ready",
        "source_texture": item["output_path"],
        "source_metadata": "",
        "sprite_frames": "",
        "frame_count": 1,
        "rules": [rule],
        "manual_review_required": True,
        "boundary": (
            "First-pass standalone VFX rule. This describes the whole texture as one VFX source; "
            "manual cleanup is still required before runtime replacement."
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

    index_path = out_dir / "vfx_rules.index.json"
    built = existing_rule_entries(root, out_dir, index_path)
    built_ids = {item["asset_id"] for item in built}
    for item in queue.get("items", []):
        if item.get("target_kind") not in VFX_KINDS:
            continue
        asset_id = item["asset_id"]
        if asset_id in built_ids:
            continue
        if asset_id in manifest_by_id:
            rules = build_atlas_rules(root, item, manifest_by_id[asset_id])
        else:
            rules = build_standalone_rules(root, item)
        out_path = out_dir / f"{asset_id}.vfx_rules.json"
        built.append(
            {
                "asset_id": asset_id,
                "path": rel(out_path, root),
                "frame_count": int(rules["frame_count"]),
                "target_kind": item["target_kind"],
            }
        )
        built_ids.add(asset_id)
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
            "First-pass VFX rule index. All rules explicitly disable gameplay collision and damage; "
            "runtime damage/hit logic must be authored separately in gameplay code or scenes."
        ),
    }
    if not args.dry_run:
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(
        f"VFX rules {'planned' if args.dry_run else 'built'}: "
        f"{index['asset_count']} assets, {index['frame_rule_count']} frame rules."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
