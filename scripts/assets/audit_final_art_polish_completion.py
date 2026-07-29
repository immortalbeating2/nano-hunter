#!/usr/bin/env python3
"""Audit final-art polish FP-01 through FP-05 completion evidence."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_JSON_REPORT = "docs/assets/final-art-polish-completion-audit-report.json"
DEFAULT_MD_REPORT = "docs/assets/final-art-polish-completion-audit-report.md"

FP_REPORTS = [
    {
        "batch": "FP-01",
        "path": "tests/artifacts/local/final-art-polish/fp01_runtime_readability/fp01_runtime_readability_report.json",
        "status_key": "ok",
        "expected": True,
    },
    {
        "batch": "FP-02",
        "path": "docs/assets/final-art-polish-fp02-atlas-split-report.json",
        "status_key": "status",
        "expected": "ok",
    },
    {
        "batch": "FP-03",
        "path": "docs/assets/final-art-polish-fp03-tileset-review-report.json",
        "status_key": "status",
        "expected": "ok",
    },
    {
        "batch": "FP-04",
        "path": "docs/assets/final-art-polish-fp04-ui-small-readability-report.json",
        "status_key": "status",
        "expected": "ok",
    },
    {
        "batch": "FP-05",
        "path": "docs/assets/final-art-polish-fp05-animation-vfx-report.json",
        "status_key": "status",
        "expected": "ok",
    },
]

FINAL_GATES = [
    {
        "id": "art_readiness",
        "path": "docs/assets/art-readiness-audit-report.json",
        "checks": {
            "ok": True,
        },
    },
    {
        "id": "asset_package",
        "path": "docs/assets/asset-package-audit-report.json",
        "checks": {
            "ok": True,
        },
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit final art polish completion evidence.")
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--json-report", default=DEFAULT_JSON_REPORT)
    parser.add_argument("--md-report", default=DEFAULT_MD_REPORT)
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit_fp_reports(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    rows = []
    for spec in FP_REPORTS:
        path = root / spec["path"]
        row_errors: list[str] = []
        value: Any = None
        if not path.exists():
            row_errors.append("report_missing")
        else:
            data = load_json(path)
            value = data.get(spec["status_key"])
            if value != spec["expected"]:
                row_errors.append(f"status_mismatch:{value}")
        errors.extend(f"{spec['batch']}:{error}" for error in row_errors)
        rows.append({
            "batch": spec["batch"],
            "path": spec["path"],
            "status": "complete" if not row_errors else "blocked",
            "observed": value,
            "expected": spec["expected"],
            "errors": row_errors,
        })
    return {
        "status": "complete" if not errors else "blocked",
        "batches": rows,
        "errors": errors,
        "warnings": [],
    }


def audit_final_gates(root: Path) -> dict[str, Any]:
    errors: list[str] = []
    rows = []
    for spec in FINAL_GATES:
        path = root / spec["path"]
        row_errors: list[str] = []
        observed: dict[str, Any] = {}
        if not path.exists():
            row_errors.append("report_missing")
        else:
            data = load_json(path)
            for key, expected in spec["checks"].items():
                observed[key] = data.get(key)
                if data.get(key) != expected:
                    row_errors.append(f"{key}_mismatch:{data.get(key)}")
        errors.extend(f"{spec['id']}:{error}" for error in row_errors)
        rows.append({
            "id": spec["id"],
            "path": spec["path"],
            "status": "complete" if not row_errors else "blocked",
            "observed": observed,
            "errors": row_errors,
        })
    return {
        "status": "complete" if not errors else "blocked",
        "gates": rows,
        "errors": errors,
        "warnings": [],
    }


def build_report(root: Path) -> dict[str, Any]:
    fp_reports = audit_fp_reports(root)
    final_gates = audit_final_gates(root)
    errors = [
        *[f"fp_reports:{error}" for error in fp_reports["errors"]],
        *[f"final_gates:{error}" for error in final_gates["errors"]],
    ]
    return {
        "version": 1,
        "status": "complete" if not errors else "blocked",
        "boundary": (
            "Final-art polish completion evidence for FP-01 through FP-05. Completion means the "
            "planned final-polish audits and structural/runtime gates passed; it does not claim "
            "commercial-release hand paint, typography cleanup, final autotile authoring, or full "
            "playtest art direction signoff."
        ),
        "summary": {
            "fp_batch_count": len(FP_REPORTS),
            "complete_fp_batch_count": sum(1 for row in fp_reports["batches"] if row["status"] == "complete"),
            "final_gate_count": len(FINAL_GATES),
            "complete_final_gate_count": sum(1 for row in final_gates["gates"] if row["status"] == "complete"),
            "error_count": len(errors),
        },
        "fp_reports": fp_reports,
        "final_gates": final_gates,
        "errors": errors,
        "warnings": [],
    }


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    lines = [
        "# Final Art Polish Completion Audit Report",
        "",
        f"- Status: `{report['status']}`",
        f"- FP batches: `{report['summary']['complete_fp_batch_count']}/{report['summary']['fp_batch_count']}` complete",
        f"- Final gates: `{report['summary']['complete_final_gate_count']}/{report['summary']['final_gate_count']}` complete",
        f"- Errors: `{report['summary']['error_count']}`",
        "",
        "## FP Reports",
        "",
    ]
    for row in report["fp_reports"]["batches"]:
        lines.append(f"- `{row['batch']}`: `{row['status']}` / `{row['path']}`")
    lines.extend(["", "## Final Gates", ""])
    for row in report["final_gates"]["gates"]:
        lines.append(f"- `{row['id']}`: `{row['status']}` / `{row['path']}`")
    lines.extend(["", "## Boundary", "", report["boundary"], ""])
    path.write_text("\n".join(lines), encoding="utf-8")


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
        "Final art polish completion audit: "
        f"{report['summary']['complete_fp_batch_count']}/{report['summary']['fp_batch_count']} FP batches, "
        f"{report['summary']['complete_final_gate_count']}/{report['summary']['final_gate_count']} final gates, "
        f"{report['summary']['error_count']} errors."
    )
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
