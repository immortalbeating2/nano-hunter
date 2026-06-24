# Runtime Source Review Queue

## Summary

本计划记录剩余 runtime source review-required 资产的集中复核队列。当前目标不是继续机械重建图集，而是把剩余 `15` 个运行时来源复核项拆成可执行分类，避免为了降低数字而回退到 duplicate 补位或质量更弱的候选。

## Scope

- 新增 `scripts/assets/build_runtime_source_review_queue.py`。
- 新增 `docs/assets/runtime-source-review-queue.json`。
- 新增 `docs/assets/runtime-source-review-queue.md`。
- 更新 `scripts/assets/audit_asset_package.py`，让综合资产包审计校验 runtime source safety 和 runtime source review queue。

## Non-Goals

- 不新增 image gen PNG。
- 不把 review-required 候选自动升级为 confirmed。
- 不自动重建剩余 15 个 runtime assets。
- 不改变场景、HUD、Boss、玩家或 VFX 的运行时引用。

## Current Classification

- `manual_compare_selected_mix`: `8`
  - 当前 selected sources 同时使用 `project_session_confirmed` 和 review-required 候选。
  - 代表资产：Luna run / air dash / attack / idle、Seal Guardian boss sheet、core icon sheet、menu ninepatch、seal magic VFX。
  - 下一步：人工比较现有 selected sources 与确认候选；如果 confirmed-only dry-run 需要 duplicate 补位，不自动回退。
- `manual_source_review_or_regenerate`: `7`
  - 当前运行时来源只来自 review-required 候选。
  - 代表资产：Stage16 menu icons、talisman relay、Alpha Demo completion、pause / completion panels、Boss HUD frame、ability status HUD。
  - 下一步：人工确认来源，或使用 image gen 重新生成 Nano Hunter 专属候选，再执行 standalone 导出 / atlas rebuild / Godot import / runtime source safety。

## Verification

```powershell
python -m py_compile scripts\assets\build_runtime_source_review_queue.py scripts\assets\audit_asset_package.py
python scripts\assets\build_runtime_source_review_queue.py
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Current Result

- Runtime source review queue：`15` review-required assets，`0` unsafe。
- Strategy counts：`8` manual compare selected mix，`7` manual source review or regenerate。
- Asset package audit：通过，并记录 `15 runtime source review-required assets` 与 `15 runtime source review queue entries`。

## Risks

- 这些资产仍不能称为 final-ready。
- 当前续跑环境没有内置 `image_gen` 工具入口，无法在本轮直接重生 PNG。
- 后续如果恢复 image gen 工具，应优先为 `manual_source_review_or_regenerate` 的 7 个 runtime UI / VFX 资产重生 Nano Hunter 专属候选。
