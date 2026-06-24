#!/usr/bin/env python3
"""Build a clean Luna air-dash body runtime candidate from an image_gen chroma strip."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shutil
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_SOURCE_IMAGE = (
    "C:/Users/peng8/.codex/generated_images/019dd85a-7144-7b63-924f-979212c1d613/"
    "ig_0a8a071ef4b2be08016a3bb0488ba881998e6e33f2e1f9e788.png"
)
DEFAULT_CANDIDATE_MANIFEST = "docs/assets/animation-runtime-replacement-candidates.json"
DEFAULT_INBOX_DIR = "assets/source/imagegen_inbox/animation_runtime_replacement/arp_13"
DEFAULT_OUT_DIR = "assets/art/characters/player/sprite_sheets/runtime_replacement"
ASSET_ID = "luna_air_dash_body_runtime_sheet_ai02"
SOURCE_ASSET_ID = "imagegen_luna_air_dash_body_clean_source_ai02"
CELL = [192, 160]
COLUMNS = 8
FRAME_COUNT = 8
HORIZONTAL_PADDING = 24
VERTICAL_PADDING = 8
ANIMATION_NAME = "air_dash_body"
ANIMATION_SPEED = 20.0
PROMPT = """Use case: stylized-concept
Asset type: production candidate spritesheet for a 2D Godot metroidvania player air dash body animation
Primary request: Create a single horizontal 8-frame spritesheet of Luna, a young Northern-and-Southern-Dynasties inspired demon-hunter heroine, performing a fast forward air dash. This is body-only animation for runtime integration.
Subject and style: same character identity across all frames; elegant Chinese fantasy / Shan Hai Jing / Buddhist talisman hunter style; white layered robe, dark teal-black flowing hair, teal sash fabric, small talisman accessories, slim athletic silhouette, painterly 2D game sprite art matching a soft Ori-like readable action silhouette.
Composition: exactly one row of 8 equal frame slots, left-to-right action progression, character facing right in every frame, generous empty padding around each frame, consistent scale, consistent bottom-center anchor, no cropped limbs.
Action beats: frame 1 crouched air-dash anticipation, frame 2 launch lean, frames 3-5 stretched forward dash body pose, frames 6-7 recovery hover, frame 8 compact landing-ready recovery pose.
Background: perfectly flat solid #00ff00 chroma-key background for local removal; one uniform color only, no shadows, no gradients, no texture, no floor plane.
Critical constraints: no cyan energy ball, no blue glow, no air trail, no slash arc, no impact burst, no dust, no particles, no detached fragments, no extra characters, no labels, no text, no watermark. Do not use #00ff00 anywhere in the character. Keep all 8 frames clearly separated with empty green space between slots.
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build Luna air-dash body ai02 runtime sheet from a built-in image_gen chroma-key strip.",
    )
    parser.add_argument("--source-image", default=DEFAULT_SOURCE_IMAGE)
    parser.add_argument("--candidate-manifest", default=DEFAULT_CANDIDATE_MANIFEST)
    parser.add_argument("--inbox-dir", default=DEFAULT_INBOX_DIR)
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def res_path(path: Path, root: Path) -> str:
    return "res://" + rel(path, root)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def remove_green_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    key = (0, 255, 0)
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            distance = math.sqrt((r - key[0]) ** 2 + (g - key[1]) ** 2 + (b - key[2]) ** 2)
            if distance <= 95:
                pixels[x, y] = (r, g, b, 0)
            elif distance <= 145 and g > r + 65 and g > b + 45:
                fade = int(round(255 * ((distance - 95) / 50)))
                pixels[x, y] = (r, min(g, max(r, b) + 18), b, min(a, fade))
            elif g > r + 85 and g > b + 60:
                pixels[x, y] = (r, min(g, max(r, b) + 24), b, a)
    return rgba


