#!/usr/bin/env python3
"""Audit final-art acceptance gate report."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REPORT_PATH = Path("docs/assets/final-art-acceptance-gates.json")
MARKDOWN_PATH = Path("docs/assets/final-art-acceptance-gates.md")
RUNTIME_SOURCE_SAFETY_PATH = Path("docs/assets/runtime-source-safety-report.json")
READINESS_PATH = Path("docs/assets/art-readiness-audit-report.json")
EXPECTED_GATES = [
    "source_traceability",
    "license_terms",
    "godot_structural_resource",
    "editor_review_card",
    "runtime_replacement",
    "family_specific_polish",
    "final_approval",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit final-art acceptance gates.")
    parser.add_argument("--strict", action="store_true", help="Return failure when the report is incomplete.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(
    report: dict[str, Any],
    runtime_source_report: dict[str, Any],
    readiness_report: dict[str, Any],
) -> list[str]:
    errors: list[str] = []
    entries = report.get("entries", [])
    summary = report.get("summary", {})
    gate_order = report.get("gate_order", [])

    if gate_order != EXPECTED_GATES:
        errors.append("gate_order mismatch")
    expected_ids = {str(item.get("asset_id", "")) for item in readiness_report.get("items", [])}
    entry_ids = {str(entry.get("asset_id", "")) for entry in entries}
    if entry_ids != expected_ids:
        errors.append(
            f"asset id coverage mismatch: missing={sorted(expected_ids - entry_ids)} "
            f"extra={sorted(entry_ids - expected_ids)}"
        )
    if int(summary.get("asset_count", -1)) != len(expected_ids):
        errors.append(f"summary asset_count expected {len(expected_ids)}")
    final_ready_count = sum(1 for entry in entries if bool(entry.get("final_ready", False)))
    blocked_asset_count = sum(1 for entry in entries if int(entry.get("blocked_gate_count", 0)) > 0)
    if int(summary.get("final_ready_count", -1)) != final_ready_count:
        errors.append("summary final_ready_count mismatch")
    if int(summary.get("blocked_asset_count", -1)) != blocked_asset_count:
        errors.append("summary blocked_asset_count mismatch")
    if final_ready_count + blocked_asset_count != len(entries):
        errors.append("final_ready_count + blocked_asset_count must equal entry count")
    if not MARKDOWN_PATH.exists():
        errors.append("markdown_missing")

    gate_summary = summary.get("gate_summary", {})
    for gate_name in EXPECTED_GATES:
        actual = gate_summary.get(gate_name, {})
        passed = int(actual.get("passed", -1))
        blocked = int(actual.get("blocked", -1))
        if passed + blocked != len(entries):
            errors.append(f"{gate_name} passed + blocked must equal entry count")
    final_gate = gate_summary.get("final_approval", {})
    if int(final_gate.get("passed", -1)) != final_ready_count:
        errors.append("final_approval passed must match final_ready_count")

    for entry in entries:
        asset_id = str(entry.get("asset_id", "unknown"))
        gates = entry.get("gates", {})
        for gate_name in EXPECTED_GATES:
            if gate_name not in gates:
                errors.append(f"{asset_id}: missing gate {gate_name}")
                continue
            gate = gates[gate_name]
            if gate.get("status") not in {"passed", "blocked"}:
                errors.append(f"{asset_id}: invalid gate status {gate_name}")
            if not gate.get("evidence"):
                errors.append(f"{asset_id}: gate evidence missing {gate_name}")
        blocked_gate_count = int(entry.get("blocked_gate_count", -1))
        if bool(entry.get("final_ready", False)) and blocked_gate_count != 0:
            errors.append(f"{asset_id}: final-ready asset must have zero blocked gates")
        if not bool(entry.get("final_ready", False)) and blocked_gate_count <= 0:
            errors.append(f"{asset_id}: blocked_gate_count expected > 0")

    entries_by_asset = {str(entry.get("asset_id", "")): entry for entry in entries}
    review_required_items = runtime_source_report.get("summary", {}).get("runtime_review_required_items", [])
    for asset_id in review_required_items:
        entry = entries_by_asset.get(str(asset_id))
        if entry is None:
            errors.append(f"{asset_id}: runtime source review item missing from final gates")
            continue
        source_gate = entry.get("gates", {}).get("source_traceability", {})
        if source_gate.get("status") != "blocked":
            errors.append(f"{asset_id}: runtime source review must block source_traceability")
        if "runtime_source_safety_review_required" not in source_gate.get("blockers", []):
            errors.append(f"{asset_id}: runtime source blocker missing")
        if bool(entry.get("final_ready", False)):
            errors.append(f"{asset_id}: runtime source review item cannot be final-ready")
    return errors


def main() -> int:
    args = parse_args()
    if not REPORT_PATH.exists():
        print("final-art acceptance gates report missing")
        return 1 if args.strict else 0
    if not RUNTIME_SOURCE_SAFETY_PATH.exists():
        print("runtime source safety report missing")
        return 1 if args.strict else 0
    if not READINESS_PATH.exists():
        print("art readiness report missing")
        return 1 if args.strict else 0
    report = load_json(REPORT_PATH)
    runtime_source_report = load_json(RUNTIME_SOURCE_SAFETY_PATH)
    readiness_report = load_json(READINESS_PATH)
    errors = audit(report, runtime_source_report, readiness_report)
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    summary = report["summary"]
    print(
        "Final art acceptance gates OK: "
        f"{summary['asset_count']} assets, "
        f"{summary['blocked_asset_count']} blocked assets, "
        f"{summary['final_ready_count']} final-ready assets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
