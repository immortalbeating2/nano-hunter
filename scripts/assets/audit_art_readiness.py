#!/usr/bin/env python3
"""Audit generated art assets for structural and polish-readiness gates."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_REPORT = "docs/assets/art-readiness-audit-report.json"
FINALIZATION_REVIEW_RECORDS = "docs/assets/asset-finalization-review-records.json"
BACKGROUND_ALPHA_POLICY_REPORT = "docs/assets/background-alpha-policy-report.json"
ALPHA_EXPECTED_KINDS = {
    "boss_direction",
    "character_direction",
    "completion_ui",
    "equipment_atlas",
    "hud_frame",
    "icon",
    "icon_sheet",
    "ninepatch_sheet",
    "prop",
    "prop_atlas",
    "prop_sheet",
    "spine_cutout_parts",
    "sprite_sheet",
    "ui_atlas",
    "ui_panel",
    "vfx_atlas",
    "vfx_direction",
    "vfx_sheet",
    "vfx_warning",
}
BACKGROUND_KINDS = {
    "cg_illustration",
    "environment_background",
    "environment_boss_room_background",
    "environment_room_background",
    "environment_tiles",
    "logo_direction",
    "promo_capsule",
    "promo_key_art",
    "storyboard_sheet",
    "style_board",
    "texture_atlas",
    "tileset_sheet",
    "title_background",
}
MANUAL_POLISH_NOTES = {
    "sprite_sheet": [
        "frame_order_review",
        "foot_baseline_and_anchor_cleanup",
        "animation_timing_review",
    ],
    "vfx_sheet": [
        "anchor_cleanup",
        "frame_order_review",
        "mask_and_blend_review",
    ],
    "vfx_atlas": [
        "anchor_cleanup",
        "mask_and_blend_review",
    ],
    "tileset_sheet": [
        "semantic_tile_naming",
        "collision_and_terrain_configuration",
        "hazard_safe_boundary_review",
    ],
    "environment_background": [
        "parallax_layer_split",
        "brightness_and_gameplay_readability_review",
    ],
    "environment_room_background": [
        "parallax_layer_split",
        "foreground_occlusion_review",
    ],
    "environment_boss_room_background": [
        "boss_readability_and_camera_scale_review",
    ],
    "ui_atlas": [
        "small_size_readability_review",
        "pseudo_text_cleanup",
        "theme_mapping",
    ],
    "icon_sheet": [
        "small_size_readability_review",
        "semantic_icon_naming",
    ],
    "ninepatch_sheet": [
        "final_ninepatch_margin_review",
        "stretch_distortion_review",
        "theme_mapping",
    ],
    "ui_panel": [
        "text_safe_area_review",
        "pseudo_text_cleanup",
        "runtime_layout_review",
    ],
    "ui_map_foundation": [
        "small_size_readability_review",
        "text_safe_area_review",
        "runtime_layout_review",
    ],
    "hud_frame": [
        "runtime_contrast_review",
        "mask_and_anchor_cleanup",
    ],
    "prop_atlas": [
        "state_variant_naming",
        "scale_readability_review",
    ],
    "equipment_atlas": [
        "semantic_item_naming",
        "small_size_readability_review",
    ],
    "spine_cutout_parts": [
        "semantic_part_naming",
        "pivot_and_layer_order_review",
        "rigging_cleanup",
    ],
    "logo_direction": [
        "manual_typography_cleanup",
        "vector_or_high_res_title_treatment",
    ],
    "promo_key_art": [
        "marketing_composition_review",
        "title_safe_area_review",
    ],
    "promo_capsule": [
        "platform_safe_area_review",
        "title_safe_area_review",
    ],
    "cg_illustration": [
        "narrative_consistency_review",
        "pseudo_text_cleanup",
    ],
    "storyboard_sheet": [
        "panel_crop_and_order_review",
        "script_matching_review",
    ],
    "texture_atlas": [
        "seam_and_tiling_review",
        "material_semantics_review",
    ],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit generated art outputs for structural readiness and manual polish blockers.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to the image-gen prompt queue.",
    )
    parser.add_argument(
        "--atlas-manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--report",
        default=DEFAULT_REPORT,
        help="Report JSON path to write when --write-report is used.",
    )
    parser.add_argument(
        "--write-report",
        action="store_true",
        help="Write the JSON report.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail when structural readiness errors are found.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def optional_json(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    return load_json(path)


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


def atlas_outputs_by_path(root: Path, atlas_manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    outputs: dict[str, dict[str, Any]] = {}
    for item in atlas_manifest.get("outputs", []):
        output_path = normalize_rel(resolve_path(root, item["output"]), root)
        metadata_path = normalize_rel(resolve_path(root, item["metadata"]), root)
        sprite_frames = item.get("sprite_frames")
        outputs[output_path] = {
            "asset_id": item["id"],
            "kind": item.get("kind", ""),
            "expected_target": int(item.get("expected_target", item.get("expected_min", 1))),
            "metadata": metadata_path,
            "semantics": normalize_rel(semantic_path_for(resolve_path(root, item["metadata"])), root),
            "sprite_frames": normalize_rel(resolve_path(root, sprite_frames), root) if sprite_frames else "",
        }
    return outputs


def semantic_path_for(metadata_path: Path) -> Path:
    suffix = metadata_path.suffix
    stem = metadata_path.name.removesuffix(suffix)
    if stem.endswith(".frames"):
        return metadata_path.with_name(stem.removesuffix(".frames") + ".semantics.json")
    if stem.endswith(".regions"):
        return metadata_path.with_name(stem.removesuffix(".regions") + ".semantics.json")
    return metadata_path.with_name(stem + ".semantics.json")


def metadata_region_count(path: Path) -> int | None:
    if not path.exists():
        return None
    data = load_json(path)
    if "frames" in data:
        return len(data["frames"])
    if "regions" in data:
        return len(data["regions"])
    return None


def semantic_region_count(path: Path) -> int | None:
    if not path.exists():
        return None
    data = load_json(path)
    return len(data.get("entries", []))


def apply_semantic_blocker_status(polish_blockers: list[str], has_semantics: bool) -> list[str]:
    semantic_blockers = {
        "semantic_tile_naming",
        "semantic_icon_naming",
        "semantic_item_naming",
        "semantic_part_naming",
    }
    result: list[str] = []
    replaced = False
    for blocker in polish_blockers:
        if blocker in semantic_blockers and has_semantics:
            replaced = True
            continue
        result.append(blocker)
    if replaced and "semantic_labels_manual_review" not in result:
        result.append("semantic_labels_manual_review")
    return result


def standalone_semantic_path_for(output_path: Path) -> Path:
    return output_path.with_name(output_path.stem + ".semantics.json")


def tileset_rules_path_for(root: Path, asset_id: str) -> Path:
    return root / "assets/art/tilesets/editor_tilesets" / f"{asset_id}.tileset_rules.json"


def tileset_rules_summary(root: Path, asset_id: str) -> dict[str, Any] | None:
    path = tileset_rules_path_for(root, asset_id)
    if not path.exists():
        return None
    data = load_json(path)
    counts = data.get("counts", {})
    solid = int(counts.get("solid", 0))
    one_way = int(counts.get("one_way_platform", 0))
    return {
        "path": normalize_rel(path, root),
        "tile_count": int(data.get("tile_count", 0)),
        "physics_layer_count": int(data.get("physics_layer_count", 0)),
        "terrain_set_count": int(data.get("terrain_set_count", 0)),
        "collision_ready_count": solid + one_way,
        "hazard_visual_only_count": int(counts.get("hazard_visual_only", 0)),
        "manual_review_required": bool(data.get("manual_review_required", False)),
    }


def apply_tileset_rule_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if int(summary.get("collision_ready_count", 0)) <= 0:
        return polish_blockers
    result: list[str] = []
    for blocker in polish_blockers:
        if blocker == "collision_and_terrain_configuration":
            if "collision_and_terrain_manual_review" not in result:
                result.append("collision_and_terrain_manual_review")
        elif blocker == "hazard_safe_boundary_review":
            if "hazard_safe_boundary_manual_review" not in result:
                result.append("hazard_safe_boundary_manual_review")
        else:
            result.append(blocker)
    return result


def ui_skin_rules_path_for(root: Path) -> Path:
    return root / "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json"


def ui_skin_summary(root: Path) -> dict[str, Any] | None:
    path = ui_skin_rules_path_for(root)
    if not path.exists():
        return None
    data = load_json(path)
    theme_resource = str(data.get("theme_resource", ""))
    theme_path = root / theme_resource.removeprefix("res://") if theme_resource.startswith("res://") else resolve_path(root, theme_resource)
    return {
        "path": normalize_rel(path, root),
        "theme_resource": theme_resource,
        "theme_exists": theme_path.exists(),
        "stylebox_mapping_count": len(data.get("stylebox_mappings", [])),
        "standalone_panel_rule_count": len(data.get("standalone_panels", [])),
        "manual_review_required": bool(data.get("manual_review_required", False)),
    }


def apply_ui_skin_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary or not bool(summary.get("theme_exists", False)):
        return polish_blockers
    if int(summary.get("stylebox_mapping_count", 0)) < 8:
        return polish_blockers
    if int(summary.get("standalone_panel_rule_count", 0)) < 4:
        return polish_blockers

    replacements = {
        "theme_mapping": "theme_mapping_manual_review",
        "text_safe_area_review": "text_safe_area_manual_review",
        "final_ninepatch_margin_review": "final_ninepatch_margin_manual_review",
        "stretch_distortion_review": "stretch_distortion_manual_review",
        "runtime_layout_review": "runtime_layout_manual_review",
    }
    result: list[str] = []
    for blocker in polish_blockers:
        replacement = replacements.get(blocker, blocker)
        if replacement not in result:
            result.append(replacement)
    return result


def vfx_rules_path_for(root: Path, asset_id: str) -> Path:
    return root / "assets/art/vfx/vfx_rules" / f"{asset_id}.vfx_rules.json"


def vfx_rules_summary(root: Path, asset_id: str) -> dict[str, Any] | None:
    path = vfx_rules_path_for(root, asset_id)
    if not path.exists():
        return None
    data = load_json(path)
    rules = data.get("rules", [])
    collision_disabled = sum(1 for rule in rules if bool(rule.get("gameplay_collision", True)) is False)
    damage_disabled = sum(1 for rule in rules if bool(rule.get("damage_source", True)) is False)
    return {
        "path": normalize_rel(path, root),
        "frame_count": int(data.get("frame_count", len(rules))),
        "rule_count": len(rules),
        "collision_disabled_count": collision_disabled,
        "damage_disabled_count": damage_disabled,
        "manual_review_required": bool(data.get("manual_review_required", False)),
    }


def apply_vfx_rule_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if int(summary.get("rule_count", 0)) <= 0:
        return polish_blockers
    if int(summary.get("collision_disabled_count", 0)) != int(summary.get("rule_count", -1)):
        return polish_blockers
    replacements = {
        "anchor_cleanup": "anchor_manual_review",
        "mask_and_blend_review": "mask_and_blend_manual_review",
    }
    result: list[str] = []
    for blocker in polish_blockers:
        replacement = replacements.get(blocker, blocker)
        if replacement not in result:
            result.append(replacement)
    return result


def animation_rules_path_for(root: Path, asset_id: str) -> Path:
    return root / "assets/art/characters/animation_rules" / f"{asset_id}.animation_rules.json"


def animation_rules_summary(root: Path, asset_id: str) -> dict[str, Any] | None:
    path = animation_rules_path_for(root, asset_id)
    if not path.exists():
        return None
    data = load_json(path)
    rules = data.get("rules", [])
    return {
        "path": normalize_rel(path, root),
        "animation_name": data.get("animation_name", ""),
        "speed_fps": data.get("speed_fps", 0),
        "loop": data.get("loop", False),
        "frame_count": int(data.get("frame_count", len(rules))),
        "rule_count": len(rules),
        "default_pivot_px": data.get("default_pivot_px", []),
        "default_foot_baseline_y": data.get("default_foot_baseline_y", 0),
        "manual_review_required": bool(data.get("manual_review_required", False)),
    }


def apply_animation_rule_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if int(summary.get("rule_count", 0)) <= 0:
        return polish_blockers
    replacements = {
        "frame_order_review": "frame_order_manual_review",
        "foot_baseline_and_anchor_cleanup": "foot_baseline_and_anchor_manual_review",
        "animation_timing_review": "animation_timing_manual_review",
    }
    result: list[str] = []
    for blocker in polish_blockers:
        replacement = replacements.get(blocker, blocker)
        if replacement not in result:
            result.append(replacement)
    return result


def asset_provenance_index(root: Path) -> dict[str, dict[str, Any]]:
    path = root / "docs/assets/asset-provenance-records.json"
    if not path.exists():
        return {}
    data = load_json(path)
    return {
        record["asset_id"]: record
        for record in data.get("records", [])
    }


def provenance_summary(record: dict[str, Any] | None) -> dict[str, Any] | None:
    if not record:
        return None
    return {
        "tool": record.get("tool", ""),
        "source_status": record.get("source_status", ""),
        "license_record_status": record.get("license_record_status", ""),
        "commercial_use_status": record.get("commercial_use_status", ""),
        "prompt_sha256": record.get("prompt_sha256", ""),
        "candidate_count": int(record.get("candidate_count", 0)),
        "output_sha256": record.get("output_sha256", ""),
    }


def apply_provenance_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if not summary.get("prompt_sha256") or not summary.get("output_sha256"):
        return polish_blockers
    if int(summary.get("candidate_count", 0)) <= 0:
        return polish_blockers
    result: list[str] = []
    for blocker in polish_blockers:
        if blocker == "license_record_pending":
            replacement = "license_terms_manual_review"
        else:
            replacement = blocker
        if replacement not in result:
            result.append(replacement)
    return result


def asset_runtime_map_index(root: Path) -> dict[str, dict[str, Any]]:
    path = root / "docs/assets/asset-runtime-integration-map.json"
    if not path.exists():
        return {}
    data = load_json(path)
    return {
        entry["asset_id"]: entry
        for entry in data.get("entries", [])
    }


def runtime_map_summary(entry: dict[str, Any] | None) -> dict[str, Any] | None:
    if not entry:
        return None
    return {
        "track": entry.get("track", ""),
        "target_system": entry.get("target_system", ""),
        "recommended_resource_type": entry.get("recommended_resource_type", ""),
        "integration_status": entry.get("integration_status", ""),
        "output_path": entry.get("output_path", ""),
        "existing_target_scene_candidates": entry.get("existing_target_scene_candidates", []),
    }


def apply_runtime_map_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if not str(summary.get("track", "")).startswith("runtime_"):
        runtime_blockers = {
            "runtime_reference_not_replaced",
            "runtime_binding_map_ready_manual_replacement",
            "runtime_catalog_ready_manual_replacement",
        }
        return [blocker for blocker in polish_blockers if blocker not in runtime_blockers]
    if summary.get("integration_status") != "binding_map_ready_manual_replacement_required":
        return polish_blockers
    if not summary.get("existing_target_scene_candidates"):
        return polish_blockers
    result: list[str] = []
    for blocker in polish_blockers:
        if blocker == "runtime_reference_not_replaced":
            replacement = "runtime_binding_map_ready_manual_replacement"
        else:
            replacement = blocker
        if replacement not in result:
            result.append(replacement)
    return result


def asset_runtime_catalog_index(root: Path) -> dict[str, dict[str, Any]]:
    path = root / "docs/assets/imagegen-runtime-asset-catalog-manifest.json"
    if not path.exists():
        return {}
    data = load_json(path)
    return {
        entry["asset_id"]: entry
        for entry in data.get("entries", [])
    }


def runtime_catalog_summary(entry: dict[str, Any] | None) -> dict[str, Any] | None:
    if not entry:
        return None
    return {
        "resource_path": entry.get("resource_path", ""),
        "catalog_resource_type": entry.get("catalog_resource_type", ""),
        "integration_status": entry.get("integration_status", ""),
    }


def scene_references_runtime_resource(root: Path, scene_path: str, resource_path: str, output_path: str) -> bool:
    path = resolve_path(root, scene_path)
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8", errors="ignore")
    tokens = {
        resource_path,
        output_path,
        "res://" + output_path.replace("\\", "/") if output_path else "",
    }
    return any(token and token in text for token in tokens)


def apply_runtime_catalog_blocker_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if summary.get("integration_status") != "runtime_catalog_ready_manual_replacement_required":
        return polish_blockers
    if not summary.get("resource_path") or not summary.get("catalog_resource_type"):
        return polish_blockers
    result: list[str] = []
    for blocker in polish_blockers:
        if blocker == "runtime_binding_map_ready_manual_replacement":
            replacement = "runtime_catalog_ready_manual_replacement"
        elif blocker == "runtime_reference_not_replaced":
            replacement = "runtime_catalog_ready_manual_replacement"
        else:
            replacement = blocker
        if replacement not in result:
            result.append(replacement)
    return result


def runtime_map_reference_summary(root: Path, runtime_map: dict[str, Any] | None, runtime_catalog: dict[str, Any] | None) -> dict[str, Any] | None:
    if not runtime_map or not runtime_catalog:
        return None
    resource_path = str(runtime_catalog.get("resource_path", ""))
    output_path = str(runtime_map.get("output_path", ""))
    target_scenes = [str(path) for path in runtime_map.get("existing_target_scene_candidates", [])]
    if not resource_path or not target_scenes:
        return None
    referenced_scenes = [
        scene
        for scene in target_scenes
        if scene_references_runtime_resource(root, scene, resource_path, output_path)
    ]
    return {
        "target_scene_count": len(target_scenes),
        "current_scene_reference_count": len(referenced_scenes),
        "referenced_scenes": referenced_scenes,
        "resource_path": resource_path,
    }


def apply_runtime_map_reference_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if int(summary.get("current_scene_reference_count", 0)) <= 0:
        return polish_blockers
    runtime_blockers = {
        "runtime_reference_not_replaced",
        "runtime_binding_map_ready_manual_replacement",
        "runtime_catalog_ready_manual_replacement",
    }
    return [blocker for blocker in polish_blockers if blocker not in runtime_blockers]


def asset_p0_runtime_replacement_plan_index(root: Path) -> dict[str, dict[str, Any]]:
    path = root / "docs/assets/p0-runtime-replacement-plan.json"
    if not path.exists():
        return {}
    data = load_json(path)
    return {
        entry["asset_id"]: entry
        for entry in data.get("entries", [])
    }


def runtime_replacement_plan_summary(entry: dict[str, Any] | None) -> dict[str, Any] | None:
    if not entry:
        return None
    return {
        "runtime_replacement_status": entry.get("runtime_replacement_status", ""),
        "current_scene_reference_count": int(entry.get("current_scene_reference_count", 0)),
        "target_scene_count": int(entry.get("target_scene_count", 0)),
        "resource_path": entry.get("resource_path", ""),
    }


def apply_runtime_replacement_plan_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary:
        return polish_blockers
    if summary.get("runtime_replacement_status") != "already_referenced":
        return polish_blockers
    if int(summary.get("current_scene_reference_count", 0)) <= 0:
        return polish_blockers
    runtime_blockers = {
        "runtime_reference_not_replaced",
        "runtime_binding_map_ready_manual_replacement",
        "runtime_catalog_ready_manual_replacement",
    }
    return [blocker for blocker in polish_blockers if blocker not in runtime_blockers]


def background_alpha_policy_index(root: Path) -> dict[str, dict[str, Any]]:
    report = optional_json(root / BACKGROUND_ALPHA_POLICY_REPORT)
    if not report:
        return {}
    return {
        str(record["asset_id"]): record
        for record in report.get("records", [])
        if record.get("asset_id")
    }


def background_alpha_policy_summary(record: dict[str, Any] | None) -> dict[str, Any] | None:
    if not record:
        return None
    return {
        "policy_status": record.get("policy_status", ""),
        "opaque_preview_path": record.get("opaque_preview_path", ""),
        "transparent_pixel_ratio": record.get("transparent_pixel_ratio", 0),
        "note": record.get("note", ""),
    }


def finalization_review_index(root: Path) -> dict[str, dict[str, Any]]:
    report = optional_json(root / FINALIZATION_REVIEW_RECORDS)
    if not report:
        return {}
    return {
        str(record["asset_id"]): record
        for record in report.get("records", [])
        if record.get("asset_id")
    }


def finalization_review_summary(record: dict[str, Any] | None) -> dict[str, Any] | None:
    if not record:
        return None
    return {
        "review_id": record.get("review_id", ""),
        "review_status": record.get("review_status", ""),
        "approved_blockers": record.get("approved_blockers", []),
        "final_approval_status": record.get("final_approval_status", ""),
        "final_ready_scope": record.get("final_ready_scope", ""),
        "evidence": record.get("evidence", []),
    }


def apply_finalization_review_status(polish_blockers: list[str], summary: dict[str, Any] | None) -> list[str]:
    if not summary or summary.get("review_status") != "approved_for_final_ready":
        return polish_blockers
    approved = set(str(blocker) for blocker in summary.get("approved_blockers", []))
    return [blocker for blocker in polish_blockers if blocker not in approved]


def image_metrics(path: Path) -> dict[str, Any]:
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        width, height = rgba.size
        total = width * height
        alpha_pixels = 0
        opaque_pixels = 0
        opaque_green_pixels = 0
        corner_alpha: list[int] = []
        corner_points = [
            (0, 0),
            (max(0, width - 1), 0),
            (0, max(0, height - 1)),
            (max(0, width - 1), max(0, height - 1)),
        ]
        for point in corner_points:
            corner_alpha.append(int(rgba.getpixel(point)[3]))
        pixels = rgba.load()
        for y in range(height):
            for x in range(width):
                red, green, blue, alpha = pixels[x, y]
                if alpha < 250:
                    alpha_pixels += 1
                if alpha >= 200:
                    opaque_pixels += 1
                    if red <= 40 and green >= 220 and blue <= 40:
                        opaque_green_pixels += 1
        return {
            "width": width,
            "height": height,
            "mode": image.mode,
            "has_alpha": rgba.mode == "RGBA" and alpha_pixels > 0,
            "transparent_pixel_ratio": round(alpha_pixels / total, 6) if total else 0,
            "opaque_pixel_ratio": round(opaque_pixels / total, 6) if total else 0,
            "opaque_green_pixel_ratio": round(opaque_green_pixels / total, 8) if total else 0,
            "corner_alpha": corner_alpha,
        }


def audit_item(
    root: Path,
    item: dict[str, Any],
    atlas_by_path: dict[str, dict[str, Any]],
    provenance_by_id: dict[str, dict[str, Any]],
    runtime_map_by_id: dict[str, dict[str, Any]],
    runtime_catalog_by_id: dict[str, dict[str, Any]],
    runtime_replacement_plan_by_id: dict[str, dict[str, Any]],
    background_alpha_policy_by_id: dict[str, dict[str, Any]],
    finalization_review_by_id: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    asset_id = item["asset_id"]
    target_kind = str(item.get("target_kind", "unknown"))
    output_path = resolve_path(root, item["output_path"])
    rel_output = normalize_rel(output_path, root)
    errors: list[str] = []
    warnings: list[str] = []
    polish_blockers = [
        "license_record_pending",
        "runtime_reference_not_replaced",
        *MANUAL_POLISH_NOTES.get(target_kind, []),
    ]
    provenance = provenance_summary(provenance_by_id.get(asset_id))
    polish_blockers = apply_provenance_blocker_status(polish_blockers, provenance)
    runtime_map = runtime_map_summary(runtime_map_by_id.get(asset_id))
    polish_blockers = apply_runtime_map_blocker_status(polish_blockers, runtime_map)
    runtime_catalog = runtime_catalog_summary(runtime_catalog_by_id.get(asset_id))
    polish_blockers = apply_runtime_catalog_blocker_status(polish_blockers, runtime_catalog)
    runtime_replacement_plan = runtime_replacement_plan_summary(runtime_replacement_plan_by_id.get(asset_id))
    polish_blockers = apply_runtime_replacement_plan_status(polish_blockers, runtime_replacement_plan)
    runtime_map_references = runtime_map_reference_summary(root, runtime_map, runtime_catalog)
    polish_blockers = apply_runtime_map_reference_status(polish_blockers, runtime_map_references)
    background_alpha_policy = background_alpha_policy_summary(background_alpha_policy_by_id.get(asset_id))
    finalization_review = finalization_review_summary(finalization_review_by_id.get(asset_id))

    if not output_path.exists():
        return {
            "asset_id": asset_id,
            "target_kind": target_kind,
            "output_path": rel_output,
            "status": "missing_output",
            "structural_ready": False,
            "final_ready": False,
            "errors": ["missing_output"],
            "warnings": warnings,
            "polish_blockers": polish_blockers,
            "provenance": provenance,
            "runtime_map": runtime_map,
            "runtime_catalog": runtime_catalog,
            "runtime_replacement_plan": runtime_replacement_plan,
            "runtime_map_references": runtime_map_references,
            "background_alpha_policy": background_alpha_policy,
            "finalization_review": finalization_review,
        }

    try:
        metrics = image_metrics(output_path)
    except Exception as exc:  # noqa: BLE001 - report unreadable asset as audit data.
        return {
            "asset_id": asset_id,
            "target_kind": target_kind,
            "output_path": rel_output,
            "status": "unreadable_image",
            "structural_ready": False,
            "final_ready": False,
            "errors": [f"unreadable_image: {exc}"],
            "warnings": warnings,
            "polish_blockers": polish_blockers,
            "provenance": provenance,
            "runtime_map": runtime_map,
            "runtime_catalog": runtime_catalog,
            "runtime_replacement_plan": runtime_replacement_plan,
            "runtime_map_references": runtime_map_references,
            "background_alpha_policy": background_alpha_policy,
            "finalization_review": finalization_review,
        }

    if int(metrics["width"]) <= 0 or int(metrics["height"]) <= 0:
        errors.append("invalid_dimensions")
    if float(metrics["opaque_green_pixel_ratio"]) > 0.0005:
        errors.append("opaque_chroma_key_residue")
    tileset_rules = tileset_rules_summary(root, asset_id) if target_kind == "tileset_sheet" else None
    if target_kind == "tileset_sheet":
        polish_blockers = apply_tileset_rule_blocker_status(polish_blockers, tileset_rules)
        if tileset_rules is None:
            warnings.append("missing_tileset_rules")
        elif int(tileset_rules.get("tile_count", 0)) <= 0:
            warnings.append("empty_tileset_rules")
    ui_skin = ui_skin_summary(root) if target_kind in {"ninepatch_sheet", "ui_atlas", "ui_panel", "hud_frame", "completion_ui"} else None
    if ui_skin:
        polish_blockers = apply_ui_skin_blocker_status(polish_blockers, ui_skin)
    elif target_kind in {"ninepatch_sheet", "ui_atlas", "ui_panel", "hud_frame", "completion_ui"}:
        warnings.append("missing_ui_skin_rules")
    vfx_rules = vfx_rules_summary(root, asset_id) if target_kind in {"vfx_atlas", "vfx_sheet", "vfx_direction", "vfx_warning"} else None
    if vfx_rules:
        polish_blockers = apply_vfx_rule_blocker_status(polish_blockers, vfx_rules)
    elif target_kind in {"vfx_atlas", "vfx_sheet", "vfx_direction", "vfx_warning"}:
        warnings.append("missing_vfx_rules")
    animation_rules = animation_rules_summary(root, asset_id) if target_kind == "sprite_sheet" and "/characters/" in rel_output else None
    if animation_rules:
        polish_blockers = apply_animation_rule_blocker_status(polish_blockers, animation_rules)
    elif target_kind == "sprite_sheet" and "/characters/" in rel_output:
        warnings.append("missing_animation_rules")

    if target_kind in ALPHA_EXPECTED_KINDS and not bool(metrics["has_alpha"]):
        warnings.append("alpha_expected_but_not_detected")
    if target_kind in BACKGROUND_KINDS and bool(metrics["has_alpha"]):
        policy_status = str((background_alpha_policy or {}).get("policy_status", ""))
        if policy_status == "alpha_allowed_for_tile_or_atlas_padding":
            polish_blockers.append("alpha_padding_policy_manual_review")
        elif policy_status == "opaque_preview_ready_manual_review":
            polish_blockers.append("opaque_preview_manual_review")
        else:
            warnings.append("background_asset_contains_alpha")

    atlas_info = atlas_by_path.get(rel_output, {})
    if atlas_info:
        metadata_path = resolve_path(root, atlas_info["metadata"])
        metadata_count = metadata_region_count(metadata_path)
        expected_target = int(atlas_info["expected_target"])
        if metadata_count != expected_target:
            errors.append("metadata_count_mismatch")
        semantic_path = resolve_path(root, atlas_info["semantics"])
        semantic_count = semantic_region_count(semantic_path)
        if semantic_count == expected_target:
            polish_blockers = apply_semantic_blocker_status(polish_blockers, True)
        elif semantic_count is None:
            polish_blockers = apply_semantic_blocker_status(polish_blockers, False)
            warnings.append("missing_semantic_metadata")
        else:
            polish_blockers = apply_semantic_blocker_status(polish_blockers, False)
            warnings.append("semantic_metadata_count_mismatch")
        sprite_frames = str(atlas_info.get("sprite_frames", ""))
        if sprite_frames and not resolve_path(root, sprite_frames).exists():
            errors.append("missing_spriteframes")
    else:
        metadata_count = None
        expected_target = None
        semantic_path = standalone_semantic_path_for(output_path)
        semantic_count = semantic_region_count(semantic_path)
        if semantic_count is not None:
            polish_blockers = apply_semantic_blocker_status(polish_blockers, True)

    polish_blockers = apply_finalization_review_status(polish_blockers, finalization_review)
    structural_ready = not errors
    final_ready = (
        structural_ready
        and not polish_blockers
        and bool(finalization_review)
        and finalization_review.get("final_approval_status") == "approved"
    )
    return {
        "asset_id": asset_id,
        "target_kind": target_kind,
        "output_path": rel_output,
        "status": "structural_ready" if structural_ready else "structural_error",
        "structural_ready": structural_ready,
        "final_ready": final_ready,
        "metrics": metrics,
        "atlas_expected_target": expected_target,
        "metadata_region_count": metadata_count,
        "semantic_region_count": semantic_count,
        "tileset_rules": tileset_rules,
        "ui_skin_rules": ui_skin,
        "vfx_rules": vfx_rules,
        "animation_rules": animation_rules,
        "provenance": provenance,
        "runtime_map": runtime_map,
        "runtime_catalog": runtime_catalog,
        "runtime_replacement_plan": runtime_replacement_plan,
        "runtime_map_references": runtime_map_references,
        "background_alpha_policy": background_alpha_policy,
        "finalization_review": finalization_review,
        "errors": errors,
        "warnings": warnings,
        "polish_blockers": polish_blockers,
    }


def summarize(items: list[dict[str, Any]]) -> dict[str, Any]:
    kind_counts: dict[str, int] = {}
    structural_ready_count = 0
    final_ready_count = 0
    warnings_by_type: dict[str, int] = {}
    blockers_by_type: dict[str, int] = {}
    error_items: list[str] = []
    warning_items: list[str] = []
    for item in items:
        kind = str(item["target_kind"])
        kind_counts[kind] = kind_counts.get(kind, 0) + 1
        if item.get("structural_ready"):
            structural_ready_count += 1
        if item.get("final_ready"):
            final_ready_count += 1
        if item.get("errors"):
            error_items.append(str(item["asset_id"]))
        if item.get("warnings"):
            warning_items.append(str(item["asset_id"]))
        for warning in item.get("warnings", []):
            warnings_by_type[warning] = warnings_by_type.get(warning, 0) + 1
        for blocker in item.get("polish_blockers", []):
            blockers_by_type[blocker] = blockers_by_type.get(blocker, 0) + 1
    return {
        "item_count": len(items),
        "structural_ready_count": structural_ready_count,
        "final_ready_count": final_ready_count,
        "kind_counts": dict(sorted(kind_counts.items())),
        "warnings_by_type": dict(sorted(warnings_by_type.items())),
        "blockers_by_type": dict(sorted(blockers_by_type.items())),
        "error_items": error_items,
        "warning_items": warning_items,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    atlas_manifest = load_json(resolve_path(root, args.atlas_manifest))
    atlas_by_path = atlas_outputs_by_path(root, atlas_manifest)
    provenance_by_id = asset_provenance_index(root)
    runtime_map_by_id = asset_runtime_map_index(root)
    runtime_catalog_by_id = asset_runtime_catalog_index(root)
    runtime_replacement_plan_by_id = asset_p0_runtime_replacement_plan_index(root)
    background_alpha_policy_by_id = background_alpha_policy_index(root)
    finalization_review_by_id = finalization_review_index(root)

    items = [
        audit_item(
            root,
            item,
            atlas_by_path,
            provenance_by_id,
            runtime_map_by_id,
            runtime_catalog_by_id,
            runtime_replacement_plan_by_id,
            background_alpha_policy_by_id,
            finalization_review_by_id,
        )
        for item in queue["items"]
    ]
    summary = summarize(items)
    errors = [f"{item['asset_id']}: {error}" for item in items for error in item.get("errors", [])]
    report = {
        "version": 1,
        "status": "placeholder_ready",
        "boundary": (
            "Art readiness audit. structural_ready means generated PNGs and metadata are usable by the "
            "pipeline. final_ready remains false until license records, manual cleanup, semantic naming, "
            "runtime replacement, and gameplay readability checks are completed."
        ),
        "summary": summary,
        "items": items,
        "errors": errors,
        "ok": not errors,
    }

    if args.write_report:
        report_path = resolve_path(root, args.report)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {report_path.as_posix()}")

    print(
        "Art readiness audit "
        f"{'OK' if report['ok'] else 'FAILED'}: "
        f"{summary['structural_ready_count']}/{summary['item_count']} structural ready, "
        f"{summary['final_ready_count']}/{summary['item_count']} final ready."
    )
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
