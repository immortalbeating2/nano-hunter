#!/usr/bin/env python3
"""读取通用角色 / 怪物模型锁清单，并为生成器提供唯一 metadata 契约。"""

from __future__ import annotations

import argparse
from copy import deepcopy
import json
from pathlib import Path
from typing import Any, Iterator


DEFAULT_MANIFEST = Path("docs/assets/character-creature-model-locks.json")


def load_manifest(root: Path, manifest_path: Path = DEFAULT_MANIFEST) -> dict[str, Any]:
    path = manifest_path if manifest_path.is_absolute() else root / manifest_path
    return json.loads(path.read_text(encoding="utf-8"))


def iter_asset_contracts(
    manifest: dict[str, Any],
) -> Iterator[tuple[dict[str, Any], dict[str, Any], dict[str, Any]]]:
    """依次返回 family、asset 与可直接写入 sidecar 的 model_lock。"""
    contract_kind = str(manifest.get("contract_kind", ""))
    contract_version = int(manifest.get("version", 0))
    for family in manifest.get("families", []):
        if not isinstance(family, dict):
            continue
        for asset in family.get("assets", []):
            if not isinstance(asset, dict):
                continue
            model_lock = {
                "contract_kind": contract_kind,
                "contract_version": contract_version,
                "model_id": str(family.get("model_id", "")),
                "canonical_reference": str(family.get("canonical_reference", "")),
                "canonical_frame_index": int(family.get("canonical_frame_index", 0)),
                "cell": [int(value) for value in family.get("cell", [])],
                "root_anchor_kind": str(family.get("root_anchor_kind", "")),
                "center_x": float(family.get("center_x", 0)),
                "center_tolerance_px": float(family.get("center_tolerance_px", 0)),
                "root_y": int(family.get("root_y", 0)),
                "root_tolerance_px": int(family.get("root_tolerance_px", 0)),
                "identity_height_ratio_min": float(family.get("identity_height_ratio_min", 0)),
                "identity_height_ratio_max": float(family.get("identity_height_ratio_max", 0)),
                "geometry_lock_ready": bool(
                    asset.get("geometry_lock_ready", family.get("geometry_lock_ready", False))
                ),
                "identity_lock_ready": bool(
                    asset.get("identity_lock_ready", family.get("identity_lock_ready", False))
                ),
                "runtime_binding_allowed": bool(
                    asset.get("runtime_binding_allowed", family.get("runtime_binding_allowed", False))
                ),
                "identity_review_status": str(family.get("identity_review_status", "pending")),
                "semantic_anchor_contract": deepcopy(
                    family.get("semantic_anchor_contract", {})
                ),
                "asset_role": str(asset.get("role", "")),
                "asset_status": str(asset.get("status", "active")),
                "identity_sample_indices": [
                    int(value) for value in asset.get("identity_sample_indices", [])
                ],
                "scale_sample_indices": [
                    int(value)
                    for value in asset.get(
                        "scale_sample_indices", asset.get("identity_sample_indices", [])
                    )
                ],
                "root_sample_indices": [int(value) for value in asset.get("root_sample_indices", [])],
                "manual_identity_features": [
                    str(value) for value in family.get("manual_identity_features", [])
                ],
                "allowed_variants": [str(value) for value in family.get("allowed_variants", [])],
            }
            yield family, asset, model_lock


def contract_by_asset_id(
    root: Path,
    manifest: dict[str, Any] | None = None,
) -> dict[str, dict[str, Any]]:
    source = manifest if manifest is not None else load_manifest(root)
    return {
        str(asset["asset_id"]): model_lock
        for _family, asset, model_lock in iter_asset_contracts(source)
    }


def model_lock_for_asset(
    root: Path,
    asset_id: str,
    manifest: dict[str, Any] | None = None,
) -> dict[str, Any]:
    contracts = contract_by_asset_id(root, manifest)
    if asset_id not in contracts:
        raise KeyError(f"Model lock asset is not registered: {asset_id}")
    return contracts[asset_id]


def attach_model_lock(
    payload: dict[str, Any],
    root: Path,
    asset_id: str,
    manifest: dict[str, Any] | None = None,
) -> dict[str, Any]:
    payload["model_lock"] = model_lock_for_asset(root, asset_id, manifest)
    return payload


