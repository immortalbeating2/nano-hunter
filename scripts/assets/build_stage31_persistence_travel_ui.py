#!/usr/bin/env python3
"""从既有正式菜单与驿站图标确定性构建 Stage31 存档 / 传送 UI 图集。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path.cwd()
OUTPUT_DIR = Path("assets/art/ui")
OUTPUT_ID = "stage31_persistence_travel_ui_runtime_ai01"
CELL_SIZE = 160
SAFE_SIZE = 136

SOURCES = {
    "menu": Path("assets/art/ui/stage16_demo_menu_icons_ai01.png"),
    "waystation": Path(
        "assets/art/environment/waystation/stage28_waystation_world_runtime_ai01.png"
    ),
}

# 索引顺序是 DemoShell 的稳定运行契约；每格只复用一个已接入来源，不重绘语义。
CELLS: list[tuple[str, str, int, int, int]] = [
    ("continue_load", "menu", 3, 2, 1),
    ("new_game", "menu", 3, 2, 2),
    ("save_success", "menu", 3, 2, 3),
    ("save_error", "menu", 3, 2, 5),
    ("waystation_main", "waystation", 4, 4, 12),
    ("thunder_outpost", "waystation", 4, 4, 13),
    ("travel_available", "waystation", 4, 4, 11),
    ("travel_locked", "waystation", 4, 4, 10),
    ("checkpoint", "waystation", 4, 4, 14),
    ("backup", "waystation", 4, 4, 15),
    ("return", "menu", 3, 2, 4),
    ("paused_save", "menu", 3, 2, 0),
    ("current_waystation", "waystation", 4, 4, 12),
    ("current_outpost", "waystation", 4, 4, 13),
    ("save_pending", "waystation", 4, 4, 9),
    ("valid_save", "menu", 3, 2, 3),
]


def relative(path: Path) -> str:
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def crop_cell(image: Image.Image, columns: int, rows: int, index: int) -> Image.Image:
    cell_width = image.width // columns
    cell_height = image.height // rows
    left = (index % columns) * cell_width
    top = (index // columns) * cell_height
    return image.crop((left, top, left + cell_width, top + cell_height))


def normalize_icon(source: Image.Image) -> tuple[Image.Image, list[int]]:
    bounds = source.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("source icon has no visible pixels")
    icon = source.crop(bounds)
    icon.thumbnail((SAFE_SIZE, SAFE_SIZE), Image.Resampling.LANCZOS)
    frame = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    paste = ((CELL_SIZE - icon.width) // 2, (CELL_SIZE - icon.height) // 2)
    frame.alpha_composite(icon, paste)
    return frame, [*bounds]


def main() -> None:
    loaded = {name: Image.open(path).convert("RGBA") for name, path in SOURCES.items()}
    atlas = Image.new("RGBA", (CELL_SIZE * 4, CELL_SIZE * 4), (0, 0, 0, 0))
    frames: list[dict[str, Any]] = []
    for output_index, (name, source_name, columns, rows, source_index) in enumerate(CELLS):
        raw = crop_cell(loaded[source_name], columns, rows, source_index)
        frame, source_bounds = normalize_icon(raw)
        target = ((output_index % 4) * CELL_SIZE, (output_index // 4) * CELL_SIZE)
        atlas.alpha_composite(frame, target)
        frames.append(
            {
                "index": output_index,
                "name": name,
                "region": [*target, CELL_SIZE, CELL_SIZE],
                "source": relative(SOURCES[source_name]),
                "source_index": source_index,
                "source_bounds": source_bounds,
            }
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / f"{OUTPUT_ID}.png"
    atlas.save(output)
    write_json(
        OUTPUT_DIR / f"{OUTPUT_ID}.frames.json",
        {
            "id": OUTPUT_ID,
            "kind": "ui_icon_sheet",
            "output": relative(output),
            "cell": [CELL_SIZE, CELL_SIZE],
            "columns": 4,
            "rows": 4,
            "frame_count": len(frames),
            "frames": frames,
        },
    )
    write_json(
        OUTPUT_DIR / f"{OUTPUT_ID}.source.json",
        {
            "asset_id": "NS31-PersistenceTravelUI",
            "runtime_asset_id": OUTPUT_ID,
            "project_key": "nano-hunter",
            "project_name": "Nano Hunter",
            "sources": [
                {"path": relative(path), "sha256": sha256(path)}
                for path in SOURCES.values()
            ],
            "output": relative(output),
            "output_sha256": sha256(output),
            "process": "deterministic_composite_from_existing_runtime_assets",
            "license_record_status": "inherits_recorded_source_boundaries",
            "commercial_use_status": "manual_release_review_required",
            "constraints": [
                "fixed_4x4_grid",
                "display_only",
                "no_gameplay_collision",
                "no_damage_source",
            ],
        },
    )
    print(f"built {OUTPUT_ID}: {output} ({sha256(output)})")


if __name__ == "__main__":
    main()
