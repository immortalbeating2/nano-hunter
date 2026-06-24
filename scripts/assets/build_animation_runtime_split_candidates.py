#!/usr/bin/env python3
"""Build semantic runtime animation clips from existing normalized candidates."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_MANIFEST = "docs/assets/animation-runtime-replacement-candidates.json"
DEFAULT_OUT_DIR = "assets/art/characters/player/sprite_sheets/runtime_replacement"
ENEMY_OUT_DIR = "assets/art/characters/enemies/sprite_sheets/runtime_replacement"
VFX_ATLAS_OUT_DIR = "assets/art/vfx/atlases"

CLIP_SPECS = [
    {
        "id": "luna_attack_body_runtime_sheet_ai01",
        "source_id": "luna_attack_01_runtime_sheet_ai01",
        "batch": "ARP-04",
        "animation": {"name": "attack_body", "speed": 18.0, "loop": False},
        "frame_indexes": [3, 4, 5, 6, 7, 11, 12, 13, 14, 15],
        "filter": "remove_cyan_vfx",
        "boundary": "Attack body candidate only. Slash / seal arc must remain in an independent VFX layer.",
    },
    {
        "id": "luna_hit_react_runtime_sheet_ai01",
        "source_id": "luna_hit_death_runtime_sheet_ai01",
        "batch": "ARP-04",
        "animation": {"name": "hit_react", "speed": 12.0, "loop": False},
        "frame_indexes": list(range(0, 11)),
        "filter": "none",
        "boundary": "Hit reaction candidate only. Does not include knockdown or death idle.",
    },
    {
        "id": "luna_death_idle_runtime_sheet_ai01",
        "source_id": "luna_hit_death_runtime_sheet_ai01",
        "batch": "ARP-04",
        "animation": {"name": "death_idle", "speed": 8.0, "loop": False},
        "frame_indexes": list(range(17, 24)),
        "filter": "none",
        "boundary": "Death idle candidate only. Knockdown transition still requires regeneration or a separate clip.",
    },
    {
        "id": "enemy_basic_melee_runtime_sheet_ai01",
        "source_id": "enemies_core_runtime_sheet_ai01",
        "batch": "ARP-05",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "basic_melee_cycle", "speed": 10.0, "loop": True},
        "frame_indexes": list(range(0, 8)),
        "filter": "none",
        "boundary": "Single basic melee enemy runtime candidate split from the enemy roster sheet.",
    },
    {
        "id": "enemy_ground_charger_runtime_sheet_ai01",
        "source_id": "enemies_core_runtime_sheet_ai01",
        "batch": "ARP-05",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "ground_charger_cycle", "speed": 10.0, "loop": True},
        "frame_indexes": list(range(8, 16)),
        "filter": "none",
        "boundary": "Single ground charger enemy runtime candidate split from the enemy roster sheet.",
    },
    {
        "id": "enemy_aerial_sentinel_runtime_sheet_ai01",
        "source_id": "enemies_core_runtime_sheet_ai01",
        "batch": "ARP-05",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "aerial_sentinel_cycle", "speed": 10.0, "loop": True},
        "frame_indexes": list(range(16, 24)),
        "filter": "none",
        "boundary": "Single aerial sentinel enemy runtime candidate split from the enemy roster sheet.",
    },
    {
        "id": "enemy_miasma_caster_runtime_sheet_ai01",
        "source_id": "enemies_core_runtime_sheet_ai01",
        "batch": "ARP-05",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "miasma_caster_cycle", "speed": 10.0, "loop": True},
        "frame_indexes": list(range(24, 32)),
        "filter": "none",
        "boundary": "Single miasma caster enemy runtime candidate split from the enemy roster sheet.",
    },
    {
        "id": "seal_guardian_idle_runtime_sheet_ai01",
        "source_id": "seal_guardian_boss_runtime_sheet_ai01",
        "batch": "ARP-06",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "idle", "speed": 8.0, "loop": True},
        "frame_indexes": list(range(0, 4)),
        "filter": "none",
        "boundary": "Seal Guardian idle candidate only. Does not include warning, attack or defeat frames.",
    },
    {
        "id": "seal_guardian_warning_runtime_sheet_ai01",
        "source_id": "seal_guardian_boss_runtime_sheet_ai01",
        "batch": "ARP-06",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "warning", "speed": 10.0, "loop": False},
        "frame_indexes": list(range(4, 8)),
        "filter": "none",
        "boundary": "Seal Guardian attack warning candidate only. Runtime boss binding must align this with warning telegraph timing.",
    },
    {
        "id": "seal_guardian_attack_runtime_sheet_ai01",
        "source_id": "seal_guardian_boss_runtime_sheet_ai01",
        "batch": "ARP-06",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "attack", "speed": 12.0, "loop": False},
        "frame_indexes": list(range(8, 16)),
        "filter": "none",
        "boundary": "Seal Guardian attack candidate only. Damage window and hitbox timing are not approved by this geometry split.",
    },
    {
        "id": "seal_guardian_defeat_runtime_sheet_ai01",
        "source_id": "seal_guardian_boss_runtime_sheet_ai01",
        "batch": "ARP-06",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "defeat", "speed": 8.0, "loop": False},
        "frame_indexes": list(range(16, 20)),
        "filter": "none",
        "boundary": "Seal Guardian defeat / seal-release candidate only. Does not replace Stage16 completion feedback by itself.",
    },
    {
        "id": "seal_guardian_attack_body_runtime_sheet_ai01",
        "source_id": "seal_guardian_attack_runtime_sheet_ai01",
        "batch": "ARP-07",
        "out_dir": ENEMY_OUT_DIR,
        "animation": {"name": "attack_body", "speed": 12.0, "loop": False},
        "frame_indexes": list(range(0, 8)),
        "filter": "remove_low_cyan_vfx",
        "boundary": "Seal Guardian attack body candidate with lower ground slash / impact VFX removed while preserving body seal glow. Hitbox timing is not approved by this split.",
    },
    {
        "id": "seal_guardian_attack_vfx_atlas_ai01",
        "source_id": "seal_guardian_attack_runtime_sheet_ai01",
        "batch": "ARP-07",
        "out_dir": VFX_ATLAS_OUT_DIR,
        "manifest_kind": "vfx_atlas",
        "include_in_manifest": False,
        "animation": {"name": "boss_attack_vfx", "speed": 12.0, "loop": False},
        "frame_indexes": list(range(0, 8)),
        "filter": "keep_low_cyan_vfx",
        "boundary": "Extracted Seal Guardian cyan ground slash / impact VFX candidate. This is a VFX atlas candidate, not a character runtime replacement candidate.",
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build semantic runtime split clips from normalized animation candidates.",
    )
    parser.add_argument("--candidate-manifest", default=DEFAULT_MANIFEST)
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR)
    parser.add_argument("--columns", type=int, default=8)
    parser.add_argument("--only", nargs="*", default=[], help="Optional clip spec ids to build.")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def res_path(path: Path, root: Path) -> str:
    return "res://" + rel(path, root)


def is_cyan_vfx_pixel(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    cyan_like = b >= 120 and g >= 95 and r <= 150 and (b - r) >= 35 and (g - r) >= 20
    bright_cyan = b >= 150 and g >= 135 and r <= 185 and (b - r) >= 20
    return cyan_like or bright_cyan


def remove_cyan_vfx(frame: Image.Image) -> Image.Image:
    image = frame.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if is_cyan_vfx_pixel(r, g, b, a):
                pixels[x, y] = (r, g, b, 0)
    return image


def keep_cyan_vfx(frame: Image.Image) -> Image.Image:
    image = frame.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if not is_cyan_vfx_pixel(r, g, b, a):
                pixels[x, y] = (r, g, b, 0)
    return image


def remove_low_cyan_vfx(frame: Image.Image) -> Image.Image:
    image = frame.convert("RGBA")
    pixels = image.load()
    low_y = int(image.height * 0.58)
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if y >= low_y and is_cyan_vfx_pixel(r, g, b, a):
                pixels[x, y] = (r, g, b, 0)
    return image


def keep_low_cyan_vfx(frame: Image.Image) -> Image.Image:
    image = frame.convert("RGBA")
    pixels = image.load()
    low_y = int(image.height * 0.58)
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if y < low_y or not is_cyan_vfx_pixel(r, g, b, a):
                pixels[x, y] = (r, g, b, 0)
    return image


def write_spriteframes(
    root: Path,
    path: Path,
    texture_path: Path,
    asset_id: str,
    animation: dict[str, Any],
    frame_count: int,
    cell: list[int],
    columns: int,
) -> None:
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{res_path(texture_path, root)}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        x = (index % columns) * int(cell[0])
        y = (index // columns) * int(cell[1])
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{asset_id}_{index:03d}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {int(cell[0])}, {int(cell[1])})",
                "",
            ]
        )
    frame_entries = [
        '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (asset_id, index)
        for index in range(frame_count)
    ]
    lines.extend(
        [
            "[resource]",
            "animations = [{",
            f'"frames": [{", ".join(frame_entries)}],',
            f'"loop": {"true" if bool(animation.get("loop", False)) else "false"},',
            f'"name": &"{animation.get("name", asset_id)}",',
            f'"speed": {float(animation.get("speed", 12.0))}',
            "}]",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def frame_from_sheet(sheet: Image.Image, frame: dict[str, Any]) -> Image.Image:
    x, y, width, height = [int(value) for value in frame["region"]]
    return sheet.crop((x, y, x + width, y + height)).convert("RGBA")


def build_clip(root: Path, source_item: dict[str, Any], spec: dict[str, Any], out_dir: Path, columns: int, dry_run: bool) -> dict[str, Any]:
    source_image = Image.open(resolve_path(root, str(source_item["output"]))).convert("RGBA")
    source_metadata = load_json(resolve_path(root, str(source_item["metadata"])))
    source_frames = {int(frame["index"]): frame for frame in source_metadata.get("frames", [])}
    cell = [int(value) for value in source_item["cell"]]
    asset_id = str(spec["id"])
    selected_indexes = [int(index) for index in spec["frame_indexes"]]
    rows = max(1, math.ceil(len(selected_indexes) / columns))
    sheet = Image.new("RGBA", (columns * int(cell[0]), rows * int(cell[1])), (0, 0, 0, 0))
    out_dir.mkdir(parents=True, exist_ok=True)
    output_path = out_dir / f"{asset_id}.png"
    metadata_path = out_dir / f"{asset_id}.frames.json"
    spriteframes_path = out_dir / f"{asset_id}.spriteframes.tres"
    source_record_path = out_dir / f"{asset_id}.source.json"
    frames: list[dict[str, Any]] = []

    for output_index, source_index in enumerate(selected_indexes):
        if source_index not in source_frames:
            raise SystemExit(f"Missing source frame {source_index} for {asset_id}")
        image = frame_from_sheet(source_image, source_frames[source_index])
        if spec.get("filter") == "remove_cyan_vfx":
            image = remove_cyan_vfx(image)
        elif spec.get("filter") == "keep_cyan_vfx":
            image = keep_cyan_vfx(image)
        elif spec.get("filter") == "remove_low_cyan_vfx":
            image = remove_low_cyan_vfx(image)
        elif spec.get("filter") == "keep_low_cyan_vfx":
            image = keep_low_cyan_vfx(image)
        x = (output_index % columns) * int(cell[0])
        y = (output_index // columns) * int(cell[1])
        sheet.alpha_composite(image, dest=(x, y))
        frames.append(
            {
                "index": output_index,
                "name": f"{asset_id}_runtime_{output_index + 1:03d}",
                "source": str(source_item["output"]),
                "source_frame_index": source_index,
                "region": [x, y, int(cell[0]), int(cell[1])],
            }
        )

    metadata = {
        "id": asset_id,
        "source_asset_id": str(source_item["id"]),
        "kind": str(spec.get("manifest_kind", "sprite_sheet")),
        "output": rel(output_path, root),
        "cell": cell,
        "columns": columns,
        "rows": rows,
        "frames": frames,
        "split": {
            "source_runtime_candidate": str(source_item["id"]),
            "source_frame_indexes": selected_indexes,
            "filter": str(spec.get("filter", "none")),
            "boundary": str(spec["boundary"]),
        },
    }
    source_record = {
        "asset_id": asset_id,
        "source_asset_id": str(source_item["id"]),
        "source_texture": str(source_item["output"]),
        "source_metadata": str(source_item["metadata"]),
        "process": "semantic_runtime_clip_split_from_normalized_candidate",
        "boundary": str(spec["boundary"]),
        "source_frame_indexes": selected_indexes,
        "filter": str(spec.get("filter", "none")),
    }
    if not dry_run:
        sheet.save(output_path)
        metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        source_record_path.write_text(json.dumps(source_record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_spriteframes(root, spriteframes_path, output_path, asset_id, spec["animation"], len(frames), cell, columns)

    return {
        "id": asset_id,
        "source_asset_id": str(source_item["id"]),
        "kind": str(spec.get("manifest_kind", "sprite_sheet")),
        "batch": str(spec["batch"]),
        "output": rel(output_path, root),
        "metadata": rel(metadata_path, root),
        "sprite_frames": rel(spriteframes_path, root),
        "cell": cell,
        "columns": columns,
        "animation": spec["animation"],
        "frame_count": len(frames),
        "split": metadata["split"],
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    manifest_path = resolve_path(root, args.candidate_manifest)
    manifest = load_json(manifest_path)
    by_id = {str(item["id"]): item for item in manifest.get("outputs", [])}
    outputs = list(manifest.get("outputs", []))
    generated: list[dict[str, Any]] = []
    selected_ids = {str(value) for value in args.only}

    for spec in CLIP_SPECS:
        if selected_ids and str(spec["id"]) not in selected_ids:
            continue
        source_id = str(spec["source_id"])
        if source_id not in by_id:
            raise SystemExit(f"Missing source candidate: {source_id}")
        out_dir = resolve_path(root, str(spec.get("out_dir", args.out_dir)))
        generated.append(build_clip(root, by_id[source_id], spec, out_dir, int(args.columns), bool(args.dry_run)))

    merged = {str(item["id"]): item for item in outputs}
    for spec, item in zip([spec for spec in CLIP_SPECS if (not selected_ids or str(spec["id"]) in selected_ids)], generated):
        if spec.get("include_in_manifest", True) is False:
            continue
        merged[str(item["id"])] = item
    if not args.dry_run:
        manifest["outputs"] = list(merged.values())
        manifest["asset_count"] = len(manifest["outputs"])
        manifest["pass"] = "mixed"
        manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(
        f"Animation split candidates {'planned' if args.dry_run else 'built'}: "
        f"{len(generated)} assets, {sum(int(item['frame_count']) for item in generated)} frames."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
