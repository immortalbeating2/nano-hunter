# Nano Hunter Status

Last Updated: 2026-04-24

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 8：系统稳固与内容生产前准备（首轮实现与验证已完成）`

> Update: 2026-04-24 已完成 Stage 8 首轮实现：玩家关键参数、房间流程参数与基础敌人关键参数已收口到只读配置资源；HUD 已统一消费房间 / 玩家快照接口；`BasicMeleeEnemy` 已整理为基于 `base_enemy.gd` 的最小模板入口，并通过阶段 1-8 自动化验证。

## Stage Goal

在阶段 7 已完成的三段短链路主流程基线上，把当前系统从“可玩原型”收口为“更适合持续扩内容的稳定工程基线”。本轮固定优先完成参数数据化，其次收口 HUD 第二轮接口，最后把 `BasicMeleeEnemy` 整理成更可复用的敌人模板入口，而不引入新能力、新房间、新敌人种类或更长主流程。

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
- `Main` 不再依赖阶段 6 的定向切房判断，而是统一消费房间侧 `room_transition_requested`
- `CombatTrialRoom` 现已在清房后稳定过渡到 `GoalTrialRoom`
- 新增 `GoalTrialRoom`，包含“先击败守门敌人 -> 再穿过已解锁空间门控 -> 抵达目标点”的最小混合门控目标流程
- HUD 现可在教学房、实战房、目标房与短链路完成态之间切换提示
- 玩家关键参数现已通过 `res://scenes/player/player_placeholder_config.tres` 统一驱动
- 房间标题 / 提示 / 出生点 / 阈值现已通过 `res://assets/configs/rooms/*.tres` 统一驱动
- `TutorialHUD` 现统一读取房间 `get_hud_context()` 与玩家 `get_hud_status_snapshot()`
- `BasicMeleeEnemy` 现已通过 `res://scripts/combat/base_enemy.gd` 收口基础契约，并通过只读配置资源驱动关键参数

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
- 当前 Stage 8 已新增的主要只读配置入口：
- `res://scenes/player/player_placeholder_config.tres`
- `res://scripts/configs/basic_melee_enemy_config.tres`
- `res://scripts/configs/goal_trial_melee_enemy_config.tres`
- `res://assets/configs/rooms/tutorial_room_flow.tres`
- `res://assets/configs/rooms/combat_trial_room_flow.tres`
- `res://assets/configs/rooms/goal_trial_room_flow.tres`
- `max_health`
- `damage_invulnerability_duration`
- `damage_knockback_speed`
- `damage_knockback_lift`
- `BasicMeleeEnemy.patrol_distance`
- `BasicMeleeEnemy.patrol_speed`
- `BasicMeleeEnemy.touch_damage`

## Exit Criteria

- 玩家关键参数已从只读配置资源稳定读取并成功应用
- `BasicMeleeEnemy` 关键参数已从只读配置资源稳定读取并成功应用
- HUD 已改为统一消费稳定只读接口，而不是继续依赖零散探测
- `BasicMeleeEnemy` 已整理成可复用模板入口，且现有行为不回归
- `Main`、`TutorialRoom`、`CombatTrialRoom` 与 `GoalTrialRoom` 的当前三段主流程保持稳定，不因系统收口而断链
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 自动化验证全部通过
- 当前结果足以作为继续扩内容的稳定前置基线

当前状态：以上退出条件已完成首轮实现与验证，当前结果可作为继续扩内容前的稳定前置基线。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 8：系统稳固与内容生产前准备`

## Current Goal

阶段 8 已合并回 `main` 并完成分支 / worktree 清理。当前主线目标已切换为：以参数数据化、HUD 第二轮接口和基础敌人模板化结果作为新的稳定基线，再决定下一轮更偏内容生产还是继续小范围系统收口，而不是继续在 stage8 worktree 内追加临时扩展。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `main` 当前已承载阶段 8 的稳定结果，可直接作为后续继续扩内容前的前置基线
- 阶段 8 的 `分支 + worktree` 已完成收口，Git 元数据和物理目录都已清理
- 本轮已按“玩家配置 / HUD 接口 / 敌人模板与测试文档”拆分并实际启用代理协作
- 当前不再有挂起中的 stage8 收口动作

## Recently Completed

- 阶段 7 的“短链路主流程串联”已完成并收口为当前稳定基线
- `Main` 已稳定推进 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- HUD 已能随教学房、实战房、目标房与完成态切换提示
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 自动化验证已在主线上全部通过
- 已基于干净 `main` 建立 `codex/stage-8-systems-hardening-and-content-prep` 与 `.worktrees/stage-8-systems-hardening-and-content-prep`
- 已补齐 stage8 的执行版计划、设计文档与进度启动记录
- 玩家参数、房间流程参数与基础敌人关键参数已收口到只读资源
- `TutorialHUD` 已改为统一消费稳定只读接口
- `BasicMeleeEnemy` 已整理成基于 `base_enemy.gd` 的最小模板入口
- `godot --headless --path . --import` 与阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 GUT 已全部通过
- 已将 `codex/stage-8-systems-hardening-and-content-prep` 本地合并回 `main`
- 已清理阶段 8 本地分支与 `.worktrees/stage-8-systems-hardening-and-content-prep` 物理目录

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 8 最容易失控的方向是：借“系统稳固”之名继续扩玩法内容，或者提前铺过重的数据/模板基础设施
- 若 HUD 第二轮同时改结构和表现，容易让本轮从“接口收口”滑向“大规模 UI 重做”
- 若敌人模板化过早扩成第二类敌人，会直接把本轮拖回新内容开发
- 当前 worktree 内 `git` 命令需要显式处理 `safe.directory`，后续实现与验证时要保持这一点的一致性
- 当前桌面会话里的 `godot-mcp` 工具仍未恢复到可直接调用状态；本轮已定位为“Codex 侧 bridge 未在 6505-6509 重建监听”，并已采用 shell + headless 验证完成 fallback

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

1. 基于当前 Stage 8 主线结果，先做一次路线判断：下一轮是偏内容生产扩展，还是继续小范围系统收口。
2. 若继续扩内容，优先复用现有配置资源和敌人模板，不回退到脚本级散落参数。
3. 若再开新阶段，继续沿用这次的收口顺序：先 fresh 验证，再 merge，最后按占用进程顺序清理 worktree。
