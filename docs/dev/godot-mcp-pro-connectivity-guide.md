# Godot MCP Pro Connectivity Guide

本文件是 Nano Hunter 的 Godot MCP Pro 唯一权威入口，覆盖客户端工具入口、端口规划、bridge / editor / runtime autoload 分层排障、脚本使用、补丁重放、跨项目使用和阶段收口。`AGENTS.md` 只保留原则和指针，具体流程以本文为准。

## Core Rules

- 不把所有 Godot MCP 问题都归因到 bridge。
- 先判断当前 IDE / CLI 是否已加载 Godot MCP Pro 工具入口，再判断 bridge 和 Godot editor。
- Codex Desktop 当前常见工具前缀是 `mcp__godot_mcp_pro__`；其它 IDE / CLI 的命名可能不同，不能把该前缀当作跨客户端标准。
- stdio bridge 端口为 `6505-6509,6515-6534`；`6510-6514` 保留给 `godot-cli`，不得按 stale bridge 默认清理。
- Godot 插件扫描 `6505-6534`，连接后发送 `godot_hello`；Node bridge 只接受 workspace 匹配的 Godot editor。
- runtime autoload 失败不按 bridge stale 处理。
- 清理 bridge 前必须确认不会影响其它活跃项目 / worktree 会话。

## Client Tool Entry

Godot MCP 复核需要当前客户端已经加载 Godot MCP Pro server 暴露的工具。不同客户端展示方式不同：

- Codex Desktop 当前配置下通常能看到 `mcp__godot_mcp_pro__` 前缀工具。
- 其它 IDE / CLI 可能使用不同工具名、不同 namespace，或只在工具面板中显示 server 能力。
- 判断标准是“当前客户端是否已加载 Godot MCP Pro 工具”，不是固定字符串。

如果工具入口缺失：

1. 确认当前物理目录是目标 worktree。
2. 从该 worktree 重新打开客户端会话。
3. 新会话先运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun`。

普通 PowerShell 脚本无法让已经启动的客户端会话热加载 MCP 工具。

## Port Plan

| Port Range | Role | Cleanup Rule |
| --- | --- | --- |
| `6505-6509` | stdio MCP primary | 可作为 stdio bridge 诊断对象 |
| `6510-6514` | `godot-cli` reserved | 不按 stale bridge 清理 |
| `6515-6534` | stdio MCP overflow | 可作为 stdio bridge 诊断对象 |

Node stdio server 会跳过 `6510-6514`。`GODOT_MCP_PORT` 只是 preferred port；只有 `GODOT_MCP_STRICT_PORT=1` 才严格固定。当前 server 支持 lazy reconnect：清出端口后，已加载 MCP 工具入口的会话可在下次命令前重新尝试监听。

Bridge lock 位于：

```text
%LOCALAPPDATA%/godot-mcp-pro/bridges/<port>.json
```

lock/heartbeat 是辅助证据，不是唯一真相。stale 判断必须结合 PID、TCP 连接、workspace、heartbeat age 和 Godot editor 归属。

## Daily Workflow

日常优先运行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
```

它会输出推荐动作：

- `AlreadyConnected`：当前 workspace editor 已连接 stdio bridge；先用只读 MCP 工具实测。
- `SafeOpenEditor`：已有 stdio bridge，但当前 workspace 没开 Godot editor；可打开当前 worktree Godot。
- `SafeReopenEditor`：当前 workspace editor 已开但没连 stdio bridge；优先重开当前 worktree Godot。
- `ReopenSessionThenCleanStaleBridge`：只有 stale stdio bridge；确认无其它会话后再清理。
- `InspectManually`：状态混杂；先看 `check-godot-mcp.ps1` 输出。

只读诊断：

```powershell
.\scripts\dev\check-godot-mcp.ps1
```

