# Godot MCP Pro 联通与排障指南

## 目的

这份文档用于解决 `nano-hunter` 在新 worktree / 新会话进场时，经常出现的 `godot_mcp` 联通问题，包括：

- 项目级 `.codex/config.toml` 已加载，但 bridge / 编辑器仍未正确连通
- 旧 `godot-mcp-pro` bridge 残留
- `6505-6509` 端口被旧会话占用
- 当前 worktree 的 Godot 编辑器连错 bridge
- 当前 AI 会话的 bridge 已坏，但 Godot 仍连着旧桥

本指南的目标不是改变 `godot-mcp-pro` 的底层固定端口机制，也不是重新说明 MCP 如何安装；它只把“检查 / 修复 / 打开当前 worktree Godot 编辑器”的流程工程化。

## 项目级配置边界

当前仓库通过项目级 `.codex/config.toml` 注册 `godot-mcp-pro`：

```toml
[mcp_servers.godot-mcp-pro]
type = "stdio"
command = "cmd"
args = ["/c", "node", "%USERPROFILE%/.mcp/godot-mcp-pro/server/build/index.js"]
```

这解决的是“Godot MCP 只在本项目 / worktree 会话中加载”，避免普通 Codex 会话全局启动 Godot bridge。

它不解决：

- 旧 bridge 进程仍占用 `6505-6509`
- 当前会话的 bridge 启动后没有抢到可用端口
- Godot 编辑器连到了旧会话 bridge
- worktree 切换后 Godot 编辑器仍打开旧路径
- `project.godot` 中临时 MCP autoload 的清理节奏

因此，下面这些脚本仍然保留为“排障工具”，不是“配置工具”。

## 先理解机制

`godot_mcp` 的链路分成两层：

1. AI 会话侧 `node.exe bridge`
- 常见命令行：`godot-mcp-pro/server/build/index.js`
- 负责监听 `6505-6509` 这组端口中的若干项
- 这是“占端口”的那一侧

2. Godot 编辑器侧
- 插件启动后，会主动去连接这些 bridge 端口
- Godot 通常不是监听端口的一方，而是连接 bridge 的客户端

这意味着：

- “只开 AI 会话，不开 Godot 编辑器”，也可能已经有 bridge 在监听端口
- “Godot 已打开”不代表它一定连到了当前会话的 bridge
- “清掉旧桥”也不自动意味着“新桥一定已经起来并被 Godot 消费”

## 核心原则

### 原则 1：先看状态，不要先猜

默认先执行：

```powershell
.\scripts\dev\check-godot-mcp.ps1
```

它会输出：

- 当前 worktree 路径
- bridge 进程
- `6505-6509` 监听
- Godot 编辑器进程
- 当前 worktree Godot 编辑器到 bridge 的已建立连接
- `RecommendedAction`
- `Reason`

### 原则 2：默认不要清 bridge

如果当前会话的 `godot_mcp` 可能还活着，默认不要直接清 bridge。

因为一旦把“当前会话自己的 bridge”也一起清掉，当前会话里的 `godot_mcp` 很可能会进一步退化成：

- `editor is not connected`
- 或 `Transport closed`

后者通常意味着当前会话很难自愈。

### 原则 3：只有在会话已坏或准备重开时，才强制清 bridge

适合使用强制桥接清理的场景：

- 当前会话已经明显坏掉
- `check` 明确建议 `ReopenSessionThenForceKillBridge`
- 你准备重开 Codex 会话

## 排障脚本总览

### 1. `check-godot-mcp.ps1`

路径：

`scripts/dev/check-godot-mcp.ps1`

用途：

- 单纯检查当前 `godot_mcp` 状态
- 给出推荐动作

推荐场景：

- 每次新 worktree 进场前先跑一次
- `godot_mcp` 突然不通时先判断

示例：

```powershell
.\scripts\dev\check-godot-mcp.ps1
```

### 2. `safe-repair-godot-mcp.ps1`

路径：

`scripts/dev/safe-repair-godot-mcp.ps1`

用途：

- 默认只关闭“当前 worktree”的 Godot 编辑器
- 默认只报告 bridge，不会杀 bridge
- 只有显式 `-ForceKillBridge` 才会清 bridge

推荐场景：

- 当前会话可能还活着
- 想先保守修复编辑器现场

示例：

```powershell
.\scripts\dev\safe-repair-godot-mcp.ps1
```

预演：

```powershell
.\scripts\dev\safe-repair-godot-mcp.ps1 -DryRun
```

仅在明确需要时强制清 bridge：

