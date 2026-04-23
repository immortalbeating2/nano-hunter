# Nano Hunter Status

Last Updated: 2026-04-23

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 8：系统稳固与内容生产前准备（设计与 preflight 中）`

> Update: 2026-04-23 已从阶段 7 稳定基线建立 `codex/stage-8-systems-hardening-and-content-prep` 与对应 worktree，当前只完成 stage8 的设计、执行版计划与进度启动记录，尚未进入任何玩法实现。

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
- 当前关键参数仍主要散落在玩家、敌人和房间脚本的导出字段中
- 当前 HUD 仍主要依赖房间/玩家脚本的分散读取方式，尚未形成稳定接口层
- 当前 `BasicMeleeEnemy` 仍是可用原型，但还没有整理成可复用模板入口

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

- 玩家关键参数已从只读配置资源稳定读取并成功应用
- `BasicMeleeEnemy` 关键参数已从只读配置资源稳定读取并成功应用
- HUD 已改为统一消费稳定只读接口，而不是继续依赖零散探测
- `BasicMeleeEnemy` 已整理成可复用模板入口，且现有行为不回归
- `Main`、`TutorialRoom`、`CombatTrialRoom` 与 `GoalTrialRoom` 的当前三段主流程保持稳定，不因系统收口而断链
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 自动化验证全部通过
- 当前结果足以作为继续扩内容的稳定前置基线

当前状态：以上退出条件尚未开始验证，当前仅完成设计与 preflight。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 8：系统稳固与内容生产前准备`

## Current Goal

当前 `codex/stage-8-systems-hardening-and-content-prep` worktree 的目标是先完成 stage8 preflight：补齐设计文档、执行版计划、状态页、时间线和当日日志启动记录，并把“参数数据化优先 / HUD 第二轮 / 敌人模板化 / 不扩玩法内容”写成明确起点，再进入正式实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 8：系统稳固与内容生产前准备` 当前处于设计与 preflight 中
- 本轮继续采用 `分支 + worktree`
- 当前 preflight 只补计划、设计与进度启动记录，不混入任何玩法实现
- 本轮已明确把 `subagent / multi-agent` 写成实现硬约束：满足“2 个以上子任务、写入可隔离、验证可独立、下一步不强依赖单一结果”时，应实际启用代理协作

## Recently Completed

- 阶段 7 的“短链路主流程串联”已完成并收口为当前稳定基线
- `Main` 已稳定推进 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- HUD 已能随教学房、实战房、目标房与完成态切换提示
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 自动化验证已在主线上全部通过
- 已基于干净 `main` 建立 `codex/stage-8-systems-hardening-and-content-prep` 与 `.worktrees/stage-8-systems-hardening-and-content-prep`
- 已补齐 stage8 的执行版计划、设计文档与进度启动记录

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 8 最容易失控的方向是：借“系统稳固”之名继续扩玩法内容，或者提前铺过重的数据/模板基础设施
- 若 HUD 第二轮同时改结构和表现，容易让本轮从“接口收口”滑向“大规模 UI 重做”
- 若敌人模板化过早扩成第二类敌人，会直接把本轮拖回新内容开发
- 当前 worktree 内 `git` 命令需要显式处理 `safe.directory`，后续实现与验证时要保持这一点的一致性

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

1. 在当前 stage8 worktree 中完成 preflight 收口后，正式进入参数数据化与 HUD / 敌人模板化实现。
2. 实现开始前先按“配置资源 / HUD 接口 / 敌人模板 + 测试文档”三块拆分任务，并优先实际启用代理协作。
3. 保持范围稳定，不提前混入阶段 9 级别的新内容扩张。
