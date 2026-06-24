#!/usr/bin/env python3
"""Build a P0 runtime replacement plan for image-gen assets."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


RUNTIME_MAP_PATH = Path("docs/assets/asset-runtime-integration-map.json")
RUNTIME_CATALOG_PATH = Path("docs/assets/imagegen-runtime-asset-catalog-manifest.json")
ACCEPTANCE_GATES_PATH = Path("docs/assets/final-art-acceptance-gates.json")
OUT_JSON = Path("docs/assets/p0-runtime-replacement-plan.json")
OUT_MD = Path("docs/assets/p0-runtime-replacement-plan.md")


REPLACEMENT_MODES = {
    "CompressedTexture2D": "Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.",
    "Texture2D": "Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.",
    "SpriteFrames": "Assign to AnimatedSprite2D.sprite_frames after animation clip, fps and frame order review.",
    "TileSet": "Assign to TileMapLayer.tile_set after collision, terrain and hazard boundary review.",
    "StyleBoxTexture": "Apply through Theme or add_theme_stylebox_override after NinePatch margin and stretch review.",
    "AtlasTexture": "Use the selected AtlasTexture region for TextureRect/Sprite2D after semantic region review.",
}


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def res_to_path(value: str) -> Path:
    if value.startswith("res://"):
        return Path(value.removeprefix("res://"))
    return Path(value)


def catalog_by_asset(catalog: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(entry["asset_id"]): entry for entry in catalog.get("entries", [])}


def gates_by_asset(gates: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(entry["asset_id"]): entry for entry in gates.get("entries", [])}


def scene_references_resource(scene_path: Path, resource_path: str, output_path: str) -> bool:
    if not scene_path.exists():
        return False
    text = scene_path.read_text(encoding="utf-8", errors="ignore")
    tokens = {
        resource_path,
        output_path,
        "res://" + output_path.replace("\\", "/"),
    }
    return any(token and token in text for token in tokens)


def build_entry(entry: dict[str, Any], catalog_entry: dict[str, Any], gate_entry: dict[str, Any]) -> dict[str, Any]:
    asset_id = str(entry["asset_id"])
    resource_path = str(catalog_entry.get("resource_path", ""))
    output_path = str(entry.get("output_path", ""))
    resource_type = str(catalog_entry.get("catalog_resource_type") or entry.get("recommended_resource_type", "unknown"))
    target_scenes = [str(path) for path in entry.get("existing_target_scene_candidates", [])]
    target_scene_status = []
    reference_count = 0
    for scene in target_scenes:
        scene_path = res_to_path(scene)
        referenced = scene_references_resource(scene_path, resource_path, output_path)
        if referenced:
            reference_count += 1
        target_scene_status.append(
            {
                "scene": scene,
                "exists": scene_path.exists(),
                "already_references_resource": referenced,
            }
        )

    runtime_gate = gate_entry.get("gates", {}).get("runtime_replacement", {})
    family_gate = gate_entry.get("gates", {}).get("family_specific_polish", {})
    return {
        "asset_id": asset_id,
        "priority": entry.get("priority", "unknown"),
        "track": entry.get("track", "unknown"),
        "target_kind": entry.get("target_kind", "unknown"),
        "target_system": entry.get("target_system", "unknown"),
        "recommended_resource_type": entry.get("recommended_resource_type", "unknown"),
        "catalog_resource_type": resource_type,
        "resource_path": resource_path,
        "output_path": output_path,
        "resource_exists": res_to_path(resource_path).exists(),
        "output_exists": Path(output_path).exists(),
        "replacement_mode": REPLACEMENT_MODES.get(resource_type, "Manual Godot resource assignment required."),
        "target_scene_status": target_scene_status,
        "target_scene_count": len(target_scene_status),
        "current_scene_reference_count": reference_count,
        "runtime_replacement_status": "already_referenced" if reference_count > 0 else "planned_manual_replacement",
        "runtime_gate_blockers": runtime_gate.get("blockers", []),
        "family_polish_blockers": family_gate.get("blockers", []),
        "validation_commands": [
            "godot --headless --path . --import",
            "python scripts\\assets\\audit_asset_package.py --strict --write-report",
            "Use the closest Stage / HUD / room GUT after replacing the target scene reference.",
        ],
    }


def summarize(entries: list[dict[str, Any]]) -> dict[str, Any]:
    track_counts: dict[str, int] = {}
    resource_type_counts: dict[str, int] = {}
    planned_count = 0
    referenced_count = 0
    missing_resources: list[str] = []
    missing_targets: list[str] = []
    for entry in entries:
        track = str(entry["track"])
        resource_type = str(entry["catalog_resource_type"])
        track_counts[track] = track_counts.get(track, 0) + 1
        resource_type_counts[resource_type] = resource_type_counts.get(resource_type, 0) + 1
        if entry["runtime_replacement_status"] == "already_referenced":
            referenced_count += 1
        else:
            planned_count += 1
        if not entry["resource_exists"] or not entry["output_exists"]:
            missing_resources.append(str(entry["asset_id"]))
        for scene in entry["target_scene_status"]:
            if not scene["exists"]:
                missing_targets.append(f"{entry['asset_id']}:{scene['scene']}")
    return {
        "asset_count": len(entries),
        "planned_manual_replacement_count": planned_count,
        "already_referenced_count": referenced_count,
        "missing_resource_count": len(missing_resources),
        "missing_target_scene_count": len(missing_targets),
        "track_counts": dict(sorted(track_counts.items())),
        "resource_type_counts": dict(sorted(resource_type_counts.items())),
        "missing_resources": missing_resources,
        "missing_target_scenes": missing_targets,
    }


def write_markdown(report: dict[str, Any]) -> None:
    summary = report["summary"]
    lines = [
        "# P0 Runtime Replacement Plan / P0 运行时替换计划",
        "",
        "本计划只覆盖 runtime map 中 priority 为 `P0` 的资产条目，用于关闭 `runtime_replacement` gate 前的执行排程。",
        "它不直接替换场景引用，也不代表 final art 已批准。",
        "",
        "## Summary",
        "",
        f"- P0 runtime entries：`{summary['asset_count']}`",
        f"- 仍需手动替换：`{summary['planned_manual_replacement_count']}`",
        f"- 当前已被目标场景引用：`{summary['already_referenced_count']}`",
        f"- 缺失资源：`{summary['missing_resource_count']}`",
        f"- 缺失目标场景：`{summary['missing_target_scene_count']}`",
        "",
        "## Entries",
        "",
    ]
    for entry in report["entries"]:
        lines.append(
            f"- [ ] `{entry['asset_id']}` ({entry['track']} / {entry['target_kind']} / {entry['catalog_resource_type']})"
        )
        lines.append(f"  - Target system: {entry['target_system']}")
        lines.append(f"  - Resource: `{entry['resource_path']}`")
        lines.append(f"  - Mode: {entry['replacement_mode']}")
        lines.append(f"  - Status: `{entry['runtime_replacement_status']}`")
        target_scenes = ", ".join(f"`{scene['scene']}`" for scene in entry["target_scene_status"])
        lines.append(f"  - Target scenes: {target_scenes}")
        if entry["family_polish_blockers"]:
            lines.append(f"  - Polish blockers: {', '.join(entry['family_polish_blockers'])}")
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    runtime_map = load_json(RUNTIME_MAP_PATH)
    runtime_catalog = load_json(RUNTIME_CATALOG_PATH)
    gates = load_json(ACCEPTANCE_GATES_PATH)
    catalog_entries = catalog_by_asset(runtime_catalog)
    gate_entries = gates_by_asset(gates)

    entries = [
        build_entry(entry, catalog_entries[str(entry["asset_id"])], gate_entries[str(entry["asset_id"])])
        for entry in runtime_map.get("entries", [])
        if entry.get("priority") == "P0"
    ]
    report = {
        "version": 1,
        "status": "p0_runtime_replacement_plan_ready",
        "boundary": "Planning report only. It maps P0 image-gen assets to target scenes and replacement modes; it does not replace runtime scene references or approve final art.",
        "sources": {
            "runtime_map": str(RUNTIME_MAP_PATH),
            "runtime_catalog": str(RUNTIME_CATALOG_PATH),
            "acceptance_gates": str(ACCEPTANCE_GATES_PATH),
        },
        "summary": summarize(entries),
        "entries": entries,
    }
    write_json(OUT_JSON, report)
    write_markdown(report)
    print(
        "P0 runtime replacement plan built: "
        f"{report['summary']['asset_count']} entries, "
        f"{report['summary']['planned_manual_replacement_count']} planned replacements, "
        f"{report['summary']['already_referenced_count']} already referenced."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