```powershell
.\scripts\dev\safe-repair-godot-mcp.ps1 -ForceKillBridge
```

### 3. `force-repair-godot-mcp.ps1`

路径：

`scripts/dev/force-repair-godot-mcp.ps1`

用途：

- 强制关闭当前 worktree Godot 编辑器
- 强制清掉全部 `godot-mcp-pro` bridge

定位：

- 危险工具
- 不作为默认入口

只适合：

- 当前会话已坏
- 或你明确准备重开会话

示例：

```powershell
.\scripts\dev\force-repair-godot-mcp.ps1
```

### 4. `open-worktree-godot.ps1`

路径：

`scripts/dev/open-worktree-godot.ps1`

用途：

- 在当前 worktree 路径上用 `-e --path` 打开 Godot 编辑器
- 打开后输出当前 bridge / editor / established connections 状态

推荐场景：

- 你已经确认 bridge 状态正常
- 只想重开当前 worktree 的 Godot 编辑器

示例：

```powershell
.\scripts\dev\open-worktree-godot.ps1
```

### 5. `enter-worktree-godot-mcp.ps1`

路径：

`scripts/dev/enter-worktree-godot-mcp.ps1`

用途：

- 串起：
  1. `check`
  2. `safe-repair`
  3. `open`

定位：

- 新 worktree / 新 stage 需要 Godot MCP 运行态复核时的诊断入口
- 它不负责注册 MCP；注册入口是项目级 `.codex/config.toml`

示例：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

预演：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
```

仅在当前会话已坏、且你准备重开会话时：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ForceKillBridge
```

## 推荐动作说明

`check-godot-mcp.ps1` 会给出 `RecommendedAction`。

### `AlreadyConnected`

含义：

- 当前 worktree Godot 编辑器已经连上 bridge
- 而且存在疑似当前会话的 bridge 批次

动作：

- 不必修复，直接继续工作

### `SafeOpenEditor`

含义：

- 当前会话 bridge 看起来已经存在
- 但当前 worktree 还没有打开 Godot 编辑器

动作：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

### `SafeReopenEditor`

含义：

- 当前 worktree 的 Godot 编辑器已经开了
- 但没有建立 bridge 连接
- 同时看起来存在当前会话 bridge

动作：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

### `ReopenSessionThenForceKillBridge`

含义：

- 当前 worktree Godot 编辑器只连到了“疑似旧桥”
- 或当前系统里只剩旧桥，没有当前桥

动作：

1. 结束当前坏会话
2. 重开 Codex 会话
3. 再执行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ForceKillBridge
```

注意：

- 不建议在当前仍活着的会话里直接强清 bridge
- 因为这可能顺手把“当前会话自己的 bridge”也一起清掉

### `InspectManually`

含义：

- 当前 bridge / editor / connections 状态混杂
- 脚本不想替你做过度自信的决策

动作：

- 先看 `check` 输出的几张表
- 再决定用安全模式还是重开会话后强清

## 新 worktree 进场推荐顺序

### 正常场景

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

### 先观察，不动现场

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
```

### 当前会话已坏，准备彻底重置桥接

先重开 Codex 会话，再执行：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1 -ForceKillBridge
```

## 常见误区

### 误区 1：只要打开会话就一定会占满 5 个端口

不是。

更准确地说：

- 会话启动后，可能会拉起一批 bridge
- 它们会尝试占用 `6505-6509` 中的若干端口
- 不保证每次都 5 个全占满

### 误区 2：Godot 编辑器才是占端口的一方

不是。

更常见的是：

- `node.exe bridge` 在监听端口
- Godot 编辑器去连接这些端口

### 误区 3：清掉旧桥就一定恢复

不是。

恢复联通通常至少要同时满足：

1. 旧桥已经释放
2. 当前会话的新桥已经起来
3. Godot 编辑器是在新桥起来之后重新打开的

## 当前工具集建议

日常保留并使用：

- `check-godot-mcp.ps1`
- `enter-worktree-godot-mcp.ps1`
- `safe-repair-godot-mcp.ps1`
- `open-worktree-godot.ps1`
- `godot-mcp-common.ps1`

危险工具，仅在明确场景下使用：

- `force-repair-godot-mcp.ps1`

## 维护建议

如果后续这套流程还会继续扩展，建议优先继续做：

- 让 `enter-worktree-godot-mcp.ps1` 在 `RecommendedAction = ReopenSessionThenForceKillBridge` 时直接停止并给出提醒
- 在后续新阶段文档里统一引用本指南，而不是重复写一遍桥接排障经验
