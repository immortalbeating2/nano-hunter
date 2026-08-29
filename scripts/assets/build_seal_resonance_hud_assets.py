#!/usr/bin/env python3
"""构建“镇妖官印”v2 符印共鸣盘的固定尺寸运行图与 AtlasTexture。

本脚本只消费官方去色键 helper 生成的 RGBA：框体仅做 Alpha bbox 裁切、
一次等比缩小和透明居中；符号按固定 3x2 等格裁切，以 Alpha 核心权重质心
与统一光学半径做一次等比缩放和亚像素居中。光学半径同时考虑 95% Alpha
核心分布和等效墨量，避免细长尖端冒充视觉大小。脚本不重绘、不修补、
不拉伸，也不改变六枚符号的固定顺序。
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "assets/source/ai_generated/batch_10/hud_seal_resonance_v2"
ALPHA_ROOT = ROOT / "tests/artifacts/local/seal-resonance-hud-v2/alpha"
OUTPUT_ROOT = ROOT / "assets/art/ui/hud_seal_resonance_v2"
ATLAS_ROOT = ROOT / "assets/art/editor_resources/seal_resonance_symbols_warden_ai02"
ALPHA_CROP_THRESHOLD = 8
FRAME_PADDING = 2
SYMBOL_CORE_THRESHOLD = 16
SYMBOL_CELL_SIZE = (256, 256)
SYMBOL_FOCAL_POINT = (128.0, 128.0)
SYMBOL_FOCAL_TOLERANCE = 0.5
SYMBOL_TARGET_OPTICAL_RADIUS = 60.0
SYMBOL_OPTICAL_RADIUS_RANGE = (57.0, 63.0)
SYMBOL_MAX_CORE_RADIUS = 104.0
SYMBOL_OPTICAL_PERCENTILE = 0.95
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

REFERENCE_PATHS = (
    "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/selected_option_02_command_seal_sha256_941695354052e8fd.png",
    "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/gameplay_resolved_wind_thunder_sha256_66ec712ad638641f.png",
)
STATE_IDENTITY_REFERENCE = (
    "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/"
    "seal_resonance_idle_frame_warden_ai02_source.png"
)
SYMBOL_STYLE_REFERENCE = (
    "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
    "symbol_style_active_candidate_sha256_2ad4bdf8f7909c54.png"
)
SYMBOL_GENERATION_COMPONENTS = (
    {
        "path": (
            "assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/"
            "symbols_micro_clean_grid_sha256_0a7fcf2b809e7853.png"
        ),
        "sha256": "0a7fcf2b809e78539d634a6927d7d8c95d9267dc41e2a3f85116724c21c3d120",
        "role": "accepted_imagegen_micro_hud_clean_grid",
    },
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
HUMAN_REVIEW_BOUNDARY = (
    "User selected Option 02 as the visual direction. Runtime promotion still requires "
    "real-window fidelity and physical-size readability review, pseudo-text inspection, "
    "provenance/license approval and Gate26H before final-art or release promotion."
)

IDLE_PROMPT = """Create ONE corrected production-ready IDLE / compact frame for Nano Hunter's selected Option 02 镇妖官印 resonance HUD. Reference image 1 is the selected hierarchy. Reference image 2 is the accepted expanded state and controls the exact physical identity, material, large element ring, smaller stance ring, hinge language, bronze/black-lacquer construction, and tiny red rivets. Show that SAME apparatus mechanically folded closed.

Isolate one orthographic front-facing asset on a perfectly flat pure #00FF00 chroma-key background. The complete visible non-green silhouette, INCLUDING every pendant, must be between 1.90:1 and 2.08:1 width-to-height. This ratio is mandatory. Make the artifact occupy at least 84% of the canvas height and most of its width. Keep the large element seal recess at least 48% of total visible height, and the smaller stance recess at least 32%, so runtime overlays remain readable at 232x116. Place the large main seal on the left and the clearly separate smaller stance satellite to its right. Fold the long lower sequence rail completely closed behind/into the horizontal body; only a short hinge seam may remain.

The blank official tag must be VERY SHORT and tucked close beside or immediately below the large seal; it may not extend more than 12% of total artifact height below the main body and must not make the silhouette tall. No long dangling tag. Preserve the broad, simple, coherent construction. Blank nearly-black display wells. Aged dark bronze, black lacquer, restrained teal patina, tiny cinnabar pins. Crisp hard edges, no fuzzy halo, no kitbash seams.

