# Nano Hunter Status

Last Updated: 2026-04-23

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 6：最小真实战斗循环（首轮实现已完成）`

> Update: 2026-04-23 宸插畬鎴?stage6 棣栬疆鎵嬫劅鏀舵暃锛岄鎺ユ晫鍘嬪姏涓庡彈鍑诲悗鑴辩鎰熼兘宸茬粡鍋氫簡涓€杞?TDD 鎶ゅ銆?

## Stage Goal

在阶段 5 已完成的教程区垂直切片基线上，做出一个“教程后独立战斗房 + 1 个基础近战敌人 + 玩家生命 / 受击 / 本段即时重置”的最小真实战斗闭环，让玩家第一次真正承受战斗压力，而不只是完成教学目标。

## Playable Now

- `godot --path .` 当前会进入 `Main.tscn`，并默认加载 `TutorialRoom`
- 主场景会生成 1 个占位玩家到 `Runtime`
- 阶段 2 的移动、跳跃、落地与基础状态切换仍然可用
- 阶段 3 的地面普通攻击、固定命中范围与 `TrainingDummy` 仍然保留
- 阶段 4 的仅地面 `dash` 仍然保持可用，并带有最小可读性反馈
- `TestRoom` 仍保留为阶段 2 / 3 / 4 的回归与调参沙盒
- `TutorialRoom` 已接入“移动/跳跃 -> dash -> 攻击 -> 出口”的单场景线性教学流程
- 教程房现在可过渡到独立 `CombatTrialRoom`，作为阶段 6 的首段真实战斗压力段
- 玩家现已具备最小生命 / 受击 / 无敌 / `defeated` 闭环，默认生命为 `3`
- 玩家在战斗房生命归零后，会即时重置当前战斗房与玩家状态，而不会回退整段教程
- `CombatTrialRoom` 已接入 `BasicMeleeEnemy`，采用“小范围巡逻 + 接触伤害 + 被命中一次即失效”的最小模型
- 战斗房出口默认锁定，击败敌人后出口解锁
- 最小 HUD 已从“教程展示”升级为“真实读取当前房间提示 + 生命值 + dash 状态”
- `BattlePanel` 的两行文本布局仍保持稳定分离，不再出现重叠错绘

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
- 阶段 5 / 6 当前新增可调项主要集中在：
- `TutorialRoom` 中各教学节点的位置
- 教学提示文案
- 出口门控的开启时机
- 最小 HUD 的版面与提示表达
- `max_health`
- `damage_invulnerability_duration`
- `damage_knockback_speed`
- `damage_knockback_lift`
- `BasicMeleeEnemy.patrol_distance`
- `BasicMeleeEnemy.patrol_speed`
- `BasicMeleeEnemy.touch_damage`

## Exit Criteria

- 教程完成后能稳定进入 `CombatTrialRoom`
- 玩家拥有最小生命、受击、无敌与 `defeated` 闭环
- 战斗房的基础近战敌人能稳定制造第一次真实压力
- 玩家死亡后会被低摩擦地重置到战斗房本段起点
- HUD 能真实反映生命值与当前战斗提示
- 阶段 1 / 2 / 3 / 4 / 5 / 6 自动化验证全部通过
- 当前结果足以作为阶段 7 的稳定前置基线

当前状态：以上退出条件已满足。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 7：短链路主流程串联`

## Current Goal

当前 `codex/stage-6-minimal-real-combat-loop` worktree 已完成阶段 6 的首轮实现与自动化验证；当前目标是完成文档收口，并把这套“教程后实战压力 + 玩家受击 / 重置”的结果作为阶段 7 的稳定前置基线。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 6：最小真实战斗循环` 的首轮实现已经完成，当前处于文档收口与可合并评估阶段
- 本轮继续采用 `分支 + worktree`
- 本轮最终未启用 `multi-agent`，主代理按 TDD 串行收口完成实现与验证

## Recently Completed

- 阶段 6 的“最小真实战斗循环”首轮实现已完成：
- `Main` 已补上最小房间过渡与当前战斗房重置能力
- 新增 `CombatTrialRoom` 与 `BasicMeleeEnemy`
- 玩家已接入生命 / 受击 / 无敌 / `defeated`
- HUD 已改为真实读取生命值与当前战斗提示
- 新增 `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`，并确认阶段 1 / 2 / 3 / 4 / 5 / 6 自动化全部通过
- 阶段 4 的“最小能力差异”已完成并合并回 `main`
- 当前 `dash` 已同时具备输入契约、探索价值、战斗接敌价值与最小可读性反馈
- `main` 已成为阶段 5 的稳定起点
- 新建阶段 5 worktree，并补齐阶段 5 的设计文档、实现计划与进度页启动记录
- 阶段 5 教程区垂直切片已完整收口，自动化验证覆盖主入口迁移、教程顺序、`dash` 门槛、出口解锁与 HUD 战斗面板布局
- `codex/stage-5-tutorial-vertical-slice` 已本地合并回 `main`，主线 fresh 验证继续保持绿色
- 已确认阶段 5 完成后的默认路线为 `阶段 6 -> 阶段 7 -> 阶段 8`

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 6 最容易失控的方向是：把 checkpoint、多敌人、远程敌人、复杂 AI 与多房间流程一起提前混入
- `Main` 本轮只应补最小房间过渡与当前房间重置，不应顺势扩成完整房间系统
- 当前 `Main` 的房间切换逻辑仍是阶段 6 定向方案，尚未上升为正式房间系统
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

1. 基于当前阶段 6 稳定基线，开始阶段 7 的设计确认与短链路主流程规划。
2. 在进入阶段 7 前，补做一次更接近人工试玩的实战节奏复核，确认战斗房压力、重置摩擦与 HUD 读感。
3. 若阶段 7 写入范围可分离，继续按 `Main/房间流程`、`战斗房/玩家/敌人`、`HUD/测试/文档` 三块主动评估代理协作。
