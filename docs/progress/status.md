# Nano Hunter Status

Last Updated: 2026-03-31

## Current Phase

`Vertical Slice / 原型期`

## Current Goal

项目级治理基线已经落地，继续维护 `AGENTS.md`、时间线和日记录文档，然后再进入第一版可玩原型的实现计划。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `godot_mcp` 会在编辑器启动时动态注入 MCP autoload，退出时自动清理
- `better-terrain` 仍然保留在仓库中，但当前不再作为已激活插件使用
- 当前设计文档目录：`spec-design/`
- 当前进度文档目录：`docs/progress/`

## In Progress

- 维护项目专属 `AGENTS.md`
- 维护 `docs/progress/` 的状态、时间线、日记录文档
- 为后续第一版可玩原型整理实现入口

## Recently Completed

- 初始化 Godot 工程并整理基础仓库文件
- 将仓库纳入 Git 跟踪并推送到 GitHub
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md`
- 创建并提交 `docs/superpowers/plans/2026-03-31-agents-foundation.md`
- 通过 worktree 隔离创建 `codex/agents-foundation`
- 修复 Godot 基线问题，禁用当前阶段不需要的 `better-terrain` 激活
- 保留 `godot_mcp` 与 `gut` 作为当前阶段默认可用插件
- 在当前 worktree 中创建项目专属 `AGENTS.md`，尚未提交
- 在当前 worktree 中建立并更新 `docs/progress/` 的状态、时间线和日记录文档，尚未提交
- 在 `AGENTS.md` 中补充项目内代码的注释约定
- 在 `AGENTS.md` 中补充 `subagent` / `multi-agent` 原则，并要求重要委派写入 `Delegation Log`
- 在 `AGENTS.md` 中补充交互语言约定，明确面向用户与项目文档默认使用中文

## Risks And Blockers

- 目前还没有主场景、玩家控制器、关卡原型或测试目录
- 如果没有统一的项目级规范和进度文档，后续多 session 开发容易偏离目标
- 之前的基线验证暴露过 `better-terrain` 在当前 Godot 4.6 环境下的兼容性问题，因此后续再次启用前需要重新验证
- 当前阶段的 Godot 基线验证应使用 `godot --headless --path . --import`，不是 `--quit`

## Next Recommended Steps

1. 继续维护 `AGENTS.md` 和进度留痕体系
2. 在规范稳定后，为第一版可玩原型编写实现计划
3. 从主场景和玩家基础移动开始推进垂直切片
