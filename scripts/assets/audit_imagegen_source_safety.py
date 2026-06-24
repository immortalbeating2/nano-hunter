#!/usr/bin/env python3
"""Audit image_gen candidate source safety for multi-project Codex usage."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/imagegen-source-safety-report.json"
PROJECT_KEY = "nano-hunter"
NANO_HUNTER_PROMPT_ANCHORS = (
    "Nano Hunter",
    "Luna",
    "Seal Guardian",
    "Buddhist",
    "talisman",
    "miasma",
    "shrine",
    "Shanhaijing",
    "metroidvania",
    "demon-suppressing",
    "Northern and Southern Dynasties",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit Nano Hunter image_gen candidate source safety.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to image-gen prompt queue.",
    )
    parser.add_argument(
        "--candidate-pool",
        default="docs/assets/imagegen-candidate-pool-report.json",
        help="Path to image-gen candidate pool report.",
    )
    parser.add_argument(
        "--provenance",
        default="docs/assets/asset-provenance-records.json",
        help="Path to asset provenance records.",
    )
    parser.add_argument(
        "--out",
        default=DEFAULT_REPORT,
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
        help="Fail when unsafe or missing source evidence is found.",
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


def normalize_rel(path: str | Path) -> str:
    return Path(path).as_posix()


def read_session_recovery_paths(root: Path) -> set[str]:
    paths: set[str] = set()
    for summary_path in sorted((root / "assets/source/ai_generated").glob("session_recovery_*.json")):
        try:
            data = load_json(summary_path)
        except (OSError, json.JSONDecodeError):
            continue
        for item in data.get("written", []):
            path = str(item.get("path", ""))
            if path:
                paths.add(normalize_rel(path))
    return paths


def read_recovery_ledger_items(root: Path) -> dict[str, dict[str, Any]]:
    items: dict[str, dict[str, Any]] = {}
    inbox_root = root / "assets/source/imagegen_inbox"
    if not inbox_root.exists():
        return items
    for ledger_path in sorted(inbox_root.rglob("recovery-ledger.json")):
        try:
            data = load_json(ledger_path)
        except (OSError, json.JSONDecodeError):
            continue
        ledger_items = data.get("items", data if isinstance(data, list) else [])
        for item in ledger_items:
            candidate_path = str(item.get("candidate_path", ""))
            if not candidate_path:
                continue
            normalized = normalize_rel(candidate_path)
            items[normalized] = {
                "ledger": ledger_path.relative_to(root).as_posix(),
                "source": str(item.get("source", "")),
                "mapping_confidence": str(item.get("mapping_confidence", "")),
                "mapping_note": str(item.get("mapping_note", "")),
            }
    return items


def candidate_paths_from_provenance(record: dict[str, Any]) -> set[str]:
    return {
        normalize_rel(candidate.get("path", ""))
        for candidate in record.get("candidate_hashes", [])
        if candidate.get("path")
    }


def prompt_has_project_anchor(prompt: str) -> bool:
    return any(anchor in prompt for anchor in NANO_HUNTER_PROMPT_ANCHORS)


def classify_candidate(
    candidate_path: str,
    record: dict[str, Any],
    session_paths: set[str],
    ledger_items: dict[str, dict[str, Any]],
) -> tuple[str, list[str], dict[str, Any]]:
    reasons: list[str] = []
    evidence: dict[str, Any] = {}
    normalized = normalize_rel(candidate_path)

    if normalized in session_paths:
        return "project_session_confirmed", ["candidate listed in session_recovery summary"], evidence

    ledger = ledger_items.get(normalized)
    if ledger:
        evidence["ledger"] = ledger
        confidence = ledger.get("mapping_confidence", "")
        if confidence == "review_required":
            return "explicit_mapping_review_required", ["candidate listed in recovery ledger with review_required mapping"], evidence
        return "explicit_mapping_confirmed", ["candidate listed in recovery ledger"], evidence

    prompt = str(record.get("prompt", ""))
    if prompt_has_project_anchor(prompt):
        return "workspace_provenance_recorded_review_required", ["candidate has Nano Hunter prompt/provenance but no machine-readable source ledger"], evidence

    reasons.append("candidate lacks Nano Hunter prompt anchor and source ledger")
    return "unknown_or_unsafe", reasons, evidence


def build_report(root: Path, queue_path: Path, candidate_pool_path: Path, provenance_path: Path) -> dict[str, Any]:
    queue = load_json(queue_path)
    candidate_pool = load_json(candidate_pool_path)
    provenance = load_json(provenance_path)
    queue_items = {item["asset_id"]: item for item in queue.get("items", [])}
    pool_items = {item["asset_id"]: item for item in candidate_pool.get("items", [])}
    records = {record["asset_id"]: record for record in provenance.get("records", [])}
    session_paths = read_session_recovery_paths(root)
    ledger_items = read_recovery_ledger_items(root)

    summary_counts: dict[str, int] = {
        "project_session_confirmed": 0,
        "explicit_mapping_confirmed": 0,
        "explicit_mapping_review_required": 0,
        "workspace_provenance_recorded_review_required": 0,
        "unknown_or_unsafe": 0,
    }
    errors: list[str] = []
    report_items: list[dict[str, Any]] = []

    if provenance.get("project_key") != PROJECT_KEY:
        errors.append(f"provenance report project_key must be {PROJECT_KEY}")

    for asset_id, queue_item in queue_items.items():
        record = records.get(asset_id)
        pool_item = pool_items.get(asset_id)
        item_errors: list[str] = []
        candidate_reports: list[dict[str, Any]] = []

        if not record:
            item_errors.append("missing provenance record")
        elif record.get("project_key") != PROJECT_KEY:
            item_errors.append(f"provenance record project_key must be {PROJECT_KEY}")
        if not pool_item:
            item_errors.append("missing candidate pool entry")
        if not str(queue_item.get("source_dir", "")).startswith("assets/source/ai_generated/"):
            item_errors.append("queue source_dir is outside assets/source/ai_generated")
        if not str(queue_item.get("output_path", "")).startswith("assets/art/"):
            item_errors.append("queue output_path is outside assets/art")

        candidate_paths = []
        if pool_item:
            candidate_paths = [normalize_rel(candidate.get("path", "")) for candidate in pool_item.get("candidates", []) if candidate.get("path")]
        record_candidate_paths = candidate_paths_from_provenance(record or {})
        for candidate_path in candidate_paths:
            resolved_candidate = resolve_path(root, candidate_path)
            status = "unknown_or_unsafe"
            reasons: list[str] = []
            evidence: dict[str, Any] = {}
            if not candidate_path.startswith("assets/source/ai_generated/"):
                reasons.append("candidate is outside assets/source/ai_generated")
            if not resolved_candidate.exists():
                reasons.append("candidate file is missing")
            if candidate_path not in record_candidate_paths:
                reasons.append("candidate is missing from provenance candidate_hashes")
            if reasons:
                summary_counts["unknown_or_unsafe"] += 1
            else:
                status, reasons, evidence = classify_candidate(candidate_path, record or {}, session_paths, ledger_items)
                summary_counts[status] += 1
            if status == "unknown_or_unsafe":
                item_errors.append(f"{candidate_path}: {'; '.join(reasons)}")
            candidate_reports.append(
                {
                    "path": candidate_path,
                    "status": status,
                    "reasons": reasons,
                    **evidence,
                }
            )

        if not prompt_has_project_anchor(str((record or {}).get("prompt", ""))):
            item_errors.append("prompt lacks Nano Hunter anchor")

        if item_errors:
            errors.extend(f"{asset_id}: {error}" for error in item_errors)

        report_items.append(
            {
                "asset_id": asset_id,
                "batch": queue_item.get("batch", ""),
                "target_kind": queue_item.get("target_kind", ""),
                "candidate_count": len(candidate_reports),
                "candidates": candidate_reports,
                "errors": item_errors,
            }
        )

    candidate_count = sum(item["candidate_count"] for item in report_items)
    unsafe_count = summary_counts["unknown_or_unsafe"]
    review_required_count = (
        summary_counts["explicit_mapping_review_required"]
        + summary_counts["workspace_provenance_recorded_review_required"]
    )

    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "unsafe_source_found" if unsafe_count else "review_required" if review_required_count else "source_confirmed",
        "boundary": (
            "Source safety audit only. It checks multi-project image_gen import risk by classifying "
            "candidate PNGs against session recovery summaries, recovery ledgers, provenance records "
            "and project path boundaries. It does not approve final art quality, legal terms or runtime use."
        ),
        "summary": {
            "queue_item_count": len(queue_items),
            "candidate_count": candidate_count,
            "classification_counts": summary_counts,
            "review_required_candidate_count": review_required_count,
            "unsafe_candidate_count": unsafe_count,
            "session_recovery_candidate_count": len(session_paths),
            "ledger_mapped_candidate_count": len(ledger_items),
            "global_generated_images_latest_allowed": False,
            "errors": errors,
        },
        "items": report_items,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(
        root,
        resolve_path(root, args.queue),
        resolve_path(root, args.candidate_pool),
        resolve_path(root, args.provenance),
    )

    if args.write_report:
        out_path = resolve_path(root, args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    summary = report["summary"]
    errors = summary["errors"]
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "ImageGen source safety: "
        f"{summary['candidate_count']} candidates, "
        f"{summary['classification_counts']['project_session_confirmed']} project-session confirmed, "
        f"{summary['classification_counts']['explicit_mapping_review_required']} ledger review-required, "
        f"{summary['classification_counts']['workspace_provenance_recorded_review_required']} provenance review-required, "
        f"{summary['unsafe_candidate_count']} unsafe."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
