#!/usr/bin/env python3
"""Audit character SpriteFrames for formal runtime replacement readiness."""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from statistics import median
from typing import Any

from PIL import Image


DEFAULT_ATLAS_MANIFEST = "docs/assets/asset-atlas-build-manifest.json"
DEFAULT_REPORT_JSON = "docs/assets/animation-runtime-replacement-audit-report.json"
DEFAULT_REPORT_MD = "docs/assets/animation-runtime-replacement-audit-report.md"
ARCHIVED_REFERENCE_KINDS = {
    "archived_sprite_sheet_reference",
    "archived_blocked_sprite_sheet_reference",
    "blocked_sprite_sheet_reference",
}
ARCHIVED_REFERENCE_STATUSES = {
    "archived_reference",
    "archived_blocked_reference",
    "superseded_reference",
    "blocked_candidate_reference",
}


@dataclass(frozen=True)
class GateProfile:
    min_edge_padding_px: int
    recommended_horizontal_padding_px: int
    max_foot_baseline_variance_px: int
    max_center_variance_px: int
    max_size_variance_ratio: float
    max_detached_component_area_ratio: float
    min_detached_component_area_px: int
    require_no_duplicate_frame_hashes: bool


DEFAULT_PROFILE = GateProfile(
    min_edge_padding_px=4,
    recommended_horizontal_padding_px=12,
    max_foot_baseline_variance_px=10,
    max_center_variance_px=28,
    max_size_variance_ratio=0.45,
    max_detached_component_area_ratio=0.08,
    min_detached_component_area_px=160,
    require_no_duplicate_frame_hashes=True,
)

