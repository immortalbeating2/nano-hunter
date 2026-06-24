#!/usr/bin/env python3
"""Build a target-scene matrix for P0 runtime replacement planning."""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path
from typing import Any


PLAN_PATH = Path("docs/assets/p0-runtime-replacement-plan.json")
OUT_JSON = Path("docs/assets/p0-target-scene-replacement-matrix.json")
OUT_MD = Path("docs/assets/p0-target-scene-replacement-matrix.md")


VALIDATION_BY_SCENE_KEYWORD = {
    "demo_shell": ["godot --headless --path . --import", "Run DemoShell / Stage16 UI focused GUT after real replacement."],
    "tutorial_hud": ["godot --headless --path . --import", "Run HUD and closest Stage14 / Stage15 / Stage16 focused GUT after real replacement."],
    "player_placeholder": ["godot --headless --path . --import", "Run player movement / combat focused GUT after real replacement."],
    "seal_guardian_boss": ["godot --headless --path . --import", "Run Stage15 Seal Guardian focused GUT after real replacement."],
    "stage14": ["godot --headless --path . --import", "Run Stage14 focused GUT and manual Air Dash room review after real replacement."],
    "stage15": ["godot --headless --path . --import", "Run Stage15 focused GUT and boss room manual review after real replacement."],
    "stage16": ["godot --headless --path . --import", "Run Stage16 focused GUT and Alpha Demo flow review after real replacement."],
    "stage13": ["godot --headless --path . --import", "Run Stage13 / TileSet room review after real replacement."],
    "combat": ["godot --headless --path . --import", "Run closest enemy / combat focused GUT after real replacement."],
}


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def validation_commands(scene: str) -> list[str]:
    commands: list[str] = []
    lower_scene = scene.lower()
    for keyword, values in VALIDATION_BY_SCENE_KEYWORD.items():
        if keyword in lower_scene:
            for value in values:
                if value not in commands:
                    commands.append(value)
    if not commands:
        commands = ["godot --headless --path . --import", "Run the closest focused GUT after real replacement."]
    if "python scripts\\assets\\audit_asset_package.py --strict --write-report" not in commands:
        commands.append("python scripts\\assets\\audit_asset_package.py --strict --write-report")
    return commands


def scene_stage_bucket(scene: str) -> str:
    lower_scene = scene.lower()
    for token in ("stage16", "stage15", "stage14", "stage13"):
        if token in lower_scene:
            return token
    if "demo_shell" in lower_scene or "tutorial_hud" in lower_scene:
        return "ui"
    if "player" in lower_scene:
        return "player"
    if "combat" in lower_scene or "enemies" in lower_scene:
        return "combat"
    if "dev" in lower_scene:
        return "dev"
    return "misc"


def replacement_risk(entry: dict[str, Any]) -> str:
    blockers = set(entry.get("family_polish_blockers", []))
    resource_type = str(entry.get("catalog_resource_type", "unknown"))
    if blockers:
        return "blocked_by_family_polish"
    if resource_type in {"SpriteFrames", "TileSet", "StyleBoxTexture"}:
        return "requires_runtime_review"
    if entry.get("runtime_replacement_status") == "already_referenced":
        return "already_referenced_reference_only"
    return "ready_for_manual_replacement_plan"


