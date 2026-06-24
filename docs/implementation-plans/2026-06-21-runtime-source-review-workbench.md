# Runtime Source Review Workbench

## Summary

本计划把 `runtime-source-review-queue` 转成 Godot 编辑器可打开的可视化审图工作台。它集中展示剩余 `15` 个 runtime source review-required 资产的当前运行时输出和全部候选 PNG，辅助后续人工确认来源、比较候选质量或决定重新 image gen。

## Scope

- 新增 `scripts/dev/build_runtime_source_review_workbench.gd`。
- 新增 `scripts/dev/audit_runtime_source_review_workbench.gd`。
- 新增 `scenes/dev/runtime_source_review_workbench.tscn`。
- 新增 `docs/assets/runtime-source-review-workbench-manifest.json`。
- 更新 `scripts/assets/audit_asset_package.py`，让综合资产包审计校验该 workbench。

## Non-Goals

- 不新增 image gen PNG。
- 不替换 selected sources。
- 不改变运行时场景引用。
- 不把 review-required 候选升级为 confirmed 或 final-ready。

## Verification

```powershell
godot --headless --path . --script res://scripts/dev/build_runtime_source_review_workbench.gd
godot --headless --path . --script res://scripts/dev/audit_runtime_source_review_workbench.gd
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Current Result

- Runtime source review workbench：`15` assets、`15` current outputs、`34` candidates。
- Selected candidate previews：`23`。
- Strategy counts：`8` manual compare selected mix、`7` manual source review or regenerate。
- Asset package audit：通过，并记录 `34 runtime source workbench candidates`。

## Next Step

打开 `scenes/dev/runtime_source_review_workbench.tscn`，逐项比较当前输出、selected candidates 和 unselected candidates。对于 `manual_source_review_or_regenerate` 的 7 个资产，优先按 `docs/assets/runtime-source-regeneration-packet.md` 重新 image gen。
