# Nano Hunter Status

Last Updated: 2026-05-14

## Current Status

- 当前稳定游戏基线仍是 `main` 上的 Stage16 Alpha Demo 打包候选，包含最小 Demo 壳、Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、Alpha Demo 完成反馈、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与第二轮资产 / 音频需求记录。
- 当前开发现场为 `codex/asset-production-track-governance`，工作目录是 `C:\Users\peng8\.codex\worktrees\3073\nano-hunter`；本分支只做资产生产线治理、批次路线图、存储策略和文档同步，不改玩法、场景、脚本或 Godot 插件启用状态。
- 资产生产线定位为长期并行的 `Asset Production Track / 资产生产线`：玩法 Stage 仍先用灰盒 / 占位验证，资产 Batch 同步生成候选，玩法稳定后再清理并接入可运行资产。

## Current Stable Baseline

- `main` 稳定基线：Stage16 Alpha Demo 打包候选已合并，主线验证通过。
- 当前可试玩方向：从教程、战斗原型、回溯门控、首个精英 Boss 原型推进到 Alpha Demo 候选；下一步默认进入 Alpha Demo 试玩反馈、稳定性修正与 Stage17 规划。
- 当前资产方向：围绕 Alpha Demo 候选补强 Luna、Air Dash、Seal Guardian、Stage16 UI / 终局反馈、区域表现、最小 SFX / BGM 和动画参考，不追求完整商业版资产量。

## Latest Validation

- 最近稳定主线验证仍沿用 2026-04-29 Stage16 合并验证：Godot import、Stage16 专项 GUT `8/8`、Stage15 专项 GUT `11/11`、全量 GUT `115/115`、`git diff --check HEAD` 通过。
- 当前资产治理分支尚未接入新运行时资产；需要完成文档检查、`git diff --check` 和资产文档空字段扫描后再提交。

## Current Risks

- Batch 00-05 当前是资产需求与治理记录，不代表资产已生成或接入。
- AI 生成工具、音乐工具和视频工具的授权条款可能随账号计划变化；每批资产接入前必须记录工具、prompt、来源和授权状态。
- 原始 AI 候选、失败稿、参考图、源文件和授权截图默认不进入普通 Git；误提交会膨胀仓库并增加授权噪音。

## Next Steps

- 完成资产治理文档验证并提交 `codex/asset-production-track-governance`。
- 按 `docs/assets/asset-production-roadmap.md` 从 Batch 00 / Batch 01 开始生成候选资产。
- 真正接入资产时，运行 `godot --headless --path . --import`，并按影响范围执行对应 GUT 或人工复核。

## References

- 资产存储策略：`docs/assets/asset-storage-policy.md`
- 资产生产路线图：`docs/assets/asset-production-roadmap.md`
- 资产生成 brief：`docs/assets/asset-generation-brief.md`
- 资产清单：`docs/assets/asset-manifest.md`
- 资产接入 checklist：`docs/assets/asset-ingestion-checklist.md`
- Stage16 Alpha Demo QA checklist：`docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md`
- Stage16 Alpha Demo release notes：`docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`
- 当日日志：`docs/progress/logs/2026-05-14.md`
- 关键时间线：`docs/progress/timeline.md`
