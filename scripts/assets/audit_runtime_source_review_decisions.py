#!/usr/bin/env python3
"""审计运行时来源人工审图结论。"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_QUEUE = Path("docs/assets/runtime-source-review-queue.json")
DEFAULT_DECISIONS = Path("docs/assets/runtime-source-review-decisions.json")
ALLOWED_DECISIONS = {
    "confirmed_for_cleanup",
    "regenerate_before_cleanup",
    "reject",
    "defer",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit runtime source review decisions.")
    parser.add_argument("--queue", default=str(DEFAULT_QUEUE))
    parser.add_argument("--decisions", default=str(DEFAULT_DECISIONS))
    parser.add_argument("--strict", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def by_asset(entries: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {str(entry.get("asset_id", "")): entry for entry in entries if entry.get("asset_id")}


def audit(queue: dict[str, Any], decisions: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if queue.get("project_key") != PROJECT_KEY:
        errors.append("queue project_key mismatch")
    if decisions.get("project_key") != PROJECT_KEY:
        errors.append("decisions project_key mismatch")

    queue_entries = by_asset(queue.get("entries", []))
    decision_entries = by_asset(decisions.get("entries", []))
    queue_ids = set(queue_entries)
    decision_ids = set(decision_entries)

    if queue_ids != decision_ids:
        missing = sorted(queue_ids - decision_ids)
        extra = sorted(decision_ids - queue_ids)
        if missing:
            errors.append(f"missing decisions: {', '.join(missing)}")
        if extra:
            errors.append(f"extra decisions: {', '.join(extra)}")

    summary = decisions.get("summary", {})
    if int(summary.get("decision_count", -1)) != len(decision_entries):
        errors.append("summary decision_count mismatch")
    if int(summary.get("final_ready_count", -1)) != 0:
        errors.append("decisions must not mark final_ready assets")

    for asset_id, entry in sorted(decision_entries.items()):
        decision_status = str(entry.get("decision_status", ""))
        if decision_status not in ALLOWED_DECISIONS:
            errors.append(f"{asset_id}: invalid decision_status {decision_status}")
        if bool(entry.get("final_ready", False)):
            errors.append(f"{asset_id}: final_ready must remain false")
        if not entry.get("visual_conclusion"):
            errors.append(f"{asset_id}: visual_conclusion missing")
        if not entry.get("required_cleanup"):
            errors.append(f"{asset_id}: required_cleanup missing")
        preferred_output = Path(str(entry.get("preferred_runtime_output", "")))
        if not preferred_output.exists():
            errors.append(f"{asset_id}: preferred_runtime_output missing {preferred_output}")
        queue_entry = queue_entries.get(asset_id, {})
        if entry.get("target_kind") != queue_entry.get("target_kind"):
            errors.append(f"{asset_id}: target_kind mismatch")
        if entry.get("review_strategy") != queue_entry.get("review_strategy"):
            errors.append(f"{asset_id}: review_strategy mismatch")

    evidence = decisions.get("evidence", {})
    for sheet in evidence.get("contact_sheets", []):
        if not Path(str(sheet)).exists():
            errors.append(f"contact sheet missing: {sheet}")
    manifest = evidence.get("contact_sheet_manifest")
    if manifest and not Path(str(manifest)).exists():
        errors.append(f"contact sheet manifest missing: {manifest}")
    return errors


def main() -> int:
    args = parse_args()
    queue_path = Path(args.queue)
    decisions_path = Path(args.decisions)
    if not queue_path.exists():
        print(f"missing queue: {queue_path}")
        return 1 if args.strict else 0
    if not decisions_path.exists():
        print(f"missing decisions: {decisions_path}")
        return 1 if args.strict else 0
    errors = audit(load_json(queue_path), load_json(decisions_path))
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    decisions = load_json(decisions_path)
    summary = decisions["summary"]
    print(
        "Runtime source review decisions OK: "
        f"{summary['decision_count']} decisions, "
        f"{summary['confirmed_for_cleanup_count']} confirmed for cleanup, "
        f"{summary['final_ready_count']} final-ready."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
