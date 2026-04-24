# Nano Hunter Status

Last Updated: 2026-04-24

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 11：可交付试玩 Demo 切片（preflight 已完成）`

> Update: 2026-04-24 已从完成注释补强并同步到 `main` 的稳定基线出发，正式建立 `codex/stage-11-playable-demo-slice` 与对应 worktree，并完成 stage11 preflight。`godot --headless --path . --import`、Stage 1-10 GUT 与 `git diff --check` 已通过；当前阶段 11 已可从这条基线进入正式实现。

## Stage Goal

把当前 `stage1-10` 已验证成立的内容收成一个可连续试玩、可失败重来、可到达终点并给出明确完成反馈的 demo 级切片。本轮固定不新增新的核心动作、敌人类别、第二个大区域、正式经济系统或完整剧情系统，优先收束：

- 主线推进是否已经足够完整
- 支路与挑战房是否仍有明确价值
- HUD、门控与终点反馈是否足够可理解
- `stage11` 触达代码的注释是否已经达到可维护阅读基线

## Playable Now

- `godot --path .` 当前进入 `Main.tscn`，默认从教程主线开始
- 当前稳定主线链路已成立：
  - `TutorialRoom`
  - `CombatTrialRoom`
  - `GoalTrialRoom`
  - `stage9_zone_entry_room`
  - `stage9_zone_combat_room`
  - `stage9_zone_charger_room`
  - `stage9_zone_switch_room`
  - `stage9_zone_final_room`
  - `stage10_zone_aerial_room`
  - `stage10_zone_branch_room`
  - `stage10_zone_challenge_room`
- 玩家当前稳定具备：
  - 基础移动 / 跳跃
  - 地面 `dash`
  - 地面普通攻击
  - 基础生命 / 受击 / 无敌 / defeated 闭环
- 当前稳定敌人类型为：
  - `BasicMeleeEnemy`
  - `GroundChargerEnemy`
  - `AerialSentinelEnemy`
- 当前已成立的轻量区域基线为：
  - checkpoint 恢复
  - 开关门门控
  - 主线清房推进
  - HUD 稳定读取房间与玩家快照
  - stage10 可选支路 / 挑战房的收集物与恢复点快照

## Adjustable Now

- 玩家关键参数继续统一由 `res://scenes/player/player_placeholder_config.tres` 驱动
- 基础敌人与房间关键参数继续由只读配置资源驱动
- 当前可直接调的 stage9 入口包括：
  - `res://scripts/configs/ground_charger_enemy_config.tres`
  - `res://assets/configs/rooms/stage9_zone_*.tres`
- 当前 stage10 已新增：
  - `res://scripts/configs/aerial_sentinel_enemy_config.tres`
  - `res://assets/configs/rooms/stage10_zone_*.tres`
  - `Stage10RoomBase.get_stage10_progress_snapshot()`

## Exit Criteria

- demo 主链路可从开始稳定推进到终点
- 支路与挑战房仍可进入且不破坏主线
- 失败 / 重来仍能回到正确推进点
- HUD / 门控 / 终点反馈足以支撑试玩理解
- `stage11` 触达的核心脚本满足新的注释最低覆盖标准
- Stage 1-11 自动化验证通过
- 已完成最终人工复核，并能作为“可交付试玩 Demo 切片”的稳定基线

当前状态：阶段 10 已完成并作为当前稳定前置基线存在；阶段 11 的设计与 preflight 已完成，当前 worktree 已可进入 demo 闭环实现。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主
- 本轮重点不是 demo 级 polish，而是让“战斗变化 + 轻量成长反馈”先可看、可玩、可调
- 只有在玩法反馈已验证成立后，才进入更正式的视觉替换

## Next Stage

`待阶段 11 收口后再定`

## Current Goal

当前 `codex/stage-11-playable-demo-slice` worktree 的下一步固定为：

- 落地 demo 终点闭环与完成反馈
- 收束 HUD / 门控 / 终点提示的最小 polish
- 同步把 stage11 触达代码补到新的注释最低覆盖标准

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 11：可交付试玩 Demo 切片` 当前已完成 preflight，待进入正式实现
- 本轮继续采用 `分支 + worktree`
- 本轮已固定关键选择：
  - demo 形态：`扩成完整 Demo`
  - 内容策略：`复用 stage9-10 内容 + 新增最小终点表达`
  - 本轮不做：`新动作 / 新敌人类别 / 第二大区域 / 正式经济系统`
  - 注释要求：`文件头职责注释 + 关键流程分段注释`
- 当前已完成 worktree 建立、preflight 文档落盘与 baseline 验证

## Recently Completed

- 阶段 10 的战斗变化与轻量成长循环已完成收口，并成为当前稳定基线
- `stage10_zone_aerial_room` 的支路入口误触已在人工手操复核中被复现、修复并补回归测试
- `main` 已补录 stage11 的正式阶段计划：
  - `plan/2026-04-24-stage-11-playable-demo-slice.md`
- 阶段 1-10 的关键脚本与测试文件已补做一轮注释补强，`AGENTS.md` 也已改为更明确的最低注释覆盖标准

## Risks And Blockers

- 当前最容易失控的方向是：把 stage11 再做成“继续扩内容”，而不是“收成 demo”
- 若把 HUD polish、demo 终点反馈和主流程控制同时做得过深，容易重新滑向系统重构
- 若实现阶段忘记同步注释补强，本轮会再次在低可读性基线上叠内容
- 当前 worktree 内 `git` 命令仍需要显式处理 `safe.directory`

## Recommended Roadmap

- `阶段 11：可交付试玩 Demo 切片`
  - 目标：把前面验证成立的系统与内容收成一个可以对外试玩的完整 demo 级体验

## Next Recommended Steps

1. 在当前 stage11 worktree 中进入 demo 终点闭环实现
2. 然后进入 HUD / 门控可读性与注释补强三块收束
3. 在阶段收口前补做完整人工复核，而不是只依赖自动化
