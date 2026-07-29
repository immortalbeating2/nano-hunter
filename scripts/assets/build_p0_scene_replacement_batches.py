#!/usr/bin/env python3
"""Build executable P0 scene replacement batches from the target-scene matrix."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


MATRIX_PATH = Path("docs/assets/p0-target-scene-replacement-matrix.json")
OUT_JSON = Path("docs/assets/p0-scene-replacement-batches.json")
OUT_MD = Path("docs/assets/p0-scene-replacement-batches.md")

BATCH_DEFINITIONS = [
    {
        "batch_id": "batch_01_ui_shell",
        "title": "Demo 壳 UI",
        "purpose": "把 DemoShell 主菜单、暂停、重开和完成反馈相关 UI 资源作为一个可复核的 UI 壳批次处理。",
        "scenes": ["scenes/ui/demo_shell.tscn"],
    },
    {
        "batch_id": "batch_02_hud",
        "title": "教程 HUD",
        "purpose": "把 HUD 图标、能力状态和反馈资源从菜单壳中拆出来单独替换和验证。",
        "scenes": ["scenes/ui/tutorial_hud.tscn"],
    },
    {
        "batch_id": "batch_03_player",
        "title": "玩家读值与动画",
        "purpose": "在帧序、pivot 和脚底基线复核后，替换 Luna 运行时贴图与 SpriteFrames。",
        "scenes": ["scenes/player/player_placeholder.tscn"],
    },
    {
        "batch_id": "batch_04_boss_core",
        "title": "Seal Guardian 与封印压力",
        "purpose": "把 Seal Guardian 本体与 Stage15 封印压力符印资源放在同一批次复核。",
        "scenes": [
            "scenes/enemies/seal_guardian_boss.tscn",
            "scenes/rooms/stage15_seal_pressure_room.tscn",
        ],
    },
    {
        "batch_id": "batch_05_stage14_air_dash",
        "title": "Stage14 Air Dash 房间",
        "purpose": "替换 Stage14 能力循环中的 Air Dash shrine、gate、trail 和能力读值道具。",
        "scenes": [
            "scenes/rooms/stage14_air_dash_shrine_room.tscn",
        ],
    },
    {
        "batch_id": "batch_06_stage16_end_chain",
        "title": "Stage16 终局链路",
        "purpose": "把阈值释放、Stage15 完成回声、回溯确认、Alpha Demo 终点、relay 和 purge 作为终局反馈批次处理。",
        "scenes": [
            "scenes/rooms/stage16_seal_release_threshold_room.tscn",
            "scenes/rooms/stage15_completion_room.tscn",
            "scenes/rooms/stage16_backtrack_confirmation_room.tscn",
            "scenes/rooms/stage16_alpha_demo_end_room.tscn",
            "scenes/rooms/stage16_talisman_relay_room.tscn",
            "scenes/rooms/stage16_corruption_purge_room.tscn",
        ],
    },
]


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def add_counts(target: dict[str, int], source: dict[str, Any]) -> None:
    for key, value in source.items():
        target[str(key)] = target.get(str(key), 0) + int(value)


def replacement_gate_status(risk_counts: dict[str, int], planned_count: int, already_count: int, reference_count: int) -> str:
    if risk_counts.get("blocked_by_family_polish", 0) > 0:
        return "blocked_by_family_polish"
    if planned_count > 0:
        return "planned_manual_replacement"
    if already_count == reference_count:
        return "reference_only_already_bound"
    return "needs_review"


def dedupe_assets(scenes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    assets_by_id: dict[str, dict[str, Any]] = {}
    for scene in scenes:
        for asset in scene.get("assets", []):
            asset_id = str(asset.get("asset_id", ""))
            if asset_id and asset_id not in assets_by_id:
                assets_by_id[asset_id] = dict(asset)
    return [assets_by_id[key] for key in sorted(assets_by_id)]


def build_batches(matrix: dict[str, Any]) -> dict[str, Any]:
    scenes_by_path = {str(scene.get("scene", "")): scene for scene in matrix.get("scenes", [])}
    batches: list[dict[str, Any]] = []
    covered_scenes: set[str] = set()
    all_unique_assets: set[str] = set()
    total_scene_asset_references = 0
    total_planned = 0
    total_already = 0

    for definition in BATCH_DEFINITIONS:
        scene_paths = [path for path in definition["scenes"] if path in scenes_by_path]
        if not scene_paths:
            continue
        batch_scenes = [scenes_by_path[path] for path in scene_paths]
        covered_scenes.update(str(scene.get("scene", "")) for scene in batch_scenes)

        validation_commands: list[str] = []
        risk_counts: dict[str, int] = {}
        resource_type_counts: dict[str, int] = {}
        scene_asset_reference_count = 0
        planned_count = 0
        already_count = 0
        missing_scenes = [path for path in scene_paths if not scenes_by_path[path].get("exists")]

        for scene in batch_scenes:
            add_counts(risk_counts, scene.get("risk_counts", {}))
            add_counts(resource_type_counts, scene.get("resource_type_counts", {}))
            scene_asset_reference_count += int(scene.get("asset_count", 0))
            planned_count += int(scene.get("planned_replacement_count", 0))
            already_count += int(scene.get("already_referenced_count", 0))
            for command in scene.get("validation_commands", []):
                if command not in validation_commands:
                    validation_commands.append(command)

        unique_assets = dedupe_assets(batch_scenes)
        for asset in unique_assets:
            all_unique_assets.add(str(asset.get("asset_id", "")))
        total_scene_asset_references += scene_asset_reference_count
        total_planned += planned_count
        total_already += already_count

        batches.append(
            {
                "batch_id": definition["batch_id"],
                "recommended_order": len(batches),
                "title": definition["title"],
                "purpose": definition["purpose"],
                "status": "planned_scene_replacement_batch",
                "replacement_gate_status": replacement_gate_status(
                    risk_counts,
                    planned_count,
                    already_count,
                    scene_asset_reference_count,
                ),
                "scene_count": len(batch_scenes),
                "scenes": [
                    {
                        "scene": str(scene.get("scene", "")),
                        "bucket": scene.get("bucket"),
                        "exists": bool(scene.get("exists")),
                        "asset_count": int(scene.get("asset_count", 0)),
                        "planned_replacement_count": int(scene.get("planned_replacement_count", 0)),
                        "already_referenced_count": int(scene.get("already_referenced_count", 0)),
                    }
                    for scene in batch_scenes
                ],
                "missing_scenes": missing_scenes,
                "unique_asset_count": len(unique_assets),
                "scene_asset_reference_count": scene_asset_reference_count,
                "planned_scene_asset_replacement_count": planned_count,
                "already_referenced_scene_asset_count": already_count,
                "risk_counts": dict(sorted(risk_counts.items())),
                "resource_type_counts": dict(sorted(resource_type_counts.items())),
                "validation_commands": validation_commands,
                "assets": unique_assets,
            }
        )

    missing_matrix_scenes = sorted(set(scenes_by_path) - covered_scenes)
    return {
        "version": 1,
        "status": "p0_scene_replacement_batches_ready",
        "boundary": (
            "Batch plan only. It orders P0 scene replacement work for manual execution; "
            "it does not edit .tscn files, approve final art or close runtime_replacement gates."
        ),
        "sources": {
            "p0_target_scene_replacement_matrix": str(MATRIX_PATH),
        },
        "summary": {
            "batch_count": len(batches),
            "scene_count": len(covered_scenes),
            "unique_asset_count": len(all_unique_assets),
            "scene_asset_reference_count": total_scene_asset_references,
            "planned_scene_asset_replacement_count": total_planned,
            "already_referenced_scene_asset_count": total_already,
            "missing_scene_count": sum(len(batch["missing_scenes"]) for batch in batches),
            "unbatched_scene_count": len(missing_matrix_scenes),
            "blocked_batch_count": sum(
                1 for batch in batches if batch["replacement_gate_status"] == "blocked_by_family_polish"
            ),
        },
        "unbatched_scenes": missing_matrix_scenes,
        "batches": batches,
    }


def write_markdown(report: dict[str, Any]) -> None:
    summary = report["summary"]
    lines = [
        "# P0 Scene Replacement Batches / P0 场景替换批次",
        "",
        "本报告把 P0 target scene replacement matrix 拆成可以逐批执行和验证的场景替换顺序。",
        "它不直接修改 `.tscn`，不关闭 `runtime_replacement` gate，也不代表最终美术批准完成。",
        "",
        "## Summary",
        "",
        f"- 批次数：`{summary['batch_count']}`",
        f"- 覆盖场景数：`{summary['scene_count']}`",
        f"- 唯一资产数：`{summary['unique_asset_count']}`",
        f"- 场景-资产引用项：`{summary['scene_asset_reference_count']}`",
        f"- 仍需替换项：`{summary['planned_scene_asset_replacement_count']}`",
        f"- 已引用项：`{summary['already_referenced_scene_asset_count']}`",
        f"- 缺失场景数：`{summary['missing_scene_count']}`",
        f"- 未分批场景数：`{summary['unbatched_scene_count']}`",
        f"- 被 family polish 阻塞的批次数：`{summary['blocked_batch_count']}`",
        "",
        "## Batches",
        "",
    ]
    for batch in report["batches"]:
        lines.append(
            f"### {batch['recommended_order']:02d}. `{batch['batch_id']}` - {batch['title']}"
        )
        lines.append("")
        lines.append(f"- 状态：`{batch['replacement_gate_status']}`")
        lines.append(f"- 目的：{batch['purpose']}")
        lines.append(
            f"- 范围：场景 `{batch['scene_count']}`，唯一资产 `{batch['unique_asset_count']}`，场景-资产引用 `{batch['scene_asset_reference_count']}`"
        )
        lines.append(f"- 仍需替换：`{batch['planned_scene_asset_replacement_count']}`，已引用：`{batch['already_referenced_scene_asset_count']}`")
        lines.append(f"- Resource types: `{json.dumps(batch['resource_type_counts'], ensure_ascii=False)}`")
        lines.append(f"- Risks: `{json.dumps(batch['risk_counts'], ensure_ascii=False)}`")
        lines.append("- 场景：" + ", ".join(f"`{scene['scene']}`" for scene in batch["scenes"]))
        lines.append("- 资产：" + ", ".join(f"`{asset['asset_id']}`" for asset in batch["assets"]))
        lines.append("- 验证：" + " | ".join(batch["validation_commands"]))
        lines.append("")
    OUT_MD.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    matrix = load_json(MATRIX_PATH)
    report = build_batches(matrix)
    write_json(OUT_JSON, report)
    write_markdown(report)
    summary = report["summary"]
    print(
        "P0 scene replacement batches built: "
        f"{summary['batch_count']} batches, "
        f"{summary['scene_count']} scenes, "
        f"{summary['unique_asset_count']} assets, "
        f"{summary['scene_asset_reference_count']} scene-asset references."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
