#!/usr/bin/env python3
"""Audit Nano Hunter asset records for cross-project image_gen contamination."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PROJECT_KEY = "nano-hunter"
DEFAULT_REPORT = "docs/assets/project-asset-isolation-report.json"
DEFAULT_MARKDOWN = "docs/assets/project-asset-isolation-report.md"
SCAN_GLOBS = ("*.json", "*.md", "*.tres", "*.import", "*.gd", "*.py", "*.ps1")
SCAN_ROOTS = ("assets", "docs/assets", "scripts/assets")
FORBIDDEN_PROJECT_MARKERS = (
    "metroidvania-action-adventure-demo",
    "base-building-survival-game-demo",
    "Godot 2D Asset Pipeline",
    "multi-domain-bidding-platform",
    "angel-fallen",
)
ALLOWED_EXTERNAL_PATH_MARKERS = (
    "Documents/Codex/tools/imagegen-export",
    "Documents\\Codex\\tools\\imagegen-export",
    ".codex/generated_images",
    ".codex\\generated_images",
    ".codex/sessions",
    ".codex\\sessions",
    "C:/path/to/",
    "C:\\path\\to\\",
)
ABSOLUTE_PATH_RE = re.compile(
    r"(?<![A-Za-z0-9_])(?:[A-Za-z]:[\\/](?![\\/])[^\s\"'`<>]+|/mnt/[a-z]/[^\s\"'`<>]+)"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit project asset isolation for Nano Hunter image_gen assets.",
    )
    parser.add_argument("--out", default=DEFAULT_REPORT, help="JSON report path.")
    parser.add_argument("--markdown", default=DEFAULT_MARKDOWN, help="Markdown report path.")
    parser.add_argument("--write-report", action="store_true", help="Write reports.")
    parser.add_argument("--strict", action="store_true", help="Fail on isolation errors.")
    return parser.parse_args()


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def normalize(value: str) -> str:
    return value.replace("\\", "/")


def is_path_allowed(path_text: str) -> bool:
    normalized = normalize(path_text)
    if PROJECT_KEY in normalized:
        return True
    return any(normalize(marker) in normalized for marker in ALLOWED_EXTERNAL_PATH_MARKERS)


def iter_scan_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for scan_root in SCAN_ROOTS:
        directory = root / scan_root
        if not directory.exists():
            continue
        for pattern in SCAN_GLOBS:
            files.extend(directory.rglob(pattern))
    skipped = {
        root / DEFAULT_REPORT,
        root / DEFAULT_MARKDOWN,
    }
    return sorted({path for path in files if path.is_file() and path not in skipped})


def json_project_key_errors(path: Path, root: Path) -> list[dict[str, Any]]:
    if path.suffix.lower() != ".json":
        return []
    try:
        data = load_json(path)
    except (OSError, json.JSONDecodeError):
        return []

    errors: list[dict[str, Any]] = []

    def visit(value: Any, pointer: str) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                child_pointer = f"{pointer}/{key}" if pointer else f"/{key}"
                if key == "project_key" and child != PROJECT_KEY:
                    errors.append(
                        {
                            "file": path.relative_to(root).as_posix(),
                            "pointer": child_pointer,
                            "value": child,
                            "reason": f"project_key must be {PROJECT_KEY}",
                        }
                    )
                visit(child, child_pointer)
        elif isinstance(value, list):
            for index, child in enumerate(value):
                visit(child, f"{pointer}/{index}")

    visit(data, "")
    return errors


def scan_text_file(path: Path, root: Path) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    marker_matches: list[dict[str, Any]] = []
    path_matches: list[dict[str, Any]] = []
    try:
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        return marker_matches, path_matches

    relative = path.relative_to(root).as_posix()
    for line_number, line in enumerate(lines, start=1):
        if relative != "scripts/assets/audit_project_asset_isolation.py":
            for marker in FORBIDDEN_PROJECT_MARKERS:
                if marker in line and PROJECT_KEY not in line:
                    marker_matches.append(
                        {
                            "file": relative,
                            "line": line_number,
                            "marker": marker,
                            "excerpt": line.strip()[:240],
                        }
                    )
        for match in ABSOLUTE_PATH_RE.findall(line):
            if not is_path_allowed(match):
                path_matches.append(
                    {
                        "file": relative,
                        "line": line_number,
                        "path": match,
                        "excerpt": line.strip()[:240],
                    }
                )
    return marker_matches, path_matches


def build_report(root: Path) -> dict[str, Any]:
    marker_matches: list[dict[str, Any]] = []
    outside_path_matches: list[dict[str, Any]] = []
    project_key_errors: list[dict[str, Any]] = []

    files = iter_scan_files(root)
    for path in files:
        file_marker_matches, file_path_matches = scan_text_file(path, root)
        marker_matches.extend(file_marker_matches)
        outside_path_matches.extend(file_path_matches)
        project_key_errors.extend(json_project_key_errors(path, root))

    errors: list[str] = []
    if marker_matches:
        errors.append(f"forbidden project markers found: {len(marker_matches)}")
    if outside_path_matches:
        errors.append(f"outside absolute paths found: {len(outside_path_matches)}")
    if project_key_errors:
        errors.append(f"project_key mismatches found: {len(project_key_errors)}")

    return {
        "version": 1,
        "project_key": PROJECT_KEY,
        "status": "isolation_failed" if errors else "isolated",
        "boundary": (
            "Project isolation audit only. It checks asset records, asset docs and asset scripts "
            "for known other-project markers, outside absolute paths and non-Nano-Hunter project keys. "
            "It does not prove visual quality, legal terms, final art readiness or runtime polish."
        ),
        "scan_roots": list(SCAN_ROOTS),
        "summary": {
            "scanned_file_count": len(files),
            "forbidden_project_marker_count": len(marker_matches),
            "outside_absolute_path_count": len(outside_path_matches),
            "project_key_error_count": len(project_key_errors),
            "errors": errors,
        },
        "forbidden_project_marker_matches": marker_matches,
        "outside_absolute_path_matches": outside_path_matches,
        "project_key_errors": project_key_errors,
        "allowed_external_path_markers": list(ALLOWED_EXTERNAL_PATH_MARKERS),
    }


def write_markdown(report: dict[str, Any], path: Path) -> None:
    summary = report["summary"]
    lines = [
        "# Project Asset Isolation Report / 项目资产隔离报告",
        "",
        "本报告用于防止多项目并行时把其它项目的 image_gen 输出误归属到 Nano Hunter。它只证明项目隔离，不证明最终美术质量、授权或 final-ready。",
        "",
        "## Summary",
        "",
        f"- Status: `{report['status']}`",
        f"- Project key: `{report['project_key']}`",
        f"- Scanned files: `{summary['scanned_file_count']}`",
        f"- Forbidden project markers: `{summary['forbidden_project_marker_count']}`",
        f"- Outside absolute paths: `{summary['outside_absolute_path_count']}`",
        f"- Project key errors: `{summary['project_key_error_count']}`",
        "",
        "## Boundary",
        "",
        "- 允许记录 `Documents/Codex/tools/imagegen-export` 这类导出脚本路径。",
        "- 允许包含 `nano-hunter` 的历史或当前本地路径。",
        "- 不允许资产记录、资产文档或资产脚本里出现其它项目标识作为来源。",
        "- 该报告不替代 `imagegen-source-safety-report`、`runtime-source-safety-report` 或人工审图。",
        "",
    ]
    if summary["errors"]:
        lines.extend(["## Errors", ""])
        for error in summary["errors"]:
            lines.append(f"- {error}")
        lines.append("")
    else:
        lines.extend(
            [
                "## Result",
                "",
                "未发现已扫描资产记录中混入已知其它项目标识、外项目绝对路径或非 Nano Hunter `project_key`。",
                "",
            ]
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    report = build_report(root)
    if args.write_report:
        out_path = root / args.out
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        write_markdown(report, root / args.markdown)

    summary = report["summary"]
    print(
        "Project asset isolation: "
        f"{summary['scanned_file_count']} files, "
        f"{summary['forbidden_project_marker_count']} forbidden markers, "
        f"{summary['outside_absolute_path_count']} outside paths, "
        f"{summary['project_key_error_count']} project_key errors."
    )
    if summary["errors"]:
        for error in summary["errors"]:
            print(f"ERROR: {error}")
        return 1 if args.strict else 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
