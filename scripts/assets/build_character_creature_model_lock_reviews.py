#!/usr/bin/env python3
"""为中央模型锁生成角色、普通怪物与 Boss 的逐家族接触审查表。"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont

from audit_character_creature_model_locks import audit_manifest
from character_creature_model_lock_contract import DEFAULT_MANIFEST, load_manifest


DEFAULT_OUT = Path("tests/artifacts/local/character-creature-model-lock")
BACKGROUND = (5, 18, 25, 255)
PANEL = (13, 38, 48, 255)
PANEL_ALT = (10, 30, 39, 255)
WHITE = (219, 235, 239, 255)
MUTED = (137, 167, 175, 255)
CYAN = (61, 230, 236, 255)
GOLD = (222, 178, 57, 255)
MAGENTA = (237, 63, 181, 255)
RED = (239, 91, 91, 255)
GREEN = (97, 215, 163, 255)
ORANGE = (255, 149, 74, 255)
BLUE = (67, 156, 255, 255)
PURPLE = (181, 111, 255, 255)


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/msyhbd.ttc" if bold else "C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
    ]
    for candidate in candidates:
        if candidate.is_file():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def _select_samples(indexes: list[int]) -> list[int]:
    """最多展示四个代表姿态，同时保留首尾状态。"""
    if len(indexes) <= 4:
        return indexes
    positions = [0, round((len(indexes) - 1) / 3), round(2 * (len(indexes) - 1) / 3), len(indexes) - 1]
    return [indexes[position] for position in positions]


def _draw_anchor_marker(
    draw: ImageDraw.ImageDraw,
    point: list[float | int],
    frame_x: int,
    frame_y: int,
    scale: float,
    color: tuple[int, int, int, int],
    shape: str,
) -> None:
    x = frame_x + round(float(point[0]) * scale)
    y = frame_y + round(float(point[1]) * scale)
    radius = 4
    if shape == "diamond":
        draw.polygon(((x, y - radius), (x + radius, y), (x, y + radius), (x - radius, y)), fill=color)
    elif shape == "square":
        draw.rectangle((x - radius, y - radius, x + radius, y + radius), fill=color)
    else:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
    draw.line((x - radius - 2, y, x + radius + 2, y), fill=WHITE, width=1)
    draw.line((x, y - radius - 2, x, y + radius + 2), fill=WHITE, width=1)


def _draw_frame(
    canvas: Image.Image,
    draw: ImageDraw.ImageDraw,
    texture: Image.Image,
    metrics: dict[str, Any],
    cell: list[int],
    center_x: float,
    root_y: int,
    tile_x: int,
    tile_y: int,
) -> None:
    cell_width, cell_height = cell
    scale = min(190 / cell_width, 190 / cell_height)
    width = max(1, round(cell_width * scale))
    height = max(1, round(cell_height * scale))
    region_x, region_y, _, _ = metrics["region"]
    frame = texture.crop((region_x, region_y, region_x + cell_width, region_y + cell_height))
    frame = frame.resize((width, height), Image.Resampling.NEAREST)
    frame_x = tile_x + (210 - width) // 2
    frame_y = tile_y + 8
    draw.rectangle((frame_x, frame_y, frame_x + width, frame_y + height), fill=PANEL_ALT, outline=(38, 76, 87, 255))
    canvas.alpha_composite(frame, (frame_x, frame_y))

    line_x = frame_x + round(center_x * scale)
    line_y = frame_y + round(root_y * scale)
    draw.line((line_x, frame_y, line_x, frame_y + height), fill=CYAN, width=1)
    draw.line((frame_x, line_y, frame_x + width, line_y), fill=GOLD, width=1)
    left, top, right, bottom = metrics["bbox"]
    draw.rectangle(
        (
            frame_x + round(left * scale),
            frame_y + round(top * scale),
            frame_x + round((right - 1) * scale),
            frame_y + round((bottom - 1) * scale),
        ),
        outline=MAGENTA,
        width=1,
    )
    anchors = metrics.get("semantic_anchors", {})
    core_anchor_id = "hip_center" if "hip_center" in anchors else "body_core"
    marker_specs = (
        ("root", GOLD, "circle"),
        ("foot_contact", ORANGE, "circle"),
        ("head_top", RED, "diamond"),
        (core_anchor_id, GREEN, "diamond"),
        ("front_contour", BLUE, "square"),
        ("rear_contour", PURPLE, "square"),
    )
    for anchor_id, color, shape in marker_specs:
        point = anchors.get(anchor_id)
        if isinstance(point, list) and len(point) == 2:
            _draw_anchor_marker(draw, point, frame_x, frame_y, scale, color, shape)
    core_ratio = metrics.get("semantic_evidence", {}).get("core_ratio", "-")
    label = (
        f"#{int(metrics['index']):02d}  C{float(metrics['center_x']):.1f}  "
        f"F{int(metrics['bottom_y'])}  H{int(metrics['body_height'])}  K{core_ratio}"
    )
    draw.text((tile_x + 5, tile_y + 204), label, font=_font(13), fill=MUTED)


def build_family_sheet(
    root: Path,
    out_dir: Path,
    family: dict[str, Any],
    audit_family: dict[str, Any],
) -> Path:
    assets = audit_family["assets"]
    width = 24 + 350 + 4 * 220 + 24
    header_height = 138
    row_height = 238
    height = header_height + row_height * len(assets) + 24
    canvas = Image.new("RGBA", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    title = f"{family['label']} — LIVE BODY CONTACT SHEET"
    draw.text((24, 18), title, font=_font(27, bold=True), fill=WHITE)
    draw.text(
        (24, 56),
        f"model: {family['model_id']}   canonical: {family['canonical_reference']}#{family.get('canonical_frame_index', 0)}",
        font=_font(15),
        fill=CYAN,
    )
    draw.text(
        (24, 80),
        f"cyan=center x={family['center_x']}   gold=root y={family['root_y']}   magenta=alpha bbox   identity={family['identity_review_status']}",
        font=_font(14),
        fill=MUTED,
    )
    draw.text(
        (24, 104),
        "semantic anchors: orange=foot  red=head  green=core  blue=front contour  purple=rear contour",
        font=_font(14),
        fill=MUTED,
    )

    metrics_by_asset = {asset["asset_id"]: asset for asset in audit_family["assets"]}
    for row_index, asset in enumerate(family["assets"]):
        asset_id = str(asset["asset_id"])
        result = metrics_by_asset[asset_id]
        row_y = header_height + row_index * row_height
        fill = PANEL if row_index % 2 == 0 else PANEL_ALT
        draw.rectangle((16, row_y, width - 16, row_y + row_height - 8), fill=fill)
        status = str(asset.get("status", "active"))
        status_color = GREEN if status == "active" else RED
        draw.text((28, row_y + 18), str(asset.get("role", "")), font=_font(19, bold=True), fill=WHITE)
        draw.text((28, row_y + 51), asset_id, font=_font(13), fill=MUTED)
        draw.text((28, row_y + 78), f"status: {status}", font=_font(14, bold=True), fill=status_color)
        draw.text(
            (28, row_y + 104),
            f"technical lock: {result['audit_status']}",
            font=_font(13),
            fill=GREEN if result["audit_status"] != "fail" else RED,
        )
        draw.text(
            (28, row_y + 130),
            f"runtime binding: {str(result['runtime_binding_allowed']).lower()}",
            font=_font(13),
            fill=WHITE,
        )
        if status != "active":
            draw.text((28, row_y + 166), "REJECTED REFERENCE", font=_font(16, bold=True), fill=RED)

        texture_path = root / str(family["asset_root"]) / f"{asset_id}.png"
        texture = Image.open(texture_path).convert("RGBA")
        frame_by_index = {int(frame["index"]): frame for frame in result["frames"]}
        sample_indexes = _select_samples(
            [int(value) for value in result["semantic_sample_indices"]]
        )
        for column, frame_index in enumerate(sample_indexes):
            metrics = frame_by_index[frame_index]
            _draw_frame(
                canvas,
                draw,
                texture,
                metrics,
                [int(value) for value in family["cell"]],
                float(family["center_x"]),
                int(family["root_y"]),
                374 + column * 220,
                row_y + 6,
            )

    output_path = out_dir / f"{family['model_id']}_contact_sheet.png"
    canvas.convert("RGB").save(output_path, quality=95)
    return output_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="生成全部模型锁 contact sheets。")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    manifest = load_manifest(root, args.manifest)
    report = audit_manifest(root, manifest)
    if int(report["summary"]["automated_failure_count"]) > 0:
        print("Refusing to build review sheets because strict model-lock audit failed.")
        return 1
    out_dir = args.out_dir if args.out_dir.is_absolute() else root / args.out_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    # 本目录是本地审查证据，不是运行资产；阻止 Godot 为 contact sheet 建立无意义 import 链。
    (out_dir / ".gdignore").write_text(
        "# Local model-lock review evidence; intentionally excluded from Godot imports.\n",
        encoding="utf-8",
    )
    audit_by_model = {family["model_id"]: family for family in report["families"]}
    outputs: list[str] = []
    for family in manifest["families"]:
        model_id = str(family["model_id"])
        path = build_family_sheet(root, out_dir, family, audit_by_model[model_id])
        review_path = out_dir / f"{model_id}_review.json"
        review_path.write_text(
            json.dumps(audit_by_model[model_id], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        outputs.append(path.resolve().relative_to(root).as_posix())
        print(f"Built {path}")
    summary = {
        "contract_kind": manifest["contract_kind"],
        "family_count": len(outputs),
        "contact_sheets": outputs,
        "automated_geometry_status": "pass",
        "automated_identity_lock_status": "pass",
        "human_identity_status": "pending_gate26h",
        "boundary": manifest["boundary"],
    }
    (out_dir / "contact_sheet_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "MODEL_LOCK_CONTACT_SHEETS_OK: "
        f"families={len(outputs)} automated_geometry=pass "
        "identity_lock=pass human_identity=pending_gate26h"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
