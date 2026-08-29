#!/usr/bin/env python3
"""从真实运行 PNG 计算 Luna alpha bounds，并生成带中心轴 / 脚底线的动作接触表。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from statistics import median
from typing import Any

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
RUNTIME_DIR = ROOT / "assets/art/characters/player/sprite_sheets/runtime_replacement"
OUT_DIR = ROOT / "tests/artifacts/local/runtime-visual-integrity/luna-model-lock"
OUT_IMAGE = OUT_DIR / "luna_runtime_contact_sheet.png"
OUT_REPORT = OUT_DIR / "luna_runtime_continuity_report.json"
CELL = (192, 192)
DISPLAY_CELL = (144, 144)
EXPECTED_MODEL_ID = "luna_model_v1"
EXPECTED_CANONICAL = "luna_idle_runtime_sheet_ai03"

ASSET_CASES: list[dict[str, Any]] = [
    {"id": "luna_idle_runtime_sheet_ai03", "label": "IDLE / canonical", "samples": [0, 4, 8, 12]},
    {"id": "luna_run_runtime_sheet_ai03", "label": "RUN", "samples": [0, 6, 12, 18]},
    {"id": "luna_jump_state_runtime_sheet_ai04", "label": "JUMP rise / apex / fall / land", "samples": [0, 3, 5, 9]},
    {"id": "luna_attack_body_runtime_sheet_ai03", "label": "ATTACK startup / active / recover", "samples": [4, 6, 8, 12]},
    {"id": "luna_air_dash_body_runtime_sheet_ai03", "label": "AIR DASH", "samples": [0, 4, 7, 8]},
    {"id": "luna_hit_react_runtime_sheet_ai03", "label": "HIT REACT", "samples": [0, 2, 5, 7]},
    {"id": "luna_death_idle_runtime_sheet_ai03", "label": "DEATH", "samples": [0, 4, 9, 17]},
]


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for candidate in [
        Path("C:/Windows/Fonts/segoeui.ttf"),
        Path("C:/Windows/Fonts/arial.ttf"),
    ]:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def scan_frame(sheet: Image.Image, frame_data: dict[str, Any]) -> dict[str, Any]:
    x, y, width, height = [int(value) for value in frame_data["region"]]
    alpha = sheet.crop((x, y, x + width, y + height)).getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return {"index": int(frame_data["index"]), "empty": True}
    left, top, right, bottom = bbox
    return {
        "index": int(frame_data["index"]),
        "empty": False,
        "bbox": [left, top, right, bottom],
        "center_x": round((left + right) / 2.0, 2),
        "head_y": top,
        "foot_y": bottom,
        "width": right - left,
        "height": bottom - top,
    }


def audit_asset(asset_case: dict[str, Any]) -> tuple[dict[str, Any], Image.Image, dict[str, Any]]:
    asset_id = str(asset_case["id"])
    texture_path = RUNTIME_DIR / f"{asset_id}.png"
    metadata_path = RUNTIME_DIR / f"{asset_id}.frames.json"
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    sheet = Image.open(texture_path).convert("RGBA")
    lock = dict(metadata.get("model_lock", {}))
    frame_reports = [scan_frame(sheet, frame) for frame in metadata.get("frames", [])]
    frame_data_by_index = {int(frame["index"]): frame for frame in metadata.get("frames", [])}

    centers = [float(frame["center_x"]) for frame in frame_reports if not frame["empty"]]
    feet = [int(frame["foot_y"]) for frame in frame_reports if not frame["empty"]]
    heights = [int(frame["height"]) for frame in frame_reports if not frame["empty"]]
    center_failures: list[int] = []
    foot_failures: list[int] = []
    expected_center = float(lock.get("center_x", 96))
    center_tolerance = float(lock.get("center_tolerance_px", 2))
    expected_foot = int(lock.get("ground_foot_y", 176))
    foot_tolerance = int(lock.get("ground_foot_tolerance_px", 2))
    requires_ground_foot = bool(lock.get("requires_ground_foot", False))
    for frame in frame_reports:
        if frame["empty"]:
            continue
        index = int(frame["index"])
        if abs(float(frame["center_x"]) - expected_center) > center_tolerance:
            center_failures.append(index)
        source_frame = frame_data_by_index[index]
        grounded = requires_ground_foot or bool(source_frame.get("grounded", False))
        if grounded and abs(int(frame["foot_y"]) - expected_foot) > foot_tolerance:
            foot_failures.append(index)

    cell = tuple(int(value) for value in metadata.get("cell", []))
    contract_ok = (
        str(lock.get("model_id", "")) == EXPECTED_MODEL_ID
        and str(lock.get("canonical_reference", "")) == EXPECTED_CANONICAL
        and int(lock.get("center_x", -1)) == 96
        and float(lock.get("center_tolerance_px", 999)) <= 2.0
    )
    ok = (
        cell == CELL
        and contract_ok
        and len(frame_reports) == int(metadata.get("frame_count", -1))
        and not center_failures
        and not foot_failures
    )
    report = {
        "ok": ok,
        "asset_id": asset_id,
        "label": asset_case["label"],
        "texture": relative(texture_path),
        "metadata": relative(metadata_path),
        "frame_count": len(frame_reports),
        "sample_indices": asset_case["samples"],
        "model_lock": lock,
        "cell_ok": cell == CELL,
        "contract_ok": contract_ok,
        "center_range": [min(centers), max(centers)] if centers else [],
        "center_failures": center_failures,
        "foot_range": [min(feet), max(feet)] if feet else [],
        "foot_failures": foot_failures,
        "height_range": [min(heights), max(heights)] if heights else [],
        "median_height": median(heights) if heights else 0,
        "frames": frame_reports,
    }
    return report, sheet, metadata


def build_contact_sheet(rows: list[tuple[dict[str, Any], Image.Image, dict[str, Any]]]) -> None:
    width = 1360
    header_height = 92
    row_height = 172
    height = header_height + row_height * len(rows) + 18
    canvas = Image.new("RGBA", (width, height), "#09151d")
    draw = ImageDraw.Draw(canvas)
    title_font = load_font(28)
    label_font = load_font(19)
    small_font = load_font(14)
    draw.text((24, 16), "LUNA MODEL LOCK v1 — LIVE BODY CONTACT SHEET", font=title_font, fill="#d9edf0")
    draw.text((24, 56), "cyan: center x=96    gold: grounded foot y=176    all cells: 192x192", font=small_font, fill="#84bac2")

    for row_index, (report, sheet, metadata) in enumerate(rows):
        y = header_height + row_index * row_height
        status_color = "#6ee7d8" if report["ok"] else "#ff6b6b"
        draw.text((24, y + 12), str(report["label"]), font=label_font, fill=status_color)
        draw.text(
            (24, y + 44),
            f"C {report['center_range']}\nF {report['foot_range']}\nH {report['height_range']}",
            font=small_font,
            fill="#8aa6ad",
            spacing=5,
        )
        columns = int(metadata.get("columns", 1))
        frame_by_index = {int(frame["index"]): frame for frame in report["frames"]}
        for column_index, frame_index in enumerate(report["sample_indices"]):
            x = 330 + column_index * 245
            source_x = (frame_index % columns) * CELL[0]
            source_y = (frame_index // columns) * CELL[1]
            frame = sheet.crop((source_x, source_y, source_x + CELL[0], source_y + CELL[1]))
            frame = frame.resize(DISPLAY_CELL, Image.Resampling.LANCZOS)
            draw.rectangle((x, y, x + DISPLAY_CELL[0], y + DISPLAY_CELL[1]), fill="#122731", outline="#294552")
            canvas.alpha_composite(frame, (x, y))
            center_x = x + round(DISPLAY_CELL[0] * 96 / 192)
            foot_y = y + round(DISPLAY_CELL[1] * 176 / 192)
            draw.line((center_x, y, center_x, y + DISPLAY_CELL[1]), fill="#31e0ebaa", width=1)
            draw.line((x, foot_y, x + DISPLAY_CELL[0], foot_y), fill="#f5b83dbb", width=1)
            metrics = frame_by_index[frame_index]
            draw.text(
                (x, y + DISPLAY_CELL[1] + 3),
                f"#{frame_index:02d} C{metrics['center_x']:.1f} F{metrics['foot_y']} H{metrics['height']}",
                font=small_font,
                fill="#a9c1c6",
            )
    canvas.convert("RGB").save(OUT_IMAGE)


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = [audit_asset(asset_case) for asset_case in ASSET_CASES]
    build_contact_sheet(rows)
    asset_reports = [row[0] for row in rows]
    report = {
        "ok": all(bool(asset["ok"]) for asset in asset_reports),
        "review_id": "luna_runtime_model_lock_v1",
        "model_id": EXPECTED_MODEL_ID,
        "canonical_reference": EXPECTED_CANONICAL,
        "cell": list(CELL),
        "center_x": 96,
        "center_tolerance_px": 2,
        "ground_foot_y": 176,
        "ground_foot_tolerance_px": 2,
        "asset_count": len(asset_reports),
        "assets": asset_reports,
        "contact_sheet": {
            "path": relative(OUT_IMAGE),
            "sha256": sha256(OUT_IMAGE),
            "legend": "cyan vertical=center x=96; gold horizontal=ground foot y=176",
        },
        "boundary": "Alpha-bounds, canvas and anchor continuity are automated. Face, hair, costume identity, silhouette quality and animation rhythm still require human art review.",
    }
    OUT_REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Luna Model Lock review: ok={report['ok']} assets={len(asset_reports)}")
    print(relative(OUT_REPORT))
    print(relative(OUT_IMAGE))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
