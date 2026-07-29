#!/usr/bin/env python3
"""Audit FP-05 animation runtime candidates and VFX binding readiness."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_JSON_REPORT = "docs/assets/final-art-polish-fp05-animation-vfx-report.json"
DEFAULT_MD_REPORT = "docs/assets/final-art-polish-fp05-animation-vfx-report.md"

ANIMATION_CANDIDATE_REPORT = "docs/assets/animation-runtime-replacement-candidate-audit-report.json"
ANIMATION_RULE_INDEX = "assets/art/characters/animation_rules/animation_rules.index.json"
VFX_RULE_INDEX = "assets/art/vfx/vfx_rules/vfx_rules.index.json"

RUNTIME_REFERENCES = [
    {
        "scene": "scripts/player/player_placeholder.gd",
        "required": [
            "luna_attack_body_runtime_sheet_ai02.spriteframes.tres",
            "luna_air_dash_body_runtime_sheet_ai02.spriteframes.tres",
            "luna_hit_react_runtime_sheet_ai01.spriteframes.tres",
            "luna_death_idle_runtime_sheet_ai01.spriteframes.tres",
            "luna_attack_slash_vfx_runtime_ai01.spriteframes.tres",
            "luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres",
        ],
    },
    {
        "scene": "scenes/player/player_placeholder.tscn",
        "required": [
            "luna_attack_body_runtime_sheet_ai02.spriteframes.tres",
            "luna_air_dash_body_runtime_sheet_ai02.spriteframes.tres",
            "luna_attack_slash_vfx_runtime_ai01.spriteframes.tres",
            "luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres",
            "AirDashTrailArt",
        ],
    },
    {
        "scene": "scripts/combat/seal_guardian_boss.gd",
        "required": [
            "seal_guardian_attack_body_runtime_sheet_ai02.spriteframes.tres",
            "seal_guardian_attack_vfx_atlas_ai01.spriteframes.tres",
        ],
    },
    {
        "scene": "scenes/enemies/seal_guardian_boss.tscn",
        "required": [
            "seal_guardian_attack_body_runtime_sheet_ai02.spriteframes.tres",
            "seal_guardian_attack_vfx_atlas_ai01.spriteframes.tres",
            "metadata/asset_id = \"seal_guardian_attack_vfx_atlas_ai01\"",
        ],
    },
    {
        "scene": "scenes/combat/basic_melee_enemy.tscn",
        "required": [
            "enemy_basic_melee_runtime_sheet_ai01.spriteframes.tres",
            "enemy_hit_spark_vfx_runtime_ai01.spriteframes.tres",
        ],
    },
    {
        "scene": "scripts/combat/base_enemy.gd",
        "required": [
            "EnemyHitSparkVfxVisual",
            "_show_enemy_hit_spark_vfx",
        ],
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit FP-05 animation and VFX readiness.")
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--json-report", default=DEFAULT_JSON_REPORT)
    parser.add_argument("--md-report", default=DEFAULT_MD_REPORT)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit_animation_candidates(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    report_path = root / ANIMATION_CANDIDATE_REPORT
    report = load_json(report_path) if report_path.exists() else {}
    if report.get("status") != "runtime_replacement_ready":
        errors.append("candidate_report_not_ready")
    if int(report.get("active_asset_count", 0)) != 15:
        errors.append("active_asset_count_mismatch")
    if int(report.get("ready_count", 0)) != 15:
        errors.append("active_ready_count_mismatch")
    if int(report.get("blocked_count", -1)) != 0:
        errors.append("active_blocked_not_zero")
    if int(report.get("archived_reference_count", 0)) != 8:
        errors.append("archived_reference_count_mismatch")
    if int(report.get("archived_reference_error_count", -1)) != 0:
        errors.append("archived_reference_errors")
    active_assets = [asset.get("asset_id", "") for asset in report.get("assets", [])]
    return {
        "status": "ready" if not errors else "blocked",
        "report": ANIMATION_CANDIDATE_REPORT,
        "active_asset_count": report.get("active_asset_count", 0),
        "ready_count": report.get("ready_count", 0),
        "blocked_count": report.get("blocked_count", 0),
        "archived_reference_count": report.get("archived_reference_count", 0),
        "archived_reference_error_count": report.get("archived_reference_error_count", 0),
        "sample_active_assets": active_assets[:8],
        "errors": errors,
        "warnings": [],
    }


def audit_animation_rules(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    index_path = root / ANIMATION_RULE_INDEX
    index = load_json(index_path) if index_path.exists() else {}
    if int(index.get("asset_count", 0)) != 8:
        errors.append("animation_rule_asset_count_mismatch")
    if int(index.get("frame_rule_count", 0)) != 172:
        errors.append("animation_rule_frame_count_mismatch")
    if not index.get("manual_review_required", False):
        errors.append("animation_rules_manual_review_not_marked")
    return {
        "status": "ready" if not errors else "blocked",
        "index": ANIMATION_RULE_INDEX,
        "asset_count": index.get("asset_count", 0),
        "frame_rule_count": index.get("frame_rule_count", 0),
        "errors": errors,
        "warnings": [],
    }


def audit_vfx_rules(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    warnings: list[str] = []
    index_path = root / VFX_RULE_INDEX
    index = load_json(index_path) if index_path.exists() else {}
    assets = index.get("assets", [])
    if int(index.get("asset_count", 0)) != 7:
        errors.append("vfx_rule_asset_count_mismatch")
    if int(index.get("frame_rule_count", 0)) != 86:
        errors.append("vfx_rule_frame_count_mismatch")
    if not index.get("manual_review_required", False):
        errors.append("vfx_rules_manual_review_not_marked")

    checked_frames = 0
    collision_disabled = 0
    damage_disabled = 0
    for asset in assets:
        rule_path = root / str(asset.get("path", ""))
        if not rule_path.exists():
            errors.append(f"{asset.get('asset_id')}:rule_file_missing")
            continue
        rules = load_json(rule_path)
        for rule in rules.get("rules", []):
            checked_frames += 1
            if bool(rule.get("gameplay_collision", True)) is False:
                collision_disabled += 1
            if bool(rule.get("damage_source", True)) is False:
                damage_disabled += 1
            if len(rule.get("anchor_px", [])) != 2:
                errors.append(f"{asset.get('asset_id')}:{rule.get('index')}:anchor_missing")
            if not rule.get("recommended_blend"):
                warnings.append(f"{asset.get('asset_id')}:{rule.get('index')}:blend_missing")
    if checked_frames != int(index.get("frame_rule_count", 0)):
        errors.append("vfx_checked_frame_count_mismatch")
    if collision_disabled != checked_frames:
        errors.append("vfx_collision_not_all_disabled")
    if damage_disabled != checked_frames:
        errors.append("vfx_damage_not_all_disabled")

    return {
        "status": "ready" if not errors else "blocked",
        "index": VFX_RULE_INDEX,
        "asset_count": index.get("asset_count", 0),
        "frame_rule_count": index.get("frame_rule_count", 0),
        "collision_disabled_count": collision_disabled,
        "damage_disabled_count": damage_disabled,
        "errors": errors,
        "warnings": warnings,
    }


def audit_runtime_references(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    scenes = []
    for spec in RUNTIME_REFERENCES:
        path = root / spec["scene"]
        text = path.read_text(encoding="utf-8") if path.exists() else ""
        missing = [needle for needle in spec["required"] if needle not in text]
        if not path.exists():
            errors.append(f"{spec['scene']}:missing")
        errors.extend(f"{spec['scene']}:{needle}:missing_reference" for needle in missing)
        scenes.append({
            "scene": spec["scene"],
            "status": "references_ready" if not missing and path.exists() else "blocked",
            "required_count": len(spec["required"]),
            "missing": missing,
        })
    return {
        "status": "ready" if not errors else "blocked",
        "scenes": scenes,
        "errors": errors,
        "warnings": [],
    }


def build_report(root: Path) -> dict[str, Any]:
    sections = {
        "animation_candidates": audit_animation_candidates(root),
        "animation_rules": audit_animation_rules(root),
        "vfx_rules": audit_vfx_rules(root),
        "runtime_references": audit_runtime_references(root),
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
            "FP-05 animation / VFX final polish audit. Passing means active runtime animation "
            "candidates, first-pass animation rules, VFX no-collision/no-damage rules, and key "
            "runtime references are coherent. It does not replace live playtest timing, hitbox/hurtbox "
            "or final hand-authored animation polish."
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
        "# Final Art Polish FP-05 Animation VFX Report",
        "",
        f"- Status: `{report['status']}`",
        f"- Errors: `{report['summary']['error_count']}`",
        f"- Warnings: `{report['summary']['warning_count']}`",
        "",
        "## Sections",
        "",
        f"- Animation candidates: `{report['animation_candidates']['status']}` / `{report['animation_candidates']['ready_count']}` ready / `{report['animation_candidates']['blocked_count']}` blocked",
        f"- Animation rules: `{report['animation_rules']['status']}` / `{report['animation_rules']['asset_count']}` assets / `{report['animation_rules']['frame_rule_count']}` frame rules",
        f"- VFX rules: `{report['vfx_rules']['status']}` / `{report['vfx_rules']['asset_count']}` assets / `{report['vfx_rules']['frame_rule_count']}` frame rules",
        f"- Runtime references: `{report['runtime_references']['status']}` / `{len(report['runtime_references']['scenes'])}` files",
        "",
        "## Runtime References",
        "",
    ]
    for scene in report["runtime_references"]["scenes"]:
        lines.append(f"- `{scene['scene']}`: `{scene['status']}`, required refs `{scene['required_count']}`")
    lines.extend([
        "",
        "## Boundary",
        "",
        report["boundary"],
        "",
    ])
    path.write_text("\n".join(lines), encoding="utf-8")


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
        "FP-05 animation/VFX audit: "
        f"{report['summary']['error_count']} errors, "
        f"{report['summary']['warning_count']} warnings."
    )
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
