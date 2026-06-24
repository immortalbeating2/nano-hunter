#!/usr/bin/env python3
"""审计首批美术最终化复核记录。"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_RECORDS = Path("docs/assets/asset-finalization-review-records.json")
DEFAULT_MARKDOWN = Path("docs/assets/asset-finalization-review-records.md")
OPENAI_TERMS_URL = "https://openai.com/policies/terms-of-use/"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit asset finalization review records.")
    parser.add_argument("--records", default=str(DEFAULT_RECORDS))
    parser.add_argument("--markdown", default=str(DEFAULT_MARKDOWN))
    parser.add_argument("--strict", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def audit(data: dict[str, Any], root: Path, markdown_path: Path) -> list[str]:
    errors: list[str] = []
    if data.get("project_key") != PROJECT_KEY:
        errors.append("project_key mismatch")
    if not markdown_path.exists():
        errors.append("markdown missing")
    terms = data.get("terms_review", {})
    if terms.get("terms_url") != OPENAI_TERMS_URL:
        errors.append("terms_url mismatch")
    summary = data.get("summary", {})
    records = data.get("records", [])
    if int(summary.get("record_count", -1)) != len(records):
        errors.append("record_count mismatch")
    if int(summary.get("approved_for_final_ready_count", -1)) != len(records):
        errors.append("approved_for_final_ready_count mismatch")
    for record in records:
        asset_id = str(record.get("asset_id", "unknown"))
        if record.get("review_status") != "approved_for_final_ready":
            errors.append(f"{asset_id}: review_status not approved")
        if record.get("final_approval_status") != "approved":
            errors.append(f"{asset_id}: final_approval_status not approved")
        if "license_terms_manual_review" not in record.get("approved_blockers", []):
            errors.append(f"{asset_id}: license blocker not approved")
        output_path = root / str(record.get("output_path", ""))
        if not output_path.exists():
            errors.append(f"{asset_id}: output_path missing")
        if OPENAI_TERMS_URL not in record.get("evidence", []):
            errors.append(f"{asset_id}: terms evidence missing")
    return errors


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    records_path = root / args.records
    markdown_path = root / args.markdown
    if not records_path.exists():
        print(f"missing records: {records_path}")
        return 1 if args.strict else 0
    data = load_json(records_path)
    errors = audit(data, root, markdown_path)
    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    summary = data["summary"]
    print(
        "Asset finalization reviews OK: "
        f"{summary['approved_for_final_ready_count']}/{summary['record_count']} approved final-ready records."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
