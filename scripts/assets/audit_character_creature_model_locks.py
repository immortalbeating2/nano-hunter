#!/usr/bin/env python3
"""严格审计角色、普通怪物与 Boss 的共享模型锁几何和 sidecar 契约。"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from statistics import median
from typing import Any

from PIL import Image

from character_creature_model_lock_contract import (
    DEFAULT_MANIFEST,
    contract_by_asset_id,
    load_manifest,
    validate_manifest,
)


DEFAULT_REPORT = Path(
    "tests/artifacts/local/character-creature-model-lock/model_lock_audit_report.json"
)


def _read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _normalized_box_to_pixels(
    normalized_box: list[float], cell_width: int, cell_height: int
) -> tuple[int, int, int, int]:
    """把左/右/上/下归一化搜索框转换为不越界的半开像素范围。"""
    left = max(0, min(cell_width - 1, math.floor(normalized_box[0] * cell_width)))
    right = max(left + 1, min(cell_width, math.ceil(normalized_box[1] * cell_width)))
    top = max(0, min(cell_height - 1, math.floor(normalized_box[2] * cell_height)))
    bottom = max(top + 1, min(cell_height, math.ceil(normalized_box[3] * cell_height)))
    return left, top, right, bottom


def _opaque_points(
    alpha: Image.Image, bounds: tuple[int, int, int, int]
) -> list[tuple[int, int]]:
    left, top, right, bottom = bounds
    pixels = alpha.load()
    return [
        (x, y)
        for y in range(top, bottom)
        for x in range(left, right)
        if int(pixels[x, y]) > 0
    ]


def _median_int(values: list[int]) -> int:
    return int(round(float(median(values))))


def _semantic_anchors(
    alpha: Image.Image,
    bbox: tuple[int, int, int, int],
    family: dict[str, Any],
) -> tuple[dict[str, list[float | int]], dict[str, Any], list[str]]:
    """从透明度像素推导可复核语义锚点；不冒充骨骼或解剖真值。"""
    contract = family["semantic_anchor_contract"]
    cell_width, cell_height = alpha.size
    left, top, right, bottom = bbox
    anchors: dict[str, list[float | int]] = {
        "root": [float(family["center_x"]), int(family["root_y"])]
    }
    evidence: dict[str, Any] = {}
    errors: list[str] = []

    search_boxes = {
        key: _normalized_box_to_pixels(
            [float(value) for value in contract[key]], cell_width, cell_height
        )
        for key in ("head_search_bbox", "core_search_bbox", "foot_search_bbox")
    }
    evidence["search_boxes"] = {key: list(value) for key, value in search_boxes.items()}

    head_points = _opaque_points(alpha, search_boxes["head_search_bbox"])
    if head_points:
        head_y = min(point[1] for point in head_points)
        anchors["head_top"] = [
            _median_int([point[0] for point in head_points if point[1] == head_y]),
            head_y,
        ]
    else:
        errors.append("head_top search zone has no opaque pixels")

    foot_points = _opaque_points(alpha, search_boxes["foot_search_bbox"])
    if foot_points:
        foot_y = max(point[1] for point in foot_points)
        anchors["foot_contact"] = [
            _median_int([point[0] for point in foot_points if point[1] == foot_y]),
            foot_y,
        ]
    else:
        errors.append("foot_contact search zone has no opaque pixels")

    core_anchor_id = str(contract["core_anchor_id"])
    core_points = _opaque_points(alpha, search_boxes["core_search_bbox"])
    if core_points:
        target_y = top + float(contract["core_target_y_ratio"]) * max(1, bottom - top - 1)
        core_y = min(
            {point[1] for point in core_points},
            key=lambda value: (abs(value - target_y), value),
        )
        anchors[core_anchor_id] = [
            _median_int([point[0] for point in core_points if point[1] == core_y]),
            core_y,
        ]
        evidence["core_target_y"] = round(target_y, 3)
    else:
        errors.append(f"{core_anchor_id} search zone has no opaque pixels")

    contour_range = [float(value) for value in contract["contour_y_range"]]
    contour_top = max(top, min(bottom - 1, math.floor(top + contour_range[0] * (bottom - top))))
    contour_bottom = max(
        contour_top + 1,
        min(bottom, math.ceil(top + contour_range[1] * (bottom - top))),
    )
    contour_points = _opaque_points(alpha, (left, contour_top, right, contour_bottom))
    evidence["contour_search_bbox"] = [left, contour_top, right, contour_bottom]
    if contour_points:
        left_x = min(point[0] for point in contour_points)
        right_x = max(point[0] for point in contour_points)
        left_point = [left_x, _median_int([point[1] for point in contour_points if point[0] == left_x])]
        right_point = [right_x, _median_int([point[1] for point in contour_points if point[0] == right_x])]
        if str(contract["facing"]) == "left":
            anchors["front_contour"] = left_point
            anchors["rear_contour"] = right_point
        else:
            anchors["front_contour"] = right_point
            anchors["rear_contour"] = left_point
    else:
        errors.append("contour search zone has no opaque pixels")

    if all(key in anchors for key in ("head_top", core_anchor_id, "foot_contact")):
        head_y = int(anchors["head_top"][1])
        core_y = int(anchors[core_anchor_id][1])
        foot_y = int(anchors["foot_contact"][1])
        if foot_y <= head_y:
            errors.append("head_top and foot_contact do not define a positive body span")
        else:
            evidence["core_ratio"] = round((core_y - head_y) / (foot_y - head_y), 4)
    return anchors, evidence, errors


def _frame_metrics(
    image: Image.Image, frame: dict[str, Any], family: dict[str, Any]
) -> dict[str, Any]:
    region = [int(value) for value in frame.get("region", [])]
    if len(region) != 4:
        raise ValueError(f"invalid frame region: {region}")
    x, y, width, height = region
    crop = image.crop((x, y, x + width, y + height))
    alpha = crop.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("empty alpha frame")
    left, top, right, bottom = bbox
    anchors, semantic_evidence, semantic_errors = _semantic_anchors(alpha, bbox, family)
    return {
        "index": int(frame.get("index", 0)),
        "region": region,
        "bbox": [left, top, right, bottom],
        "center_x": round((left + right - 1) / 2.0, 3),
        "top_y": top,
        "bottom_y": bottom - 1,
        "body_width": right - left,
        "body_height": bottom - top,
        "semantic_anchors": anchors,
        "semantic_evidence": semantic_evidence,
        "semantic_detection_errors": semantic_errors,
    }


def scan_asset(
    root: Path,
    family: dict[str, Any],
    asset: dict[str, Any],
    expected_lock: dict[str, Any],
) -> dict[str, Any]:
    """读取一张运行表，返回可序列化的逐帧像素证据与契约错误。"""
    asset_id = str(asset["asset_id"])
    asset_root = root / str(family["asset_root"])
    texture_path = asset_root / f"{asset_id}.png"
    metadata_path = asset_root / f"{asset_id}.frames.json"
    source_path = asset_root / f"{asset_id}.source.json"
    result: dict[str, Any] = {
        "asset_id": asset_id,
        "role": str(asset.get("role", "")),
        "status": str(asset.get("status", "active")),
        "geometry_lock_ready": bool(
            asset.get("geometry_lock_ready", family.get("geometry_lock_ready", False))
        ),
        "identity_lock_ready": bool(
            asset.get("identity_lock_ready", family.get("identity_lock_ready", False))
        ),
        "runtime_binding_allowed": bool(
            asset.get("runtime_binding_allowed", family.get("runtime_binding_allowed", False))
        ),
        "identity_sample_indices": [int(value) for value in asset.get("identity_sample_indices", [])],
        "scale_sample_indices": [
            int(value)
            for value in asset.get(
                "scale_sample_indices", asset.get("identity_sample_indices", [])
            )
        ],
        "root_sample_indices": [int(value) for value in asset.get("root_sample_indices", [])],
        "semantic_sample_indices": [
            int(value)
            for value in asset.get(
                "semantic_sample_indices",
                asset.get("scale_sample_indices", asset.get("identity_sample_indices", [])),
            )
        ],
        "texture": texture_path.resolve().relative_to(root).as_posix(),
        "metadata": metadata_path.resolve().relative_to(root).as_posix(),
        "source": source_path.resolve().relative_to(root).as_posix(),
        "frames": [],
        "contract_errors": [],
        "geometry_errors": [],
        "semantic_errors": [],
    }
    try:
        metadata = _read_json(metadata_path)
        source = _read_json(source_path)
        image = Image.open(texture_path).convert("RGBA")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        result["contract_errors"].append(f"cannot read asset evidence: {error}")
        return result

    expected_cell = [int(value) for value in family["cell"]]
    if metadata.get("model_lock") != expected_lock:
        result["contract_errors"].append("frames sidecar model_lock differs from central contract")
    if source.get("model_lock") != expected_lock:
        result["contract_errors"].append("source sidecar model_lock differs from central contract")
    if [int(value) for value in metadata.get("cell", [])] != expected_cell:
        result["contract_errors"].append(
            f"metadata cell {metadata.get('cell')} != contract cell {expected_cell}"
        )
    frame_records = metadata.get("frames", [])
    if int(metadata.get("frame_count", len(frame_records))) != len(frame_records):
        result["contract_errors"].append("frame_count differs from frames length")

    for list_index, frame in enumerate(frame_records):
        try:
            metrics = _frame_metrics(image, frame, family)
        except (TypeError, ValueError) as error:
            result["geometry_errors"].append(f"frame {list_index}: {error}")
            continue
        if metrics["region"][2:] != expected_cell:
            result["contract_errors"].append(
                f"frame {list_index}: region cell {metrics['region'][2:]} != {expected_cell}"
            )
        result["frames"].append(metrics)
    if not result["frames"]:
        result["geometry_errors"].append("no non-empty frames")
    return result


def audit_manifest(root: Path, manifest: dict[str, Any] | None = None) -> dict[str, Any]:
    """执行全家族审计；自动几何通过不代表人工身份或最终发布通过。"""
    source = manifest if manifest is not None else load_manifest(root)
    manifest_errors = validate_manifest(root, source)
    expected_by_asset = contract_by_asset_id(root, source)
    report: dict[str, Any] = {
        "contract_kind": source.get("contract_kind"),
        "contract_version": source.get("version"),
        "boundary": source.get("boundary"),
        "manifest": DEFAULT_MANIFEST.as_posix(),
        "manifest_errors": manifest_errors,
        "families": [],
    }

    for family in source.get("families", []):
        model_id = str(family["model_id"])
        family_result: dict[str, Any] = {
            "model_id": model_id,
            "label": str(family.get("label", model_id)),
            "canonical_reference": str(family["canonical_reference"]),
            "canonical_frame_index": int(family.get("canonical_frame_index", 0)),
            "cell": [int(value) for value in family["cell"]],
            "center_x": float(family["center_x"]),
            "center_tolerance_px": float(family["center_tolerance_px"]),
            "root_y": int(family["root_y"]),
            "root_tolerance_px": int(family["root_tolerance_px"]),
            "identity_height_ratio": [
                float(family["identity_height_ratio_min"]),
                float(family["identity_height_ratio_max"]),
            ],
            "identity_review_status": str(family.get("identity_review_status", "pending")),
            "identity_lock_ready": bool(family.get("identity_lock_ready", False)),
            "semantic_anchor_contract": family.get("semantic_anchor_contract", {}),
            "assets": [],
        }
        for asset in family.get("assets", []):
            asset_id = str(asset["asset_id"])
            family_result["assets"].append(
                scan_asset(root, family, asset, expected_by_asset[asset_id])
            )

        by_id = {item["asset_id"]: item for item in family_result["assets"]}
        canonical = by_id.get(family_result["canonical_reference"])
        canonical_height = 0
        canonical_core_ratio: float | None = None
        if canonical is None:
            manifest_errors.append(f"{model_id}: canonical scan result missing")
        else:
            frame_by_index = {frame["index"]: frame for frame in canonical["frames"]}
            canonical_frame = frame_by_index.get(family_result["canonical_frame_index"])
            if canonical_frame is None:
                canonical["geometry_errors"].append("canonical frame metric missing")
            else:
                canonical_height = int(canonical_frame["body_height"])
                ratio_value = canonical_frame.get("semantic_evidence", {}).get("core_ratio")
                if isinstance(ratio_value, (int, float)):
                    canonical_core_ratio = float(ratio_value)
        family_result["canonical_body_height"] = canonical_height
        family_result["canonical_core_ratio"] = canonical_core_ratio

        center_x = family_result["center_x"]
        center_tolerance = family_result["center_tolerance_px"]
        root_y = family_result["root_y"]
        root_tolerance = family_result["root_tolerance_px"]
        ratio_min, ratio_max = family_result["identity_height_ratio"]
        semantic_contract = family_result["semantic_anchor_contract"]
        core_anchor_id = str(semantic_contract.get("core_anchor_id", ""))
        required_anchors = {
            str(value) for value in semantic_contract.get("required_anchors", [])
        }
        semantic_root_tolerance = int(
            semantic_contract.get("root_contact_tolerance_px", root_tolerance)
        )
        core_ratio_tolerance = float(
            semantic_contract.get("canonical_core_ratio_tolerance", 0.0)
        )
        facing = str(semantic_contract.get("facing", "right"))
        for asset_result in family_result["assets"]:
            is_active = asset_result["status"] == "active"
            geometry_required = is_active and asset_result["geometry_lock_ready"]
            identity_required = is_active and asset_result["identity_lock_ready"]
            if is_active and not asset_result["geometry_lock_ready"]:
                asset_result["contract_errors"].append("active asset is not geometry_lock_ready")
            if is_active and not asset_result["identity_lock_ready"]:
                asset_result["contract_errors"].append("active asset is not identity_lock_ready")
            if is_active and not asset_result["runtime_binding_allowed"]:
                asset_result["contract_errors"].append("active asset is not runtime_binding_allowed")
            if not is_active and asset_result["runtime_binding_allowed"]:
                asset_result["contract_errors"].append("rejected/reference asset allows runtime binding")
            if not is_active and asset_result["identity_lock_ready"]:
                asset_result["contract_errors"].append("rejected/reference asset is identity_lock_ready")

            frame_by_index = {frame["index"]: frame for frame in asset_result["frames"]}
            if geometry_required:
                for frame in asset_result["frames"]:
                    if abs(float(frame["center_x"]) - center_x) > center_tolerance:
                        asset_result["geometry_errors"].append(
                            f"frame {frame['index']}: center_x {frame['center_x']} outside "
                            f"{center_x} +/- {center_tolerance}"
                        )
                for index in asset_result["root_sample_indices"]:
                    frame = frame_by_index.get(index)
                    if frame is None:
                        asset_result["geometry_errors"].append(
                            f"root sample frame {index} metric missing"
                        )
                    elif abs(int(frame["bottom_y"]) - root_y) > root_tolerance:
                        asset_result["geometry_errors"].append(
                            f"frame {index}: bottom_y {frame['bottom_y']} outside "
                            f"{root_y} +/- {root_tolerance}"
                        )
                if canonical_height <= 0:
                    asset_result["geometry_errors"].append("canonical body height is unavailable")
                else:
                    for index in asset_result["scale_sample_indices"]:
                        frame = frame_by_index.get(index)
                        if frame is None:
                            asset_result["geometry_errors"].append(
                                f"scale sample frame {index} metric missing"
                            )
                            continue
                        ratio = float(frame["body_height"]) / canonical_height
                        frame["canonical_height_ratio"] = round(ratio, 4)
                        if ratio < ratio_min or ratio > ratio_max:
                            asset_result["geometry_errors"].append(
                                f"frame {index}: height ratio {ratio:.3f} outside "
                                f"[{ratio_min:.3f}, {ratio_max:.3f}]"
                            )

            if identity_required:
                if canonical_core_ratio is None:
                    asset_result["semantic_errors"].append(
                        "canonical core ratio is unavailable"
                    )
                for index in asset_result["semantic_sample_indices"]:
                    frame = frame_by_index.get(index)
                    if frame is None:
                        asset_result["semantic_errors"].append(
                            f"semantic sample frame {index} metric missing"
                        )
                        continue
                    for detection_error in frame.get("semantic_detection_errors", []):
                        asset_result["semantic_errors"].append(
                            f"frame {index}: {detection_error}"
                        )
                    anchors = frame.get("semantic_anchors", {})
                    missing = sorted(required_anchors.difference(anchors))
                    if missing:
                        asset_result["semantic_errors"].append(
                            f"frame {index}: missing semantic anchors {missing}"
                        )
                        continue
                    head_y = int(anchors["head_top"][1])
                    core_y = int(anchors[core_anchor_id][1])
                    foot_y = int(anchors["foot_contact"][1])
                    if not head_y < core_y < foot_y:
                        asset_result["semantic_errors"].append(
                            f"frame {index}: vertical topology head={head_y} core={core_y} foot={foot_y}"
                        )
                    front_x = int(anchors["front_contour"][0])
                    rear_x = int(anchors["rear_contour"][0])
                    topology_ok = front_x < rear_x if facing == "left" else front_x > rear_x
                    if not topology_ok:
                        asset_result["semantic_errors"].append(
                            f"frame {index}: facing={facing} front_x={front_x} rear_x={rear_x}"
                        )
                    core_ratio = frame.get("semantic_evidence", {}).get("core_ratio")
                    if canonical_core_ratio is not None and isinstance(core_ratio, (int, float)):
                        frame["canonical_core_ratio_delta"] = round(
                            abs(float(core_ratio) - canonical_core_ratio), 4
                        )
                        if abs(float(core_ratio) - canonical_core_ratio) > core_ratio_tolerance:
                            asset_result["semantic_errors"].append(
                                f"frame {index}: core ratio {float(core_ratio):.3f} outside "
                                f"canonical {canonical_core_ratio:.3f} +/- {core_ratio_tolerance:.3f}"
                            )
                for index in asset_result["root_sample_indices"]:
                    frame = frame_by_index.get(index)
                    if frame is None:
                        continue
                    foot_contact = frame.get("semantic_anchors", {}).get("foot_contact")
                    if not isinstance(foot_contact, list) or len(foot_contact) != 2:
                        continue
                    root_delta = abs(int(foot_contact[1]) - root_y)
                    frame["root_contact_delta"] = root_delta
                    if root_delta > max(root_tolerance, semantic_root_tolerance):
                        asset_result["semantic_errors"].append(
                            f"frame {index}: foot_contact_y {foot_contact[1]} outside "
                            f"root {root_y} +/- {max(root_tolerance, semantic_root_tolerance)}"
                        )

            asset_result["computed_identity_lock_ready"] = bool(
                identity_required
                and not asset_result["contract_errors"]
                and not asset_result["geometry_errors"]
                and not asset_result["semantic_errors"]
            )
            errors = (
                asset_result["contract_errors"]
                + asset_result["geometry_errors"]
                + asset_result["semantic_errors"]
            )
            if asset_result["status"] != "active" and not errors:
                asset_result["audit_status"] = "reference_rejected_as_expected"
            else:
                asset_result["audit_status"] = "pass" if not errors else "fail"
        report["families"].append(family_result)

    assets = [asset for family in report["families"] for asset in family["assets"]]
    failure_count = len(report["manifest_errors"]) + sum(
        len(asset["contract_errors"])
        + len(asset["geometry_errors"])
        + len(asset["semantic_errors"])
        for asset in assets
    )
    report["summary"] = {
        "family_count": len(report["families"]),
        "asset_count": len(assets),
        "active_asset_count": sum(asset["status"] == "active" for asset in assets),
        "rejected_reference_count": sum(asset["status"] != "active" for asset in assets),
        "automated_failure_count": failure_count,
        "geometry_contract_status": "pass" if failure_count == 0 else "fail",
        "identity_lock_contract_status": "pass" if failure_count == 0 else "fail",
        "semantic_anchor_sample_count": sum(
            len(asset["semantic_sample_indices"])
            for asset in assets
            if asset["status"] == "active"
        ),
        "human_identity_status": "pending_gate26h",
    }
    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="审计全部角色 / 怪物 / Boss 模型锁。")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--write-report", type=Path, default=None)
    parser.add_argument("--strict", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    manifest = load_manifest(root, args.manifest)
    report = audit_manifest(root, manifest)
    if args.write_report is not None:
        report_path = args.write_report if args.write_report.is_absolute() else root / args.write_report
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Report: {report_path}")
    summary = report["summary"]
    print(
        "CHARACTER_CREATURE_MODEL_LOCK_AUDIT: "
        f"families={summary['family_count']} assets={summary['asset_count']} "
        f"active={summary['active_asset_count']} rejected={summary['rejected_reference_count']} "
        f"failures={summary['automated_failure_count']} "
        f"identity_lock={summary['identity_lock_contract_status']} "
        f"human_identity={summary['human_identity_status']}"
    )
    if args.strict and int(summary["automated_failure_count"]) > 0:
        for family in report["families"]:
            for asset in family["assets"]:
                for error in (
                    asset["contract_errors"]
                    + asset["geometry_errors"]
                    + asset["semantic_errors"]
                ):
                    print(f"ERROR {family['model_id']} / {asset['asset_id']}: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
