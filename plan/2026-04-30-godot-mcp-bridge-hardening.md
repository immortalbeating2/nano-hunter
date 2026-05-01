# Godot MCP Bridge Hardening Formal Plan

## Summary

本阶段修复 Godot MCP Pro 在多 Codex 会话、多 worktree 与旧 bridge 残留时的反复断连问题。核心改动为：Node MCP Server 支持 stdio 端口 fallback、lock/heartbeat、lazy reconnect、workspace handshake 和 `get_bridge_status`；Godot 插件端扩展扫描范围并发送项目身份；项目脚本按 lock、PID、端口和 Godot 编辑器归属精确诊断 / 清理；仓库新增补丁脚本与补丁源，保证用户目录中的 Node server 更新后可重放。

## Goals

- 旧 `6505` bridge 残留时，新 stdio 会话可自动落到 `6506-6509` 或 `6515-6534`。
- `6510-6514` 保留给 `godot-cli`，不被 stdio bridge 自动占用或清理。
- 已加载 MCP 工具入口的 Codex 会话在端口清出后可 lazy reconnect。
- 脚本能区分 active bridge、stale bridge、CLI 临时进程和其它 workspace bridge。
- 项目外 Node server 改动具备仓库内补丁源、补丁脚本、备份与回滚说明。

## Non-Goals

- 不修改玩法、场景、资产、主流程 UI 或 GUT 游戏测试内容。
- 不解决 Codex 会话未加载 MCP 工具入口的问题；该问题仍需从目标 worktree 重开会话。
- 不把运行态 autoload 注入问题与 bridge 生命周期问题合并处理。

## Stage Boundary / Preflight

- 开发分支：`codex/fix-godot-mcp-bridge-lifecycle`。
- 预检命令：`.\scripts\dev\check-godot-mcp.ps1`。
- `.codex/config.toml` 不再固定 `GODOT_MCP_PORT=6505`。
- Node server 路径：`C:/Users/peng8/.mcp/godot-mcp-pro/server`。

## Key Changes

- Node MCP Server：候选端口为 `6505-6509,6515-6534`，跳过 `6510-6514`；新增 bridge lock、diagnostic tool、workspace handshake、lazy reconnect 与退出清理。
- Godot 插件端：扫描 `6505-6534`，连接后发送 `godot_hello`，状态面板标注 stdio / CLI reserved / stdio overflow。
- 项目脚本：统一端口分组，读取 lock/heartbeat，`safe-repair` 默认不清 CLI，不清其它 workspace。
- 补丁体系：新增 `scripts/dev/apply-godot-mcp-pro-hardening-patch.ps1` 与 `tools/godot-mcp-pro-hardening/patch-files/`。

## Public Interfaces

- 新环境变量：`GODOT_MCP_PORT`、`GODOT_MCP_STRICT_PORT`、`GODOT_MCP_BASE_PORT`、`GODOT_MCP_MAX_PORT`、`GODOT_MCP_RESERVED_PORTS`、`GODOT_MCP_WORKSPACE`、`GODOT_MCP_SESSION_ID`。
- 新 MCP tool：`get_bridge_status`。
- 新 Godot -> Node notification：`godot_hello`，参数 `workspace`。

## Test Plan

- Node：`npm test`、`npm run build`。
- Godot：`godot --headless --path . --import`。
- 脚本：`.\scripts\dev\check-godot-mcp.ps1`、`.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun`、`.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun`。
- 手动复核：多 worktree 会话分配不同 stdio 端口，`godot-cli` 仍使用 `6510-6514`，旧 bridge 占满 primary 后新会话落到 overflow。

## Manual Review / Runtime Review

- 状态面板展示 `6505-6534` 并标注 CLI reserved。
- `get_bridge_status` 返回当前 workspace、sessionId、候选端口、reserved 端口、lock 路径与连接状态。
- `check-godot-mcp.ps1` 能展示 stdio bridge、CLI process、lock 和 stale reason。

## Documentation Updates

- 更新 `docs/dev/godot-mcp-pro-connectivity-guide.md`。
- 新增 `docs/implementation-plans/2026-04-30-godot-mcp-bridge-hardening.md`。
- 更新 `docs/progress/logs/2026-04-30.md` 和必要的 timeline。

## Exit Criteria

- stdio bridge 不占用 `6510-6514`。
- 旧 bridge 占满 `6505-6509` 时，新 stdio 会话能落到 `6515-6534`。
- 清理 stale bridge 后，当前已加载 MCP 工具入口的会话可 lazy reconnect。
- 补丁脚本可 dry-run、备份、应用、构建，并能追溯项目外 Node server 改动。

## Risks

- 上游插件大版本重构时，补丁源可能需要人工重审。
- 端口扩容只能降低耗尽概率，跨项目防串线仍依赖 workspace handshake。
- 用户目录 Node server 不受仓库直接保护，必须依赖补丁脚本重放。
- 2026-04-30 人工复核确认：workspace handshake 与端口扩容不能替代 session/port rendezvous；在 rendezvous 完成前，旧低端口 bridge 仍可能被 Godot 插件优先连接。

## Assumptions

- Godot MCP Pro 当前验证版本为 `1.12.0`。
- heartbeat stale 阈值默认为 `30` 秒。
- 当前方案优先服务 Windows / Codex Desktop / Nano Hunter 环境。

## Follow-up Generalization

- 补丁脚本升级为可搬移、可跨项目使用的通用工具；`nano-hunter` 只是当前托管和验证位置。
- 新增 `-Scope ServerOnly|PluginOnly|ServerAndPlugin|All`，默认 `ServerAndPlugin`。
- 新增 `-PatchRoot` 和自动查找规则，脚本与 `patch-files` 一起搬到独立目录后仍可使用。
- 项目诊断脚本从默认补丁目标中移出，只有显式 `-IncludeProjectScripts` 时才覆盖目标项目 `scripts/dev`。
- 补丁源目录语义调整为 `server`、`plugin`、`optional-project-scripts`，避免把插件补丁误解成整项目补丁。
- `docs/dev/godot-mcp-pro-connectivity-guide.md` 与脚本 README 必须以该通用语义为准。

## Post-review Correction

- 本正式计划记录的是 Godot MCP bridge lifecycle hardening，不应再被描述为完整根治。
- 真正根治多 IDE / CLI / worktree 串线，需要另起 session/port rendezvous 计划：当前会话 bridge 写出 `port/sessionId/workspace`，Godot 插件优先连接指定端口，Node server 以 `workspace + sessionId` 验证连接。

## Final Root-Cause Update: Port Migration And Rendezvous

- stdio 主端口从旧 `6505-6509,6515-6534` 改为 `17605-17619`；旧 `6505-6509` 仅为 legacy fallback。
- `godot-cli` 主端口从旧 `6510-6514` 改为 `17620-17624`；旧 `6510-6514` 仅为 legacy fallback。
- 迁移原因：本机 TCP 动态端口池为 `1024-15000`，旧 `6505-6534` 容易被 Foxmail、verge-mihomo 等通用网络软件占用。
- Node server 写入 `<workspace>/.godot/godot-mcp-pro/current-bridge.json`，Godot 插件优先读取该 rendezvous 文件，再做端口 fallback。
- `godot_hello` 握手扩展为 `workspace + sessionId + connectionSource`，Node 返回 `godot_hello_ack`；这才是防止跨 IDE / CLI / worktree 串线的根治边界。
