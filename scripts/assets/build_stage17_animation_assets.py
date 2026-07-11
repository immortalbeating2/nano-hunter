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
ENEMY_DIR = Path("assets/art/characters/enemies/sprite_sheets/runtime_replacement")
CANDIDATE_MANIFEST = Path("docs/assets/animation-runtime-replacement-candidates.json")
CELL = (192, 192)
ENEMY_CELL = (160, 160)
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
ENEMY_DEFEAT_SPECS = [
    {
        "id": "enemy_basic_melee_defeat_runtime_sheet_ai02",
        "source_id": "enemy_basic_melee_runtime_sheet_ai01",
        "animation": "basic_melee_defeat",
    },
    {
        "id": "enemy_ground_charger_defeat_runtime_sheet_ai02",
        "source_id": "enemy_ground_charger_runtime_sheet_ai01",
        "animation": "ground_charger_defeat",
    },
    {
        "id": "enemy_aerial_sentinel_defeat_runtime_sheet_ai02",
        "source_id": "enemy_aerial_sentinel_runtime_sheet_ai01",
        "animation": "aerial_sentinel_defeat",
    },
    {
        "id": "enemy_miasma_caster_defeat_runtime_sheet_ai02",
        "source_id": "enemy_miasma_caster_runtime_sheet_ai01",
        "animation": "miasma_caster_defeat",
    },
]
CHARGER_ACTION_ASSET_ID = "enemy_ground_charger_action_runtime_sheet_ai02"
CHARGER_SOURCE_ID = "enemy_ground_charger_runtime_sheet_ai01"
CHARGER_ACTION_ANIMATIONS = [
    {"name": "ground_charger_telegraph", "indexes": [0, 1, 2], "speed": 24.0, "loop": False},
    {"name": "ground_charger_charge", "indexes": [3, 4, 5], "speed": 10.0, "loop": True},
    {"name": "ground_charger_recover", "indexes": [6, 7, 8], "speed": 8.0, "loop": False},
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="构建 Stage17 动作运行态资产。")
    parser.add_argument("--jump", action="store_true", help="构建 Luna Model Lock jump-state sheet。")
    parser.add_argument("--enemies", action="store_true", help="构建普通敌人 action / defeat sheets。")
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


