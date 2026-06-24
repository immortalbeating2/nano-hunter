#!/usr/bin/env python3
"""把不走 atlas 构建的 image gen 候选导出为 assets/art 单体 PNG。"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path
from typing import Any

from PIL import Image


PROJECT_KEY = "nano-hunter"
PROJECT_NAME = "Nano Hunter"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export standalone image_gen candidates listed in image-gen-prompt-queue.json.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to image-gen-prompt-queue.json.",
    )
    parser.add_argument(
        "--only",
        help="Export only one asset_id.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing output PNGs.",
    )
    parser.add_argument(
        "--candidate-index",
        type=int,
        help="Use a specific candidate index instead of the first available candidate.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned exports without writing files.",
    )
    return parser.parse_args()


def load_queue(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def is_chroma_green(pixel: tuple[int, int, int, int] | tuple[int, int, int]) -> bool:
    red, green, blue = pixel[:3]
    return green > 140 and green > red * 1.35 and green > blue * 1.35


def is_chroma_magenta(pixel: tuple[int, int, int, int] | tuple[int, int, int]) -> bool:
    red, green, blue = pixel[:3]
    return red > 140 and blue > 140 and red > green * 1.35 and blue > green * 1.35


def chroma_key_name(pixel: tuple[int, int, int, int] | tuple[int, int, int]) -> str:
    if is_chroma_green(pixel):
        return "green"
    if is_chroma_magenta(pixel):
        return "magenta"
    return ""


def detect_chroma_key_from_corners(image: Image.Image) -> str:
    rgb = image.convert("RGB")
    width, height = rgb.size
    corners = [
        rgb.getpixel((0, 0)),
        rgb.getpixel((width - 1, 0)),
        rgb.getpixel((0, height - 1)),
        rgb.getpixel((width - 1, height - 1)),
    ]
    counts = {"green": 0, "magenta": 0}
    for pixel in corners:
        key_name = chroma_key_name(pixel)
        if key_name:
            counts[key_name] += 1
    for key_name, count in counts.items():
        if count >= 2:
            return key_name
    return ""


def remove_chroma_to_alpha(image: Image.Image, key_name: str) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            is_key = (
                is_chroma_green((red, green, blue, alpha))
                if key_name == "green"
                else is_chroma_magenta((red, green, blue, alpha))
            )
            if is_key:
                pixels[x, y] = (red, green, blue, 0)
            else:
                if key_name == "green" and green > red and green > blue:
                    green = int(max(red, blue, green * 0.45))
                elif key_name == "magenta" and red > green and blue > green:
                    red = int(max(green, min(red, red * 0.65)))
                    blue = int(max(green, min(blue, blue * 0.65)))
                pixels[x, y] = (red, green, blue, alpha)
    return rgba


def candidate_index_from_path(path: Path) -> int | None:
    stem = path.stem
    marker = "_candidate_"
    if marker not in stem:
        return None
    suffix = stem.rsplit(marker, 1)[-1]
    if not suffix.isdigit():
        return None
    return int(suffix)


def candidate_path(repo_root: Path, item: dict[str, Any], candidate_index: int | None) -> tuple[int, Path] | None:
    source_dir = repo_root / item["source_dir"]
    if candidate_index is not None:
        candidate = source_dir / f"{item['asset_id']}_candidate_{candidate_index:02d}.png"
        return (candidate_index, candidate) if candidate.exists() else None
    preferred = source_dir / f"{item['asset_id']}_candidate_01.png"
    if preferred.exists():
        return (1, preferred)
    matches = sorted(source_dir.glob("*_candidate_*.png"))
    if matches:
        index = candidate_index_from_path(matches[0])
        return (index or 1, matches[0])
    return None


def should_export(item: dict[str, Any]) -> bool:
    if item.get("atlas_output_id"):
        return False
    output = item.get("output_path", "")
    return output.startswith("assets/art/")


def export_item(repo_root: Path, item: dict[str, Any], overwrite: bool, dry_run: bool, candidate_index: int | None) -> str:
    selected = candidate_path(repo_root, item, candidate_index)
    if not selected:
        return "missing-candidate"
    selected_index, source = selected

    output = repo_root / item["output_path"]
    if output.exists() and not overwrite:
        return "exists"

    if dry_run:
        return "would-export"

    output.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as image:
        key_name = detect_chroma_key_from_corners(image)
        if key_name:
            result = remove_chroma_to_alpha(image, key_name)
            result.save(output)
        else:
            shutil.copy2(source, output)
    source_record_path = output.with_suffix(".source.json")
    source_record = {
        "version": 1,
        "project_key": PROJECT_KEY,
        "project_name": PROJECT_NAME,
        "asset_id": item["asset_id"],
        "candidate_index": selected_index,
        "candidate_path": source.relative_to(repo_root).as_posix(),
        "output_path": output.relative_to(repo_root).as_posix(),
        "boundary": (
            "Standalone output derivation record for source-safety audits. "
            "This proves which image_gen candidate was exported, not final art approval."
        ),
    }
    source_record_path.write_text(json.dumps(source_record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return "exported"


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    queue = load_queue(repo_root / args.queue)
    items = [item for item in queue["items"] if should_export(item)]
    if args.only:
        items = [item for item in items if item["asset_id"] == args.only]
        if not items:
            print(f"No standalone asset matched: {args.only}")
            return 2

    failures = 0
    for item in items:
        status = export_item(repo_root, item, args.overwrite, args.dry_run, args.candidate_index)
        if status == "missing-candidate":
            failures += 1
        print(f"{item['asset_id']}: {status} -> {item['output_path']}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
