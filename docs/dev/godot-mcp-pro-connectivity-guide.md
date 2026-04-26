# Godot MCP Pro 联通与排障指南

## 目的

本指南用于让 `nano-hunter` 的 Godot MCP 人工复核流程保持简单、可重复，尤其适配当前采用的“固定永久工作树 + 阶段分支”开发方式。

它解决的是日常进场与少量排障问题：

- Codex 会话是否从目标固定工作树启动
- 项目级 `.codex/config.toml` 是否让本会话加载了 `godot-mcp-pro`
- `godot-mcp-pro` bridge 是否监听 `6505-6509`
- 当前固定工作树的 Godot 编辑器是否连到当前会话 bridge
- 旧 bridge 占满端口时，如何避免“两次重开 Codex”

## 项目级配置边界

仓库通过项目级 `.codex/config.toml` 注册 `godot-mcp-pro`：

```toml
[mcp_servers.godot-mcp-pro]
type = "stdio"
command = "cmd"
args = ["/c", "node", "%USERPROFILE%/.mcp/godot-mcp-pro/server/build/index.js"]
```

这只决定“Codex 会话启动时是否挂载 Godot MCP 工具”。它不会在会话中途热更新工具列表，也不会自动清理旧 bridge 或重开 Godot 编辑器。

因此，Godot MCP 复核会话必须从目标固定工作树启动。不要先从别的目录启动 Codex，再 `cd` 到本项目并期待 `mcp__godot_mcp_pro__` 工具自动出现。

## 日常唯一入口

日常只运行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

该脚本会读取当前状态并自动选择动作：

- `AlreadyConnected`：已连通，不动现场，直接继续 MCP 复核
- `SafeOpenEditor`：当前会话 bridge 存在，打开当前固定工作树 Godot 编辑器
- `SafeReopenEditor`：当前会话 bridge 存在，只重开当前固定工作树 Godot 编辑器
- `ReopenSessionThenForceKillBridge`：只有旧 bridge 占端口，停止自动动作并提示重开前清理
- `InspectManually`：状态混杂，不自动修复，转入诊断

只想观察而不打开 / 关闭编辑器时：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
```

## stale-only 的正确处理

如果脚本报告 `ReopenSessionThenForceKillBridge`、`Only stale bridge listeners were found` 或等价 stale-only 状态，并且你已经准备重开 Codex，先确认本机没有其他正在使用 Godot MCP 的项目会话。

`godot-mcp-pro` bridge 使用固定端口组，当前脚本无法可靠地把无编辑器连接的旧 bridge 精确归属到某个项目；真正清理 bridge 时会停止本机全部 `godot-mcp-pro/server/build/index.js` bridge 进程。因此，如果还有其他项目 / worktree 的 Godot MCP 会话正在使用，清理会中断它们。

确认没有其他活跃 Godot MCP 会话后，再执行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions
```

然后从同一个固定工作树重开 Codex 会话，再执行一次默认入口：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

这样可以避免错误顺序：

1. 先重开 Codex
2. 再清旧 bridge
3. 清桥导致当前会话 transport 关闭
4. 被迫再重开 Codex

正确顺序是：

1. stale-only 且准备重开时，确认没有其他活跃 Godot MCP 会话
2. 执行 `-ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions`
3. 重开 Codex
4. 默认入口打开 / 重开 Godot 编辑器
5. 立刻用 MCP 工具复测

## 工具入口缺失

如果本机 bridge 和 Godot 编辑器已经连上，但当前 Codex 对话没有 `mcp__godot_mcp_pro__` 工具入口，这不是 Godot 编辑器问题，而是会话启动时没有挂载项目级 MCP。

处理方式：

1. 确认当前物理目录是目标固定工作树
2. 从该固定工作树新开 Codex 会话
3. 新会话中先运行默认入口脚本

普通脚本无法让已经启动的 Codex 会话热加载新的 MCP 工具。

## 辅助脚本定位

日常入口：

- `enter-worktree-godot-mcp.ps1`

只读诊断：

- `check-godot-mcp.ps1`

高级排障，非日常默认流程：

- `safe-repair-godot-mcp.ps1`
- `open-worktree-godot.ps1`
- `force-repair-godot-mcp.ps1`

共用函数：

- `godot-mcp-common.ps1`

除非默认入口无法给出明确动作，否则不要把这些辅助脚本串成手动五段流程。

## 阶段收口注意

固定永久工作树本身默认保留，不按临时 worktree 删除。阶段收口时只需要：

- 确认当前阶段验证完成
- 记录 Godot MCP 连接状态
- 关闭不再需要的运行中游戏实例
- 必要时关闭当前固定工作树 Godot 编辑器
- 不默认全量释放 `6505-6509`，除非能确认它们属于废弃会话，或用户明确要求清理

Codex 托管临时 worktree 才需要额外执行物理目录删除、`git worktree list` 复核和进程占用清理。
