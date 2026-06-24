#!/usr/bin/env python3
"""校验 Nano Hunter image gen 生产队列与图集构建规格是否一致。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


REQUIRED_ITEM_FIELDS = {
    "asset_id",
    "batch",
    "priority",
    "target_kind",
    "candidate_count",
    "source_dir",
    "output_path",
    "prompt",
}

BATCH_RE = re.compile(r"^Batch \d{2}$")
ASSET_ID_RE = re.compile(r"^[a-z0-9]+(?:_[a-z0-9]+)*_ai\d{2}$")
PROJECT_ANCHORS = (
    "Nano Hunter",
    "Luna",
    "Seal Guardian",
    "Buddhist",
    "metroidvania",
    "Chinese dark fantasy",
    "talisman",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate docs/assets/image-gen-prompt-queue.json.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Prompt queue JSON path.",
    )
    parser.add_argument(
        "--atlas-manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Atlas build manifest JSON path.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def require(condition: bool, errors: list[str], message: str) -> None:
    if not condition:
        errors.append(message)


def validate_item(
    item: dict[str, Any],
    index: int,
    atlas_outputs: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    label = item.get("asset_id", f"item[{index}]")
    missing = sorted(REQUIRED_ITEM_FIELDS - set(item))
    require(not missing, errors, f"{label}: missing required fields: {', '.join(missing)}")
    if missing:
        return

    asset_id = str(item["asset_id"])
    batch = str(item["batch"])
    source_dir = str(item["source_dir"])
    output_path = str(item["output_path"])
    prompt = str(item["prompt"])
    candidate_count = item["candidate_count"]

    require(bool(ASSET_ID_RE.match(asset_id)), errors, f"{label}: asset_id must be snake_case and end with _aiNN")
    require(bool(BATCH_RE.match(batch)), errors, f"{label}: batch must look like Batch 01")
    require(isinstance(candidate_count, int) and candidate_count > 0, errors, f"{label}: candidate_count must be a positive integer")
    require(source_dir.startswith("assets/source/ai_generated/"), errors, f"{label}: source_dir must live under assets/source/ai_generated/")
    require(output_path.startswith("assets/art/"), errors, f"{label}: output_path must live under assets/art/")
    require(asset_id in source_dir, errors, f"{label}: source_dir should include asset_id")
    require(batch.lower().replace(" ", "_") in source_dir, errors, f"{label}: source_dir should include normalized batch id")
    require(len(prompt) >= 240, errors, f"{label}: prompt is too short for production use")
    require(
        any(anchor in prompt for anchor in PROJECT_ANCHORS),
        errors,
        f"{label}: prompt should include a project or style anchor",
    )
    require("watermark" in prompt.lower(), errors, f"{label}: prompt should forbid watermarks")

    if "atlas_output_id" in item:
        atlas_id = str(item["atlas_output_id"])
        atlas_item = atlas_outputs.get(atlas_id)
        require(atlas_item is not None, errors, f"{label}: atlas_output_id not found: {atlas_id}")
        if atlas_item:
            require(
                atlas_item.get("output") == output_path,
                errors,
                f"{label}: output_path does not match atlas manifest output for {atlas_id}",
            )
            require(
                atlas_item.get("source_dir") == source_dir,
                errors,
                f"{label}: source_dir does not match atlas manifest source_dir for {atlas_id}",
            )


def main() -> int:
    args = parse_args()
    queue_path = Path(args.queue)
    atlas_path = Path(args.atlas_manifest)
    queue = load_json(queue_path)
    atlas_manifest = load_json(atlas_path)
    atlas_outputs = {item["id"]: item for item in atlas_manifest.get("outputs", [])}

    errors: list[str] = []
    require(queue.get("version") == 1, errors, "queue: version must be 1")
    require(bool(queue.get("style_anchor")), errors, "queue: style_anchor is required")
    require(bool(queue.get("negative_anchor")), errors, "queue: negative_anchor is required")

    items = queue.get("items")
    require(isinstance(items, list) and bool(items), errors, "queue: items must be a non-empty list")
    if not isinstance(items, list):
        items = []

    seen: set[str] = set()
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            errors.append(f"item[{index}]: must be an object")
            continue
        asset_id = str(item.get("asset_id", f"item[{index}]"))
        if asset_id in seen:
            errors.append(f"{asset_id}: duplicate asset_id")
        seen.add(asset_id)
        validate_item(item, index, atlas_outputs, errors)

    if errors:
        print("Asset production queue validation failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    atlas_linked = sum(1 for item in items if isinstance(item, dict) and item.get("atlas_output_id"))
    print(f"Asset production queue OK: {len(items)} items, {atlas_linked} atlas-linked outputs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
