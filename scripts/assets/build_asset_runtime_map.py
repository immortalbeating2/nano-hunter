#!/usr/bin/env python3
"""Build a runtime/release integration map for generated image-gen assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/asset-runtime-integration-map.json"

TARGET_KIND_RULES = {
    "boss_animation": {
        "track": "runtime_animation",
        "resource_type": "SpriteFrames",
        "target_system": "boss state animation replacement",
        "target_scene_candidates": ["scenes/enemies/seal_guardian_boss.tscn"],
    },
    "boss_direction": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "Seal Guardian boss readability direction",
        "target_scene_candidates": ["scenes/enemies/seal_guardian_boss.tscn", "scenes/rooms/stage15_seal_guardian_boss_room.tscn"],
    },
    "boss_vfx": {
        "track": "runtime_vfx",
        "resource_type": "SpriteFrames",
        "target_system": "boss state VFX replacement",
        "target_scene_candidates": ["scenes/enemies/seal_guardian_boss.tscn"],
    },
    "character_direction": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "player visual readability direction",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn"],
    },
    "combat_vfx": {
        "track": "runtime_vfx",
        "resource_type": "SpriteFrames",
        "target_system": "player combat VFX replacement",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn"],
    },
    "completion_ui": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "Alpha Demo completion feedback",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn", "scenes/rooms/stage16_alpha_demo_end_room.tscn"],
    },
    "environment_background": {
        "track": "runtime_environment",
        "resource_type": "Texture2D",
        "target_system": "area background/parallax replacement",
        "target_scene_candidates": ["scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "scenes/rooms/stage14_air_dash_shrine_room.tscn"],
    },
    "environment_boss_room_background": {
        "track": "runtime_environment",
        "resource_type": "Texture2D",
        "target_system": "boss room background/parallax replacement",
        "target_scene_candidates": ["scenes/rooms/stage15_seal_guardian_boss_room.tscn"],
    },
    "environment_room_background": {
        "track": "runtime_environment",
        "resource_type": "Texture2D",
        "target_system": "specific room background/parallax replacement",
        "target_scene_candidates": ["scenes/rooms/stage14_air_dash_shrine_room.tscn", "scenes/rooms/stage16_corruption_purge_room.tscn"],
    },
    "environment_tiles": {
        "track": "runtime_environment",
        "resource_type": "Texture2D",
        "target_system": "room tile visual replacement",
        "target_scene_candidates": ["scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "scenes/rooms/stage14_air_dash_gate_room.tscn"],
    },
    "equipment_atlas": {
        "track": "runtime_gameplay",
        "resource_type": "AtlasTexture",
        "target_system": "pickup/equipment item visuals",
        "target_scene_candidates": ["scenes/rooms/stage15_challenge_branch_room.tscn", "scenes/rooms/stage16_seal_release_threshold_room.tscn"],
    },
    "hud_frame": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "HUD frame or status panel visual replacement",
        "target_scene_candidates": ["scenes/ui/tutorial_hud.tscn", "scenes/ui/demo_shell.tscn"],
    },
    "icon": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "ability/status HUD icon replacement",
        "target_scene_candidates": ["scenes/ui/tutorial_hud.tscn"],
    },
    "icon_sheet": {
        "track": "runtime_ui",
        "resource_type": "AtlasTexture",
        "target_system": "menu/HUD icon atlas replacement",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn", "scenes/ui/tutorial_hud.tscn"],
    },
    "ninepatch_sheet": {
        "track": "runtime_ui",
        "resource_type": "StyleBoxTexture",
        "target_system": "menu/panel NinePatch theme replacement",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn"],
    },
    "prop": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "room prop visual replacement",
        "target_scene_candidates": ["scenes/rooms/stage14_air_dash_shrine_room.tscn", "scenes/rooms/stage14_air_dash_gate_room.tscn"],
    },
    "prop_atlas": {
        "track": "runtime_gameplay",
        "resource_type": "AtlasTexture",
        "target_system": "interactive prop atlas replacement",
        "target_scene_candidates": ["scenes/rooms/stage14_air_dash_gate_room.tscn", "scenes/rooms/stage16_talisman_relay_room.tscn"],
    },
    "prop_sheet": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "single prop sheet replacement",
        "target_scene_candidates": ["scenes/rooms/stage16_seal_release_threshold_room.tscn"],
    },
    "player_animation": {
        "track": "runtime_animation",
        "resource_type": "SpriteFrames",
        "target_system": "player state animation replacement",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn"],
    },
    "spine_cutout_parts": {
        "track": "animation_pipeline",
        "resource_type": "Spine-style atlas/json plus Texture2D",
        "target_system": "future cutout rig source",
        "target_scene_candidates": ["scenes/dev/imagegen_asset_integration_showcase.tscn"],
    },
    "sprite_sheet": {
        "track": "runtime_animation",
        "resource_type": "SpriteFrames",
        "target_system": "player/enemy/boss animation replacement",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn", "scenes/enemies/seal_guardian_boss.tscn", "scenes/combat/basic_melee_enemy.tscn"],
    },
    "style_board": {
        "track": "art_direction",
        "resource_type": "Texture2D",
        "target_system": "style lock reference",
        "target_scene_candidates": ["scenes/dev/imagegen_asset_gallery.tscn"],
    },
    "texture_atlas": {
        "track": "runtime_environment",
        "resource_type": "AtlasTexture",
        "target_system": "material/decor texture atlas replacement",
        "target_scene_candidates": ["scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "scenes/rooms/stage14_air_dash_gate_room.tscn"],
    },
    "tileset_sheet": {
        "track": "runtime_environment",
        "resource_type": "TileSet",
        "target_system": "TileMapLayer visual/collision replacement",
        "target_scene_candidates": ["scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "scenes/rooms/stage14_air_dash_gate_room.tscn"],
    },
    "title_background": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "DemoShell title background",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn"],
    },
    "ui_atlas": {
        "track": "runtime_ui",
        "resource_type": "AtlasTexture",
        "target_system": "HUD/menu atlas replacement",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn", "scenes/ui/tutorial_hud.tscn"],
    },
    "ui_panel": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "pause/completion panel replacement",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn"],
    },
    "ui_map_foundation": {
        "track": "runtime_ui",
        "resource_type": "Texture2D",
        "target_system": "discovery map background and ornamental frame",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn"],
    },
    "vfx_atlas": {
        "track": "runtime_vfx",
        "resource_type": "SpriteFrames",
        "target_system": "VFX atlas animation replacement",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn", "scenes/enemies/seal_guardian_boss.tscn"],
    },
    "vfx_direction": {
        "track": "runtime_vfx",
        "resource_type": "Texture2D",
        "target_system": "Air Dash VFX direction replacement",
        "target_scene_candidates": ["scenes/player/player_placeholder.tscn", "scenes/rooms/stage14_air_dash_shrine_room.tscn"],
    },
    "vfx_sheet": {
        "track": "runtime_vfx",
        "resource_type": "Texture2D",
        "target_system": "room progression VFX replacement",
        "target_scene_candidates": ["scenes/rooms/stage16_talisman_relay_room.tscn", "scenes/rooms/stage16_corruption_purge_room.tscn"],
    },
    "vfx_warning": {
        "track": "runtime_vfx",
        "resource_type": "Texture2D",
        "target_system": "boss warning VFX replacement",
        "target_scene_candidates": ["scenes/enemies/seal_guardian_boss.tscn", "scenes/rooms/stage15_seal_guardian_boss_room.tscn"],
    },
}

RELEASE_RULES = {
    "cg_illustration": "narrative_or_release",
    "logo_direction": "release_promo",
    "promo_capsule": "release_promo",
    "promo_key_art": "release_promo",
    "storyboard_sheet": "narrative_or_release",
}

ASSET_ID_RULE_OVERRIDES = {
    "stage16_seal_release_threshold_ai01": {
        "target_scene_candidates": ["scenes/rooms/stage16_seal_release_threshold_room.tscn"],
    },
    "stage28_waystation_background_ai01": {
        "target_system": "Stage11 formal waystation display layer",
        "target_scene_candidates": ["scenes/rooms/stage11_demo_end_room.tscn"],
    },
    "stage28_waystation_world_sheet_ai01": {
        "resource_type": "SpriteFrames plus AtlasTexture",
        "target_system": "Stage11 bounty board, clerk and route marker presentation",
        "target_scene_candidates": ["scenes/rooms/stage11_demo_end_room.tscn"],
    },
    "stage28_waystation_ui_sheet_ai01": {
        "target_system": "bounty, Build and two-slot DetailPanel presentation",
        "target_scene_candidates": ["scenes/ui/demo_shell.tscn"],
    },
    "stage29_thunder_waste_background_ai01": {
        "target_system": "Stage25 six-room Thunder Waste background display layer",
        "target_scene_candidates": ["scenes/rooms/stage25_thunder_waste_room_base.tscn"],
    },
    "stage29_thunder_waste_environment_sheet_ai01": {
        "resource_type": "TileSet plus AtlasTexture",
        "target_system": "Stage25 ground tiles, six room landmarks and foreground props",
        "target_scene_candidates": ["scenes/rooms/stage25_thunder_waste_room_base.tscn"],
    },
    "stage29_thunder_waste_state_vfx_ai01": {
        "resource_type": "SpriteFrames plus AtlasTexture",
        "target_system": "Stage25 storm, relay, barrier, route and outpost state presentation",
        "target_scene_candidates": ["scenes/rooms/stage25_thunder_waste_room_base.tscn"],
    },
}

SOURCE_DEV_ASSET_IDS = {
    "stage16_luna_player_readability_ai01",
    "stage14_air_dash_icon_ai01",
    "stage14_air_dash_shrine_ai01",
    "stage14_air_dash_gate_ai01",
    "stage15_seal_guardian_ai01",
    "stage15_boss_attack_warning_ai01",
    "stage15_recovery_charge_icon_ai01",
    "miasma_marsh_tileset_ai01",
    "stage15_boss_hud_frame_ai01",
    "stage14_ability_status_hud_ai01",
}

ARCHIVE_ASSET_IDS = {
    "luna_run_sheet_ai01",
    "luna_air_dash_sheet_ai01",
    "luna_attack_01_sheet_ai01",
    "luna_idle_sheet_ai01",
    "seal_guardian_boss_sheet_ai01",
    "luna_jump_fall_sheet_ai01",
    "luna_hit_death_sheet_ai01",
    "enemies_core_sheet_ai01",
    "vfx_combat_atlas_ai01",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a runtime/release integration map for image-gen assets.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to the image-gen prompt queue.",
    )
    parser.add_argument(
        "--provenance",
        default="docs/assets/asset-provenance-records.json",
        help="Path to the asset provenance report.",
    )
    parser.add_argument(
        "--out",
        default=DEFAULT_REPORT,
        help="Output integration map path.",
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


def normalize_rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def rule_for(asset_id: str, target_kind: str) -> dict[str, Any]:
    if target_kind in TARGET_KIND_RULES:
        rule = dict(TARGET_KIND_RULES[target_kind])
    else:
        release_track = RELEASE_RULES.get(target_kind, "manual_review")
        rule = {
            "track": release_track,
            "resource_type": "Texture2D",
            "target_system": "release/narrative asset binding",
            "target_scene_candidates": ["scenes/dev/imagegen_asset_gallery.tscn"],
        }
    rule.update(ASSET_ID_RULE_OVERRIDES.get(asset_id, {}))
    if asset_id in SOURCE_DEV_ASSET_IDS:
        rule["track"] = "source_dev"
        rule["disposition"] = "source_dev_keep"
    elif asset_id in ARCHIVE_ASSET_IDS:
        rule["track"] = "archive"
        rule["disposition"] = "archive_keep"
    elif str(rule["track"]).startswith("runtime_"):
        rule["disposition"] = "runtime_keep"
    else:
        rule["disposition"] = "source_dev_keep"
    return rule


def read_scene_text(root: Path, scene: str) -> str:
    path = resolve_path(root, scene)
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def scene_paths(root: Path, development: bool) -> list[str]:
    paths: list[str] = []
    for path in (root / "scenes").rglob("*.tscn"):
        relative = normalize_rel(path, root)
        if relative.startswith("scenes/dev/") == development:
            paths.append(relative)
    return sorted(paths)


def script_paths(root: Path, development: bool) -> list[str]:
    paths: list[str] = []
    for path in (root / "scripts").rglob("*.gd"):
        relative = normalize_rel(path, root)
        if relative.startswith("scripts/dev/") == development:
            paths.append(relative)
    return sorted(paths)


def find_direct_references(root: Path, consumers: list[str], asset_id: str, output_path: str) -> list[str]:
    references: list[str] = []
    res_path = "res://" + output_path.replace("\\", "/")
    output_stem = Path(output_path).stem
    for consumer in consumers:
        text = read_scene_text(root, consumer)
        if not text:
            continue
        if asset_id in text or res_path in text or output_stem in text:
            references.append(consumer)
    return references


def integration_status_for(direct_references: list[str], track: str) -> str:
    if not track.startswith("runtime_"):
        return "not_runtime_target"
    if direct_references:
        return "scene_reference_verified"
    return "binding_map_ready_manual_replacement_required"


def manual_gates_for(status: str) -> list[str]:
    if status == "not_runtime_target":
        return ["art_quality_review", "scene_or_release_context_review"]
    if status == "scene_reference_verified":
        return [
            "art_quality_review",
            "scale_and_readability_review",
            "scene_or_release_context_review",
        ]
    return [
        "art_quality_review",
        "scale_and_readability_review",
        "runtime_reference_replacement",
        "scene_or_release_context_review",
    ]


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    provenance = load_json(resolve_path(root, args.provenance))
    provenance_by_id = {
        record["asset_id"]: record
        for record in provenance.get("records", [])
    }
    production_scenes = scene_paths(root, development=False)
    development_scenes = scene_paths(root, development=True)
    production_consumers = production_scenes + script_paths(root, development=False)
    development_consumers = development_scenes + script_paths(root, development=True)

    entries: list[dict[str, Any]] = []
    for item in queue.get("items", []):
        asset_id = item["asset_id"]
        target_kind = str(item.get("target_kind", "unknown"))
        rule = rule_for(asset_id, target_kind)
        output_path = resolve_path(root, item["output_path"])
        candidate_scenes = [
            scene
            for scene in rule["target_scene_candidates"]
            if resolve_path(root, scene).exists()
        ]
        provenance_record = provenance_by_id.get(asset_id, {})
        output_rel = normalize_rel(output_path, root)
        direct_scene_references = find_direct_references(root, production_consumers, asset_id, output_rel)
        development_scene_references = find_direct_references(root, development_consumers, asset_id, output_rel)
        integration_status = integration_status_for(direct_scene_references, str(rule["track"]))
        entries.append(
            {
                "asset_id": asset_id,
                "batch": item.get("batch", ""),
                "priority": item.get("priority", ""),
                "target_kind": target_kind,
                "track": rule["track"],
                "disposition": rule["disposition"],
                "target_system": rule["target_system"],
                "recommended_resource_type": rule["resource_type"],
                "output_path": output_rel,
                "output_exists": output_path.exists(),
                "output_sha256": provenance_record.get("output_sha256", ""),
                "target_scene_candidates": rule["target_scene_candidates"],
                "existing_target_scene_candidates": candidate_scenes,
                "direct_scene_references": direct_scene_references,
                "development_scene_references": development_scene_references,
                "integration_status": integration_status,
                "manual_gates": manual_gates_for(integration_status),
            }
        )

    track_counts: dict[str, int] = {}
    status_counts: dict[str, int] = {}
    missing_outputs: list[str] = []
    missing_target_scene_candidates: list[str] = []
    development_reference_count = 0
    for entry in entries:
        track = str(entry["track"])
        track_counts[track] = track_counts.get(track, 0) + 1
        status = str(entry["integration_status"])
        status_counts[status] = status_counts.get(status, 0) + 1
        if not entry["output_exists"]:
            missing_outputs.append(entry["asset_id"])
        if not entry["existing_target_scene_candidates"]:
            missing_target_scene_candidates.append(entry["asset_id"])
        if entry["development_scene_references"]:
            development_reference_count += 1

    report = {
        "version": 1,
        "status": "runtime_map_scene_reference_split_ready",
        "boundary": (
            "Runtime/release integration map only. It assigns generated assets to target systems, "
            "resource types and candidate scenes, and records production and development consumer references separately; "
            "it does not approve final art quality."
        ),
        "summary": {
            "entry_count": len(entries),
            "track_counts": dict(sorted(track_counts.items())),
            "status_counts": dict(sorted(status_counts.items())),
            "directly_referenced_entry_count": status_counts.get("scene_reference_verified", 0),
            "development_referenced_entry_count": development_reference_count,
            "missing_output_count": len(missing_outputs),
            "missing_target_scene_candidate_count": len(missing_target_scene_candidates),
        },
        "missing_outputs": missing_outputs,
        "missing_target_scene_candidates": missing_target_scene_candidates,
        "entries": entries,
    }

    out_path = resolve_path(root, args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        "Asset runtime integration map built: "
        f"{report['summary']['entry_count']} entries, "
        f"{len(report['summary']['track_counts'])} tracks."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
