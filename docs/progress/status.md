# Nano Hunter Status

Last Updated: 2026-05-22

## Current Status

- 当前稳定游戏基线仍是 `main` 上的 Stage16 Alpha Demo 打包候选，包含最小 Demo 壳、Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、Alpha Demo 完成反馈、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与第二轮资产 / 音频需求记录。
- Godot MCP Pro 1.13.1 增量已合并到主线；当前项目保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，并吸收 ping/pong、heartbeat timeout、idle/stale UI 与输入模拟修正。
- 资产生产线治理已合并到主线；`Asset Production Track / 资产生产线` 作为长期并行工作流运行，玩法 Stage 仍先用灰盒 / 占位验证，资产 Batch 同步生成候选，玩法稳定后再清理并接入可运行资产。
- 本次合并刻意排除了 Luna 行走关键帧生成内容：`assets/art/characters/player/luna_walk/`、`docs/progress/logs/2026-05-05.md` 和 `asset-manifest.md` 中对应行不进入本轮远端同步。

## Current Stable Baseline

- `main` 稳定基线：Stage16 Alpha Demo 打包候选已合并，主线验证通过。
- 当前可试玩方向：从教程、战斗原型、回溯门控、首个精英 Boss 原型推进到 Alpha Demo 候选；下一步默认进入 Alpha Demo 试玩反馈、稳定性修正与 Stage17 规划。
- 当前设计约束：后续阶段继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。
- 当前资产方向：围绕 Alpha Demo 候选补强 Luna、Air Dash、Seal Guardian、Stage16 UI / 终局反馈、区域表现、最小 SFX / BGM 和动画参考，不追求完整商业版资产量。

## Recent Status Changes

### 2026-05-22 - 资产生产线治理合并

- 状态：`codex/asset-production-track-governance` 已合并到 `main`，新增资产存储策略、生产路线图、AI 工具分工、manifest 批次字段、接入 checklist 扩展和 `.gitignore` 源文件边界。
- 范围：仅文档治理和忽略规则；不改玩法、场景、脚本、测试、插件启用项或 Godot 运行时资产引用。
- 排除：Luna 行走关键帧生成素材与日志仍保留为本地未提交内容，本轮不合并。
- 验证：`git diff --check` 通过；完整推送前验证以 `docs/progress/logs/2026-05-22.md` 为准。

### 2026-05-13 - Godot MCP Pro 1.13.1 增量合并

- 状态：在 `codex/upgrade-godot-mcp-1-13-1-increments` 上确认 1.13.1 原包会退回旧端口模型并删除本地 rendezvous / handshake，因此只吸收 ping/pong、heartbeat timeout、idle/stale UI 与输入 `unhandled=false` 修正。
- 验证：外部 Node server `npm test` / `npm run build`、补丁脚本 dry-run、MCP 诊断脚本、入口脚本 dry-run、Godot import 和 `git diff --check` 通过。
- 详情：`docs/progress/logs/2026-05-13.md`。

### 2026-05-01 - Godot MCP 端口迁移与 rendezvous 根治

- 状态：在 `codex/fix-godot-mcp-bridge-lifecycle` 上实现新主端口段、项目本地 rendezvous、`godot_hello_ack`、脚本诊断同步和补丁源重放更新。
- 原因：本机 TCP 动态端口池为 `1024-15000`，旧 `6505-6534` 已观察到被 Foxmail、verge-mihomo 等网络软件占用。
- 验证：外部 Node server `npm test` / `npm run build`、Godot import、诊断脚本 dry-run、补丁脚本 dry-run、rendezvous smoke test 和 `git diff --check` 已通过。
- 详情：`docs/progress/logs/2026-05-01.md`。

## Current Risks

- Batch 00-05 当前是资产需求与治理记录，不代表资产已生成或接入。
- AI 生成工具、音乐工具和视频工具的授权条款可能随账号计划变化；每批资产接入前必须记录工具、prompt、来源和授权状态。
- 原始 AI 候选、失败稿、参考图、源文件和授权截图默认不进入普通 Git；误提交会膨胀仓库并增加授权噪音。
- Godot MCP Pro 的端口迁移与 rendezvous 根治已通过静态、构建、脚本和 smoke 验证；当前会话若要实测 Godot MCP 直连新 rendezvous，需要从本 worktree 重开 IDE / CLI 会话加载新 server。
- MCP 运行态截图和一次性复核证据默认保留在 `tests/artifacts/local/`，不进入提交。

## Next Steps

- 推送主线后，按 `docs/assets/asset-production-roadmap.md` 从 Batch 00 / Batch 01 开始生成候选资产。
- 真正接入资产时，运行 `godot --headless --path . --import`，并按影响范围执行对应 GUT 或人工复核。
- 若继续处理 Luna 行走关键帧素材，应单独提交或单独保留，不混入资产治理合并。

## References

- 资产存储策略：`docs/assets/asset-storage-policy.md`
- 资产生产路线图：`docs/assets/asset-production-roadmap.md`
- 资产生成 brief：`docs/assets/asset-generation-brief.md`
- 资产清单：`docs/assets/asset-manifest.md`
- 资产接入 checklist：`docs/assets/asset-ingestion-checklist.md`
- Godot MCP 排障入口：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- Stage16 Alpha Demo QA checklist：`docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md`
- Stage16 Alpha Demo release notes：`docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`
- 当日日志：`docs/progress/logs/2026-05-22.md`
- 关键时间线：`docs/progress/timeline.md`
