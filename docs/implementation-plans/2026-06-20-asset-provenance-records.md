# Asset Provenance Records Implementation Plan

Date: 2026-06-20

## Summary

为当前 `55` 个 image gen 资产建立来源、prompt、候选 PNG hash 和输出 PNG hash 的机器可审计记录。该层用于把资产从“只有文件存在”推进到“来源可追踪”，但不替代法律条款复核、最终美术审批或运行时接入。

## Goals

- 为每个 queue item 记录 image gen prompt 和 `prompt_sha256`。
- 为每个 raw candidate 记录路径、尺寸、mode 和 sha256。
- 为每个 `assets/art` 输出记录 sha256。
- 在 readiness 报告中把 `license_record_pending` 推进为 `license_terms_manual_review`。
- 将 provenance 纳入综合资产包审计。

## Non-Goals

- 不声称商业发布授权已经完成。
- 不修改 image gen prompt queue。
- 不改变 raw candidates、selected sources 或 `assets/art` 图像内容。
- 不替换运行时引用。

## Key Changes

- 新增 `scripts/assets/build_asset_provenance.py`。
- 新增 `scripts/assets/audit_asset_provenance.py`。
- 生成 `docs/assets/asset-provenance-records.json`。
- 扩展 `scripts/assets/audit_art_readiness.py`，读取 provenance 并更新 license blocker。
- 扩展 `scripts/assets/audit_asset_package.py`，校验 provenance record / candidate hash / output hash 数量。

## Validation

```powershell
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
```

当前结果：

- `Asset provenance records built: 55 records, 101 candidate hashes, 55 output hashes.`
- `Asset provenance OK: 55 records, 101 candidate hashes, 55 output hashes.`
- `Art readiness audit OK: 55/55 structural ready, 0/55 final ready.`
- `Asset package audit OK`，并记录 `55 provenance records`。

## Exit Criteria

- 每个 queue item 有 provenance record。
- 每个 record 有 prompt hash、output hash 和 candidate hash。
- candidate hash 数量与候选池报告一致。
- readiness 报告不再出现 `license_record_pending`，而是保留 `license_terms_manual_review`。
- 综合资产包审计通过。

## Risks / Follow-Up

- 当前只完成来源追踪，不完成商业条款确认。
- 后续对外发布、商店页、商业 demo 或第三方分发前，仍需按实际 image gen 工具账号和平台条款人工复核。
- 如后续替换候选或重导出资产，必须重跑 provenance build / audit。