确认无其它 Godot MCP 会话需要 stale bridge 后，才允许受限清理：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions
```

清理后如果当前客户端出现 `Transport closed`，从同一 worktree 重开客户端会话。

## Script Reference

| Script | Frequency | Read-only | May Kill Process | Typical Use |
| --- | --- | --- | --- | --- |
| `enter-worktree-godot-mcp.ps1` | High | Dry-run only | Only with explicit cleanup flags | Daily entry for MCP review |
| `check-godot-mcp.ps1` | High | Yes | No | Show bridge, CLI, lock, stale reason and editor connections |
| `safe-repair-godot-mcp.ps1` | Low | No | Yes | Reopen current workspace Godot or clean confirmed stale bridge |
| `open-worktree-godot.ps1` | Low | No | No | Open current worktree Godot when stdio bridge exists |
| `godot-mcp-common.ps1` | Library | N/A | No | Shared port plan, process classification, lock and stale logic |
| `apply-godot-mcp-pro-hardening-patch.ps1` | Upgrade-time | Dry-run only | No | Replay server/plugin hardening patch |

`safe-repair` and `open-worktree-godot` are implementation helpers. Prefer `enter-worktree-godot-mcp.ps1` unless you are doing focused diagnostics.

## Troubleshooting Layers

1. Tool entry
   - If the client has no Godot MCP tools, reopen the client from the target worktree.
   - Do not restart Godot repeatedly for a missing client-side tool entry.

2. Bridge listener
   - Use `check-godot-mcp.ps1` or `get_bridge_status`.
   - Stdio bridge candidates are `6505-6509,6515-6534`; CLI reserved ports are `6510-6514`.
   - Do not kill a bridge only because it is old.

3. Godot editor connection
   - If bridge exists but editor is not connected, reopen the current worktree Godot editor.
   - If another workspace has a bridge lock or editor connection, do not steal or clean it.

4. Runtime autoload
   - If editor tools work but screenshot/input/runtime script tools fail, treat it as runtime autoload injection failure.
   - Reopen or refresh current worktree editor, restart the review scene, then retest runtime tools.

5. Closeout cleanup
   - After runtime MCP review, clean temporary MCP autoload diff from `project.godot`.
   - If more runtime review is needed after cleanup, confirm autoload injection again.

## Runtime Autoload And Plugins

`godot_mcp` may dynamically inject runtime autoloads while the editor is open. Keep those temporary autoloads during MCP screenshot, input, game inspector and runtime script review. Clean them only after the MCP runtime review is finished.

Other plugin autoloads are not temporary MCP injection. If Godot reports many plugin errors, first check:

1. `project.godot` `[autoload]` entries for plugins not enabled in the current stage.
2. `project.godot` `[editor_plugins]` entries for plugins not needed now.
3. `.godot` import cache from older plugin state.
4. Stale stdio bridge state only after the above layers are ruled out.

Plugin inventory and enablement rules live in `docs/dev/plugin-inventory.md`.

## Patch Tool Usage

通用补丁工具位于：

```text
tools/godot-mcp-pro-hardening/
```

补丁源目录：

```text
tools/godot-mcp-pro-hardening/patch-files/
  server/
  plugin/addons/godot_mcp/
  optional-project-scripts/scripts/dev/
```

默认预览：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
```

默认真实应用并构建：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -Build
```

默认 `Scope=ServerAndPlugin`，只更新全局 Node server 和目标项目 `addons/godot_mcp`，不覆盖目标项目 `scripts/dev`。

给其它项目只补插件端，例如 `angel-fallen`：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope PluginOnly `
  -DryRun
```

脚本搬到独立目录时，如果同级存在 `patch-files` 可自动发现；否则传入 `-PatchRoot`：

```powershell
C:\Tools\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -PatchRoot C:\Users\peng8\.codex\worktrees\fef5\nano-hunter\tools\godot-mcp-pro-hardening\patch-files `
  -Scope PluginOnly `
  -DryRun
```

`-IncludeProjectScripts` 是显式风险确认，只适合目标项目也采用本仓库的 `check / enter / safe-repair / open-worktree` 诊断脚本规范时使用。

## Worktree Closeout

固定永久 worktree 默认保留。阶段收口时：

- 记录 Godot MCP 连接状态。
- 关闭不再需要的运行中游戏实例。
- 必要时关闭当前 worktree Godot editor。
- 不为了“收口干净”全量释放 bridge。
- 若删除物理 worktree，先关闭指向该 worktree 的 Godot / 运行实例 / 终端 / 资源管理器窗口，迁移需要保留的 ignored 本地证据，再复核 `git worktree list`、磁盘目录、stdio bridge `6505-6509,6515-6534` 与 CLI reserved `6510-6514` 状态。

临时 worktree 删除和证据迁移的通用规则以 `AGENTS.md` 为准。
