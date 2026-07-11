#!/usr/bin/env python3
"""Audit FP-02 atlas / large-sheet semantic split readiness."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_JSON_REPORT = "docs/assets/final-art-polish-fp02-atlas-split-report.json"
DEFAULT_MD_REPORT = "docs/assets/final-art-polish-fp02-atlas-split-report.md"

ATLAS_TARGETS = [
    {
        "asset_id": "shrine_gate_prop_atlas_ai01",
        "kind": "prop_atlas",
        "output": "assets/art/atlases/shrine_gate_prop_atlas_ai01.png",
        "regions": "assets/art/atlases/shrine_gate_prop_atlas_ai01.regions.json",
        "semantics": "assets/art/atlases/shrine_gate_prop_atlas_ai01.semantics.json",
        "editor_dir": "assets/art/editor_resources/shrine_gate_prop_atlas_ai01",
    },
    {
        "asset_id": "equipment_pickup_atlas_ai01",
        "kind": "equipment_atlas",
        "output": "assets/art/atlases/equipment_pickup_atlas_ai01.png",
        "regions": "assets/art/atlases/equipment_pickup_atlas_ai01.regions.json",
        "semantics": "assets/art/atlases/equipment_pickup_atlas_ai01.semantics.json",
        "editor_dir": "assets/art/editor_resources/equipment_pickup_atlas_ai01",
    },
    {
        "asset_id": "material_texture_atlas_ai01",
        "kind": "texture_atlas",
        "output": "assets/art/textures/material_texture_atlas_ai01.png",
        "regions": "assets/art/textures/material_texture_atlas_ai01.regions.json",
        "semantics": "assets/art/textures/material_texture_atlas_ai01.semantics.json",
        "editor_dir": "assets/art/editor_resources/material_texture_atlas_ai01",
    },
]

STANDALONE_TARGETS = [
    {
        "asset_id": "reusable_seal_props_ai01",
        "kind": "prop_sheet",
        "output": "assets/art/props/reusable_seal_props_ai01.png",
        "runtime_catalog_status": "standalone_texture_preview",
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit FP-02 atlas split readiness.")
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--json-report", default=DEFAULT_JSON_REPORT)
    parser.add_argument("--md-report", default=DEFAULT_MD_REPORT)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def atlas_texture_files(path: Path) -> list[str]:
    if not path.exists():
        return []
    return sorted(file.name for file in path.glob("*.tres"))


def audit_atlas(root: Path, target: dict[str, str]) -> dict[str, Any]:
    output_path = root / target["output"]
    regions_path = root / target["regions"]
    semantics_path = root / target["semantics"]
    editor_dir = root / target["editor_dir"]
    errors: list[str] = []
    warnings: list[str] = []

    regions = load_json(regions_path) if regions_path.exists() else {}
    semantics = load_json(semantics_path) if semantics_path.exists() else {}
    frames = regions.get("frames", [])
    semantic_entries = semantics.get("entries", [])
    editor_files = atlas_texture_files(editor_dir)

    if not output_path.exists():
        errors.append("output_missing")
    if not regions_path.exists():
        errors.append("regions_missing")
    if not semantics_path.exists():
        errors.append("semantics_missing")
    if not editor_files:
        errors.append("editor_atlas_textures_missing")
    if frames and semantic_entries and len(frames) != len(semantic_entries):
        errors.append("regions_semantics_count_mismatch")
    if frames and editor_files and len(frames) != len(editor_files):
        errors.append("regions_editor_texture_count_mismatch")

    semantic_names = [str(entry.get("semantic_name", "")) for entry in semantic_entries]
    if semantic_names and len(set(semantic_names)) != len(semantic_names):
        warnings.append("duplicate_semantic_names")

    return {
        "asset_id": target["asset_id"],
        "kind": target["kind"],
        "status": "split_ready" if not errors else "blocked",
        "output": target["output"],
        "regions": target["regions"],
        "semantics": target["semantics"],
        "editor_dir": target["editor_dir"],
        "region_count": len(frames),
        "semantic_count": len(semantic_entries),
        "editor_atlas_texture_count": len(editor_files),
        "sample_semantic_names": semantic_names[:8],
        "manual_review_required": bool(semantics.get("manual_review_required", False)),
        "errors": errors,
        "warnings": warnings,
    }


def audit_standalone(root: Path, target: dict[str, str]) -> dict[str, Any]:
    output_path = root / target["output"]
    errors: list[str] = []
    if not output_path.exists():
        errors.append("output_missing")
    return {
        "asset_id": target["asset_id"],
        "kind": target["kind"],
        "status": "standalone_preview_ready" if not errors else "blocked",
        "output": target["output"],
        "runtime_catalog_status": target["runtime_catalog_status"],
        "split_policy": "No atlas split is required for current visual preview use; add regions only when individual prop runtime use is needed.",
        "errors": errors,
        "warnings": [],
    }


def build_report(root: Path) -> dict[str, Any]:
    atlas_reports = [audit_atlas(root, target) for target in ATLAS_TARGETS]
    standalone_reports = [audit_standalone(root, target) for target in STANDALONE_TARGETS]
    assets = atlas_reports + standalone_reports
    errors = [
        f"{asset['asset_id']}:{error}"
        for asset in assets
        for error in asset.get("errors", [])
    ]
    warnings = [
        f"{asset['asset_id']}:{warning}"
        for asset in assets
        for warning in asset.get("warnings", [])
    ]
    return {
        "version": 1,
        "status": "ok" if not errors else "blocked",
        "boundary": (
            "FP-02 atlas / large-sheet semantic split audit. Passing means existing region, semantic, "
            "and editor AtlasTexture resources are coherent enough for controlled runtime use; it does not "
            "replace human art-quality review."
        ),
        "summary": {
            "asset_count": len(assets),
            "split_ready_count": sum(1 for asset in assets if asset.get("status") == "split_ready"),
            "standalone_preview_ready_count": sum(1 for asset in assets if asset.get("status") == "standalone_preview_ready"),
            "error_count": len(errors),
            "warning_count": len(warnings),
        },
        "assets": assets,
        "errors": errors,
        "warnings": warnings,
    }


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    lines = [
        "# Final Art Polish FP-02 Atlas Split Report",
        "",
        f"- Status: `{report['status']}`",
        f"- Assets: `{report['summary']['asset_count']}`",
        f"- Split-ready atlases: `{report['summary']['split_ready_count']}`",
        f"- Standalone preview-ready sheets: `{report['summary']['standalone_preview_ready_count']}`",
        "",
        "## Assets",
        "",
    ]
    for asset in report["assets"]:
        lines.extend([
            f"### {asset['asset_id']}",
            "",
            f"- Kind: `{asset['kind']}`",
            f"- Status: `{asset['status']}`",
            f"- Output: `{asset['output']}`",
        ])
        if asset.get("region_count") is not None:
            lines.extend([
                f"- Regions: `{asset['region_count']}`",
                f"- Semantic entries: `{asset['semantic_count']}`",
                f"- Editor AtlasTextures: `{asset['editor_atlas_texture_count']}`",
                f"- Sample semantics: `{', '.join(asset.get('sample_semantic_names', []))}`",
            ])
        if asset.get("split_policy"):
            lines.append(f"- Split policy: {asset['split_policy']}")
        if asset.get("errors"):
            lines.append(f"- Errors: `{asset['errors']}`")
        if asset.get("warnings"):
            lines.append(f"- Warnings: `{asset['warnings']}`")
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
        "FP-02 atlas split audit: "
        f"{report['summary']['split_ready_count']} split-ready atlases, "
        f"{report['summary']['standalone_preview_ready_count']} standalone preview-ready sheets, "
        f"{report['summary']['error_count']} errors."
    )
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
