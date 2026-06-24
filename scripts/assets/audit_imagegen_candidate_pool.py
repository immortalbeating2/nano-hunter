#!/usr/bin/env python3
"""审计 image_gen raw candidates 与 selected sources 的使用关系。"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

from PIL import Image


PROJECT_KEY = "nano-hunter"
PROJECT_NAME = "Nano Hunter"
CANDIDATE_RE = re.compile(r"_candidate_(\d+)\.png$")
SELECTED_SOURCE_RE = re.compile(r"_c(\d+)\.png$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit image_gen candidate pool and selected-source usage.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to image-gen prompt queue.",
    )
    parser.add_argument(
        "--out",
        default="docs/assets/imagegen-candidate-pool-report.json",
        help="Report output path.",
    )
    parser.add_argument(
        "--write-report",
        action="store_true",
        help="Write the report JSON.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail when missing or invalid candidate files are found.",
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


def candidate_dir_for(root: Path, item: dict[str, Any]) -> Path:
    source_dir = resolve_path(root, item["source_dir"])
    if source_dir.name == "candidates":
        return source_dir
    return source_dir.parent / "candidates"


def selected_dir_for(root: Path, item: dict[str, Any]) -> Path | None:
    source_dir = resolve_path(root, item["source_dir"])
    if source_dir.name.startswith("selected_"):
        return source_dir
    return None


def standalone_source_record_for(root: Path, item: dict[str, Any]) -> Path:
    output_path = resolve_path(root, item["output_path"])
    return output_path.with_suffix(".source.json")


def candidate_index(path: Path) -> int | None:
    match = CANDIDATE_RE.search(path.name)
    if not match:
        return None
    return int(match.group(1))


def selected_candidate_index(path: Path) -> int | None:
    match = SELECTED_SOURCE_RE.search(path.name)
    if not match:
        return None
    return int(match.group(1))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def image_metrics(path: Path) -> dict[str, Any]:
    with Image.open(path) as image:
        image.verify()
    with Image.open(path) as image:
        return {
            "width": image.width,
            "height": image.height,
            "mode": image.mode,
        }


def read_recovery_ledgers(root: Path) -> list[dict[str, Any]]:
    ledgers: list[dict[str, Any]] = []
    inbox_root = root / "assets" / "source" / "imagegen_inbox"
    if not inbox_root.exists():
        return ledgers
    for path in sorted(inbox_root.rglob("recovery-ledger.json")):
        try:
            data = load_json(path)
        except (OSError, json.JSONDecodeError):
            continue
        items = data.get("items", data if isinstance(data, list) else [])
        ledgers.append({
            "path": path.relative_to(root).as_posix(),
            "item_count": len(items),
        })
    return ledgers


def audit_queue_item(root: Path, item: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    asset_id = item["asset_id"]
    candidate_dir = candidate_dir_for(root, item)
    selected_dir = selected_dir_for(root, item)
    errors: list[str] = []
    candidates = sorted(candidate_dir.glob(f"{asset_id}_candidate_*.png"))
    selected_paths = []
    if selected_dir and selected_dir.exists():
        selected_paths = sorted(
            path for path in selected_dir.glob("*.png")
            if "_auto_" in path.name or "_duplicate_" in path.name
        )
    standalone_source = None
    if selected_dir is None:
        source_record_path = standalone_source_record_for(root, item)
        if source_record_path.exists():
            try:
                standalone_source = load_json(source_record_path)
            except (OSError, json.JSONDecodeError) as exc:
                errors.append(f"{asset_id}: invalid standalone source record {source_record_path}: {exc}")

    candidate_entries = []
    candidate_hashes: dict[str, list[int]] = defaultdict(list)
    for path in candidates:
        index = candidate_index(path)
        if index is None:
            continue
        try:
            metrics = image_metrics(path)
            digest = sha256(path)
            candidate_hashes[digest].append(index)
            candidate_entries.append({
                "index": index,
                "path": path.relative_to(root).as_posix(),
                "sha256": digest,
                **metrics,
            })
        except Exception as exc:  # noqa: BLE001 - 报告要保留坏图原因。
            errors.append(f"{asset_id}: invalid candidate {path}: {exc}")

    selected_indices = [
        index for index in (selected_candidate_index(path) for path in selected_paths)
        if index is not None
    ]
    if standalone_source:
        if standalone_source.get("project_key") != PROJECT_KEY:
            errors.append(f"{asset_id}: standalone source record project_key must be {PROJECT_KEY}")
        if standalone_source.get("project_name") != PROJECT_NAME:
            errors.append(f"{asset_id}: standalone source record project_name must be {PROJECT_NAME}")
        if standalone_source.get("asset_id") != asset_id:
            errors.append(f"{asset_id}: standalone source record asset_id mismatch")
        candidate_index_value = standalone_source.get("candidate_index")
        if isinstance(candidate_index_value, int):
            selected_indices.append(candidate_index_value)
        else:
            errors.append(f"{asset_id}: standalone source record candidate_index must be an integer")
    selected_counter = Counter(selected_indices)
    candidate_indices = [entry["index"] for entry in candidate_entries]
    unselected_indices = [
        index for index in candidate_indices
        if selected_counter.get(index, 0) == 0
    ]
    duplicate_hash_groups = [
        indices for indices in candidate_hashes.values()
        if len(indices) > 1
    ]

    if not candidates:
        errors.append(f"{asset_id}: missing candidates in {candidate_dir}")

    entry = {
        "asset_id": asset_id,
        "batch": item.get("batch", ""),
        "target_kind": item.get("target_kind", ""),
        "candidate_dir": candidate_dir.relative_to(root).as_posix(),
        "candidate_count": len(candidate_entries),
        "candidate_indices": candidate_indices,
        "selected_dir": selected_dir.relative_to(root).as_posix() if selected_dir else None,
        "selected_source_count": len(selected_paths) + (1 if standalone_source else 0),
        "selected_candidate_indices": sorted(selected_counter),
        "selected_candidate_usage": {
            f"{index:02d}": count for index, count in sorted(selected_counter.items())
        },
        "standalone_source_record": (
            standalone_source_record_for(root, item).relative_to(root).as_posix()
            if standalone_source
            else None
        ),
        "unselected_candidate_indices": unselected_indices,
        "review_required": bool(unselected_indices or duplicate_hash_groups),
        "duplicate_candidate_hash_groups": duplicate_hash_groups,
        "candidates": candidate_entries,
    }
    return entry, errors


def build_report(root: Path, queue_path: Path) -> dict[str, Any]:
    queue = load_json(queue_path)
    items = queue["items"]
    report_items = []
    errors: list[str] = []
    candidate_total = 0
    selected_total = 0
    unselected_total = 0
    review_required_items = []
    kind_counts = Counter()
    batch_counts = Counter()

    for item in items:
        entry, item_errors = audit_queue_item(root, item)
        report_items.append(entry)
        errors.extend(item_errors)
        candidate_total += entry["candidate_count"]
        selected_total += entry["selected_source_count"]
        unselected_total += len(entry["unselected_candidate_indices"])
        kind_counts[entry["target_kind"]] += 1
        batch_counts[entry["batch"]] += entry["candidate_count"]
        if entry["review_required"]:
            review_required_items.append(entry["asset_id"])

    return {
        "version": 1,
        "status": "review_required" if review_required_items else "ready_for_selected_rebuild",
        "boundary": (
            "Candidate pool audit only. It proves raw PNG candidates exist and "
            "tracks whether selected sources already use them; it does not approve "
            "art quality or runtime replacement."
        ),
        "summary": {
            "queue_item_count": len(items),
            "candidate_png_count": candidate_total,
            "selected_source_count": selected_total,
            "unselected_candidate_count": unselected_total,
            "review_required_item_count": len(review_required_items),
            "review_required_items": review_required_items,
            "target_kind_counts": dict(sorted(kind_counts.items())),
            "candidate_batch_counts": dict(sorted(batch_counts.items())),
            "recovery_ledgers": read_recovery_ledgers(root),
            "errors": errors,
        },
        "items": report_items,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue_path = resolve_path(root, args.queue)
    report = build_report(root, queue_path)

    if args.write_report:
        out_path = resolve_path(root, args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(
            json.dumps(report, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    summary = report["summary"]
    print(
        "ImageGen candidate pool: "
        f"{summary['candidate_png_count']} candidates, "
        f"{summary['selected_source_count']} selected sources, "
        f"{summary['unselected_candidate_count']} unselected candidates, "
        f"{summary['review_required_item_count']} review-required assets."
    )
    if summary["errors"]:
        for error in summary["errors"]:
            print(f"ERROR: {error}")
        if args.strict:
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
