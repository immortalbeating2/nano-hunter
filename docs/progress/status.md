# Nano Hunter Status

Last Updated: 2026-04-22

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 4：最小能力差异（进行中，探索/战斗价值验证已接入）`

## Stage Goal

在阶段 3 稳定攻击闭环基线之上，通过“仅地面冲刺 + TestRoom 混合验证”证明最小能力差异已经具备探索价值和战斗价值。

## Playable Now

- `godot --path .` 仍会进入 `Main.tscn`
- 主场景仍会生成 1 个占位玩家到 `Runtime`
- 阶段 2 的移动、跳跃、落地与基础状态切换仍然可用
- 阶段 3 的地面普通攻击、固定命中范围与 `TrainingDummy` 仍然保留
- 阶段 4 已接入仅地面 `dash`，并限制为只能从 `idle` / `run` / `land` 进入
- 当前 `dash` 在持续期内保持平直位移，用于稳定承担短门槛穿越与快速接敌价值
- `TestRoom` 已加入 `FloorRight`、`DashGapLeft`、`DashGapRight`、`DashGateCeiling` 与 `DashCombatDummy`，形成阶段 4 的最小探索 / 战斗验证区

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

## Exit Criteria

- 玩家可稳定从地面进入 `dash`，并与普通移动形成清晰差异
- `dash` 在探索门槛与战斗接敌中都具备可感知价值
- 阶段 1 / 2 / 3 / 4 自动化测试保持绿色
- 当前结果足以承接阶段 5 的教程区垂直切片

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 4 允许加入轻量级冲刺可读性反馈，但不引入正式 HUD
- 更强反馈只在确认其服务于能力差异表达时再进入实现

## Next Stage

`阶段 5：教程区垂直切片`

## Current Goal

继续验证当前 `dash` 与 TestRoom 门槛是否已经形成足够清晰、足够好调的能力差异；若手感或可读性仍偏弱，再补最小反馈或更强的房间验证，而不是提前扩系统。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- 准备将阶段 4 作为“最小能力差异已成立”的稳定检查点收口
- 整理阶段 4 的提交拆分、分支收口与合并前验证结论
- 继续在 stage4 worktree 中同步最终收口文档

## Recently Completed

- 在 `project.godot` 中新增 `dash` 动作与默认键位，并在 `scripts/main/main.gd` 中补齐运行时兜底输入绑定
- 在 `scripts/player/player_placeholder.gd` 中新增 `dash` 状态、方向规则、持续时间、速度与冷却时间，并将默认参数调到更适合 stage4 价值验证的区间
- 新增并扩展 `tests/stage4/test_stage_4_minimal_ability_difference.gd` 到 `8/8` 通过，除输入契约外，还覆盖探索门槛与战斗接敌价值
- 将 `scenes/rooms/test_room.tscn` 收敛成真正的 stage4 验证区，加入 `FloorRight`、`DashGapLeft`、`DashGapRight`、`DashGateCeiling` 与 `DashCombatDummy`
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过
- 通过 Godot MCP Pro CLI 与内置 MCP 工具复核主场景运行树，确认 stage4 新节点已进入运行态，且 `DashGateCeiling.position == (0, 90)`、`DashCombatDummy.position == (56, 136)`
- 完成一轮额外的运行态人工手感复核：确认低顶 + 缺口构图已经能直观表达“仅地面 dash”，且过门槛后到 `DashCombatDummy` 只剩短距离接敌
- 为 `dash` 补上一层最小可读性反馈：冲刺期间玩家本体从默认蓝青色切到更亮的冷白色，并在结束后立即恢复；对应 stage4 自动化扩展到 `9/9` 通过

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告
- `PlayerSpawn` 仍与 `TestRoom` 并列，本轮不处理场景归属重构
- 当前 stage4 自动化、运行态复核与最小可读性反馈都已到位；当前已无明确玩法阻塞项，主要剩分支收口与合并准备
- 主工作区里仍保留一份未提交的 `AGENTS.md` 修订；stage4 worktree 已同步，但主工作区仍需后续单独收口

## Next Recommended Steps

1. 进入阶段 4 的提交拆分、分支收口与合并准备。
2. 若合并前还想再看一眼，只做最终试玩确认，不再追加新系统。
3. 阶段 4 收口后，把下一轮重点切到阶段 5 的教程区垂直切片设计。
