#!/usr/bin/env python3
"""Audit landing of runtime source regeneration PNGs into Nano Hunter candidate paths."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_PACKET = "docs/assets/runtime-source-regeneration-packet.json"
DEFAULT_REPORT = "docs/assets/runtime-source-regeneration-landing-report.json"
DEFAULT_MARKDOWN = "docs/assets/runtime-source-regeneration-landing-report.md"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit where runtime source regeneration PNGs land in the Nano Hunter workspace.",
    )
    parser.add_argument("--packet", default=DEFAULT_PACKET, help="Runtime source regeneration packet JSON.")
    parser.add_argument("--out", default=DEFAULT_REPORT, help="JSON report output path.")
    parser.add_argument("--markdown", default=DEFAULT_MARKDOWN, help="Markdown report output path.")
    parser.add_argument("--write-report", action="store_true", help="Write the landing report files.")
    parser.add_argument("--strict", action="store_true", help="Fail on malformed paths or misplaced assets.")
    parser.add_argument(
        "--accept-latest-existing",
        action="store_true",
        help=(
            "If the packet was rebuilt after import and now points to the next slot, "
            "treat the latest existing candidate in the same asset folder as landed."
        ),
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def resolve_path(root: Path, value: str | Path) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def normalize(path: Path) -> str:
    return path.as_posix()


def normalize_batch(batch: str) -> str:
    value = batch.strip().lower()
    if value.startswith("batch_"):
        return value
    if value.startswith("batch "):
        value = value.replace("batch ", "")
    return f"batch_{int(value):02d}"


def latest_existing_candidate(root: Path, entry: dict[str, Any]) -> Path | None:
    source_dir = resolve_path(root, entry.get("source_dir", ""))
    if not source_dir.exists() or not source_dir.is_dir():
        return None
    asset_id = str(entry["asset_id"])
    candidates = sorted(source_dir.glob(f"{asset_id}_candidate_*.png"))
    if not candidates:
        return None
    return candidates[-1]


def audit_entry(root: Path, entry: dict[str, Any], accept_latest_existing: bool) -> dict[str, Any]:
    candidate_path = resolve_path(root, entry["candidate_path"])
    expected_candidate_rel = Path(entry["candidate_path"]).as_posix()
    expected_output = str(entry.get("output_path", ""))
    art_output_path = resolve_path(root, expected_output) if expected_output else None
    candidate_rel = candidate_path.relative_to(root).as_posix() if candidate_path.is_relative_to(root) else candidate_path.as_posix()
    target_prefix = f"assets/source/ai_generated/{normalize_batch(str(entry.get('batch', '')) )}/{entry['asset_id']}/candidates/"
    status = "pending"
    errors: list[str] = []
    landed_candidate = candidate_path
    landed_note = ""

    if not expected_candidate_rel.startswith("assets/source/ai_generated/"):
        errors.append("candidate path must live under assets/source/ai_generated")
    if candidate_rel != expected_candidate_rel:
        errors.append("resolved candidate path differs from packet path")
    if not expected_candidate_rel.startswith(target_prefix):
        errors.append("candidate path does not match expected batch/asset slot")
    if art_output_path and candidate_path.exists() and candidate_path.resolve() == art_output_path.resolve():
        errors.append("candidate path must not overwrite assets/art output")

    if not candidate_path.exists() and accept_latest_existing:
        latest_candidate = latest_existing_candidate(root, entry)
        if latest_candidate:
            landed_candidate = latest_candidate
            landed_note = "packet path was advanced after import; latest existing candidate accepted"

    if landed_candidate.exists():
        if landed_candidate.suffix.lower() != ".png":
            errors.append("candidate file must be a PNG")
        elif not landed_candidate.is_file():
            errors.append("candidate path exists but is not a file")
        elif landed_candidate.suffix.lower() == ".png":
            status = "landed"
    else:
        status = "pending"

    if errors:
        status = "invalid"

    return {
        "asset_id": entry["asset_id"],
        "batch": entry.get("batch", ""),
        "target_kind": entry.get("target_kind", ""),
        "candidate_path": expected_candidate_rel,
        "landed_candidate_path": landed_candidate.relative_to(root).as_posix()
        if landed_candidate.is_relative_to(root)
        else landed_candidate.as_posix(),
        "candidate_exists": landed_candidate.exists(),
        "candidate_status": status,
        "landing_note": landed_note,
        "output_path": expected_output,
        "target_scenes": entry.get("target_scenes", []),
        "errors": errors,
    }


def build_report(root: Path, packet_path: Path, accept_latest_existing: bool) -> dict[str, Any]:
    packet = load_json(packet_path)
    entries = [
        audit_entry(root, entry, accept_latest_existing)
        for entry in packet.get("entries", [])
    ]
    counts = {
        "total": len(entries),
        "pending": sum(1 for entry in entries if entry["candidate_status"] == "pending"),
        "landed": sum(1 for entry in entries if entry["candidate_status"] == "landed"),
        "invalid": sum(1 for entry in entries if entry["candidate_status"] == "invalid"),
    }
    errors = [
        f"{entry['asset_id']}: {', '.join(entry['errors'])}"
        for entry in entries
        if entry["errors"]
    ]
    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "landing_invalid" if counts["invalid"] else "landing_pending" if counts["pending"] else "landing_complete",
        "boundary": (
            "Landing audit only. It checks whether runtime regeneration PNGs exist at the exact "
            "project candidate paths and do not overwrite assets/art. With accept-latest-existing, "
            "it can also recognize the latest candidate when the prompt packet has already advanced "
            "to the next slot. It does not generate or approve art."
        ),
        "accept_latest_existing": accept_latest_existing,
        "summary": {
            "asset_count": counts["total"],
            "pending_count": counts["pending"],
            "landed_count": counts["landed"],
            "invalid_count": counts["invalid"],
            "errors": errors,
        },
        "entries": entries,
    }


def write_markdown(report: dict[str, Any], path: Path) -> None:
    summary = report["summary"]
    lines = [
        "# Runtime Source Regeneration Landing Report / 运行时重生图落盘报告",
        "",
        "本报告只检查重生图是否真正落到 Nano Hunter 目标候选路径。未落盘时标记为 `pending`；落在错误位置、错误类型或覆盖 `assets/art/` 时标记为 `invalid`。",
        "",
        "## Summary",
        "",
        f"- Project key: `{report['project_key']}`",
        f"- Assets: `{summary['asset_count']}`",
        f"- Pending: `{summary['pending_count']}`",
        f"- Landed: `{summary['landed_count']}`",
        f"- Invalid: `{summary['invalid_count']}`",
        "",
        "## Result",
        "",
    ]
    if summary["invalid_count"]:
        lines.append("存在落盘路径问题，需要修正。")
        lines.append("")
    elif summary["pending_count"]:
        lines.append("当前尚未发现实际落盘 PNG，仍处于等待 image_gen 生成或手动导入阶段。")
        lines.append("")
    else:
        lines.append("所有重生图候选已落到预期路径。")
        lines.append("")
    lines.append("## Entries")
    lines.append("")
    for entry in report["entries"]:
        scenes = ", ".join(entry["target_scenes"]) if entry["target_scenes"] else "not referenced"
        lines.extend(
            [
                f"### {entry['asset_id']}",
                "",
                f"- Status: `{entry['candidate_status']}`",
                f"- Candidate: `{entry['candidate_path']}`",
                f"- Landed candidate: `{entry['landed_candidate_path']}`",
                f"- Current output: `{entry['output_path']}`",
                f"- Runtime scenes: `{scenes}`",
            ]
        )
        if entry.get("landing_note"):
            lines.append(f"- Note: `{entry['landing_note']}`")
        if entry["errors"]:
            lines.append(f"- Errors: `{'; '.join(entry['errors'])}`")
        lines.append("")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    packet_path = resolve_path(root, args.packet)
    report = build_report(root, packet_path, args.accept_latest_existing)
    if args.write_report:
        out_path = resolve_path(root, args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_markdown(report, resolve_path(root, args.markdown))

    summary = report["summary"]
    print(
        "Runtime source regeneration landing: "
        f"{summary['asset_count']} assets, "
        f"{summary['pending_count']} pending, "
        f"{summary['landed_count']} landed, "
        f"{summary['invalid_count']} invalid."
    )
    if summary["errors"]:
        for error in summary["errors"]:
            print(f"ERROR: {error}")
        return 1 if args.strict else 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
