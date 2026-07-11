#!/usr/bin/env python3
"""Audit generated atlas / tileset cell boundaries and runtime usage."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "docs/assets/asset-atlas-build-manifest.json"
REPORT_JSON = ROOT / "docs/assets/tileset-cut-integrity-audit-2026-07-06.json"
REPORT_MD = ROOT / "docs/assets/tileset-cut-integrity-audit-2026-07-06.md"

EXTRA_OUTPUTS = [
    {
        "id": "dac_formal_terrain_tileset_ai01_64",
        "kind": "tileset_sheet",
        "batch": "DAC-06",
        "output": "assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.png",
        "metadata": "assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.regions.json",
        "cell": [64, 64],
        "columns": 8,
    }
]

PRODUCTION_SCAN_ROOTS = [
    "scenes/rooms",
    "scenes/player",
    "scenes/combat",
    "scenes/ui",
    "scripts/combat",
    "scripts/configs",
    "scripts/main",
    "scripts/player",
    "scripts/rooms",
    "scripts/ui",
]

TEXT_SUFFIXES = {".gd", ".tscn", ".tres", ".json", ".md", ".cfg", ".godot"}


def _load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _frames(metadata: dict[str, Any]) -> list[dict[str, Any]]:
    return list(metadata.get("frames") or metadata.get("entries") or [])


def _alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = image.convert("RGBA").getchannel("A")
    return alpha.getbbox()


def _edge_touches(image: Image.Image) -> dict[str, bool]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    alpha = rgba.getchannel("A")

    def any_alpha(points: list[tuple[int, int]]) -> bool:
        return any(alpha.getpixel(point) > 8 for point in points)

    return {
        "left": any_alpha([(0, y) for y in range(height)]),
        "right": any_alpha([(width - 1, y) for y in range(height)]),
        "top": any_alpha([(x, 0) for x in range(width)]),
        "bottom": any_alpha([(x, height - 1) for x in range(width)]),
    }


def _scan_text_refs(needles: list[str]) -> dict[str, int]:
    counts = {needle: 0 for needle in needles}
    for root_name in PRODUCTION_SCAN_ROOTS:
        root = ROOT / root_name
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
            for needle in needles:
                if needle in text:
                    counts[needle] += 1
    return counts


def _room_asset_node_visibility(asset_id: str) -> dict[str, Any]:
    import re

    total = 0
    visible = 0
    hidden = 0
    for path in (ROOT / "scenes/rooms").glob("*.tscn"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        blocks = re.split(r"(?=\n\[node )", text)
        for block in blocks:
            if f'metadata/asset_id = "{asset_id}"' not in block:
                continue
            total += 1
            if "visible = false" in block:
                hidden += 1
            else:
                visible += 1
    return {"room_nodes": total, "visible_room_nodes": visible, "hidden_room_nodes": hidden}


def _audit_output(config: dict[str, Any]) -> dict[str, Any]:
    asset_id = str(config["id"])
    output = ROOT / str(config["output"])
    metadata_path = ROOT / str(config.get("metadata", ""))
    source_dir = ROOT / str(config.get("source_dir", ""))
    result: dict[str, Any] = {
        "asset_id": asset_id,
        "kind": config.get("kind", ""),
        "batch": config.get("batch", ""),
        "output": str(config.get("output", "")),
        "output_exists": output.exists(),
        "metadata": str(config.get("metadata", "")),
        "metadata_exists": metadata_path.exists(),
        "source_dir": str(config.get("source_dir", "")),
        "source_dir_exists": bool(config.get("source_dir")) and source_dir.exists(),
        "frame_count": 0,
        "empty_cells": 0,
        "edge_touch_cells": 0,
        "edge_touch_rate": 0.0,
        "edge_touch_breakdown": {"left": 0, "right": 0, "top": 0, "bottom": 0},
        "production_reference_files": 0,
        "notes": [],
    }
    if not output.exists() or not metadata_path.exists():
        result["notes"].append("missing_output_or_metadata")
        return result

    image = Image.open(output).convert("RGBA")
    metadata = _load_json(metadata_path)
    frames = _frames(metadata)
    result["image_size"] = list(image.size)
    result["frame_count"] = len(frames)

    for frame in frames:
        region = frame.get("region")
        if not region or len(region) != 4:
            continue
        x, y, w, h = [int(value) for value in region]
        crop = image.crop((x, y, x + w, y + h))
        bbox = _alpha_bbox(crop)
        if bbox is None:
            result["empty_cells"] += 1
            continue
        touches = _edge_touches(crop)
        if any(touches.values()):
            result["edge_touch_cells"] += 1
        for edge, touched in touches.items():
            if touched:
                result["edge_touch_breakdown"][edge] += 1

    if result["frame_count"]:
        result["edge_touch_rate"] = round(result["edge_touch_cells"] / result["frame_count"], 4)

    refs = _scan_text_refs([asset_id, str(config.get("output", "")), output.name])
    result["production_reference_files"] = max(refs.values()) if refs else 0
    result.update(_room_asset_node_visibility(asset_id))

    if asset_id in {"miasma_marsh_tileset_ai01", "shrine_trial_tileset_ai01"}:
        result["disposition"] = "keep_as_hidden_preview_or_source_only"
        result["regenerate"] = "not_now; regenerate only as a new biome-specific formal terrain kit"
    elif asset_id == "dac_formal_terrain_tileset_ai01_64":
        result["disposition"] = "active_limited_formal_ground_palette"
        result["regenerate"] = "partial; keep flat stone cells, regenerate missing stairs/cliffs/door transitions if needed"
    else:
        result["disposition"] = "catalog_or_candidate"
        result["regenerate"] = "only if this asset is promoted to active runtime use and fails manual review"

    return result


def _build_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# TileSet 切片完整性审计 - 2026-07-06",
        "",
        f"- 审计输出数：`{report['summary']['output_count']}`",
        f"- 当前正式运行道路资产：`{report['summary']['active_runtime_terrain_asset']}`",
        f"- 当前 worktree 中缺少 source_dir、无法做源图逐张对比的输出数：`{report['summary']['missing_source_dir_count']}`",
        "",
        "## 重点结论",
        "",
    ]
    for item in report["focus"]:
        lines.extend(
            [
                f"### {item['asset_id']}",
                "",
                f"- 类型 / 批次：`{item['kind']}` / `{item['batch']}`",
                f"- 切片数：`{item['frame_count']}`，贴边切片：`{item['edge_touch_cells']}` (`{item['edge_touch_rate']}`)",
                f"- 当前 source_dir 是否存在：`{item['source_dir_exists']}`",
                f"- 生产运行目录引用文件数：`{item['production_reference_files']}`",
                f"- 房间节点可见 / 隐藏：`{item['visible_room_nodes']}` / `{item['hidden_room_nodes']}`",
                f"- 当前处理结论：`{item['disposition']}`",
                f"- 是否需要重生：`{item['regenerate']}`",
                "",
            ]
        )
    lines.extend(
        [
            "## 判读说明",
            "",
            "- `edge_touch_cells` 表示不透明像素贴到 cell 边界。对地形连接块这可能是刻意的，但它也证明该格不适合当作独立 prop 或无脑连续平地使用。",
            "- `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 是 Batch07 第一版 editor/source TileSet，不应在没有手工 terrain 规则和边缘拟合的情况下承担正式道路主体。",
            "- 当前正式道路主体是 `dac_formal_terrain_tileset_ai01_64`。它可保留用于平地石板循环，但台阶、断崖、门口衔接仍应按新的正式 terrain kit 规则补齐或重生。",
            "- 许多已生成资产本来就是 catalog、preview、style board、storyboard、promo 或未来 rigging source；生成不等于必须立即上屏。",
        ]
    )
    unused = [item for item in report["outputs"] if item["production_reference_files"] == 0]
    lines.extend(["", "## 当前未被 production runtime 直接引用的生成输出", ""])
    if unused:
        lines.append("| Asset ID | Kind | Batch | 当前结论 |")
        lines.append("| --- | --- | --- | --- |")
        for item in unused:
            lines.append(
                f"| `{item['asset_id']}` | `{item['kind']}` | `{item['batch']}` | `{item['disposition']}` |"
            )
    else:
        lines.append("- 无。")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-report", action="store_true")
    args = parser.parse_args()

    manifest = _load_json(MANIFEST)
    outputs = list(manifest.get("outputs", [])) + EXTRA_OUTPUTS
    audited = [_audit_output(output) for output in outputs]
    focus_ids = {
        "miasma_marsh_tileset_ai01",
        "shrine_trial_tileset_ai01",
        "dac_formal_terrain_tileset_ai01_64",
    }
    focus = [item for item in audited if item["asset_id"] in focus_ids]
    report = {
        "version": 1,
        "status": "ok",
        "scope": "Generated atlas / tileset cell boundary and production-reference audit.",
        "summary": {
            "output_count": len(audited),
            "missing_source_dir_count": sum(1 for item in audited if item.get("source_dir") and not item["source_dir_exists"]),
            "active_runtime_terrain_asset": "dac_formal_terrain_tileset_ai01_64",
        },
        "focus": focus,
        "outputs": audited,
    }

    if args.write_report:
        REPORT_JSON.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
        REPORT_MD.write_text(_build_markdown(report), encoding="utf-8")

    print(json.dumps(report["summary"], ensure_ascii=False))
    for item in focus:
        print(
            f"{item['asset_id']}: frames={item['frame_count']} "
            f"edge_touch={item['edge_touch_cells']} refs={item['production_reference_files']} "
            f"source_dir={item['source_dir_exists']} disposition={item['disposition']}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
