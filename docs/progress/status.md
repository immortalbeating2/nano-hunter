# Nano Hunter Status

Last Updated: 2026-04-23

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 5：教程区垂直切片（已完成，形成稳定基线）`

## Stage Goal

在阶段 4 已完成的移动、跳跃、地面冲刺与基础攻击基线上，做出一个“单场景、低压、可理解”的教程区垂直切片，让玩家第一次在真实主流程里完成 `move / jump / dash / attack` 的顺序学习，并看到最小 HUD 形态。

## Playable Now

- `godot --path .` 当前会进入 `Main.tscn`，并默认加载 `TutorialRoom`
- 主场景会生成 1 个占位玩家到 `Runtime`
- 阶段 2 的移动、跳跃、落地与基础状态切换仍然可用
- 阶段 3 的地面普通攻击、固定命中范围与 `TrainingDummy` 仍然保留
- 阶段 4 的仅地面 `dash` 仍然保持可用，并带有最小可读性反馈
- `TestRoom` 仍保留为阶段 2 / 3 / 4 的回归与调参沙盒
- `TutorialRoom` 已接入“移动/跳跃 -> dash -> 攻击 -> 出口”的单场景线性教学流程
- 最小 HUD 已接入“提示区 + 战斗面板”，提示区默认显示首条移动 / 跳跃教学文案
- 战斗面板当前只做展示：固定生命框位与 `dash` 状态文本，不接正式扣血 / 死亡 / 恢复循环
- `BattlePanel` 的两行文本布局已稳定分离，不再出现重叠错绘

## Adjustable Now

- 阶段 2 现有移动参数：
- `max_run_speed`
- `ground_acceleration`
- `ground_deceleration`
- `air_acceleration`
- `jump_velocity`
- `jump_cut_ratio`
- `rise_gravity`
- `fall_gravity`
- `max_fall_speed`
- `coyote_time_window`
- `jump_buffer_window`
- `landing_state_duration`
- 阶段 3 当前可调的攻击参数：
- `attack_startup_duration`
- `attack_active_duration`
- `attack_recovery_duration`
- `attack_hitbox_size`
- `attack_hitbox_offset`
- `attack_knockback_force`
- 阶段 4 当前可调的冲刺参数：
- `dash_duration`
- `dash_speed`
- `dash_cooldown`
- 阶段 5 当前可调项主要集中在：
- `TutorialRoom` 中各教学节点的位置
- 教学提示文案
- 出口门控的开启时机
- 最小 HUD 的版面与提示表达

## Exit Criteria

- `Main` 默认加载教程主房间，而不是继续硬编码 `TestRoom`
- 教程区能按“移动/跳跃 -> dash -> 攻击 -> 出口”顺序稳定推进
- 最小 HUD 已接入“提示区 + 战斗面板”，且战斗面板仅做展示
- 教程区门控采用低压模型，不引入正式死亡 / 恢复循环
- 阶段 1 / 2 / 3 / 4 / 5 自动化测试保持绿色
- 当前结果足以作为下一轮垂直切片扩展的稳定基线

当前状态：以上退出条件已满足。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 6：最小真实战斗循环（推荐）`

## Current Goal

`main` 现已承载阶段 5 的稳定基线：`Main` 主房间契约迁移、`TutorialRoom`、最小 HUD、节奏 / 文案收敛、HUD 错绘修复与 Stage 5 自动化均已闭环；当前推荐按 `阶段 6 -> 阶段 7 -> 阶段 8` 继续推进，而不是继续在阶段 5 内追加内容。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- 当前无新的阶段 5 实现项在进行中
- 当前更适合进入“阶段 6 设计确认”的准备阶段

## Recently Completed

- 阶段 4 的“最小能力差异”已完成并合并回 `main`
- 当前 `dash` 已同时具备输入契约、探索价值、战斗接敌价值与最小可读性反馈
- `main` 已成为阶段 5 的稳定起点
- 新建阶段 5 worktree，并补齐阶段 5 的设计文档、实现计划与进度页启动记录
- 阶段 5 教程区垂直切片已完整收口，自动化验证覆盖主入口迁移、教程顺序、`dash` 门槛、出口解锁与 HUD 战斗面板布局
- `codex/stage-5-tutorial-vertical-slice` 已本地合并回 `main`，主线 fresh 验证继续保持绿色

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 5 的退出条件已经满足，但仍未做长时间真人试玩；后续若要继续扩展，应把“新系统实现”和“真实试玩调参”拆开推进
- 当前主要风险不再是“功能未闭环”，而是后续若不收边界，容易把 HUD、教程串联、门控与更多系统一次性继续扩张
- 当前 `AGENTS.md` 中仍有重复的“测试文件异常排查约定”段落；这不是阶段阻塞项，但后续整理规范时可收口

## Recommended Roadmap

- `阶段 6：最小真实战斗循环`
- 目标：在现有教程切片之后，加入第一次真实战斗压力，而不再只是教学目标
- 范围：1 个基础敌人或攻击性障碍、玩家受击 / 生命 / 死亡或重置的最小闭环、教程后短实战段
- `阶段 7：短链路主流程串联`
- 目标：把当前单房间教程推进为至少两段连续流程，而不只是一个教学房间
- 范围：短链路主流程、最小门控、房间切换或区域衔接、一次完整小目标达成
- `阶段 8：系统稳固与内容生产前准备`
- 目标：为后续持续扩内容打底，而不是继续堆临时逻辑
- 范围：HUD 第二轮、参数数据化、敌人 / 房间模板化、必要的工程与流程收口

## Next Recommended Steps

1. 以 `阶段 6：最小真实战斗循环` 为下一轮默认优先项，先补设计文档与实现计划。
2. 在阶段 6 中优先验证“敌人压力 + 玩家受击 / 重置”是否成立，不提前混入多敌人、姿态、元素或大规模内容生产。
3. 阶段 6 验证成立后，再按 `阶段 7：短链路主流程串联` 与 `阶段 8：系统稳固与内容生产前准备` 继续推进。
