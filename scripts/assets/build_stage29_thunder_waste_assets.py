#!/usr/bin/env python3
"""从 Stage29 image_gen 候选构建雷泽背景、地形、地标与机关 VFX。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image

from build_luna_unified_runtime_body_sheets import crop_grid_cell
from build_stage27_formal_combat_assets import normalize_frame


ROOT = Path.cwd()
SOURCE_ROOT = Path("assets/source/ai_generated/batch_29")
OUT = Path("assets/art/environment/thunder_waste")

BACKGROUND_SOURCE_ID = "stage29_thunder_waste_background_ai01"
ENVIRONMENT_SOURCE_ID = "stage29_thunder_waste_environment_sheet_ai01"
VFX_SOURCE_ID = "stage29_thunder_waste_state_vfx_ai01"

BACKGROUND_ID = "stage29_thunder_waste_background_runtime_ai01"
ENVIRONMENT_ID = "stage29_thunder_waste_environment_runtime_ai01"
VFX_ID = "stage29_thunder_waste_state_vfx_runtime_ai01"
TILES_ID = "stage29_thunder_waste_tiles_runtime_ai01"

VFX_ANIMATIONS: dict[str, list[int]] = {
    "storm_active": [0, 1, 2],
    "storm_grounded": [3],
    "relay_active": [4],
    "relay_struck": [5],
    "relay_grounded": [6],
    "relay_disabled": [7],
    "barrier_locked": [8],
    "barrier_unlock": [9, 10],
    "barrier_open": [10],
    "exit_right": [11],
    "outpost_checkpoint": [12],
    "branch_up": [13],
    "cloud_flash": [14],
    "safe_discharge": [15],
}


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


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def source_candidate(asset_id: str) -> Path:
    return SOURCE_ROOT / asset_id / "candidates" / f"{asset_id}_candidate_01.png"


def alpha_candidate(asset_id: str) -> Path:
    return SOURCE_ROOT / asset_id / "prepared" / f"{asset_id}_alpha.png"


def crop_cell_without_grid(image: Image.Image, index: int) -> Image.Image:
    """去掉 image_gen 偶发的 1px 网格线，避免其进入透明内容包围盒。"""
    raw = crop_grid_cell(image, 4, 4, index)
    inset = 3
    return raw.crop((inset, inset, raw.width - inset, raw.height - inset))


def write_source_record(
    path: Path,
    source_asset_id: str,
    source: Path,
    output: Path,
    constraints: list[str],
) -> None:
    write_json(
        path,
        {
            "asset_id": source_asset_id,
            "runtime_asset_id": output.stem,
            "project_key": "nano-hunter",
            "project_name": "Nano Hunter",
            "candidate_index": 1,
            "source": relative(source),
            "source_sha256": sha256(source),
            "output": relative(output),
            "output_sha256": sha256(output),
            "process": "built_in_image_gen_stage29_fixed_grid_chroma_to_alpha",
            "license_record_status": "source_recorded_terms_review_required",
            "commercial_use_status": "manual_terms_review_required_before_external_release",
            "constraints": constraints,
        },
    )


def build_background() -> None:
    source = source_candidate(BACKGROUND_SOURCE_ID)
    image = Image.open(source).convert("RGB")
    crop_height = round(image.width / (1280 / 512))
    top = max(0, (image.height - crop_height) // 2)
    runtime = image.crop((0, top, image.width, top + crop_height)).resize(
        (1280, 512), Image.Resampling.LANCZOS
    )
    OUT.mkdir(parents=True, exist_ok=True)
    output = OUT / f"{BACKGROUND_ID}.png"
    runtime.save(output)
    write_source_record(
        OUT / f"{BACKGROUND_ID}.source.json",
        BACKGROUND_SOURCE_ID,
        source,
        output,
        ["camera_bounds_1280x512", "three_depth_layers", "display_layer_only"],
    )
    print(f"built {BACKGROUND_ID}: {output} ({sha256(output)})")


def build_grid_asset(source_asset_id: str, runtime_id: str, kind: str) -> Path:
    source = source_candidate(source_asset_id)
    image = Image.open(alpha_candidate(source_asset_id)).convert("RGBA")
    atlas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []
    for index in range(16):
        raw = crop_cell_without_grid(image, index)
        frame, record = normalize_frame(raw, (256, 256), (236, 236), "center", None)
        target = ((index % 4) * 256, (index // 4) * 256)
        atlas.alpha_composite(frame, target)
        frames.append({"index": index, "region": [*target, 256, 256], **record})

    OUT.mkdir(parents=True, exist_ok=True)
    output = OUT / f"{runtime_id}.png"
    atlas.save(output)
    write_json(
        OUT / f"{runtime_id}.frames.json",
        {
            "id": runtime_id,
            "kind": kind,
            "output": relative(output),
            "cell": [256, 256],
            "columns": 4,
            "rows": 4,
            "frame_count": 16,
            "frames": frames,
        },
    )
    write_source_record(
        OUT / f"{runtime_id}.source.json",
        source_asset_id,
        source,
        output,
        ["transparent_png", "fixed_4x4_grid", "small_scale_readability"],
    )
    print(f"built {runtime_id}: {output} ({sha256(output)})")
    return output


def build_tileset() -> None:
    source = source_candidate(ENVIRONMENT_SOURCE_ID)
    image = Image.open(alpha_candidate(ENVIRONMENT_SOURCE_ID)).convert("RGBA")
    atlas = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
    for index in range(4):
        raw = crop_cell_without_grid(image, index)
        frame, _record = normalize_frame(raw, (64, 64), (62, 60), "bottom", 64)
        atlas.alpha_composite(frame, (index * 64, 0))

    output = OUT / f"{TILES_ID}.png"
    atlas.save(output)
    write_source_record(
        OUT / f"{TILES_ID}.source.json",
        ENVIRONMENT_SOURCE_ID,
        source,
        output,
        ["64px_tiles", "collision_disabled_visual_layer", "safe_and_hazard_ground"],
    )
    tiles = "\n".join(f"{index}:0/0 = 0" for index in range(4))
    resource = (
        '[gd_resource type="TileSet" load_steps=3 format=3]\n\n'
        f'[ext_resource type="Texture2D" path="{resource_path(output)}" id="1"]\n\n'
        '[sub_resource type="TileSetAtlasSource" id="Stage29Atlas"]\n'
        'texture = ExtResource("1")\n'
        'texture_region_size = Vector2i(64, 64)\n'
        f"{tiles}\n\n"
        '[resource]\n'
        'tile_size = Vector2i(64, 64)\n'
        'sources/0 = SubResource("Stage29Atlas")\n'
    )
    (OUT / f"{TILES_ID}.tileset.tres").write_text(resource, encoding="utf-8")
    print(f"built {TILES_ID}: {output} ({sha256(output)})")


def write_vfx_spriteframes(texture: Path) -> None:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=18 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(texture)}" id="1"]',
        "",
    ]
    for index in range(16):
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="Stage29Vfx_{index:02d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({(index % 4) * 256}, {(index // 4) * 256}, 256, 256)",
                "",
            ]
        )
    animations: list[str] = []
    for name, indexes in VFX_ANIMATIONS.items():
        frames = ", ".join(
            '{"duration": 1.0, "texture": SubResource("Stage29Vfx_%02d")}' % index
            for index in indexes
        )
        animations.append(
            "{\n"
            f'"frames": [{frames}],\n'
            f'"loop": {"true" if name == "storm_active" else "false"},\n'
            f'"name": &"{name}",\n'
            f'"speed": {6.0 if name == "storm_active" else 4.0:.1f}\n'
            "}"
        )
    lines.extend(["[resource]", f'animations = [{", ".join(animations)}]'])
    (OUT / f"{VFX_ID}.spriteframes.tres").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    build_background()
    build_grid_asset(ENVIRONMENT_SOURCE_ID, ENVIRONMENT_ID, "environment_prop_sheet")
    vfx_texture = build_grid_asset(VFX_SOURCE_ID, VFX_ID, "environment_state_vfx_sheet")
    build_tileset()
    write_vfx_spriteframes(vfx_texture)


if __name__ == "__main__":
    main()
