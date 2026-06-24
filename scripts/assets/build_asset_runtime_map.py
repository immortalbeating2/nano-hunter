#!/usr/bin/env python3
"""Build a runtime/release integration map for generated image-gen assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/asset-runtime-integration-map.json"

TARGET_KIND_RULES = {
    "boss_direction": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "Seal Guardian boss readability direction",
        "target_scene_candidates": ["scenes/enemies/seal_guardian_boss.tscn", "scenes/rooms/stage15_seal_guardian_boss_room.tscn"],
    },
    "character_direction": {
        "track": "runtime_gameplay",
        "resource_type": "Texture2D",
        "target_system": "player visual readability direction",
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
        rule.update(ASSET_ID_RULE_OVERRIDES.get(asset_id, {}))
        return rule
    release_track = RELEASE_RULES.get(target_kind, "manual_review")
    rule = {
        "track": release_track,
        "resource_type": "Texture2D",
        "target_system": "release/narrative asset binding",
        "target_scene_candidates": ["scenes/dev/imagegen_asset_gallery.tscn"],
    }
    rule.update(ASSET_ID_RULE_OVERRIDES.get(asset_id, {}))
    return rule


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    provenance = load_json(resolve_path(root, args.provenance))
    provenance_by_id = {
        record["asset_id"]: record
        for record in provenance.get("records", [])
    }

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
        entries.append(
            {
                "asset_id": asset_id,
                "batch": item.get("batch", ""),
                "priority": item.get("priority", ""),
                "target_kind": target_kind,
                "track": rule["track"],
                "target_system": rule["target_system"],
                "recommended_resource_type": rule["resource_type"],
                "output_path": normalize_rel(output_path, root),
                "output_exists": output_path.exists(),
                "output_sha256": provenance_record.get("output_sha256", ""),
                "target_scene_candidates": rule["target_scene_candidates"],
                "existing_target_scene_candidates": candidate_scenes,
                "integration_status": "binding_map_ready_manual_replacement_required",
                "manual_gates": [
                    "art_quality_review",
                    "scale_and_readability_review",
                    "runtime_reference_replacement",
                    "scene_or_release_context_review",
                ],
            }
        )

    track_counts: dict[str, int] = {}
    missing_outputs: list[str] = []
    missing_target_scene_candidates: list[str] = []
    for entry in entries:
        track = str(entry["track"])
        track_counts[track] = track_counts.get(track, 0) + 1
        if not entry["output_exists"]:
            missing_outputs.append(entry["asset_id"])
        if not entry["existing_target_scene_candidates"]:
            missing_target_scene_candidates.append(entry["asset_id"])

    report = {
        "version": 1,
        "status": "binding_map_ready_manual_replacement_required",
        "boundary": (
            "Runtime/release integration map only. It assigns generated assets to target systems, "
            "resource types and candidate scenes; it does not replace scene references or approve final art."
        ),
        "summary": {
            "entry_count": len(entries),
            "track_counts": dict(sorted(track_counts.items())),
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