# 从固定网格读取一格，保留现有透明像素和角色细节。
def source_cell(
    sheet: Image.Image,
    index: int,
    columns: int,
    cell: tuple[int, int] = CELL,
) -> Image.Image:
    x = (index % columns) * cell[0]
    y = (index // columns) * cell[1]
    return sheet.crop((x, y, x + cell[0], y + cell[1])).convert("RGBA")


# 读取角色 alpha bounds；空帧属于不可恢复的源资产错误。
def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("source frame is empty")
    return tuple(int(value) for value in bbox)


# 颜色乘数只改变动作读值，不重新绘制模型；alpha 单独保留，避免透明背景被污染。
def tint_image(image: Image.Image, factors: tuple[float, float, float], alpha_factor: float) -> Image.Image:
    red, green, blue, alpha = image.split()
    channels = []
    for channel, factor in zip((red, green, blue), factors):
        channels.append(channel.point(lambda value, f=factor: min(255, round(value * f))))
    alpha = alpha.point(lambda value: min(255, round(value * alpha_factor)))
    return Image.merge("RGBA", (*channels, alpha))


# 普通敌人派生帧使用统一中心和脚底基线；状态差异只通过受控缩放、压缩和色值表达。
def normalize_enemy_frame(
    frame: Image.Image,
    scale_multiplier: float,
    width_multiplier: float,
    tint: tuple[float, float, float],
    alpha_factor: float,
    foot_y: int = 148,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(frame)
    content = frame.crop(bbox)
    safe_width = ENEMY_CELL[0] - 24
    safe_height = ENEMY_CELL[1] - 16
    base_scale = min(safe_width / content.width, safe_height / content.height, 1.0)
    width = max(1, round(content.width * base_scale * scale_multiplier * width_multiplier))
    height = max(1, round(content.height * base_scale * scale_multiplier))
    width = min(width, safe_width)
    height = min(height, safe_height)
    resized = content.resize((width, height), Image.Resampling.LANCZOS)
    resized = tint_image(resized, tint, alpha_factor)
    paste_x = round((ENEMY_CELL[0] - width) / 2)
    paste_y = foot_y - height
    output = Image.new("RGBA", ENEMY_CELL, (0, 0, 0, 0))
    output.alpha_composite(resized, (paste_x, paste_y))
    return (
        output,
        {
            "source_bbox": list(bbox),
            "normalized_size": [width, height],
            "paste": [paste_x, paste_y],
            "scale": round(base_scale * scale_multiplier, 6),
            "center_x": ENEMY_CELL[0] // 2,
            "foot_y": foot_y,
            "alpha_factor": alpha_factor,
            "tint": list(tint),
        },
    )


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


# 普通敌人资源共用同一 SpriteFrames 写入器，动作表可声明一个或多个稳定 animation 名。
def write_enemy_spriteframes(
    path: Path,
    texture_path: Path,
    asset_id: str,
    frame_count: int,
    columns: int,
    animations_spec: list[dict[str, Any]],
) -> None:
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(texture_path)}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        x = (index % columns) * ENEMY_CELL[0]
        y = (index // columns) * ENEMY_CELL[1]
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{asset_id}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {ENEMY_CELL[0]}, {ENEMY_CELL[1]})",
                "",
            ]
        )

    animations = []
    for animation in animations_spec:
        frames = [
            '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (asset_id, index)
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


# Stage17 派生资产以最小候选条目加入严格审计，不复制 frames.json 的逐帧正文。
def update_enemy_candidate_manifest(entries: list[dict[str, Any]]) -> None:
    manifest = json.loads(CANDIDATE_MANIFEST.read_text(encoding="utf-8"))
    entry_ids = {str(entry["id"]) for entry in entries}
    outputs = [item for item in manifest.get("outputs", []) if str(item.get("id", "")) not in entry_ids]
    outputs.extend(entries)
    manifest["outputs"] = outputs
    manifest["asset_count"] = len(outputs)
    manifest["active_asset_count"] = sum(1 for item in outputs if item.get("kind") == "sprite_sheet")
    manifest["archived_reference_count"] = len(outputs) - manifest["active_asset_count"]
    CANDIDATE_MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


# 从现有敌人 cycle 的后半姿态派生非血腥倒地反馈，保持模型、透明边界和脚底基线一致。
def build_enemy_defeat(spec: dict[str, str]) -> dict[str, Any]:
    asset_id = spec["id"]
    source_id = spec["source_id"]
    animation_name = spec["animation"]
    source_path = ENEMY_DIR / f"{source_id}.png"
    source_sheet = Image.open(source_path).convert("RGBA")
    selected_indexes = [4, 5, 6, 7]
    scale_multipliers = [1.0, 0.94, 0.86, 0.78]
    alpha_factors = [1.0, 0.88, 0.72, 0.56]
    tints = [
        (1.0, 0.96, 0.96),
        (0.96, 0.88, 0.88),
        (0.88, 0.76, 0.76),
        (0.78, 0.64, 0.64),
    ]
    columns = 4
    output = Image.new("RGBA", (columns * ENEMY_CELL[0], ENEMY_CELL[1]), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []
    for index, source_index in enumerate(selected_indexes):
        frame = source_cell(source_sheet, source_index, 8, ENEMY_CELL)
        normalized, record = normalize_enemy_frame(
            frame,
            scale_multipliers[index],
            1.0,
            tints[index],
            alpha_factors[index],
        )
        target_x = index * ENEMY_CELL[0]
        output.alpha_composite(normalized, (target_x, 0))
        frames.append(
            {
                "index": index,
                "name": f"{asset_id}_{animation_name}_{index + 1:02d}",
                "phase": "defeat",
                "source": relative(source_path),
                "source_frame_index": source_index,
                "region": [target_x, 0, *ENEMY_CELL],
                **record,
            }
        )

    output_path = ENEMY_DIR / f"{asset_id}.png"
    metadata_path = ENEMY_DIR / f"{asset_id}.frames.json"
    source_record_path = ENEMY_DIR / f"{asset_id}.source.json"
    spriteframes_path = ENEMY_DIR / f"{asset_id}.spriteframes.tres"
    output.save(output_path)
    animations = [{"name": animation_name, "indexes": [0, 1, 2, 3], "speed": 12.0, "loop": False}]
    write_enemy_spriteframes(spriteframes_path, output_path, asset_id, len(frames), columns, animations)
    metadata = {
        "id": asset_id,
        "source_asset_id": source_id,
        "kind": "sprite_sheet",
        "batch": "ARP-17",
        "output": relative(output_path),
        "metadata": relative(metadata_path),
        "sprite_frames": relative(spriteframes_path),
        "cell": list(ENEMY_CELL),
        "columns": columns,
        "rows": 1,
        "frame_count": len(frames),
        "animation": {"name": animation_name, "speed": 12.0, "loop": False},
        "animations": animations,
        "anchor": "foot",
        "frames": frames,
        "normalization": {
            "process": "reuse_cycle_frames_with_progressive_collapse_and_fade",
            "source_cell": list(ENEMY_CELL),
            "selected_source_frames": selected_indexes,
            "foot_baseline_y": 148,
            "center_x": 80,
        },
    }
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    source_record_path.write_text(
        json.dumps(
            {
                "asset_id": asset_id,
                "source_asset_id": source_id,
                "source": relative(source_path),
                "source_sha256": sha256(source_path),
                "process": "stage17_deterministic_cycle_to_non_gory_defeat",
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    return {key: value for key, value in metadata.items() if key != "frames"}


# Ground Charger 只派生当前 AI 已真实存在的读招、冲锋和恢复姿态，不新增攻击判定。
def build_ground_charger_action() -> dict[str, Any]:
    asset_id = CHARGER_ACTION_ASSET_ID
    source_path = ENEMY_DIR / f"{CHARGER_SOURCE_ID}.png"
    source_sheet = Image.open(source_path).convert("RGBA")
    frame_specs = [
        ("telegraph", 0, 0.92, 0.92, (0.84, 0.96, 1.08), 1.0),
        ("telegraph", 1, 0.96, 0.96, (0.88, 0.98, 1.08), 1.0),
        ("telegraph", 2, 1.0, 1.0, (0.94, 1.0, 1.08), 1.0),
        ("charge", 3, 1.0, 1.0, (1.0, 1.0, 1.0), 1.0),
        ("charge", 4, 1.0, 1.04, (1.04, 1.02, 0.96), 1.0),
        ("charge", 5, 1.0, 1.08, (1.08, 1.02, 0.92), 1.0),
        ("recover", 6, 0.98, 1.0, (0.94, 0.94, 0.98), 1.0),
        ("recover", 7, 0.92, 1.0, (0.88, 0.88, 0.94), 0.92),
        ("recover", 0, 0.86, 1.0, (0.80, 0.80, 0.88), 0.84),
    ]
    columns = 3
    rows = 3
    output = Image.new("RGBA", (columns * ENEMY_CELL[0], rows * ENEMY_CELL[1]), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []
    for index, (phase, source_index, scale, width_scale, tint, alpha_factor) in enumerate(frame_specs):
        frame = source_cell(source_sheet, source_index, 8, ENEMY_CELL)
        normalized, record = normalize_enemy_frame(frame, scale, width_scale, tint, alpha_factor)
        target_x = (index % columns) * ENEMY_CELL[0]
        target_y = (index // columns) * ENEMY_CELL[1]
        output.alpha_composite(normalized, (target_x, target_y))
        frames.append(
            {
                "index": index,
                "name": f"{asset_id}_{phase}_{index + 1:02d}",
                "phase": phase,
                "source": relative(source_path),
                "source_frame_index": source_index,
                "region": [target_x, target_y, *ENEMY_CELL],
                **record,
            }
        )

    output_path = ENEMY_DIR / f"{asset_id}.png"
    metadata_path = ENEMY_DIR / f"{asset_id}.frames.json"
    source_record_path = ENEMY_DIR / f"{asset_id}.source.json"
    spriteframes_path = ENEMY_DIR / f"{asset_id}.spriteframes.tres"
    output.save(output_path)
    write_enemy_spriteframes(
        spriteframes_path,
        output_path,
        asset_id,
        len(frames),
        columns,
        CHARGER_ACTION_ANIMATIONS,
    )
    metadata = {
        "id": asset_id,
        "source_asset_id": CHARGER_SOURCE_ID,
        "kind": "sprite_sheet",
        "batch": "ARP-17",
        "output": relative(output_path),
        "metadata": relative(metadata_path),
        "sprite_frames": relative(spriteframes_path),
        "cell": list(ENEMY_CELL),
        "columns": columns,
        "rows": rows,
        "frame_count": len(frames),
        "animation": CHARGER_ACTION_ANIMATIONS[0],
        "animations": CHARGER_ACTION_ANIMATIONS,
        "anchor": "foot",
        "frames": frames,
        "normalization": {
            "process": "reuse_cycle_frames_with_state_specific_pose_emphasis",
            "source_cell": list(ENEMY_CELL),
            "foot_baseline_y": 148,
            "center_x": 80,
        },
    }
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    source_record_path.write_text(
        json.dumps(
            {
                "asset_id": asset_id,
                "source_asset_id": CHARGER_SOURCE_ID,
                "source": relative(source_path),
                "source_sha256": sha256(source_path),
                "process": "stage17_deterministic_cycle_to_telegraph_charge_recover",
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    return {key: value for key, value in metadata.items() if key != "frames"}


def build_enemies() -> None:
    ENEMY_DIR.mkdir(parents=True, exist_ok=True)
    entries = [build_enemy_defeat(spec) for spec in ENEMY_DEFEAT_SPECS]
    entries.append(build_ground_charger_action())
    update_enemy_candidate_manifest(entries)
    print(f"Built Stage17 regular enemy assets: {len(entries)} sheets")


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
    if args.enemies:
        build_enemies()
        return
    raise SystemExit("Choose an asset group, for example --jump or --enemies")


if __name__ == "__main__":
    main()
