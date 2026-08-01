#!/usr/bin/env python3
"""Audit the full Nano Hunter image-gen asset package and editor resources."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_REPORT = "docs/assets/asset-package-audit-report.json"
REQUIRED_TARGET_KIND_FAMILIES = {
    "style": {"style_board"},
    "characters": {"character_direction", "sprite_sheet", "boss_direction", "spine_cutout_parts"},
    "environment": {"tileset_sheet", "environment_tiles", "environment_background", "environment_room_background", "environment_boss_room_background"},
    "ui": {"ui_atlas", "ui_panel", "ui_map_foundation", "hud_frame", "completion_ui", "title_background", "ninepatch_sheet"},
    "icons": {"icon", "icon_sheet"},
    "props_equipment": {"prop", "prop_atlas", "prop_sheet", "equipment_atlas"},
    "vfx": {"vfx_direction", "vfx_warning", "vfx_sheet", "vfx_atlas"},
    "textures": {"texture_atlas"},
    "promo_logo_cg": {"promo_key_art", "promo_capsule", "logo_direction", "cg_illustration"},
    "story": {"storyboard_sheet"},
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit image-gen asset package coverage and generated Godot editor resources.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to image-gen prompt queue.",
    )
    parser.add_argument(
        "--atlas-manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to atlas build manifest.",
    )
    parser.add_argument(
        "--report",
        default=DEFAULT_REPORT,
        help="Report JSON path to write when --write-report is used.",
    )
    parser.add_argument(
        "--write-report",
        action="store_true",
        help="Write a JSON audit report.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure when required coverage or resources are missing.",
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


def resolve_res_path(root: Path, value: str) -> Path:
    if value.startswith("res://"):
        return root / value.removeprefix("res://")
    return resolve_path(root, value)


def candidate_dir(root: Path, item: dict[str, Any]) -> Path:
    source_dir = resolve_path(root, item["source_dir"])
    if source_dir.name == "candidates":
        return source_dir
    return source_dir.parent / "candidates"


def audit_queue(root: Path, queue: dict[str, Any]) -> dict[str, Any]:
    items = queue["items"]
    missing_candidates: list[str] = []
    missing_outputs: list[str] = []
    target_kind_counts: dict[str, int] = {}
    batch_counts: dict[str, int] = {}
    output_paths: set[str] = set()
    candidate_count = 0

    for item in items:
        asset_id = item["asset_id"]
        target_kind = str(item.get("target_kind", "unknown"))
        batch = str(item.get("batch", "unknown"))
        target_kind_counts[target_kind] = target_kind_counts.get(target_kind, 0) + 1
        batch_counts[batch] = batch_counts.get(batch, 0) + 1

        candidates = sorted(candidate_dir(root, item).glob("*_candidate_*.png"))
        candidate_count += len(candidates)
        if not candidates:
            missing_candidates.append(asset_id)

        output = resolve_path(root, item["output_path"])
        output_paths.add(output.as_posix())
        if not output.exists():
            missing_outputs.append(asset_id)

    present_kinds = set(target_kind_counts)
    missing_target_families = sorted(
        family for family, kinds in REQUIRED_TARGET_KIND_FAMILIES.items()
        if not present_kinds.intersection(kinds)
    )
    return {
        "item_count": len(items),
        "candidate_png_count": candidate_count,
        "candidate_storage_policy": "raw_candidates_optional_outside_git",
        "unique_output_path_count": len(output_paths),
        "target_kind_counts": dict(sorted(target_kind_counts.items())),
        "batch_counts": dict(sorted(batch_counts.items())),
        "missing_candidates": missing_candidates,
        "missing_outputs": missing_outputs,
        "missing_target_families": missing_target_families,
    }


def audit_atlas_manifest(root: Path, manifest: dict[str, Any]) -> dict[str, Any]:
    outputs = manifest["outputs"]
    missing_outputs: list[str] = []
    missing_metadata: list[str] = []
    missing_spriteframes: list[str] = []
    kind_counts: dict[str, int] = {}
    selected_counts: dict[str, int] = {
        "selected_frames": 0,
        "selected_items": 0,
        "selected_tiles": 0,
        "selected_parts": 0,
        "selected_panels": 0,
    }

    for item in outputs:
        asset_id = item["id"]
        kind = str(item.get("kind", "unknown"))
        kind_counts[kind] = kind_counts.get(kind, 0) + 1
        source_dir = resolve_path(root, item["source_dir"])
        if source_dir.name in selected_counts:
            selected_counts[source_dir.name] += len(list(source_dir.glob("*.png")))
        if not resolve_path(root, item["output"]).exists():
            missing_outputs.append(asset_id)
        if not resolve_path(root, item["metadata"]).exists():
            missing_metadata.append(asset_id)
        sprite_frames = item.get("sprite_frames")
        if sprite_frames and not resolve_path(root, sprite_frames).exists():
            missing_spriteframes.append(asset_id)

    return {
        "output_count": len(outputs),
        "kind_counts": dict(sorted(kind_counts.items())),
        "selected_counts": selected_counts,
        "missing_outputs": missing_outputs,
        "missing_metadata": missing_metadata,
        "missing_spriteframes": missing_spriteframes,
    }


def audit_editor_atlas_textures(root: Path) -> dict[str, Any]:
    index_path = root / "assets/art/editor_resources/editor_atlas_textures.index.json"
    if not index_path.exists():
        return {"present": False, "asset_count": 0, "resource_count": 0, "missing_resources": ["index"]}
    index = load_json(index_path)
    missing: list[str] = []
    for asset in index.get("assets", []):
        for resource in asset.get("resources", []):
            path = resolve_res_path(root, resource["resource"])
            if not path.exists():
                missing.append(resource["resource"])
    return {
        "present": True,
        "asset_count": int(index.get("asset_count", 0)),
        "resource_count": int(index.get("resource_count", 0)),
        "missing_resources": missing,
    }


def audit_tilesets(root: Path) -> dict[str, Any]:
    paths = sorted((root / "assets/art/tilesets/editor_tilesets").glob("*.tileset.tres"))
    rule_paths = sorted((root / "assets/art/tilesets/editor_tilesets").glob("*.tileset_rules.json"))
    expected = {
        "dac_formal_terrain_tileset_ai01_64.tileset.tres",
        "formal_terrain_kit_ai01.tileset.tres",
        "miasma_marsh_tileset_ai01.tileset.tres",
        "shrine_trial_tileset_ai01.tileset.tres",
        "tutorial_thin_platform_visual_ai01.tileset.tres",
    }
    present = {path.name for path in paths}
    expected_rules = {
        "formal_terrain_kit_ai01.tileset_rules.json",
        "miasma_marsh_tileset_ai01.tileset_rules.json",
        "shrine_trial_tileset_ai01.tileset_rules.json",
    }
    present_rules = {path.name for path in rule_paths}
    rule_summaries: list[dict[str, Any]] = []
    total_tiles = 0
    total_collision_ready = 0
    total_hazard_visual_only = 0
    total_manual_review = 0
    for path in rule_paths:
        data = load_json(path)
        counts = data.get("counts", {})
        solid = int(counts.get("solid", 0))
        one_way = int(counts.get("one_way_platform", 0))
        hazard = int(counts.get("hazard_visual_only", 0))
        total_tiles += int(data.get("tile_count", 0))
        total_collision_ready += solid + one_way
        total_hazard_visual_only += hazard
        if data.get("manual_review_required", False):
            total_manual_review += 1
        rule_summaries.append(
            {
                "asset_id": data.get("asset_id", path.stem),
                "path": path.as_posix(),
                "tile_count": int(data.get("tile_count", 0)),
                "physics_layer_count": int(data.get("physics_layer_count", 0)),
                "terrain_set_count": int(data.get("terrain_set_count", 0)),
                "collision_ready_count": solid + one_way,
                "hazard_visual_only_count": hazard,
                "manual_review_required": bool(data.get("manual_review_required", False)),
            }
        )
    return {
        "resource_count": len(paths),
        "resources": [path.as_posix() for path in paths],
        "missing_expected": sorted(expected - present),
        "rule_file_count": len(rule_paths),
        "rules": rule_summaries,
        "missing_expected_rules": sorted(expected_rules - present_rules),
        "total_rule_tiles": total_tiles,
        "total_collision_ready": total_collision_ready,
        "total_hazard_visual_only": total_hazard_visual_only,
        "manual_review_rule_files": total_manual_review,
    }


def audit_styleboxes(root: Path) -> dict[str, Any]:
    index_path = root / "assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
    if not index_path.exists():
        return {"present": False, "resource_count": 0, "missing_resources": ["index"]}
    index = load_json(index_path)
    missing: list[str] = []
    for item in index.get("items", []):
        if not resolve_res_path(root, item["resource"]).exists():
            missing.append(item["resource"])
    return {
        "present": True,
        "resource_count": int(index.get("count", 0)),
        "missing_resources": missing,
    }


def audit_ui_skin(root: Path) -> dict[str, Any]:
    rules_path = root / "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json"
    theme_path = root / "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres"
    missing: list[str] = []
    if not rules_path.exists():
        missing.append("rules")
    if not theme_path.exists():
        missing.append("theme")
    if missing:
        return {
            "present": False,
            "theme_exists": theme_path.exists(),
            "rules_exists": rules_path.exists(),
            "stylebox_mapping_count": 0,
            "standalone_panel_rule_count": 0,
            "missing": missing,
        }

    rules = load_json(rules_path)
    missing_resources: list[str] = []
    for mapping in rules.get("stylebox_mappings", []):
        resource = str(mapping.get("stylebox_resource", ""))
        if not resource or not resolve_res_path(root, resource).exists():
            missing_resources.append(resource or "empty_stylebox_resource")
    for panel in rules.get("standalone_panels", []):
        texture = str(panel.get("texture", ""))
        if not texture or not resolve_res_path(root, texture).exists():
            missing_resources.append(texture or "empty_panel_texture")

    return {
        "present": True,
        "theme": "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres",
        "rules": "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json",
        "theme_exists": theme_path.exists(),
        "rules_exists": rules_path.exists(),
        "stylebox_mapping_count": len(rules.get("stylebox_mappings", [])),
        "standalone_panel_rule_count": len(rules.get("standalone_panels", [])),
        "manual_review_required": bool(rules.get("manual_review_required", False)),
        "missing": missing_resources,
    }


def audit_runtime_ui_skin_binding(root: Path) -> dict[str, Any]:
    theme = "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres"
    stylebox = (
        "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/"
        "000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres"
    )
    scene_specs = {
        "scenes/ui/demo_shell.tscn": {
            "panels": ["MainMenu", "PauseMenu", "CompletionPanel"],
            "textures": {
                "TitleBackground": "res://assets/art/ui/stage16_title_background_ai01.png",
                "MenuIconStrip": "res://assets/art/ui/stage16_demo_menu_icons_ai01.png",
                "PausePanelArt": "res://assets/art/ui/stage16_pause_panel_ui_ai01.png",
                "CompletionPanelArt": "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
            },
        },
        "scenes/ui/tutorial_hud.tscn": {
            "panels": ["PromptPanel", "BattlePanel"],
            "textures": {},
        },
    }
    missing: list[str] = []
    theme_path = resolve_res_path(root, theme)
    theme_text = theme_path.read_text(encoding="utf-8", errors="ignore") if theme_path.exists() else ""
    if not theme_path.exists():
        missing.append("runtime_ui_skin:missing_theme_resource")
    elif stylebox not in theme_text:
        missing.append("runtime_ui_skin:theme_missing_panel_stylebox")
    scene_count = 0
    panel_count = 0
    texture_count = 0
    for scene, spec in scene_specs.items():
        path = root / scene
        if not path.exists():
            missing.append(f"{scene}:missing_scene")
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if theme not in text:
            missing.append(f"{scene}:missing_theme")
        if stylebox not in text and (theme not in text or stylebox not in theme_text):
            missing.append(f"{scene}:missing_panel_stylebox")
        scene_count += 1
        for panel in spec["panels"]:
            marker = f'[node name="{panel}" type="Panel"'
            if marker not in text:
                missing.append(f"{scene}:{panel}:missing_panel_node")
                continue
            panel_count += 1
        for node_name, texture_path in spec["textures"].items():
            marker = f'[node name="{node_name}" type="TextureRect"'
            if marker not in text:
                missing.append(f"{scene}:{node_name}:missing_texture_node")
                continue
            if str(texture_path) not in text:
                missing.append(f"{scene}:{node_name}:missing_texture_reference")
                continue
            texture_count += 1
    return {
        "present": not missing,
        "theme": theme,
        "panel_stylebox": stylebox,
        "scene_count": scene_count,
        "panel_count": panel_count,
        "texture_count": texture_count,
        "missing": missing,
    }


def audit_vfx_rules(root: Path) -> dict[str, Any]:
    index_path = root / "assets/art/vfx/vfx_rules/vfx_rules.index.json"
    if not index_path.exists():
        return {
            "present": False,
            "asset_count": 0,
            "frame_rule_count": 0,
            "collision_disabled_count": 0,
            "damage_disabled_count": 0,
            "missing": ["index"],
        }
    index = load_json(index_path)
    missing: list[str] = []
    frame_rule_count = 0
    collision_disabled_count = 0
    damage_disabled_count = 0
    for asset in index.get("assets", []):
        path = resolve_path(root, asset["path"])
        if not path.exists():
            missing.append(asset["path"])
            continue
        rules = load_json(path)
        for rule in rules.get("rules", []):
            frame_rule_count += 1
            if bool(rule.get("gameplay_collision", True)) is False:
                collision_disabled_count += 1
            if bool(rule.get("damage_source", True)) is False:
                damage_disabled_count += 1
    return {
        "present": True,
        "expected_asset_count": int(index.get("asset_count", -1)),
        "asset_count": int(index.get("asset_count", 0)),
        "expected_frame_rule_count": int(index.get("frame_rule_count", -1)),
        "frame_rule_count": frame_rule_count,
        "collision_disabled_count": collision_disabled_count,
        "damage_disabled_count": damage_disabled_count,
        "missing": missing,
    }


def audit_animation_rules(root: Path) -> dict[str, Any]:
    index_path = root / "assets/art/characters/animation_rules/animation_rules.index.json"
    if not index_path.exists():
        return {
            "present": False,
            "asset_count": 0,
            "frame_rule_count": 0,
            "missing": ["index"],
        }
    index = load_json(index_path)
    missing: list[str] = []
    frame_rule_count = 0
    for asset in index.get("assets", []):
        path = resolve_path(root, asset["path"])
        if not path.exists():
            missing.append(asset["path"])
            continue
        rules = load_json(path)
        frame_rule_count += len(rules.get("rules", []))
    return {
        "present": True,
        "asset_count": int(index.get("asset_count", 0)),
        "frame_rule_count": frame_rule_count,
        "missing": missing,
    }


def audit_spine_exports(root: Path) -> dict[str, Any]:
    index_path = root / "assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json"
    if not index_path.exists():
        return {"present": False, "asset_count": 0, "part_count": 0, "missing_exports": ["index"]}
    index = load_json(index_path)
    missing: list[str] = []
    for asset in index.get("assets", []):
        for key in ("atlas", "spine_style_json", "cutout_manifest"):
            path = resolve_res_path(root, asset[key])
            if not path.exists():
                missing.append(asset[key])
    return {
        "present": True,
        "asset_count": int(index.get("asset_count", 0)),
        "part_count": int(index.get("part_count", 0)),
        "missing_exports": missing,
    }


def audit_gallery(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/imagegen-asset-gallery-manifest.json"
    scene_path = root / "scenes/dev/imagegen_asset_gallery.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "missing": ["manifest"],
            "counts": {},
        }
    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/imagegen-asset-gallery-manifest.json",
        "counts": manifest.get("counts", {}),
        "missing": missing,
    }


def audit_art_readiness(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/art-readiness-audit-report.json"
    if not report_path.exists():
        return {
            "present": False,
            "ok": False,
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "ok": bool(report.get("ok", False)),
        "summary": report.get("summary", {}),
        "errors": report.get("errors", []),
    }


def image_has_alpha(path: Path) -> bool:
    with Image.open(path) as image:
        return image.mode in {"RGBA", "LA"} or "transparency" in image.info


def audit_background_alpha_policy(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/background-alpha-policy-report.json"
    if not report_path.exists():
        return {
            "present": False,
            "summary": {},
            "missing": ["report"],
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    records = report.get("records", [])
    missing: list[str] = []
    preview_alpha_errors: list[str] = []
    policy_counts: dict[str, int] = {}
    for record in records:
        asset_id = str(record.get("asset_id", "unknown"))
        status = str(record.get("policy_status", ""))
        policy_counts[status] = policy_counts.get(status, 0) + 1
        source_path = resolve_path(root, str(record.get("source_path", "")))
        if not source_path.exists():
            missing.append(f"{asset_id}:source")
        preview = str(record.get("opaque_preview_path", ""))
        if preview:
            preview_path = resolve_path(root, preview)
            if not preview_path.exists():
                missing.append(f"{asset_id}:opaque_preview")
            elif image_has_alpha(preview_path):
                preview_alpha_errors.append(asset_id)
    errors: list[str] = []
    if len(records) != 11:
        errors.append(f"record_count expected 11 got {len(records)}")
    if int(policy_counts.get("alpha_allowed_for_tile_or_atlas_padding", 0)) != 5:
        errors.append("alpha_allowed_for_tile_or_atlas_padding expected 5")
    if int(policy_counts.get("opaque_preview_ready_manual_review", 0)) != 6:
        errors.append("opaque_preview_ready_manual_review expected 6")
    if missing:
        errors.append(f"missing: {missing}")
    if preview_alpha_errors:
        errors.append(f"opaque previews still have alpha: {preview_alpha_errors}")
    summary = report.get("summary", {})
    return {
        "present": True,
        "status": report.get("status", "unknown"),
        "summary": summary,
        "policy_counts": dict(sorted(policy_counts.items())),
        "missing": missing,
        "preview_alpha_errors": preview_alpha_errors,
        "errors": errors,
    }


def audit_final_art_review_queue(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/final-art-review-queue.json"
    markdown_path = root / "docs/assets/final-art-review-queue.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    entries = report.get("entries", [])
    expected_count = len(load_json(root / "docs/assets/image-gen-prompt-queue.json").get("items", []))
    errors: list[str] = []
    if not markdown_path.exists():
        errors.append("markdown_missing")
    if len(entries) != expected_count:
        errors.append(f"entry_count expected {expected_count} got {len(entries)}")
    summary = report.get("summary", {})
    manual_review_count = sum(1 for entry in entries if entry.get("blockers"))
    final_ready_count = sum(1 for entry in entries if bool(entry.get("final_ready", False)))
    if int(summary.get("manual_review_required_count", -1)) != manual_review_count:
        errors.append("manual_review_required_count mismatch")
    if int(summary.get("final_ready_count", -1)) != final_ready_count:
        errors.append("final_ready_count mismatch")
    if manual_review_count + final_ready_count != len(entries):
        errors.append("manual_review_required_count + final_ready_count must equal entry_count")
    for entry in entries:
        asset_id = str(entry.get("asset_id", "unknown"))
        output_path = resolve_path(root, str(entry.get("output_path", "")))
        if not output_path.exists():
            errors.append(f"{asset_id}: output missing")
        if not entry.get("blockers") and not bool(entry.get("final_ready", False)):
            errors.append(f"{asset_id}: blockers missing")
        if len(entry.get("blockers", [])) != len(entry.get("next_actions", [])):
            errors.append(f"{asset_id}: blocker/action mismatch")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "entry_count": len(entries),
        "errors": errors,
    }


def audit_final_art_review_workbench(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/final-art-review-workbench-manifest.json"
    scene_path = root / "scenes/dev/final_art_review_workbench.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "missing": ["manifest"],
            "counts": {},
            "errors": ["manifest_missing"],
        }

    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    errors: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())

    counts = manifest.get("counts", {})
    expected_count = len(load_json(root / "docs/assets/image-gen-prompt-queue.json").get("items", []))
    if int(counts.get("entry_count", -1)) != expected_count:
        errors.append(f"entry_count expected {expected_count}")
    if int(counts.get("texture_card_count", -1)) != expected_count:
        errors.append(f"texture_card_count expected {expected_count}")
    entry_count = int(counts.get("entry_count", -1))
    manual_count = int(counts.get("manual_review_required_count", -1))
    final_ready_count = int(counts.get("final_ready_count", -1))
    if manual_count + final_ready_count != entry_count:
        errors.append("manual_review_required_count + final_ready_count must equal entry_count")
    if missing:
        errors.append(f"missing: {missing}")

    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/final-art-review-workbench-manifest.json",
        "counts": counts,
        "missing": missing,
        "errors": errors,
    }


def audit_final_art_acceptance_gates(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/final-art-acceptance-gates.json"
    markdown_path = root / "docs/assets/final-art-acceptance-gates.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }

    report = load_json(report_path)
    summary = report.get("summary", {})
    expected_count = len(load_json(root / "docs/assets/image-gen-prompt-queue.json").get("items", []))
    errors: list[str] = []
    if not markdown_path.exists():
        errors.append("markdown_missing")
    if int(summary.get("asset_count", -1)) != expected_count:
        errors.append(f"asset_count expected {expected_count}")
    final_ready_count = int(summary.get("final_ready_count", -1))
    blocked_asset_count = int(summary.get("blocked_asset_count", -1))
    if final_ready_count + blocked_asset_count != expected_count:
        errors.append(f"final_ready_count + blocked_asset_count expected {expected_count}")
    if int(summary.get("gate_count", -1)) != 7:
        errors.append("gate_count expected 7")
    gate_summary = summary.get("gate_summary", {})
    for gate_name in (
        "source_traceability",
        "license_terms",
        "godot_structural_resource",
        "editor_review_card",
        "runtime_replacement",
        "family_specific_polish",
        "final_approval",
    ):
        actual = gate_summary.get(gate_name, {})
        if int(actual.get("passed", -1)) + int(actual.get("blocked", -1)) != expected_count:
            errors.append(f"{gate_name} passed + blocked expected {expected_count}")
    final_gate = gate_summary.get("final_approval", {})
    if int(final_gate.get("passed", -1)) != final_ready_count:
        errors.append("final_approval passed must match final_ready_count")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "errors": errors,
    }


def audit_p0_runtime_replacement_plan(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/p0-runtime-replacement-plan.json"
    markdown_path = root / "docs/assets/p0-runtime-replacement-plan.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }

    report = load_json(report_path)
    summary = report.get("summary", {})
    errors: list[str] = []
    if not markdown_path.exists():
        errors.append("markdown_missing")
    entries = report.get("entries", [])
    if int(summary.get("asset_count", -1)) != len(entries):
        errors.append("asset_count mismatch")
    if not entries:
        errors.append("runtime plan has no entries")
    if int(summary.get("missing_resource_count", -1)) != 0:
        errors.append("missing_resource_count expected 0")
    if int(summary.get("missing_target_scene_count", -1)) != 0:
        errors.append("missing_target_scene_count expected 0")
    for entry in report.get("entries", []):
        asset_id = str(entry.get("asset_id", "unknown"))
        if not entry.get("resource_exists"):
            errors.append(f"{asset_id}: resource missing")
        if not entry.get("output_exists"):
            errors.append(f"{asset_id}: output missing")
        if not entry.get("target_scene_status"):
            errors.append(f"{asset_id}: target scenes missing")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "errors": errors,
    }


def expected_p0_rehearsal_counts(plan: dict[str, Any]) -> dict[str, int]:
    counts = {
        "entry_count": 0,
        "texture2d_nodes": 0,
        "spriteframes_nodes": 0,
        "tileset_nodes": 0,
        "stylebox_nodes": 0,
        "atlastexture_nodes": 0,
    }
    for entry in plan.get("entries", []):
        counts["entry_count"] += 1
        resource_type = str(entry.get("catalog_resource_type", "unknown"))
        if resource_type == "SpriteFrames":
            counts["spriteframes_nodes"] += 1
        elif resource_type == "TileSet":
            counts["tileset_nodes"] += 1
        elif resource_type == "StyleBoxTexture":
            counts["stylebox_nodes"] += 1
        elif resource_type == "AtlasTexture":
            counts["atlastexture_nodes"] += 1
        else:
            counts["texture2d_nodes"] += 1
    return counts


def audit_p0_runtime_replacement_rehearsal(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/p0-runtime-replacement-rehearsal-manifest.json"
    scene_path = root / "scenes/dev/p0_runtime_replacement_rehearsal.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "counts": {},
            "errors": ["manifest_missing"],
        }

    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    counts = manifest.get("counts", {})
    errors: list[str] = []
    if not resolved_scene.exists():
        errors.append("scene_missing")
    plan_path = root / "docs/assets/p0-runtime-replacement-plan.json"
    expected_counts = expected_p0_rehearsal_counts(load_json(plan_path)) if plan_path.exists() else {}
    if not expected_counts:
        errors.append("p0 runtime replacement plan missing")
    for key, expected in expected_counts.items():
        if int(counts.get(key, -1)) != expected:
            errors.append(f"{key} expected {expected}")
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/p0-runtime-replacement-rehearsal-manifest.json",
        "counts": counts,
        "errors": errors,
    }


def audit_p0_target_scene_replacement_matrix(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/p0-target-scene-replacement-matrix.json"
    markdown_path = root / "docs/assets/p0-target-scene-replacement-matrix.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }

    report = load_json(report_path)
    summary = report.get("summary", {})
    plan_path = root / "docs/assets/p0-runtime-replacement-plan.json"
    plan = load_json(plan_path) if plan_path.exists() else {}
    plan_entries = plan.get("entries", [])
    expected_asset_ids = {str(entry.get("asset_id", "")) for entry in plan_entries if entry.get("asset_id")}
    expected_reference_count = sum(len(entry.get("target_scene_status", [])) for entry in plan_entries)
    expected_planned_count = sum(
        1
        for entry in plan_entries
        for scene in entry.get("target_scene_status", [])
        if not scene.get("already_references_resource", False)
    )
    matrix_asset_ids = {
        str(asset.get("asset_id", ""))
        for scene in report.get("scenes", [])
        for asset in scene.get("assets", [])
        if asset.get("asset_id")
    }
    errors: list[str] = []
    if not markdown_path.exists():
        errors.append("markdown_missing")
    if int(summary.get("scene_count", -1)) != len(report.get("scenes", [])):
        errors.append("scene_count mismatch")
    if matrix_asset_ids != expected_asset_ids:
        errors.append("unique asset ids do not match P0 runtime plan")
    if int(summary.get("unique_asset_count", -1)) != len(expected_asset_ids):
        errors.append(f"unique_asset_count expected {len(expected_asset_ids)}")
    if int(summary.get("scene_asset_reference_count", -1)) != expected_reference_count:
        errors.append(f"scene_asset_reference_count expected {expected_reference_count}")
    if int(summary.get("missing_scene_count", -1)) != 0:
        errors.append("missing_scene_count expected 0")
    if int(summary.get("planned_scene_asset_replacement_count", -1)) != expected_planned_count:
        errors.append(f"planned_scene_asset_replacement_count expected {expected_planned_count}")
    for scene in report.get("scenes", []):
        scene_path = str(scene.get("scene", ""))
        if not scene.get("exists"):
            errors.append(f"{scene_path}: scene missing")
        if int(scene.get("asset_count", 0)) <= 0:
            errors.append(f"{scene_path}: asset_count missing")
        if not scene.get("validation_commands"):
            errors.append(f"{scene_path}: validation_commands missing")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "errors": errors,
    }


def audit_p0_scene_replacement_batches(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/p0-scene-replacement-batches.json"
    markdown_path = root / "docs/assets/p0-scene-replacement-batches.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }

    report = load_json(report_path)
    summary = report.get("summary", {})
    batches = report.get("batches", [])
    matrix_path = root / "docs/assets/p0-target-scene-replacement-matrix.json"
    matrix = load_json(matrix_path) if matrix_path.exists() else {}
    matrix_summary = matrix.get("summary", {})
    errors: list[str] = []
    if not markdown_path.exists():
        errors.append("markdown_missing")
    if int(summary.get("batch_count", -1)) != len(batches):
        errors.append("batch_count mismatch")
    if not batches:
        errors.append("no replacement batches")
    for key in (
        "scene_count",
        "unique_asset_count",
        "scene_asset_reference_count",
        "planned_scene_asset_replacement_count",
        "already_referenced_scene_asset_count",
    ):
        if int(summary.get(key, -1)) != int(matrix_summary.get(key, -2)):
            errors.append(f"{key} does not match target scene matrix")
    if int(summary.get("missing_scene_count", -1)) != 0:
        errors.append("missing_scene_count expected 0")
    if int(summary.get("unbatched_scene_count", -1)) != 0:
        errors.append("unbatched_scene_count expected 0")

    seen_batch_ids: set[str] = set()
    for order, batch in enumerate(batches):
        batch_id = str(batch.get("batch_id", ""))
        if not batch_id:
            errors.append("empty batch_id")
        if batch_id in seen_batch_ids:
            errors.append(f"{batch_id}: duplicate batch_id")
        seen_batch_ids.add(batch_id)
        if int(batch.get("recommended_order", -1)) != order:
            errors.append(f"{batch_id}: recommended_order mismatch")
        if not batch.get("validation_commands"):
            errors.append(f"{batch_id}: validation_commands missing")
        if not batch.get("replacement_gate_status"):
            errors.append(f"{batch_id}: replacement_gate_status missing")
        if batch.get("missing_scenes"):
            errors.append(f"{batch_id}: missing_scenes not empty")
        if int(batch.get("scene_count", -1)) != len(batch.get("scenes", [])):
            errors.append(f"{batch_id}: scene_count mismatch")
        if int(batch.get("scene_asset_reference_count", 0)) <= 0:
            errors.append(f"{batch_id}: scene_asset_reference_count missing")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "errors": errors,
    }


def audit_asset_semantics(root: Path) -> dict[str, Any]:
    index_path = root / "docs/assets/asset-semantics-index.json"
    if not index_path.exists():
        return {
            "present": False,
            "asset_count": 0,
            "entry_count": 0,
            "missing": ["index"],
        }
    index = load_json(index_path)
    missing: list[str] = []
    for asset in index.get("assets", []):
        path = resolve_path(root, asset["path"])
        if not path.exists():
            missing.append(asset["path"])
    return {
        "present": True,
        "asset_count": int(index.get("asset_count", 0)),
        "entry_count": int(index.get("entry_count", 0)),
        "missing": missing,
    }


def audit_standalone_semantics(root: Path) -> dict[str, Any]:
    paths = [
        root / "assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json",
    ]
    missing = [path.as_posix() for path in paths if not path.exists()]
    entry_count = 0
    for path in paths:
        if path.exists():
            entry_count += len(load_json(path).get("entries", []))
    return {
        "asset_count": len(paths) - len(missing),
        "entry_count": entry_count,
        "missing": missing,
    }


def audit_candidate_pool(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/imagegen-candidate-pool-report.json"
    if not report_path.exists():
        return {
            "present": False,
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_candidate_review_gallery(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/imagegen-candidate-review-gallery-manifest.json"
    scene_path = root / "scenes/dev/imagegen_candidate_review_gallery.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "missing": ["manifest"],
            "counts": {},
        }
    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/imagegen-candidate-review-gallery-manifest.json",
        "counts": manifest.get("counts", {}),
        "missing": missing,
    }


def audit_asset_provenance(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/asset-provenance-records.json"
    if not report_path.exists():
        return {
            "present": False,
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("errors", []),
    }


def audit_imagegen_source_safety(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/imagegen-source-safety-report.json"
    if not report_path.exists():
        return {
            "present": False,
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_runtime_source_safety(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/runtime-source-safety-report.json"
    markdown_path = root / "docs/assets/runtime-source-safety-report.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_runtime_source_review_queue(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/runtime-source-review-queue.json"
    markdown_path = root / "docs/assets/runtime-source-review-queue.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_runtime_source_review_decisions(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/runtime-source-review-decisions.json"
    markdown_path = root / "docs/assets/runtime-source-review-decisions.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    errors: list[str] = []
    if report.get("project_key") != "nano-hunter":
        errors.append("project_key_mismatch")
    summary = report.get("summary", {})
    entries = report.get("entries", [])
    if int(summary.get("decision_count", -1)) != len(entries):
        errors.append("decision_count_mismatch")
    if int(summary.get("final_ready_count", -1)) != 0:
        errors.append("final_ready_count_must_remain_zero")
    for entry in entries:
        if bool(entry.get("final_ready", False)):
            errors.append(f"{entry.get('asset_id', 'unknown')}: final_ready_true")
        output = root / str(entry.get("preferred_runtime_output", ""))
        if not output.exists():
            errors.append(f"{entry.get('asset_id', 'unknown')}: preferred_runtime_output_missing")
    evidence = report.get("evidence", {})
    missing_evidence: list[str] = []
    for sheet in evidence.get("contact_sheets", []):
        if not (root / str(sheet)).exists():
            missing_evidence.append(f"contact_sheet_missing:{sheet}")
    manifest = str(evidence.get("contact_sheet_manifest", ""))
    if manifest and not (root / manifest).exists():
        missing_evidence.append(f"contact_sheet_manifest_missing:{manifest}")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "missing_local_evidence": missing_evidence,
        "errors": errors,
    }


def audit_asset_finalization_reviews(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/asset-finalization-review-records.json"
    markdown_path = root / "docs/assets/asset-finalization-review-records.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    errors: list[str] = []
    if report.get("project_key") != "nano-hunter":
        errors.append("project_key_mismatch")
    if not markdown_path.exists():
        errors.append("markdown_missing")
    summary = report.get("summary", {})
    records = report.get("records", [])
    if int(summary.get("record_count", -1)) != len(records):
        errors.append("record_count_mismatch")
    if int(summary.get("approved_for_final_ready_count", -1)) != len(records):
        errors.append("approved_for_final_ready_count_mismatch")
    for record in records:
        asset_id = str(record.get("asset_id", "unknown"))
        if record.get("review_status") != "approved_for_final_ready":
            errors.append(f"{asset_id}: review_status_not_approved")
        if record.get("final_approval_status") != "approved":
            errors.append(f"{asset_id}: final_approval_status_not_approved")
        if "license_terms_manual_review" not in record.get("approved_blockers", []):
            errors.append(f"{asset_id}: license_blocker_not_approved")
        if not resolve_path(root, str(record.get("output_path", ""))).exists():
            errors.append(f"{asset_id}: output_path_missing")
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": summary,
        "errors": errors,
    }


def audit_runtime_source_regeneration_packet(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/runtime-source-regeneration-packet.json"
    markdown_path = root / "docs/assets/runtime-source-regeneration-packet.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "stale_prompt_packet_allowed": True,
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_runtime_source_regeneration_landing(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/runtime-source-regeneration-landing-report.json"
    markdown_path = root / "docs/assets/runtime-source-regeneration-landing-report.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_runtime_source_review_workbench(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/runtime-source-review-workbench-manifest.json"
    scene_path = root / "scenes/dev/runtime_source_review_workbench.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "counts": {},
            "missing": ["manifest"],
        }
    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/runtime-source-review-workbench-manifest.json",
        "counts": manifest.get("counts", {}),
        "missing": missing,
    }


def audit_asset_family_coverage(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/asset-family-coverage-report.json"
    markdown_path = root / "docs/assets/asset-family-coverage-report.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("errors", []),
    }


def audit_project_asset_isolation(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/project-asset-isolation-report.json"
    markdown_path = root / "docs/assets/project-asset-isolation-report.md"
    if not report_path.exists():
        return {
            "present": False,
            "markdown_exists": markdown_path.exists(),
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "markdown_exists": markdown_path.exists(),
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("summary", {}).get("errors", []),
    }


def audit_asset_runtime_map(root: Path) -> dict[str, Any]:
    report_path = root / "docs/assets/asset-runtime-integration-map.json"
    if not report_path.exists():
        return {
            "present": False,
            "summary": {},
            "errors": ["report_missing"],
        }
    report = load_json(report_path)
    return {
        "present": True,
        "status": report.get("status", "unknown"),
        "summary": report.get("summary", {}),
        "errors": report.get("errors", []),
    }


def audit_runtime_asset_catalog(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/imagegen-runtime-asset-catalog-manifest.json"
    scene_path = root / "scenes/dev/imagegen_runtime_asset_catalog.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "missing": ["manifest"],
            "counts": {},
        }
    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())
    for entry in manifest.get("entries", []):
        resource_path = str(entry.get("resource_path", ""))
        if not resource_path or not resolve_res_path(root, resource_path).exists():
            missing.append(resource_path or f"{entry.get('asset_id', 'unknown')}:empty_resource_path")
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/imagegen-runtime-asset-catalog-manifest.json",
        "counts": manifest.get("counts", {}),
        "missing": missing,
    }


def audit_integration_showcase(root: Path) -> dict[str, Any]:
    manifest_path = root / "docs/assets/imagegen-asset-integration-showcase-manifest.json"
    scene_path = root / "scenes/dev/imagegen_asset_integration_showcase.tscn"
    if not manifest_path.exists():
        return {
            "present": False,
            "scene_exists": scene_path.exists(),
            "missing": ["manifest"],
            "counts": {},
        }
    manifest = load_json(manifest_path)
    declared_scene = str(manifest.get("scene", ""))
    resolved_scene = resolve_res_path(root, declared_scene) if declared_scene else scene_path
    missing: list[str] = []
    if not resolved_scene.exists():
        missing.append(declared_scene or scene_path.as_posix())
    return {
        "present": True,
        "scene_exists": resolved_scene.exists(),
        "scene": declared_scene,
        "manifest": "docs/assets/imagegen-asset-integration-showcase-manifest.json",
        "counts": manifest.get("counts", {}),
        "missing": missing,
    }


def audit_file_counts(root: Path) -> dict[str, int]:
    return {
        "art_png": len(list((root / "assets/art").rglob("*.png"))),
        "art_import": len(list((root / "assets/art").rglob("*.import"))),
        "metadata_json": len(list((root / "assets/art").rglob("*.json"))),
        "spriteframes_tres": len(list((root / "assets/art").rglob("*.spriteframes.tres"))),
        "atlas_texture_tres": len(list((root / "assets/art/editor_resources").rglob("*.atlas_texture.tres"))),
        "tileset_tres": len(list((root / "assets/art/tilesets/editor_tilesets").glob("*.tileset.tres"))),
        "stylebox_texture_tres": len(list((root / "assets/art/ui/styleboxes").rglob("*.stylebox_texture.tres"))),
        "spine_export_files": len(list((root / "assets/art/spine_parts/spine_exports").rglob("*.*"))),
    }


def collect_errors(report: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    queue = report["queue"]
    expected_asset_count = int(queue["item_count"])
    if queue["item_count"] < 55:
        errors.append(f"queue item_count expected at least 55 got {queue['item_count']}")
    for key in ("missing_outputs", "missing_target_families"):
        if queue[key]:
            errors.append(f"queue {key}: {queue[key]}")

    atlas = report["atlas_manifest"]
    if atlas["output_count"] != 26:
        errors.append(f"atlas output_count expected 26 got {atlas['output_count']}")
    for key in ("missing_outputs", "missing_metadata", "missing_spriteframes"):
        if atlas[key]:
            errors.append(f"atlas {key}: {atlas[key]}")

    editor = report["editor_resources"]
    if editor["atlas_textures"]["resource_count"] != 302:
        errors.append("AtlasTexture resource_count expected 302")
    if editor["tilesets"]["resource_count"] != 5:
        errors.append("TileSet resource_count expected 5")
    if editor["tilesets"]["rule_file_count"] != 3:
        errors.append("TileSet rule_file_count expected 3")
    if editor["tilesets"]["total_rule_tiles"] != 144:
        errors.append("TileSet total_rule_tiles expected 144")
    if editor["tilesets"]["total_collision_ready"] != 92:
        errors.append("TileSet total_collision_ready expected 92")
    if editor["tilesets"]["total_hazard_visual_only"] != 9:
        errors.append("TileSet total_hazard_visual_only expected 9")
    if editor["styleboxes"]["resource_count"] != 8:
        errors.append("StyleBoxTexture resource_count expected 8")
    if not editor["ui_skin"]["present"]:
        errors.append("UI skin Theme or rules missing")
    if editor["ui_skin"]["stylebox_mapping_count"] != 9:
        errors.append("UI skin stylebox_mapping_count expected 9")
    if editor["ui_skin"]["standalone_panel_rule_count"] != 4:
        errors.append("UI skin standalone_panel_rule_count expected 4")

    runtime_ui_skin = report["runtime_ui_skin_binding"]
    if not runtime_ui_skin["present"]:
        errors.append("runtime UI skin binding missing")
    if int(runtime_ui_skin.get("scene_count", -1)) != 2:
        errors.append("runtime UI skin scene_count expected 2")
    if int(runtime_ui_skin.get("panel_count", -1)) != 5:
        errors.append("runtime UI skin panel_count expected 5")
    if int(runtime_ui_skin.get("texture_count", -1)) != 4:
        errors.append("runtime UI skin texture_count expected 4")
    if runtime_ui_skin.get("missing"):
        errors.append(f"runtime UI skin missing: {runtime_ui_skin['missing']}")

    if not editor["vfx_rules"]["present"]:
        errors.append("VFX rules index missing")
    expected_vfx_asset_count = int(editor["vfx_rules"].get("expected_asset_count", -1))
    actual_vfx_asset_count = int(editor["vfx_rules"].get("asset_count", -1))
    if actual_vfx_asset_count != expected_vfx_asset_count:
        errors.append(f"VFX rules asset_count expected {expected_vfx_asset_count} got {actual_vfx_asset_count}")
    expected_vfx_rules = int(editor["vfx_rules"].get("expected_frame_rule_count", -1))
    actual_vfx_rules = int(editor["vfx_rules"].get("frame_rule_count", -1))
    if actual_vfx_rules != expected_vfx_rules:
        errors.append(f"VFX rules frame_rule_count expected {expected_vfx_rules} got {actual_vfx_rules}")
    if editor["vfx_rules"]["collision_disabled_count"] != actual_vfx_rules:
        errors.append("VFX rules collision_disabled_count must match frame_rule_count")
    if editor["vfx_rules"]["damage_disabled_count"] != actual_vfx_rules:
        errors.append("VFX rules damage_disabled_count must match frame_rule_count")
    if not editor["animation_rules"]["present"]:
        errors.append("Animation rules index missing")
    if editor["animation_rules"]["asset_count"] != 8:
        errors.append("Animation rules asset_count expected 8")
    if editor["animation_rules"]["frame_rule_count"] != 172:
        errors.append("Animation rules frame_rule_count expected 172")
    if editor["spine_exports"]["asset_count"] != 2 or editor["spine_exports"]["part_count"] != 48:
        errors.append("Spine cutout exports expected 2 assets and 48 parts")

    for section_name, section in editor.items():
        for key, value in section.items():
            if key.startswith("missing") and value:
                errors.append(f"{section_name} {key}: {value}")

    gallery = report["gallery"]
    if not gallery["present"] or not gallery["scene_exists"]:
        errors.append("imagegen asset gallery scene or manifest is missing")
    gallery_counts = gallery.get("counts", {})
    expected_gallery_counts = {
        "queue_outputs": expected_asset_count,
        "atlas_textures": 302,
        "tilesets": 2,
        "styleboxes": 8,
        "spine_parts": 48,
    }
    for key, expected in expected_gallery_counts.items():
        actual = int(gallery_counts.get(key, -1))
        if actual != expected:
            errors.append(f"gallery {key} expected {expected} got {actual}")
    if gallery.get("missing"):
        errors.append(f"gallery missing: {gallery['missing']}")

    art_readiness = report["art_readiness"]
    if not art_readiness["present"] or not art_readiness["ok"]:
        errors.append("art readiness report is missing or has structural errors")
    readiness_summary = art_readiness.get("summary", {})
    if int(readiness_summary.get("item_count", -1)) != expected_asset_count:
        errors.append(f"art readiness item_count expected {expected_asset_count}")
    if int(readiness_summary.get("structural_ready_count", -1)) != expected_asset_count:
        errors.append(f"art readiness structural_ready_count expected {expected_asset_count}")

    background_alpha_policy = report["background_alpha_policy"]
    if not background_alpha_policy["present"]:
        errors.append("background alpha policy report is missing")
    policy_summary = background_alpha_policy.get("summary", {})
    if int(policy_summary.get("record_count", -1)) != 11:
        errors.append("background alpha policy record_count expected 11")
    if int(policy_summary.get("opaque_preview_count", -1)) != 6:
        errors.append("background alpha policy opaque_preview_count expected 6")
    if background_alpha_policy.get("errors"):
        errors.append(f"background alpha policy errors: {background_alpha_policy['errors']}")

    final_art_review = report["final_art_review_queue"]
    if not final_art_review["present"]:
        errors.append("final art review queue is missing")
    if not final_art_review.get("markdown_exists"):
        errors.append("final art review queue markdown is missing")
    review_summary = final_art_review.get("summary", {})
    if int(review_summary.get("asset_count", -1)) != expected_asset_count:
        errors.append(f"final art review queue asset_count expected {expected_asset_count}")
    review_manual = int(review_summary.get("manual_review_required_count", -1))
    review_final = int(review_summary.get("final_ready_count", -1))
    if review_manual + review_final != expected_asset_count:
        errors.append(f"final art review queue manual + final expected {expected_asset_count}")
    if final_art_review.get("errors"):
        errors.append(f"final art review queue errors: {final_art_review['errors']}")

    final_art_workbench = report["final_art_review_workbench"]
    if not final_art_workbench["present"] or not final_art_workbench["scene_exists"]:
        errors.append("final art review workbench scene or manifest is missing")
    workbench_counts = final_art_workbench.get("counts", {})
    if int(workbench_counts.get("entry_count", -1)) != expected_asset_count:
        errors.append(f"final art review workbench entry_count expected {expected_asset_count}")
    if int(workbench_counts.get("texture_card_count", -1)) != expected_asset_count:
        errors.append(f"final art review workbench texture_card_count expected {expected_asset_count}")
    workbench_manual = int(workbench_counts.get("manual_review_required_count", -1))
    workbench_final = int(workbench_counts.get("final_ready_count", -1))
    if workbench_manual + workbench_final != expected_asset_count:
        errors.append(f"final art review workbench manual + final expected {expected_asset_count}")
    if final_art_workbench.get("errors"):
        errors.append(f"final art review workbench errors: {final_art_workbench['errors']}")

    final_art_gates = report["final_art_acceptance_gates"]
    if not final_art_gates["present"]:
        errors.append("final art acceptance gates report is missing")
    if not final_art_gates.get("markdown_exists"):
        errors.append("final art acceptance gates markdown is missing")
    gates_summary = final_art_gates.get("summary", {})
    if int(gates_summary.get("asset_count", -1)) != expected_asset_count:
        errors.append(f"final art acceptance gates asset_count expected {expected_asset_count}")
    gates_blocked = int(gates_summary.get("blocked_asset_count", -1))
    gates_final = int(gates_summary.get("final_ready_count", -1))
    if gates_blocked + gates_final != expected_asset_count:
        errors.append(f"final art acceptance gates blocked + final expected {expected_asset_count}")
    if int(gates_summary.get("gate_count", -1)) != 7:
        errors.append("final art acceptance gates gate_count expected 7")
    if final_art_gates.get("errors"):
        errors.append(f"final art acceptance gates errors: {final_art_gates['errors']}")

    p0_runtime_plan = report["p0_runtime_replacement_plan"]
    if not p0_runtime_plan["present"]:
        errors.append("P0 runtime replacement plan is missing")
    if not p0_runtime_plan.get("markdown_exists"):
        errors.append("P0 runtime replacement plan markdown is missing")
    p0_summary = p0_runtime_plan.get("summary", {})
    p0_asset_count = int(p0_summary.get("asset_count", -1))
    if p0_asset_count <= 0:
        errors.append("P0 runtime replacement plan asset_count must be positive")
    if int(p0_summary.get("missing_resource_count", -1)) != 0:
        errors.append("P0 runtime replacement plan missing_resource_count expected 0")
    if int(p0_summary.get("missing_target_scene_count", -1)) != 0:
        errors.append("P0 runtime replacement plan missing_target_scene_count expected 0")
    if p0_runtime_plan.get("errors"):
        errors.append(f"P0 runtime replacement plan errors: {p0_runtime_plan['errors']}")

    p0_rehearsal = report["p0_runtime_replacement_rehearsal"]
    if not p0_rehearsal["present"] or not p0_rehearsal["scene_exists"]:
        errors.append("P0 runtime replacement rehearsal scene or manifest is missing")
    rehearsal_counts = p0_rehearsal.get("counts", {})
    if int(rehearsal_counts.get("entry_count", -1)) != p0_asset_count:
        errors.append(
            f"P0 runtime replacement rehearsal entry_count expected {p0_asset_count}"
        )
    if p0_rehearsal.get("errors"):
        errors.append(f"P0 runtime replacement rehearsal errors: {p0_rehearsal['errors']}")

    p0_scene_matrix = report["p0_target_scene_replacement_matrix"]
    if not p0_scene_matrix["present"]:
        errors.append("P0 target scene replacement matrix is missing")
    if not p0_scene_matrix.get("markdown_exists"):
        errors.append("P0 target scene replacement matrix markdown is missing")
    scene_matrix_summary = p0_scene_matrix.get("summary", {})
    if int(scene_matrix_summary.get("unique_asset_count", -1)) != p0_asset_count:
        errors.append(
            f"P0 target scene replacement matrix unique_asset_count expected {p0_asset_count}"
        )
    if int(scene_matrix_summary.get("scene_asset_reference_count", -1)) <= 0:
        errors.append("P0 target scene replacement matrix has no scene-asset references")
    if int(scene_matrix_summary.get("missing_scene_count", -1)) != 0:
        errors.append("P0 target scene replacement matrix missing_scene_count expected 0")
    if p0_scene_matrix.get("errors"):
        errors.append(f"P0 target scene replacement matrix errors: {p0_scene_matrix['errors']}")

    p0_scene_batches = report["p0_scene_replacement_batches"]
    if not p0_scene_batches["present"]:
        errors.append("P0 scene replacement batches are missing")
    if not p0_scene_batches.get("markdown_exists"):
        errors.append("P0 scene replacement batches markdown is missing")
    scene_batches_summary = p0_scene_batches.get("summary", {})
    if int(scene_batches_summary.get("batch_count", -1)) <= 0:
        errors.append("P0 scene replacement batches batch_count must be positive")
    for key in ("scene_count", "unique_asset_count", "scene_asset_reference_count"):
        if int(scene_batches_summary.get(key, -1)) != int(scene_matrix_summary.get(key, -2)):
            errors.append(f"P0 scene replacement batches {key} does not match matrix")
    if int(scene_batches_summary.get("missing_scene_count", -1)) != 0:
        errors.append("P0 scene replacement batches missing_scene_count expected 0")
    if int(scene_batches_summary.get("unbatched_scene_count", -1)) != 0:
        errors.append("P0 scene replacement batches unbatched_scene_count expected 0")
    if p0_scene_batches.get("errors"):
        errors.append(f"P0 scene replacement batches errors: {p0_scene_batches['errors']}")

    semantics = report["asset_semantics"]
    if not semantics["present"]:
        errors.append("asset semantics index is missing")
    if int(semantics.get("asset_count", -1)) != 26:
        errors.append("asset semantics asset_count expected 26")
    if int(semantics.get("entry_count", -1)) != 538:
        errors.append("asset semantics entry_count expected 538")
    if semantics.get("missing"):
        errors.append(f"asset semantics missing: {semantics['missing']}")

    standalone_semantics = report["standalone_semantics"]
    if int(standalone_semantics.get("asset_count", -1)) != 1:
        errors.append("standalone semantics asset_count expected 1")
    if int(standalone_semantics.get("entry_count", -1)) != 6:
        errors.append("standalone semantics entry_count expected 6")
    if standalone_semantics.get("missing"):
        errors.append(f"standalone semantics missing: {standalone_semantics['missing']}")

    candidate_pool = report["candidate_pool"]
    if not candidate_pool["present"]:
        errors.append("imagegen candidate pool report is missing")
    candidate_summary = candidate_pool.get("summary", {})
    if int(candidate_summary.get("queue_item_count", -1)) != queue["item_count"]:
        errors.append("candidate pool queue_item_count must match current queue")
    if int(candidate_summary.get("candidate_png_count", -1)) < queue["candidate_png_count"]:
        errors.append("candidate pool candidate count is lower than queue scan")
    if candidate_pool.get("errors"):
        errors.append(f"candidate pool errors: {candidate_pool['errors']}")

    candidate_review_gallery = report["candidate_review_gallery"]
    if not candidate_review_gallery["present"] or not candidate_review_gallery["scene_exists"]:
        errors.append("imagegen candidate review gallery scene or manifest is missing")
    review_counts = candidate_review_gallery.get("counts", {})
    expected_unselected = int(candidate_summary.get("unselected_candidate_count", -1))
    expected_review_assets = int(candidate_summary.get("review_required_item_count", -1))
    actual_unselected = int(review_counts.get("unselected_candidates", -1))
    actual_review_assets = int(review_counts.get("review_required_assets", -1))
    if actual_unselected > expected_unselected:
        errors.append(f"candidate_review_gallery unselected_candidates expected {expected_unselected} got {actual_unselected}")
    if actual_review_assets != expected_review_assets:
        errors.append(f"candidate_review_gallery review_required_assets expected {expected_review_assets} got {actual_review_assets}")
    if candidate_review_gallery.get("missing"):
        errors.append(f"candidate_review_gallery missing: {candidate_review_gallery['missing']}")

    provenance = report["asset_provenance"]
    if not provenance["present"]:
        errors.append("asset provenance report is missing")
    provenance_summary = provenance.get("summary", {})
    if int(provenance_summary.get("record_count", -1)) != queue["item_count"]:
        errors.append("asset provenance record_count must match current queue")
    if int(provenance_summary.get("output_hash_count", -1)) != queue["item_count"]:
        errors.append("asset provenance output_hash_count must match current queue")
    if int(provenance_summary.get("candidate_hash_count", -1)) != int(candidate_summary.get("candidate_png_count", -2)):
        errors.append("asset provenance candidate_hash_count must match candidate pool candidate_png_count")
    if provenance.get("errors"):
        errors.append(f"asset provenance errors: {provenance['errors']}")

    source_safety = report["imagegen_source_safety"]
    if not source_safety["present"]:
        errors.append("imagegen source safety report is missing")
    safety_summary = source_safety.get("summary", {})
    if int(safety_summary.get("queue_item_count", -1)) != queue["item_count"]:
        errors.append("imagegen source safety queue_item_count must match current queue")
    if int(safety_summary.get("candidate_count", -1)) != int(candidate_summary.get("candidate_png_count", -2)):
        errors.append("imagegen source safety candidate_count must match candidate pool candidate_png_count")
    if int(safety_summary.get("unsafe_candidate_count", -1)) != 0:
        errors.append("imagegen source safety unsafe_candidate_count expected 0")
    if source_safety.get("errors"):
        errors.append(f"imagegen source safety errors: {source_safety['errors']}")

    runtime_source_safety = report["runtime_source_safety"]
    if not runtime_source_safety["present"]:
        errors.append("runtime source safety report is missing")
    if not runtime_source_safety.get("markdown_exists"):
        errors.append("runtime source safety markdown is missing")
    runtime_source_summary = runtime_source_safety.get("summary", {})
    expected_runtime_asset_count = int(
        report["p0_runtime_replacement_plan"].get("summary", {}).get("asset_count", -2)
    )
    if int(runtime_source_summary.get("runtime_asset_count", -1)) != expected_runtime_asset_count:
        errors.append(
            f"runtime source safety runtime_asset_count expected {expected_runtime_asset_count}"
        )
    if int(runtime_source_summary.get("unsafe_item_count", -1)) != 0:
        errors.append("runtime source safety unsafe_item_count expected 0")
    if runtime_source_safety.get("errors"):
        errors.append(f"runtime source safety errors: {runtime_source_safety['errors']}")

    runtime_source_review = report["runtime_source_review_queue"]
    if not runtime_source_review["present"]:
        errors.append("runtime source review queue is missing")
    if not runtime_source_review.get("markdown_exists"):
        errors.append("runtime source review queue markdown is missing")
    runtime_review_summary = runtime_source_review.get("summary", {})
    expected_runtime_review = int(runtime_source_summary.get("runtime_review_required_count", -1))
    actual_runtime_review = int(runtime_review_summary.get("runtime_review_required_count", -2))
    if actual_runtime_review != expected_runtime_review:
        errors.append(f"runtime source review queue expected {expected_runtime_review} got {actual_runtime_review}")
    if int(runtime_review_summary.get("unsafe_item_count", -1)) != 0:
        errors.append("runtime source review queue unsafe_item_count expected 0")
    strategy_total = sum(int(value) for value in runtime_review_summary.get("strategy_counts", {}).values())
    if strategy_total != actual_runtime_review:
        errors.append("runtime source review queue strategy count must match review-required count")
    if runtime_source_review.get("errors"):
        errors.append(f"runtime source review queue errors: {runtime_source_review['errors']}")

    runtime_source_decisions = report["runtime_source_review_decisions"]
    if not runtime_source_decisions["present"]:
        errors.append("runtime source review decisions are missing")
    if not runtime_source_decisions.get("markdown_exists"):
        errors.append("runtime source review decisions markdown is missing")
    runtime_decision_summary = runtime_source_decisions.get("summary", {})
    if actual_runtime_review > 0 and int(runtime_decision_summary.get("decision_count", -1)) != actual_runtime_review:
        errors.append(f"runtime source review decisions expected {actual_runtime_review}")
    if actual_runtime_review > 0 and int(runtime_decision_summary.get("confirmed_for_cleanup_count", -1)) != actual_runtime_review:
        errors.append("runtime source review decisions must confirm all review-required assets for cleanup")
    if int(runtime_decision_summary.get("final_ready_count", -1)) != 0:
        errors.append("runtime source review decisions final_ready_count expected 0")
    if runtime_source_decisions.get("errors"):
        errors.append(f"runtime source review decisions errors: {runtime_source_decisions['errors']}")

    finalization_reviews = report["asset_finalization_reviews"]
    if not finalization_reviews["present"]:
        errors.append("asset finalization review records are missing")
    if not finalization_reviews.get("markdown_exists"):
        errors.append("asset finalization review records markdown is missing")
    finalization_summary = finalization_reviews.get("summary", {})
    if int(finalization_summary.get("record_count", -1)) <= 0:
        errors.append("asset finalization review records expected at least one record")
    if int(finalization_summary.get("approved_for_final_ready_count", -1)) != int(
        finalization_summary.get("record_count", -2)
    ):
        errors.append("asset finalization review approved count must match record count")
    if finalization_reviews.get("errors"):
        errors.append(f"asset finalization review errors: {finalization_reviews['errors']}")

    runtime_regeneration = report["runtime_source_regeneration_packet"]
    if not runtime_regeneration["present"]:
        errors.append("runtime source regeneration packet is missing")
    if not runtime_regeneration.get("markdown_exists"):
        errors.append("runtime source regeneration packet markdown is missing")
    runtime_regeneration_summary = runtime_regeneration.get("summary", {})
    expected_regeneration = int(
        runtime_review_summary.get("strategy_counts", {}).get("manual_source_review_or_regenerate", 0)
    )
    actual_regeneration = int(runtime_regeneration_summary.get("asset_count", -2))
    if expected_regeneration > 0 and actual_regeneration != expected_regeneration:
        errors.append(f"runtime source regeneration packet expected {expected_regeneration} got {actual_regeneration}")
    if runtime_regeneration.get("errors"):
        errors.append(f"runtime source regeneration packet errors: {runtime_regeneration['errors']}")

    runtime_landing = report["runtime_source_regeneration_landing"]
    if not runtime_landing["present"]:
        errors.append("runtime source regeneration landing report is missing")
    if not runtime_landing.get("markdown_exists"):
        errors.append("runtime source regeneration landing markdown is missing")
    runtime_landing_summary = runtime_landing.get("summary", {})
    if int(runtime_landing_summary.get("invalid_count", 0)) != 0:
        errors.append("runtime source regeneration landing invalid_count expected 0")
    if runtime_landing.get("errors"):
        errors.append(f"runtime source regeneration landing errors: {runtime_landing['errors']}")

    runtime_review_workbench = report["runtime_source_review_workbench"]
    if not runtime_review_workbench["present"] or not runtime_review_workbench["scene_exists"]:
        errors.append("runtime source review workbench scene or manifest is missing")
    workbench_counts = runtime_review_workbench.get("counts", {})
    if actual_runtime_review > 0 and int(workbench_counts.get("entry_count", -1)) != actual_runtime_review:
        errors.append(f"runtime source review workbench entry_count expected {actual_runtime_review}")
    if actual_runtime_review > 0 and int(workbench_counts.get("current_output_count", -1)) != actual_runtime_review:
        errors.append(f"runtime source review workbench current_output_count expected {actual_runtime_review}")
    if actual_runtime_review > 0 and int(workbench_counts.get("candidate_count", -1)) <= actual_runtime_review:
        errors.append("runtime source review workbench candidate_count must exceed runtime review count")
    strategy_counts = workbench_counts.get("strategy_counts", {})
    if actual_runtime_review > 0 and strategy_counts != runtime_review_summary.get("strategy_counts", {}):
        errors.append("runtime source review workbench strategy_counts must match runtime source review queue")
    if runtime_review_workbench.get("missing"):
        errors.append(f"runtime source review workbench missing: {runtime_review_workbench['missing']}")

    family_coverage = report["asset_family_coverage"]
    if not family_coverage["present"]:
        errors.append("asset family coverage report is missing")
    if not family_coverage.get("markdown_exists"):
        errors.append("asset family coverage markdown is missing")
    family_summary = family_coverage.get("summary", {})
    if int(family_summary.get("family_count", -1)) != 10:
        errors.append("asset family coverage family_count expected 10")
    if int(family_summary.get("families_structurally_covered", -1)) != 10:
        errors.append("asset family coverage families_structurally_covered expected 10")
    if int(family_summary.get("format_count", -1)) != 7:
        errors.append("asset family coverage format_count expected 7")
    if int(family_summary.get("formats_structurally_covered", -1)) != 7:
        errors.append("asset family coverage formats_structurally_covered expected 7")
    if family_coverage.get("errors"):
        errors.append(f"asset family coverage errors: {family_coverage['errors']}")

    project_isolation = report["project_asset_isolation"]
    if not project_isolation["present"]:
        errors.append("project asset isolation report is missing")
    if not project_isolation.get("markdown_exists"):
        errors.append("project asset isolation markdown is missing")
    isolation_summary = project_isolation.get("summary", {})
    if int(isolation_summary.get("forbidden_project_marker_count", -1)) != 0:
        errors.append("project asset isolation forbidden_project_marker_count expected 0")
    if int(isolation_summary.get("outside_absolute_path_count", -1)) != 0:
        errors.append("project asset isolation outside_absolute_path_count expected 0")
    if int(isolation_summary.get("project_key_error_count", -1)) != 0:
        errors.append("project asset isolation project_key_error_count expected 0")
    if project_isolation.get("errors"):
        errors.append(f"project asset isolation errors: {project_isolation['errors']}")

    runtime_map = report["asset_runtime_map"]
    if not runtime_map["present"]:
        errors.append("asset runtime integration map is missing")
    runtime_summary = runtime_map.get("summary", {})
    if int(runtime_summary.get("entry_count", -1)) != expected_asset_count:
        errors.append(f"asset runtime map entry_count expected {expected_asset_count}")
    if int(runtime_summary.get("missing_output_count", -1)) != 0:
        errors.append("asset runtime map missing_output_count expected 0")
    if int(runtime_summary.get("missing_target_scene_candidate_count", -1)) != 0:
        errors.append("asset runtime map missing_target_scene_candidate_count expected 0")
    if runtime_map.get("errors"):
        errors.append(f"asset runtime map errors: {runtime_map['errors']}")

    runtime_catalog = report["runtime_asset_catalog"]
    if not runtime_catalog["present"] or not runtime_catalog["scene_exists"]:
        errors.append("imagegen runtime asset catalog scene or manifest is missing")
    catalog_counts = runtime_catalog.get("counts", {})
    if int(catalog_counts.get("resource_count", -1)) != expected_asset_count:
        errors.append(f"runtime asset catalog resource_count expected {expected_asset_count}")
    if int(catalog_counts.get("entry_count", -1)) != expected_asset_count:
        errors.append(f"runtime asset catalog entry_count expected {expected_asset_count}")
    if int(catalog_counts.get("missing_count", -1)) != 0:
        errors.append("runtime asset catalog missing_count expected 0")
    if runtime_catalog.get("missing"):
        errors.append(f"runtime asset catalog missing: {runtime_catalog['missing']}")

    integration_showcase = report["integration_showcase"]
    if not integration_showcase["present"] or not integration_showcase["scene_exists"]:
        errors.append("imagegen asset integration showcase scene or manifest is missing")
    showcase_counts = integration_showcase.get("counts", {})
    expected_showcase_counts = {
        "animated_sprite_nodes": 10,
        "tilemap_layer_nodes": 2,
        "stylebox_nodes": 4,
        "atlas_sprite_nodes": 8,
    }
    for key, expected in expected_showcase_counts.items():
        actual = int(showcase_counts.get(key, -1))
        if actual != expected:
            errors.append(f"integration_showcase {key} expected {expected} got {actual}")
    if integration_showcase.get("missing"):
        errors.append(f"integration_showcase missing: {integration_showcase['missing']}")
    return errors


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    atlas_manifest = load_json(resolve_path(root, args.atlas_manifest))

    report = {
        "version": 1,
        "status": "placeholder_ready",
        "boundary": (
            "Structural audit only. Passing this report proves files, counts and editor resource "
            "descriptors exist; it does not prove final art polish, semantic cleanup, runtime integration, "
            "license readiness or gameplay readability."
        ),
        "queue": audit_queue(root, queue),
        "atlas_manifest": audit_atlas_manifest(root, atlas_manifest),
        "editor_resources": {
            "atlas_textures": audit_editor_atlas_textures(root),
            "tilesets": audit_tilesets(root),
            "styleboxes": audit_styleboxes(root),
            "ui_skin": audit_ui_skin(root),
            "vfx_rules": audit_vfx_rules(root),
            "animation_rules": audit_animation_rules(root),
            "spine_exports": audit_spine_exports(root),
        },
        "runtime_ui_skin_binding": audit_runtime_ui_skin_binding(root),
        "gallery": audit_gallery(root),
        "art_readiness": audit_art_readiness(root),
        "background_alpha_policy": audit_background_alpha_policy(root),
        "final_art_review_queue": audit_final_art_review_queue(root),
        "final_art_review_workbench": audit_final_art_review_workbench(root),
        "final_art_acceptance_gates": audit_final_art_acceptance_gates(root),
        "p0_runtime_replacement_plan": audit_p0_runtime_replacement_plan(root),
        "p0_runtime_replacement_rehearsal": audit_p0_runtime_replacement_rehearsal(root),
        "p0_target_scene_replacement_matrix": audit_p0_target_scene_replacement_matrix(root),
        "p0_scene_replacement_batches": audit_p0_scene_replacement_batches(root),
        "asset_semantics": audit_asset_semantics(root),
        "standalone_semantics": audit_standalone_semantics(root),
        "candidate_pool": audit_candidate_pool(root),
        "candidate_review_gallery": audit_candidate_review_gallery(root),
        "asset_provenance": audit_asset_provenance(root),
        "imagegen_source_safety": audit_imagegen_source_safety(root),
        "runtime_source_safety": audit_runtime_source_safety(root),
        "runtime_source_review_queue": audit_runtime_source_review_queue(root),
        "runtime_source_review_decisions": audit_runtime_source_review_decisions(root),
        "asset_finalization_reviews": audit_asset_finalization_reviews(root),
        "runtime_source_regeneration_packet": audit_runtime_source_regeneration_packet(root),
        "runtime_source_regeneration_landing": audit_runtime_source_regeneration_landing(root),
        "runtime_source_review_workbench": audit_runtime_source_review_workbench(root),
        "asset_family_coverage": audit_asset_family_coverage(root),
        "project_asset_isolation": audit_project_asset_isolation(root),
        "asset_runtime_map": audit_asset_runtime_map(root),
        "runtime_asset_catalog": audit_runtime_asset_catalog(root),
        "integration_showcase": audit_integration_showcase(root),
        "file_counts": audit_file_counts(root),
    }
    errors = collect_errors(report)
    report["errors"] = errors
    report["ok"] = not errors

    if args.write_report:
        report_path = resolve_path(root, args.report)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {report_path.as_posix()}")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "Asset package audit OK: "
        f"{report['queue']['item_count']} queue items, "
        f"{report['atlas_manifest']['output_count']} atlas outputs, "
        f"{report['editor_resources']['atlas_textures']['resource_count']} AtlasTextures, "
        f"{report['editor_resources']['tilesets']['resource_count']} TileSets, "
        f"{report['editor_resources']['tilesets']['total_collision_ready']} collision-ready tiles, "
        f"{report['editor_resources']['styleboxes']['resource_count']} StyleBoxes, "
        f"{report['editor_resources']['ui_skin']['stylebox_mapping_count']} UI Theme mappings, "
        f"{report['runtime_ui_skin_binding']['panel_count']} runtime UI skin panels, "
        f"{report['runtime_ui_skin_binding']['texture_count']} runtime UI skin textures, "
        f"{report['editor_resources']['vfx_rules']['frame_rule_count']} VFX rules, "
        f"{report['editor_resources']['animation_rules']['frame_rule_count']} animation rules, "
        f"{report['editor_resources']['spine_exports']['part_count']} spine parts, "
        f"{report['art_readiness']['summary'].get('structural_ready_count', 0)} art-ready structures, "
        f"{report['background_alpha_policy']['summary'].get('record_count', 0)} background alpha policies, "
        f"{report['final_art_review_queue']['summary'].get('manual_review_required_count', 0)} final-art review entries, "
        f"{report['final_art_review_workbench']['counts'].get('texture_card_count', 0)} final-art workbench cards, "
        f"{report['final_art_acceptance_gates']['summary'].get('asset_count', 0)} final-art acceptance-gated assets, "
        f"{report['p0_runtime_replacement_plan']['summary'].get('asset_count', 0)} P0 runtime replacement-plan entries, "
        f"{report['p0_runtime_replacement_rehearsal']['counts'].get('entry_count', 0)} P0 runtime rehearsal nodes, "
        f"{report['p0_target_scene_replacement_matrix']['summary'].get('scene_count', 0)} P0 target scenes, "
        f"{report['p0_scene_replacement_batches']['summary'].get('batch_count', 0)} P0 scene replacement batches, "
        f"{report['asset_semantics']['entry_count'] + report['standalone_semantics']['entry_count']} semantic labels, "
        f"{report['candidate_pool']['summary'].get('unselected_candidate_count', 0)} unselected candidates, "
        f"{report['candidate_review_gallery']['counts'].get('unselected_candidates', 0)} candidate review cards, "
        f"{report['asset_provenance']['summary'].get('record_count', 0)} provenance records, "
        f"{report['imagegen_source_safety']['summary'].get('unsafe_candidate_count', 0)} unsafe source candidates, "
        f"{report['runtime_source_safety']['summary'].get('runtime_review_required_count', 0)} runtime source review-required assets, "
        f"{report['runtime_source_review_queue']['summary'].get('runtime_review_required_count', 0)} runtime source review queue entries, "
        f"{report['runtime_source_review_decisions']['summary'].get('confirmed_for_cleanup_count', 0)} runtime source cleanup decisions, "
        f"{report['asset_finalization_reviews']['summary'].get('approved_for_final_ready_count', 0)} asset finalization approvals, "
        f"{report['runtime_source_regeneration_packet']['summary'].get('asset_count', 0)} runtime source regeneration prompts, "
        f"{report['runtime_source_regeneration_landing']['summary'].get('landed_count', 0)}/"
        f"{report['runtime_source_regeneration_landing']['summary'].get('asset_count', 0)} runtime source regeneration landed, "
        f"{report['runtime_source_review_workbench']['counts'].get('candidate_count', 0)} runtime source workbench candidates, "
        f"{report['asset_family_coverage']['summary'].get('families_structurally_covered', 0)}/"
        f"{report['asset_family_coverage']['summary'].get('family_count', 0)} asset families covered, "
        f"{report['asset_family_coverage']['summary'].get('formats_structurally_covered', 0)}/"
        f"{report['asset_family_coverage']['summary'].get('format_count', 0)} Godot formats covered, "
        f"{report['project_asset_isolation']['summary'].get('forbidden_project_marker_count', 0)} forbidden project markers, "
        f"{report['project_asset_isolation']['summary'].get('outside_absolute_path_count', 0)} outside asset paths, "
        f"{report['asset_runtime_map']['summary'].get('entry_count', 0)} runtime map entries, "
        f"{report['runtime_asset_catalog']['counts'].get('resource_count', 0)} runtime catalog resources."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
