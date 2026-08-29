#!/usr/bin/env python3
"""Build unified Luna runtime body sheets from fixed-grid image_gen sources."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shutil
from pathlib import Path
from typing import Any

from PIL import Image

from character_creature_model_lock_contract import model_lock_for_asset


INBOX_DIR = Path("assets/source/imagegen_inbox/luna_unified_runtime_body_2026_07_03")
SOURCE_DIR = INBOX_DIR
OUT_DIR = Path("assets/art/characters/player/sprite_sheets/runtime_replacement")
MANIFEST_PATH = Path("docs/assets/luna-unified-runtime-body-candidates-2026-07-03.json")
CELL = [192, 192]
SAFE_SIZE = [144, 144]
MAGENTA = (255, 0, 255)
ASSETS: list[dict[str, Any]] = [
    {
        "id": "luna_idle_runtime_sheet_ai03",
        "source": "ig_0ded67518d3bd3ad016a46ba4c4e3c819492f783c9bad241d2.png",
        "grid": [4, 4],
        "frames": 16,
        "animation": {"name": "idle", "speed": 8.0, "loop": True},
        "anchor": "foot",
    },
    {
        "id": "luna_run_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bacf88048196ba785a223a3953dc.png",
        "grid": [6, 4],
        "frames": 24,
        "animation": {"name": "run", "speed": 18.0, "loop": True},
        "anchor": "foot",
    },
    {
        "id": "luna_jump_fall_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bb43392881969f456d3e6631136f.png",
        "grid": [6, 4],
        "frames": 24,
        "animation": {"name": "jump_fall", "speed": 14.0, "loop": False},
        "anchor": "body_center",
    },
    {
        "id": "luna_attack_body_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bbc07af081968cfcbe5ea1f0bfcb.png",
        "grid": [4, 4],
        "frames": 16,
        "animation": {"name": "attack_body", "speed": 18.0, "loop": False},
        "anchor": "foot",
    },
    {
        "id": "luna_air_dash_body_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bc0536808196a8244280a4c0596e.png",
        "grid": [4, 4],
        "frames": 16,
        "animation": {"name": "air_dash_body", "speed": 20.0, "loop": False},
        "anchor": "body_center",
    },
    {
        "id": "luna_hit_react_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bc4873788196a3f159bc0054b41a.png",
        "grid": [4, 2],
        "frames": 8,
        "animation": {"name": "hit_react", "speed": 14.0, "loop": False},
        "anchor": "foot",
    },
    {
        "id": "luna_death_idle_runtime_sheet_ai03",
        "source": "ig_0b7418c88991aee0016a46bc7c9cc88196bcedac95e2b2a55f.png",
        "grid": [5, 4],
        "frames": 20,
        "animation": {"name": "death_idle", "speed": 10.0, "loop": False},
        "anchor": "foot",
    },
]


def rel(path: Path) -> str:
    return path.resolve().relative_to(Path.cwd().resolve()).as_posix()


def res_path(path: Path) -> str:
    return "res://" + rel(path)


def build_model_lock(asset: dict[str, Any]) -> dict[str, Any]:
    """从中央清单读取 Luna 契约，避免生成器与审查规则分叉。"""
    return model_lock_for_asset(Path.cwd().resolve(), str(asset["id"]))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def key_to_alpha(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            dist = math.sqrt((r - MAGENTA[0]) ** 2 + (g - MAGENTA[1]) ** 2 + (b - MAGENTA[2]) ** 2)
            is_key_fringe = r > 170 and b > 160 and g < 135 and abs(r - b) < 75
            if dist <= 86 or is_key_fringe:
                pixels[x, y] = (r, g, b, 0)
            elif dist <= 135 and r > 160 and b > 150:
                fade = int(round(255 * ((dist - 86) / 49)))
                pixels[x, y] = (r, g, b, min(a, fade))
    return rgba


def remove_grid_rules(frame: Image.Image) -> Image.Image:
    rgba = frame.copy()
    pixels = rgba.load()

    for y in range(rgba.height):
        white_count = 0
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            if a > 0 and r > 215 and g > 215 and b > 215:
                white_count += 1
        if white_count > rgba.width * 0.45:
            for x in range(rgba.width):
                r, g, b, a = pixels[x, y]
                if a > 0 and r > 200 and g > 200 and b > 200:
                    pixels[x, y] = (r, g, b, 0)

    for x in range(rgba.width):
        white_count = 0
        for y in range(rgba.height):
            r, g, b, a = pixels[x, y]
            if a > 0 and r > 215 and g > 215 and b > 215:
                white_count += 1
        if white_count > rgba.height * 0.45:
            for y in range(rgba.height):
                r, g, b, a = pixels[x, y]
                if a > 0 and r > 200 and g > 200 and b > 200:
                    pixels[x, y] = (r, g, b, 0)

    return rgba


def remove_thin_background_fragments(frame: Image.Image) -> Image.Image:
    rgba = frame.copy()
    pixels = rgba.load()
    visited: set[tuple[int, int]] = set()

    for start_y in range(rgba.height):
        for start_x in range(rgba.width):
            if (start_x, start_y) in visited or pixels[start_x, start_y][3] <= 24:
                continue

            stack = [(start_x, start_y)]
            visited.add((start_x, start_y))
            points: list[tuple[int, int]] = []
            while stack:
                x, y = stack.pop()
                points.append((x, y))
                for next_x in range(x - 1, x + 2):
                    for next_y in range(y - 1, y + 2):
                        if (
                            next_x < 0
                            or next_x >= rgba.width
                            or next_y < 0
                            or next_y >= rgba.height
                            or (next_x, next_y) in visited
                            or pixels[next_x, next_y][3] <= 24
                        ):
                            continue
                        visited.add((next_x, next_y))
                        stack.append((next_x, next_y))

            xs = [point[0] for point in points]
            ys = [point[1] for point in points]
            width = max(xs) - min(xs) + 1
            height = max(ys) - min(ys) + 1
            is_lower_half = min(ys) >= rgba.height * 0.55
            if is_lower_half and height <= 3 and width >= 24:
                for x, y in points:
                    r, g, b, _a = pixels[x, y]
                    pixels[x, y] = (r, g, b, 0)

    return rgba


def crop_grid_cell(source: Image.Image, columns: int, rows: int, index: int) -> Image.Image:
    col = index % columns
    row = index // columns
    left = round(col * source.width / columns)
    right = round((col + 1) * source.width / columns)
    top = round(row * source.height / rows)
    bottom = round((row + 1) * source.height / rows)
    # Generated grid lines sit on cell edges; trim only the gutter line, not the sprite.
    margin = 12
    return source.crop((left + margin, top + margin, right - margin, bottom - margin))


def normalize_frame(frame: Image.Image, anchor: str, scale: float | None = None) -> tuple[Image.Image, dict[str, Any]]:
    alpha = frame.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("empty frame after chroma-key removal")

    content = frame.crop(bbox)
    if scale is None:
        scale = min(SAFE_SIZE[0] / content.width, SAFE_SIZE[1] / content.height, 1.0)
    resized = content.resize(
        (max(1, round(content.width * scale)), max(1, round(content.height * scale))),
        Image.Resampling.LANCZOS,
    )
    cell = Image.new("RGBA", tuple(CELL), (0, 0, 0, 0))
    x = round((CELL[0] - resized.width) / 2)
    if anchor == "body_center":
        y = round((CELL[1] - resized.height) / 2)
    else:
        y = CELL[1] - 16 - resized.height
    cell.alpha_composite(resized, (x, y))
    return cell, {
        "source_bbox": [int(value) for value in bbox],
        "content_size": [content.width, content.height],
        "normalized_size": [resized.width, resized.height],
        "paste": [x, y],
        "scale": round(scale, 6),
    }


def write_spriteframes(path: Path, texture_path: Path, asset: dict[str, Any]) -> None:
    frame_count = int(asset["frames"])
    columns = int(asset["grid"][0])
    anim = asset["animation"]
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{res_path(texture_path)}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        x = (index % columns) * CELL[0]
        y = (index // columns) * CELL[1]
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{asset["id"]}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {CELL[0]}, {CELL[1]})",
                "",
            ]
        )
    frames = [
        '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (asset["id"], index)
        for index in range(frame_count)
    ]
    loop = "true" if anim["loop"] else "false"
    lines.extend(
        [
            "[resource]",
            "animations = [{",
            f'"frames": [{", ".join(frames)}],',
            f'"loop": {loop},',
            f'"name": &"{anim["name"]}",',
            f'"speed": {float(anim["speed"]):.1f}',
            "}]",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_asset(asset: dict[str, Any]) -> dict[str, Any]:
    source_path = SOURCE_DIR / asset["source"]
    if not source_path.exists():
        raise FileNotFoundError(source_path)

    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    inbox_path = INBOX_DIR / asset["source"]
    if source_path.resolve() != inbox_path.resolve():
        shutil.copy2(source_path, inbox_path)

    source = key_to_alpha(Image.open(source_path))
    columns, rows = [int(value) for value in asset["grid"]]
    frame_count = int(asset["frames"])
    sheet = Image.new("RGBA", (columns * CELL[0], rows * CELL[1]), (0, 0, 0, 0))
    frame_records: list[dict[str, Any]] = []
    cell_sources = [
        remove_thin_background_fragments(remove_grid_rules(crop_grid_cell(source, columns, rows, index)))
        for index in range(frame_count)
    ]
    bboxes = [frame.getchannel("A").getbbox() for frame in cell_sources]
    if any(bbox is None for bbox in bboxes):
        raise ValueError(f"{asset['id']} contains empty frame after cleanup")
    max_content_width = max(int(bbox[2] - bbox[0]) for bbox in bboxes if bbox is not None)
    max_content_height = max(int(bbox[3] - bbox[1]) for bbox in bboxes if bbox is not None)
    action_scale = min(SAFE_SIZE[0] / max_content_width, SAFE_SIZE[1] / max_content_height, 1.0)
    model_lock = build_model_lock(asset)
    scales: list[float] = []
    for index in range(frame_count):
        normalized, info = normalize_frame(cell_sources[index], str(asset["anchor"]), action_scale)
        x = (index % columns) * CELL[0]
        y = (index // columns) * CELL[1]
        sheet.alpha_composite(normalized, (x, y))
        scales.append(float(info["scale"]))
        frame_records.append(
            {
                "index": index,
                "name": f"{asset['id']}_runtime_{index + 1:03d}",
                "source": rel(inbox_path),
                "source_frame_index": index,
                "region": [x, y, CELL[0], CELL[1]],
                **info,
                "center_x": round(float(info["paste"][0]) + float(info["normalized_size"][0]) / 2.0, 2),
                "head_y": int(info["paste"][1]),
                "foot_y": int(info["paste"][1]) + int(info["normalized_size"][1]),
                "body_height": int(info["normalized_size"][1]),
            }
        )

    output_path = OUT_DIR / f"{asset['id']}.png"
    metadata_path = OUT_DIR / f"{asset['id']}.frames.json"
    spriteframes_path = OUT_DIR / f"{asset['id']}.spriteframes.tres"
    source_record_path = OUT_DIR / f"{asset['id']}.source.json"
    sheet.save(output_path)
    metadata = {
        "id": asset["id"],
        "kind": "sprite_sheet",
        "source_asset_id": f"imagegen_{asset['id']}",
        "output": rel(output_path),
        "metadata": rel(metadata_path),
        "sprite_frames": rel(spriteframes_path),
        "cell": CELL,
        "columns": columns,
        "rows": rows,
        "frame_count": frame_count,
        "animation": asset["animation"],
        "anchor": asset["anchor"],
        "model_lock": model_lock,
        "frames": frame_records,
        "normalization": {
            "safe_size": SAFE_SIZE,
            "source_grid": [columns, rows],
            "chroma_key": "#ff00ff",
            "scale_min": round(min(scales), 6),
            "scale_max": round(max(scales), 6),
            "transparent_png": True,
        },
    }
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    source_record_path.write_text(
        json.dumps(
            {
                "asset_id": asset["id"],
                "source": rel(inbox_path),
                "source_sha256": sha256(inbox_path),
                "process": "built_in_image_gen_fixed_grid_chroma_to_alpha_runtime_body_sheet",
                "constraints": [
                    "transparent_png",
                    "no_green_background",
                    "no_white_background",
                    "no_checkerboard_background",
                    "fixed_grid",
                    "one_action_per_sheet",
                    "stable_scale",
                    "stable_anchor",
                ],
                "anchor": asset["anchor"],
                "model_lock": model_lock,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    write_spriteframes(spriteframes_path, output_path, asset)
    return metadata


def enrich_existing_asset(asset: dict[str, Any]) -> dict[str, Any]:
    """源图不在当前 checkout 时，只为已存在且已审计的运行表补写 Model Lock 元数据。"""
    metadata_path = OUT_DIR / f"{asset['id']}.frames.json"
    source_record_path = OUT_DIR / f"{asset['id']}.source.json"
    if not metadata_path.exists() or not source_record_path.exists():
        raise FileNotFoundError(f"Missing existing Luna runtime metadata for {asset['id']}")

    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    model_lock = build_model_lock(asset)
    metadata["model_lock"] = model_lock
    for frame in metadata.get("frames", []):
        paste = [int(value) for value in frame.get("paste", [0, 0])]
        size = [int(value) for value in frame.get("normalized_size", [0, 0])]
        frame["center_x"] = round(float(paste[0]) + float(size[0]) / 2.0, 2)
        frame["head_y"] = paste[1]
        frame["foot_y"] = paste[1] + size[1]
        frame["body_height"] = size[1]
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    source_record = json.loads(source_record_path.read_text(encoding="utf-8"))
    source_record["model_lock"] = model_lock
    source_record_path.write_text(
        json.dumps(source_record, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="enrich existing audited outputs when original image-gen source files are unavailable",
    )
    args = parser.parse_args()
    outputs = [
        enrich_existing_asset(asset) if args.metadata_only else build_asset(asset)
        for asset in ASSETS
    ]
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps(
            {
                "version": 1,
                "status": "luna_unified_runtime_body_candidate",
                "asset_count": len(outputs),
                "outputs": outputs,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    action = "Enriched" if args.metadata_only else "Built"
    print(f"{action} {len(outputs)} Luna unified runtime body sheets")
    print(MANIFEST_PATH)


if __name__ == "__main__":
    main()
