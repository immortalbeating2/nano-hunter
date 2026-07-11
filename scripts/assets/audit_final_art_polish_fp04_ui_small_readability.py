#!/usr/bin/env python3
"""Audit FP-04 UI, NinePatch, HUD, and small-icon readiness."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_JSON_REPORT = "docs/assets/final-art-polish-fp04-ui-small-readability-report.json"
DEFAULT_MD_REPORT = "docs/assets/final-art-polish-fp04-ui-small-readability-report.md"

STYLEBOX_INDEX = "assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
UI_RULES = "assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json"

RUNTIME_SCENES = [
    {
        "scene": "scenes/ui/demo_shell.tscn",
        "required_paths": [
            "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres",
            "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres",
            "res://assets/art/ui/stage16_title_background_ai01.png",
            "res://assets/art/ui/stage16_demo_menu_icons_ai01.png",
            "res://assets/art/ui/stage16_pause_panel_ui_ai01.png",
            "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
        ],
    },
    {
        "scene": "scenes/ui/tutorial_hud.tscn",
        "required_paths": [
            "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres",
            "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres",
            "res://assets/art/ui/stage14_air_dash_icon_ai01.png",
            "res://assets/art/ui/stage15_recovery_charge_icon_ai01.png",
            "res://assets/art/ui/stage14_ability_status_hud_ai01.png",
            "res://assets/art/ui/stage15_boss_hud_frame_ai01.png",
        ],
    },
]

SMALL_ICON_TARGETS = [
    "assets/art/ui/stage14_air_dash_icon_ai01.png",
    "assets/art/ui/stage15_recovery_charge_icon_ai01.png",
]

ATLAS_REGION_TARGETS = [
    {
        "asset_id": "stage16_demo_menu_icons_ai01",
        "path": "assets/art/ui/stage16_demo_menu_icons_ai01.png",
        "regions": "assets/art/ui/stage16_demo_menu_icons_ai01.regions.json",
        "expected_regions": 6,
        "expected_cell": [512, 512],
    },
    {
        "asset_id": "icon_sheet_core_ai01",
        "path": "assets/art/ui/atlases/icon_sheet_core_ai01.png",
        "regions": "assets/art/ui/atlases/icon_sheet_core_ai01.regions.json",
        "expected_regions": 16,
        "expected_cell": [64, 64],
    },
    {
        "asset_id": "hud_core_ui_atlas_ai01",
        "path": "assets/art/ui/atlases/hud_core_ui_atlas_ai01.png",
        "regions": "assets/art/ui/atlases/hud_core_ui_atlas_ai01.regions.json",
        "expected_regions": 16,
        "expected_cell": [96, 96],
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit FP-04 UI small-size readiness.")
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--json-report", default=DEFAULT_JSON_REPORT)
    parser.add_argument("--md-report", default=DEFAULT_MD_REPORT)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def image_info(path: Path) -> dict[str, Any]:
    with Image.open(path) as image:
        return {
            "size": [image.size[0], image.size[1]],
            "mode": image.mode,
            "has_alpha": image.mode in {"RGBA", "LA"} or "transparency" in image.info,
        }


def res_to_project_path(resource_path: str) -> str:
    return resource_path.removeprefix("res://")


def rect_inside(rect: list[Any], size: list[int]) -> bool:
    if len(rect) != 4:
        return False
    x, y, width, height = [float(value) for value in rect]
    return x >= 0 and y >= 0 and width > 0 and height > 0 and x + width <= size[0] and y + height <= size[1]


def audit_styleboxes(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    warnings: list[str] = []
    index_path = root / STYLEBOX_INDEX
    index = load_json(index_path) if index_path.exists() else {}
    items = index.get("items", [])
    source_textures = sorted({str(item.get("texture", "")) for item in items})

    for item in items:
        texture_path = root / res_to_project_path(str(item.get("texture", "")))
        resource_path = root / res_to_project_path(str(item.get("resource", "")))
        if not texture_path.exists():
            errors.append(f"{item.get('name')}:texture_missing")
            continue
        if not resource_path.exists():
            errors.append(f"{item.get('name')}:resource_missing")
        info = image_info(texture_path)
        region = item.get("region", [])
        if not rect_inside(region, info["size"]):
            errors.append(f"{item.get('name')}:region_outside_texture")
        margin = int(item.get("margin", 0))
        if margin <= 0:
            errors.append(f"{item.get('name')}:margin_not_positive")
        if len(region) == 4 and (margin * 2 >= int(region[2]) or margin * 2 >= int(region[3])):
            warnings.append(f"{item.get('name')}:margin_large_for_region")

    return {
        "status": "ready" if not errors else "blocked",
        "index": STYLEBOX_INDEX,
        "count": len(items),
        "source_textures": source_textures,
        "errors": errors,
        "warnings": warnings,
    }


def audit_ui_rules(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    warnings: list[str] = []
    rules_path = root / UI_RULES
    rules = load_json(rules_path) if rules_path.exists() else {}
    mappings = rules.get("stylebox_mappings", [])
    panels = rules.get("standalone_panels", [])

    if len(mappings) != 9:
        errors.append("stylebox_mapping_count_mismatch")
    if len(panels) != 4:
        errors.append("standalone_panel_count_mismatch")

    panel_reports = []
    for panel in panels:
        texture_path = root / res_to_project_path(str(panel.get("texture", "")))
        panel_errors: list[str] = []
        info = image_info(texture_path) if texture_path.exists() else {"size": [0, 0], "mode": "", "has_alpha": False}
        if not texture_path.exists():
            panel_errors.append("texture_missing")
        if panel.get("size") != info["size"]:
            panel_errors.append("size_mismatch")
        if not info["has_alpha"]:
            warnings.append(f"{panel.get('id')}:texture_has_no_alpha")
        if not rect_inside(panel.get("text_safe_rect", []), info["size"]):
            panel_errors.append("text_safe_rect_invalid")
        min_size = panel.get("min_runtime_size", [])
        if len(min_size) != 2 or int(min_size[0]) < 64 or int(min_size[1]) < 64:
            panel_errors.append("min_runtime_size_too_small")
        notes = set(str(note) for note in panel.get("notes", []))
        if "pseudo_text_cleanup_required_before_runtime_use" not in notes:
            warnings.append(f"{panel.get('id')}:pseudo_text_cleanup_note_missing")
        if not panel.get("manual_review_required", False):
            warnings.append(f"{panel.get('id')}:manual_review_not_marked")
        errors.extend(f"{panel.get('id')}:{error}" for error in panel_errors)
        panel_reports.append({
            "id": panel.get("id", ""),
            "status": "ready_with_manual_review" if not panel_errors else "blocked",
            "texture": panel.get("texture", ""),
            "size": info["size"],
            "mode": info["mode"],
            "has_alpha": info["has_alpha"],
            "text_safe_rect": panel.get("text_safe_rect", []),
            "min_runtime_size": min_size,
            "layout_role": panel.get("layout_role", ""),
            "errors": panel_errors,
        })

    return {
        "status": "ready_with_manual_review" if not errors else "blocked",
        "rules": UI_RULES,
        "stylebox_mapping_count": len(mappings),
        "standalone_panel_count": len(panels),
        "panels": panel_reports,
        "errors": errors,
        "warnings": warnings,
    }


def audit_runtime_scenes(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    scene_reports = []
    for spec in RUNTIME_SCENES:
        scene_path = root / spec["scene"]
        text = scene_path.read_text(encoding="utf-8") if scene_path.exists() else ""
        missing = [path for path in spec["required_paths"] if path not in text]
        if not scene_path.exists():
            errors.append(f"{spec['scene']}:scene_missing")
        errors.extend(f"{spec['scene']}:{path}:reference_missing" for path in missing)
        scene_reports.append({
            "scene": spec["scene"],
            "status": "references_ready" if not missing and scene_path.exists() else "blocked",
            "required_reference_count": len(spec["required_paths"]),
            "missing_references": missing,
        })
    return {
        "status": "ready" if not errors else "blocked",
        "scenes": scene_reports,
        "errors": errors,
        "warnings": [],
    }


def audit_small_icons(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    icons = []
    for target in SMALL_ICON_TARGETS:
        path = root / target
        icon_errors: list[str] = []
        if not path.exists():
            icon_errors.append("texture_missing")
            info = {"size": [0, 0], "mode": "", "has_alpha": False}
        else:
            info = image_info(path)
            if min(info["size"]) < 64:
                icon_errors.append("source_smaller_than_64px")
            if not info["has_alpha"]:
                icon_errors.append("alpha_missing")
        errors.extend(f"{target}:{error}" for error in icon_errors)
        icons.append({
            "path": target,
            "status": "small_size_source_ready" if not icon_errors else "blocked",
            **info,
            "errors": icon_errors,
        })
    return {
        "status": "ready" if not errors else "blocked",
        "icons": icons,
        "errors": errors,
        "warnings": [],
    }


def audit_atlas_regions(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    atlases = []
    for target in ATLAS_REGION_TARGETS:
        path = root / target["path"]
        regions_path = root / target["regions"]
        atlas_errors: list[str] = []
        info = image_info(path) if path.exists() else {"size": [0, 0], "mode": "", "has_alpha": False}
        regions = load_json(regions_path) if regions_path.exists() else {}
        frames = regions.get("regions", regions.get("frames", []))
        expected_cell = target["expected_cell"]
        if not path.exists():
            atlas_errors.append("texture_missing")
        if not regions_path.exists():
            atlas_errors.append("regions_missing")
        if len(frames) != target["expected_regions"]:
            atlas_errors.append("region_count_mismatch")
        for frame in frames:
            rect = frame.get("rect", frame.get("region", []))
            if len(rect) != 4 or [int(rect[2]), int(rect[3])] != expected_cell:
                atlas_errors.append(f"{frame.get('name', frame.get('index'))}:cell_size_mismatch")
            if not rect_inside(rect, info["size"]):
                atlas_errors.append(f"{frame.get('name', frame.get('index'))}:region_outside_texture")
        errors.extend(f"{target['asset_id']}:{error}" for error in atlas_errors)
        atlases.append({
            "asset_id": target["asset_id"],
            "status": "regions_ready" if not atlas_errors else "blocked",
            "path": target["path"],
            "size": info["size"],
            "mode": info["mode"],
            "has_alpha": info["has_alpha"],
            "region_count": len(frames),
            "expected_cell": expected_cell,
            "errors": atlas_errors,
        })
    return {
        "status": "ready" if not errors else "blocked",
        "atlases": atlases,
        "errors": errors,
        "warnings": [],
    }


def build_report(root: Path) -> dict[str, Any]:
    sections = {
        "styleboxes": audit_styleboxes(root),
        "ui_rules": audit_ui_rules(root),
        "runtime_scenes": audit_runtime_scenes(root),
        "small_icons": audit_small_icons(root),
        "atlas_regions": audit_atlas_regions(root),
    }
    errors = [
        f"{section}:{error}"
        for section, data in sections.items()
        for error in data.get("errors", [])
    ]
    warnings = [
        f"{section}:{warning}"
        for section, data in sections.items()
        for warning in data.get("warnings", [])
    ]
    return {
        "version": 1,
        "status": "ok" if not errors else "blocked",
        "boundary": (
            "FP-04 UI / NinePatch / HUD small-size audit. Passing means current resources, "
            "runtime references, regions, alpha, and text-safe rule metadata are coherent; "
            "it does not approve final typography cleanup or human visual polish."
        ),
        "summary": {
            "section_count": len(sections),
            "error_count": len(errors),
            "warning_count": len(warnings),
        },
        **sections,
        "errors": errors,
        "warnings": warnings,
    }


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    lines = [
        "# Final Art Polish FP-04 UI Small Readability Report",
        "",
        f"- Status: `{report['status']}`",
        f"- Errors: `{report['summary']['error_count']}`",
        f"- Warnings: `{report['summary']['warning_count']}`",
        "",
        "## Sections",
        "",
        f"- StyleBoxes: `{report['styleboxes']['status']}` / `{report['styleboxes']['count']}` resources",
        f"- UI rules: `{report['ui_rules']['status']}` / `{report['ui_rules']['stylebox_mapping_count']}` mappings / `{report['ui_rules']['standalone_panel_count']}` standalone panels",
        f"- Runtime scenes: `{report['runtime_scenes']['status']}`",
        f"- Small icons: `{report['small_icons']['status']}` / `{len(report['small_icons']['icons'])}` icons",
        f"- Atlas regions: `{report['atlas_regions']['status']}` / `{len(report['atlas_regions']['atlases'])}` atlases",
        "",
        "## Runtime Scenes",
        "",
    ]
    for scene in report["runtime_scenes"]["scenes"]:
        lines.extend([
            f"- `{scene['scene']}`: `{scene['status']}`, required refs `{scene['required_reference_count']}`",
        ])
    lines.extend(["", "## Standalone Panels", ""])
    for panel in report["ui_rules"]["panels"]:
        lines.extend([
            f"- `{panel['id']}`: `{panel['status']}`, size `{panel['size']}`, min runtime `{panel['min_runtime_size']}`, alpha `{panel['has_alpha']}`",
        ])
    lines.extend(["", "## Atlas Regions", ""])
    for atlas in report["atlas_regions"]["atlases"]:
        lines.extend([
            f"- `{atlas['asset_id']}`: `{atlas['status']}`, regions `{atlas['region_count']}`, cell `{atlas['expected_cell']}`, alpha `{atlas['has_alpha']}`",
        ])
    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(root)

    if args.write_report:
        json_path = root / args.json_report
        md_path = root / args.md_report
        json_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_markdown(md_path, report)
        print(f"wrote {json_path}")
        print(f"wrote {md_path}")

    print(
        "FP-04 UI small readability audit: "
        f"{report['summary']['error_count']} errors, "
        f"{report['summary']['warning_count']} warnings."
    )
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
