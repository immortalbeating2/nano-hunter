# Nano Hunter Status

Last Updated: 2026-04-01

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 1：可启动骨架（已完成，可试玩）`

## Stage Goal

保持阶段 1 的启动骨架可试玩，并在不扩大范围的前提下完成首轮画面与相机构图调优，为阶段 2 的移动手感开发做准备。

## Playable Now

- `godot --path .` 可直接进入 `Main.tscn`
- 当前基准分辨率为 `640x360`，初始窗口为 `1280x720`
- 当前窗口放大时按整数倍等比缩放，非 `16:9` 时显示留边
- 当前测试房间已经约束相机边界，试玩时不再露出默认灰色空区
- 当前可在测试房间中看到占位玩家、基础相机与基础碰撞壳体

## Adjustable Now

- 测试房间尺寸、地面高度与边界宽度
- 玩家出生位置与当前构图关系
- 相机边界、房间留白与玩家占画面比例
- 阶段 2 前是否要调整 `PlayerSpawn` 与 `TestRoom` 的场景归属

## Exit Criteria

- `run/main_scene` 已配置
- `Main.tscn`、测试房间、玩家出生点、相机与基础碰撞已经落地
- 项目已形成第一个可启动、可看、可调的试玩检查点

## Asset Status

- 当前以占位资产与简单几何可视化为主
- 阶段 2 前允许继续补充免费替代资产与少量 AI 临时视觉探索
- 仍未进入正式项目资产生产

## Next Stage

`阶段 2：基础移动手感`

## Current Goal

本轮阶段 1 画面与相机调优已完成，当前转入试玩反馈收集和阶段 2 准备。

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
- 收集最新试玩反馈，确认调优后的画面感受
- 整理阶段 2 的准备事项与参数目标

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
- 提权验证 Godot 的 `AppData/Godot` 写入链路，确认之前的 GUT CLI 崩溃主要由受限运行环境触发
- 完成 `阶段 1` Task 1：启动入口骨架，提交 `6e77ab8`
- 完成 `阶段 1` Task 2：占位玩家与启动脚本，提交 `939f251`，并修正可见性与生成顺序，提交 `719fc92`
- 完成 `阶段 1` Task 3：测试房间壳体，提交 `49d69e4`，并补强房间测试契约，提交 `6770ba5`
- 当前 worktree 已可直接启动进入 `Main.tscn`，形成第一个可试玩检查点
- 编写并提交 `spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`，提交 `3a5f4da`
- 编写并提交 `docs/superpowers/plans/2026-04-01-stage-1-display-and-camera-tuning.md`，提交 `d7418d2`
- 完成 `阶段 1` Task 1：实现显示设置与基础启动收口，提交 `6597c44`，并根据 review 修复收口问题，提交 `1c832ab`
- 完成 `阶段 1` Task 2：实现测试房间边界相机限制与房间构图调优，提交 `9213814`，并根据 review 修复收口问题，提交 `ccd6ad7`
- 本轮阶段 1 画面与相机调优已完成，当前进入试玩反馈收集和阶段 2 准备

## Risks And Blockers

- 如果没有统一的项目级规范和进度文档，后续多 session 开发容易偏离目标
- 资产需求仍处于原型期规划阶段，目前依赖占位、免费资源和 AI 临时探索并行推进
- 之前的基线验证暴露过 `better-terrain` 在当前 Godot 4.6 环境下的兼容性问题，因此后续再次启用前需要重新验证
- 当前阶段的 Godot 基线验证应使用 `godot --headless --path . --import`，不是 `--quit`
- `godot --headless --path . --import` 仍会在退出时输出 `ObjectDB instances leaked at exit` 警告，暂未定位到项目侧根因
- `PlayerSpawn` 当前与 `TestRoom` 为并列节点；阶段 2 如果开始调整房间原点或复用房间模板，需要明确两者的归属关系

## Next Recommended Steps

1. 收集新的试玩反馈，确认当前 `640x360` 画面、整数倍缩放和留边观感是否稳定
2. 评估阶段 2 前是否需要调整 `PlayerSpawn` 与 `TestRoom` 的场景归属
3. 为 `阶段 2：基础移动手感` 整理实现计划与参数目标
