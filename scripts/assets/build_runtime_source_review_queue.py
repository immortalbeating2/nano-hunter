#!/usr/bin/env python3
"""生成运行时 image_gen 来源复核队列。"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
CONFIRMED_STATUSES = {"project_session_confirmed", "explicit_mapping_confirmed"}
DEFAULT_RUNTIME_SAFETY = "docs/assets/runtime-source-safety-report.json"
DEFAULT_SOURCE_SAFETY = "docs/assets/imagegen-source-safety-report.json"
DEFAULT_PROVENANCE = "docs/assets/asset-provenance-records.json"
DEFAULT_JSON_OUT = "docs/assets/runtime-source-review-queue.json"
DEFAULT_MARKDOWN_OUT = "docs/assets/runtime-source-review-queue.md"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build runtime source review queue for image_gen assets.")
    parser.add_argument("--runtime-safety", default=DEFAULT_RUNTIME_SAFETY)
    parser.add_argument("--source-safety", default=DEFAULT_SOURCE_SAFETY)
    parser.add_argument("--provenance", default=DEFAULT_PROVENANCE)
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


def candidate_index(path: str) -> int | None:
    match = re.search(r"_candidate_(\d+)\.png$", path)
    if not match:
        return None
    return int(match.group(1))


def by_asset(items: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {str(item.get("asset_id", "")): item for item in items if item.get("asset_id")}


def candidate_rows(source_item: dict[str, Any], selected_indices: set[int]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for candidate in source_item.get("candidates", []):
        path = str(candidate.get("path", ""))
        index = candidate_index(path)
        status = str(candidate.get("status", "unknown_or_unsafe"))
        rows.append(
            {
                "index": index,
                "path": path,
                "status": status,
                "selected": index in selected_indices if index is not None else False,
                "confirmed": status in CONFIRMED_STATUSES,
                "reasons": candidate.get("reasons", []),
            }
        )
    return rows


def review_strategy(runtime_item: dict[str, Any], candidates: list[dict[str, Any]]) -> tuple[str, str]:
    selected = [candidate for candidate in candidates if candidate["selected"]]
    selected_statuses = {candidate["status"] for candidate in selected}
    has_confirmed = any(candidate["confirmed"] for candidate in candidates)
    selected_has_confirmed = any(candidate["confirmed"] for candidate in selected)
    selected_has_review = any(
        status not in CONFIRMED_STATUSES
        for status in selected_statuses
    )
    source_status = str(runtime_item.get("source_status", ""))

    if source_status == "unsafe_candidate_present":
        return (
            "block_until_source_removed",
            "先隔离 unsafe candidate，禁止继续运行时接入或 final-ready 结论。",
        )
    if selected_has_confirmed and selected_has_review:
        return (
            "manual_compare_selected_mix",
            "当前 selected sources 混用确认候选和 review-required 候选；先人工比较候选质量，再决定确认、重生图或局部重建。",
        )
    if selected_has_review and not selected_has_confirmed and not has_confirmed:
        return (
            "manual_source_review_or_regenerate",
            "当前运行时来源只来自 review-required 候选；需要人工确认来源或重新使用 image_gen 生成 Nano Hunter 专属候选。",
        )
    if selected_has_review and has_confirmed:
        return (
            "confirmed_candidate_rebuild_candidate",
            "存在确认候选，但当前 selected sources 仍含 review-required；重建前必须 dry-run，若出现 duplicate 补位则不要自动回退。",
        )
    return (
        "manual_review_required",
        "来源仍需人工复核；保持 preview 边界，不声明 final-ready。",
    )


def build_entry(runtime_item: dict[str, Any], source_item: dict[str, Any], provenance_item: dict[str, Any]) -> dict[str, Any]:
    selected_indices = {
        int(index)
        for index in provenance_item.get("selected_candidate_indices", [])
        if isinstance(index, int)
    }
    candidates = candidate_rows(source_item, selected_indices)
    strategy, next_action = review_strategy(runtime_item, candidates)
    target_scenes = runtime_item.get("target_scenes", [])
    return {
        "asset_id": runtime_item.get("asset_id", ""),
        "target_kind": provenance_item.get("target_kind", ""),
        "runtime_source_gate": runtime_item.get("runtime_source_gate", ""),
        "source_status": runtime_item.get("source_status", ""),
        "selected_candidate_indices": sorted(selected_indices),
        "review_strategy": strategy,
        "next_action": next_action,
        "target_scenes": target_scenes,
        "resource_path": runtime_item.get("resource_path", ""),
        "output_path": provenance_item.get("output_path", ""),
        "candidates": candidates,
    }


def markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Runtime Source Review Queue / 运行时来源复核队列",
        "",
        "该队列只处理已经进入运行时引用或 P0 替换路径的 image_gen 资产来源风险。它不证明最终美术质量、授权、清稿或 final-ready。",
        "",
        "## Summary",
        "",
        f"- Runtime review-required assets: `{report['summary']['runtime_review_required_count']}`",
        f"- Unsafe assets: `{report['summary']['unsafe_item_count']}`",
        "",
        "## Strategy Counts",
        "",
    ]
    for key, value in report["summary"]["strategy_counts"].items():
        lines.append(f"- `{key}`: `{value}`")
    lines.extend(["", "## Queue", ""])
    for entry in report["entries"]:
        candidates = ", ".join(
            f"{candidate['index']:02d}:{candidate['status']}{'*' if candidate['selected'] else ''}"
            for candidate in entry["candidates"]
            if candidate["index"] is not None
        )
        scenes = ", ".join(entry["target_scenes"]) if entry["target_scenes"] else "not referenced"
        lines.append(
            f"- [ ] `{entry['asset_id']}` ({entry['target_kind']}) - `{entry['review_strategy']}`"
        )
        lines.append(f"  - Selected candidates: `{entry['selected_candidate_indices']}`")
        lines.append(f"  - Candidate statuses: `{candidates}`")
        lines.append(f"  - Scenes: `{scenes}`")
        lines.append(f"  - Next: {entry['next_action']}")
    lines.append("")
    return "\n".join(lines)


def build_report(root: Path, runtime_path: Path, source_path: Path, provenance_path: Path) -> dict[str, Any]:
    runtime = load_json(runtime_path)
    source = load_json(source_path)
    provenance = load_json(provenance_path)
    errors: list[str] = []
    for name, data in (("runtime source safety", runtime), ("source safety", source), ("provenance", provenance)):
        if data.get("project_key") != PROJECT_KEY:
            errors.append(f"{name} project_key must be {PROJECT_KEY}")

    source_lookup = by_asset(source.get("items", []))
    provenance_lookup = by_asset(provenance.get("records", []))
    review_ids = set(runtime.get("summary", {}).get("runtime_review_required_items", []))
    entries: list[dict[str, Any]] = []
    for runtime_item in runtime.get("items", []):
        asset_id = str(runtime_item.get("asset_id", ""))
        if asset_id not in review_ids:
            continue
        source_item = source_lookup.get(asset_id, {})
        provenance_item = provenance_lookup.get(asset_id, {})
        if not source_item:
            errors.append(f"{asset_id}: missing source safety item")
        if not provenance_item:
            errors.append(f"{asset_id}: missing provenance record")
        entries.append(build_entry(runtime_item, source_item, provenance_item))

    strategy_counts = Counter(entry["review_strategy"] for entry in entries)
    unsafe_count = int(runtime.get("summary", {}).get("unsafe_item_count", 0))
    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "unsafe_source_found" if unsafe_count else "runtime_source_review_required" if entries else "ready",
        "boundary": (
            "Review queue for runtime-bound image_gen source risk. "
            "It recommends review and regeneration actions; it does not approve final art."
        ),
        "sources": {
            "runtime_source_safety": runtime_path.relative_to(root).as_posix(),
            "imagegen_source_safety": source_path.relative_to(root).as_posix(),
            "asset_provenance": provenance_path.relative_to(root).as_posix(),
        },
        "summary": {
            "runtime_review_required_count": len(entries),
            "unsafe_item_count": unsafe_count,
            "strategy_counts": dict(sorted(strategy_counts.items())),
            "errors": errors,
        },
        "entries": entries,
    }


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(
        root,
        resolve_path(root, args.runtime_safety),
        resolve_path(root, args.source_safety),
        resolve_path(root, args.provenance),
    )
    json_out = resolve_path(root, args.json_out)
    markdown_out = resolve_path(root, args.markdown_out)
    json_out.parent.mkdir(parents=True, exist_ok=True)
    markdown_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    markdown_out.write_text(markdown(report), encoding="utf-8")

    summary = report["summary"]
    for error in summary["errors"]:
        print(f"ERROR: {error}")
    print(
        "Runtime source review queue: "
        f"{summary['runtime_review_required_count']} review-required assets, "
        f"{summary['unsafe_item_count']} unsafe."
    )
    return 1 if summary["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
