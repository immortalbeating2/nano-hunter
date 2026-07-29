#!/usr/bin/env python3
"""Audit FP-03 TileSet semantic and collision-readiness rules."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_JSON_REPORT = "docs/assets/final-art-polish-fp03-tileset-review-report.json"
DEFAULT_MD_REPORT = "docs/assets/final-art-polish-fp03-tileset-review-report.md"

TILESET_TARGETS = [
    {
        "asset_id": "miasma_marsh_tileset_ai01",
        "rules": "assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset_rules.json",
        "requires_hazard_visuals": True,
    },
    {
        "asset_id": "shrine_trial_tileset_ai01",
        "rules": "assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset_rules.json",
        "requires_hazard_visuals": False,
    },
]

EXPECTED_TILE_COUNT = 48
EXPECTED_TILE_SIZE = [64, 64]
VISUAL_ONLY_ROLES = {"decorative_visual_only", "hazard_visual_only", "unclassified_visual_only"}
COLLISION_ROLES = {"solid", "one_way_platform"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit FP-03 TileSet semantics.")
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--json-report", default=DEFAULT_JSON_REPORT)
    parser.add_argument("--md-report", default=DEFAULT_MD_REPORT)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit_rules(root: Path, target: dict[str, Any]) -> dict[str, Any]:
    rules_path = root / str(target["rules"])
    errors: list[str] = []
    warnings: list[str] = []

    data: dict[str, Any] = {}
    if not rules_path.exists():
        errors.append("rules_missing")
    else:
        data = load_json(rules_path)

    counts = data.get("counts", {})
    rules = data.get("rules", [])
    if data and data.get("asset_id") != target["asset_id"]:
        errors.append("asset_id_mismatch")
    if data and data.get("tile_count") != EXPECTED_TILE_COUNT:
        errors.append("tile_count_mismatch")
    if data and data.get("tile_size") != EXPECTED_TILE_SIZE:
        errors.append("tile_size_mismatch")
    if data and len(rules) != data.get("tile_count"):
        errors.append("rules_tile_count_mismatch")
    if data and data.get("physics_layer_count", 0) < 1:
        errors.append("physics_layer_missing")
    if data and data.get("terrain_set_count", 0) < 1:
        errors.append("terrain_set_missing")
    if counts.get("solid", 0) < 1:
        errors.append("solid_tiles_missing")
    if counts.get("one_way_platform", 0) < 1:
        errors.append("one_way_tiles_missing")
    if counts.get("unclassified_visual_only", 0) != 0:
        errors.append("unclassified_tiles_present")
    if target["requires_hazard_visuals"] and counts.get("hazard_visual_only", 0) < 1:
        errors.append("hazard_visual_tiles_missing")
    if data and not data.get("manual_review_required", False):
        warnings.append("tileset_not_marked_manual_review")

    role_counts: dict[str, int] = {}
    semantic_names: list[str] = []
    for rule in rules:
        role = str(rule.get("collision_role", ""))
        role_counts[role] = role_counts.get(role, 0) + 1
        semantic_name = str(rule.get("semantic_name", ""))
        semantic_names.append(semantic_name)

        collision_count = int(rule.get("collision_polygon_count", 0))
        notes = set(str(note) for note in rule.get("notes", []))
        if not rule.get("manual_review_required", False):
            warnings.append(f"{semantic_name}:rule_not_marked_manual_review")
        if role in COLLISION_ROLES and collision_count != 1:
            errors.append(f"{semantic_name}:collision_polygon_count_not_one")
        if role in VISUAL_ONLY_ROLES and collision_count != 0:
            errors.append(f"{semantic_name}:visual_only_has_collision")
        if role == "hazard_visual_only" and "damage_area_must_be_authored_in_runtime_scene" not in notes:
            errors.append(f"{semantic_name}:hazard_runtime_area_note_missing")
        if role in {"decorative_visual_only", "hazard_visual_only"} and "no_physics_collision" not in notes:
            warnings.append(f"{semantic_name}:visual_only_no_physics_note_missing")

    if semantic_names and len(set(semantic_names)) != len(semantic_names):
        errors.append("duplicate_semantic_names")

    return {
        "asset_id": target["asset_id"],
        "status": "tileset_semantics_ready" if not errors else "blocked",
        "rules": target["rules"],
        "tileset_resource": data.get("tileset_resource", ""),
        "tile_count": data.get("tile_count", 0),
        "tile_size": data.get("tile_size", []),
        "physics_layer_count": data.get("physics_layer_count", 0),
        "terrain_set_count": data.get("terrain_set_count", 0),
        "counts": counts,
        "role_counts_from_rules": role_counts,
        "requires_hazard_visuals": target["requires_hazard_visuals"],
        "manual_review_required": bool(data.get("manual_review_required", False)),
        "boundary": data.get("boundary", ""),
        "sample_semantic_names": semantic_names[:8],
        "errors": errors,
        "warnings": warnings,
    }


def build_report(root: Path) -> dict[str, Any]:
    tilesets = [audit_rules(root, target) for target in TILESET_TARGETS]
    errors = [
        f"{tileset['asset_id']}:{error}"
        for tileset in tilesets
        for error in tileset.get("errors", [])
    ]
    warnings = [
        f"{tileset['asset_id']}:{warning}"
        for tileset in tilesets
        for warning in tileset.get("warnings", [])
    ]
    return {
        "version": 1,
        "status": "ok" if not errors else "blocked",
        "boundary": (
            "FP-03 TileSet semantic and collision-readiness audit. Passing means current TileSet rules "
            "are coherent for conservative editor use; it does not approve final autotile painting, "
            "hand-fitted collision polygons, or runtime hazard damage Areas."
        ),
        "summary": {
            "tileset_count": len(tilesets),
            "ready_count": sum(1 for tileset in tilesets if tileset.get("status") == "tileset_semantics_ready"),
            "error_count": len(errors),
            "warning_count": len(warnings),
        },
        "tilesets": tilesets,
        "errors": errors,
        "warnings": warnings,
    }


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    lines = [
        "# Final Art Polish FP-03 TileSet Review Report",
        "",
        f"- Status: `{report['status']}`",
        f"- TileSets: `{report['summary']['tileset_count']}`",
        f"- Ready: `{report['summary']['ready_count']}`",
        f"- Errors: `{report['summary']['error_count']}`",
        f"- Warnings: `{report['summary']['warning_count']}`",
        "",
        "## TileSets",
        "",
    ]
    for tileset in report["tilesets"]:
        lines.extend([
            f"### {tileset['asset_id']}",
            "",
            f"- Status: `{tileset['status']}`",
            f"- Rules: `{tileset['rules']}`",
            f"- TileSet resource: `{tileset['tileset_resource']}`",
            f"- Tile count / size: `{tileset['tile_count']}` / `{tileset['tile_size']}`",
            f"- Physics layers / terrain sets: `{tileset['physics_layer_count']}` / `{tileset['terrain_set_count']}`",
            f"- Counts: `{tileset['counts']}`",
            f"- Boundary: {tileset['boundary']}",
            f"- Sample semantics: `{', '.join(tileset.get('sample_semantic_names', []))}`",
        ])
        if tileset.get("errors"):
            lines.append(f"- Errors: `{tileset['errors']}`")
        if tileset.get("warnings"):
            lines.append(f"- Warnings: `{tileset['warnings']}`")
        lines.append("")
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
        "FP-03 tileset semantics audit: "
        f"{report['summary']['ready_count']}/{report['summary']['tileset_count']} ready, "
        f"{report['summary']['error_count']} errors, "
        f"{report['summary']['warning_count']} warnings."
    )
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
