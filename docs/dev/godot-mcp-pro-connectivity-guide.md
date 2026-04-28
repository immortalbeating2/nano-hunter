# Godot MCP Pro 联通与排障指南（Codex 客户端）

## 目的

本指南记录当前 Codex 客户端下的 `godot-mcp-pro` 联通与排障流程，用于让 `nano-hunter` 的 Godot MCP 人工复核保持简单、可重复。

如果后续换用其他客户端或 CLI，本文件不能直接当作通用 MCP 标准；应新增对应客户端指南，并复用项目层面的通用要求：固定永久工作树、运行态人工复核、验证留痕和插件启用边界。

它解决的是日常进场与少量排障问题：

- Codex 会话是否从目标固定工作树启动
- 项目级 `.codex/config.toml` 是否让本会话加载了 `godot-mcp-pro`
- `godot-mcp-pro` bridge 是否监听 `6505-6509`
- 当前固定工作树的 Godot 编辑器是否连到可用 bridge
- 运行态 autoload 是否已经注入到当前游戏实例
- 旧 bridge 占满端口时，如何避免“两次重开 Codex”
- `godot_mcp` 动态 autoload 和其他插件 autoload / editor plugin 启用项如何区分

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

## 固定永久工作树原则

固定永久工作树的目标是复用同一个 Godot 编辑器、导入缓存和 MCP 运行态现场。阶段切换不等于每个 stage 都必须重连一次 MCP。

如果当前 Codex 会话已经成功调用过 `mcp__godot_mcp_pro__` 工具，并且仍在同一个固定永久工作树继续开发或复核，优先保持现有连接，直接继续 MCP 复核。不要仅因为进入新阶段、脚本启发式显示 stale 字样、或本机存在旧 bridge 进程就主动清理 bridge。

`ReopenSessionThenForceKillBridge` 是故障恢复流程，不是日常 preflight。只有在 MCP 工具不可用、编辑器无法连接、或已经明确准备重开 Codex 时，才进入 stale bridge 清理流程。

如果脚本提示 bridge 年龄可疑，但当前工作树编辑器已经连到 bridge，优先视为“已连接但 bridge 年龄未知”。这不是 stale-only，不应直接清 bridge；先调用一个只读 MCP 工具实测。如果工具可用，就继续人工复核。

## 四层判断流程

Godot MCP 问题必须先分层，不要把运行态问题、工具入口问题和 bridge 问题混在一起处理。

1. 会话工具入口
   - 当前会话能看到 `mcp__godot_mcp_pro__` 工具，才说明 Codex 启动时加载了项目级 MCP。
   - 工具入口缺失时，从目标固定工作树重开 Codex；普通脚本不能热加载 MCP 工具。
2. 编辑器连接
   - 运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1`。
   - `AlreadyConnected`、`SafeOpenEditor`、`SafeReopenEditor` 和 `ConnectedBridgeAgeUnknown` 都不应清 bridge。
   - `ConnectedBridgeAgeUnknown` 表示当前工作树编辑器已连到 bridge，但脚本无法确认它是否属于当前会话；先用 MCP 只读工具实测。
3. 运行态 autoload
   - 如果编辑器场景树可读，但运行态截图、输入、场景脚本执行或测试场景控制不可用，优先判断为 Godot MCP 运行态 autoload 未注入当前游戏实例。
   - 处理顺序是重新注入 / 重开当前工作树编辑器 / 重启运行场景，再复测运行态工具。
   - 这里不要求记住具体服务名；只要属于 MCP 的运行态截图、输入、脚本执行或 game inspector 能力，都归入这一层。
4. 收口清理
   - 运行态人工复核结束后，清理 `project.godot` 中的临时 Godot MCP autoload diff。
   - 清理后如果还要继续运行态复核，必须重新确认运行态 autoload 已注入，不能沿用清理前的判断。

## 日常唯一入口

日常只运行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

该脚本会读取当前状态并自动选择动作：

- `AlreadyConnected`：已连通，不动现场，直接继续 MCP 复核
- `SafeOpenEditor`：当前会话 bridge 存在，打开当前固定工作树 Godot 编辑器
- `SafeReopenEditor`：当前会话 bridge 存在，只重开当前固定工作树 Godot 编辑器
- `ConnectedBridgeAgeUnknown`：当前工作树编辑器已连到 bridge，但 bridge 年龄不像当前会话；不清 bridge，先用 MCP 工具实测
- `ReopenSessionThenForceKillBridge`：只有旧 bridge 占端口，停止自动动作并提示重开前清理
- `InspectManually`：状态混杂，不自动修复，转入诊断

只想观察而不打开 / 关闭编辑器时：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
```