def maybe_attach_model_lock(
    payload: dict[str, Any],
    root: Path,
    asset_id: str,
    manifest: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """只为已登记 body 写入模型锁；VFX 和 review-only 未登记资产保持原样。"""
    contracts = contract_by_asset_id(root, manifest)
    if asset_id in contracts:
        payload["model_lock"] = contracts[asset_id]
    return payload


def asset_paths(root: Path, family: dict[str, Any], asset_id: str) -> tuple[Path, Path, Path]:
    asset_root = root / str(family["asset_root"])
    return (
        asset_root / f"{asset_id}.png",
        asset_root / f"{asset_id}.frames.json",
        asset_root / f"{asset_id}.source.json",
    )


def validate_manifest(root: Path, manifest: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if manifest.get("contract_kind") != "character_creature_model_lock_v1":
        errors.append("contract_kind must be character_creature_model_lock_v1")
    if int(manifest.get("version", 0)) != 2:
        errors.append("manifest version must be 2")

    seen_assets: set[str] = set()
    seen_models: set[str] = set()
    for family in manifest.get("families", []):
        model_id = str(family.get("model_id", ""))
        if not model_id or model_id in seen_models:
            errors.append(f"duplicate or missing model_id: {model_id}")
        seen_models.add(model_id)
        assets = [asset for asset in family.get("assets", []) if isinstance(asset, dict)]
        active_ids = {
            str(asset.get("asset_id", ""))
            for asset in assets
            if str(asset.get("status", "active")) == "active"
        }
        canonical = str(family.get("canonical_reference", ""))
        if canonical not in active_ids:
            errors.append(f"{model_id}: canonical reference is not active: {canonical}")
        if len(family.get("cell", [])) != 2:
            errors.append(f"{model_id}: cell must contain two values")
        if not bool(family.get("identity_lock_ready", False)):
            errors.append(f"{model_id}: active family must be identity_lock_ready")
        semantic_contract = family.get("semantic_anchor_contract", {})
        if not isinstance(semantic_contract, dict):
            errors.append(f"{model_id}: semantic_anchor_contract must be an object")
            semantic_contract = {}
        core_anchor_id = str(semantic_contract.get("core_anchor_id", ""))
        required_anchors = {
            str(value) for value in semantic_contract.get("required_anchors", [])
        }
        expected_anchors = {
            "root",
            "foot_contact",
            "head_top",
            core_anchor_id,
            "front_contour",
            "rear_contour",
        }
        if not core_anchor_id or required_anchors != expected_anchors:
            errors.append(
                f"{model_id}: required semantic anchors must be root/foot/head/core/front/rear"
            )
        for box_key in ("head_search_bbox", "core_search_bbox", "foot_search_bbox"):
            box = semantic_contract.get(box_key, [])
            if (
                not isinstance(box, list)
                or len(box) != 4
                or any(not isinstance(value, (int, float)) for value in box)
                or not (0.0 <= float(box[0]) < float(box[1]) <= 1.0)
                or not (0.0 <= float(box[2]) < float(box[3]) <= 1.0)
            ):
                errors.append(f"{model_id}: invalid {box_key}")
        contour_range = semantic_contract.get("contour_y_range", [])
        if (
            not isinstance(contour_range, list)
            or len(contour_range) != 2
            or not (0.0 <= float(contour_range[0]) < float(contour_range[1]) <= 1.0)
        ):
            errors.append(f"{model_id}: invalid contour_y_range")

        for asset in assets:
            asset_id = str(asset.get("asset_id", ""))
            if not asset_id or asset_id in seen_assets:
                errors.append(f"duplicate or missing asset_id: {asset_id}")
                continue
            seen_assets.add(asset_id)
            status = str(asset.get("status", "active"))
            identity_lock_ready = bool(
                asset.get("identity_lock_ready", family.get("identity_lock_ready", False))
            )
            if status == "active" and not identity_lock_ready:
                errors.append(f"{asset_id}: active asset must be identity_lock_ready")
            if status != "active" and identity_lock_ready:
                errors.append(f"{asset_id}: rejected asset cannot be identity_lock_ready")
            texture, metadata_path, source_path = asset_paths(root, family, asset_id)
            for path in (texture, metadata_path, source_path):
                if not path.is_file():
                    errors.append(f"{asset_id}: missing file {path.as_posix()}")
            if not metadata_path.is_file():
                continue
            metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
            frame_count = len(metadata.get("frames", []))
            for key in ("identity_sample_indices", "scale_sample_indices", "root_sample_indices"):
                indexes = asset.get(key, asset.get("identity_sample_indices", []))
                for index in indexes:
                    if int(index) < 0 or int(index) >= frame_count:
                        errors.append(f"{asset_id}: {key} index out of range: {index}")
    return errors


def apply_metadata(root: Path, manifest: dict[str, Any]) -> int:
    changed = 0
    for family, asset, model_lock in iter_asset_contracts(manifest):
        asset_id = str(asset["asset_id"])
        _texture, metadata_path, source_path = asset_paths(root, family, asset_id)
        for path in (metadata_path, source_path):
            payload = json.loads(path.read_text(encoding="utf-8"))
            if payload.get("model_lock") == model_lock:
                continue
            payload["model_lock"] = model_lock
            path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            changed += 1
    return changed


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="校验或写入角色 / 怪物通用模型锁 metadata。")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--apply-metadata", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    manifest = load_manifest(root, args.manifest)
    errors = validate_manifest(root, manifest)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    changed = apply_metadata(root, manifest) if args.apply_metadata else 0
    family_count = len(manifest.get("families", []))
    asset_count = sum(len(family.get("assets", [])) for family in manifest.get("families", []))
    print(
        "Character / creature model lock contract OK: "
        f"{family_count} families, {asset_count} assets, metadata_changed={changed}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
