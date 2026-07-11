"""Normalize the DAC image_gen terrain sheet into a Godot-friendly 64px grid."""

from __future__ import annotations

import json
from pathlib import Path
from PIL import Image


SOURCE = Path("assets/art/tilesets/dac_formal_terrain_tileset_ai01.png")
OUT = Path("assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.png")
REGIONS = Path("assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.regions.json")
SEMANTICS = Path("assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.semantics.json")

COLUMNS = 8
ROWS = 6
CELL = 64
PADDED_MAX = 58


def _fit_tile(tile: Image.Image) -> Image.Image:
    bbox = tile.getbbox()
    out = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if bbox is None:
        return out

    cropped = tile.crop(bbox)
    scale = min(PADDED_MAX / cropped.width, PADDED_MAX / cropped.height, 1.0)
    size = (max(1, round(cropped.width * scale)), max(1, round(cropped.height * scale)))
    resized = cropped.resize(size, Image.Resampling.LANCZOS)
    out.alpha_composite(resized, ((CELL - size[0]) // 2, (CELL - size[1]) // 2))
    return out


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    atlas = Image.new("RGBA", (COLUMNS * CELL, ROWS * CELL), (0, 0, 0, 0))
    frames = []

    for row in range(ROWS):
        for col in range(COLUMNS):
            left = round(col * source.width / COLUMNS)
            top = round(row * source.height / ROWS)
            right = round((col + 1) * source.width / COLUMNS)
            bottom = round((row + 1) * source.height / ROWS)
            normalized = _fit_tile(source.crop((left, top, right, bottom)))
            atlas.alpha_composite(normalized, (col * CELL, row * CELL))
            frames.append({
                "index": row * COLUMNS + col,
                "name": f"dac_formal_terrain_tile_{row + 1:02d}_{col + 1:02d}",
                "region": [col * CELL, row * CELL, CELL, CELL],
            })

    OUT.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUT)
    REGIONS.write_text(json.dumps({
        "id": "dac_formal_terrain_tileset_ai01_64",
        "kind": "tileset_sheet",
        "source": str(SOURCE).replace("\\", "/"),
        "output": str(OUT).replace("\\", "/"),
        "cell": [CELL, CELL],
        "columns": COLUMNS,
        "rows": ROWS,
        "frames": frames,
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    SEMANTICS.write_text(json.dumps({
        "version": 1,
        "asset_id": "dac_formal_terrain_tileset_ai01_64",
        "kind": "tileset_sheet",
        "source_asset": "dac_formal_terrain_tileset_ai01",
        "output": str(OUT).replace("\\", "/"),
        "entry_count": len(frames),
        "boundary": "image_gen source normalized to 64x64 transparent Godot tiles; collision remains authored by room StaticBody2D.",
        "entries": frames,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    pixels = (atlas.getpixel((x, y)) for y in range(atlas.height) for x in range(atlas.width))
    opaque = [px for px in pixels if px[3] > 200]
    magenta = sum(1 for r, g, b, a in opaque if r > 230 and b > 230 and g < 80)
    green = sum(1 for r, g, b, a in opaque if g > 230 and r < 80 and b < 80)
    white = sum(1 for r, g, b, a in opaque if r > 245 and g > 245 and b > 245)
    corners = [atlas.getpixel((0, 0))[3], atlas.getpixel((atlas.width - 1, 0))[3], atlas.getpixel((0, atlas.height - 1))[3], atlas.getpixel((atlas.width - 1, atlas.height - 1))[3]]
    print(f"normalized={OUT} size={atlas.size} opaque={len(opaque)} magenta={magenta} green={green} white={white} corners_alpha={corners}")
    if magenta or green or any(corners):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
