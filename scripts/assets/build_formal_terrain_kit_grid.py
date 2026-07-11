#!/usr/bin/env python3
"""将正式 terrain kit 透明源图重排为固定网格 sprite sheet。

本脚本只处理已经去背景的 PNG 源图，不负责生成美术。输出目标是给
Godot TileSet / 后续切片工具使用的稳定 4x3 网格，避免直接使用 AI
生成图时出现非整数格宽、残点或半截资产。
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


# 资产生产约定：每张小图 4x3，最终每格 384px，给台阶 / 门框等大件留足空间。
COLUMNS = 4
ROWS = 3
CELL_SIZE = 384
ALPHA_THRESHOLD = 8

SOURCE_DIR = Path("assets/art/tilesets/formal_terrain_kit")
OUTPUT_DIR = SOURCE_DIR / "grid"


@dataclass(frozen=True)
class Component:
    """表示透明源图中一个连通的可见资产主体。"""

    area: int
    bbox: tuple[int, int, int, int]

    @property
    def center(self) -> tuple[float, float]:
        min_x, min_y, max_x, max_y = self.bbox
        return ((min_x + max_x) / 2.0, (min_y + max_y) / 2.0)


def _find_components(image: Image.Image) -> list[Component]:
    """按 alpha 连通域提取主体，用于已经清理过的小型 terrain 源图。"""

    alpha = image.getchannel("A")
    width, height = alpha.size
    pixels = alpha.load()
    seen = bytearray(width * height)
    components: list[Component] = []

    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if seen[idx] or pixels[x, y] <= ALPHA_THRESHOLD:
                continue

            seen[idx] = 1
            stack = [(x, y)]
            area = 0
            min_x = max_x = x
            min_y = max_y = y

            while stack:
                current_x, current_y = stack.pop()
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
                    next_idx = next_y * width + next_x
                    if seen[next_idx] or pixels[next_x, next_y] <= ALPHA_THRESHOLD:
                        continue
                    seen[next_idx] = 1
                    stack.append((next_x, next_y))

            components.append(Component(area=area, bbox=(min_x, min_y, max_x, max_y)))

    return components


def _sort_components_as_grid(components: list[Component]) -> list[Component]:
    """把 12 个主体按视觉行列排序，保留生成图中的阅读顺序。"""

    if len(components) != COLUMNS * ROWS:
        raise RuntimeError(f"expected {COLUMNS * ROWS} components, got {len(components)}")

    by_y = sorted(components, key=lambda component: component.center[1])
    rows = [by_y[index : index + COLUMNS] for index in range(0, len(by_y), COLUMNS)]
    return [component for row in rows for component in sorted(row, key=lambda c: c.center[0])]


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    """返回局部图的 alpha 可见包围盒。"""

    alpha = image.getchannel("A")
    width, height = alpha.size
    pixels = alpha.load()
    min_x = width
    min_y = height
    max_x = -1
    max_y = -1

    for y in range(height):
        for x in range(width):
            if pixels[x, y] <= ALPHA_THRESHOLD:
                continue
            min_x = min(min_x, x)
            max_x = max(max_x, x)
            min_y = min(min_y, y)
            max_y = max(max_y, y)

    if max_x < min_x or max_y < min_y:
        return None
    return (min_x, min_y, max_x, max_y)


def _paste_centered(
    target: Image.Image,
    item: Image.Image,
    cell_index: int,
) -> dict[str, object]:
    """将单个资产居中贴入固定格子，并返回布局信息。"""

    row = cell_index // COLUMNS
    column = cell_index % COLUMNS
    cell_x = column * CELL_SIZE
    cell_y = row * CELL_SIZE

    bbox = _visible_bbox(item)
    if bbox is None:
        raise RuntimeError(f"empty cell at index {cell_index}")

    min_x, min_y, max_x, max_y = bbox
    cropped = item.crop((min_x, min_y, max_x + 1, max_y + 1))
    crop_width, crop_height = cropped.size
    if crop_width >= CELL_SIZE or crop_height >= CELL_SIZE:
        raise RuntimeError(
            f"cell {cell_index} item too large for {CELL_SIZE}px grid: {cropped.size}"
        )

    paste_x = cell_x + (CELL_SIZE - crop_width) // 2
    paste_y = cell_y + (CELL_SIZE - crop_height) // 2
    target.alpha_composite(cropped, (paste_x, paste_y))

    return {
        "index": cell_index,
        "row": row,
        "column": column,
        "cell_rect": [cell_x, cell_y, CELL_SIZE, CELL_SIZE],
        "visible_rect": [paste_x, paste_y, crop_width, crop_height],
        "source_visible_rect": [min_x, min_y, crop_width, crop_height],
    }


def _build_from_components(source_path: Path, output_name: str) -> dict[str, object]:
    """处理每个资产已经是单一连通主体的源图。"""

    source = Image.open(source_path).convert("RGBA")
    components = _sort_components_as_grid(_find_components(source))
    target = Image.new("RGBA", (COLUMNS * CELL_SIZE, ROWS * CELL_SIZE), (0, 0, 0, 0))
    cells: list[dict[str, object]] = []

    for index, component in enumerate(components):
        min_x, min_y, max_x, max_y = component.bbox
        item = source.crop((min_x, min_y, max_x + 1, max_y + 1))
        info = _paste_centered(target, item, index)
        info["source_component_area"] = component.area
        info["source_component_bbox"] = [min_x, min_y, max_x - min_x + 1, max_y - min_y + 1]
        cells.append(info)

    out_path = OUTPUT_DIR / output_name
    target.save(out_path)
    return _write_layout(source_path, out_path, "components", cells)


def _build_from_existing_cells(source_path: Path, output_name: str) -> dict[str, object]:
    """处理装饰图：每格可能包含碎石 / 雾气等多个小组件，需按原格子分组。"""

    source = Image.open(source_path).convert("RGBA")
    source_width, source_height = source.size
    if source_width % COLUMNS != 0 or source_height % ROWS != 0:
        raise RuntimeError(f"{source_path} is not divisible by {COLUMNS}x{ROWS}: {source.size}")

    source_cell_width = source_width // COLUMNS
    source_cell_height = source_height // ROWS
    target = Image.new("RGBA", (COLUMNS * CELL_SIZE, ROWS * CELL_SIZE), (0, 0, 0, 0))
    cells: list[dict[str, object]] = []

    for index in range(COLUMNS * ROWS):
        row = index // COLUMNS
        column = index % COLUMNS
        item = source.crop(
            (
                column * source_cell_width,
                row * source_cell_height,
                (column + 1) * source_cell_width,
                (row + 1) * source_cell_height,
            )
        )
        info = _paste_centered(target, item, index)
        info["source_cell_rect"] = [
            column * source_cell_width,
            row * source_cell_height,
            source_cell_width,
            source_cell_height,
        ]
        cells.append(info)

    out_path = OUTPUT_DIR / output_name
    target.save(out_path)
    return _write_layout(source_path, out_path, "source_cells", cells)


def _write_layout(
    source_path: Path,
    output_path: Path,
    extraction_mode: str,
    cells: list[dict[str, object]],
) -> dict[str, object]:
    """写入切片 sidecar，后续 Godot TileSet 构建脚本可以直接读取。"""

    layout = {
        "source": str(source_path).replace("\\", "/"),
        "output": str(output_path).replace("\\", "/"),
        "columns": COLUMNS,
        "rows": ROWS,
        "cell_size": [CELL_SIZE, CELL_SIZE],
        "canvas_size": [COLUMNS * CELL_SIZE, ROWS * CELL_SIZE],
        "extraction_mode": extraction_mode,
        "cells": cells,
    }
    output_path.with_suffix(".layout.json").write_text(
        json.dumps(layout, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return layout


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    jobs = [
        (
            _build_from_components,
            SOURCE_DIR / "formal_terrain_flat_edges_ai01.png",
            "formal_terrain_flat_edges_ai01_grid.png",
        ),
        (
            _build_from_components,
            SOURCE_DIR / "formal_terrain_stairs_cliffs_ai01.png",
            "formal_terrain_stairs_cliffs_ai01_grid.png",
        ),
        (
            _build_from_components,
            SOURCE_DIR / "formal_terrain_door_transitions_ai01.png",
            "formal_terrain_door_transitions_ai01_grid.png",
        ),
        (
            _build_from_existing_cells,
            SOURCE_DIR / "formal_terrain_decor_props_ai01.png",
            "formal_terrain_decor_props_ai01_grid.png",
        ),
    ]

    for builder, source_path, output_name in jobs:
        layout = builder(source_path, output_name)
        print(f"wrote {layout['output']} ({layout['columns']}x{layout['rows']})")


if __name__ == "__main__":
    main()