def alpha_column_runs(image: Image.Image, threshold: int = 10) -> list[tuple[int, int]]:
    alpha = image.getchannel("A")
    counts: list[int] = []
    for x in range(image.width):
        column_count = 0
        for y in range(image.height):
            if alpha.getpixel((x, y)) > 12:
                column_count += 1
        counts.append(column_count)

    runs: list[tuple[int, int]] = []
    in_run = False
    start = 0
    for x, count in enumerate(counts):
        if count > threshold and not in_run:
            start = x
            in_run = True
        if in_run and (count <= threshold or x == image.width - 1):
            end = x if count <= threshold else x + 1
            if end - start >= 24:
                runs.append((start, end))
            in_run = False
    return runs


def normalize_slices(source: Image.Image) -> tuple[Image.Image, list[dict[str, Any]], dict[str, Any]]:
    transparent = remove_green_background(source)
    source_width, source_height = transparent.size
    runs = alpha_column_runs(transparent)
    if len(runs) != FRAME_COUNT:
        raise SystemExit(f"Expected {FRAME_COUNT} projected frame runs, found {len(runs)}: {runs}")

    slices: list[dict[str, Any]] = []
    for index, (left, right) in enumerate(runs):
        frame = transparent.crop((left, 0, right, source_height))
        bbox = frame.getchannel("A").getbbox()
        if bbox is None:
            continue
        content = frame.crop(bbox)
        slices.append(
            {
                "index": index,
                "source_region": [left, 0, right - left, source_height],
                "source_bbox": [int(value) for value in bbox],
                "content": content,
                "content_size": [content.width, content.height],
            }
        )

    if len(slices) != FRAME_COUNT:
        raise SystemExit(f"Expected {FRAME_COUNT} non-empty slices, found {len(slices)}")

    safe_width = CELL[0] - (HORIZONTAL_PADDING * 2)
    safe_height = CELL[1] - (VERTICAL_PADDING * 2)
    max_width = max(int(item["content_size"][0]) for item in slices)
    max_height = max(int(item["content_size"][1]) for item in slices)
    scale = min(1.0, safe_width / max(1, max_width), safe_height / max(1, max_height))
    sheet = Image.new("RGBA", (CELL[0] * COLUMNS, CELL[1]), (0, 0, 0, 0))
    foot_baseline_y = CELL[1] - VERTICAL_PADDING
    center_x = CELL[0] // 2
    frames: list[dict[str, Any]] = []

    for output_index, item in enumerate(slices):
        content = item["content"]
        resized = content.resize(
            (
                max(1, int(round(content.width * scale))),
                max(1, int(round(content.height * scale))),
            ),
            Image.Resampling.LANCZOS,
        )
        cell = Image.new("RGBA", tuple(CELL), (0, 0, 0, 0))
        paste_x = int(round(center_x - resized.width / 2))
        paste_y = int(round(foot_baseline_y - resized.height))
        cell.alpha_composite(resized, dest=(paste_x, paste_y))
        target_x = output_index * CELL[0]
        sheet.alpha_composite(cell, dest=(target_x, 0))
        frames.append(
            {
                "index": output_index,
                "name": f"{ASSET_ID}_runtime_{output_index + 1:03d}",
                "source": SOURCE_ASSET_ID,
                "source_frame_index": int(item["index"]),
                "source_region": item["source_region"],
                "source_bbox": item["source_bbox"],
                "region": [target_x, 0, CELL[0], CELL[1]],
            }
        )

    summary = {
        "source_image_size": [source_width, source_height],
        "source_max_content_size": [max_width, max_height],
        "target_safe_size": [safe_width, safe_height],
        "scale": round(scale, 6),
        "horizontal_padding": HORIZONTAL_PADDING,
        "vertical_padding": VERTICAL_PADDING,
        "foot_baseline_y": foot_baseline_y,
        "center_x": center_x,
        "projected_runs": [[int(left), int(right)] for left, right in runs],
        "slice_strategy": "alpha_projection_8_horizontal_runs_then_alpha_bbox_normalize",
    }
    return sheet, frames, summary


