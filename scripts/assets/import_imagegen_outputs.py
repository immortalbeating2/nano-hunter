#!/usr/bin/env python3
"""定位并导入 Codex 内置 image_gen 生成图到 Nano Hunter 资产批次目录。"""

from __future__ import annotations

import argparse
import os
import shutil
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path


IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}
DEFAULT_EXCLUDES = (
    "\\.tmp\\plugins\\",
    "\\bundled-marketplaces\\",
    "\\plugins\\cache\\",
    "\\node_modules\\",
    "\\.godot\\",
    "\\Cache\\Cache_Data\\",
    "\\Code Cache\\",
    "\\GPUCache\\",
)


@dataclass(frozen=True)
class ImageCandidate:
    path: Path
    modified: datetime
    size: int
    kind: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Find or import built-in image_gen outputs into assets/source/ai_generated.",
    )
    parser.add_argument(
        "--batch",
        help="Batch id, for example batch_01 or 01. Required when importing.",
    )
    parser.add_argument(
        "--asset-id",
        help="Asset id used for the destination folder and filename. Required when importing.",
    )
    parser.add_argument(
        "--source",
        help="Explicit source image path to import. Use this when the image was saved manually.",
    )
    parser.add_argument(
        "--copy-latest",
        action="store_true",
        help=(
            "Import the newest scanned image candidate. This is blocked for the global "
            "Codex generated_images root unless --allow-global-latest is also passed."
        ),
    )
    parser.add_argument(
        "--allow-global-latest",
        action="store_true",
        help=(
            "Allow --copy-latest to import from CODEX_HOME/generated_images. Use only "
            "after manually confirming the image belongs to Nano Hunter."
        ),
    )
    parser.add_argument(
        "--slot",
        choices=("candidates", "selected_frames", "selected_items"),
        default="candidates",
        help="Destination slot below the asset folder.",
    )
    parser.add_argument(
        "--since-minutes",
        type=int,
        default=120,
        help="Scan images modified within this many minutes.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Maximum candidates to print.",
    )
    parser.add_argument(
        "--root",
        action="append",
        help="Additional root to scan. Can be passed multiple times.",
    )
    parser.add_argument(
        "--include-codex-home",
        action="store_true",
        help="Also scan CODEX_HOME outside generated_images. This is a fallback, not the default.",
    )
    parser.add_argument(
        "--include-temp",
        action="store_true",
        help="Also scan TEMP/TMP clipboard or manually saved images. This is a fallback, not the default.",
    )
    parser.add_argument(
        "--include-inbox",
        action="store_true",
        help="Also scan assets/source/imagegen_inbox for manually saved image_gen downloads.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the planned import path without copying.",
    )
    parser.add_argument(
        "--magic-scan",
        action="store_true",
        help="Detect PNG/JPEG/WebP files by file header, including files with missing or wrong extensions.",
    )
    parser.add_argument(
        "--min-size",
        type=int,
        default=0,
        help="Minimum file size in bytes for scan candidates.",
    )
    return parser.parse_args()


def repo_root() -> Path:
    return Path.cwd().resolve()


def codex_home() -> Path:
    value = os.environ.get("CODEX_HOME")
    if value:
        return Path(value).expanduser().resolve()
    return (Path.home() / ".codex").resolve()


def default_roots(
    root: Path,
    extra_roots: list[str] | None,
    include_codex_home: bool,
    include_temp: bool,
    include_inbox: bool,
) -> list[Path]:
    home = codex_home()
    roots = [home / "generated_images"]
    if include_inbox:
        roots.append(root / "assets" / "source" / "imagegen_inbox")
    if include_codex_home:
        roots.append(home)
    if include_temp:
        roots.extend(
            [
                Path(os.environ.get("TEMP", "")),
                Path(os.environ.get("TMP", "")),
            ]
        )
    if extra_roots:
        roots.extend(Path(root).expanduser() for root in extra_roots)

    seen: set[Path] = set()
    existing: list[Path] = []
    for root in roots:
        if not str(root):
            continue
        resolved = root.resolve()
        if resolved in seen or not resolved.exists():
            continue
        seen.add(resolved)
        existing.append(resolved)
    return existing


def is_excluded(path: Path) -> bool:
    normalized = str(path)
    return any(pattern in normalized for pattern in DEFAULT_EXCLUDES)