## stale-only 的正确处理

如果脚本报告 `ReopenSessionThenForceKillBridge`、`Only stale bridge listeners were found` 或等价 stale-only 状态，并且你已经准备重开 Codex，先确认本机没有其他正在使用 Godot MCP 的项目会话。

如果脚本报告 `ConnectedBridgeAgeUnknown`，不要执行 stale-only 清理。该状态说明当前工作树编辑器已经和 bridge 建立连接，只是 PowerShell 侧无法证明这个 bridge 是当前会话新启动的。此时先用 MCP 工具实测；只有工具调用失败、入口缺失或返回 `Transport closed` 时，才进入重开会话或 stale 清理判断。

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

## Transport closed

`Transport closed` 通常表示当前 Codex 会话到 `godot-mcp-pro` MCP 子进程的传输已经关闭。常见触发方式是：在当前会话里执行了会停止 bridge 的清理动作，然后继续尝试使用同一个会话的 MCP 工具。

如果已经执行过：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions
```

不要在同一个旧 Codex 会话里继续做 MCP 人工复核。正确下一步是从同一固定永久工作树重开 Codex，再运行默认入口脚本。

## 运行态 autoload 与插件启用项

本节只解释 MCP 复核时与 autoload / 插件启用项的关系。更完整的插件盘点、默认启用范围和报错判断，参考 `docs/dev/plugin-inventory.md`。

需要区分三类状态：

- 插件目录存在：例如 `addons/dialogue_manager/`、`addons/controller_icons/`。目录存在本身通常不会让 Godot 启动时报错。
- `[editor_plugins]` 启用：插件会作为编辑器插件加载。当前默认只启用 `res://addons/godot_mcp/plugin.cfg` 和 `res://addons/gut/plugin.cfg`。
- `[autoload]` 启用：脚本或场景会在项目启动时自动加载。即使插件没有在 `[editor_plugins]` 启用，只要残留在 `[autoload]`，仍可能在进入项目或运行游戏时触发错误。

`godot_mcp` 在编辑器运行期间可能动态注入它需要的临时 autoload。运行态人工复核期间应保留这类临时注入；等所有 MCP 截图、输入、运行态脚本检查、game inspector 读值和测试场景控制结束后，再清理 `project.godot` 中的 MCP autoload diff。

运行态 autoload 问题的通用判断是：编辑器连接可用，但运行中的游戏实例无法响应 MCP 运行态能力。此时不要清 bridge，按以下顺序处理：

1. 确认当前 Godot 编辑器打开的是目标固定工作树。
2. 重新打开或刷新当前工作树编辑器，让 Godot MCP 插件重新注入运行态 autoload。
3. 重新启动 `Main.tscn` 或当前复核场景。
4. 复测运行态工具。
5. 复核结束后清理 `project.godot` 中的 MCP autoload diff。

清理后如果还要继续使用 MCP 运行态能力，应重新打开当前 worktree 的 Godot 编辑器并确认 MCP 已重新注入和连通。

其他插件的 autoload 不是临时 MCP 注入。当前阶段没有引用的插件不应默认写入 `project.godot` 的 `[autoload]` 或 `[editor_plugins]`。进入 Godot 项目时如果出现多条插件报错，优先按 `docs/dev/plugin-inventory.md` 排查，重点检查：

1. `project.godot` 是否残留非当前默认插件的 `[autoload]`。
2. `project.godot` 的 `[editor_plugins]` 是否启用了当前阶段不需要的插件。
3. `.godot` 导入缓存是否来自旧插件状态。
4. `6505-6509` 是否有旧 `godot-mcp-pro` bridge 占用，导致当前会话错连。

之前启动 Godot 时的多插件报错，高置信度原因不是“插件目录存在”，而是历史 autoload / editor plugin 启用项、旧 UID 引用和 `.godot` 缓存状态叠加。`DialogueManager` 与 `ControllerIcons` 曾作为 autoload 默认加载，`better-terrain` 也曾有残留引用且在 Godot 4.6 下有兼容性风险；这些才是需要清理或禁用的重点。

## 阶段收口注意

固定永久工作树本身默认保留，不按临时 worktree 删除。阶段收口时只需要：

- 确认当前阶段验证完成
- 记录 Godot MCP 连接状态
- 关闭不再需要的运行中游戏实例
- 必要时关闭当前固定工作树 Godot 编辑器
- 不默认全量释放 `6505-6509`，除非能确认它们属于废弃会话，或用户明确要求清理

Codex 托管临时 worktree 才需要额外执行物理目录删除、`git worktree list` 复核和进程占用清理。通用 worktree 清理规则以 `AGENTS.md` 为准。