Absolutely NO text, characters, numbers, pseudo-writing, runes, elemental glyphs, lightning, wind, baked energy, labels, logos, or extra ornaments. No screen mockup, scene, character, multiple variants, contact sheet, perspective, shadows, floor, gradient, or texture in the chroma background. One isolated frame only."""

ACTIVE_PROMPT = """Targeted production correction of reference image 1, preserving its accepted design. Return ONE isolated active HUD frame on perfectly flat pure #00FF00. Keep the exact large left element housing, smaller stance housing, black-lacquer top body, short tag, lower rail, exactly two small sequence wells, and exactly one large reaction well. Keep the same 2.02:1–2.14:1 overall silhouette and the same Option 02 materials.

Fix ONE structural defect: the upper body and lower rail currently read as two panels with a green gap. Mechanically join them into a single continuous L-shaped artifact using ONE clearly visible broad vertical folding hinge / bronze bridge at the rail's left joint, approximately under the stance housing. The hinge must physically touch both the upper body's lower edge and the lower rail's upper edge. No green gap may remain at this joint. Use a substantial 32–48 px-at-runtime joint with matching black lacquer, bronze side plates, two plain rivets and one restrained cyan seam. It must look engineered as one unfolding device, not a panel pasted below another.

Do not change the semantic wells or add any new well. Keep all display wells empty and nearly black. Do not add text, characters, pseudo-writing, runes, symbols, labels, lightning, wind, energy glyphs, logos, shadows, background scene, multiple variants, or perspective. Crisp edges, no fuzzy seam, no floating components."""

SYMBOLS_PROMPT = """Create ONE exact 3-by-2 production sprite sheet of six simple, high-readability ritual HUD symbols for Nano Hunter's selected Option 02 镇妖官印 resonance apparatus. Use a transparent background. Exact overall layout: 3 equal columns x 2 equal rows, 3:2 aspect ratio, generous clear gap between cells, one centered symbol per cell, no dividers, no frames, no captions.

Fixed semantic order, left to right:
TOP ROW: (1) WIND element — three broad curved cyan-green wind blades forming a simple open swirl; (2) THUNDER element — one bold angular pale-cyan lightning fork inside a loose circular energy stroke; (3) SWIFT stance — a concise forward-sweeping double-chevron / wing stroke in pale blue-white.
BOTTOM ROW: (4) WARD stance — one strong centered shield/lotus silhouette in muted warm gold; (5) PIERCE reaction — one bold straight spearhead/needle passing through a single ring in warm white-gold with one restrained cinnabar accent; (6) SCATTER reaction — one central point splitting into three broad outward rays in warm white-gold with one restrained cinnabar accent.

Visual language: Southern-Northern Dynasties dark-fantasy official talisman instrument, matching the selected Option 02 and expanded bronze command-seal device. Symbols are runtime-emissive overlays made specifically for 29–62 pixel display: crisp broad strokes, large clean color fields, smooth flat fills, strong negative space and at most one simple brighter inner highlight band. All six use one shared optical radius and comparable ink mass; no isolated long tip may enlarge only the bounding radius. Wind and ward must not be denser than thunder and swift. Pierce is a compact thick complete ring with a short broad spear; scatter uses three short broad joined rays without detached sparks.

