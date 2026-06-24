#!/usr/bin/env python3
"""Audit first-pass semantic metadata for generated atlas regions and frames."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_INDEX = "docs/assets/asset-semantics-index.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit generated semantic metadata coverage.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to atlas build manifest.",
    )
    parser.add_argument(
        "--index",
        default=DEFAULT_INDEX,
        help="Path to semantics index.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return failure when coverage is incomplete.",
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


def rel_path(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def semantic_path_for(metadata_path: Path) -> Path:
    suffix = metadata_path.suffix
    stem = metadata_path.name.removesuffix(suffix)
    if stem.endswith(".frames"):
        return metadata_path.with_name(stem.removesuffix(".frames") + ".semantics.json")
    if stem.endswith(".regions"):
        return metadata_path.with_name(stem.removesuffix(".regions") + ".semantics.json")
    return metadata_path.with_name(stem + ".semantics.json")


def metadata_entry_count(metadata: dict[str, Any]) -> int:
    if "frames" in metadata:
        return len(metadata["frames"])
    if "regions" in metadata:
        return len(metadata["regions"])
    return 0


def audit_asset(root: Path, item: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    asset_id = item["id"]
    metadata_path = resolve_path(root, item["metadata"])
    semantics_path = semantic_path_for(metadata_path)
    errors: list[str] = []
    expected_count = 0
    actual_count = 0
    empty_names = 0
    missing_indices: list[int] = []

    if not metadata_path.exists():
        errors.append("missing_metadata")
    else:
        metadata = load_json(metadata_path)
        expected_count = metadata_entry_count(metadata)

    if not semantics_path.exists():
        errors.append("missing_semantics")
    else:
        semantics = load_json(semantics_path)
        entries = semantics.get("entries", [])
        actual_count = len(entries)
        if actual_count != expected_count:
            errors.append(f"entry_count_mismatch expected {expected_count} got {actual_count}")
        seen = {int(entry.get("index", -1)) for entry in entries}
        missing_indices = [index for index in range(expected_count) if index not in seen]
        if missing_indices:
            errors.append("missing_semantic_indices")
        empty_names = sum(1 for entry in entries if not str(entry.get("semantic_name", "")).strip())
        if empty_names:
            errors.append("empty_semantic_names")

    return {
        "asset_id": asset_id,
        "kind": item.get("kind", ""),
        "metadata": rel_path(root, metadata_path),
        "semantics": rel_path(root, semantics_path),
        "expected_count": expected_count,
        "actual_count": actual_count,
        "empty_names": empty_names,
        "missing_indices": missing_indices,
        "ok": not errors,
    }, errors


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest = load_json(resolve_path(repo_root, args.manifest))
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()
    index_path = resolve_path(repo_root, args.index)

    errors: list[str] = []
    assets: list[dict[str, Any]] = []
    total_expected = 0
    total_actual = 0

    if not index_path.exists():
        errors.append("missing_semantics_index")
    else:
        index = load_json(index_path)
        if int(index.get("asset_count", -1)) != len(manifest.get("outputs", [])):
            errors.append("semantics_index_asset_count_mismatch")

    for item in manifest.get("outputs", []):
        result, asset_errors = audit_asset(root, item)
        total_expected += int(result["expected_count"])
        total_actual += int(result["actual_count"])
        assets.append(result)
        for error in asset_errors:
            errors.append(f"{item['id']}: {error}")

    if index_path.exists():
        index = load_json(index_path)
        if int(index.get("entry_count", -1)) != total_actual:
            errors.append("semantics_index_entry_count_mismatch")

    if errors:
        for error in errors:
            print(error)
        return 1 if args.strict else 0

    print(
        "Asset semantics OK: "
        f"{len(assets)} assets, {total_actual}/{total_expected} semantic entries."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
