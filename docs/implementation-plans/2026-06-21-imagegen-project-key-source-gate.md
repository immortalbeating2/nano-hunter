# ImageGen Project Key Source Gate

## Summary

为多项目并行开发补一道 Nano Hunter 专属来源门禁：所有 image_gen 候选、provenance 记录和 source-safety 报告必须显式带有 `project_key = nano-hunter`，否则严格审计失败。

## Scope

- 更新 `scripts/assets/build_asset_provenance.py`，让新生成的 provenance 顶层与每条记录都写入 `project_key` 和 `project_name`。
- 更新 `scripts/assets/audit_asset_provenance.py`，在 strict 审计中强制检查项目键。
- 更新 `scripts/assets/audit_imagegen_source_safety.py`，在 source-safety 报告和审计中强制检查项目键。
- 更新 `scripts/assets/export_standalone_candidates.py`，让 standalone `.source.json` 也写入 `project_key` 和 `project_name`。
- 更新 `scripts/assets/audit_imagegen_candidate_pool.py`，让 standalone `.source.json` 缺少项目键时 strict 审计失败。
- 重建 `docs/assets/asset-provenance-records.json` 与 `docs/assets/imagegen-source-safety-report.json`。
- 更新 `docs/assets/asset-storage-policy.md`，把多项目来源门禁写成资产存储规则。

## Non-Goals

- 不新增或替换任何游戏内美术资产。
- 不把 `review_required` 候选升级为最终资产。
- 不改变当前 P0 runtime replacement 计划的资产优先级。

## Validation

```powershell
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_imagegen_candidate_pool.py --write-report --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_runtime_source_safety.py --write-report
python scripts\assets\audit_asset_package.py --write-report --strict
git diff --check
```

## Exit Criteria

- `asset-provenance-records.json` 顶层和 55 条记录均包含 `project_key = nano-hunter`。
- `imagegen-source-safety-report.json` 顶层包含 `project_key = nano-hunter`。
- standalone `.source.json` 均包含 `project_key = nano-hunter` 与 `project_name = Nano Hunter`。
- 严格来源审计当前保持 `105 candidates, 35 project-session confirmed, 30 ledger review-required, 40 provenance review-required, 0 unsafe`。
- runtime source safety 当前保持 `28 runtime assets, 16 review-required, 0 unsafe`。
- 后续资产接入只默认使用 `project_session_confirmed` 候选；其它候选必须保留人工复核边界。
