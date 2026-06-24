#!/usr/bin/env python3
"""Build Nano Hunter sprite sheets and atlases from selected image-gen frames."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build sprite sheets / atlases from docs/assets/asset-atlas-build-manifest.json.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--only",
        help="Build only one output id.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate source availability and planned outputs without writing files.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail when an output has fewer than expected_min source images.",
    )
    return parser.parse_args()


def load_manifest(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def collect_sources(root: Path, item: dict[str, Any]) -> list[Path]:
    source_dir = resolve_path(root, item["source_dir"])
    if not source_dir.exists():
        return []
    return sorted(
        path for path in source_dir.glob(item.get("source_glob", "*.png"))
        if path.is_file()
    )


def fit_into_cell(image: Image.Image, cell_width: int, cell_height: int) -> Image.Image:
    source = image.convert("RGBA")
    ratio = min(cell_width / source.width, cell_height / source.height)
    new_size = (
        max(1, int(source.width * ratio)),
        max(1, int(source.height * ratio)),
    )
    resized = source.resize(new_size, Image.Resampling.LANCZOS)
    cell = Image.new("RGBA", (cell_width, cell_height), (0, 0, 0, 0))
    offset = ((cell_width - resized.width) // 2, (cell_height - resized.height) // 2)
    cell.alpha_composite(resized, offset)
    return cell


def build_sheet(root: Path, item: dict[str, Any], sources: list[Path]) -> dict[str, Any]:
    cell_width, cell_height = item["cell"]
    columns = int(item["columns"])
    rows = max(1, math.ceil(len(sources) / columns))
    sheet = Image.new("RGBA", (columns * cell_width, rows * cell_height), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []

    for index, source_path in enumerate(sources):
        with Image.open(source_path) as image:
            cell = fit_into_cell(image, cell_width, cell_height)
        column = index % columns
        row = index // columns
        x = column * cell_width
        y = row * cell_height
        sheet.alpha_composite(cell, (x, y))
        frames.append({
            "index": index,
            "name": source_path.stem,
            "source": source_path.as_posix(),
            "region": [x, y, cell_width, cell_height],
        })

    output_path = resolve_path(root, item["output"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path)

    metadata = {
        "id": item["id"],
        "kind": item["kind"],
        "output": output_path.as_posix(),
        "cell": [cell_width, cell_height],
        "columns": columns,
        "rows": rows,
        "frames": frames,
    }
    metadata_path = resolve_path(root, item["metadata"])
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if item.get("sprite_frames"):
        write_sprite_frames(root, item, metadata, output_path)

    return metadata


def write_sprite_frames(root: Path, item: dict[str, Any], metadata: dict[str, Any], output_path: Path) -> None:
    sprite_path = resolve_path(root, item["sprite_frames"])
    sprite_path.parent.mkdir(parents=True, exist_ok=True)
    res_path = "res://" + output_path.relative_to(root).as_posix()
    animation = item.get("animation", {})
    animation_name = animation.get("name", item["id"])
    speed = float(animation.get("speed", 12.0))
    loop = "true" if animation.get("loop", True) else "false"

    subresources: list[str] = []
    frame_entries: list[str] = []
    for frame in metadata["frames"]:
        index = frame["index"]
        x, y, width, height = frame["region"]
        sub_id = f"AtlasTexture_{item['id']}_{index:03d}"
        subresources.append(
            "\n".join([
                f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {width}, {height})",
                "",
            ])
        )
        frame_entries.append(
            '{"duration": 1.0, "texture": SubResource("%s")}' % sub_id
        )

    load_steps = len(metadata["frames"]) + 2
    body = [
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{res_path}" id="1"]',
        "",
        *subresources,
        "[resource]",
        "animations = [{",
        f'"frames": [{", ".join(frame_entries)}],',
        f'"loop": {loop},',
        f'"name": &"{animation_name}",',
        f'"speed": {speed}',
        "}]",
        "",
    ]
    sprite_path.write_text("\n".join(body), encoding="utf-8")


def validate_item(item: dict[str, Any], sources: list[Path]) -> tuple[str, bool]:
    expected_min = int(item.get("expected_min", 1))
    expected_target = int(item.get("expected_target", expected_min))
    count = len(sources)
    if count < expected_min:
        return (
            f"{item['id']}: missing sources {count}/{expected_min} minimum, target {expected_target}",
            False,
        )
    if count < expected_target:
        return (
            f"{item['id']}: partial sources {count}/{expected_target} target, minimum satisfied",
            True,
        )
    return (f"{item['id']}: ready with {count}/{expected_target} sources", True)


def main() -> int:
    args = parse_args()
    manifest_path = Path(args.manifest).resolve()
    repo_root = Path.cwd().resolve()
    manifest = load_manifest(manifest_path)
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()

    outputs = manifest["outputs"]
    if args.only:
        outputs = [item for item in outputs if item["id"] == args.only]
        if not outputs:
            print(f"No output id matched: {args.only}")
            return 2

    failed = False
    for item in outputs:
        sources = collect_sources(root, item)
        message, ok = validate_item(item, sources)
        print(message)
        if not ok:
            failed = True
            if args.strict:
                continue
        if args.dry_run or not ok:
            continue
        metadata = build_sheet(root, item, sources)
        print(f"  wrote {metadata['output']}")
        print(f"  wrote {resolve_path(root, item['metadata']).as_posix()}")
        if item.get("sprite_frames"):
            print(f"  wrote {resolve_path(root, item['sprite_frames']).as_posix()}")

    if failed and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
