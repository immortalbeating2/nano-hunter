# Project Asset Isolation Audit / 项目资产隔离审计

## Summary

针对多项目并行开发时可能误用其它项目 image_gen 输出的问题，新增项目资产隔离审计层。该层只检查资产记录、资产文档和资产脚本中是否出现已知其它项目标识、外项目绝对路径或非 `nano-hunter` 的 `project_key`。

## Scope

- 新增 `scripts/assets/audit_project_asset_isolation.py`。
- 生成 `docs/assets/project-asset-isolation-report.json`。
- 生成 `docs/assets/project-asset-isolation-report.md`。
- 扩展 `scripts/assets/audit_asset_package.py`，让综合资产包审计同步检查隔离报告。

## Non-Goals

- 不生成新 PNG。
- 不替换 `assets/art/` 输出。
- 不把 `review-required` 来源升级为 confirmed。
- 不判断美术质量、授权条款、final-ready 或运行时 polish。

## Rules

- 允许记录 `Documents/Codex/tools/imagegen-export` 这类导出脚本路径。
- 允许记录包含 `nano-hunter` 的历史或当前本地路径。
- 允许文档中说明全局 `.codex/generated_images` 和 `.codex/sessions` 风险，但不能把它们当作无需复核的项目专属来源。
- 不允许资产记录、资产文档或资产脚本里出现已知其它项目标识作为来源。
- JSON 中出现 `project_key` 时必须为 `nano-hunter`。

## Verification

```powershell
python scripts\assets\audit_project_asset_isolation.py --write-report --strict
python scripts\assets\audit_asset_package.py --write-report --strict
git diff --check
```

## Exit Criteria

- Project asset isolation 输出 `0 forbidden markers, 0 outside paths, 0 project_key errors`。
- 综合资产包审计纳入 `project_asset_isolation`，并在 strict 模式下通过。
- 资产矩阵、production backlog、status 和当日日志记录该门槛与边界。

## Current Result

- `scripts/assets/audit_project_asset_isolation.py --write-report --strict` 已通过：`1918 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`。
- 该结果证明当前已扫描资产记录中未发现已知外项目污染证据；不证明 `15` 个 runtime review-required 来源已经人工确认，也不改变 `0/55 final_ready`。
