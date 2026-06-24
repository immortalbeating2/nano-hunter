#!/usr/bin/env python3
"""Build runtime-normalized animation candidate sheets from existing source sheets."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image


DEFAULT_ATLAS_MANIFEST = "docs/assets/asset-atlas-build-manifest.json"
DEFAULT_OUT_DIR = "assets/art/characters/player/sprite_sheets/runtime_replacement"
DEFAULT_CANDIDATE_MANIFEST = "docs/assets/animation-runtime-replacement-candidates.json"
DEFAULT_ONLY = ["luna_idle_sheet_ai01", "luna_run_sheet_ai01"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build normalized runtime animation candidates for formal replacement review.",
    )
    parser.add_argument("--atlas-manifest", default=DEFAULT_ATLAS_MANIFEST)
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR)
    parser.add_argument("--candidate-manifest", default=DEFAULT_CANDIDATE_MANIFEST)
    parser.add_argument("--only", nargs="*", default=DEFAULT_ONLY)
    parser.add_argument("--pass-id", default="ARP-01")
    parser.add_argument("--merge-existing", action="store_true")
    parser.add_argument("--horizontal-padding", type=int, default=16)
    parser.add_argument("--vertical-padding", type=int, default=8)
    parser.add_argument("--columns", type=int, default=8)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def res_path(path: Path, root: Path) -> str:
    return "res://" + rel(path, root)


def output_by_id(manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(item["id"]): item for item in manifest.get("outputs", [])}


def frame_hash(image: Image.Image) -> bytes:
    return image.tobytes()


def crop_frame(sheet: Image.Image, frame: dict[str, Any]) -> tuple[Image.Image, tuple[int, int, int, int] | None]:
    x, y, width, height = [int(value) for value in frame["region"]]
    crop = sheet.crop((x, y, x + width, y + height)).convert("RGBA")
    return crop, crop.getchannel("A").getbbox()


def normalize_frames(
    source_sheet: Image.Image,
    frames: list[dict[str, Any]],
    cell: list[int],
    horizontal_padding: int,
    vertical_padding: int,
) -> tuple[list[Image.Image], list[dict[str, Any]], dict[str, Any]]:
    cropped: list[dict[str, Any]] = []
    seen_hashes: set[bytes] = set()
    duplicates_removed: list[int] = []

    for frame in frames:
        crop, bbox = crop_frame(source_sheet, frame)
        if bbox is None:
            continue
        digest = frame_hash(crop)
        if digest in seen_hashes:
            duplicates_removed.append(int(frame["index"]))
            continue
        seen_hashes.add(digest)
        left, top, right, bottom = bbox
        cropped.append(
            {
                "source_frame": frame,
                "crop": crop.crop((left, top, right, bottom)),
                "bbox": [left, top, right, bottom],
                "content_size": [right - left, bottom - top],
            }
        )

    if not cropped:
        return [], [], {"duplicates_removed": duplicates_removed}

    max_width = max(int(item["content_size"][0]) for item in cropped)
    max_height = max(int(item["content_size"][1]) for item in cropped)
    safe_width = int(cell[0]) - (horizontal_padding * 2)
    safe_height = int(cell[1]) - (vertical_padding * 2)
    scale = min(1.0, safe_width / max(1, max_width), safe_height / max(1, max_height))
    foot_baseline_y = int(cell[1]) - vertical_padding
    center_x = int(cell[0]) // 2

    normalized_images: list[Image.Image] = []
    normalized_frame_sources: list[dict[str, Any]] = []
    for item in cropped:
        crop = item["crop"]
        new_size = (
            max(1, int(round(crop.width * scale))),
            max(1, int(round(crop.height * scale))),
        )
        resized = crop.resize(new_size, Image.Resampling.LANCZOS)
        cell_image = Image.new("RGBA", (int(cell[0]), int(cell[1])), (0, 0, 0, 0))
        paste_x = int(round(center_x - (resized.width / 2)))
        paste_y = int(round(foot_baseline_y - resized.height))
        cell_image.alpha_composite(resized, dest=(paste_x, paste_y))
        normalized_images.append(cell_image)
        normalized_frame_sources.append(item["source_frame"])

    summary = {
        "duplicates_removed": duplicates_removed,
        "scale": round(scale, 6),
        "source_max_content_size": [max_width, max_height],
        "target_safe_size": [safe_width, safe_height],
        "foot_baseline_y": foot_baseline_y,
        "center_x": center_x,
        "horizontal_padding": horizontal_padding,
        "vertical_padding": vertical_padding,
    }
    return normalized_images, normalized_frame_sources, summary


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
    frame_entries = []
    for index in range(frame_count):
        frame_entries.append(
            '{"duration": 1.0, "texture": SubResource("AtlasTexture_%s_%03d")}' % (asset_id, index)
        )
    animation_name = str(animation.get("name", asset_id))
    speed = float(animation.get("speed", 12.0))
    loop = "true" if bool(animation.get("loop", False)) else "false"
    lines.extend(
        [
            "[resource]",
            "animations = [{",
            f'"frames": [{", ".join(frame_entries)}],',
            f'"loop": {loop},',
            f'"name": &"{animation_name}",',
            f'"speed": {speed}',
            "}]",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_candidate(
    root: Path,
    source_item: dict[str, Any],
    out_dir: Path,
    columns: int,
    horizontal_padding: int,
    vertical_padding: int,
    pass_id: str,
    dry_run: bool,
) -> dict[str, Any]:
    source_asset_id = str(source_item["id"])
    candidate_id = source_asset_id.replace("_sheet_ai01", "_runtime_sheet_ai01")
    source_texture = resolve_path(root, str(source_item["output"]))
    source_metadata = resolve_path(root, str(source_item["metadata"]))
    source_sheet = Image.open(source_texture).convert("RGBA")
    metadata = load_json(source_metadata)
    cell = [int(value) for value in source_item["cell"]]
    frames = metadata.get("frames", [])
    normalized_images, normalized_sources, summary = normalize_frames(
        source_sheet,
        frames,
        cell,
        horizontal_padding,
        vertical_padding,
    )
    rows = max(1, math.ceil(len(normalized_images) / columns))
    sheet = Image.new("RGBA", (columns * int(cell[0]), rows * int(cell[1])), (0, 0, 0, 0))
    out_dir.mkdir(parents=True, exist_ok=True)
    output_path = out_dir / f"{candidate_id}.png"
    metadata_path = out_dir / f"{candidate_id}.frames.json"
    spriteframes_path = out_dir / f"{candidate_id}.spriteframes.tres"
    source_record_path = out_dir / f"{candidate_id}.source.json"
    candidate_frames: list[dict[str, Any]] = []
    for index, image in enumerate(normalized_images):
        x = (index % columns) * int(cell[0])
        y = (index // columns) * int(cell[1])
        sheet.alpha_composite(image, dest=(x, y))
        source_frame = normalized_sources[index]
        candidate_frames.append(
            {
                "index": index,
                "name": f"{candidate_id}_runtime_{index + 1:03d}",
                "source": str(source_frame.get("source", source_item["output"])),
                "source_frame_index": int(source_frame["index"]),
                "region": [x, y, int(cell[0]), int(cell[1])],
            }
        )

    candidate_metadata = {
        "id": candidate_id,
        "source_asset_id": source_asset_id,
        "kind": "sprite_sheet",
        "output": str(output_path),
        "cell": cell,
        "columns": columns,
        "rows": rows,
        "frames": candidate_frames,
        "normalization": summary,
    }
    source_record = {
        "asset_id": candidate_id,
        "source_asset_id": source_asset_id,
        "source_texture": rel(source_texture, root),
        "source_metadata": rel(source_metadata, root),
        "process": "runtime_normalized_from_existing_final_ready_source",
        "boundary": (
            "Candidate for Animation Runtime Replacement Pass geometry review. "
            "Not approved for live controller replacement until strict audit, scene tests and runtime review pass."
        ),
        "normalization": summary,
    }
    if not dry_run:
        sheet.save(output_path)
        metadata_path.write_text(json.dumps(candidate_metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        source_record_path.write_text(json.dumps(source_record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_spriteframes(
            root,
            spriteframes_path,
            output_path,
            candidate_id,
            source_item.get("animation", {}),
            len(candidate_frames),
            cell,
            columns,
        )

    return {
        "id": candidate_id,
        "source_asset_id": source_asset_id,
        "kind": "sprite_sheet",
        "batch": pass_id,
        "output": rel(output_path, root),
        "metadata": rel(metadata_path, root),
        "sprite_frames": rel(spriteframes_path, root),
        "cell": cell,
        "columns": columns,
        "animation": source_item.get("animation", {}),
        "frame_count": len(candidate_frames),
        "normalization": summary,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    manifest = load_json(resolve_path(root, args.atlas_manifest))
    by_id = output_by_id(manifest)
    out_dir = resolve_path(root, args.out_dir)
    outputs: list[dict[str, Any]] = []
    for asset_id in args.only:
        if asset_id not in by_id:
            raise SystemExit(f"Unknown asset id: {asset_id}")
        outputs.append(
            build_candidate(
                root,
                by_id[asset_id],
                out_dir,
                int(args.columns),
                int(args.horizontal_padding),
                int(args.vertical_padding),
                str(args.pass_id),
                bool(args.dry_run),
            )
        )

    existing_outputs: list[dict[str, Any]] = []
    candidate_manifest_path = resolve_path(root, args.candidate_manifest)
    if args.merge_existing and candidate_manifest_path.exists():
        existing_manifest = load_json(candidate_manifest_path)
        existing_outputs = list(existing_manifest.get("outputs", []))

    merged_by_id: dict[str, dict[str, Any]] = {}
    for item in existing_outputs + outputs:
        merged_by_id[str(item["id"])] = item
    merged_outputs = list(merged_by_id.values())
    candidate_manifest = {
        "version": 1,
        "status": "runtime_candidate",
        "pass": "mixed" if args.merge_existing and existing_outputs else str(args.pass_id),
        "asset_count": len(merged_outputs),
        "outputs": merged_outputs,
        "boundary": (
            "Runtime-normalized geometry candidates. These are not live controller replacements "
            "until strict audit, scene tests and runtime review pass."
        ),
    }
    if not args.dry_run:
        candidate_manifest_path.write_text(
            json.dumps(candidate_manifest, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
    print(
        f"Animation runtime candidates {'planned' if args.dry_run else 'built'}: "
        f"{len(outputs)} assets, {sum(int(item['frame_count']) for item in outputs)} frames."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