def write_spriteframes(root: Path, path: Path, texture_path: Path, frame_count: int) -> None:
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{res_path(texture_path, root)}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        x = index * CELL[0]
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{ASSET_ID}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, 0, {CELL[0]}, {CELL[1]})",
                "",
            ]
        )
    frames = [
        '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (ASSET_ID, index)
        for index in range(frame_count)
    ]
    lines.extend(
        [
            "[resource]",
            "animations = [{",
            f'"frames": [{", ".join(frames)}],',
            '"loop": false,',
            f'"name": &"{ANIMATION_NAME}",',
            f'"speed": {ANIMATION_SPEED:.1f}',
            "}]",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def merge_candidate_manifest(root: Path, manifest_path: Path, item: dict[str, Any]) -> None:
    manifest = load_json(manifest_path)
    merged: dict[str, dict[str, Any]] = {}
    for existing in manifest.get("outputs", []):
        merged[str(existing["id"])] = existing
    merged[str(item["id"])] = item
    outputs = list(merged.values())
    manifest["outputs"] = outputs
    manifest["asset_count"] = len(outputs)
    manifest["pass"] = "mixed"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    source_path = Path(args.source_image).resolve()
    if not source_path.exists():
        raise SystemExit(f"Missing source image: {source_path}")

    inbox_dir = (root / args.inbox_dir).resolve()
    out_dir = (root / args.out_dir).resolve()
    inbox_path = inbox_dir / f"{SOURCE_ASSET_ID}.png"
    output_path = out_dir / f"{ASSET_ID}.png"
    metadata_path = out_dir / f"{ASSET_ID}.frames.json"
    spriteframes_path = out_dir / f"{ASSET_ID}.spriteframes.tres"
    source_record_path = out_dir / f"{ASSET_ID}.source.json"
    manifest_path = (root / args.candidate_manifest).resolve()

    sheet, frames, summary = normalize_slices(Image.open(source_path))
    candidate_metadata = {
        "id": ASSET_ID,
        "source_asset_id": SOURCE_ASSET_ID,
        "kind": "sprite_sheet",
        "output": rel(output_path, root),
        "cell": CELL,
        "columns": COLUMNS,
        "rows": 1,
        "frames": frames,
        "normalization": summary,
    }
    source_record = {
        "asset_id": ASSET_ID,
        "source_asset_id": SOURCE_ASSET_ID,
        "source_texture": rel(inbox_path, root),
        "source_hash_sha256": sha256(source_path),
        "tool": "built_in_image_gen",
        "process": "imagegen_chroma_key_strip_to_runtime_normalized_candidate",
        "prompt": PROMPT,
        "boundary": (
            "Clean Luna air-dash body candidate only. Independent AirDashTrailArt remains the VFX layer; "
            "dash physics, ability gating, collision and cooldown timing are unchanged."
        ),
        "normalization": summary,
    }
    manifest_item = {
        "id": ASSET_ID,
        "source_asset_id": SOURCE_ASSET_ID,
        "kind": "sprite_sheet",
        "batch": "ARP-13",
        "output": rel(output_path, root),
        "metadata": rel(metadata_path, root),
        "sprite_frames": rel(spriteframes_path, root),
        "cell": CELL,
        "columns": COLUMNS,
        "animation": {"name": ANIMATION_NAME, "speed": ANIMATION_SPEED, "loop": False},
        "frame_count": len(frames),
        "normalization": summary,
    }

    if not args.dry_run:
        inbox_dir.mkdir(parents=True, exist_ok=True)
        out_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, inbox_path)
        sheet.save(output_path)
        metadata_path.write_text(json.dumps(candidate_metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        source_record_path.write_text(json.dumps(source_record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_spriteframes(root, spriteframes_path, output_path, len(frames))
        merge_candidate_manifest(root, manifest_path, manifest_item)

    print(
        f"Luna air-dash body candidate {'planned' if args.dry_run else 'built'}: "
        f"{ASSET_ID}, {len(frames)} frames, scale={summary['scale']}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
