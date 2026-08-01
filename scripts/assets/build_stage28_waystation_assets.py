#!/usr/bin/env python3
"""从 Stage28 image_gen 候选构建驿站背景、世界物件与 UI 图集。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image

from build_luna_unified_runtime_body_sheets import crop_grid_cell
from build_stage27_formal_combat_assets import normalize_frame


ROOT = Path.cwd()
SOURCE_ROOT = Path("assets/source/ai_generated/batch_28")
ENV_OUT = Path("assets/art/environment/waystation")
UI_OUT = Path("assets/art/ui")

BACKGROUND_ID = "stage28_waystation_background_runtime_ai01"
WORLD_ID = "stage28_waystation_world_runtime_ai01"
UI_ID = "stage28_waystation_ui_runtime_ai01"

WORLD_ANIMATIONS: dict[str, list[int]] = {
    "bounty_available": [0],
    "bounty_accepted": [1],
    "bounty_completed": [2],
    "bounty_turned_in": [3],
    "clerk_idle": [4, 5, 6, 7],
    "lantern": [8],
    "bell": [9],
    "route_locked": [10],
    "route_open": [11],
    "travel_left": [12],
    "travel_right": [13],
    "checkpoint": [14],
    "document_chest": [15],
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


def build_background() -> None:
    source = SOURCE_ROOT / "stage28_waystation_background_ai01/candidates/stage28_waystation_background_ai01_candidate_01.png"
    image = Image.open(source).convert("RGB")
    crop_height = round(image.width / (1152 / 512))
    top = max(0, (image.height - crop_height) // 2)
    cropped = image.crop((0, top, image.width, top + crop_height))
    runtime = cropped.resize((1152, 512), Image.Resampling.LANCZOS)
    ENV_OUT.mkdir(parents=True, exist_ok=True)
    output = ENV_OUT / f"{BACKGROUND_ID}.png"
    runtime.save(output)
    write_source_record(
        ENV_OUT / f"{BACKGROUND_ID}.source.json",
        "stage28_waystation_background_ai01",
        source,
        output,
        ["camera_bounds_1152x512", "display_layer_only"],
    )
    print(f"built {BACKGROUND_ID}: {output} ({sha256(output)})")


def build_grid_asset(
    source_asset_id: str,
    runtime_id: str,
    output_dir: Path,
    cell_size: tuple[int, int],
    safe_size: tuple[int, int],
    kind: str,
) -> Path:
    source = SOURCE_ROOT / source_asset_id / "candidates" / f"{source_asset_id}_candidate_01.png"
    alpha_source = SOURCE_ROOT / source_asset_id / "prepared" / f"{source_asset_id}_alpha.png"
    image = Image.open(alpha_source).convert("RGBA")
    atlas = Image.new("RGBA", (cell_size[0] * 4, cell_size[1] * 4), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []
    for index in range(16):
        raw = crop_grid_cell(image, 4, 4, index)
        frame, record = normalize_frame(raw, cell_size, safe_size, "center", None)
        target = ((index % 4) * cell_size[0], (index // 4) * cell_size[1])
        atlas.alpha_composite(frame, target)
        frames.append({"index": index, "region": [*target, *cell_size], **record})

    output_dir.mkdir(parents=True, exist_ok=True)
    output = output_dir / f"{runtime_id}.png"
    atlas.save(output)
    write_json(
        output_dir / f"{runtime_id}.frames.json",
        {
            "id": runtime_id,
            "kind": kind,
            "output": relative(output),
            "cell": list(cell_size),
            "columns": 4,
            "rows": 4,
            "frame_count": 16,
            "frames": frames,
        },
    )
    write_source_record(
        output_dir / f"{runtime_id}.source.json",
        source_asset_id,
        source,
        output,
        ["transparent_png", "fixed_4x4_grid", "small_scale_readability"],
    )
    print(f"built {runtime_id}: {output} ({sha256(output)})")
    return output


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
            "process": "built_in_image_gen_stage28_fixed_grid_chroma_to_alpha",
            "license_record_status": "source_recorded_terms_review_required",
            "commercial_use_status": "manual_terms_review_required_before_external_release",
            "constraints": constraints,
        },
    )


def write_world_spriteframes(texture: Path) -> None:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=18 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(texture)}" id="1"]',
        "",
    ]
    for index in range(16):
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{index:02d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({(index % 4) * 256}, {(index // 4) * 256}, 256, 256)",
                "",
            ]
        )
    animations: list[str] = []
    for name, indexes in WORLD_ANIMATIONS.items():
        frames = ", ".join(
            '{"duration": 1.0, "texture": SubResource("AtlasTexture_%02d")}' % index
            for index in indexes
        )
        animations.append(
            "{\n"
            f'"frames": [{frames}],\n'
            f'"loop": {"true" if name == "clerk_idle" else "false"},\n'
            f'"name": &"{name}",\n'
            f'"speed": {5.0 if name == "clerk_idle" else 1.0:.1f}\n'
            "}"
        )
    lines.extend(["[resource]", f'animations = [{", ".join(animations)}]'])
    (ENV_OUT / f"{WORLD_ID}.spriteframes.tres").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    build_background()
    world_texture = build_grid_asset(
        "stage28_waystation_world_sheet_ai01",
        WORLD_ID,
        ENV_OUT,
        (256, 256),
        (236, 236),
        "sprite_sheet",
    )
    write_world_spriteframes(world_texture)
    build_grid_asset(
        "stage28_waystation_ui_sheet_ai01",
        UI_ID,
        UI_OUT,
        (160, 160),
        (144, 144),
        "ui_icon_sheet",
    )


if __name__ == "__main__":
    main()
