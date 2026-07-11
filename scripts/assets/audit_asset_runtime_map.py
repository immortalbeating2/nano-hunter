#!/usr/bin/env python3
"""Audit runtime/release integration map coverage for image-gen assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/asset-runtime-integration-map.json"

ALLOWED_INTEGRATION_STATUSES = {
    "binding_map_ready_manual_replacement_required",
    "scene_reference_verified",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit Nano Hunter image-gen runtime/release integration map.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to the image-gen prompt queue.",
    )
    parser.add_argument(
        "--report",
        default=DEFAULT_REPORT,
        help="Path to the runtime integration map.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure when integration map coverage is incomplete.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    report = load_json(resolve_path(root, args.report))
    queue_ids = {item["asset_id"] for item in queue.get("items", [])}
    entries = {entry["asset_id"]: entry for entry in report.get("entries", [])}

    errors: list[str] = []
    missing = sorted(queue_ids - set(entries))
    extra = sorted(set(entries) - queue_ids)
    if missing:
        errors.append(f"missing integration map entries: {missing}")
    if extra:
        errors.append(f"extra integration map entries: {extra}")

    for asset_id, entry in entries.items():
        if not entry.get("track"):
            errors.append(f"{asset_id}: empty track")
        if not entry.get("target_system"):
            errors.append(f"{asset_id}: empty target_system")
        if not entry.get("recommended_resource_type"):
            errors.append(f"{asset_id}: empty recommended_resource_type")
        output_path = resolve_path(root, str(entry.get("output_path", "")))
        if not output_path.exists():
            errors.append(f"{asset_id}: output_path missing")
        if not entry.get("output_sha256"):
            errors.append(f"{asset_id}: missing output_sha256")
        target_scenes = entry.get("target_scene_candidates", [])
        if not target_scenes:
            errors.append(f"{asset_id}: no target_scene_candidates")
        existing_scenes = entry.get("existing_target_scene_candidates", [])
        if not existing_scenes:
            errors.append(f"{asset_id}: no existing target scene candidates")
        for scene in existing_scenes:
            if not resolve_path(root, str(scene)).exists():
                errors.append(f"{asset_id}: declared existing scene missing {scene}")
        status = str(entry.get("integration_status", ""))
        if status not in ALLOWED_INTEGRATION_STATUSES:
            errors.append(f"{asset_id}: unexpected integration_status {status}")
        direct_references = entry.get("direct_scene_references", [])
        if status == "scene_reference_verified" and not direct_references:
            errors.append(f"{asset_id}: scene_reference_verified without direct_scene_references")
        for scene in direct_references:
            if scene not in existing_scenes:
                errors.append(f"{asset_id}: direct scene reference not in existing candidates {scene}")
            scene_text = resolve_path(root, str(scene)).read_text(encoding="utf-8")
            output_res_path = "res://" + str(entry.get("output_path", "")).replace("\\", "/")
            if asset_id not in scene_text and output_res_path not in scene_text:
                errors.append(f"{asset_id}: direct scene reference missing asset id or path in {scene}")

    summary = report.get("summary", {})
    if int(summary.get("entry_count", -1)) != len(queue_ids):
        errors.append("entry_count must match queue item count")
    if int(summary.get("missing_output_count", -1)) != 0:
        errors.append("missing_output_count must be 0")
    if int(summary.get("missing_target_scene_candidate_count", -1)) != 0:
        errors.append("missing_target_scene_candidate_count must be 0")
    status_counts = summary.get("status_counts", {})
    if int(summary.get("directly_referenced_entry_count", -1)) != int(status_counts.get("scene_reference_verified", -2)):
        errors.append("directly_referenced_entry_count must match scene_reference_verified status count")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "Asset runtime map OK: "
        f"{len(entries)} entries, "
        f"{len(summary.get('track_counts', {}))} tracks."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
