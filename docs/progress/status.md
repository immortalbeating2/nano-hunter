# Nano Hunter Status

Last Updated: 2026-04-23

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 7：短链路主流程串联（设计与 preflight 中）`

> Update: 2026-04-23 已从阶段 6 稳定基线建立 `codex/stage-7-short-mainline-chain` 与对应 worktree，当前只完成 stage7 的设计、计划与进度启动记录，尚未进入玩法实现。

## Stage Goal

在阶段 6 已完成的最小真实战斗循环基线上，把当前 `TutorialRoom -> CombatTrialRoom` 扩展为一条真正可顺序推进的短主流程：`TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`。本轮固定验证三段流转、混合门控目标房、最小房间契约升级和三段 HUD 提示，而不引入大地图、存档、正式 checkpoint、多分支路线或第二类敌人。

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
- 当前主流程仍只到 `CombatTrialRoom` 为止，尚未接入阶段 7 的 `GoalTrialRoom`

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

- `Main` 能稳定推进 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- `GoalTrialRoom` 满足主房间契约，并提供独立出生点与明确完成条件
- 目标房初始门控关闭，满足条件后解锁
- HUD 能随教学房、实战房、目标房与完成态切换提示
- 玩家若在 `CombatTrialRoom` 中失败，仍只重置当前战斗房，不回滚整条链路
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 自动化验证全部通过
- 当前结果足以作为阶段 8 的稳定前置基线

当前状态：以上退出条件尚未开始验证，当前仅完成设计与 preflight。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 8：系统稳固与内容生产前准备`

## Current Goal

当前 `codex/stage-7-short-mainline-chain` worktree 的目标是先完成 stage7 preflight：补齐设计文档、实现计划、状态页、时间线和当日日志启动记录，并把“三段顺序链路 + 混合门控目标房 + 代理协作硬约束”写成明确起点，再进入正式实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 7：短链路主流程串联` 当前处于设计与 preflight 中
- 本轮继续采用 `分支 + worktree`
- 当前 preflight 只补文档与启动留痕，不混入玩法代码实现
- 本轮已明确把 `subagent / multi-agent` 写成实现硬约束：满足“2 个以上子任务、写入可隔离、验证可独立、下一步不强依赖单一结果”时，必须启用代理协作

## Recently Completed

- 阶段 6 的“最小真实战斗循环”已完成并收口为当前稳定基线
- `Main` 已具备最小房间过渡与当前战斗房重置能力
- `CombatTrialRoom`、`BasicMeleeEnemy`、玩家生命 / 受击 / `defeated` 与 HUD 真实读值均已成立
- 阶段 1 / 2 / 3 / 4 / 5 / 6 自动化验证已在主线上全部通过
- 已基于干净 `main` 建立 `codex/stage-7-short-mainline-chain` 与 `.worktrees/stage-7-short-mainline-chain`
- 已补齐 stage7 的设计文档、实现计划与进度启动记录

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 7 最容易失控的方向是：把三段短链路顺势扩成完整房间图、地图系统或正式 checkpoint
- `GoalTrialRoom` 若做成纯平台或纯战斗，会削弱本轮验证价值
- 当前 `Main` 的房间切换逻辑仍是阶段 6 定向方案，尚未上升为三段顺序链路
- 若本轮在实现时再次把代理协作只停留在文字上，而没有真正启用，会重复阶段 6 的执行偏差

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

1. 在当前 stage7 worktree 中完成 preflight 收口后，正式进入“三段顺序链路”实现。
2. 实现开始前先按 `Main/房间流转`、`GoalTrialRoom/门控流程`、`HUD/测试/文档` 三块做代理拆分，并按计划实际启用 `multi-agent` 或降级后的 `subagent`。
3. 优先保持范围稳定，不提前混入阶段 8 的系统稳固项。
