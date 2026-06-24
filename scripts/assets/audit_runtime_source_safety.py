#!/usr/bin/env python3
"""Audit runtime-bound image_gen assets against selected source safety."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_REPORT = Path("docs/assets/runtime-source-safety-report.json")
DEFAULT_MARKDOWN = Path("docs/assets/runtime-source-safety-report.md")
CONFIRMED_STATUSES = {"project_session_confirmed", "explicit_mapping_confirmed"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit Nano Hunter runtime asset references against image_gen source safety.",
    )
    parser.add_argument(
        "--runtime-plan",
        default="docs/assets/p0-runtime-replacement-plan.json",
        help="Path to P0 runtime replacement plan.",
    )
    parser.add_argument(
        "--source-safety",
        default="docs/assets/imagegen-source-safety-report.json",
        help="Path to image_gen source safety report.",
    )
    parser.add_argument(
        "--provenance",
        default="docs/assets/asset-provenance-records.json",
        help="Path to asset provenance records.",
    )
    parser.add_argument("--out", default=str(DEFAULT_REPORT), help="JSON report output path.")
    parser.add_argument("--md", default=str(DEFAULT_MARKDOWN), help="Markdown report output path.")
    parser.add_argument("--write-report", action="store_true", help="Write JSON and Markdown reports.")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail when runtime-bound assets use unconfirmed selected sources.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str | Path) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def candidate_index(path: str) -> int | None:
    match = re.search(r"_candidate_(\d+)\.png$", path)
    if not match:
        return None
    return int(match.group(1))


def build_source_lookup(source_safety: dict[str, Any]) -> dict[str, dict[str, Any]]:
    lookup: dict[str, dict[str, Any]] = {}
    for item in source_safety.get("items", []):
        asset_id = str(item.get("asset_id", ""))
        by_index: dict[int, dict[str, Any]] = {}
        statuses: list[str] = []
        for candidate in item.get("candidates", []):
            path = str(candidate.get("path", ""))
            index = candidate_index(path)
            status = str(candidate.get("status", "unknown_or_unsafe"))
            statuses.append(status)
            if index is not None:
                by_index[index] = {
                    "path": path,
                    "status": status,
                    "reasons": candidate.get("reasons", []),
                }
        lookup[asset_id] = {
            "candidate_count": int(item.get("candidate_count", 0)),
            "statuses": statuses,
            "by_index": by_index,
        }
    return lookup


def build_provenance_lookup(provenance: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {
        str(record.get("asset_id", "")): record
        for record in provenance.get("records", [])
        if record.get("asset_id")
    }


def selected_status(asset_id: str, source: dict[str, Any], provenance: dict[str, Any]) -> dict[str, Any]:
    selected_indices = [int(index) for index in provenance.get("selected_candidate_indices", [])]
    all_statuses = list(source.get("statuses", []))
    by_index = source.get("by_index", {})
    project_candidate_count = sum(1 for status in all_statuses if status in CONFIRMED_STATUSES)
    unsafe_candidate_count = sum(1 for status in all_statuses if status == "unknown_or_unsafe")

    if unsafe_candidate_count:
        return {
            "status": "unsafe_candidate_present",
            "selected_candidate_indices": selected_indices,
            "selected_candidate_statuses": [],
            "project_session_candidate_count": project_candidate_count,
            "reason": "one or more candidates are unknown_or_unsafe",
        }

    if selected_indices:
        selected_reports = [by_index.get(index, {"status": "missing_from_source_safety"}) for index in selected_indices]
        selected_candidate_statuses = [str(report.get("status", "missing_from_source_safety")) for report in selected_reports]
        if all(status in CONFIRMED_STATUSES for status in selected_candidate_statuses):
            status = "selected_source_confirmed"
        elif any(status == "missing_from_source_safety" for status in selected_candidate_statuses):
            status = "selected_source_unknown"
        else:
            status = "selected_source_review_required"
        return {
            "status": status,
            "selected_candidate_indices": selected_indices,
            "selected_candidate_statuses": selected_candidate_statuses,
            "project_session_candidate_count": project_candidate_count,
            "reason": "selected candidate indices are recorded in provenance",
        }

    if int(source.get("candidate_count", 0)) == 1 and project_candidate_count == 1:
        return {
            "status": "single_candidate_confirmed",
            "selected_candidate_indices": [],
            "selected_candidate_statuses": all_statuses,
            "project_session_candidate_count": project_candidate_count,
            "reason": "single available candidate is project-session confirmed",
        }

    if project_candidate_count:
        return {
            "status": "project_candidate_exists_output_derivation_unverified",
            "selected_candidate_indices": [],
            "selected_candidate_statuses": all_statuses,
            "project_session_candidate_count": project_candidate_count,
            "reason": "project-session candidate exists, but current output does not record selected source",
        }

    return {
        "status": "runtime_source_review_required",
        "selected_candidate_indices": [],
        "selected_candidate_statuses": all_statuses,
        "project_session_candidate_count": project_candidate_count,
        "reason": "no selected source is recorded and no project-session-confirmed candidate proves the output",
    }


def runtime_gate_status(entry: dict[str, Any], source_status: str) -> str:
    referenced = int(entry.get("current_scene_reference_count", 0)) > 0
    planned = str(entry.get("runtime_replacement_status", "")) == "planned_manual_replacement"
    confirmed = source_status in {"selected_source_confirmed", "single_candidate_confirmed"}
    unverified = source_status == "project_candidate_exists_output_derivation_unverified"
    if referenced and confirmed:
        return "runtime_reference_source_confirmed"
    if referenced and unverified:
        return "runtime_reference_derivation_review_required"
    if referenced:
        return "runtime_reference_source_review_required"
    if planned and confirmed:
        return "planned_replacement_source_confirmed"
    if planned and unverified:
        return "planned_replacement_derivation_review_required"
    if planned:
        return "planned_replacement_source_review_required"
    return "not_runtime_bound"


def build_report(root: Path, runtime_plan_path: Path, source_safety_path: Path, provenance_path: Path) -> dict[str, Any]:
    runtime_plan = load_json(runtime_plan_path)
    source_safety = load_json(source_safety_path)
    provenance = load_json(provenance_path)
    source_lookup = build_source_lookup(source_safety)
    provenance_lookup = build_provenance_lookup(provenance)

    errors: list[str] = []
    if source_safety.get("project_key") != PROJECT_KEY:
        errors.append(f"source safety project_key must be {PROJECT_KEY}")
    if provenance.get("project_key") != PROJECT_KEY:
        errors.append(f"provenance project_key must be {PROJECT_KEY}")

    items: list[dict[str, Any]] = []
    counts: dict[str, int] = {}
    source_counts: dict[str, int] = {}
    for entry in runtime_plan.get("entries", []):
        asset_id = str(entry.get("asset_id", ""))
        source = source_lookup.get(asset_id, {"candidate_count": 0, "statuses": [], "by_index": {}})
        record = provenance_lookup.get(asset_id, {})
        selected = selected_status(asset_id, source, record)
        gate = runtime_gate_status(entry, selected["status"])
        counts[gate] = counts.get(gate, 0) + 1
        source_counts[selected["status"]] = source_counts.get(selected["status"], 0) + 1
        items.append(
            {
                "asset_id": asset_id,
                "resource_path": entry.get("resource_path", ""),
                "runtime_replacement_status": entry.get("runtime_replacement_status", ""),
                "current_scene_reference_count": int(entry.get("current_scene_reference_count", 0)),
                "source_status": selected["status"],
                "runtime_source_gate": gate,
                "selected_candidate_indices": selected["selected_candidate_indices"],
                "selected_candidate_statuses": selected["selected_candidate_statuses"],
                "project_session_candidate_count": selected["project_session_candidate_count"],
                "reason": selected["reason"],
                "target_scenes": [
                    scene.get("scene", "")
                    for scene in entry.get("target_scene_status", [])
                    if scene.get("already_references_resource")
                ],
            }
        )

    runtime_review_items = [
        item["asset_id"]
        for item in items
        if item["runtime_source_gate"]
        in {
            "runtime_reference_source_review_required",
            "runtime_reference_derivation_review_required",
            "planned_replacement_source_review_required",
            "planned_replacement_derivation_review_required",
        }
    ]
    unsafe_items = [item["asset_id"] for item in items if item["source_status"] == "unsafe_candidate_present"]
    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "unsafe_source_found" if unsafe_items else "runtime_source_review_required" if runtime_review_items else "runtime_sources_confirmed",
        "boundary": (
            "Runtime source safety audit for P0 image_gen assets. It checks whether assets already referenced "
            "by Godot scenes, or planned for immediate replacement, are backed by selected project-session-confirmed "
            "sources. It does not judge visual quality, animation polish, license terms or final approval."
        ),
        "sources": {
            "runtime_plan": runtime_plan_path.relative_to(root).as_posix(),
            "source_safety": source_safety_path.relative_to(root).as_posix(),
            "provenance": provenance_path.relative_to(root).as_posix(),
        },
        "summary": {
            "runtime_asset_count": len(items),
            "runtime_source_gate_counts": dict(sorted(counts.items())),
            "source_status_counts": dict(sorted(source_counts.items())),
            "runtime_review_required_count": len(runtime_review_items),
            "runtime_review_required_items": runtime_review_items,
            "unsafe_item_count": len(unsafe_items),
            "unsafe_items": unsafe_items,
            "errors": errors,
        },
        "items": items,
    }


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    summary = report["summary"]
    lines = [
        "# Runtime Source Safety Report",
        "",
        "This report blocks multi-project image_gen mix-ups for Nano Hunter runtime assets.",
        "",
        "## Summary",
        "",
        f"- Status: `{report['status']}`",
        f"- Runtime assets: `{summary['runtime_asset_count']}`",
        f"- Review-required runtime assets: `{summary['runtime_review_required_count']}`",
        f"- Unsafe assets: `{summary['unsafe_item_count']}`",
        "",
        "## Runtime Gate Counts",
        "",
    ]
    for key, value in summary["runtime_source_gate_counts"].items():
        lines.append(f"- `{key}`: `{value}`")
    lines.extend(["", "## Review Required", ""])
    review_items = [
        item
        for item in report["items"]
        if item["asset_id"] in set(summary["runtime_review_required_items"])
    ]
    if not review_items:
        lines.append("- None")
    else:
        for item in review_items:
            scenes = ", ".join(item["target_scenes"]) if item["target_scenes"] else "not referenced yet"
            lines.append(
                f"- `{item['asset_id']}`: `{item['runtime_source_gate']}`; "
                f"source `{item['source_status']}`; scenes `{scenes}`; reason: {item['reason']}"
            )
    lines.extend(
        [
            "",
            "## Policy",
            "",
            "- `runtime_reference_source_confirmed` assets may stay in preview/runtime binding.",
            "- `runtime_reference_derivation_review_required` assets must be treated as temporary preview until selected-source derivation is recorded or regenerated.",
            "- `runtime_reference_source_review_required` assets must not be described as final runtime art; regenerate or manually confirm before final binding.",
            "- `planned_replacement_*_review_required` assets must be fixed before being newly bound into scenes.",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(
        root,
        resolve_path(root, args.runtime_plan),
        resolve_path(root, args.source_safety),
        resolve_path(root, args.provenance),
    )
    if args.write_report:
        out_path = resolve_path(root, args.out)
        md_path = resolve_path(root, args.md)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        md_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_markdown(md_path, report)

    summary = report["summary"]
    for error in summary.get("errors", []):
        print(error)
    print(
        "Runtime source safety: "
        f"{summary['runtime_asset_count']} runtime assets, "
        f"{summary['runtime_review_required_count']} review-required, "
        f"{summary['unsafe_item_count']} unsafe."
    )
    if args.strict and (summary["runtime_review_required_count"] or summary["unsafe_item_count"] or summary.get("errors")):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
