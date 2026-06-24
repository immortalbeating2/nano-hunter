#!/usr/bin/env python3
"""Build source, prompt and hash provenance records for image-gen assets."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


DEFAULT_REPORT = "docs/assets/asset-provenance-records.json"
PROJECT_KEY = "nano-hunter"
PROJECT_NAME = "Nano Hunter"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build provenance records for Nano Hunter image-gen assets.",
    )
    parser.add_argument(
        "--queue",
        default="docs/assets/image-gen-prompt-queue.json",
        help="Path to the image-gen prompt queue.",
    )
    parser.add_argument(
        "--candidate-pool",
        default="docs/assets/imagegen-candidate-pool-report.json",
        help="Path to the image-gen candidate pool report.",
    )
    parser.add_argument(
        "--out",
        default=DEFAULT_REPORT,
        help="Output provenance report path.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolve_path(root: Path, value: str) -> Path:
    path = Path(value)
    if path.is_absolute():
        return path
    return root / path


def normalize_rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def main() -> int:
    args = parse_args()
    root = Path.cwd().resolve()
    queue = load_json(resolve_path(root, args.queue))
    candidate_pool = load_json(resolve_path(root, args.candidate_pool))
    candidate_items = {
        item["asset_id"]: item
        for item in candidate_pool.get("items", [])
    }

    records: list[dict[str, Any]] = []
    for item in queue.get("items", []):
        asset_id = item["asset_id"]
        prompt = str(item.get("prompt", ""))
        output_path = resolve_path(root, item["output_path"])
        candidate_item = candidate_items.get(asset_id, {})
        candidates = candidate_item.get("candidates", [])
        records.append(
            {
                "asset_id": asset_id,
                "project_key": PROJECT_KEY,
                "project_name": PROJECT_NAME,
                "batch": item.get("batch", ""),
                "priority": item.get("priority", ""),
                "target_kind": item.get("target_kind", ""),
                "tool": "Codex built-in image_gen",
                "tool_mode": "built_in",
                "source_type": "ai_generated_bitmap",
                "source_status": "source_recorded",
                "license_record_status": "source_recorded_terms_review_required",
                "commercial_use_status": "manual_terms_review_required_before_external_release",
                "prompt": prompt,
                "prompt_sha256": sha256_text(prompt),
                "source_dir": item.get("source_dir", ""),
                "output_path": normalize_rel(output_path, root),
                "output_sha256": sha256_file(output_path) if output_path.exists() else "",
                "candidate_count": len(candidates),
                "candidate_hashes": [
                    {
                        "index": candidate.get("index"),
                        "path": candidate.get("path", ""),
                        "sha256": candidate.get("sha256", ""),
                        "width": candidate.get("width", 0),
                        "height": candidate.get("height", 0),
                        "mode": candidate.get("mode", ""),
                    }
                    for candidate in candidates
                ],
                "selected_source_count": int(candidate_item.get("selected_source_count", 0)),
                "selected_candidate_indices": candidate_item.get("selected_candidate_indices", []),
                "unselected_candidate_indices": candidate_item.get("unselected_candidate_indices", []),
                "processing_boundary": (
                    "Generated PNG candidates were recovered or copied into the workspace, then processed by "
                    "project scripts into provisional Godot-facing art outputs. This record proves source and "
                    "prompt traceability; it does not approve final art quality or commercial release terms."
                ),
            }
        )

    recovery_ledgers = candidate_pool.get("summary", {}).get("recovery_ledgers", [])
    report = {
        "version": 1,
        "project_key": PROJECT_KEY,
        "project_name": PROJECT_NAME,
        "status": "source_recorded_review_required",
        "boundary": (
            "Provenance record only. It records image-gen prompts, source candidates, hashes and output hashes. "
            "It does not replace legal review, final art approval or runtime integration."
        ),
        "tool_policy": {
            "primary_tool": "Codex built-in image_gen",
            "fallback_tool": "not_used",
            "workspace_destination_required": True,
        },
        "license_boundary": (
            "AI-generated source records are present for project tracking. Commercial release and external "
            "distribution still require manual terms review for the active tool/account and any downstream platform."
        ),
        "summary": {
            "record_count": len(records),
            "candidate_hash_count": sum(record["candidate_count"] for record in records),
            "output_hash_count": sum(1 for record in records if record["output_sha256"]),
            "prompt_hash_count": sum(1 for record in records if record["prompt_sha256"]),
            "recovery_ledger_count": len(recovery_ledgers),
        },
        "recovery_ledgers": recovery_ledgers,
        "records": records,
    }

    out_path = resolve_path(root, args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        "Asset provenance records built: "
        f"{report['summary']['record_count']} records, "
        f"{report['summary']['candidate_hash_count']} candidate hashes, "
        f"{report['summary']['output_hash_count']} output hashes."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
