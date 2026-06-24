#!/usr/bin/env python3
"""从 image gen prompt queue 导出可执行批次生成单。"""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export a Markdown production packet from docs/assets/image-gen-prompt-queue.json.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Prompt queue JSON path.",
    )
    parser.add_argument(
        "--batch",
        help="Batch filter, for example 01 or Batch 01.",
    )
    parser.add_argument(
        "--asset-id",
        action="append",
        help="Export one asset id. Can be passed multiple times.",
    )
    parser.add_argument(
        "--out",
        help="Output Markdown path. Defaults to docs/implementation-plans/<date>-imagegen-<batch>-production-packet.md.",
    )
    parser.add_argument(
        "--date",
        default=date.today().isoformat(),
        help="Document date.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def normalize_batch(batch: str) -> str:
    value = batch.strip()
    if value.lower().startswith("batch "):
        number = int(value.split()[-1])
    else:
        number = int(value)
    return f"Batch {number:02d}"


def batch_slug(batch: str) -> str:
    return batch.lower().replace(" ", "-")


def select_items(queue: dict[str, Any], batch: str | None, asset_ids: list[str] | None) -> list[dict[str, Any]]:
    items = queue.get("items", [])
    selected: list[dict[str, Any]] = []
    normalized_batch = normalize_batch(batch) if batch else None
    wanted_assets = set(asset_ids or [])

    for item in items:
        if normalized_batch and item.get("batch") != normalized_batch:
            continue
        if wanted_assets and item.get("asset_id") not in wanted_assets:
            continue
        selected.append(item)
    return selected


def default_output_path(document_date: str, batch: str | None, asset_ids: list[str] | None) -> Path:
    if batch:
        stem = f"{document_date}-imagegen-{batch_slug(normalize_batch(batch))}-production-packet.md"
    elif asset_ids and len(asset_ids) == 1:
        stem = f"{document_date}-imagegen-{asset_ids[0]}-production-packet.md"
    else:
        stem = f"{document_date}-imagegen-selected-production-packet.md"
    return Path("docs") / "implementation-plans" / stem


def slot_for_item(item: dict[str, Any]) -> str:
    source_dir = str(item.get("source_dir", ""))
    if source_dir.endswith("/selected_frames"):
        return "selected_frames"
    if source_dir.endswith("/selected_items") or source_dir.endswith("/selected_tiles") or source_dir.endswith("/selected_parts") or source_dir.endswith("/selected_panels"):
        return "selected_items"
    return "candidates"


def render_item(item: dict[str, Any]) -> list[str]:
    asset_id = item["asset_id"]
    batch = item["batch"]
    normalized_batch_arg = batch.split()[-1]
    candidate_count = item["candidate_count"]
    slot = slot_for_item(item)

    lines = [
        f"### {asset_id}",
        "",
        f"- Batch: `{batch}`",
        f"- Priority: `{item['priority']}`",
        f"- Target kind: `{item['target_kind']}`",
        f"- Candidate count: `{candidate_count}`",
        f"- Source directory: `{item['source_dir']}`",
        f"- Output path: `{item['output_path']}`",
    ]
    if item.get("atlas_output_id"):
        lines.append(f"- Atlas output id: `{item['atlas_output_id']}`")
    lines.extend([
        "",
        "Prompt to paste into built-in image_gen:",
        "",
        "```text",
        item["prompt"],
        "```",
        "",
        "After each generated image is saved or detected, import as a raw candidate:",
        "",
        "```powershell",
        f"python scripts/assets/import_imagegen_outputs.py --copy-latest --batch {normalized_batch_arg} --asset-id {asset_id}",
        "```",
        "",
        "If the preview was manually saved to a file, import by explicit path:",
        "",
        "```powershell",
        f"python scripts/assets/import_imagegen_outputs.py --source C:\\path\\to\\image.png --batch {normalized_batch_arg} --asset-id {asset_id}",
        "```",
    ])
    if item.get("atlas_output_id"):
        lines.extend([
            "",
            f"After review and cleanup, place selected PNGs in `{item['source_dir']}` and build the atlas output:",
            "",
            "```powershell",
            f"python scripts/assets/build_asset_atlases.py --only {item['atlas_output_id']}",
            "```",
        ])
    elif slot != "candidates":
        lines.extend([
            "",
            f"After review and cleanup, move selected PNGs into `{item['source_dir']}`.",
        ])
    lines.append("")
    return lines


def render_document(queue: dict[str, Any], items: list[dict[str, Any]], document_date: str) -> str:
    batches = sorted({item["batch"] for item in items})
    title_batch = ", ".join(batches) if batches else "Selected Assets"
    atlas_count = sum(1 for item in items if item.get("atlas_output_id"))

    lines = [
        f"# Image Gen Production Packet - {title_batch}",
        "",
        f"日期：{document_date}",
        "",
        "## Summary",
        "",
        "本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。",
        "",
        f"- 资产条目数：`{len(items)}`",
        f"- Atlas-linked 条目数：`{atlas_count}`",
        "- 生成方式：Codex 内置 `image_gen` 优先",
        "- 原始候选默认位置：`assets/source/ai_generated/batch_XX/<asset_id>/candidates/` 或外部资产库",
        "",
        "## Batch Rules",
        "",
        "- 每个 asset 先生成 queue 指定数量的候选。",
        "- 每次生成后先运行导入命令；扫描不到本地文件时，不把会话预览记为已落盘。",
        "- 透明类资产优先使用 #00ff00 chroma-key 背景，再本地去背景。",
        "- 只有入选并清稿后的 PNG 才进入 `selected_frames`、`selected_items`、`selected_tiles`、`selected_parts` 或 `selected_panels`。",
        "- 接入 Godot 前必须回填来源、prompt、授权和状态。",
        "",
        "## Global Style Anchor",
        "",
        "```text",
        queue.get("style_anchor", ""),
        "```",
        "",
        "## Global Negative Anchor",
        "",
        "```text",
        queue.get("negative_anchor", ""),
        "```",
        "",
        "## Assets",
        "",
    ]
    for item in items:
        lines.extend(render_item(item))
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    queue_path = Path(args.queue)
    queue = load_json(queue_path)
    items = select_items(queue, args.batch, args.asset_id)
    if not items:
        print("No queue items matched the requested filters.")
        return 1

    output_path = Path(args.out) if args.out else default_output_path(args.date, args.batch, args.asset_id)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(render_document(queue, items, args.date), encoding="utf-8")
    print(f"Wrote {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
