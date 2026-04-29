# Godot MCP Script Reference

本速查表记录 Godot MCP Pro bridge hardening 后的日常脚本入口。它面向 Nano Hunter 当前工作流，也可作为其它项目决定是否采用 `optional-project-scripts` 的参考。

## 日常优先级

1. `enter-worktree-godot-mcp.ps1 -DryRun`
   - 最常用入口。
   - 用于判断当前 worktree 是否已有 bridge、Godot editor 是否已连接、是否只剩 stale bridge。
   - 默认不清理，不杀进程。

2. `check-godot-mcp.ps1`
   - 只读诊断。
   - 用于查看 stdio bridge、CLI reserved listener、lock/heartbeat、Godot editor 与 workspace 连接。
   - 不启动 Godot，不清理 bridge。

3. `enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions`
   - 只有确认没有其它 Godot MCP 会话需要 stale bridge 时使用。
   - 会通过 `safe-repair-godot-mcp.ps1` 执行受限清理。

## 脚本说明

| 脚本 | 常用频率 | 是否只读 | 是否可能杀进程 | 推荐命令 | 典型场景 |
| --- | --- | --- | --- | --- | --- |
| `enter-worktree-godot-mcp.ps1` | 高 | 默认只读 / 可打开 Godot | 仅在确认参数齐全时 | `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun` | 进入当前 worktree MCP 人工复核前的统一入口 |
| `check-godot-mcp.ps1` | 高 | 是 | 否 | `.\scripts\dev\check-godot-mcp.ps1` | 查看端口、lock、stale reason、editor 连接 |
| `safe-repair-godot-mcp.ps1` | 中低 | 否 | 是 | `.\scripts\dev\safe-repair-godot-mcp.ps1 -DryRun` | enter 判断需要重开当前 workspace Godot 或确认后清 stale bridge |
| `open-worktree-godot.ps1` | 中低 | 否 | 否 | `.\scripts\dev\open-worktree-godot.ps1 -DryRun` | 已有 stdio bridge listener 时打开当前 worktree Godot |
| `godot-mcp-common.ps1` | 不直接运行 | 不适用 | 否 | 不直接运行 | 给其它脚本共享端口规划、进程识别、lock 读取和 stale 判断 |
| `apply-godot-mcp-pro-hardening-patch.ps1` | 升级后使用 | Dry-run 只读 | 否 | `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun` | 插件 / Node server 升级后重放 hardening 补丁 |

## 通用补丁脚本示例

当前项目预览：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
```

当前项目应用并构建 Node server：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -Build
```

给其它项目只打插件补丁：

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope PluginOnly `
  -DryRun
```

脚本搬到独立目录且与 `patch-files` 分离时：

```powershell
C:\Tools\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -PatchRoot C:\Users\peng8\.codex\worktrees\fef5\nano-hunter\tools\godot-mcp-pro-hardening\patch-files `
  -Scope PluginOnly `
  -DryRun
```

## 判断边界

- MCP 工具入口缺失：从目标 worktree 重开 Codex；脚本无法给当前会话动态注入 MCP 工具。
- bridge stale：先看 `check` 或 `enter -DryRun` 的 lock/heartbeat/PID/workspace/connection 证据。
- Godot editor 未连接：优先重开当前 worktree Godot，不先清 bridge。
- runtime autoload 失败：按运行态 autoload 流程处理，不归因于 bridge 生命周期。
- 6510-6514：保留给 `godot-cli`，不作为 stdio bridge 清理目标。
