# Final Asset Disposition Cleanup Implementation Plan

> **执行日期：** 2026-07-12  
> **关联阶段：** Stage 17 动作运行态稳定化后的资产收口  
> **状态：** 完成

## 目标

移除正式场景中仅用于历史接入计数的隐藏 `Preview` 节点，使运行接入报告只反映真实可见或真实播放的资产；随后统一重算来源安全、运行接入和最终验收门禁。只有在旧资产达到零正式引用，并且 Godot import 与相关 GUT 通过后，才删除旧 SVG 占位资产及其导入元数据。

## 实现原则

- `scenes/dev/` 的资产画廊和工作台属于开发工具，不纳入正式场景 Preview 清理。
- 正式场景中隐藏的 `*Preview*` 节点直接删除；实际可见且承担玩法表达的节点只去掉误导性的 `Preview` 命名，不删除视觉。
- 资产目录不做按文件名或时间批量清理，只处理本清单明确列出的退役资产。
- 运行接入、来源安全和最终门禁必须由同一轮新鲜报告得出；不继续依赖与当前场景状态不一致的旧 JSON。
- 删除旧资产前必须同时满足：正式场景零引用、代码与测试零引用、Godot import 通过、相关 GUT 通过。

## 执行清单

- [x] 新增正式场景 Preview 与退役资产回归测试，并确认测试在清理前失败。
- [x] 删除正式场景中的隐藏 Preview 节点，重命名仍承担运行职责的可见节点。
- [x] 清理玩家、敌人、Boss、HUD、房间测试和开发复核脚本中的旧 Preview 契约。
- [x] 重建 asset runtime map、P0 replacement plan、art readiness、review queue、source safety 与 final acceptance gates。
- [x] 确认 14 个旧 SVG 及其 `.import` 在正式场景、脚本、测试和资源中均无引用。
- [x] 运行 Godot import 与最接近的 Stage 12-17 / Demo GUT。
- [x] 在上述门禁通过后删除 14 个旧 SVG 及其 `.import`。
- [x] 再次运行零引用检查、Godot import、相关 GUT、资产 strict audits 与 `git diff --check`。
- [x] 更新最终处置清单、`docs/progress/status.md` 和 2026-07-12 开发日志。

## 验证命令

```powershell
godot --headless --path . --import --quit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
python scripts/assets/build_asset_runtime_map.py
python scripts/assets/audit_asset_runtime_map.py --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/audit_runtime_source_safety.py --write-report --strict
python scripts/assets/audit_final_art_acceptance_gates.py --strict
python scripts/assets/audit_asset_package.py --write-report --strict
git diff --check
```

最终使用项目现有 GUT 入口补跑受影响的 Stage 12-16、Demo 与全量回归；具体命令以仓库脚本和当次运行结果为准。

## 完成摘要

- 正式场景 `Preview` 节点由 `52` 收敛为 `0`：删除 `50` 个隐藏节点，重命名 `2` 个真实运行节点。
- 删除 `14` 个退役 SVG 与 `14` 个 `.import`；删除前后 import 和 GUT 门禁均执行。
- runtime map 为 `55` 项，处置为 `26 runtime_keep / 20 source_dev_keep / 9 archive_keep`；P0 计划收敛为 `11` 项。
- P0 rehearsal / target matrix / batches 已从当前计划动态重建为 `11` 节点、`12` 场景 / `23` 引用、`6` 批。
- runtime source safety 为 `11` 项、`0` review-required、`0` unsafe；final acceptance 为 `55/55 final-ready`。
- 最终验证与边界详见 `docs/assets/2026-07-12-final-asset-disposition.md` 和 `docs/progress/logs/2026-07-12.md`。