WIDE_ACTION_PROFILE = GateProfile(
    min_edge_padding_px=8,
    recommended_horizontal_padding_px=24,
    max_foot_baseline_variance_px=12,
    max_center_variance_px=36,
    max_size_variance_ratio=0.55,
    max_detached_component_area_ratio=0.08,
    min_detached_component_area_px=160,
    require_no_duplicate_frame_hashes=True,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit animation sprite sheets against formal runtime replacement gates.",
    )
    parser.add_argument("--atlas-manifest", default=DEFAULT_ATLAS_MANIFEST)
    parser.add_argument(
        "--candidate-manifest",
        default="",
        help="Optional candidate manifest with an outputs list to audit instead of the atlas manifest.",
    )
    parser.add_argument("--report-json", default=DEFAULT_REPORT_JSON)
    parser.add_argument("--report-md", default=DEFAULT_REPORT_MD)
    parser.add_argument("--write-report", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument(
        "--include-archived",
        action="store_true",
        help="Also audit archived / superseded references as active blockers.",
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


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def is_character_sprite_sheet(item: dict[str, Any]) -> bool:
    if item.get("kind") != "sprite_sheet":
        return False
    output = str(item.get("output", "")).replace("\\", "/")
    return "/characters/" in f"/{output}"


def is_archived_reference(item: dict[str, Any]) -> bool:
    return (
        str(item.get("kind", "")) in ARCHIVED_REFERENCE_KINDS
        or str(item.get("status", "")) in ARCHIVED_REFERENCE_STATUSES
    )


def audit_items_from_args(root: Path, args: argparse.Namespace) -> tuple[list[dict[str, Any]], list[dict[str, Any]], str]:
    if args.candidate_manifest:
        manifest_path = resolve_path(root, args.candidate_manifest)
        manifest = load_json(manifest_path)
        candidates = [
            item for item in manifest.get("outputs", [])
            if item.get("kind") in ("sprite_sheet", "blocked_sprite_sheet_reference", "archived_sprite_sheet_reference", "archived_blocked_sprite_sheet_reference")
        ]
        archived = [item for item in candidates if is_archived_reference(item)]
        active = candidates if args.include_archived else [item for item in candidates if not is_archived_reference(item)]
        return active, archived, rel(manifest_path, root)
    manifest_path = resolve_path(root, args.atlas_manifest)
    manifest = load_json(manifest_path)
    items = [item for item in manifest.get("outputs", []) if is_character_sprite_sheet(item)]
    return items, [], rel(manifest_path, root)


def audit_archived_references(root: Path, archived_items: list[dict[str, Any]], active_items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    active_ids = {str(item.get("id", "")) for item in active_items}
    rows: list[dict[str, Any]] = []
    for item in archived_items:
        superseded_by = item.get("superseded_by", [])
        if not isinstance(superseded_by, list):
            superseded_by = []
        replacements: list[dict[str, Any]] = []
        errors: list[str] = []
        if not superseded_by:
            errors.append("missing_superseded_by")
        for replacement in superseded_by:
            if not isinstance(replacement, dict):
                errors.append("invalid_superseded_by_entry")
                continue
            replacement_id = str(replacement.get("id", ""))
            replacement_path = str(replacement.get("path", ""))
            id_ok = bool(replacement_id) and replacement_id in active_ids
            path_ok = bool(replacement_path) and resolve_path(root, replacement_path).exists()
            if not id_ok and not path_ok:
                errors.append(f"missing_replacement:{replacement_id or replacement_path or 'empty'}")
            replacements.append(
                {
                    "id": replacement_id,
                    "path": replacement_path,
                    "id_ok": id_ok,
                    "path_ok": path_ok,
                }
            )

        rows.append(
            {
                "asset_id": str(item.get("id", "")),
                "kind": str(item.get("kind", "")),
                "status": str(item.get("status", "")),
                "blocked_reason": str(item.get("blocked_reason", "")),
                "archival_reason": str(item.get("archival_reason", "")),
                "replacements": replacements,
                "errors": errors,
                "ok": not errors,
            }
        )
    return rows


def profile_for(asset_id: str) -> GateProfile:
    if any(token in asset_id for token in ("attack", "air_dash", "boss")):
        return WIDE_ACTION_PROFILE
    return DEFAULT_PROFILE


def frame_hash(crop: Image.Image) -> int:
    return hash(crop.tobytes())


def connected_components(crop: Image.Image, alpha_threshold: int = 12) -> list[dict[str, Any]]:
    alpha = crop.getchannel("A")
    pixels = alpha.load()
    width, height = crop.size
    visited: set[tuple[int, int]] = set()
    components: list[dict[str, Any]] = []

    for y in range(height):
        for x in range(width):
            if pixels[x, y] <= alpha_threshold or (x, y) in visited:
                continue

            stack = [(x, y)]
            visited.add((x, y))
            area = 0
            min_x = max_x = x
            min_y = max_y = y
            while stack:
                current_x, current_y = stack.pop()
                area += 1
                min_x = min(min_x, current_x)
                max_x = max(max_x, current_x)
                min_y = min(min_y, current_y)
                max_y = max(max_y, current_y)
                for next_x, next_y in (
                    (current_x + 1, current_y),
                    (current_x - 1, current_y),
                    (current_x, current_y + 1),
                    (current_x, current_y - 1),
                ):
                    if next_x < 0 or next_y < 0 or next_x >= width or next_y >= height:
                        continue
                    if (next_x, next_y) in visited or pixels[next_x, next_y] <= alpha_threshold:
                        continue
                    visited.add((next_x, next_y))
                    stack.append((next_x, next_y))

            components.append(
                {
                    "area": area,
                    "bbox": [min_x, min_y, max_x + 1, max_y + 1],
                }
            )

    components.sort(key=lambda component: int(component["area"]), reverse=True)
    return components


def audit_frame(
    image: Image.Image,
    frame: dict[str, Any],
    cell: list[int],
) -> dict[str, Any]:
    x, y, width, height = [int(value) for value in frame["region"]]
    crop = image.crop((x, y, x + width, y + height)).convert("RGBA")
    bbox = crop.getchannel("A").getbbox()
    row: dict[str, Any] = {
        "index": int(frame["index"]),
        "name": str(frame.get("name", "")),
        "region": [x, y, width, height],
        "hash": frame_hash(crop),
        "empty": bbox is None,
    }
    if bbox is None:
        row.update(
            {
                "bbox": None,
                "margins": None,
                "content_size": [0, 0],
                "center": None,
                "foot_y": None,
            }
        )
        return row

    components = connected_components(crop)
    left, top, right, bottom = [int(value) for value in bbox]
    row.update(
        {
            "bbox": [left, top, right, bottom],
            "margins": {
                "left": left,
                "top": top,
                "right": int(cell[0]) - right,
                "bottom": int(cell[1]) - bottom,
            },
            "content_size": [right - left, bottom - top],
            "center": [round((left + right) / 2, 2), round((top + bottom) / 2, 2)],
            "foot_y": bottom,
            "components": components[:8],
        }
    )
    return row


def duplicate_groups(frames: list[dict[str, Any]]) -> list[list[int]]:
    by_hash: dict[int, list[int]] = {}
    for frame in frames:
        by_hash.setdefault(int(frame["hash"]), []).append(int(frame["index"]))
    return [indexes for indexes in by_hash.values() if len(indexes) > 1]


def audit_model_lock(
    texture_path: Path,
    metadata: dict[str, Any],
    audited_frames: list[dict[str, Any]],
) -> tuple[dict[str, Any], list[str], list[str]]:
    """验证 Stage17 Luna Model Lock 的相位基线和 canonical 体量。"""
    lock = metadata.get("model_lock")
    if not isinstance(lock, dict):
        return {}, [], []

    blockers: list[str] = []
    warnings: list[str] = []
    expected_center = float(lock.get("center_x", 96))
    center_tolerance = float(lock.get("center_tolerance_px", 2))
    expected_foot = int(lock.get("ground_foot_y", 176))
    foot_tolerance = int(lock.get("ground_foot_tolerance_px", 2))
    expected_height = int(lock.get("standing_reference_height", 140))
    height_tolerance = int(lock.get("standing_height_tolerance_px", 6))
    standing_indexes = {int(index) for index in lock.get("standing_frame_indices", [])}
    grounded_phases = {str(phase) for phase in lock.get("grounded_phases", [])}
    metadata_by_index = {
        int(frame.get("index", -1)): frame
        for frame in metadata.get("frames", [])
        if isinstance(frame, dict)
    }

    center_failures = [
        int(frame["index"])
        for frame in audited_frames
        if not frame["empty"] and abs(float(frame["center"][0]) - expected_center) > center_tolerance
    ]
    grounded_frames = [
        frame
        for frame in audited_frames
        if (
            not frame["empty"]
            and str(metadata_by_index.get(int(frame["index"]), {}).get("phase", "")) in grounded_phases
        )
    ]
    foot_failures = [
        int(frame["index"])
        for frame in grounded_frames
        if abs(int(frame["foot_y"]) - expected_foot) > foot_tolerance
    ]
    standing_frames = [
        frame for frame in audited_frames
        if not frame["empty"] and int(frame["index"]) in standing_indexes
    ]
    standing_heights = [int(frame["content_size"][1]) for frame in standing_frames]
    standing_height_failures = [
        int(frame["index"])
        for frame in standing_frames
        if abs(int(frame["content_size"][1]) - expected_height) > height_tolerance
    ]

    canonical_id = str(lock.get("canonical_reference", ""))
    canonical_metadata_path = texture_path.parent / f"{canonical_id}.frames.json"
    canonical_texture_path = texture_path.parent / f"{canonical_id}.png"
    canonical_median_height: float | None = None
    standing_median_height: float | None = float(median(standing_heights)) if standing_heights else None
    cross_action_deviation: float | None = None
    if canonical_id and canonical_metadata_path.exists() and canonical_texture_path.exists():
        canonical_metadata = load_json(canonical_metadata_path)
        canonical_cell = [int(value) for value in canonical_metadata.get("cell", [192, 192])]
        canonical_image = Image.open(canonical_texture_path).convert("RGBA")
        canonical_frames = [
            audit_frame(canonical_image, frame, canonical_cell)
            for frame in canonical_metadata.get("frames", [])
            if isinstance(frame, dict)
        ]
        canonical_heights = [
            int(frame["content_size"][1])
            for frame in canonical_frames
            if not frame["empty"]
        ]
        if canonical_heights:
            canonical_median_height = float(median(canonical_heights))
    else:
        blockers.append("model_lock_missing_canonical_reference")

    if canonical_median_height and standing_median_height is not None:
        cross_action_deviation = abs(standing_median_height - canonical_median_height) / canonical_median_height
        max_deviation = float(lock.get("max_cross_action_median_height_deviation_ratio", 0.08))
        if cross_action_deviation > max_deviation:
            blockers.append("model_lock_cross_action_height_drift")

    if str(lock.get("model_id", "")) != "luna_model_v1":
        blockers.append("model_lock_id_mismatch")
    if center_failures:
        blockers.append("model_lock_center_line_drift")
    if not grounded_frames or foot_failures:
        blockers.append("model_lock_grounded_foot_baseline_drift")
    if not standing_frames or standing_height_failures:
        blockers.append("model_lock_standing_height_drift")
    if center_failures:
        warnings.append(f"model_lock_center_failures={center_failures}")
    if foot_failures:
        warnings.append(f"model_lock_foot_failures={foot_failures}")
    if standing_height_failures:
        warnings.append(f"model_lock_standing_height_failures={standing_height_failures}")

    return (
        {
            "model_id": str(lock.get("model_id", "")),
            "canonical_reference": canonical_id,
            "center_x": expected_center,
            "center_tolerance_px": center_tolerance,
            "center_failures": center_failures,
            "ground_foot_y": expected_foot,
            "ground_foot_tolerance_px": foot_tolerance,
            "grounded_frame_count": len(grounded_frames),
            "foot_failures": foot_failures,
            "standing_reference_height": expected_height,
            "standing_height_tolerance_px": height_tolerance,
            "standing_frame_indices": sorted(standing_indexes),
            "standing_heights": standing_heights,
            "standing_height_failures": standing_height_failures,
            "canonical_median_height": canonical_median_height,
            "standing_median_height": standing_median_height,
            "cross_action_median_height_deviation_ratio": (
                round(cross_action_deviation, 4) if cross_action_deviation is not None else None
            ),
        },
        blockers,
        warnings,
    )


def audit_asset(root: Path, item: dict[str, Any]) -> dict[str, Any]:
    asset_id = str(item["id"])
    profile = profile_for(asset_id)
    texture_path = resolve_path(root, str(item["output"]))
    metadata_path = resolve_path(root, str(item["metadata"]))
    sprite_frames_path = resolve_path(root, str(item.get("sprite_frames", "")))
    cell = [int(value) for value in item["cell"]]
    report: dict[str, Any] = {
        "asset_id": asset_id,
        "texture": rel(texture_path, root),
        "metadata": rel(metadata_path, root),
        "sprite_frames": rel(sprite_frames_path, root),
        "animation": item.get("animation", {}),
        "cell": cell,
        "status": "blocked",
        "blockers": [],
        "warnings": [],
        "frames": [],
        "summary": {},
        "gates": {
            "min_edge_padding_px": profile.min_edge_padding_px,
            "recommended_horizontal_padding_px": profile.recommended_horizontal_padding_px,
            "max_foot_baseline_variance_px": profile.max_foot_baseline_variance_px,
            "max_center_variance_px": profile.max_center_variance_px,
            "max_size_variance_ratio": profile.max_size_variance_ratio,
            "max_detached_component_area_ratio": profile.max_detached_component_area_ratio,
            "min_detached_component_area_px": profile.min_detached_component_area_px,
            "require_no_duplicate_frame_hashes": profile.require_no_duplicate_frame_hashes,
        },
    }
    if item.get("kind") == "blocked_sprite_sheet_reference":
        report["blockers"].append("blocked_candidate_reference")
        reason = str(item.get("blocked_reason", "manual blocked candidate reference"))
        report["warnings"].append(f"blocked_reason={reason}")

    if not texture_path.exists():
        report["blockers"].append("missing_texture")
        return report
    if not metadata_path.exists():
        report["blockers"].append("missing_frame_metadata")
        return report
    if not sprite_frames_path.exists():
        report["blockers"].append("missing_spriteframes_resource")
        return report

    metadata = load_json(metadata_path)
    frames = metadata.get("frames", [])
    anchor_mode = str(item.get("anchor", "foot"))
    recorded_scales = [
        float(frame["scale"])
        for frame in frames
        if isinstance(frame, dict) and "scale" in frame
    ]
    image = Image.open(texture_path).convert("RGBA")
    audited_frames = [audit_frame(image, frame, cell) for frame in frames]
    report["frames"] = audited_frames
    model_lock_report, model_lock_blockers, model_lock_warnings = audit_model_lock(
        texture_path,
        metadata,
        audited_frames,
    )
    if model_lock_report:
        report["model_lock"] = model_lock_report
        report["blockers"].extend(model_lock_blockers)
        report["warnings"].extend(model_lock_warnings)

    if not audited_frames:
        report["blockers"].append("no_frames")
        return report
    if any(frame["empty"] for frame in audited_frames):
        report["blockers"].append("empty_frame")

    duplicates = duplicate_groups(audited_frames)
    if profile.require_no_duplicate_frame_hashes and duplicates:
        report["blockers"].append("duplicate_frame_hashes")
        report["warnings"].append(f"duplicate_frame_groups={duplicates}")

    non_empty = [frame for frame in audited_frames if not frame["empty"]]
    if non_empty:
        min_margins = {
            side: min(int(frame["margins"][side]) for frame in non_empty)
            for side in ("left", "top", "right", "bottom")
        }
        edge_touch_frames = [
            int(frame["index"])
            for frame in non_empty
            if any(int(frame["margins"][side]) <= 0 for side in ("left", "top", "right", "bottom"))
        ]
        edge_padding_failures = [
            int(frame["index"])
            for frame in non_empty
            if any(int(frame["margins"][side]) < profile.min_edge_padding_px for side in ("left", "top", "right", "bottom"))
        ]
        horizontal_padding_warnings = [
            int(frame["index"])
            for frame in non_empty
            if (
                int(frame["margins"]["left"]) < profile.recommended_horizontal_padding_px
                or int(frame["margins"]["right"]) < profile.recommended_horizontal_padding_px
            )
        ]
        foot_values = [int(frame["foot_y"]) for frame in non_empty]
        center_x_values = [float(frame["center"][0]) for frame in non_empty]
        widths = [int(frame["content_size"][0]) for frame in non_empty]
        heights = [int(frame["content_size"][1]) for frame in non_empty]
        foot_variance = max(foot_values) - min(foot_values)
        center_x_variance = max(center_x_values) - min(center_x_values)
        width_ratio = (max(widths) - min(widths)) / max(1, max(widths))
        height_ratio = (max(heights) - min(heights)) / max(1, max(heights))
        recorded_scale_variance = (
            max(recorded_scales) - min(recorded_scales)
            if len(recorded_scales) == len(non_empty)
            else None
        )
        has_stable_recorded_scale = (
            recorded_scale_variance is not None and recorded_scale_variance <= 0.001
        )
        detached_component_failures: list[int] = []
        detached_component_notes: list[str] = []
        for frame in non_empty:
            components = list(frame.get("components", []))
            if len(components) <= 1:
                continue
            main_area = max(1, int(components[0]["area"]))
            significant_components = [
                component for component in components[1:]
                if (
                    int(component["area"]) >= profile.min_detached_component_area_px
                    and (int(component["area"]) / main_area) >= profile.max_detached_component_area_ratio
                )
            ]
            if significant_components:
                detached_component_failures.append(int(frame["index"]))
                detached_component_notes.append(
                    "frame_%s=%s" % (
                        int(frame["index"]),
                        [
                            {
                                "area": int(component["area"]),
                                "bbox": component["bbox"],
                            }
                            for component in significant_components[:3]
                        ],
                    )
                )

        if edge_touch_frames:
            report["blockers"].append("content_touches_cell_edge")
            report["warnings"].append(f"edge_touch_frames={edge_touch_frames}")
        if edge_padding_failures:
            report["blockers"].append("insufficient_edge_padding")
            report["warnings"].append(f"edge_padding_failures={edge_padding_failures}")
        if horizontal_padding_warnings:
            report["warnings"].append(f"horizontal_padding_below_recommended={horizontal_padding_warnings}")
        if anchor_mode not in {"body_center", "phase_locked"} and foot_variance > profile.max_foot_baseline_variance_px:
            report["blockers"].append("unstable_foot_baseline")
        if center_x_variance > profile.max_center_variance_px:
            report["blockers"].append("unstable_center_x")
        if max(width_ratio, height_ratio) > profile.max_size_variance_ratio and not has_stable_recorded_scale:
            report["blockers"].append("unstable_content_scale")
        if detached_component_failures:
            report["blockers"].append("detached_frame_fragments")
            report["warnings"].append(f"detached_component_frames={detached_component_failures}")
            report["warnings"].extend(detached_component_notes[:3])

        report["summary"] = {
            "frame_count": len(audited_frames),
            "min_margins": min_margins,
            "edge_touch_frames": edge_touch_frames,
            "edge_padding_failures": edge_padding_failures,
            "horizontal_padding_below_recommended": horizontal_padding_warnings,
            "duplicate_frame_groups": duplicates,
            "foot_baseline_variance_px": foot_variance,
            "center_x_variance_px": round(center_x_variance, 2),
            "content_width_variance_ratio": round(width_ratio, 4),
            "content_height_variance_ratio": round(height_ratio, 4),
            "anchor_mode": anchor_mode,
            "recorded_scale_variance": (
                round(recorded_scale_variance, 6)
                if recorded_scale_variance is not None
                else None
            ),
            "stable_recorded_scale": has_stable_recorded_scale,
            "detached_component_failures": detached_component_failures,
        }

    report["blockers"] = sorted(set(report["blockers"]))
    report["status"] = "runtime_replacement_ready" if not report["blockers"] else "blocked"
    return report


def write_markdown(report: dict[str, Any], path: Path) -> None:
    lines = [
        "# Animation Runtime Replacement Audit",
        "",
        f"Status: `{report['status']}`",
        "",
        f"- Active assets: `{report['active_asset_count']}`",
        f"- Active ready: `{report['ready_count']}`",
        f"- Active blocked: `{report['blocked_count']}`",
        f"- Archived references: `{report['archived_reference_count']}`",
        f"- Archived reference errors: `{report['archived_reference_error_count']}`",
        "",
        "| Asset | Status | Key blockers | Min margins | Baseline variance | Notes |",
        "| --- | --- | --- | --- | ---: | --- |",
    ]
    for asset in report["assets"]:
        summary = asset.get("summary", {})
        margins = summary.get("min_margins", {})
        margin_text = ", ".join(f"{key}={value}" for key, value in margins.items()) if margins else "n/a"
        blockers = ", ".join(asset.get("blockers", [])) or "-"
        notes = "; ".join(asset.get("warnings", [])[:2]) or "-"
        lines.append(
            "| "
            + " | ".join(
                [
                    f"`{asset['asset_id']}`",
                    f"`{asset['status']}`",
                    blockers,
                    margin_text,
                    str(summary.get("foot_baseline_variance_px", "n/a")),
                    notes,
                ]
            )
            + " |"
        )
    lines.extend(
        [
            "",
            "## Archived References",
            "",
            "| Asset | Status | Replacements | Errors |",
            "| --- | --- | --- | --- |",
        ]
    )
    for archived in report.get("archived_references", []):
        replacements = ", ".join(
            replacement.get("id") or replacement.get("path") or "-"
            for replacement in archived.get("replacements", [])
        ) or "-"
        errors = ", ".join(archived.get("errors", [])) or "-"
        lines.append(
            "| "
            + " | ".join(
                [
                    f"`{archived['asset_id']}`",
                    f"`{archived['status']}`",
                    replacements,
                    errors,
                ]
            )
            + " |"
        )
    lines.extend(
        [
            "",
            "## Gate Meaning",
            "",
            "- `content_touches_cell_edge`: opaque pixels touch a frame boundary; this is not acceptable for formal runtime replacement.",
            "- `insufficient_edge_padding`: one or more frames lack the minimum transparent padding required by the action profile.",
            "- `unstable_foot_baseline`: foot / bottom bound drift is above the profile threshold and may cause visible jitter.",
            "- `unstable_center_x`: horizontal center drift is above the profile threshold and may cause runtime position popping.",
            "- `unstable_content_scale`: content size changes too much across frames and may read as character scale drift.",
            "- `detached_frame_fragments`: sizable disconnected opaque components remain inside a cell and may indicate adjacent-frame fragments or baked VFX debris.",
            "- `blocked_candidate_reference`: legacy status for a failed candidate retained as evidence or regeneration input.",
            "- `archived_blocked_reference` / `superseded_reference`: not part of the active strict gate, but must declare existing `superseded_by` replacements.",
            "- `duplicate_frame_hashes`: exact duplicate frames remain in the sheet and should be removed before formal replacement.",
            "",
            "This audit proves formal runtime replacement readiness only for the sprite sheet geometry and resource layer. Gameplay timing, hitbox / hurtbox, damage windows, cancel windows and playtest readability still require scene-level tests.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    items, archived_items, source_manifest = audit_items_from_args(root, args)
    assets = [audit_asset(root, item) for item in items]
    archived_references = audit_archived_references(root, archived_items, items)
    ready_count = sum(1 for asset in assets if asset["status"] == "runtime_replacement_ready")
    archived_reference_error_count = sum(1 for row in archived_references if not bool(row.get("ok", False)))
    report = {
        "version": 1,
        "status": "blocked" if ready_count != len(assets) or archived_reference_error_count else "runtime_replacement_ready",
        "active_asset_count": len(assets),
        "asset_count": len(assets),
        "source_manifest": source_manifest,
        "ready_count": ready_count,
        "blocked_count": len(assets) - ready_count,
        "archived_reference_count": len(archived_references),
        "archived_reference_error_count": archived_reference_error_count,
        "assets": assets,
        "archived_references": archived_references,
        "boundary": (
            "Formal animation runtime replacement audit for active runtime candidates. Archived references "
            "are retained as failed evidence or regeneration inputs and must point to existing replacements. "
            "Passing this audit is required before replacing live player, enemy or boss controller animations, "
            "but it does not replace "
            "gameplay timing, hitbox/hurtbox and playtest verification."
        ),
    }
    if args.write_report:
        report_json = resolve_path(root, args.report_json)
        report_md = resolve_path(root, args.report_md)
        report_json.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_markdown(report, report_md)
        print(f"wrote {report_json.as_posix()}")
        print(f"wrote {report_md.as_posix()}")
    print(
        "Animation runtime replacement audit: "
        f"{report['ready_count']}/{report['active_asset_count']} active ready, "
        f"{report['blocked_count']} active blocked, "
        f"{report['archived_reference_count']} archived references, "
        f"{report['archived_reference_error_count']} archive errors."
    )
    if args.strict and (report["blocked_count"] or report["archived_reference_error_count"]):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