Critical constraints: exactly six symbols in exactly the stated positions; NO black interior outline, black inset border, dark dots, speckles, scratches, patina, hammered metal, grain, noise, engraving, filigree, mottling or micro-highlights; NO Chinese or Latin text, numbers, pseudo-characters, runes, decorative frames, extra medallion housings, background panels, chains, hanging tags, contact-sheet labels, glow clouds or extra marks. Keep each cell isolated and clean for atlas slicing. One image only."""


@dataclass(frozen=True)
class AssetBuild:
    asset_id: str
    source_name: str
    alpha_name: str
    output_name: str
    target_size: tuple[int, int]
    prompt: str
    process: str


BUILDS = (
    AssetBuild(
        asset_id="seal_resonance_idle_frame_warden_ai02",
        source_name="seal_resonance_idle_frame_warden_ai02_source.png",
        alpha_name="idle.png",
        output_name="seal_resonance_idle_frame_warden_ai02.png",
        target_size=(928, 464),
        prompt=IDLE_PROMPT,
        process="official_remove_chroma_key_soft_matte_despill_edge_contract_1_then_alpha_bbox_crop_single_uniform_downscale_center_pad",
    ),
    AssetBuild(
        asset_id="seal_resonance_active_frame_warden_ai02",
        source_name="seal_resonance_active_frame_warden_ai02_source.png",
        alpha_name="active.png",
        output_name="seal_resonance_active_frame_warden_ai02.png",
        target_size=(1296, 624),
        prompt=ACTIVE_PROMPT,
        process="official_remove_chroma_key_soft_matte_despill_edge_contract_1_then_alpha_bbox_crop_single_uniform_downscale_center_pad",
    ),
    AssetBuild(
        asset_id="seal_resonance_symbols_warden_ai02",
        source_name="seal_resonance_symbols_warden_ai02_source.png",
        alpha_name="symbols.png",
        output_name="seal_resonance_symbols_warden_ai02.png",
        target_size=(768, 512),
        prompt=SYMBOLS_PROMPT,
        process="official_remove_chroma_key_soft_matte_despill_edge_contract_1_then_fixed_3x2_equal_cell_crop_per_cell_alpha_core_weighted_centroid_optical_mass_p95_single_uniform_scale_subpixel_focal_recenter_transparent_center_pad",
    ),
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


def _relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > ALPHA_CROP_THRESHOLD else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise ValueError("RGBA candidate has no visible pixels")
    return bbox


def _fit_without_distortion(
    image: Image.Image, target_size: tuple[int, int], padding: int
) -> Image.Image:
    cropped = image.crop(_visible_bbox(image))
    available_width = target_size[0] - padding * 2
    available_height = target_size[1] - padding * 2
    scale = min(available_width / cropped.width, available_height / cropped.height, 1.0)
    resized_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(resized_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    offset = (
        (target_size[0] - resized.width) // 2,
        (target_size[1] - resized.height) // 2,
    )
    canvas.alpha_composite(resized, offset)
    return canvas


def _build_frame(alpha_path: Path, target_size: tuple[int, int]) -> Image.Image:
    with Image.open(alpha_path) as opened:
        return _fit_without_distortion(opened.convert("RGBA"), target_size, FRAME_PADDING)


def _alpha_core_metrics(image: Image.Image) -> dict[str, object]:
    """复算视觉焦点、95% 分布半径、等效墨量与光学半径。"""

    rgba = image.convert("RGBA")
    weighted_x = 0.0
    weighted_y = 0.0
    weight_total = 0.0
    core_points: list[tuple[float, float, float]] = []
    border_core_pixels = 0
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            alpha = rgba.getpixel((x, y))[3]
            if alpha < SYMBOL_CORE_THRESHOLD:
                continue
            point_x = x + 0.5
            point_y = y + 0.5
            weighted_x += point_x * alpha
            weighted_y += point_y * alpha
            weight_total += alpha
            core_points.append((point_x, point_y, alpha / 255.0))
            if x == 0 or y == 0 or x == width - 1 or y == height - 1:
                border_core_pixels += 1
    if not core_points or weight_total <= 0.0:
        raise ValueError("Symbol cell has no Alpha core pixels")
    centroid = (weighted_x / weight_total, weighted_y / weight_total)
    max_radius = max(
        ((point_x - centroid[0]) ** 2 + (point_y - centroid[1]) ** 2) ** 0.5
        for point_x, point_y, _alpha in core_points
    )
    weighted_radii = sorted(
        (
            (((point_x - centroid[0]) ** 2 + (point_y - centroid[1]) ** 2) ** 0.5, alpha)
            for point_x, point_y, alpha in core_points
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
    return {
        "centroid": centroid,
        "max_radius": max_radius,
        "radial_fill": max_radius / (min(width, height) * 0.5),
        "robust_radius": robust_radius,
        "equivalent_alpha_radius": equivalent_alpha_radius,
        "optical_radius": optical_radius,
        "core_pixel_count": len(core_points),
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


def _assert_micro_clarity(cell: Image.Image, symbol_id: str) -> None:
    metrics = _micro_clarity_metrics(cell)
    if int(metrics["source_isolated_dark_components"]) > SYMBOL_DARK_COMPONENT_MAX_COUNT:
        raise ValueError(f"{symbol_id}: source contains isolated dark texture specks")
    for sample_size, quality in metrics["samples"].items():
        if int(quality["isolated_dark_components"]) > SYMBOL_DARK_COMPONENT_MAX_COUNT:
            raise ValueError(f"{symbol_id}: {sample_size}px sample contains isolated dark texture specks")
        if float(quality["edge_contrast"]) < SYMBOL_MICRO_MIN_EDGE_CONTRAST:
            raise ValueError(
                f"{symbol_id}: {sample_size}px edge contrast {quality['edge_contrast']} is below "
                f"{SYMBOL_MICRO_MIN_EDGE_CONTRAST}"
            )


def _render_symbol_at_keyline(
    source: Image.Image,
    source_focal: tuple[float, float],
    scale: float,
) -> Image.Image:
    inverse_scale = 1.0 / scale
    target_x, target_y = SYMBOL_FOCAL_POINT
    source_x, source_y = source_focal
    return source.transform(
        SYMBOL_CELL_SIZE,
        Image.Transform.AFFINE,
        (
            inverse_scale,
            0.0,
            source_x - target_x * inverse_scale,
            0.0,
            inverse_scale,
            source_y - target_y * inverse_scale,
        ),
        resample=Image.Resampling.BICUBIC,
        fillcolor=(0, 0, 0, 0),
    )


def _translate_symbol_subpixel(image: Image.Image, delta: tuple[float, float]) -> Image.Image:
    return image.transform(
        image.size,
        Image.Transform.AFFINE,
        (1.0, 0.0, -delta[0], 0.0, 1.0, -delta[1]),
        resample=Image.Resampling.BICUBIC,
        fillcolor=(0, 0, 0, 0),
    )


def _normalize_symbol_cell(cell: Image.Image, symbol_id: str) -> tuple[Image.Image, dict[str, object]]:
    source_metrics = _alpha_core_metrics(cell)
    source_focal = tuple(source_metrics["centroid"])
    scale = SYMBOL_TARGET_OPTICAL_RADIUS / float(source_metrics["optical_radius"])
    normalized = _render_symbol_at_keyline(cell, source_focal, scale)

    # 重采样会轻微改变 Alpha 质心与光学半径；每次都从源图重绘，避免累积模糊。
    for _attempt in range(3):
        metrics = _alpha_core_metrics(normalized)
        optical_radius = float(metrics["optical_radius"])
        scale *= SYMBOL_TARGET_OPTICAL_RADIUS / optical_radius
        normalized = _render_symbol_at_keyline(cell, source_focal, scale)
        metrics = _alpha_core_metrics(normalized)
        centroid = tuple(metrics["centroid"])
        delta = (
            SYMBOL_FOCAL_POINT[0] - centroid[0],
            SYMBOL_FOCAL_POINT[1] - centroid[1],
        )
        normalized = _translate_symbol_subpixel(normalized, delta)
        metrics = _alpha_core_metrics(normalized)
        centroid = tuple(metrics["centroid"])
        focal_error = (
            (centroid[0] - SYMBOL_FOCAL_POINT[0]) ** 2
            + (centroid[1] - SYMBOL_FOCAL_POINT[1]) ** 2
        ) ** 0.5
        if (
            focal_error <= SYMBOL_FOCAL_TOLERANCE
            and SYMBOL_OPTICAL_RADIUS_RANGE[0] <= float(metrics["optical_radius"]) <= SYMBOL_OPTICAL_RADIUS_RANGE[1]
            and float(metrics["max_radius"]) <= SYMBOL_MAX_CORE_RADIUS
        ):
            break

    final_metrics = _alpha_core_metrics(normalized)
    final_centroid = tuple(final_metrics["centroid"])
    focal_error = (
        (final_centroid[0] - SYMBOL_FOCAL_POINT[0]) ** 2
        + (final_centroid[1] - SYMBOL_FOCAL_POINT[1]) ** 2
    ) ** 0.5
    optical_radius = float(final_metrics["optical_radius"])
    if focal_error > SYMBOL_FOCAL_TOLERANCE:
        raise ValueError(f"{symbol_id}: focal error {focal_error:.4f}px exceeds contract")
    if not SYMBOL_OPTICAL_RADIUS_RANGE[0] <= optical_radius <= SYMBOL_OPTICAL_RADIUS_RANGE[1]:
        raise ValueError(f"{symbol_id}: optical radius {optical_radius:.4f}px outside contract")
    if float(final_metrics["max_radius"]) > SYMBOL_MAX_CORE_RADIUS:
        raise ValueError(f"{symbol_id}: max core radius {final_metrics['max_radius']:.4f}px exceeds safety keyline")
    if int(final_metrics["border_core_pixels"]) != 0:
        raise ValueError(f"{symbol_id}: Alpha core touches cell border")
    return normalized, {
        "source_focal": [round(source_focal[0], 6), round(source_focal[1], 6)],
        "normalized_focal": [round(final_centroid[0], 6), round(final_centroid[1], 6)],
        "focal_error_px": round(focal_error, 6),
        "max_radius_px": round(float(final_metrics["max_radius"]), 6),
        "radial_fill": round(float(final_metrics["radial_fill"]), 6),
        "robust_radius_px": round(float(final_metrics["robust_radius"]), 6),
        "equivalent_alpha_radius_px": round(float(final_metrics["equivalent_alpha_radius"]), 6),
        "optical_radius_px": round(optical_radius, 6),
        "core_pixel_count": int(final_metrics["core_pixel_count"]),
        "border_core_pixels": int(final_metrics["border_core_pixels"]),
    }


def _build_symbols(alpha_path: Path) -> Image.Image:
    with Image.open(alpha_path) as opened:
        sheet = opened.convert("RGBA")
    if sheet.width % 3 or sheet.height % 2:
        raise ValueError(f"Symbol source must be an exact 3x2 grid, got {sheet.size}")
    source_cell_size = (sheet.width // 3, sheet.height // 2)
    output = Image.new("RGBA", (768, 512), (0, 0, 0, 0))
    for index, (symbol_id, region) in enumerate(SYMBOL_REGIONS):
        column = index % 3
        row = index // 3
        source_box = (
            column * source_cell_size[0],
            row * source_cell_size[1],
            (column + 1) * source_cell_size[0],
            (row + 1) * source_cell_size[1],
        )
        cell = sheet.crop(source_box)
        normalized, _metrics = _normalize_symbol_cell(cell, symbol_id)
        _assert_micro_clarity(normalized, symbol_id)
        output.alpha_composite(normalized, (region[0], region[1]))
    return output


def _symbol_metrics_from_atlas(image: Image.Image) -> dict[str, dict[str, object]]:
    reports: dict[str, dict[str, object]] = {}
    for symbol_id, region in SYMBOL_REGIONS:
        x, y, width, height = region
        metrics = _alpha_core_metrics(image.crop((x, y, x + width, y + height)))
        centroid = tuple(metrics["centroid"])
        reports[symbol_id] = {
            "normalized_focal": [round(centroid[0], 6), round(centroid[1], 6)],
            "focal_error_px": round(
                ((centroid[0] - SYMBOL_FOCAL_POINT[0]) ** 2 + (centroid[1] - SYMBOL_FOCAL_POINT[1]) ** 2) ** 0.5,
                6,
            ),
            "max_radius_px": round(float(metrics["max_radius"]), 6),
            "radial_fill": round(float(metrics["radial_fill"]), 6),
            "robust_radius_px": round(float(metrics["robust_radius"]), 6),
            "equivalent_alpha_radius_px": round(float(metrics["equivalent_alpha_radius"]), 6),
            "optical_radius_px": round(float(metrics["optical_radius"]), 6),
            "core_pixel_count": int(metrics["core_pixel_count"]),
            "border_core_pixels": int(metrics["border_core_pixels"]),
        }
    return reports


def _micro_clarity_metrics_from_atlas(image: Image.Image) -> dict[str, dict[str, object]]:
    reports: dict[str, dict[str, object]] = {}
    for symbol_id, region in SYMBOL_REGIONS:
        x, y, width, height = region
        reports[symbol_id] = _micro_clarity_metrics(image.crop((x, y, x + width, y + height)))
    return reports


def _write_atlas_textures() -> None:
    ATLAS_ROOT.mkdir(parents=True, exist_ok=True)
    atlas_path = "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png"
    for symbol_id, region in SYMBOL_REGIONS:
        text = "\n".join(
            (
                '[gd_resource type="AtlasTexture" load_steps=2 format=3]',
                "",
                f'[ext_resource type="Texture2D" path="{atlas_path}" id="1"]',
                "",
                "[resource]",
                'atlas = ExtResource("1")',
                f"region = Rect2({region[0]}, {region[1]}, {region[2]}, {region[3]})",
                "",
            )
        )
        (ATLAS_ROOT / f"{symbol_id}.atlas_texture.tres").write_text(text, encoding="utf-8")


def _write_source_record(build: AssetBuild, output_path: Path) -> None:
    source_path = SOURCE_ROOT / build.source_name
    with Image.open(source_path) as source_image:
        source_size = list(source_image.size)
    with Image.open(output_path) as output_image:
        output_size = list(output_image.size)
    references = []
    for reference in REFERENCE_PATHS:
        reference_path = ROOT / reference
        references.append({"path": reference, "sha256": _sha256(reference_path)})
    is_symbols = build.asset_id.endswith("symbols_warden_ai02")
    record = {
        "version": 1,
        "project_key": "nano-hunter",
        "project_name": "Nano Hunter",
        "asset_id": build.asset_id,
        "provider": "official OpenAI built-in image_gen",
        "direction": "02_warden_seal_resonance_command_v2",
        "candidate_path": _relative(source_path),
        "source_path": _relative(source_path),
        "candidate_sha256": _sha256(source_path),
        "input_sha256": _sha256(source_path),
        "output_path": _relative(output_path),
        "output_sha256": _sha256(output_path),
        "source_size": source_size,
        "output_size": output_size,
        "reference_inputs": references,
        "process": build.process,
        "allowed_process_steps": (
            SYMBOL_ALLOWED_PROCESS_STEPS if is_symbols else FRAME_ALLOWED_PROCESS_STEPS
        ),
        "prompt": build.prompt,
        "prompt_sha256": _sha256_text(build.prompt),
        "visual_assembly_contract": "seal_resonance_v2_command_seal",
        "runtime_binding_allowed": True,
        "final_ready": False,
        "boundary": HUMAN_REVIEW_BOUNDARY,
    }
    if build.asset_id == "seal_resonance_active_frame_warden_ai02":
        identity_path = ROOT / STATE_IDENTITY_REFERENCE
        record["state_identity_reference"] = {
            "path": STATE_IDENTITY_REFERENCE,
            "sha256": _sha256(identity_path),
        }
    if build.asset_id == "seal_resonance_symbols_warden_ai02":
        style_path = ROOT / SYMBOL_STYLE_REFERENCE
        record["symbol_style_reference"] = {
            "path": SYMBOL_STYLE_REFERENCE,
            "sha256": _sha256(style_path),
        }
        record["generation_components"] = [
            {
                "path": component["path"],
                "sha256": _sha256(ROOT / component["path"]),
                "role": component["role"],
            }
            for component in SYMBOL_GENERATION_COMPONENTS
        ]
        with Image.open(output_path) as opened:
            record["icon_keyline_contract"] = {
                "alpha_core_threshold": SYMBOL_CORE_THRESHOLD,
                "cell_size": list(SYMBOL_CELL_SIZE),
                "normalized_focal_point": list(SYMBOL_FOCAL_POINT),
                "focal_tolerance_px": SYMBOL_FOCAL_TOLERANCE,
                "optical_percentile": SYMBOL_OPTICAL_PERCENTILE,
                "target_optical_radius_px": SYMBOL_TARGET_OPTICAL_RADIUS,
                "optical_radius_range_px": list(SYMBOL_OPTICAL_RADIUS_RANGE),
                "maximum_core_radius_px": SYMBOL_MAX_CORE_RADIUS,
                "method": "alpha_weighted_centroid_optical_mass_p95_single_uniform_scale_subpixel_recenter",
            }
            record["micro_clarity_contract"] = SYMBOL_MICRO_CLARITY_CONTRACT
            record["symbol_metrics"] = _symbol_metrics_from_atlas(opened.convert("RGBA"))
            record["micro_clarity_metrics"] = _micro_clarity_metrics_from_atlas(opened.convert("RGBA"))
    record_path = OUTPUT_ROOT / f"{build.asset_id}.source.json"
    record_path.write_text(
        json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def main() -> int:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    for build in BUILDS:
        source_path = SOURCE_ROOT / build.source_name
        alpha_path = ALPHA_ROOT / build.alpha_name
        if not source_path.is_file():
            raise FileNotFoundError(f"Missing Image Gen source: {source_path}")
        if not alpha_path.is_file():
            raise FileNotFoundError(
                f"Missing alpha candidate: {alpha_path}. Run official remove_chroma_key.py first."
            )
        output = (
            _build_symbols(alpha_path)
            if build.asset_id.endswith("symbols_warden_ai02")
            else _build_frame(alpha_path, build.target_size)
        )
        output_path = OUTPUT_ROOT / build.output_name
        output.save(output_path, format="PNG", optimize=True)
        _write_source_record(build, output_path)
        bbox = _visible_bbox(output)
        print(
            f"Wrote {_relative(output_path)} size={output.size} alpha_bbox={bbox} "
            f"sha256={_sha256(output_path)}"
        )
    _write_atlas_textures()
    print(f"Wrote {len(SYMBOL_REGIONS)} AtlasTexture resources under {_relative(ATLAS_ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