def build_matrix(plan: dict[str, Any]) -> dict[str, Any]:
    scene_entries: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for entry in plan.get("entries", []):
        for scene_status in entry.get("target_scene_status", []):
            scene = str(scene_status.get("scene", ""))
            scene_entries[scene].append(
                {
                    "asset_id": entry.get("asset_id"),
                    "track": entry.get("track"),
                    "target_kind": entry.get("target_kind"),
                    "target_system": entry.get("target_system"),
                    "catalog_resource_type": entry.get("catalog_resource_type"),
                    "resource_path": entry.get("resource_path"),
                    "runtime_replacement_status": entry.get("runtime_replacement_status"),
                    "already_references_resource": bool(scene_status.get("already_references_resource", False)),
                    "family_polish_blockers": entry.get("family_polish_blockers", []),
                    "replacement_risk": replacement_risk(entry),
                }
            )

    scenes: list[dict[str, Any]] = []
    all_assets: set[str] = set()
    scene_reference_count = 0
    high_impact_scenes = 0
    for scene, assets in sorted(scene_entries.items()):
        for asset in assets:
            all_assets.add(str(asset["asset_id"]))
        scene_reference_count += len(assets)
        if len(assets) >= 4:
            high_impact_scenes += 1
        risk_counts: dict[str, int] = {}
        resource_type_counts: dict[str, int] = {}
        for asset in assets:
            risk = str(asset["replacement_risk"])
            resource_type = str(asset["catalog_resource_type"])
            risk_counts[risk] = risk_counts.get(risk, 0) + 1
            resource_type_counts[resource_type] = resource_type_counts.get(resource_type, 0) + 1
        scenes.append(
            {
                "scene": scene,
                "exists": Path(scene).exists(),
                "bucket": scene_stage_bucket(scene),
                "asset_count": len(assets),
                "already_referenced_count": sum(1 for asset in assets if asset["already_references_resource"]),
                "planned_replacement_count": sum(1 for asset in assets if not asset["already_references_resource"]),
                "risk_counts": dict(sorted(risk_counts.items())),
                "resource_type_counts": dict(sorted(resource_type_counts.items())),
                "validation_commands": validation_commands(scene),
                "assets": assets,
            }
        )

    return {
        "version": 1,
        "status": "p0_target_scene_replacement_matrix_ready",
        "boundary": "Scene matrix only. It groups P0 runtime replacement entries by target scene; it does not modify scene references or approve final art.",
        "sources": {
            "p0_runtime_replacement_plan": str(PLAN_PATH),
        },
        "summary": {
            "scene_count": len(scenes),
            "unique_asset_count": len(all_assets),
            "scene_asset_reference_count": scene_reference_count,
            "high_impact_scene_count": high_impact_scenes,
            "missing_scene_count": sum(1 for scene in scenes if not scene["exists"]),
            "already_referenced_scene_asset_count": sum(scene["already_referenced_count"] for scene in scenes),
            "planned_scene_asset_replacement_count": sum(scene["planned_replacement_count"] for scene in scenes),
        },
        "scenes": scenes,
    }


def write_markdown(report: dict[str, Any]) -> None:
    summary = report["summary"]
    lines = [
        "# P0 Target Scene Replacement Matrix / P0 目标场景替换矩阵",
        "",
        "本矩阵把 P0 runtime replacement plan 按目标场景聚合，帮助后续按场景分批替换资源。",
        "它不直接修改 `.tscn`，也不关闭 `runtime_replacement` gate。",
        "",
        "## Summary",
        "",
        f"- 目标场景数：`{summary['scene_count']}`",
        f"- 唯一资产数：`{summary['unique_asset_count']}`",
        f"- 场景-资产引用项：`{summary['scene_asset_reference_count']}`",
        f"- 高影响场景数：`{summary['high_impact_scene_count']}`",
        f"- 缺失场景数：`{summary['missing_scene_count']}`",
        f"- 已引用项：`{summary['already_referenced_scene_asset_count']}`",
        f"- 仍需替换项：`{summary['planned_scene_asset_replacement_count']}`",
        "",
        "## Scenes",
        "",
    ]
    for scene in report["scenes"]:
        lines.append(f"- [ ] `{scene['scene']}` ({scene['bucket']}) - assets `{scene['asset_count']}`, planned `{scene['planned_replacement_count']}`")
        lines.append(f"  - Resource types: {json.dumps(scene['resource_type_counts'], ensure_ascii=False)}")
        lines.append(f"  - Risks: {json.dumps(scene['risk_counts'], ensure_ascii=False)}")
        lines.append("  - Assets: " + ", ".join(f"`{asset['asset_id']}`" for asset in scene["assets"]))
        lines.append("  - Validation: " + " | ".join(scene["validation_commands"]))
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    plan = load_json(PLAN_PATH)
    report = build_matrix(plan)
    write_json(OUT_JSON, report)
    write_markdown(report)
    summary = report["summary"]
    print(
        "P0 target scene replacement matrix built: "
        f"{summary['scene_count']} scenes, "
        f"{summary['unique_asset_count']} assets, "
        f"{summary['scene_asset_reference_count']} scene-asset references."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
