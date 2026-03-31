# Nano Hunter Status

Last Updated: 2026-03-31

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 1：可启动骨架（待开始）`

## Stage Goal

建立可直接启动进入主场景的最小骨架，为后续移动、战斗和教程区验证提供稳定入口。

## Playable Now

- 当前还没有可直接运行的主场景
- 目前只能进行工程导入验证、阶段规划与资产策略收敛

## Adjustable Now

- 阶段 1 的范围与退出条件
- 主场景比例、测试房间尺寸、基础相机策略
- 原型期资产替代方式与视觉方向

## Exit Criteria

- 已配置 `run/main_scene`
- 存在 `Main.tscn`、测试房间、玩家出生点、相机与基础碰撞
- 项目可直接启动进入场景，作为后续移动手感开发入口

## Asset Status

- 当前以占位资产规划为主，允许免费替代与少量 AI 视觉探索
- 尚未进入正式项目资产生产

## Next Stage

`阶段 2：基础移动手感`

## Current Goal

`阶段 1：可启动骨架` 的实现计划已经完成，下一步是在该计划基础上选择执行方式并开始落地。

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

- 维护项目专属 `AGENTS.md` 与设计文档
- 维护 `docs/progress/` 的状态、时间线、日记录文档
- 为 `阶段 1：可启动骨架` 准备执行环境与文件边界

## Recently Completed

- 初始化 Godot 工程并整理基础仓库文件
- 将仓库纳入 Git 跟踪并推送到 GitHub
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md`
- 创建并提交 `docs/superpowers/plans/2026-03-31-agents-foundation.md`
- 通过 worktree 隔离创建 `codex/agents-foundation`
- 修复 Godot 基线问题，禁用当前阶段不需要的 `better-terrain` 激活
- 保留 `godot_mcp` 与 `gut` 作为当前阶段默认可用插件
- 在当前 worktree 中创建并持续完善项目专属 `AGENTS.md`
- 在当前 worktree 中建立并持续更新 `docs/progress/` 的状态、时间线和日记录文档
- 在 `AGENTS.md` 中补充项目内代码的注释约定
- 在 `AGENTS.md` 中补充 `subagent` / `multi-agent` 原则，并要求重要委派写入 `Delegation Log`
- 在 `AGENTS.md` 中补充交互语言约定，明确面向用户与项目文档默认使用中文
- 在 `AGENTS.md` 与设计稿中补充 5 个可试玩检查点、阶段记录要求与原型期资产策略
- 编写 `docs/superpowers/plans/2026-03-31-stage-1-startup-skeleton.md`

## Risks And Blockers

- 目前还没有主场景、玩家控制器、关卡原型或测试目录
- 如果没有统一的项目级规范和进度文档，后续多 session 开发容易偏离目标
- 阶段 1 仍未开始实现，当前还没有可试玩入口
- 资产需求仍处于原型期规划阶段，目前依赖占位、免费资源和 AI 临时探索并行推进
- 之前的基线验证暴露过 `better-terrain` 在当前 Godot 4.6 环境下的兼容性问题，因此后续再次启用前需要重新验证
- 当前阶段的 Godot 基线验证应使用 `godot --headless --path . --import`，不是 `--quit`

## Next Recommended Steps

1. 选择 `阶段 1：可启动骨架` 的执行方式
2. 落地 `Main.tscn` 与 `run/main_scene`
3. 形成第一个可启动、可看、可调的测试场景
