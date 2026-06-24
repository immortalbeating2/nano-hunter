#!/usr/bin/env python3
"""Audit alpha-channel policy records and opaque previews."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_REPORT = "docs/assets/background-alpha-policy-report.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit background alpha policy records and opaque previews.",
    )
    parser.add_argument(
        "--report",
        default=DEFAULT_REPORT,
        help="Path to background alpha policy report.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure when policy records or previews are invalid.",
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


def image_has_alpha(path: Path) -> bool:
    with Image.open(path) as image:
        return image.mode in {"RGBA", "LA"} or "transparency" in image.info


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = load_json(resolve_path(root, args.report))
    errors: list[str] = []
    records = report.get("records", [])
    if len(records) != 11:
        errors.append(f"record_count expected 11 got {len(records)}")
    preview_count = 0
    allowed_count = 0
    for record in records:
        asset_id = record.get("asset_id", "")
        source_path = resolve_path(root, str(record.get("source_path", "")))
        if not source_path.exists():
            errors.append(f"{asset_id}: source missing")
        status = str(record.get("policy_status", ""))
        if status == "alpha_allowed_for_tile_or_atlas_padding":
            allowed_count += 1
        elif status == "opaque_preview_ready_manual_review":
            preview_count += 1
            preview_path = resolve_path(root, str(record.get("opaque_preview_path", "")))
            if not preview_path.exists():
                errors.append(f"{asset_id}: opaque preview missing")
            elif image_has_alpha(preview_path):
                errors.append(f"{asset_id}: opaque preview still has alpha")
        else:
            errors.append(f"{asset_id}: unexpected policy_status {status}")
    if allowed_count != 5:
        errors.append(f"alpha_allowed count expected 5 got {allowed_count}")
    if preview_count != 6:
        errors.append(f"opaque preview count expected 6 got {preview_count}")
    summary = report.get("summary", {})
    if int(summary.get("opaque_preview_count", -1)) != 6:
        errors.append("summary opaque_preview_count expected 6")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0
    print("Background alpha policy OK: 11 records, 6 opaque previews, 5 alpha-allowed atlas assets.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