def detect_image_kind(path: Path, magic_scan: bool) -> str | None:
    suffix = path.suffix.lower()
    if not magic_scan:
        if suffix in IMAGE_EXTENSIONS:
            return suffix.lstrip(".")
        return None

    try:
        with path.open("rb") as file:
            head = file.read(16)
    except OSError:
        return None

    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if head.startswith(b"\xff\xd8\xff"):
        return "jpg"
    if head.startswith(b"RIFF") and head[8:12] == b"WEBP":
        return "webp"
    return None


def scan_candidates(
    roots: list[Path],
    since_minutes: int,
    magic_scan: bool,
    min_size: int,
) -> list[ImageCandidate]:
    cutoff = datetime.now() - timedelta(minutes=since_minutes)
    candidates: list[ImageCandidate] = []
    for root in roots:
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if is_excluded(path):
                continue
            stat = path.stat()
            if stat.st_size < min_size:
                continue
            modified = datetime.fromtimestamp(stat.st_mtime)
            if modified < cutoff:
                continue
            kind = detect_image_kind(path, magic_scan)
            if not kind:
                continue
            candidates.append(
                ImageCandidate(path=path, modified=modified, size=stat.st_size, kind=kind)
            )
    return sorted(candidates, key=lambda item: item.modified, reverse=True)


def normalize_batch(batch: str) -> str:
    value = batch.strip().lower()
    if value.startswith("batch_"):
        return value
    return f"batch_{int(value):02d}"


def next_destination(root: Path, batch: str, asset_id: str, slot: str, extension: str) -> Path:
    batch_id = normalize_batch(batch)
    target_dir = root / "assets" / "source" / "ai_generated" / batch_id / asset_id / slot
    if slot == "candidates":
        prefix = f"{asset_id}_candidate"
    elif slot == "selected_frames":
        prefix = f"{asset_id}_frame"
    else:
        prefix = f"{asset_id}_item"

    index = 1
    while True:
        width = 3 if slot != "candidates" else 2
        candidate = target_dir / f"{prefix}_{index:0{width}d}{extension.lower()}"
        if not candidate.exists():
            return candidate
        index += 1


def print_candidates(candidates: list[ImageCandidate], limit: int) -> None:
    if not candidates:
        print("No recent image candidates found.")
        return
    for index, item in enumerate(candidates[:limit], start=1):
        print(
            f"{index:02d}  {item.modified:%Y-%m-%d %H:%M:%S}  "
            f"{item.size:>9}  {item.kind:<4}  {item.path}"
        )


def import_source(source: Path, target: Path, dry_run: bool) -> None:
    if not source.exists() or not source.is_file():
        raise FileNotFoundError(f"Source image not found: {source}")
    if not detect_image_kind(source, True):
        raise ValueError(f"Unsupported source image file: {source}")

    print(f"source: {source}")
    print(f"target: {target}")
    if dry_run:
        print("dry-run: no file copied")
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    print("copied")


def is_inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
    except ValueError:
        return False
    return True


def main() -> int:
    args = parse_args()
    root = repo_root()
    roots = default_roots(
        root,
        args.root,
        args.include_codex_home,
        args.include_temp,
        args.include_inbox,
    )
    candidates = scan_candidates(roots, args.since_minutes, args.magic_scan, args.min_size)

    print("Scan roots:")
    for scan_root in roots:
        print(f"  {scan_root}")
    print_candidates(candidates, args.limit)

    source: Path | None = None
    source_kind: str | None = None
    if args.source:
        source = Path(args.source).expanduser().resolve()
        source_kind = detect_image_kind(source, True)
    elif args.copy_latest:
        if not candidates:
            print("Cannot copy latest because no candidates were found.")
            return 1
        source = candidates[0].path
        source_kind = candidates[0].kind
        global_generated_root = codex_home() / "generated_images"
        if is_inside(source, global_generated_root) and not args.allow_global_latest:
            print(
                "Refusing --copy-latest from the global Codex generated_images root. "
                "Multiple projects can write there at the same time, so the newest PNG "
                "is not reliable project evidence."
            )
            print("Use --source with an inspected image path, or rerun with --allow-global-latest after manual confirmation.")
            print(f"blocked_source: {source}")
            return 4

    if not source:
        return 0

    if not args.batch or not args.asset_id:
        print("--batch and --asset-id are required when importing.")
        return 2

    if not source_kind:
        print(f"Unsupported source image file: {source}")
        return 3

    extension = source.suffix.lower() or f".{source_kind}"
    target = next_destination(root, args.batch, args.asset_id, args.slot, extension)
    import_source(source, target, args.dry_run)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
