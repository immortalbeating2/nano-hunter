#!/usr/bin/env python3
"""把 image gen 原始候选整理为 atlas 构建器可读取的 selected 源图。"""

from __future__ import annotations

import argparse
import json
import math
import shutil
from collections import deque
from pathlib import Path
from typing import Any

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prepare selected_frames / selected_items from recovered image_gen candidates.",
    )
    parser.add_argument(
        "--manifest",
        default="docs/assets/asset-atlas-build-manifest.json",
        help="Path to the atlas build manifest.",
    )
    parser.add_argument(
        "--only",
        help="Prepare only one output id.",
    )
    parser.add_argument(
        "--target",
        choices=("min", "target"),
        default="min",
        help="How many selected source images to prepare for each output.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Clear existing auto-selected images before writing.",
    )
    parser.add_argument(
        "--candidate-index",
        type=int,
        help="Use only a specific candidate index for extraction.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned extraction without writing files.",
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


def candidate_dir_from_source_dir(source_dir: Path) -> Path:
    return source_dir.parent / "candidates"


def candidate_index_from_path(path: Path) -> int | None:
    stem = path.stem
    marker = "_candidate_"
    if marker not in stem:
        return None
    suffix = stem.rsplit(marker, 1)[-1]
    if not suffix.isdigit():
        return None
    return int(suffix)


def find_candidates(source_dir: Path, asset_id: str, candidate_index: int | None = None) -> list[tuple[int, Path]]:
    candidates = candidate_dir_from_source_dir(source_dir)
    if candidate_index is not None:
        candidate = candidates / f"{asset_id}_candidate_{candidate_index:02d}.png"
        return [(candidate_index, candidate)] if candidate.exists() else []
    preferred = candidates / f"{asset_id}_candidate_01.png"
    matches = sorted(candidates.glob("*_candidate_*.png"))
    if preferred.exists():
        ordered = [preferred, *[path for path in matches if path != preferred]]
    else:
        ordered = matches
    indexed: list[tuple[int, Path]] = []
    for path in ordered:
        index = candidate_index_from_path(path)
        if index is not None:
            indexed.append((index, path))
    return indexed


def is_chroma_green(pixel: tuple[int, int, int, int] | tuple[int, int, int]) -> bool:
    red, green, blue = pixel[:3]
    return green > 140 and green > red * 1.35 and green > blue * 1.35


def has_chroma_corners(image: Image.Image) -> bool:
    rgb = image.convert("RGB")
    width, height = rgb.size
    corners = [
        rgb.getpixel((0, 0)),
        rgb.getpixel((width - 1, 0)),
        rgb.getpixel((0, height - 1)),
        rgb.getpixel((width - 1, height - 1)),
    ]
    return sum(1 for pixel in corners if is_chroma_green(pixel)) >= 2


def remove_chroma_to_alpha(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if is_chroma_green((red, green, blue, alpha)):
                pixels[x, y] = (red, green, blue, 0)
            else:
                # 简单去绿溢色，后续正式清稿仍应人工检查边缘。
                if green > red and green > blue:
                    green = int(max(red, blue, green * 0.45))
                pixels[x, y] = (red, green, blue, alpha)
    return rgba


def min_component_area(item: dict[str, Any]) -> int:
    cell_width, cell_height = item["cell"]
    kind = item.get("kind", "")
    if kind == "sprite_sheet":
        return max(3200, int(cell_width * cell_height * 0.10))
    if kind in {"tileset_sheet", "ninepatch_sheet"}:
        return max(1200, int(cell_width * cell_height * 0.08))
    return max(900, int(cell_width * cell_height * 0.05))


def connected_component_boxes(image: Image.Image, item: dict[str, Any]) -> list[tuple[int, int, int, int, int]]:
    rgb = image.convert("RGB")
    width, height = rgb.size
    pixels = rgb.load()
    visited = bytearray(width * height)
    boxes: list[tuple[int, int, int, int, int]] = []
    min_area = min_component_area(item)

    for y in range(height):
        for x in range(width):
            index = y * width + x
            if visited[index]:
                continue
            visited[index] = 1
            if is_chroma_green(pixels[x, y]):
                continue

            queue: deque[tuple[int, int]] = deque([(x, y)])
            min_x = max_x = x
            min_y = max_y = y
            area = 0
            while queue:
                current_x, current_y = queue.pop()
                area += 1
                min_x = min(min_x, current_x)
                max_x = max(max_x, current_x)
                min_y = min(min_y, current_y)
                max_y = max(max_y, current_y)
                for next_x, next_y in (
                    (current_x + 1, current_y),
                    (current_x - 1, current_y),
                    (current_x, current_y + 1),
                    (current_x, current_y - 1),
                ):
                    if not (0 <= next_x < width and 0 <= next_y < height):
                        continue
                    next_index = next_y * width + next_x
                    if visited[next_index]:
                        continue
                    visited[next_index] = 1
                    if not is_chroma_green(pixels[next_x, next_y]):
                        queue.append((next_x, next_y))

            if area >= min_area:
                boxes.append((min_x, min_y, max_x + 1, max_y + 1, area))

    return sorted(boxes, key=lambda box: (box[1], box[0]))


def grid_columns_for_count(image: Image.Image, count: int, preferred: int | None = None) -> int:
    if preferred and preferred > 0:
        rows = math.ceil(count / preferred)
        if rows > 0 and preferred / rows <= max(8.0, image.width / max(1, image.height) * 4):
            return preferred

    aspect = image.width / max(1, image.height)
    columns = max(1, round(math.sqrt(count * aspect)))
    return min(count, columns)


def grid_boxes(image: Image.Image, count: int, columns: int | None = None) -> list[tuple[int, int, int, int, int]]:
    columns = grid_columns_for_count(image, count, columns)
    rows = math.ceil(count / columns)
    cell_width = image.width / columns
    cell_height = image.height / rows
    boxes = []
    for index in range(count):
        column = index % columns
        row = index // columns
        left = int(round(column * cell_width))
        top = int(round(row * cell_height))
        right = int(round((column + 1) * cell_width))
        bottom = int(round((row + 1) * cell_height))
        boxes.append((left, top, right, bottom, (right - left) * (bottom - top)))
    return boxes


def padded_crop(image: Image.Image, box: tuple[int, int, int, int, int], padding: int = 8) -> Image.Image:
    left, top, right, bottom, _area = box
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(image.width, right + padding)
    bottom = min(image.height, bottom + padding)
    return image.crop((left, top, right, bottom))


def clear_auto_outputs(source_dir: Path) -> None:
    if not source_dir.exists():
        return
    for pattern in ("*_auto_*.png", "*_duplicate_*.png"):
        for path in source_dir.glob(pattern):
            path.unlink()


def write_selected_images(
    item: dict[str, Any],
    source_dir: Path,
    candidate_paths: list[tuple[int, Path]],
    count: int,
    dry_run: bool,
) -> tuple[int, str]:
    selected: list[tuple[Image.Image, tuple[int, int, int, int, int], str]] = []
    extraction_modes: list[str] = []
    fallback_grid_used = False

    for candidate_index, candidate_path in candidate_paths:
        if len(selected) >= count:
            break
        with Image.open(candidate_path) as opened:
            original = opened.convert("RGBA")

        use_components = has_chroma_corners(original) and item.get("kind") != "tileset_sheet"
        if use_components:
            boxes = connected_component_boxes(original, item)
            extraction = "chroma-components"
            if not boxes and not selected:
                boxes = grid_boxes(original, count, item.get("columns"))
                extraction = "fallback-grid"
                fallback_grid_used = True
        else:
            boxes = grid_boxes(original, count, item.get("columns"))
            extraction = "grid"
            fallback_grid_used = True

        prepared = remove_chroma_to_alpha(original) if has_chroma_corners(original) else original
        remaining = count - len(selected)
        for box in boxes[:remaining]:
            selected.append((prepared, box, f"c{candidate_index:02d}"))
        extraction_modes.append(extraction)

        # 网格图通常一张候选就覆盖完整目标；继续叠加其它候选会混入不同网格语义。
        if fallback_grid_used:
            break

    duplicate_start = len(selected)
    if len(selected) < count and selected:
        # 所有原始候选都不足时才补 duplicate，并在文件名标记。
        base = list(selected)
        while len(selected) < count:
            source_image, box, source_label = base[len(selected) % len(base)]
            selected.append((source_image, box, source_label))

    if dry_run:
        extraction = "+".join(dict.fromkeys(extraction_modes))
        if len(selected) > duplicate_start:
            extraction = f"{extraction}-with-duplicates"
        return len(selected), extraction

    source_dir.mkdir(parents=True, exist_ok=True)
    for index, (prepared, box, source_label) in enumerate(selected, 1):
        crop = padded_crop(prepared, box)
        suffix = "duplicate" if index > duplicate_start else "auto"
        output_path = source_dir / f"{item['id']}_{suffix}_{index:03d}_{source_label}.png"
        crop.save(output_path)

    extraction = "+".join(dict.fromkeys(extraction_modes))
    if len(selected) > duplicate_start:
        extraction = f"{extraction}-with-duplicates"
    return len(selected), extraction


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest = load_manifest(resolve_path(repo_root, args.manifest))
    root = resolve_path(repo_root, manifest.get("root", ".")).resolve()
    outputs = manifest["outputs"]
    if args.only:
        outputs = [item for item in outputs if item["id"] == args.only]
        if not outputs:
            print(f"No output id matched: {args.only}")
            return 2

    failures = 0
    for item in outputs:
        source_dir = resolve_path(root, item["source_dir"])
        candidate_paths = find_candidates(source_dir, item["id"], args.candidate_index)
        if not candidate_paths:
            print(f"{item['id']}: missing candidate in {candidate_dir_from_source_dir(source_dir)}")
            failures += 1
            continue

        count_key = "expected_target" if args.target == "target" else "expected_min"
        count = int(item.get(count_key, item.get("expected_min", 1)))
        if args.overwrite and not args.dry_run:
            clear_auto_outputs(source_dir)

        written_count, extraction = write_selected_images(
            item=item,
            source_dir=source_dir,
            candidate_paths=candidate_paths,
            count=count,
            dry_run=args.dry_run,
        )
        action = "would prepare" if args.dry_run else "prepared"
        candidate_list = ", ".join(path.name for _candidate_index, path in candidate_paths)
        print(
            f"{item['id']}: {action} {written_count}/{count} via {extraction} from "
            f"{candidate_list}"
        )

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
