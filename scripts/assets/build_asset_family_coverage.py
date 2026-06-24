#!/usr/bin/env python3
"""生成完整美术资产族与 Godot 可用格式覆盖报告。"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any


DEFAULT_QUEUE = "docs/assets/image-gen-prompt-queue.json"
DEFAULT_READINESS = "docs/assets/art-readiness-audit-report.json"
DEFAULT_PACKAGE = "docs/assets/asset-package-audit-report.json"
DEFAULT_JSON_OUT = "docs/assets/asset-family-coverage-report.json"
DEFAULT_MARKDOWN_OUT = "docs/assets/asset-family-coverage-report.md"

FAMILY_REQUIREMENTS = {
    "characters": {
        "label": "角色类",
        "target_kinds": {"character_direction", "boss_direction", "sprite_sheet", "spine_cutout_parts"},
        "minimum_assets": 6,
    },
    "level_environment": {
        "label": "关卡地图 / 场景类",
        "target_kinds": {
            "environment_background",
            "environment_boss_room_background",
            "environment_room_background",
            "environment_tiles",
            "tileset_sheet",
        },
        "minimum_assets": 6,
    },
    "ui_interface": {
        "label": "UI / 界面类",
        "target_kinds": {"completion_ui", "hud_frame", "ninepatch_sheet", "title_background", "ui_atlas", "ui_panel"},
        "minimum_assets": 6,
    },
    "icons": {
        "label": "图标类",
        "target_kinds": {"icon", "icon_sheet"},
        "minimum_assets": 3,
    },
    "props_equipment": {
        "label": "道具与装备类",
        "target_kinds": {"prop", "prop_atlas", "prop_sheet", "equipment_atlas"},
        "minimum_assets": 4,
    },
    "vfx": {
        "label": "特效类",
        "target_kinds": {"vfx_atlas", "vfx_direction", "vfx_sheet", "vfx_warning"},
        "minimum_assets": 5,
    },
    "animation_frames": {
        "label": "动画帧图 / 序列帧",
        "target_kinds": {"sprite_sheet"},
        "minimum_assets": 6,
    },
    "textures": {
        "label": "贴图类",
        "target_kinds": {"texture_atlas", "environment_tiles", "tileset_sheet"},
        "minimum_assets": 3,
    },
    "promo_logo_cg": {
        "label": "宣传 / 运营 / LOGO / CG",
        "target_kinds": {"logo_direction", "promo_capsule", "promo_key_art", "cg_illustration", "style_board"},
        "minimum_assets": 5,
    },
    "story_narrative": {
        "label": "叙事 / 剧情 / 分镜",
        "target_kinds": {"storyboard_sheet", "cg_illustration"},
        "minimum_assets": 3,
    },
}

FORMAT_REQUIREMENTS = {
    "sprite_sheet": {
        "label": "Sprite Sheet",
        "target_kinds": {"sprite_sheet"},
        "package_path": ("editor_resources", "animation_rules", "frame_rule_count"),
        "minimum_assets": 6,
    },
    "texture_atlas": {
        "label": "Texture Atlas",
        "target_kinds": {"texture_atlas", "prop_atlas", "equipment_atlas", "promo_key_art", "storyboard_sheet", "cg_illustration"},
        "package_path": ("editor_resources", "atlas_textures", "resource_count"),
        "minimum_assets": 6,
    },
    "tile_set": {
        "label": "Tile Set",
        "target_kinds": {"tileset_sheet", "environment_tiles"},
        "package_path": ("editor_resources", "tilesets", "resource_count"),
        "minimum_assets": 2,
    },
    "spine_cutout": {
        "label": "Spine 拆件图集",
        "target_kinds": {"spine_cutout_parts"},
        "package_path": ("editor_resources", "spine_exports", "part_count"),
        "minimum_assets": 2,
    },
    "ui_atlas": {
        "label": "UI 图集",
        "target_kinds": {"ui_atlas", "icon_sheet", "hud_frame", "ui_panel"},
        "package_path": ("editor_resources", "ui_skin", "stylebox_mapping_count"),
        "minimum_assets": 5,
    },
    "vfx_atlas": {
        "label": "特效图集",
        "target_kinds": {"vfx_atlas", "vfx_sheet", "vfx_warning", "vfx_direction"},
        "package_path": ("editor_resources", "vfx_rules", "frame_rule_count"),
        "minimum_assets": 5,
    },
    "ninepatch": {
        "label": "九宫格图片 / StyleBox",
        "target_kinds": {"ninepatch_sheet", "ui_panel", "hud_frame"},
        "package_path": ("editor_resources", "styleboxes", "resource_count"),
        "minimum_assets": 3,
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build asset family coverage report.")
    parser.add_argument("--queue", default=DEFAULT_QUEUE)
    parser.add_argument("--readiness", default=DEFAULT_READINESS)
    parser.add_argument("--package", default=DEFAULT_PACKAGE)
    parser.add_argument("--json-out", default=DEFAULT_JSON_OUT)
    parser.add_argument("--markdown-out", default=DEFAULT_MARKDOWN_OUT)
    return parser.parse_args()


def resolve_path(root: Path, value: str | Path) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def nested_value(data: dict[str, Any], path: tuple[str, ...]) -> int:
    current: Any = data
    for key in path:
        if not isinstance(current, dict):
            return 0
        current = current.get(key, {})
    return int(current) if isinstance(current, int) else 0


def readiness_by_kind(readiness: dict[str, Any]) -> dict[str, dict[str, int]]:
    result: dict[str, dict[str, int]] = {}
    for item in readiness.get("items", []):
        kind = str(item.get("target_kind", "unknown"))
        if kind not in result:
            result[kind] = {"structural_ready": 0, "final_ready": 0}
        if item.get("structural_ready"):
            result[kind]["structural_ready"] += 1
        if item.get("final_ready"):
            result[kind]["final_ready"] += 1
    return result


def build_family_entries(queue_items: list[dict[str, Any]], readiness: dict[str, Any]) -> list[dict[str, Any]]:
    kind_counts = Counter(str(item.get("target_kind", "unknown")) for item in queue_items)
    ready_by_kind = readiness_by_kind(readiness)
    entries: list[dict[str, Any]] = []
    for key, requirement in FAMILY_REQUIREMENTS.items():
        kinds = set(requirement["target_kinds"])
        asset_count = sum(kind_counts.get(kind, 0) for kind in kinds)
        structural_ready_count = sum(ready_by_kind.get(kind, {}).get("structural_ready", 0) for kind in kinds)
        final_ready_count = sum(ready_by_kind.get(kind, {}).get("final_ready", 0) for kind in kinds)
        minimum = int(requirement["minimum_assets"])
        entries.append(
            {
                "family": key,
                "label": requirement["label"],
                "target_kinds": sorted(kinds),
                "asset_count": asset_count,
                "minimum_assets": minimum,
                "structural_ready_count": structural_ready_count,
                "final_ready_count": final_ready_count,
                "coverage_status": "covered_structural" if asset_count >= minimum and structural_ready_count >= minimum else "under_target",
                "final_status": "final_ready" if final_ready_count >= minimum else "final_blocked",
            }
        )
    return entries


def build_format_entries(queue_items: list[dict[str, Any]], readiness: dict[str, Any], package: dict[str, Any]) -> list[dict[str, Any]]:
    kind_counts = Counter(str(item.get("target_kind", "unknown")) for item in queue_items)
    ready_by_kind = readiness_by_kind(readiness)
    entries: list[dict[str, Any]] = []
    for key, requirement in FORMAT_REQUIREMENTS.items():
        kinds = set(requirement["target_kinds"])
        asset_count = sum(kind_counts.get(kind, 0) for kind in kinds)
        structural_ready_count = sum(ready_by_kind.get(kind, {}).get("structural_ready", 0) for kind in kinds)
        final_ready_count = sum(ready_by_kind.get(kind, {}).get("final_ready", 0) for kind in kinds)
        package_count = nested_value(package, requirement["package_path"])
        minimum = int(requirement["minimum_assets"])
        entries.append(
            {
                "format": key,
                "label": requirement["label"],
                "target_kinds": sorted(kinds),
                "asset_count": asset_count,
                "minimum_assets": minimum,
                "structural_ready_count": structural_ready_count,
                "final_ready_count": final_ready_count,
                "package_count": package_count,
                "package_path": list(requirement["package_path"]),
                "coverage_status": "covered_structural" if asset_count >= minimum and structural_ready_count >= minimum else "under_target",
                "final_status": "final_ready" if final_ready_count >= minimum else "final_blocked",
            }
        )
    return entries


def markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Asset Family Coverage Report / 美术资产族覆盖报告",
        "",
        "本报告把目标中的完整游戏美术资产类型和 Godot 可用格式映射到当前仓库证据。它证明结构覆盖，不证明最终清稿、授权、运行时表现或 final-ready。",
        "",
        "## Summary",
        "",
        f"- Asset families: `{report['summary']['family_count']}`",
        f"- Families structurally covered: `{report['summary']['families_structurally_covered']}`",
        f"- Godot formats: `{report['summary']['format_count']}`",
        f"- Formats structurally covered: `{report['summary']['formats_structurally_covered']}`",
        f"- Final-ready assets: `{report['summary']['final_ready_count']}`",
        f"- Structural-ready assets: `{report['summary']['structural_ready_count']}`",
        "",
        "## Asset Families",
        "",
        "| Family | Assets | Structural Ready | Final Ready | Status |",
        "| --- | ---: | ---: | ---: | --- |",
    ]
    for entry in report["asset_families"]:
        lines.append(
            f"| {entry['label']} | {entry['asset_count']}/{entry['minimum_assets']} | "
            f"{entry['structural_ready_count']} | {entry['final_ready_count']} | "
            f"{entry['coverage_status']} / {entry['final_status']} |"
        )
    lines.extend(
        [
            "",
            "## Godot Formats",
            "",
            "| Format | Assets | Structural Ready | Package Count | Final Ready | Status |",
            "| --- | ---: | ---: | ---: | ---: | --- |",
        ]
    )
    for entry in report["godot_formats"]:
        lines.append(
            f"| {entry['label']} | {entry['asset_count']}/{entry['minimum_assets']} | "
            f"{entry['structural_ready_count']} | {entry['package_count']} | "
            f"{entry['final_ready_count']} | {entry['coverage_status']} / {entry['final_status']} |"
        )
    lines.extend(
        [
            "",
            "## Remaining Gates",
            "",
            f"- 当前覆盖已达到完整资产族的 structural pass，`final_ready_count = {report['summary']['final_ready_count']}`；未进入 final-ready 的资产仍需要授权复核、清稿、运行态读值或最终批准。",
            "- 下一步不是扩大类别，而是按 final-art review queue、runtime source review queue 和 regeneration packet 继续做来源确认、授权复核、人工清稿、帧序 / NinePatch / TileSet / VFX 运行态复核。",
            "",
        ]
    )
    return "\n".join(lines)


def build_report(root: Path, queue_path: Path, readiness_path: Path, package_path: Path) -> dict[str, Any]:
    queue = load_json(queue_path)
    readiness = load_json(readiness_path)
    package = load_json(package_path)
    items = list(queue.get("items", []))
    family_entries = build_family_entries(items, readiness)
    format_entries = build_format_entries(items, readiness, package)
    readiness_summary = readiness.get("summary", {})
    return {
        "version": 1,
        "status": "structural_coverage_ready",
        "boundary": (
            "Coverage report for requested asset families and Godot-ready formats. "
            "It proves structural coverage only, not final art approval."
        ),
        "sources": {
            "image_gen_prompt_queue": queue_path.relative_to(root).as_posix(),
            "art_readiness": readiness_path.relative_to(root).as_posix(),
            "asset_package_audit": package_path.relative_to(root).as_posix(),
        },
        "summary": {
            "family_count": len(family_entries),
            "families_structurally_covered": sum(1 for entry in family_entries if entry["coverage_status"] == "covered_structural"),
            "format_count": len(format_entries),
            "formats_structurally_covered": sum(1 for entry in format_entries if entry["coverage_status"] == "covered_structural"),
            "structural_ready_count": int(readiness_summary.get("structural_ready_count", 0)),
            "final_ready_count": int(readiness_summary.get("final_ready_count", 0)),
            "queue_item_count": len(items),
        },
        "asset_families": family_entries,
        "godot_formats": format_entries,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(
        root,
        resolve_path(root, args.queue),
        resolve_path(root, args.readiness),
        resolve_path(root, args.package),
    )
    json_out = resolve_path(root, args.json_out)
    markdown_out = resolve_path(root, args.markdown_out)
    json_out.parent.mkdir(parents=True, exist_ok=True)
    markdown_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    markdown_out.write_text(markdown(report), encoding="utf-8")
    summary = report["summary"]
    print(
        "Asset family coverage: "
        f"{summary['families_structurally_covered']}/{summary['family_count']} families, "
        f"{summary['formats_structurally_covered']}/{summary['format_count']} Godot formats, "
        f"{summary['final_ready_count']} final-ready."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
