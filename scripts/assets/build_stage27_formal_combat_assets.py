#!/usr/bin/env python3
"""从 Stage27 已确认 image_gen 网格候选构建正式运行态动作与 VFX。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image

from build_luna_unified_runtime_body_sheets import crop_grid_cell


ROOT = Path.cwd()
PLAYER_OUT = Path("assets/art/characters/player/sprite_sheets/runtime_replacement")
BOSS_OUT = Path("assets/art/characters/enemies/sprite_sheets/runtime_replacement")
VFX_OUT = Path("assets/art/vfx/atlases")

ASSETS: list[dict[str, Any]] = [
    {
        "id": "luna_formal_combat_body_runtime_sheet_ai01",
        "source_asset_id": "stage27_luna_formal_combat_body_ai01",
        "source": Path("assets/source/ai_generated/batch_27/stage27_luna_formal_combat_body_ai01/candidates/stage27_luna_formal_combat_body_ai01_candidate_01.png"),
        "alpha_source": Path("assets/source/ai_generated/batch_27/stage27_luna_formal_combat_body_ai01/prepared/stage27_luna_formal_combat_body_ai01_alpha.png"),
        "output_dir": PLAYER_OUT,
        "cell": (192, 192),
        "safe": (168, 160),
        "anchor": "foot",
        "foot_y": 178,
        "animations": {
            "ward_attack": [0, 1, 2, 3],
            "air_attack": [4, 5, 6, 7],
            "apex": [4],
            "wind_thunder_finisher": [8, 9, 10, 11],
            "thunder_wind_finisher": [12, 13, 14, 15],
            "element_switch": [8, 9, 8, 0],
            "stance_switch": [12, 13, 12, 0],
            "recover": [15, 12, 0],
        },
        "speed": 18.0,
    },
    {
        "id": "seal_guardian_formal_motion_runtime_sheet_ai01",
        "source_asset_id": "stage27_seal_guardian_formal_motion_ai01",
        "source": Path("assets/source/ai_generated/batch_27/stage27_seal_guardian_formal_motion_ai01/candidates/stage27_seal_guardian_formal_motion_ai01_candidate_01.png"),
        "alpha_source": Path("assets/source/ai_generated/batch_27/stage27_seal_guardian_formal_motion_ai01/prepared/stage27_seal_guardian_formal_motion_ai01_alpha.png"),
        "output_dir": BOSS_OUT,
        "cell": (256, 192),
        "safe": (232, 168),
        "anchor": "foot",
        "foot_y": 184,
        "animations": {
            "close_pressure": [0, 1],
            "ground_impact": [2, 3],
            "air_warning": [4, 5],
            "air_punish": [6, 7],
            "recovery": [7, 6, 5, 4],
            "guard_break": [8, 9],
            "phase_transition": [10, 11],
            "hit": [12],
            "defeat": [12, 13, 14, 15],
        },
        "speed": 10.0,
    },
    {
        "id": "stage27_core_combat_vfx_runtime_ai01",
        "source_asset_id": "stage27_core_combat_vfx_ai01",
        "source": Path("assets/source/ai_generated/batch_27/stage27_core_combat_vfx_ai01/candidates/stage27_core_combat_vfx_ai01_candidate_01.png"),
        "alpha_source": Path("assets/source/ai_generated/batch_27/stage27_core_combat_vfx_ai01/prepared/stage27_core_combat_vfx_ai01_alpha.png"),
        "output_dir": VFX_OUT,
        "cell": (256, 192),
        "safe": (248, 176),
        "anchor": "center",
        "animations": {
            "wind_attack": [0, 1, 2, 3],
            "thunder_attack": [4, 5, 6, 7],
            "wind_thunder_pierce": [8, 9, 10, 11],
            "thunder_wind_scatter": [12, 13, 14, 15],
        },
        "speed": 22.0,
    },
    {
        "id": "stage27_seal_guardian_vfx_runtime_ai01",
        "source_asset_id": "stage27_seal_guardian_vfx_ai01",
        "source": Path("assets/source/ai_generated/batch_27/stage27_seal_guardian_vfx_ai01/candidates/stage27_seal_guardian_vfx_ai01_candidate_01.png"),
        "alpha_source": Path("assets/source/ai_generated/batch_27/stage27_seal_guardian_vfx_ai01/prepared/stage27_seal_guardian_vfx_ai01_alpha.png"),
        "output_dir": VFX_OUT,
        "cell": (256, 192),
        "safe": (248, 176),
        "anchor": "center",
        "animations": {
            "warning": [0, 1, 2, 3],
            "impact": [4, 5, 6, 7],
            "guard_break": [8, 9, 10, 11],
            "phase_transition": [15, 14, 13, 12],
            "defeat": [12, 13, 14, 15],
        },
        "speed": 12.0,
    },
]


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


def normalize_frame(
    frame: Image.Image,
    cell_size: tuple[int, int],
    safe_size: tuple[int, int],
    anchor: str,
    foot_y: int | None,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = frame.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("empty frame after chroma-key removal")
    content = frame.crop(bbox)
    scale = min(safe_size[0] / content.width, safe_size[1] / content.height, 1.0)
    size = (max(1, round(content.width * scale)), max(1, round(content.height * scale)))
    resized = content.resize(size, Image.Resampling.LANCZOS)
    output = Image.new("RGBA", cell_size, (0, 0, 0, 0))
    x = round((cell_size[0] - size[0]) / 2)
    y = round((cell_size[1] - size[1]) / 2) if anchor == "center" else int(foot_y or cell_size[1]) - size[1]
    output.alpha_composite(resized, (x, y))
    return output, {
        "source_bbox": list(bbox),
        "normalized_size": list(size),
        "paste": [x, y],
        "scale": round(scale, 6),
    }


def write_spriteframes(path: Path, texture: Path, asset: dict[str, Any]) -> None:
    asset_id = str(asset["id"])
    cell_w, cell_h = asset["cell"]
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=18 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(texture)}" id="1"]',
        "",
    ]
    for index in range(16):
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{asset_id}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({(index % 4) * cell_w}, {(index // 4) * cell_h}, {cell_w}, {cell_h})",
                "",
            ]
        )

    animations = []
    for name, indexes in asset["animations"].items():
        frames = ", ".join(
            '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (asset_id, index)
            for index in indexes
        )
        animations.append(
            "{\n"
            f'"frames": [{frames}],\n'
            '"loop": false,\n'
            f'"name": &"{name}",\n'
            f'"speed": {float(asset["speed"]):.1f}\n'
            "}"
        )
    lines.extend(["[resource]", f'animations = [{", ".join(animations)}]'])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_asset(asset: dict[str, Any]) -> None:
    source: Path = asset["source"]
    if not source.is_file():
        raise FileNotFoundError(source)
    alpha_source: Path = asset["alpha_source"]
    if not alpha_source.is_file():
        raise FileNotFoundError(f"run imagegen remove_chroma_key.py first: {alpha_source}")
    source_image = Image.open(alpha_source).convert("RGBA")
    cell_size = tuple(asset["cell"])
    atlas = Image.new("RGBA", (cell_size[0] * 4, cell_size[1] * 4), (0, 0, 0, 0))
    frame_records = []
    for index in range(16):
        raw = crop_grid_cell(source_image, 4, 4, index)
        frame, record = normalize_frame(raw, cell_size, tuple(asset["safe"]), asset["anchor"], asset.get("foot_y"))
        target = ((index % 4) * cell_size[0], (index // 4) * cell_size[1])
        atlas.alpha_composite(frame, target)
        frame_records.append({"index": index, "region": [*target, *cell_size], **record})

    output_dir: Path = asset["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)
    stem = str(asset["id"])
    texture_path = output_dir / f"{stem}.png"
    frames_path = output_dir / f"{stem}.frames.json"
    spriteframes_path = output_dir / f"{stem}.spriteframes.tres"
    source_path = output_dir / f"{stem}.source.json"
    atlas.save(texture_path)
    write_spriteframes(spriteframes_path, texture_path, asset)
    frames_path.write_text(
        json.dumps(
            {
                "id": stem,
                "kind": "sprite_sheet" if "vfx" not in stem else "vfx_atlas",
                "output": relative(texture_path),
                "sprite_frames": relative(spriteframes_path),
                "cell": list(cell_size),
                "columns": 4,
                "rows": 4,
                "frame_count": 16,
                "animations": asset["animations"],
                "anchor": asset["anchor"],
                "frames": frame_records,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    source_path.write_text(
        json.dumps(
            {
                "asset_id": asset["source_asset_id"],
                "runtime_asset_id": stem,
                "project_key": "nano-hunter",
                "project_name": "Nano Hunter",
                "candidate_index": 1,
                "source": relative(source),
                "source_sha256": sha256(source),
                "process": "built_in_image_gen_fixed_grid_chroma_to_alpha_stage27",
                "license_record_status": "source_recorded_terms_review_required",
                "commercial_use_status": "manual_terms_review_required_before_external_release",
                "constraints": ["transparent_png", "fixed_4x4_grid", "stable_scale", "stable_anchor"],
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"built {stem}: {texture_path} ({sha256(texture_path)})")


def main() -> None:
    for asset in ASSETS:
        build_asset(asset)


if __name__ == "__main__":
    main()
