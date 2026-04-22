# Nano Hunter Status

Last Updated: 2026-04-22

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 4：最小能力差异（已完成，待进入阶段 5）`

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

`main` 现已承载阶段 4 的稳定基线；下一步优先进入阶段 5“教程区垂直切片”的设计确认、实现计划与新的分支 / worktree 入口。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- 维护阶段 4 已完成基线的主线留痕
- 以新的代理协作默认规则作为后续阶段推进基线
- 为阶段 5 的设计确认、实现计划与隔离开发现场做准备

## Recently Completed

- 在 `project.godot` 中新增 `dash` 动作与默认键位，并在 `scripts/main/main.gd` 中补齐运行时兜底输入绑定
- 在 `scripts/player/player_placeholder.gd` 中新增 `dash` 状态、方向规则、持续时间、速度与冷却时间，并将默认参数调到更适合 stage4 价值验证的区间
- 新增并扩展 `tests/stage4/test_stage_4_minimal_ability_difference.gd` 到 `8/8` 通过，除输入契约外，还覆盖探索门槛与战斗接敌价值
- 将 `scenes/rooms/test_room.tscn` 收敛成真正的 stage4 验证区，加入 `FloorRight`、`DashGapLeft`、`DashGapRight`、`DashGateCeiling` 与 `DashCombatDummy`
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过
- 通过 Godot MCP Pro CLI 与内置 MCP 工具复核主场景运行树，确认 stage4 新节点已进入运行态，且 `DashGateCeiling.position == (0, 90)`、`DashCombatDummy.position == (56, 136)`
- 完成一轮额外的运行态人工手感复核：确认低顶 + 缺口构图已经能直观表达“仅地面 dash”，且过门槛后到 `DashCombatDummy` 只剩短距离接敌
- 为 `dash` 补上一层最小可读性反馈：冲刺期间玩家本体从默认蓝青色切到更亮的冷白色，并在结束后立即恢复；对应 stage4 自动化扩展到 `9/9` 通过
- 将 `codex/stage-4-minimal-ability-difference` 以“分支 + worktree”模式本地合并回 `main`，并在主线上重新确认阶段 1 / 2 / 3 / 4 自动化全部通过

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告
- `PlayerSpawn` 仍与 `TestRoom` 并列，本轮不处理场景归属重构
- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- `PlayerSpawn` 仍与 `TestRoom` 并列，本轮不处理场景归属重构
- 当前已无明确玩法阻塞项；后续主要风险转为阶段 5 启动时是否会过早引入 HUD、门控和教程串联之外的额外系统

## Next Recommended Steps

1. 以当前 `main` 为新稳定基线，启动阶段 5“教程区垂直切片”的 brainstorming、设计文档与实现计划。
2. 新建阶段 5 分支与 worktree，并把 HUD、教程区短流程、简单门控和基础敌人 / 障碍的边界一次性写清。
3. 若阶段 5 接入教程串联后发现当前 `dash` 与 `attack` 节奏不匹配，优先回调现有参数，不提前扩展更多战斗系统。
