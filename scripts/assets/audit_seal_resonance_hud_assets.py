#!/usr/bin/env python3
"""审计“镇妖官印”v2 共鸣盘三张运行图、来源记录与六份 AtlasTexture。"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "assets/source/ai_generated/batch_10/hud_seal_resonance_v2"
OUTPUT_ROOT = ROOT / "assets/art/ui/hud_seal_resonance_v2"
ATLAS_ROOT = ROOT / "assets/art/editor_resources/seal_resonance_symbols_warden_ai02"
BUILDER_PATH = ROOT / "scripts/assets/build_seal_resonance_hud_assets.py"
ANCHOR_CONTRACT_PATH = OUTPUT_ROOT / "seal_resonance_anchor_contract.json"
REPORT_PATH = ROOT / "tests/artifacts/local/seal-resonance-hud-v2/audit.json"
VISUAL_CONTRACT = "seal_resonance_v2_command_seal"
PROVIDER = "official OpenAI built-in image_gen"
DIRECTION = "02_warden_seal_resonance_command_v2"
HUMAN_REVIEW_BOUNDARY = (
    "User selected Option 02 as the visual direction. Runtime promotion still requires "
    "real-window fidelity and physical-size readability review, pseudo-text inspection, "
    "provenance/license approval and Gate26H before final-art or release promotion."
)
COMMON_REFERENCES = [
    {
        "path": (
            "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
            "selected_option_02_command_seal_sha256_941695354052e8fd.png"
        ),
        "sha256": "941695354052e8fdfe561136c36a7441d53e870d7d73257da9eb7b0dd2e07241",
    },
    {
        "path": (
            "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
            "gameplay_resolved_wind_thunder_sha256_66ec712ad638641f.png"
        ),
        "sha256": "66ec712ad638641f32f7af4d0d9d2adbfaa19073fc5007944d7a84b4809f567b",
    },
]
REFERENCE_FILE_CONTRACTS = (
    (COMMON_REFERENCES[0]["path"], COMMON_REFERENCES[0]["sha256"], (1672, 941), 2017002),
    (COMMON_REFERENCES[1]["path"], COMMON_REFERENCES[1]["sha256"], (1280, 720), 1177271),
)
FRAME_ALLOWED_PROCESS_STEPS = [
    "official_remove_chroma_key_auto_key_border",
    "soft_matte",
    "despill",
    "edge_contract_1",
    "alpha_bbox_crop",
    "single_uniform_downscale_only",
    "transparent_center_pad",
]
SYMBOL_ALLOWED_PROCESS_STEPS = [
    "imagegen_component_selection",
    "official_remove_chroma_key_auto_key_border",
    "soft_matte",
    "despill",
    "edge_contract_1",
    "fixed_3x2_equal_cell_crop",
    "alpha_core_weighted_centroid",
    "single_uniform_optical_scale",
    "subpixel_focal_recenter",
    "transparent_center_pad",
]
FRAME_PROCESS = (
    "official_remove_chroma_key_soft_matte_despill_edge_contract_1_then_"
    "alpha_bbox_crop_single_uniform_downscale_center_pad"
)
SYMBOL_PROCESS = (
    "official_remove_chroma_key_soft_matte_despill_edge_contract_1_then_"
    "fixed_3x2_equal_cell_crop_per_cell_alpha_core_weighted_centroid_"
    "optical_mass_p95_single_uniform_scale_subpixel_focal_recenter_transparent_center_pad"
)
SYMBOL_CORE_THRESHOLD = 16
SYMBOL_FOCAL_POINT = (128.0, 128.0)
SYMBOL_FOCAL_TOLERANCE = 0.5
SYMBOL_OPTICAL_PERCENTILE = 0.95
SYMBOL_TARGET_OPTICAL_RADIUS = 60.0
SYMBOL_OPTICAL_RADIUS_RANGE = (57.0, 63.0)
SYMBOL_MAX_CORE_RADIUS = 104.0
SYMBOL_DARK_INTERIOR_LUMA_MAX = 0.12
SYMBOL_DARK_INTERIOR_ALPHA_MIN = 96
SYMBOL_DARK_COMPONENT_MAX_AREA = 2
SYMBOL_DARK_COMPONENT_MAX_COUNT = 0
SYMBOL_MICRO_SAMPLE_SIZES = (29, 34)
SYMBOL_MICRO_MIN_EDGE_CONTRAST = 0.18
SYMBOL_MICRO_CLARITY_CONTRACT = {
    "dark_interior_luminance_max": SYMBOL_DARK_INTERIOR_LUMA_MAX,
    "dark_interior_alpha_min": SYMBOL_DARK_INTERIOR_ALPHA_MIN,
    "isolated_dark_component_max_area_px": SYMBOL_DARK_COMPONENT_MAX_AREA,
    "isolated_dark_component_max_count": SYMBOL_DARK_COMPONENT_MAX_COUNT,
    "micro_sample_sizes_px": list(SYMBOL_MICRO_SAMPLE_SIZES),
    "minimum_micro_edge_contrast": SYMBOL_MICRO_MIN_EDGE_CONTRAST,
    "micro_resample_filter": "lanczos",
}
SYMBOL_KEYLINE_CONTRACT = {
    "alpha_core_threshold": SYMBOL_CORE_THRESHOLD,
    "cell_size": [256, 256],
    "normalized_focal_point": [128.0, 128.0],
    "focal_tolerance_px": SYMBOL_FOCAL_TOLERANCE,
    "optical_percentile": SYMBOL_OPTICAL_PERCENTILE,
    "target_optical_radius_px": SYMBOL_TARGET_OPTICAL_RADIUS,
    "optical_radius_range_px": list(SYMBOL_OPTICAL_RADIUS_RANGE),
    "maximum_core_radius_px": SYMBOL_MAX_CORE_RADIUS,
    "method": "alpha_weighted_centroid_optical_mass_p95_single_uniform_scale_subpixel_recenter",
}
ACTIVE_IDENTITY_REFERENCE = {
    "path": (
        "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/"
        "seal_resonance_idle_frame_warden_ai02_source.png"
    ),
    "sha256": "e2bf94cb244cec26d38afad2aba06699b5adb8381af4de6543677e0d9be7b85f",
}
SYMBOL_STYLE_REFERENCE = {
    "path": (
        "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
        "symbol_style_active_candidate_sha256_2ad4bdf8f7909c54.png"
    ),
    "sha256": "2ad4bdf8f7909c54f66e6c0bd895bad272af3cfc650cf94171623b858c25fe96",
}
SYMBOL_GENERATION_COMPONENTS = [
    {
        "path": (
            "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
            "symbols_micro_clean_grid_sha256_0a7fcf2b809e7853.png"
        ),
        "sha256": "0a7fcf2b809e78539d634a6927d7d8c95d9267dc41e2a3f85116724c21c3d120",
        "role": "accepted_imagegen_micro_hud_clean_grid",
    },
]

ASSETS = (
    {
        "asset_id": "seal_resonance_idle_frame_warden_ai02",
        "source_name": "seal_resonance_idle_frame_warden_ai02_source.png",
        "output_size": (928, 464),
        "prompt_sha256": "6bc2bc757852276c739f2302e75a876a30817cfa063d078258b5964bd2b7b9e9",
        "process": FRAME_PROCESS,
        "allowed_process_steps": FRAME_ALLOWED_PROCESS_STEPS,
        "visible_ratio_range": (1.87, 1.91),
    },
    {
        "asset_id": "seal_resonance_active_frame_warden_ai02",
        "source_name": "seal_resonance_active_frame_warden_ai02_source.png",
        "output_size": (1296, 624),
        "prompt_sha256": "79c0cf7d9abda268e00d49290ed27de721eb3debeba8949e61f4855af561c4d8",
        "process": FRAME_PROCESS,
        "allowed_process_steps": FRAME_ALLOWED_PROCESS_STEPS,
        "visible_ratio_range": (2.12, 2.16),
    },
    {
        "asset_id": "seal_resonance_symbols_warden_ai02",
        "source_name": "seal_resonance_symbols_warden_ai02_source.png",
        "output_size": (768, 512),
        "prompt_sha256": "05ba1ec886ca264ddf8923675e26b22119d511cf51045c806b724ce38a0bfa54",
        "process": SYMBOL_PROCESS,
        "allowed_process_steps": SYMBOL_ALLOWED_PROCESS_STEPS,
        "visible_ratio_range": None,
    },
)

SYMBOL_REGIONS = (
    ("wind", (0, 0, 256, 256)),
    ("thunder", (256, 0, 256, 256)),
    ("swift", (512, 0, 256, 256)),
    ("ward", (0, 256, 256, 256)),
    ("wind_thunder_pierce", (256, 256, 256, 256)),
    ("thunder_wind_scatter", (512, 256, 256, 256)),
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").point(lambda value: 255 if value > 8 else 0).getbbox()


def _green_residue_count(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.get_flattened_data():
        if alpha > 8 and green > 220 and red < 80 and blue < 100:
            count += 1
    return count


def _border_alpha_count(cell: Image.Image) -> int:
    alpha = cell.getchannel("A")
    width, height = cell.size
    coordinates = (
        [(x, 0) for x in range(width)]
        + [(x, height - 1) for x in range(width)]
        + [(0, y) for y in range(1, height - 1)]
        + [(width - 1, y) for y in range(1, height - 1)]
    )
    return sum(1 for point in coordinates if alpha.getpixel(point) > 0)


def _alpha_core_metrics(cell: Image.Image) -> dict[str, object]:
    """复算运行 atlas 单格的实际 Alpha 核心，而不是相信 TextureRect 尺寸。"""

    rgba = cell.convert("RGBA")
    weighted_x = 0.0
    weighted_y = 0.0
    weight_total = 0.0
    points: list[tuple[float, float, float]] = []
    border_core_pixels = 0
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            alpha = rgba.getpixel((x, y))[3]
            if alpha < SYMBOL_CORE_THRESHOLD:
                continue
            point = (x + 0.5, y + 0.5)
            weighted_x += point[0] * alpha
            weighted_y += point[1] * alpha
            weight_total += alpha
            points.append((point[0], point[1], alpha / 255.0))
            if x == 0 or y == 0 or x == width - 1 or y == height - 1:
                border_core_pixels += 1
    if not points or weight_total <= 0.0:
        return {
            "normalized_focal": None,
            "focal_error_px": None,
            "max_radius_px": None,
            "radial_fill": None,
            "core_pixel_count": 0,
            "border_core_pixels": border_core_pixels,
        }
    centroid = (weighted_x / weight_total, weighted_y / weight_total)
    max_radius = max(
        ((point_x - centroid[0]) ** 2 + (point_y - centroid[1]) ** 2) ** 0.5
        for point_x, point_y, _alpha in points
    )
    weighted_radii = sorted(
        (
            (((point_x - centroid[0]) ** 2 + (point_y - centroid[1]) ** 2) ** 0.5, alpha)
            for point_x, point_y, alpha in points
        ),
        key=lambda sample: sample[0],
    )
    alpha_weight_total = sum(alpha for _radius, alpha in weighted_radii)
    accumulated_weight = 0.0
    robust_radius = 0.0
    for radius, alpha in weighted_radii:
        accumulated_weight += alpha
        if accumulated_weight >= alpha_weight_total * SYMBOL_OPTICAL_PERCENTILE:
            robust_radius = radius
            break
    equivalent_alpha_radius = (alpha_weight_total / 3.141592653589793) ** 0.5
    optical_radius = (robust_radius * equivalent_alpha_radius) ** 0.5
    focal_error = (
        (centroid[0] - SYMBOL_FOCAL_POINT[0]) ** 2
        + (centroid[1] - SYMBOL_FOCAL_POINT[1]) ** 2
    ) ** 0.5
    return {
        "normalized_focal": [round(centroid[0], 6), round(centroid[1], 6)],
        "focal_error_px": round(focal_error, 6),
        "max_radius_px": round(max_radius, 6),
        "radial_fill": round(max_radius / (min(width, height) * 0.5), 6),
        "robust_radius_px": round(robust_radius, 6),
        "equivalent_alpha_radius_px": round(equivalent_alpha_radius, 6),
        "optical_radius_px": round(optical_radius, 6),
        "core_pixel_count": len(points),
        "border_core_pixels": border_core_pixels,
    }


def _isolated_dark_interior_components(cell: Image.Image) -> list[int]:
    """统计被符号主体四向包围的 1-2px 暗斑，外轮廓与透明背景不计入。"""

    rgba = cell.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
    row_bounds: dict[int, tuple[int, int]] = {}
    column_bounds: dict[int, tuple[int, int]] = {}
    for y in range(height):
        visible_x = [x for x in range(width) if pixels[x, y][3] >= SYMBOL_DARK_INTERIOR_ALPHA_MIN]
        if visible_x:
            row_bounds[y] = (min(visible_x), max(visible_x))
    for x in range(width):
        visible_y = [y for y in range(height) if pixels[x, y][3] >= SYMBOL_DARK_INTERIOR_ALPHA_MIN]
        if visible_y:
            column_bounds[x] = (min(visible_y), max(visible_y))

    dark_points: set[tuple[int, int]] = set()
    for y in range(1, height - 1):
        for x in range(1, width - 1):
            red, green, blue, alpha = pixels[x, y]
            if alpha < SYMBOL_DARK_INTERIOR_ALPHA_MIN:
                continue
            luminance = (red / 255.0) * 0.2126 + (green / 255.0) * 0.7152 + (blue / 255.0) * 0.0722
            if luminance > SYMBOL_DARK_INTERIOR_LUMA_MAX:
                continue
            row_min, row_max = row_bounds.get(y, (x, x))
            column_min, column_max = column_bounds.get(x, (y, y))
            if row_min < x < row_max and column_min < y < column_max:
                dark_points.add((x, y))

    component_areas: list[int] = []
    while dark_points:
        seed = dark_points.pop()
        pending = [seed]
        area = 0
        while pending:
            x, y = pending.pop()
            area += 1
            for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if neighbor in dark_points:
                    dark_points.remove(neighbor)
                    pending.append(neighbor)
        if area <= SYMBOL_DARK_COMPONENT_MAX_AREA:
            component_areas.append(area)
    return sorted(component_areas)


def _micro_glyph_quality(cell: Image.Image, sample_size: int) -> dict[str, object]:
    micro = cell.convert("RGBA").resize((sample_size, sample_size), Image.Resampling.LANCZOS)
    pixels = micro.load()
    edge_samples = 0
    edge_contrast_total = 0.0
    for y in range(1, sample_size - 1):
        for x in range(1, sample_size - 1):
            alpha = pixels[x, y][3] / 255.0
            if alpha <= 0.1:
                continue
            max_neighbor_delta = max(
                abs(alpha - pixels[x - 1, y][3] / 255.0),
                abs(alpha - pixels[x + 1, y][3] / 255.0),
                abs(alpha - pixels[x, y - 1][3] / 255.0),
                abs(alpha - pixels[x, y + 1][3] / 255.0),
            )
            if max_neighbor_delta > 0.05:
                edge_samples += 1
                edge_contrast_total += max_neighbor_delta
    return {
        "isolated_dark_components": len(_isolated_dark_interior_components(micro)),
        "edge_contrast": round(edge_contrast_total / max(1, edge_samples), 6),
    }


def _micro_clarity_metrics(cell: Image.Image) -> dict[str, object]:
    return {
        "source_isolated_dark_components": len(_isolated_dark_interior_components(cell)),
        "samples": {
            str(sample_size): _micro_glyph_quality(cell, sample_size)
            for sample_size in SYMBOL_MICRO_SAMPLE_SIZES
        },
    }


def _audit_anchor_contract(errors: list[str]) -> dict[str, object]:
    expected = {
        "contract_id": "seal_resonance_semantic_anchors_v2",
        "schema_version": 2,
        "static_center_tolerance": 0.5,
        "label_circle_gap_px": 8.0,
    }
    if not ANCHOR_CONTRACT_PATH.is_file():
        errors.append("missing seal_resonance_anchor_contract.json")
        return {"missing": True}
    try:
        contract = json.loads(ANCHOR_CONTRACT_PATH.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        errors.append(f"invalid seal resonance anchor contract: {exc}")
        return {"invalid": True}
    for key, value in expected.items():
        if contract.get(key) != value:
            errors.append(f"anchor contract {key}={contract.get(key)!r}, expected {value!r}")
    if contract.get("symbol_pixel_gate") != {
        "atlas_path": "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png",
        "atlas_size": [768, 512],
        "cell_size": [256, 256],
        "alpha_core_threshold": 16,
        "focal_method": "alpha_weighted_centroid_of_core_pixels",
        "normalized_focal_point": [128.0, 128.0],
        "focal_tolerance_px": 0.5,
        "final_raster_focal_tolerance_logical_px": 0.8,
        "final_raster_focal_tolerance_physical_px": 1.25,
        "optical_percentile": 0.95,
        "target_optical_radius_px": 60.0,
        "optical_radius_range_px": [57.0, 63.0],
        "maximum_core_radius_px": 104.0,
        "sequence_runtime_circle_diameter_px": 29.0,
        "reaction_runtime_circle_diameter_px": 34.0,
        "reaction_to_sequence_optical_ratio_range": [1.14, 1.21],
        "minimum_runtime_core_inset_px": 2.0,
        "dark_interior_luminance_max": 0.12,
        "dark_interior_alpha_min": 96,
        "isolated_dark_component_max_area_px": 2,
        "isolated_dark_component_max_count": 0,
        "micro_sample_sizes_px": [29, 34],
        "minimum_micro_edge_contrast": 0.18,
        "micro_resample_filter": "lanczos",
        "mask_shader_path": "res://assets/shaders/ui/seal_resonance_icon_circle_mask.gdshader",
        "mask_radius_normalized": 0.49,
        "mask_feather_normalized": 0.01,
    }:
        errors.append("anchor contract symbol_pixel_gate mismatch")
    motion = contract.get("motion_envelopes", {})
    if not isinstance(motion, dict) or motion.get("position_translation_allowed") is not False:
        errors.append("anchor contract must prohibit icon position translation")
    return {
        "contract_id": contract.get("contract_id"),
        "schema_version": contract.get("schema_version"),
        "symbol_pixel_gate": contract.get("symbol_pixel_gate"),
    }


def _audit_frozen_references(errors: list[str]) -> list[dict[str, object]]:
    """验证本轮选择稿与实机上下文副本，拒绝可变截图或同名替换。"""

    reports: list[dict[str, object]] = []
    for relative_path, expected_sha, expected_size, expected_bytes in REFERENCE_FILE_CONTRACTS:
        path = ROOT / relative_path
        report: dict[str, object] = {"path": relative_path}
        reports.append(report)
        if not path.is_file():
            errors.append(f"missing frozen reference {relative_path}")
            continue
        byte_count = path.stat().st_size
        digest = _sha256(path)
        report.update({"bytes": byte_count, "sha256": digest})
        if byte_count != expected_bytes:
            errors.append(
                f"frozen reference {relative_path} bytes={byte_count}, expected {expected_bytes}"
            )
        if digest != expected_sha:
            errors.append(f"frozen reference SHA256 mismatch {relative_path}")
        try:
            with Image.open(path) as opened:
                image_format = opened.format
                image_size = opened.size
        except (OSError, ValueError) as exc:
            errors.append(f"invalid frozen reference PNG {relative_path}: {exc}")
            continue
        report.update({"size": list(image_size), "format": image_format})
        if image_format != "PNG":
            errors.append(f"frozen reference {relative_path} format={image_format!r}")
        if image_size != expected_size:
            errors.append(
                f"frozen reference {relative_path} size={image_size}, expected {expected_size}"
            )
    return reports


def _validate_reference_inputs(
    references: object, asset_id: str, errors: list[str]
) -> None:
    """验证两条共同参考的顺序、路径与 SHA，拒绝自报式漂移。"""

    if references != COMMON_REFERENCES:
        errors.append(f"{asset_id}: reference_inputs must equal the two frozen references")


def _extract_builder_reference_paths(
    builder_source: str, errors: list[str]
) -> list[str]:
    """只读解析 builder 的常量，不导入模块或触发任何资产写入。"""

    try:
        module = ast.parse(builder_source, filename=BUILDER_PATH.as_posix())
    except SyntaxError as exc:
        errors.append(f"builder source cannot be parsed: {exc}")
        return []
    assignments = []
    for node in module.body:
        if not isinstance(node, ast.Assign):
            continue
        if any(
            isinstance(target, ast.Name) and target.id == "REFERENCE_PATHS"
            for target in node.targets
        ):
            assignments.append(node.value)
    if len(assignments) != 1:
        errors.append(
            f"builder must define exactly one top-level REFERENCE_PATHS, got {len(assignments)}"
        )
        return []
    try:
        value = ast.literal_eval(assignments[0])
    except (TypeError, ValueError) as exc:
        errors.append(f"builder REFERENCE_PATHS must be a literal tuple/list: {exc}")
        return []
    if not isinstance(value, (tuple, list)) or not all(
        isinstance(item, str) for item in value
    ):
        errors.append("builder REFERENCE_PATHS must contain only literal project-relative strings")
        return []
    return list(value)


def _audit_builder_reference_contract(
    errors: list[str], builder_source: str | None = None
) -> list[dict[str, str | None]]:
    """复算 builder 的有效 path+SHA，并与 strict 冻结合同精确比对。"""

    if builder_source is None:
        try:
            builder_source = BUILDER_PATH.read_text(encoding="utf-8")
        except OSError as exc:
            errors.append(f"cannot read builder source: {exc}")
            return []
    paths = _extract_builder_reference_paths(builder_source, errors)
    effective: list[dict[str, str | None]] = []
    for reference in paths:
        reference_path = ROOT / reference
        digest = _sha256(reference_path) if reference_path.is_file() else None
        effective.append({"path": reference, "sha256": digest})
    if effective != COMMON_REFERENCES:
        errors.append(
            "builder REFERENCE_PATHS effective path+SHA contract must equal COMMON_REFERENCES"
        )
    return effective


def _audit_asset(spec: dict[str, object], errors: list[str]) -> dict[str, object]:
    asset_id = str(spec["asset_id"])
    source_name = str(spec["source_name"])
    expected_size = tuple(spec["output_size"])
    source_path = SOURCE_ROOT / source_name
    output_path = OUTPUT_ROOT / f"{asset_id}.png"
    record_path = OUTPUT_ROOT / f"{asset_id}.source.json"
    for path in (source_path, output_path, record_path):
        if not path.is_file():
            errors.append(f"{asset_id}: missing {path.relative_to(ROOT).as_posix()}")
            return {"asset_id": asset_id, "missing": True}

    record = json.loads(record_path.read_text(encoding="utf-8"))
    with Image.open(source_path) as opened:
        source_size = opened.size
    with Image.open(output_path) as opened:
        image = opened.convert("RGBA")
        original_mode = opened.mode

    if original_mode != "RGBA":
        errors.append(f"{asset_id}: output mode {original_mode}, expected RGBA")
    if image.size != expected_size:
        errors.append(f"{asset_id}: output size {image.size}, expected {expected_size}")
    corners = (
        image.getpixel((0, 0))[3],
        image.getpixel((image.width - 1, 0))[3],
        image.getpixel((0, image.height - 1))[3],
        image.getpixel((image.width - 1, image.height - 1))[3],
    )
    if corners != (0, 0, 0, 0):
        errors.append(f"{asset_id}: corner alpha must be zero, got {corners}")
    bbox = _visible_bbox(image)
    visible_ratio = None
    if bbox is None:
        errors.append(f"{asset_id}: no visible pixels")
    else:
        visible_ratio = (bbox[2] - bbox[0]) / (bbox[3] - bbox[1])
        ratio_range = spec["visible_ratio_range"]
        if ratio_range is not None:
            minimum, maximum = ratio_range
            if not minimum <= visible_ratio <= maximum:
                errors.append(
                    f"{asset_id}: visible ratio {visible_ratio:.4f} outside "
                    f"[{minimum:.4f}, {maximum:.4f}]"
                )
    green_residue = _green_residue_count(image)
    if green_residue:
        errors.append(f"{asset_id}: green residue pixels={green_residue}")

    source_hash = _sha256(source_path)
    output_hash = _sha256(output_path)
    candidate_path = source_path.relative_to(ROOT).as_posix()
    expected_output_path = output_path.relative_to(ROOT).as_posix()
    expected_fields = {
        "version": 1,
        "project_key": "nano-hunter",
        "project_name": "Nano Hunter",
        "asset_id": asset_id,
        "provider": PROVIDER,
        "direction": DIRECTION,
        "candidate_path": candidate_path,
        "source_path": candidate_path,
        "candidate_sha256": source_hash,
        "input_sha256": source_hash,
        "output_path": expected_output_path,
        "output_sha256": output_hash,
        "source_size": list(source_size),
        "output_size": list(expected_size),
        "process": spec["process"],
        "allowed_process_steps": spec["allowed_process_steps"],
        "prompt_sha256": spec["prompt_sha256"],
        "visual_assembly_contract": VISUAL_CONTRACT,
        "runtime_binding_allowed": True,
        "final_ready": False,
        "boundary": HUMAN_REVIEW_BOUNDARY,
    }
    for key, expected in expected_fields.items():
        if record.get(key) != expected:
            errors.append(
                f"{asset_id}: source record {key}={record.get(key)!r}, expected {expected!r}"
            )
    prompt = record.get("prompt")
    if not isinstance(prompt, str) or _sha256_text(prompt) != spec["prompt_sha256"]:
        errors.append(f"{asset_id}: full frozen prompt hash mismatch")

    references = record.get("reference_inputs")
    _validate_reference_inputs(references, asset_id, errors)
    for reference in COMMON_REFERENCES:
        reference_path = ROOT / reference["path"]
        if not reference_path.is_file():
            errors.append(f"{asset_id}: missing frozen reference {reference['path']}")
        elif _sha256(reference_path) != reference["sha256"]:
            errors.append(f"{asset_id}: frozen reference SHA mismatch {reference['path']}")

    if asset_id == "seal_resonance_active_frame_warden_ai02":
        if record.get("state_identity_reference") != ACTIVE_IDENTITY_REFERENCE:
            errors.append(f"{asset_id}: state identity reference mismatch")
        identity_path = ROOT / ACTIVE_IDENTITY_REFERENCE["path"]
        if not identity_path.is_file() or _sha256(identity_path) != ACTIVE_IDENTITY_REFERENCE["sha256"]:
            errors.append(f"{asset_id}: frozen idle identity source SHA mismatch")
    elif "state_identity_reference" in record:
        errors.append(f"{asset_id}: unexpected state_identity_reference")

    if asset_id == "seal_resonance_symbols_warden_ai02":
        if record.get("symbol_style_reference") != SYMBOL_STYLE_REFERENCE:
            errors.append(f"{asset_id}: symbol style reference mismatch")
        style_path = ROOT / SYMBOL_STYLE_REFERENCE["path"]
        if not style_path.is_file() or _sha256(style_path) != SYMBOL_STYLE_REFERENCE["sha256"]:
            errors.append(f"{asset_id}: frozen symbol style source SHA mismatch")
        if record.get("icon_keyline_contract") != SYMBOL_KEYLINE_CONTRACT:
            errors.append(f"{asset_id}: icon_keyline_contract mismatch")
        if record.get("micro_clarity_contract") != SYMBOL_MICRO_CLARITY_CONTRACT:
            errors.append(f"{asset_id}: micro_clarity_contract mismatch")
        if record.get("generation_components") != SYMBOL_GENERATION_COMPONENTS:
            errors.append(f"{asset_id}: generation_components mismatch")
        for component in SYMBOL_GENERATION_COMPONENTS:
            component_path = ROOT / component["path"]
            if not component_path.is_file():
                errors.append(f"{asset_id}: missing generation component {component['path']}")
            elif _sha256(component_path) != component["sha256"]:
                errors.append(f"{asset_id}: generation component SHA mismatch {component['path']}")
    elif "symbol_style_reference" in record:
        errors.append(f"{asset_id}: unexpected symbol_style_reference")

    return {
        "asset_id": asset_id,
        "source_size": list(source_size),
        "output_size": list(image.size),
        "alpha_bbox": list(bbox) if bbox else None,
        "visible_ratio": visible_ratio,
        "corner_alpha": list(corners),
        "green_residue_pixels": green_residue,
        "source_sha256": source_hash,
        "output_sha256": output_hash,
    }


def _audit_symbols(errors: list[str]) -> list[dict[str, object]]:
    path = OUTPUT_ROOT / "seal_resonance_symbols_warden_ai02.png"
    if not path.is_file():
        return []
    with Image.open(path) as opened:
        image = opened.convert("RGBA")
    reports = []
    record_path = OUTPUT_ROOT / "seal_resonance_symbols_warden_ai02.source.json"
    record = json.loads(record_path.read_text(encoding="utf-8")) if record_path.is_file() else {}
    recorded_metrics = record.get("symbol_metrics", {})
    recorded_clarity_metrics = record.get("micro_clarity_metrics", {})
    for symbol_id, region in SYMBOL_REGIONS:
        x, y, width, height = region
        cell = image.crop((x, y, x + width, y + height))
        bbox = _visible_bbox(cell)
        visible_pixels = sum(
            1 for alpha in cell.getchannel("A").get_flattened_data() if alpha > 8
        )
        border_alpha = _border_alpha_count(cell)
        metrics = _alpha_core_metrics(cell)
        clarity_metrics = _micro_clarity_metrics(cell)
        if not visible_pixels:
            errors.append(f"{symbol_id}: symbol cell has no visible pixels")
        if border_alpha:
            errors.append(f"{symbol_id}: visible pixels touch/cross fixed cell border")
        focal_error = metrics.get("focal_error_px")
        optical_radius = metrics.get("optical_radius_px")
        max_radius = metrics.get("max_radius_px")
        if focal_error is None or float(focal_error) > SYMBOL_FOCAL_TOLERANCE:
            errors.append(f"{symbol_id}: Alpha focal error {focal_error} exceeds {SYMBOL_FOCAL_TOLERANCE}")
        if optical_radius is None or not SYMBOL_OPTICAL_RADIUS_RANGE[0] <= float(optical_radius) <= SYMBOL_OPTICAL_RADIUS_RANGE[1]:
            errors.append(f"{symbol_id}: optical radius {optical_radius} outside {SYMBOL_OPTICAL_RADIUS_RANGE}")
        if max_radius is None or float(max_radius) > SYMBOL_MAX_CORE_RADIUS:
            errors.append(f"{symbol_id}: max core radius {max_radius} exceeds {SYMBOL_MAX_CORE_RADIUS}")
        if int(metrics.get("border_core_pixels", -1)) != 0:
            errors.append(f"{symbol_id}: Alpha core touches/crosses fixed cell border")
        if not isinstance(recorded_metrics, dict) or recorded_metrics.get(symbol_id) != metrics:
            errors.append(f"{symbol_id}: recorded symbol_metrics do not match runtime pixels")
        if (
            not isinstance(recorded_clarity_metrics, dict)
            or recorded_clarity_metrics.get(symbol_id) != clarity_metrics
        ):
            errors.append(f"{symbol_id}: recorded micro_clarity_metrics do not match runtime pixels")
        if int(clarity_metrics["source_isolated_dark_components"]) > SYMBOL_DARK_COMPONENT_MAX_COUNT:
            errors.append(f"{symbol_id}: source contains isolated dark texture specks")
        for sample_size, quality in clarity_metrics["samples"].items():
            if int(quality["isolated_dark_components"]) > SYMBOL_DARK_COMPONENT_MAX_COUNT:
                errors.append(f"{symbol_id}: {sample_size}px sample contains isolated dark texture specks")
            if float(quality["edge_contrast"]) < SYMBOL_MICRO_MIN_EDGE_CONTRAST:
                errors.append(
                    f"{symbol_id}: {sample_size}px edge contrast {quality['edge_contrast']} is below "
                    f"{SYMBOL_MICRO_MIN_EDGE_CONTRAST}"
                )
        reports.append(
            {
                "symbol_id": symbol_id,
                "region": list(region),
                "alpha_bbox_in_cell": list(bbox) if bbox else None,
                "visible_pixels": visible_pixels,
                "border_alpha_pixels": border_alpha,
                "micro_clarity": clarity_metrics,
                **metrics,
            }
        )
    return reports


def _audit_atlas_textures(errors: list[str]) -> list[dict[str, object]]:
    expected_names = {f"{symbol_id}.atlas_texture.tres" for symbol_id, _ in SYMBOL_REGIONS}
    actual_names = {path.name for path in ATLAS_ROOT.glob("*.atlas_texture.tres")} if ATLAS_ROOT.is_dir() else set()
    if actual_names != expected_names:
        errors.append(
            f"AtlasTexture file set mismatch: actual={sorted(actual_names)} expected={sorted(expected_names)}"
        )
    reports = []
    expected_atlas = 'path="res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png"'
    for symbol_id, region in SYMBOL_REGIONS:
        path = ATLAS_ROOT / f"{symbol_id}.atlas_texture.tres"
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        expected_region = f"region = Rect2({region[0]}, {region[1]}, {region[2]}, {region[3]})"
        if '[gd_resource type="AtlasTexture"' not in text:
            errors.append(f"{symbol_id}: resource type is not AtlasTexture")
        if expected_atlas not in text:
            errors.append(f"{symbol_id}: atlas path mismatch")
        if expected_region not in text:
            errors.append(f"{symbol_id}: region mismatch")
        reports.append({"symbol_id": symbol_id, "path": path.relative_to(ROOT).as_posix(), "region": list(region)})
    return reports


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="Return non-zero when any audit error is found.")
    args = parser.parse_args()
    errors: list[str] = []

    expected_sources = {str(spec["source_name"]) for spec in ASSETS}
    actual_sources = (
        {path.name for path in SOURCE_ROOT.glob("*_source.png")}
        if SOURCE_ROOT.is_dir()
        else set()
    )
    if actual_sources != expected_sources:
        errors.append(
            f"Source PNG set mismatch: actual={sorted(actual_sources)} expected={sorted(expected_sources)}"
        )

    _audit_builder_reference_contract(errors)
    frozen_references = _audit_frozen_references(errors)
    anchor_contract = _audit_anchor_contract(errors)
    assets = [_audit_asset(spec, errors) for spec in ASSETS]
    symbols = _audit_symbols(errors)
    atlas_textures = _audit_atlas_textures(errors)
    report = {
        "ok": not errors,
        "strict": args.strict,
        "source_png_count": len(actual_sources),
        "frozen_references": frozen_references,
        "anchor_contract": anchor_contract,
        "assets": assets,
        "symbols": symbols,
        "atlas_textures": atlas_textures,
        "errors": errors,
        "human_review_boundary": HUMAN_REVIEW_BOUNDARY,
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    for asset in assets:
        print(
            f"{asset['asset_id']}: source={asset.get('source_size')} output={asset.get('output_size')} "
            f"alpha_bbox={asset.get('alpha_bbox')} visible_ratio={asset.get('visible_ratio')} "
            f"green={asset.get('green_residue_pixels')}"
        )
    for reference in frozen_references:
        print(
            f"frozen reference: path={reference.get('path')} size={reference.get('size')} "
            f"bytes={reference.get('bytes')} sha256={reference.get('sha256')}"
        )
    for symbol in symbols:
        print(
            f"{symbol['symbol_id']}: region={symbol['region']} bbox={symbol['alpha_bbox_in_cell']} "
            f"visible={symbol['visible_pixels']} border_alpha={symbol['border_alpha_pixels']} "
            f"focal={symbol.get('normalized_focal')} focal_error={symbol.get('focal_error_px')} "
            f"radius={symbol.get('max_radius_px')} optical={symbol.get('optical_radius_px')} "
            f"micro={symbol.get('micro_clarity')}"
        )
    print(
        f"seal-resonance HUD audit: sources={len(actual_sources)} assets={len(assets)} "
        f"symbols={len(symbols)} atlas={len(atlas_textures)} errors={len(errors)} ok={not errors}"
    )
    for error in errors:
        print(f"ERROR: {error}")
    return 1 if args.strict and errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
