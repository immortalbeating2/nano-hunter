# Nano Hunter Status

Last Updated: 2026-04-24

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 9：首个小区域内容生产（设计与 preflight 中）`

> Update: 2026-04-24 已从阶段 8 稳定基线建立 `codex/stage-9-first-content-zone-production` 与对应 worktree，当前只完成 stage9 的设计、正式计划与进度启动记录，尚未进入玩法实现。

## Stage Goal

在阶段 8 已完成的系统稳固基线上，做出第一个真正像“游戏区域”的内容段：`4-6` 房间的线性主线区，接入第 `2` 类敌人、首个正式 checkpoint 与第一种正式门控，验证当前配置资源、HUD 接口与敌人模板是否足以支撑内容生产。

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
- 当前仍只有 1 类基础敌人
- 当前还没有正式 checkpoint
- 当前还没有真正意义上的小区域关卡

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

- 已完成一个 `4-6` 房间的线性主线小区域
- 第 `2` 类敌人“地面冲锋敌”已接入并稳定工作
- 首个正式 checkpoint 与开关门门控已接入主流程
- 现有配置资源、HUD 接口和敌人模板已被真正用于内容生产
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 / 9 自动化验证全部通过
- 当前结果足以承接 `阶段 10：战斗变化与轻量成长循环`

当前状态：以上退出条件尚未开始验证，当前仅完成设计与 preflight。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 当前阶段允许继续在不阻塞玩法验证的前提下，混合使用占位资源、免费替代资源与少量临时美术探索
- 本轮重点是“先让小区域真正成立”，而不是在阶段 9 前半段就推进 demo 级视觉 polish

## Next Stage

`阶段 10：战斗变化与轻量成长循环`

## Current Goal

当前 `codex/stage-9-first-content-zone-production` worktree 的目标是先完成 stage9 preflight：补齐设计文档、正式计划、状态页、时间线与当日日志启动记录，并把“小区域线性主线、第 2 类敌人、checkpoint、开关门”的边界写成明确起点，再进入正式实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 9：首个小区域内容生产` 当前处于设计与 preflight 中
- 本轮继续采用 `分支 + worktree`
- 当前 preflight 只补计划、设计与进度启动记录，不混入任何玩法实现
- 本轮已明确固定：
  - 第 `2` 类敌人：`地面冲锋敌`
  - checkpoint：`房间入口存档点`
  - 门控：`开关门`
  - 区域结构：`线性主线区`

## Recently Completed

- 阶段 8 的“系统稳固与内容生产前准备”已完成并收口为当前稳定基线
- 玩家参数、房间流程参数与基础敌人关键参数已收口到只读资源
- `TutorialHUD` 已改为统一消费稳定只读接口
- `BasicMeleeEnemy` 已整理成基于 `base_enemy.gd` 的最小模板入口
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 自动化验证已在主线上全部通过
- 已基于干净 `main` 建立 `codex/stage-9-first-content-zone-production` 与 `.worktrees/stage-9-first-content-zone-production`
- 已补齐 stage9 的正式计划与执行清单

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 9 最容易失控的方向是：直接把小区域做成带支路的小地图
- 若地面冲锋敌一上来就做得过重，会把本轮拖成敌人系统扩张
- 若 checkpoint 和门控继续写死在房间脚本里，会削弱阶段 8 配置化成果的验证价值
- 当前 worktree 内 `git` 命令需要显式处理 `safe.directory`

## Recommended Roadmap

- `阶段 9：首个小区域内容生产`
- 目标：用阶段 8 建立的配置资源、HUD 接口和敌人模板，真正产出第一段“像游戏区域”的内容，而不是继续只做系统收口
- 范围：`4-6` 个连续房间、第 `2` 类敌人、`2-3` 组遭遇组合、第一个正式 checkpoint / 区域重置点与更正式的门控类型
- `阶段 10：战斗变化与轻量成长循环`
- 目标：让玩法不再只是“过门 + 打一种敌人”，而开始出现战斗变化、路线变化和轻量成长反馈
- 范围：第 `3` 类敌人或精英变体、`1` 个战斗扩展动作、可选支路、挑战房、恢复点 / 收集物等轻量成长反馈
- `阶段 11：可交付试玩 Demo 切片`
- 目标：把前面的系统和内容收成一个可以对外试玩、可连续体验、完成度明显更高的 demo 版本
- 范围：`8-12` 个房间的完整 demo 区域、阶段性终点、HUD / 文案 / 节奏 polish、关键视觉替换与 demo 级 QA

## Next Recommended Steps

1. 在当前 stage9 worktree 中完成 preflight 收口后，正式进入小区域线性主线内容生产。
2. 实现开始前，先按“小区域房间 / 地面冲锋敌 / Stage 9 GUT 与文档留痕”三块拆分代理协作。
3. 保持范围稳定，不提前混入阶段 10 的玩家新动作、支路或成长循环。
## Update - 2026-04-24 Stage 9 Implementation Completion

### Current Stage

`阶段 9：首个小区域内容生产（已实现并完成自动化验证）`

### Current Playable Content

- 新增 5 个连续房间的线性主线小区域：
  - `stage9_zone_entry_room`
  - `stage9_zone_combat_room`
  - `stage9_zone_charger_room`
  - `stage9_zone_switch_room`
  - `stage9_zone_final_room`
- 新增第 2 类敌人 `GroundChargerEnemy`，行为为“短巡逻 -> 触发后横向冲锋 -> 恢复”
- `Main` 现已支持运行期 checkpoint 恢复；stage9 中会记录最近一次房间入口恢复点
- stage9 已接入首个正式开关门；`stage9_zone_switch_room` 可通过开关解除门控
- 最终房 `stage9_zone_final_room` 使用 `BasicMeleeEnemy + GroundChargerEnemy` 的混合遭遇收口

### Current Adjustable Entries

- `res://scripts/configs/ground_charger_enemy_config.tres`
  - `patrol_distance`
  - `patrol_speed`
  - `touch_damage`
  - `trigger_distance`
  - `charge_speed`
  - `charge_duration`
  - `recovery_duration`
- `res://assets/configs/rooms/stage9_zone_*.tres`
  - 房间标题
  - HUD 提示
  - 房间入口 spawn

### Verification Snapshot

- `godot --headless --path . --import`：通过
- Stage 1-9 GUT：全部通过
- `git diff --check`：通过
- `godot_mcp` 当前会话连通性：已恢复；`get_open_scripts` 返回 `count = 0`

### Residual Notes

- `godot --headless --path . --import` 退出时仍会输出历史性的 `ObjectDB instances leaked at exit`
- Stage 9 GUT 当前有 1 条 `unfreed children` warning，测试结果仍为 `4/4 passed`

### Next Stage

`阶段 10：战斗变化与轻量成长循环`
