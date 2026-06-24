#!/usr/bin/env python3
"""Build a manual final-art review queue from art readiness blockers."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_READINESS = "docs/assets/art-readiness-audit-report.json"
DEFAULT_JSON_OUT = "docs/assets/final-art-review-queue.json"
DEFAULT_MARKDOWN_OUT = "docs/assets/final-art-review-queue.md"

BLOCKER_ACTIONS = {
    "license_terms_manual_review": "确认 image gen / 外部来源的商业使用条款，并记录审批结论。",
    "runtime_catalog_ready_manual_replacement": "在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。",
    "animation_timing_manual_review": "在 Godot 中复核动画 fps、停顿帧、预备动作和收招节奏。",
    "foot_baseline_and_anchor_manual_review": "检查逐帧脚底基线、pivot 和 anchor 是否稳定。",
    "frame_order_manual_review": "确认帧序并移除不适合运行时播放的错序姿势。",
    "frame_order_review": "复核帧序和预期播放用途。",
    "semantic_labels_manual_review": "确认语义标签与实际 atlas region 一致。",
    "alpha_padding_policy_manual_review": "确认 tile / atlas 的透明 padding 是有意保留的编辑边界。",
    "opaque_preview_manual_review": "复核 opaque preview 的发布 / 叙事构图，同时保留原始 alpha 图。",
    "parallax_layer_split": "把背景拆成前景、中景、远景等可配置 parallax 层。",
    "anchor_manual_review": "在测试场景中复核 VFX anchor、spawn offset 和缩放。",
    "mask_and_blend_manual_review": "复核 VFX mask、透明边缘和混合模式。",
    "pseudo_text_cleanup": "清理或重绘不可读的生成伪文字。",
    "small_size_readability_review": "按目标 HUD / icon 像素尺寸检查读值。",
    "foreground_occlusion_review": "检查前景装饰不会遮挡玩家、危险物或交互物。",
    "panel_crop_and_order_review": "裁切分镜面板并确认阅读顺序。",
    "script_matching_review": "对照剧情 beat 或脚本确认分镜意图。",
    "brightness_and_gameplay_readability_review": "平衡背景亮度，确保玩家、危险物和交互物读值清楚。",
    "collision_and_terrain_manual_review": "在 Godot 中复核 TileSet 碰撞候选和 terrain 分组。",
    "hazard_safe_boundary_manual_review": "确认危险视觉不会暗示错误碰撞边界。",
    "mask_and_anchor_cleanup": "清理 HUD / warning mask 和 anchor 位置。",
    "pivot_and_layer_order_review": "绑定前复核拆件 pivot 与绘制层级。",
    "rigging_cleanup": "为后续 rigging 清理拆件并移除不适合绑定的碎片。",
    "runtime_contrast_review": "在预期背景上检查运行时对比度。",
    "runtime_layout_manual_review": "在真实运行时容器中复核 UI 面板布局。",
    "text_safe_area_manual_review": "确认 UI 面板文本安全区和缩放边界。",
    "theme_mapping_manual_review": "确认 Theme / StyleBox 映射在目标 UI 场景中可用。",
    "title_safe_area_review": "检查标题和主视觉在目标比例下的安全区。",
    "final_ninepatch_margin_manual_review": "复核最终 NinePatch / StyleBox 边距。",
    "stretch_distortion_manual_review": "检查 UI 拉伸时是否失真。",
    "manual_typography_cleanup": "手工或矢量方式重绘 Logo / 标题字。",
    "marketing_composition_review": "复核宣传构图、视觉焦点和裁切版本。",
    "narrative_consistency_review": "对照故事、角色和世界观检查 CG 内容。",
    "platform_safe_area_review": "检查 capsule / 商店图安全区。",
    "vector_or_high_res_title_treatment": "制作矢量或高清标题字处理。",
    "material_semantics_review": "命名材质区域并确认用途。",
    "seam_and_tiling_review": "复核贴图接缝和重复效果。",
    "state_variant_naming": "命名道具状态变体及其玩法含义。",
    "scale_readability_review": "对照玩家体型检查道具比例读值。",
    "boss_readability_and_camera_scale_review": "检查 Boss 读值尺寸和镜头 framing。",
}

FAMILY_BY_KIND = {
    "boss_direction": "characters",
    "character_direction": "characters",
    "spine_cutout_parts": "characters",
    "sprite_sheet": "animation",
    "environment_background": "environment",
    "environment_boss_room_background": "environment",
    "environment_room_background": "environment",
    "environment_tiles": "environment",
    "texture_atlas": "textures",
    "tileset_sheet": "environment",
    "completion_ui": "ui",
    "hud_frame": "ui",
    "icon": "icons",
    "icon_sheet": "icons",
    "ninepatch_sheet": "ui",
    "title_background": "ui",
    "ui_atlas": "ui",
    "ui_panel": "ui",
    "prop": "props_equipment",
    "prop_atlas": "props_equipment",
    "prop_sheet": "props_equipment",
    "equipment_atlas": "props_equipment",
    "vfx_atlas": "vfx",
    "vfx_direction": "vfx",
    "vfx_sheet": "vfx",
    "vfx_warning": "vfx",
    "logo_direction": "promo_logo_cg",
    "promo_capsule": "promo_logo_cg",
    "promo_key_art": "promo_logo_cg",
    "cg_illustration": "promo_logo_cg",
    "storyboard_sheet": "story",
    "style_board": "style",
}

PRIORITY_BY_FAMILY = {
    "characters": "P0",
    "animation": "P0",
    "vfx": "P0",
    "ui": "P0",
    "icons": "P0",
    "environment": "P1",
    "props_equipment": "P1",
    "textures": "P1",
    "style": "P1",
    "promo_logo_cg": "P2",
    "story": "P2",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build final-art manual review queue.")
    parser.add_argument("--readiness", default=DEFAULT_READINESS)
    parser.add_argument("--json-out", default=DEFAULT_JSON_OUT)
    parser.add_argument("--markdown-out", default=DEFAULT_MARKDOWN_OUT)
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


def action_for(blocker: str) -> str:
    return BLOCKER_ACTIONS.get(blocker, f"需要人工复核 `{blocker}`。")


def build_entry(root: Path, item: dict[str, Any]) -> dict[str, Any]:
    target_kind = str(item.get("target_kind", "unknown"))
    family = FAMILY_BY_KIND.get(target_kind, "other")
    blockers = list(dict.fromkeys(str(blocker) for blocker in item.get("polish_blockers", [])))
    output_path = resolve_path(root, str(item.get("output_path", "")))
    evidence_paths = [normalize_rel(output_path, root)]
    for key in ("background_alpha_policy", "tileset_rules", "ui_skin_rules", "vfx_rules", "animation_rules"):
        value = item.get(key)
        if isinstance(value, dict):
            path = value.get("path") or value.get("opaque_preview_path")
            if path:
                evidence_paths.append(str(path))
            preview = value.get("opaque_preview_path")
            if preview:
                evidence_paths.append(str(preview))
    if isinstance(item.get("runtime_catalog"), dict):
        resource_path = item["runtime_catalog"].get("resource_path", "")
        if resource_path:
            evidence_paths.append(str(resource_path).removeprefix("res://"))
    return {
        "asset_id": item["asset_id"],
        "target_kind": target_kind,
        "family": family,
        "priority": PRIORITY_BY_FAMILY.get(family, "P2"),
        "review_status": "manual_review_required",
        "structural_ready": bool(item.get("structural_ready", False)),
        "final_ready": bool(item.get("final_ready", False)),
        "output_path": normalize_rel(output_path, root),
        "blocker_count": len(blockers),
        "blockers": blockers,
        "next_actions": [action_for(blocker) for blocker in blockers],
        "evidence_paths": sorted(dict.fromkeys(evidence_paths)),
    }


def markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Final Art Review Queue / 最终美术复核队列",
        "",
        "本队列把 art readiness blockers 转换为可逐项勾选的人工复核任务。它是复核计划，不是最终美术批准。",
        "",
        "## Summary",
        "",
        f"- 资产总数：`{report['summary']['asset_count']}`",
        f"- 需要人工复核：`{report['summary']['manual_review_required_count']}`",
        f"- Final ready：`{report['summary']['final_ready_count']}`",
        "",
        "## By Family",
        "",
    ]
    for family, count in report["summary"]["family_counts"].items():
        lines.append(f"- `{family}`: `{count}`")
    lines.extend(["", "## Queue", ""])
    for entry in report["entries"]:
        lines.append(
            f"- [ ] `{entry['priority']}` `{entry['asset_id']}` "
            f"({entry['family']} / {entry['target_kind']}) - {entry['blocker_count']} blockers"
        )
        for action in entry["next_actions"][:5]:
            lines.append(f"  - {action}")
        if entry["blocker_count"] > 5:
            lines.append(f"  - 另有 `{entry['blocker_count'] - 5}` 项复核动作。")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    readiness = load_json(resolve_path(root, args.readiness))
    entries = [build_entry(root, item) for item in readiness.get("items", [])]
    entries.sort(key=lambda item: (item["priority"], item["family"], item["asset_id"]))

    family_counts: dict[str, int] = {}
    blocker_counts: dict[str, int] = {}
    for entry in entries:
        family_counts[entry["family"]] = family_counts.get(entry["family"], 0) + 1
        for blocker in entry["blockers"]:
            blocker_counts[blocker] = blocker_counts.get(blocker, 0) + 1
    report = {
        "version": 1,
        "status": "manual_review_queue_ready",
        "boundary": (
            "Manual final-art review queue. Passing audits means every structural asset has an explicit "
            "review task; it does not mean the asset is final-ready."
        ),
        "summary": {
            "asset_count": len(entries),
            "manual_review_required_count": sum(1 for entry in entries if entry["blockers"]),
            "final_ready_count": sum(1 for entry in entries if entry["final_ready"]),
            "family_counts": dict(sorted(family_counts.items())),
            "blocker_counts": dict(sorted(blocker_counts.items())),
        },
        "entries": entries,
    }
    json_out = resolve_path(root, args.json_out)
    md_out = resolve_path(root, args.markdown_out)
    json_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    md_out.write_text(markdown(report), encoding="utf-8")
    print(
        "Final art review queue built: "
        f"{report['summary']['asset_count']} assets, "
        f"{report['summary']['manual_review_required_count']} manual-review assets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
