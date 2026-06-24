#!/usr/bin/env python3
"""Build first-pass semantic labels for generated atlas regions and sprite frames."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_INDEX = "docs/assets/asset-semantics-index.json"


ICON_NAMES = [
    "air_dash",
    "recovery_charge",
    "checkpoint",
    "sealed_gate",
    "reward_marker",
    "completion_seal",
    "boss_warning",
    "talisman_relay",
    "corruption_purge",
    "health",
    "ability_ready",
    "ability_cooldown",
    "pause",
    "restart",
    "continue",
    "back",
]
HUD_NAMES = [
    "health_frame",
    "health_fill",
    "ability_socket",
    "air_dash_ready",
    "air_dash_spent",
    "recovery_charge_empty",
    "recovery_charge_ready",
    "boss_health_frame",
    "boss_health_fill",
    "seal_chain_progress",
    "checkpoint_marker",
    "room_goal_marker",
    "reward_counter",
    "demo_status_panel",
    "warning_badge",
    "completion_badge",
]
NINEPATCH_NAMES = [
    "pause_panel",
    "completion_panel",
    "dialog_panel",
    "hud_panel",
    "button_normal",
    "button_focus",
    "button_disabled",
    "tooltip_panel",
]
PROP_NAMES = [
    "air_dash_shrine_inactive",
    "air_dash_shrine_active",
    "air_dash_shrine_claimed",
    "seal_gate_locked",
    "seal_gate_unlocking",
    "seal_gate_open",
    "talisman_stake_idle",
    "talisman_stake_lit",
    "stone_lantern_idle",
    "stone_lantern_lit",
    "seal_pillar_intact",
    "seal_pillar_cracked",
    "reward_marker_idle",
    "reward_marker_collected",
    "checkpoint_inactive",
    "checkpoint_active",
    "miasma_ward_idle",
    "miasma_ward_purged",
    "chain_anchor_left",
    "chain_anchor_right",
    "seal_ring_idle",
    "seal_ring_active",
    "boss_gate_locked",
    "boss_gate_open",
]
EQUIPMENT_NAMES = [
    "luna_blade",
    "talisman_paper",
    "prayer_beads",
    "bronze_bell",
    "demon_bureau_token",
    "seal_fragment",
    "recovery_charm",
    "air_dash_charm",
    "reward_orb_small",
    "reward_orb_large",
    "miasma_sample",
    "shrine_key_token",
    "ward_chain_link",
    "spirit_coin",
    "cloth_sash",
    "paper_seal_stack",
    "ritual_ink",
    "broken_mask",
    "copper_talisman_case",
    "boss_core_shard",
    "checkpoint_bell",
    "purge_flame_seed",
    "map_scrap",
    "demo_completion_token",
]
MATERIAL_NAMES = [
    "shrine_stone",
    "weathered_wood",
    "talisman_paper",
    "miasma_mud",
    "corrupted_water",
    "cloth_sash",
    "bronze_trim",
    "carved_jade",
    "charcoal_ink",
    "vermilion_paint",
    "moss_edge",
    "worn_tile",
    "cracked_plaster",
    "sealed_chain",
    "ritual_rope",
    "ash_dust",
]
SPINE_LUNA_PARTS = [
    "head",
    "hair_back",
    "hair_front",
    "torso",
    "pelvis",
    "upper_arm_left",
    "lower_arm_left",
    "hand_left",
    "upper_arm_right",
    "lower_arm_right",
    "hand_right",
    "upper_leg_left",
    "lower_leg_left",
    "foot_left",
    "upper_leg_right",
    "lower_leg_right",
    "foot_right",
    "sash",
    "blade",
    "talisman_paper",
    "cloak",
    "shoulder_guard",
    "belt_token",
    "shadow_contact",
]
SPINE_GUARDIAN_PARTS = [
    "mask",
    "head_back",
    "torso",
    "core",
    "shoulder_left",
    "upper_arm_left",
    "forearm_left",
    "hand_left",
    "shoulder_right",
    "upper_arm_right",
    "forearm_right",
    "hand_right",
    "hip",
    "upper_leg_left",
    "lower_leg_left",
    "foot_left",
    "upper_leg_right",
    "lower_leg_right",
    "foot_right",
    "chain_left",
    "chain_right",
    "back_banner",
    "seal_ring",
    "shadow_contact",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate first-pass semantic metadata for built image-gen atlases.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to atlas build manifest.",
    )
    parser.add_argument(
        "--index",
        default=DEFAULT_INDEX,
        help="Path to write the semantics index.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned output counts without writing files.",
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


def rel_path(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def semantic_path_for(metadata_path: Path) -> Path:
    suffix = metadata_path.suffix
    stem = metadata_path.name.removesuffix(suffix)
    if stem.endswith(".frames"):
        return metadata_path.with_name(stem.removesuffix(".frames") + ".semantics.json")
    if stem.endswith(".regions"):
        return metadata_path.with_name(stem.removesuffix(".regions") + ".semantics.json")
    return metadata_path.with_name(stem + ".semantics.json")


def list_name(values: list[str], index: int, fallback_prefix: str) -> str:
    if index < len(values):
        return values[index]
    return f"{fallback_prefix}_{index + 1:02d}"


def phase_from_ranges(index: int, ranges: list[tuple[int, int, str]]) -> str:
    for start, end, phase in ranges:
        if start <= index <= end:
            return phase
    return "review"


def tile_semantics(asset_id: str, index: int) -> tuple[str, str]:
    row = index // 8
    column = index % 8
    biome = "miasma_marsh" if "miasma" in asset_id else "shrine_trial"
    if row == 0:
        category = "ground"
    elif row == 1:
        category = "platform_edge"
    elif row == 2:
        category = "wall"
    elif row == 3:
        category = "decor"
    elif row == 4:
        category = "hazard" if "miasma" in asset_id else "ornament"
    else:
        category = "transition"
    return category, f"{biome}_{category}_{row + 1:02d}_{column + 1:02d}"


def semantic_for_item(asset_id: str, kind: str, index: int, total: int, animation_name: str) -> dict[str, Any]:
    category = kind
    group = asset_id
    name = f"{asset_id}_{index + 1:03d}"
    role = "review"
    tags: list[str] = []

    if kind == "sprite_sheet":
        role = "animation_frame"
        group = animation_name or asset_id
        name = f"{group}_frame_{index + 1:03d}"
        if asset_id == "seal_guardian_boss_sheet_ai01":
            phase = phase_from_ranges(index, [(0, 3, "idle"), (4, 7, "warning"), (8, 15, "attack"), (16, 19, "defeat")])
            name = f"seal_guardian_{phase}_frame_{index + 1:03d}"
            tags.append(phase)
        elif asset_id == "luna_jump_fall_sheet_ai01":
            phase = phase_from_ranges(index, [(0, 5, "jump_start"), (6, 11, "rise"), (12, 17, "fall"), (18, 23, "land")])
            name = f"luna_{phase}_frame_{index + 1:03d}"
            tags.append(phase)
        elif asset_id == "luna_hit_death_sheet_ai01":
            phase = phase_from_ranges(index, [(0, 7, "hit"), (8, 23, "death")])
            name = f"luna_{phase}_frame_{index + 1:03d}"
            tags.append(phase)
        elif asset_id == "enemies_core_sheet_ai01":
            enemy_names = ["basic_melee", "ground_charger", "aerial_sentinel", "miasma_caster"]
            enemy = enemy_names[min(index // 8, len(enemy_names) - 1)]
            local = index % 8
            phase = phase_from_ranges(local, [(0, 1, "idle"), (2, 4, "move"), (5, 7, "attack")])
            name = f"{enemy}_{phase}_frame_{local + 1:02d}"
            group = enemy
            tags.extend([enemy, phase])
        elif asset_id.startswith("vfx_"):
            phase = phase_from_ranges(index, [(0, 7, "slash"), (8, 15, "hit_spark"), (16, 23, "warning"), (24, 31, "purge")])
            if "seal_magic" in asset_id:
                phase = phase_from_ranges(index, [(0, 7, "air_dash_trail"), (8, 15, "talisman_relay"), (16, 23, "seal_burst"), (24, 31, "corruption_purge")])
            name = f"{phase}_frame_{index + 1:03d}"
            group = phase
            tags.append(phase)

    elif kind == "tileset_sheet":
        category, name = tile_semantics(asset_id, index)
        role = "tile"
        group = category
        tags.append(category)
    elif asset_id == "hud_core_ui_atlas_ai01":
        role = "hud_region"
        name = list_name(HUD_NAMES, index, "hud_region")
        group = "hud"
    elif asset_id == "icon_sheet_core_ai01":
        role = "icon_region"
        name = list_name(ICON_NAMES, index, "icon")
        group = "icons"
    elif asset_id == "menu_ninepatch_ui_ai01":
        role = "ninepatch_region"
        name = list_name(NINEPATCH_NAMES, index, "ninepatch")
        group = "ui_panel"
    elif asset_id == "shrine_gate_prop_atlas_ai01":
        role = "prop_region"
        name = list_name(PROP_NAMES, index, "prop")
        group = "props"
    elif asset_id == "equipment_pickup_atlas_ai01":
        role = "equipment_region"
        name = list_name(EQUIPMENT_NAMES, index, "equipment")
        group = "equipment"
    elif asset_id == "material_texture_atlas_ai01":
        role = "material_region"
        name = list_name(MATERIAL_NAMES, index, "material")
        group = "materials"
    elif asset_id == "luna_spine_parts_ai01":
        role = "spine_part"
        name = "luna_" + list_name(SPINE_LUNA_PARTS, index, "part")
        group = "luna"
    elif asset_id == "seal_guardian_spine_parts_ai01":
        role = "spine_part"
        name = "seal_guardian_" + list_name(SPINE_GUARDIAN_PARTS, index, "part")
        group = "seal_guardian"
    elif "promo" in asset_id or "capsule" in asset_id or "cg_" in asset_id:
        role = "promo_panel"
        group = "promo"
        name = f"{asset_id}_variant_{index + 1:02d}"
    elif "storyboard" in asset_id:
        role = "storyboard_panel"
        group = "storyboard"
        name = f"{asset_id}_panel_{index + 1:02d}"

    return {
        "index": index,
        "semantic_name": name,
        "category": category,
        "group": group,
        "role": role,
        "tags": tags,
        "manual_review_required": True,
    }


def build_semantics(root: Path, item: dict[str, Any]) -> tuple[Path, dict[str, Any]]:
    metadata_path = resolve_path(root, item["metadata"])
    metadata = load_json(metadata_path)
    entries_source = metadata.get("frames", metadata.get("regions", []))
    animation = item.get("animation", {})
    animation_name = str(animation.get("name", ""))
    entries = []
    for entry in entries_source:
        index = int(entry["index"])
        semantic = semantic_for_item(item["id"], item["kind"], index, len(entries_source), animation_name)
        semantic.update({
            "source_name": entry.get("name", ""),
            "source": entry.get("source", ""),
            "region": entry.get("region", []),
        })
        entries.append(semantic)

    output = semantic_path_for(metadata_path)
    data = {
        "version": 1,
        "asset_id": item["id"],
        "kind": item["kind"],
        "batch": item.get("batch", ""),
        "source_metadata": rel_path(root, metadata_path),
        "output": item.get("output", ""),
        "entry_count": len(entries),
        "manual_review_required": True,
        "boundary": "First-pass machine semantic labels. Human review is still required before final runtime integration.",
        "entries": entries,
    }
    return output, data


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest = load_json(resolve_path(repo_root, args.manifest))
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()

    index_entries = []
    total_entries = 0
    for item in manifest.get("outputs", []):
        semantic_path, data = build_semantics(root, item)
        total_entries += int(data["entry_count"])
        index_entries.append({
            "asset_id": item["id"],
            "kind": item["kind"],
            "path": rel_path(root, semantic_path),
            "entry_count": data["entry_count"],
            "manual_review_required": True,
        })
        if not args.dry_run:
            semantic_path.parent.mkdir(parents=True, exist_ok=True)
            semantic_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    index_data = {
        "version": 1,
        "status": "first_pass",
        "asset_count": len(index_entries),
        "entry_count": total_entries,
        "manual_review_required": True,
        "boundary": "First-pass semantic labels for generated assets; not final art approval.",
        "assets": index_entries,
    }
    index_path = resolve_path(repo_root, args.index)
    if not args.dry_run:
        index_path.parent.mkdir(parents=True, exist_ok=True)
        index_path.write_text(json.dumps(index_data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    action = "would write" if args.dry_run else "wrote"
    print(f"{action} semantic labels for {len(index_entries)} assets / {total_entries} entries")
    print(f"{action} {index_path.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
