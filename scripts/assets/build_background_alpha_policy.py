#!/usr/bin/env python3
"""Build alpha-channel policy records and opaque previews for background-like assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_REPORT = "docs/assets/background-alpha-policy-report.json"
OPAQUE_PREVIEW_KINDS = {
    "promo_key_art",
    "promo_capsule",
    "cg_illustration",
    "storyboard_sheet",
}
ALPHA_ALLOWED_KINDS = {
    "environment_tiles",
    "texture_atlas",
    "tileset_sheet",
}
COMPOSITE_COLOR = (8, 16, 20, 255)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build background alpha policy records and opaque previews.",
    )
    parser.add_argument(
        "--readiness",
        default="docs/assets/art-readiness-audit-report.json",
        help="Path to art readiness report.",
    )
    parser.add_argument(
        "--out",
        default=DEFAULT_REPORT,
        help="Output alpha policy report path.",
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


def normalize_rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def opaque_preview_path(output_path: Path) -> Path:
    return output_path.parent / "opaque_previews" / f"{output_path.stem}_opaque_preview.png"


def write_opaque_preview(source_path: Path, preview_path: Path) -> dict[str, Any]:
    preview_path.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source_path) as image:
        rgba = image.convert("RGBA")
        background = Image.new("RGBA", rgba.size, COMPOSITE_COLOR)
        flattened = Image.alpha_composite(background, rgba).convert("RGB")
        flattened.save(preview_path)
        return {
            "width": flattened.width,
            "height": flattened.height,
            "mode": flattened.mode,
        }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    readiness = load_json(resolve_path(root, args.readiness))
    records: list[dict[str, Any]] = []
    for item in readiness.get("items", []):
        warnings = item.get("warnings", [])
        asset_id = item["asset_id"]
        target_kind = item["target_kind"]
        metrics = item.get("metrics", {})
        has_background_alpha = (
            "background_asset_contains_alpha" in warnings
            or (target_kind in (ALPHA_ALLOWED_KINDS | OPAQUE_PREVIEW_KINDS) and bool(metrics.get("has_alpha", False)))
            or bool(item.get("background_alpha_policy"))
        )
        if not has_background_alpha:
            continue
        output_path = resolve_path(root, item["output_path"])
        record: dict[str, Any] = {
            "asset_id": asset_id,
            "target_kind": target_kind,
            "source_path": normalize_rel(output_path, root),
            "transparent_pixel_ratio": metrics.get("transparent_pixel_ratio", 0),
            "policy_status": "manual_review_required",
            "opaque_preview_path": "",
            "note": "",
        }
        if target_kind in ALPHA_ALLOWED_KINDS:
            record["policy_status"] = "alpha_allowed_for_tile_or_atlas_padding"
            record["note"] = "Transparent padding is expected for tile/atlas editing; preserve source alpha for Godot editing."
        elif target_kind in OPAQUE_PREVIEW_KINDS:
            preview_path = opaque_preview_path(output_path)
            preview_metrics = write_opaque_preview(output_path, preview_path)
            record["policy_status"] = "opaque_preview_ready_manual_review"
            record["opaque_preview_path"] = normalize_rel(preview_path, root)
            record["opaque_preview_metrics"] = preview_metrics
            record["note"] = "Source alpha is preserved; opaque preview is available for release/narrative review."
        records.append(record)

    counts: dict[str, int] = {}
    for record in records:
        status = str(record["policy_status"])
        counts[status] = counts.get(status, 0) + 1

    report = {
        "version": 1,
        "status": "background_alpha_policy_ready_manual_review",
        "boundary": (
            "Alpha policy only. It preserves original generated PNGs, records which alpha channels are intentional, "
            "and creates opaque previews for release/narrative sheets. It does not approve final art."
        ),
        "composite_color_rgba": list(COMPOSITE_COLOR),
        "summary": {
            "record_count": len(records),
            "policy_counts": dict(sorted(counts.items())),
            "opaque_preview_count": sum(1 for record in records if record.get("opaque_preview_path")),
        },
        "records": records,
    }
    out_path = resolve_path(root, args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        "Background alpha policy built: "
        f"{report['summary']['record_count']} records, "
        f"{report['summary']['opaque_preview_count']} opaque previews."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
