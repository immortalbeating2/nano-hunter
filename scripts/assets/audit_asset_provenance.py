#!/usr/bin/env python3
"""Audit source, prompt and hash provenance records for image-gen assets."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/asset-provenance-records.json"
PROJECT_KEY = "nano-hunter"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit Nano Hunter image-gen asset provenance records.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to the image-gen prompt queue.",
    )
    parser.add_argument(
        "--candidate-pool",
        default="docs/assets/imagegen-candidate-pool-report.json",
        help="Path to the image-gen candidate pool report.",
    )
    parser.add_argument(
        "--report",
        default=DEFAULT_REPORT,
        help="Path to the provenance report.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure when provenance is incomplete or inconsistent.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def audit(root: Path, queue: dict[str, Any], candidate_pool: dict[str, Any], report: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    errors: list[str] = []
    if report.get("project_key") != PROJECT_KEY:
        errors.append(f"report project_key must be {PROJECT_KEY}")
    records = {record["asset_id"]: record for record in report.get("records", [])}
    candidate_items = {item["asset_id"]: item for item in candidate_pool.get("items", [])}
    queue_items = queue.get("items", [])

    for item in queue_items:
        asset_id = item["asset_id"]
        record = records.get(asset_id)
        if not record:
            errors.append(f"{asset_id}: missing provenance record")
            continue
        if record.get("project_key") != PROJECT_KEY:
            errors.append(f"{asset_id}: project_key must be {PROJECT_KEY}")
        prompt = str(item.get("prompt", ""))
        if record.get("prompt_sha256") != sha256_text(prompt):
            errors.append(f"{asset_id}: prompt hash mismatch")
        output_path = resolve_path(root, item["output_path"])
        if not output_path.exists():
            errors.append(f"{asset_id}: output missing")
        elif record.get("output_sha256") != sha256_file(output_path):
            errors.append(f"{asset_id}: output hash mismatch")
        candidate_item = candidate_items.get(asset_id, {})
        candidates = candidate_item.get("candidates", [])
        record_candidates = record.get("candidate_hashes", [])
        if len(record_candidates) != len(candidates):
            errors.append(f"{asset_id}: candidate count mismatch")
        candidate_hashes = {candidate.get("path"): candidate.get("sha256") for candidate in candidates}
        for candidate in record_candidates:
            path = str(candidate.get("path", ""))
            if not path:
                errors.append(f"{asset_id}: empty candidate path")
                continue
            candidate_path = resolve_path(root, path)
            if not candidate_path.exists():
                errors.append(f"{asset_id}: candidate missing {path}")
                continue
            if candidate_hashes.get(path) != candidate.get("sha256"):
                errors.append(f"{asset_id}: candidate report hash mismatch {path}")
            if candidate.get("sha256") != sha256_file(candidate_path):
                errors.append(f"{asset_id}: candidate file hash mismatch {path}")
        if record.get("license_record_status") != "source_recorded_terms_review_required":
            errors.append(f"{asset_id}: unexpected license_record_status")
        if record.get("tool") != "Codex built-in image_gen":
            errors.append(f"{asset_id}: unexpected tool")

    extra_records = sorted(set(records) - {item["asset_id"] for item in queue_items})
    if extra_records:
        errors.append(f"extra provenance records: {extra_records}")

    summary = {
        "record_count": len(records),
        "queue_item_count": len(queue_items),
        "candidate_hash_count": sum(len(record.get("candidate_hashes", [])) for record in records.values()),
        "candidate_pool_count": int(candidate_pool.get("summary", {}).get("candidate_png_count", 0)),
        "output_hash_count": sum(1 for record in records.values() if record.get("output_sha256")),
        "prompt_hash_count": sum(1 for record in records.values() if record.get("prompt_sha256")),
    }
    return summary, errors


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    candidate_pool = load_json(resolve_path(root, args.candidate_pool))
    report = load_json(resolve_path(root, args.report))
    summary, errors = audit(root, queue, candidate_pool, report)

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "Asset provenance OK: "
        f"{summary['record_count']} records, "
        f"{summary['candidate_hash_count']} candidate hashes, "
        f"{summary['output_hash_count']} output hashes."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
