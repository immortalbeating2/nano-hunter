#!/usr/bin/env python3
"""Audit the final-art manual review queue."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_QUEUE = "docs/assets/final-art-review-queue.json"
DEFAULT_MARKDOWN = "docs/assets/final-art-review-queue.md"
DEFAULT_SOURCE_QUEUE = "docs/assets/image-gen-prompt-queue.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit final-art manual review queue.")
    parser.add_argument("--queue", default=DEFAULT_QUEUE)
    parser.add_argument("--markdown", default=DEFAULT_MARKDOWN)
    parser.add_argument("--source-queue", default=DEFAULT_SOURCE_QUEUE)
    parser.add_argument("--strict", action="store_true")
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
    queue_path = resolve_path(root, args.queue)
    markdown_path = resolve_path(root, args.markdown)
    source_queue = load_json(resolve_path(root, args.source_queue))
    expected_ids = {str(item["asset_id"]) for item in source_queue.get("items", [])}
    errors: list[str] = []
    if not queue_path.exists():
        errors.append("review queue json missing")
        queue = {"entries": [], "summary": {}}
    else:
        queue = load_json(queue_path)
    if not markdown_path.exists():
        errors.append("review queue markdown missing")

    entries = queue.get("entries", [])
    summary = queue.get("summary", {})
    entry_ids = {str(entry.get("asset_id", "")) for entry in entries}
    if entry_ids != expected_ids:
        errors.append(
            f"asset id coverage mismatch: missing={sorted(expected_ids - entry_ids)} "
            f"extra={sorted(entry_ids - expected_ids)}"
        )
    if int(summary.get("asset_count", -1)) != len(entries):
        errors.append("summary asset_count mismatch")
    manual_review_count = sum(1 for entry in entries if entry.get("blockers"))
    final_ready_count = sum(1 for entry in entries if bool(entry.get("final_ready", False)))
    if int(summary.get("manual_review_required_count", -1)) != manual_review_count:
        errors.append("manual_review_required_count mismatch")
    if int(summary.get("final_ready_count", -1)) != final_ready_count:
        errors.append("final_ready_count mismatch")
    if manual_review_count + final_ready_count != len(entries):
        errors.append("manual_review_required_count + final_ready_count must equal entry count")

    seen: set[str] = set()
    for entry in entries:
        asset_id = str(entry.get("asset_id", ""))
        if not asset_id:
            errors.append("entry missing asset_id")
            continue
        if asset_id in seen:
            errors.append(f"duplicate asset_id {asset_id}")
        seen.add(asset_id)
        output_path = resolve_path(root, str(entry.get("output_path", "")))
        if not output_path.exists():
            errors.append(f"{asset_id}: output_path missing")
        if not entry.get("blockers") and not bool(entry.get("final_ready", False)):
            errors.append(f"{asset_id}: blockers missing")
        if not entry.get("next_actions") and not bool(entry.get("final_ready", False)):
            errors.append(f"{asset_id}: next_actions missing")
        if len(entry.get("next_actions", [])) != len(entry.get("blockers", [])):
            errors.append(f"{asset_id}: next_actions/blockers count mismatch")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    print(
        "Final art review queue OK: "
        f"{len(entries)} assets, {manual_review_count} manual-review entries, "
        f"{final_ready_count} final-ready assets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
