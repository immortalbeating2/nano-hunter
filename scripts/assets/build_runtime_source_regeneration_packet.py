#!/usr/bin/env python3
"""生成 runtime source 复核后的 image_gen 重生图执行包。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_REVIEW_QUEUE = "docs/assets/runtime-source-review-queue.json"
DEFAULT_PROMPT_QUEUE = "docs/assets/image-gen-prompt-queue.json"
DEFAULT_JSON_OUT = "docs/assets/runtime-source-regeneration-packet.json"
DEFAULT_MARKDOWN_OUT = "docs/assets/runtime-source-regeneration-packet.md"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build image_gen regeneration packet for runtime source review assets.")
    parser.add_argument("--review-queue", default=DEFAULT_REVIEW_QUEUE)
    parser.add_argument("--prompt-queue", default=DEFAULT_PROMPT_QUEUE)
    parser.add_argument("--json-out", default=DEFAULT_JSON_OUT)
    parser.add_argument("--markdown-out", default=DEFAULT_MARKDOWN_OUT)
    return parser.parse_args()


def resolve_path(root: Path, value: str | Path) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def queue_lookup(queue: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {
        str(item.get("asset_id", "")): item
        for item in queue.get("items", [])
        if item.get("asset_id")
    }


def next_candidate_index(root: Path, source_dir: str, asset_id: str) -> int:
    directory = resolve_path(root, source_dir)
    max_index = 0
    pattern = re.compile(r"_candidate_(\d+)\.png$")
    if directory.exists():
        for path in directory.glob(f"{asset_id}_candidate_*.png"):
            match = pattern.search(path.name)
            if match:
                max_index = max(max_index, int(match.group(1)))
    return max_index + 1


def build_prompt(style_anchor: str, negative_anchor: str, base_prompt: str, asset_id: str) -> str:
    return "\n".join(
        [
            base_prompt.strip(),
            "",
            "Regeneration pass requirements:",
            f"- Project key: {PROJECT_KEY}. This image must belong to Nano Hunter only.",
            "- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.",
            "- Keep the asset compatible with the existing Godot target path and current runtime use.",
            "- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.",
            "- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.",
            "- Favor clean silhouette, generous padding, and gameplay readability over decorative density.",
            "",
            "Global style anchor:",
            style_anchor.strip(),
            "",
            "Global negative anchor:",
            negative_anchor.strip(),
            "",
            f"Asset id: {asset_id}",
        ]
    )


def build_entry(root: Path, review_entry: dict[str, Any], prompt_item: dict[str, Any], queue: dict[str, Any]) -> dict[str, Any]:
    asset_id = str(review_entry["asset_id"])
    source_dir = str(prompt_item["source_dir"])
    index = next_candidate_index(root, source_dir, asset_id)
    candidate_name = f"{asset_id}_candidate_{index:02d}.png"
    candidate_path = (Path(source_dir) / candidate_name).as_posix()
    prompt = build_prompt(
        str(queue.get("style_anchor", "")),
        str(queue.get("negative_anchor", "")),
        str(prompt_item.get("prompt", "")),
        asset_id,
    )
    return {
        "asset_id": asset_id,
        "batch": prompt_item.get("batch", ""),
        "priority": prompt_item.get("priority", ""),
        "target_kind": prompt_item.get("target_kind", ""),
        "review_strategy": review_entry.get("review_strategy", ""),
        "source_dir": source_dir,
        "next_candidate_index": index,
        "candidate_path": candidate_path,
        "output_path": prompt_item.get("output_path", ""),
        "target_scenes": review_entry.get("target_scenes", []),
        "prompt": prompt,
        "post_generation_steps": [
            f"保存或导入生成 PNG 到 {candidate_path}",
            "运行候选池、source safety 与 runtime source review queue 审计。",
            "人工审图确认后，再执行 standalone 导出或 atlas rebuild；不要自动覆盖当前运行时引用。",
        ],
    }


def markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Runtime Source Regeneration Packet / 运行时来源重生图执行包",
        "",
        "本执行包用于把只来自 review-required 候选的运行时 UI / VFX 资产重新生成 Nano Hunter 专属候选。它不是生成完成证明；只有 PNG 真实落盘、导入候选池、通过来源审计并完成人工审图后，才允许替换 selected source 或 runtime 输出。",
        "",
        "## Summary",
        "",
        f"- Regeneration assets: `{report['summary']['asset_count']}`",
        f"- Project key: `{report['project_key']}`",
        f"- Source review strategy: `manual_source_review_or_regenerate`",
        "",
        "## Rules",
        "",
        "- 优先使用内置 `image_gen`；当前环境无可调用工具时，只执行本 packet 的准备和审计。",
        "- 每个资产生成后保存为对应 `candidate_XX.png`，不要覆盖旧候选。",
        "- 新候选只进入 `assets/source/ai_generated/.../candidates/`，不得直接覆盖 `assets/art/`。",
        "- 导入后先跑 source safety，再决定是否清稿、导出 standalone 或重建 atlas。",
        "",
        "## Assets",
        "",
    ]
    for entry in report["entries"]:
        scenes = ", ".join(entry["target_scenes"]) if entry["target_scenes"] else "not referenced"
        lines.extend(
            [
                f"### {entry['asset_id']}",
                "",
                f"- Batch: `{entry['batch']}`",
                f"- Target kind: `{entry['target_kind']}`",
                f"- Save as: `{entry['candidate_path']}`",
                f"- Runtime scenes: `{scenes}`",
                f"- Current output: `{entry['output_path']}`",
                "",
                "Prompt to paste into image_gen:",
                "",
                "```text",
                entry["prompt"],
                "```",
                "",
                "After generation:",
                "",
                "```powershell",
                f"python scripts/assets/import_imagegen_outputs.py --source C:\\path\\to\\generated.png --asset-id {entry['asset_id']} --batch {str(entry['batch']).split()[-1]}",
                "python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict",
                "python scripts/assets/audit_imagegen_source_safety.py --write-report --strict",
                "python scripts/assets/build_runtime_source_review_queue.py",
                "python scripts/assets/build_runtime_source_regeneration_packet.py",
                "```",
                "",
            ]
        )
    return "\n".join(lines).rstrip() + "\n"


def build_report(root: Path, review_queue_path: Path, prompt_queue_path: Path) -> dict[str, Any]:
    review_queue = load_json(review_queue_path)
    prompt_queue = load_json(prompt_queue_path)
    lookup = queue_lookup(prompt_queue)
    errors: list[str] = []
    entries: list[dict[str, Any]] = []
    for review_entry in review_queue.get("entries", []):
        if review_entry.get("review_strategy") != "manual_source_review_or_regenerate":
            continue
        asset_id = str(review_entry.get("asset_id", ""))
        prompt_item = lookup.get(asset_id)
        if not prompt_item:
            errors.append(f"{asset_id}: missing prompt queue item")
            continue
        entries.append(build_entry(root, review_entry, prompt_item, prompt_queue))
    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "ready_for_image_gen" if not errors else "errors",
        "boundary": (
            "Regeneration prompt packet only. It prepares exact prompts and target candidate paths; "
            "it does not prove that new images have been generated or approved."
        ),
        "sources": {
            "runtime_source_review_queue": review_queue_path.relative_to(root).as_posix(),
            "image_gen_prompt_queue": prompt_queue_path.relative_to(root).as_posix(),
        },
        "summary": {
            "asset_count": len(entries),
            "errors": errors,
        },
        "entries": entries,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(root, resolve_path(root, args.review_queue), resolve_path(root, args.prompt_queue))
    json_out = resolve_path(root, args.json_out)
    markdown_out = resolve_path(root, args.markdown_out)
    json_out.parent.mkdir(parents=True, exist_ok=True)
    markdown_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    markdown_out.write_text(markdown(report), encoding="utf-8")
    for error in report["summary"]["errors"]:
        print(f"ERROR: {error}")
    print(f"Runtime source regeneration packet: {report['summary']['asset_count']} assets.")
    return 1 if report["summary"]["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
