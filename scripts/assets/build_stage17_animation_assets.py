#!/usr/bin/env python3
"""从现有已审查 runtime sheet 构建 Stage17 最小动作资产。"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from statistics import median
from typing import Any

from PIL import Image


ROOT = Path.cwd()
PLAYER_DIR = Path("assets/art/characters/player/sprite_sheets/runtime_replacement")
CANDIDATE_MANIFEST = Path("docs/assets/animation-runtime-replacement-candidates.json")
CELL = (192, 192)
JUMP_ASSET_ID = "luna_jump_state_runtime_sheet_ai04"
JUMP_SOURCE_ID = "luna_jump_fall_runtime_sheet_ai03"
JUMP_SOURCE = PLAYER_DIR / f"{JUMP_SOURCE_ID}.png"
JUMP_SOURCE_COLUMNS = 6
JUMP_FRAME_SPECS = [
    ("jump_start", 0, True),
    ("jump_start", 1, True),
    ("jump_start", 2, True),
    ("rise_hold", 3, False),
    ("rise_hold", 4, False),
    ("fall_hold", 12, False),
    ("fall_hold", 13, False),
    ("land", 18, True),
    ("land", 19, True),
    ("land", 21, True),
    ("land", 22, True),
]
JUMP_ANIMATIONS = [
    {"name": "jump_start", "indexes": [0, 1, 2], "speed": 12.0, "loop": False},
    {"name": "rise_hold", "indexes": [3, 4], "speed": 8.0, "loop": True},
    {"name": "fall_hold", "indexes": [5, 6], "speed": 8.0, "loop": True},
    {"name": "land", "indexes": [7, 8, 9, 10], "speed": 14.0, "loop": False},
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="构建 Stage17 动作运行态资产。")
    parser.add_argument("--jump", action="store_true", help="构建 Luna Model Lock jump-state sheet。")
    return parser.parse_args()


def relative(path: Path) -> str:
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def resource_path(path: Path) -> str:
    return "res://" + relative(path)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


# 从固定 192px 网格读取一格，保留现有透明像素和角色细节。
def source_cell(sheet: Image.Image, index: int, columns: int) -> Image.Image:
    x = (index % columns) * CELL[0]
    y = (index // columns) * CELL[1]
    return sheet.crop((x, y, x + CELL[0], y + CELL[1])).convert("RGBA")


# 读取角色 alpha bounds；空帧属于不可恢复的源资产错误。
def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("source frame is empty")
    return tuple(int(value) for value in bbox)


# 使用单一 scale 规范化所有跳跃相位，避免每帧独立缩放造成模型呼吸。
def normalize_jump_frames(sheet: Image.Image) -> tuple[Image.Image, list[dict[str, Any]], float]:
    source_frames = [source_cell(sheet, source_index, JUMP_SOURCE_COLUMNS) for _, source_index, _ in JUMP_FRAME_SPECS]
    source_bboxes = [alpha_bbox(frame) for frame in source_frames]
    standing_heights = []
    for source_index in (21, 22):
        left, top, right, bottom = alpha_bbox(source_cell(sheet, source_index, JUMP_SOURCE_COLUMNS))
        standing_heights.append(bottom - top)

    target_scale = 140.0 / max(1.0, float(median(standing_heights)))
    max_width = max(right - left for left, _top, right, _bottom in source_bboxes)
    max_height = max(bottom - top for _left, top, _right, bottom in source_bboxes)
    safe_scale = min((CELL[0] - 16) / max_width, (CELL[1] - 16) / max_height)
    scale = min(target_scale, safe_scale)

    columns = 4
    rows = 3
    output = Image.new("RGBA", (columns * CELL[0], rows * CELL[1]), (0, 0, 0, 0))
    records: list[dict[str, Any]] = []
    for index, ((phase, source_index, grounded), frame, bbox) in enumerate(zip(JUMP_FRAME_SPECS, source_frames, source_bboxes)):
        content = frame.crop(bbox)
        width = max(1, round(content.width * scale))
        height = max(1, round(content.height * scale))
        resized = content.resize((width, height), Image.Resampling.LANCZOS)
        paste_x = round(96 - width / 2)
        paste_y = 176 - height if grounded else round(96 - height / 2)
        cell = Image.new("RGBA", CELL, (0, 0, 0, 0))
        cell.alpha_composite(resized, (paste_x, paste_y))
        target_x = (index % columns) * CELL[0]
        target_y = (index // columns) * CELL[1]
        output.alpha_composite(cell, (target_x, target_y))
        records.append(
            {
                "index": index,
                "name": f"{JUMP_ASSET_ID}_{phase}_{index + 1:02d}",
                "phase": phase,
                "grounded": grounded,
                "source": relative(JUMP_SOURCE),
                "source_frame_index": source_index,
                "source_bbox": list(bbox),
                "region": [target_x, target_y, CELL[0], CELL[1]],
                "normalized_size": [width, height],
                "paste": [paste_x, paste_y],
                "scale": round(scale, 6),
                "center_x": 96,
                "foot_y": 176 if grounded else paste_y + height,
            }
        )
    return output, records, scale


# SpriteFrames 保留四个固定 animation 名，物理状态只在这些名字之间切换。
def write_jump_spriteframes(path: Path, texture_path: Path, frame_count: int) -> None:
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(texture_path)}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        x = (index % 4) * CELL[0]
        y = (index // 4) * CELL[1]
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{JUMP_ASSET_ID}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {CELL[0]}, {CELL[1]})",
                "",
            ]
        )

    animations = []
    for animation in JUMP_ANIMATIONS:
        frames = [
            '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (JUMP_ASSET_ID, index)
            for index in animation["indexes"]
        ]
        animations.append(
            "{\n"
            f'"frames": [{", ".join(frames)}],\n'
            f'"loop": {str(bool(animation["loop"])).lower()},\n'
            f'"name": &"{animation["name"]}",\n'
            f'"speed": {float(animation["speed"]):.1f}\n'
            "}"
        )
    lines.extend(["[resource]", f'animations = [{", ".join(animations)}]'])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# 候选清单把旧 jump 资源转为归档引用，并把 ai04 设为唯一 live jump-state 候选。
def update_candidate_manifest(entry: dict[str, Any]) -> None:
    manifest = json.loads(CANDIDATE_MANIFEST.read_text(encoding="utf-8"))
    outputs = [item for item in manifest.get("outputs", []) if item.get("id") not in {JUMP_ASSET_ID, JUMP_SOURCE_ID}]
    for item in outputs:
        if item.get("id") != "luna_jump_fall_runtime_sheet_ai01":
            continue
        item["kind"] = "archived_sprite_sheet_reference"
        item["status"] = "superseded_reference"
        item["archival_reason"] = "Stage17 replaces the time-played jump/fall clip with phase-locked Model Lock v1 animations."
        item["superseded_by"] = [{"id": JUMP_ASSET_ID, "path": entry["output"]}]

    outputs.append(entry)
    outputs.append(
        {
            "id": JUMP_SOURCE_ID,
            "kind": "archived_sprite_sheet_reference",
            "status": "superseded_reference",
            "output": relative(JUMP_SOURCE),
            "metadata": relative(PLAYER_DIR / f"{JUMP_SOURCE_ID}.frames.json"),
            "sprite_frames": relative(PLAYER_DIR / f"{JUMP_SOURCE_ID}.spriteframes.tres"),
            "cell": list(CELL),
            "animation": {"name": "jump_fall", "speed": 14.0, "loop": False},
            "anchor": "body_center",
            "archival_reason": "Stage17 Model Lock audit confirmed the live ai03 body scale is too small for phase-locked runtime use.",
            "superseded_by": [{"id": JUMP_ASSET_ID, "path": entry["output"]}],
        }
    )
    manifest["outputs"] = outputs
    manifest["asset_count"] = len(outputs)
    manifest["active_asset_count"] = sum(1 for item in outputs if item.get("kind") == "sprite_sheet")
    manifest["archived_reference_count"] = len(outputs) - manifest["active_asset_count"]
    CANDIDATE_MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


# 构建单一 jump-state sheet，并记录 Model Lock、来源和可重放处理参数。
def build_jump() -> None:
    if not JUMP_SOURCE.exists():
        raise FileNotFoundError(JUMP_SOURCE)
    PLAYER_DIR.mkdir(parents=True, exist_ok=True)
    sheet, frames, scale = normalize_jump_frames(Image.open(JUMP_SOURCE).convert("RGBA"))
    output_path = PLAYER_DIR / f"{JUMP_ASSET_ID}.png"
    metadata_path = PLAYER_DIR / f"{JUMP_ASSET_ID}.frames.json"
    source_path = PLAYER_DIR / f"{JUMP_ASSET_ID}.source.json"
    spriteframes_path = PLAYER_DIR / f"{JUMP_ASSET_ID}.spriteframes.tres"
    sheet.save(output_path)
    write_jump_spriteframes(spriteframes_path, output_path, len(frames))

    model_lock = {
        "model_id": "luna_model_v1",
        "canonical_reference": "luna_idle_runtime_sheet_ai03",
        "center_x": 96,
        "center_tolerance_px": 2,
        "ground_foot_y": 176,
        "ground_foot_tolerance_px": 2,
        "standing_reference_height": 140,
        "standing_height_tolerance_px": 6,
        "standing_frame_indices": [9, 10],
        "grounded_phases": ["jump_start", "land"],
        "max_cross_action_median_height_deviation_ratio": 0.08,
    }
    metadata = {
        "id": JUMP_ASSET_ID,
        "kind": "sprite_sheet",
        "source_asset_id": JUMP_SOURCE_ID,
        "output": relative(output_path),
        "metadata": relative(metadata_path),
        "sprite_frames": relative(spriteframes_path),
        "cell": list(CELL),
        "columns": 4,
        "rows": 3,
        "frame_count": len(frames),
        "animation": {"name": "jump_state", "speed": 12.0, "loop": False},
        "animations": JUMP_ANIMATIONS,
        "anchor": "phase_locked",
        "model_lock": model_lock,
        "frames": frames,
        "normalization": {
            "single_scale": round(scale, 6),
            "transparent_png": True,
            "source_cell": list(CELL),
            "selected_source_frames": [source_index for _phase, source_index, _grounded in JUMP_FRAME_SPECS],
        },
    }
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    source_path.write_text(
        json.dumps(
            {
                "asset_id": JUMP_ASSET_ID,
                "source_asset_id": JUMP_SOURCE_ID,
                "source": relative(JUMP_SOURCE),
                "source_sha256": sha256(JUMP_SOURCE),
                "process": "stage17_phase_selection_single_scale_model_lock_normalization",
                "model_lock": model_lock,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    update_candidate_manifest(metadata)
    print(f"Built {JUMP_ASSET_ID}: {len(frames)} frames, scale={scale:.6f}")


def main() -> None:
    args = parse_args()
    if args.jump:
        build_jump()
        return
    raise SystemExit("Choose an asset group, for example --jump")


if __name__ == "__main__":
    main()
