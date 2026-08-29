#!/usr/bin/env python3
"""Build final-art acceptance gates from readiness and review queue reports."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


READINESS_PATH = Path("docs/assets/art-readiness-audit-report.json")
REVIEW_QUEUE_PATH = Path("docs/assets/final-art-review-queue.json")
WORKBENCH_MANIFEST_PATH = Path("docs/assets/final-art-review-workbench-manifest.json")
RUNTIME_SOURCE_SAFETY_PATH = Path("docs/assets/runtime-source-safety-report.json")
MODEL_LOCK_CONTRACT_PATH = Path("docs/assets/character-creature-model-locks.json")
OUT_JSON = Path("docs/assets/final-art-acceptance-gates.json")
OUT_MD = Path("docs/assets/final-art-acceptance-gates.md")

GATE_ORDER = [
    "source_traceability",
    "license_terms",
    "godot_structural_resource",
    "editor_review_card",
    "runtime_replacement",
    "family_specific_polish",
    "final_approval",
]

GATE_LABELS = {
    "source_traceability": "来源 / prompt / hash 可追溯",
    "license_terms": "商业使用条款人工复核",
    "godot_structural_resource": "Godot 结构资源可用",
    "editor_review_card": "编辑器复核卡可用",
    "runtime_replacement": "运行时引用替换与验证",
    "family_specific_polish": "按资产族清稿 / 读值 / 帧序 / 布局复核",
    "final_approval": "最终美术批准",
}


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def readiness_by_asset(readiness: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(item["asset_id"]): item for item in readiness.get("items", [])}


def review_by_asset(review_queue: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(entry["asset_id"]): entry for entry in review_queue.get("entries", [])}


def runtime_source_by_asset(runtime_source_report: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {str(item["asset_id"]): item for item in runtime_source_report.get("items", [])}


def gate(status: str, evidence: list[str], blockers: list[str] | None = None) -> dict[str, Any]:
    return {
        "status": status,
        "evidence": evidence,
        "blockers": blockers or [],
    }


def build_entry(
    asset_id: str,
    readiness_item: dict[str, Any],
    review_entry: dict[str, Any],
    runtime_source_item: dict[str, Any],
    workbench_present: bool,
) -> dict[str, Any]:
    blockers = list(review_entry.get("blockers", []))
    output_path = str(readiness_item.get("output_path") or review_entry.get("output_path", ""))
    provenance = readiness_item.get("provenance") or {}
    runtime_catalog = readiness_item.get("runtime_catalog") or {}

    provenance_ok = (
        provenance.get("source_status") == "source_recorded"
        and bool(provenance.get("prompt_sha256"))
        and bool(provenance.get("output_sha256"))
    )
    runtime_source_gate = str(runtime_source_item.get("runtime_source_gate", "not_runtime_bound"))
    runtime_source_ok = runtime_source_gate in {
        "not_runtime_bound",
        "runtime_reference_source_confirmed",
        "planned_replacement_source_confirmed",
    }
    source_blockers: list[str] = []
    if not provenance_ok:
        source_blockers.append("source_or_hash_record_missing")
    if not runtime_source_ok:
        source_blockers.append("runtime_source_safety_review_required")
    source_ok = not source_blockers
    structural_ok = bool(readiness_item.get("structural_ready")) and Path(output_path).exists()
    editor_card_ok = workbench_present and bool(output_path)

    polish_blockers = [
        blocker for blocker in blockers
        if blocker not in {"license_terms_manual_review", "runtime_catalog_ready_manual_replacement"}
    ]

    gates = {
        "source_traceability": gate(
            "passed" if source_ok else "blocked",
            [
                "docs/assets/asset-provenance-records.json",
                "docs/assets/runtime-source-safety-report.json",
                output_path,
            ],
            source_blockers,
        ),
        "license_terms": gate(
            "blocked" if "license_terms_manual_review" in blockers else "passed",
            [
                "docs/assets/asset-provenance-records.json",
                "docs/assets/final-art-review-queue.json",
            ],
            ["license_terms_manual_review"] if "license_terms_manual_review" in blockers else [],
        ),
        "godot_structural_resource": gate(
            "passed" if structural_ok else "blocked",
            [
                "docs/assets/art-readiness-audit-report.json",
                output_path,
                str(runtime_catalog.get("resource_path", "")),
            ],
            [] if structural_ok else ["structural_resource_missing_or_unready"],
        ),
        "editor_review_card": gate(
            "passed" if editor_card_ok else "blocked",
            [
                "scenes/dev/final_art_review_workbench.tscn",
                "docs/assets/final-art-review-workbench-manifest.json",
            ],
            [] if editor_card_ok else ["editor_review_card_missing"],
        ),
        "runtime_replacement": gate(
            "blocked" if "runtime_catalog_ready_manual_replacement" in blockers else "passed",
            [
                "docs/assets/asset-runtime-integration-map.json",
                "docs/assets/imagegen-runtime-asset-catalog-manifest.json",
            ],
            ["runtime_catalog_ready_manual_replacement"] if "runtime_catalog_ready_manual_replacement" in blockers else [],
        ),
        "family_specific_polish": gate(
            "blocked" if polish_blockers else "passed",
            [
                "docs/assets/art-readiness-audit-report.json",
                "docs/assets/final-art-review-queue.json",
            ],
            polish_blockers,
        ),
    }

    readiness_final_ready = bool(readiness_item.get("final_ready", False))
    upstream_blocked = [name for name in GATE_ORDER if name != "final_approval" and gates[name]["status"] != "passed"]
    approval_blockers: list[str] = []
    if not readiness_final_ready:
        approval_blockers.append("readiness_final_ready_false")
    if upstream_blocked:
        approval_blockers.append("upstream_acceptance_gate_blocked")
    final_ready = not approval_blockers
    gates["final_approval"] = gate(
        "passed" if final_ready else "blocked",
        [
            "docs/assets/art-readiness-audit-report.json",
            "docs/assets/final-art-review-queue.json",
            "docs/assets/runtime-source-safety-report.json",
        ],
        approval_blockers,
    )

    blocked_gate_count = sum(1 for name in GATE_ORDER if gates[name]["status"] != "passed")
    return {
        "asset_id": asset_id,
        "target_kind": review_entry.get("target_kind", readiness_item.get("target_kind", "unknown")),
        "family": review_entry.get("family", "unknown"),
        "priority": review_entry.get("priority", "unknown"),
        "output_path": output_path,
        "readiness_final_ready": readiness_final_ready,
        "final_ready": final_ready,
        "blocked_gate_count": blocked_gate_count,
        "gates": gates,
    }


def summarize(entries: list[dict[str, Any]]) -> dict[str, Any]:
    gate_summary: dict[str, dict[str, int]] = {}
    priority_blocked: dict[str, int] = {}
    family_blocked: dict[str, int] = {}
    for gate_name in GATE_ORDER:
        gate_summary[gate_name] = {"passed": 0, "blocked": 0}
    for entry in entries:
        if entry["blocked_gate_count"] > 0:
            priority = str(entry.get("priority", "unknown"))
            family = str(entry.get("family", "unknown"))
            priority_blocked[priority] = priority_blocked.get(priority, 0) + 1
            family_blocked[family] = family_blocked.get(family, 0) + 1
        for gate_name in GATE_ORDER:
            status = str(entry["gates"][gate_name]["status"])
            gate_summary[gate_name][status] = gate_summary[gate_name].get(status, 0) + 1

    return {
        "asset_count": len(entries),
        "final_ready_count": sum(1 for entry in entries if entry["final_ready"]),
        "blocked_asset_count": sum(1 for entry in entries if entry["blocked_gate_count"] > 0),
        "gate_count": len(GATE_ORDER),
        "gate_summary": gate_summary,
        "blocked_by_priority": dict(sorted(priority_blocked.items())),
        "blocked_by_family": dict(sorted(family_blocked.items())),
    }


def write_markdown(report: dict[str, Any]) -> None:
    summary = report["summary"]
    lines = [
        "# Final Art Acceptance Gates / 最终美术验收门槛",
        "",
        "本文件把最终美术从 `structural_ready` 推进到 `final_ready` 所需的门槛拆成机器可审计清单。",
        "它不是最终批准记录；当前所有未通过项仍需要人工清稿、授权确认、运行时替换或玩法读值复核。",
        "",
        "## Related Character / Creature Model Lock",
        "",
        f"- 机器契约：`{report['model_lock_contract']['path']}`",
        "- `identity_lock_ready` 只证明逐帧语义锚点、跨 sheet 比例与生产绑定的技术身份连续；它不会设置 `final_ready`。",
        "- `identity_review_status` 继续由 Gate26H 真人审美签核；授权与外部发布仍由本文件各资产的 `final_approval / final_ready` 决定。",
        "",
        "## Summary",
        "",
        f"- 资产总数：`{summary['asset_count']}`",
        f"- Final ready：`{summary['final_ready_count']}`",
        f"- 仍有阻塞门槛的资产：`{summary['blocked_asset_count']}`",
        f"- 每个资产验收门槛数：`{summary['gate_count']}`",
        "",
        "## Gate Summary",
        "",
    ]
    for gate_name in GATE_ORDER:
        counts = summary["gate_summary"][gate_name]
        lines.append(
            f"- `{gate_name}` / {GATE_LABELS[gate_name]}: passed `{counts.get('passed', 0)}`, blocked `{counts.get('blocked', 0)}`"
        )
    lines.extend(["", "## Blocked Assets", ""])
    for entry in report["entries"]:
        lines.append(
            f"- [ ] `{entry['priority']}` `{entry['asset_id']}` ({entry['family']} / {entry['target_kind']}) - blocked gates `{entry['blocked_gate_count']}`"
        )
        for gate_name in GATE_ORDER:
            gate_data = entry["gates"][gate_name]
            if gate_data["status"] != "passed":
                lines.append(f"  - `{gate_name}`: {', '.join(gate_data['blockers'])}")
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    readiness = load_json(READINESS_PATH)
    review_queue = load_json(REVIEW_QUEUE_PATH)
    workbench_manifest = load_json(WORKBENCH_MANIFEST_PATH)
    runtime_source_report = load_json(RUNTIME_SOURCE_SAFETY_PATH)
    readiness_items = readiness_by_asset(readiness)
    review_entries = review_by_asset(review_queue)
    runtime_source_items = runtime_source_by_asset(runtime_source_report)
    workbench_present = (
        bool(workbench_manifest.get("scene"))
        and int(workbench_manifest.get("counts", {}).get("entry_count", 0)) == len(review_entries)
    )
    entries = [
        build_entry(
            asset_id,
            readiness_items[asset_id],
            review_entries[asset_id],
            runtime_source_items.get(asset_id, {}),
            workbench_present,
        )
        for asset_id in sorted(review_entries)
    ]
    report = {
        "version": 2,
        "status": "acceptance_gates_ready",
        "boundary": (
            "Acceptance gates are review requirements for moving structural image-gen assets toward final-ready. "
            "Runtime source safety is an upstream gate, so review-required runtime sources cannot remain final-ready. "
            "Passing this report only proves the gates are explicit and auditable; it does not approve final art."
        ),
        "model_lock_contract": {
            "path": MODEL_LOCK_CONTRACT_PATH.as_posix(),
            "technical_identity_gate": "identity_lock_ready",
            "human_identity_gate": "identity_review_status",
            "external_release_gate": "final_ready",
            "boundary": (
                "identity_lock_ready is a technical prerequisite for registered runtime bodies; "
                "it does not approve Gate26H identity art, license terms or final_ready."
            ),
        },
        "gate_order": GATE_ORDER,
        "gate_labels": GATE_LABELS,
        "summary": summarize(entries),
        "entries": entries,
    }
    write_json(OUT_JSON, report)
    write_markdown(report)
    print(
        "Final art acceptance gates built: "
        f"{report['summary']['asset_count']} assets, "
        f"{report['summary']['blocked_asset_count']} blocked assets, "
        f"{report['summary']['final_ready_count']} final-ready assets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
