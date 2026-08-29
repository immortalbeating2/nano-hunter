#!/usr/bin/env python3
"""从 Stage30 已目检候选构建雷泽敌人、首领与吸收 VFX 运行资产。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image

from build_luna_unified_runtime_body_sheets import crop_grid_cell
from build_stage27_formal_combat_assets import normalize_frame
from character_creature_model_lock_contract import maybe_attach_model_lock


ROOT = Path.cwd()
SOURCE_ROOT = Path("assets/source/ai_generated/batch_30")
ENEMY_OUT = Path("assets/art/characters/enemies/sprite_sheets/runtime_replacement")
VFX_OUT = Path("assets/art/vfx/atlases")

ASSETS: list[dict[str, Any]] = [
    {
        "id": "stage30_thunder_fang_locomotion_runtime_ai01",
        "source_id": "stage30_thunder_fang_locomotion_ai01",
        "candidate": 2,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (224, 192),
        "safe": (208, 176),
        "anchor": "foot",
        "foot_y": 184,
        "animations": {
            "idle": [0, 1, 2, 3],
            "patrol": [4, 5, 6, 7],
            "move": [8, 9, 10, 11],
            "charged_idle": [12, 13, 14, 15],
        },
        "loops": {"idle", "patrol", "move", "charged_idle"},
        "speed": 8.0,
    },
    {
        "id": "stage30_thunder_fang_attack_runtime_ai01",
        "source_id": "stage30_thunder_fang_attack_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (224, 192),
        "safe": (208, 176),
        "anchor": "foot",
        "foot_y": 184,
        "animations": {
            "warning": [0, 1, 2, 3],
            "startup": [4, 5, 6, 7],
            "attack": [8, 9, 10, 11],
            "recovery": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 12.0,
    },
    {
        "id": "stage30_thunder_fang_reaction_runtime_ai01",
        "source_id": "stage30_thunder_fang_reaction_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (224, 192),
        "safe": (208, 176),
        "anchor": "foot",
        "foot_y": 184,
        "animations": {
            "hit": [0, 1, 2, 3],
            "guard_break": [4, 5, 6, 7],
            "stagger": [8, 9, 10, 11],
            "defeat": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 12.0,
    },
    {
        "id": "stage30_thunder_fang_vfx_runtime_ai01",
        "source_id": "stage30_thunder_fang_vfx_ai01",
        "candidate": 1,
        "out": VFX_OUT,
        "kind": "vfx_atlas",
        "cell": (256, 256),
        "safe": (244, 244),
        "anchor": "center",
        "animations": {
            "warning": [0, 1, 2, 3],
            "attack": [4, 5, 6, 7],
            "guard_break": [8, 9, 10, 11],
            "stagger": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 12.0,
    },
    {
        "id": "stage30_kui_boss_phase1_presence_runtime_ai01",
        "source_id": "stage30_kui_boss_phase1_presence_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (288, 256),
        "safe": (272, 238),
        "anchor": "foot",
        "foot_y": 246,
        "animations": {
            "phase1_idle": [0, 1, 2, 3],
            "close_warning": [4, 5, 6, 7],
            "lightning_warning": [8, 9, 10, 11],
            "phase1_recovery": [12, 13, 14, 15],
        },
        "loops": {"phase1_idle"},
        "speed": 8.0,
    },
    {
        "id": "stage30_kui_boss_phase1_attacks_runtime_ai01",
        "source_id": "stage30_kui_boss_phase1_attacks_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (288, 256),
        "safe": (272, 238),
        "anchor": "foot",
        "foot_y": 246,
        "animations": {
            "close_startup": [0, 1, 2, 3],
            "close_attack": [4, 5, 6, 7],
            "lightning_startup": [8, 9, 10, 11],
            "lightning_attack": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 12.0,
    },
    {
        "id": "stage30_kui_boss_transition_reaction_runtime_ai01",
        "source_id": "stage30_kui_boss_transition_reaction_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (288, 256),
        "safe": (272, 238),
        "anchor": "foot",
        "foot_y": 246,
        "animations": {
            "hit": [0, 1, 2, 3],
            "stagger": [4, 5, 6, 7],
            "guard_break": [8, 9, 10, 11],
            "phase_transition": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 10.0,
    },
    {
        "id": "stage30_kui_boss_phase2_presence_runtime_ai01",
        "source_id": "stage30_kui_boss_phase2_presence_ai01",
        "candidate": 2,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (288, 256),
        "safe": (272, 238),
        "anchor": "foot",
        "foot_y": 246,
        "animations": {
            "phase2_idle": [0, 1, 2, 3],
            "close_warning": [4, 5, 6, 7],
            "lightning_warning": [8, 9, 10, 11],
            "phase2_recovery": [12, 13, 14, 15],
        },
        "loops": {"phase2_idle"},
        "speed": 10.0,
    },
    {
        "id": "stage30_kui_boss_phase2_resolution_runtime_ai01",
        "source_id": "stage30_kui_boss_phase2_resolution_ai01",
        "candidate": 1,
        "out": ENEMY_OUT,
        "kind": "sprite_sheet",
        "cell": (288, 256),
        "safe": (272, 238),
        "anchor": "foot",
        "foot_y": 246,
        "animations": {
            "phase2_close_attack": [0, 1, 2, 3],
            "phase2_lightning_attack": [4, 5, 6, 7],
            "phase2_recovery": [8, 9, 10, 11],
            "defeat": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 10.0,
    },
    {
        "id": "stage30_kui_boss_combat_vfx_runtime_ai01",
        "source_id": "stage30_kui_boss_combat_vfx_ai01",
        "candidate": 1,
        "out": VFX_OUT,
        "kind": "vfx_atlas",
        "cell": (256, 256),
        "safe": (244, 244),
        "anchor": "center",
        "animations": {
            "close_warning": [0, 1, 2, 3],
            "close_impact": [4, 5, 6, 7],
            "lightning_warning": [8, 9, 10, 11],
            "lightning_impact": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 12.0,
    },
    {
        "id": "stage30_kui_boss_state_vfx_runtime_ai01",
        "source_id": "stage30_kui_boss_state_vfx_ai01",
        "candidate": 1,
        "out": VFX_OUT,
        "kind": "vfx_atlas",
        "cell": (256, 256),
        "safe": (244, 244),
        "anchor": "center",
        "animations": {
            "guard_break": [0, 1, 2, 3],
            "stagger": [4, 5, 6, 7],
            "phase_transition": [8, 9, 10, 11],
            "defeat": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 10.0,
    },
    {
        "id": "stage30_thunder_absorption_reward_vfx_runtime_ai01",
        "source_id": "stage30_thunder_absorption_reward_vfx_ai01",
        "candidate": 1,
        "out": VFX_OUT,
        "kind": "vfx_atlas",
        "cell": (256, 256),
        "safe": (244, 244),
        "anchor": "center",
        "animations": {
            "absorption_unlock": [0, 1, 2, 3],
            "thunder_beast_core": [4, 5, 6, 7],
            "demon_resonance": [8, 9, 10, 11],
            "shortcut_curtain": [12, 13, 14, 15],
        },
        "loops": set(),
        "speed": 8.0,
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


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def source_candidate(asset: dict[str, Any]) -> Path:
    source_id = str(asset["source_id"])
    return SOURCE_ROOT / source_id / "candidates" / f"{source_id}_candidate_{int(asset['candidate']):02d}.png"


def alpha_candidate(asset: dict[str, Any]) -> Path:
    source_id = str(asset["source_id"])
    return SOURCE_ROOT / source_id / "prepared" / f"{source_id}_alpha.png"


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
                f'[sub_resource type="AtlasTexture" id="Stage30_{asset_id}_{index:02d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({(index % 4) * cell_w}, {(index // 4) * cell_h}, {cell_w}, {cell_h})",
                "",
            ]
        )

    animations: list[str] = []
    for name, indexes in asset["animations"].items():
        frames = ", ".join(
            '{"duration": 1.0, "texture": SubResource("Stage30_%s_%02d")}' % (asset_id, index)
            for index in indexes
        )
        animations.append(
            "{\n"
            f'"frames": [{frames}],\n'
            f'"loop": {"true" if name in asset["loops"] else "false"},\n'
            f'"name": &"{name}",\n'
            f'"speed": {float(asset["speed"]):.1f}\n'
            "}"
        )
    lines.extend(["[resource]", f'animations = [{", ".join(animations)}]'])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_asset(asset: dict[str, Any]) -> None:
    source = source_candidate(asset)
    alpha = alpha_candidate(asset)
    if not source.is_file() or not alpha.is_file():
        raise FileNotFoundError(source if not source.is_file() else alpha)

    image = Image.open(alpha).convert("RGBA")
    cell_size = tuple(asset["cell"])
    atlas = Image.new("RGBA", (cell_size[0] * 4, cell_size[1] * 4), (0, 0, 0, 0))
    records: list[dict[str, Any]] = []
    for index in range(16):
        raw = crop_grid_cell(image, 4, 4, index)
        inset = 2
        raw = raw.crop((inset, inset, raw.width - inset, raw.height - inset))
        frame, record = normalize_frame(
            raw,
            cell_size,
            tuple(asset["safe"]),
            str(asset["anchor"]),
            asset.get("foot_y"),
        )
        target = ((index % 4) * cell_size[0], (index // 4) * cell_size[1])
        atlas.alpha_composite(frame, target)
        records.append({"index": index, "region": [*target, *cell_size], **record})

    output_dir: Path = asset["out"]
    output_dir.mkdir(parents=True, exist_ok=True)
    asset_id = str(asset["id"])
    texture = output_dir / f"{asset_id}.png"
    frames = output_dir / f"{asset_id}.frames.json"
    sprite_frames = output_dir / f"{asset_id}.spriteframes.tres"
    source_record = output_dir / f"{asset_id}.source.json"
    atlas.save(texture)
    write_spriteframes(sprite_frames, texture, asset)
    frames_payload = {
        "id": asset_id,
        "kind": asset["kind"],
        "output": relative(texture),
        "sprite_frames": relative(sprite_frames),
        "cell": list(cell_size),
        "columns": 4,
        "rows": 4,
        "frame_count": 16,
        "animations": asset["animations"],
        "anchor": asset["anchor"],
        "frames": records,
    }
    maybe_attach_model_lock(frames_payload, ROOT.resolve(), asset_id)
    write_json(frames, frames_payload)
    source_payload = {
        "asset_id": asset["source_id"],
        "runtime_asset_id": asset_id,
        "project_key": "nano-hunter",
        "project_name": "Nano Hunter",
        "candidate_index": int(asset["candidate"]),
        "source": relative(source),
        "source_sha256": sha256(source),
        "output": relative(texture),
        "output_sha256": sha256(texture),
        "process": "independent_image_api_edit_fixed_grid_chroma_to_alpha_stage30",
        "license_record_status": "source_recorded_terms_review_required",
        "commercial_use_status": "manual_terms_review_required_before_external_release",
        "constraints": [
            "transparent_png",
            "fixed_4x4_grid",
            "stable_scale",
            "stable_anchor",
            "visual_only_vfx" if asset["kind"] == "vfx_atlas" else "gameplay_timing_code_authority",
        ],
    }
    maybe_attach_model_lock(source_payload, ROOT.resolve(), asset_id)
    write_json(source_record, source_payload)
    print(f"built {asset_id}: {texture} ({sha256(texture)})")


def main() -> None:
    for asset in ASSETS:
        build_asset(asset)


if __name__ == "__main__":
    main()
