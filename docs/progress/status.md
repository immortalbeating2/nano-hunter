# Nano Hunter Status

Last Updated: 2026-05-13

## Current Status

- 当前稳定游戏基线仍是 `main` 上的 Stage16 Alpha Demo 打包候选，包含最小 Demo 壳、Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、Alpha Demo 完成反馈、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与第二轮资产 / 音频需求记录。
- 当前开发现场为工具链增量升级分支 `codex/upgrade-godot-mcp-1-13-1-increments`；本分支只吸收 Godot MCP Pro 1.13.1 的连接心跳、idle/stale UI 和输入模拟修正，不改玩法、场景、资产或主流程内容。
- Godot MCP bridge lifecycle hardening 仍以端口迁移与 session/port rendezvous 根治为主：stdio 主端口为 `17605-17619`，CLI 主端口为 `17620-17624`，Node server 会写入项目本地 `.godot/godot-mcp-pro/current-bridge.json`，Godot 插件优先按 rendezvous 连接当前会话。
- 当前 worktree 存在 `project.godot` 的临时 MCP runtime autoload diff；该 diff 属于运行态复核现场，提交文档或工具链修复前必须单独确认是否清理，不应混入文档治理提交。

## Current Stable Baseline

- `main` 稳定基线：Stage16 Alpha Demo 打包候选已合并，主线验证通过。
- 当前可试玩方向：从教程、战斗原型、回溯门控、首个精英 Boss 原型推进到 Alpha Demo 候选；下一步默认进入 Alpha Demo 试玩反馈、稳定性修正与 Stage17 规划。
- 当前设计约束：后续阶段继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。

## Recent Status Changes

### 2026-05-13 - Godot MCP Pro 1.13.1 增量合并

- 状态：在 `codex/upgrade-godot-mcp-1-13-1-increments` 上确认 1.13.1 原包会退回旧端口模型并删除本地 rendezvous / handshake，因此只吸收 ping/pong、heartbeat timeout、idle/stale UI 与输入 `unhandled=false` 修正。
- 验证：外部 Node server `npm test` / `npm run build`、补丁脚本 dry-run、MCP 诊断脚本、入口脚本 dry-run、Godot import 和 `git diff --check` 通过。
- 详情：`docs/progress/logs/2026-05-13.md`。

### 2026-05-01 - Godot MCP 端口迁移与 rendezvous 根治

- 状态：在 `codex/fix-godot-mcp-bridge-lifecycle` 上实现新主端口段、项目本地 rendezvous、`godot_hello_ack`、脚本诊断同步和补丁源重放更新。
- 原因：本机 TCP 动态端口池为 `1024-15000`，旧 `6505-6534` 已观察到被 Foxmail、verge-mihomo 等网络软件占用。
- 验证：外部 Node server `npm test` / `npm run build`、Godot import、诊断脚本 dry-run、补丁脚本 dry-run、rendezvous smoke test 和 `git diff --check` 已通过。
- 详情：`docs/progress/logs/2026-05-01.md`。

### 2026-04-30 - Godot MCP hardening 复核修正

- 状态：`ddaad7d` 与 `fd7638f` 完成的是 bridge lifecycle hardening 和通用补丁工具，不等于完整根治。
- 证据：当前会话能看到 Godot MCP 工具入口，但 MCP 只读工具返回 Godot editor 未连接；当前 worktree Godot editor 曾连到旧 `6505` bridge，而新的候选 bridge 未被 editor 选中。
- 结论：后续应新增 session/port rendezvous 计划，让插件优先连接当前会话指定 bridge，并用 `workspace + sessionId` 完成握手。
- 详情：`docs/progress/logs/2026-04-30.md`。

### 2026-04-30 - Godot MCP 文档入口收敛

- 状态：提交 `a41ea03` 将 Godot MCP 工具入口、端口规划、脚本速查、补丁工具和排障流程合并进 `docs/dev/godot-mcp-pro-connectivity-guide.md`。
- 结论：`AGENTS.md` 只保留项目级原则和单一入口指针，不再展开具体排障流程。
- 详情：`docs/progress/logs/2026-04-30.md`。

### 2026-04-30 - 通用补丁工具

- 状态：提交 `fd7638f` 将 Godot MCP hardening 补丁脚本改为可搬移、可跨项目使用，默认只覆盖全局 Node server 与目标项目 `addons/godot_mcp`。
- 验证：补丁脚本 dry-run 矩阵、外部 Node server `npm test` / `npm run build`、Godot import、诊断脚本 dry-run 和乱码扫描通过。
- 详情：`docs/progress/logs/2026-04-30.md`。

## Current Risks

- Godot MCP Pro 的端口迁移与 rendezvous 根治已通过静态、构建、脚本和 smoke 验证；当前会话若要实测 `mcp__godot_mcp_pro__` 直连新 rendezvous，需要从本 worktree 重开 IDE / CLI 会话加载新 server。
- Codex / Claude Code / opencode 等客户端的工具入口命名不同；不能把 `mcp__godot_mcp_pro__` 视为跨客户端标准，只能作为 Codex Desktop 当前常见前缀。
- MCP 运行态截图和一次性复核证据默认保留在 `tests/artifacts/local/`，不进入提交。
- 若工作树存在 MCP 临时 autoload diff，继续运行态复核前可保留；提交非 MCP 运行态改动前必须明确清理或说明。

## Next Steps

- 从本 worktree 重开 IDE / CLI 会话后，打开本 worktree Godot editor，实测当前会话工具是否通过 rendezvous 连接到 `17605-17619`。
- 若只做文档治理提交，避免纳入当前 `project.godot` 临时 MCP autoload diff。

## References

- Godot MCP 排障入口：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- Stage16 Alpha Demo QA checklist：`docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md`
- Stage16 Alpha Demo release notes：`docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`
- Godot MCP hardening 实现清单：`docs/implementation-plans/2026-04-30-godot-mcp-bridge-hardening.md`
- Godot MCP hardening 正式计划：`plan/2026-04-30-godot-mcp-bridge-hardening.md`
- 当日日志：`docs/progress/logs/2026-04-30.md`
- 关键时间线：`docs/progress/timeline.md`
