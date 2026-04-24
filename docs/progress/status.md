# Nano Hunter Status

Last Updated: 2026-04-24

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 10：战斗变化与轻量成长循环（自动化与最终人工复核已通过）`

> Update: 2026-04-24 已在 `codex/stage-10-combat-variation-and-light-progression` worktree 完成 stage10 最终人工手操复核并收口：手操复核先复现了 `stage10_zone_aerial_room` 出生后立刻误触 `BranchZone` 的真实问题，随后通过上移支路入口并补回归测试修复；修复后主房间可稳定停留并吃到真实 `jump / attack` 输入，挑战房也已确认真实 `jump / attack / dash` 输入可以进场。Stage 1-10 GUT 已通过 `64/64`。

## Stage Goal

在阶段 9 已建立的首个小区域内容基线上，把当前玩法从“通过主线房间并处理两类基础敌人”推进到“存在战斗变化、可选支路、挑战房与轻量成长反馈”的下一版内容型切片。本轮固定不引入正式经济、装备、技能树或第二个大区域，优先验证：

- 新战斗动作 `空中攻击` 是否真的带来可读且有价值的战斗决策
- 第 `3` 类普通敌人是否能把现有遭遇节奏拉开
- `恢复点 + 收集物` 是否足以形成最小成长反馈
- `1` 条可选支路与 `1` 个挑战房` 是否能在不失控扩范围的前提下成立

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

- 玩家新增 `空中攻击`，且在至少一个房间 / 遭遇中有明确玩法价值
- 第 `3` 类普通敌人已接入，且其节奏与现有两类敌人明显不同
- 区域内存在 `1` 条可选支路与 `1` 个挑战房
- `恢复点 + 收集物` 的轻量成长反馈闭环成立
- HUD 通过现有稳定接口读取本轮新增最小信息，不回退到分散探测
- Stage 1-10 自动化验证通过
- 已完成最终人工复核，并能作为进入 `阶段 11` 的稳定前置基线

当前状态：第二轮可玩化接入已通过自动化验证、MCP 复核与最终人工手操复核。已确认 stage10 主房间不再出生即误切支路，空中攻击可在主房间内被真实输入触发，支路收益读值与挑战房三类敌人组合仍成立，当前结果可作为进入 `阶段 11` 前的稳定前置基线。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主
- 本轮重点不是 demo 级 polish，而是让“战斗变化 + 轻量成长反馈”先可看、可玩、可调
- 只有在玩法反馈已验证成立后，才进入更正式的视觉替换

## Next Stage

`阶段 11：可交付试玩 Demo 切片`

## Current Goal

当前 `codex/stage-10-combat-variation-and-light-progression` worktree 的下一步是阶段收口与提交拆分：

- 整理 stage10 最终验证与文档结论
- 评估提交拆分：`玩法修复 / 验证与文档收口`
- 作为稳定基线准备进入 `阶段 11`

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 10：战斗变化与轻量成长循环` 当前已完成自动化验证、MCP 复核与最终人工手操复核
- 本轮继续采用 `分支 + worktree`
- 本轮已固定关键选择：
  - 新动作：`空中攻击`
  - 敌人变化：`第 3 类普通敌人`
  - 成长反馈：`恢复点 + 收集物`
  - 区域变化：`1` 条可选支路 + `1` 个挑战房
- 当前已完成第二轮可玩化接入、最终人工试玩复核与回归验证，已可进入阶段收口

## Recently Completed

- 阶段 9 的首个小区域内容生产已完成并收口为当前稳定基线
- `Main` 已支持 stage9 的 checkpoint 恢复
- `GroundChargerEnemy` 已稳定接入
- 阶段 1-9 自动化验证已在主线上全部通过
- `main` 已补录 stage10 的正式阶段计划：
  - `plan/2026-04-24-stage-10-combat-variation-and-light-progression.md`
- `stage10_zone_aerial_room` 的支路入口误触已在人工手操复核中被复现、修复并补回归测试

## Risks And Blockers

- 当前最容易失控的方向是：把 stage10 直接做成“第二个大区域”或“半个 stage11”
- 若把空中攻击、第三类敌人、支路、挑战房与成长反馈同时做得过深，容易把本轮拖成系统堆积
- 若恢复点和收集物直接扩成正式经济 / 存档系统，会提前越过本轮边界
- 当前 worktree 内 `git` 命令仍需要显式处理 `safe.directory`

## Recommended Roadmap

- `阶段 10：战斗变化与轻量成长循环`
  - 目标：在 stage9 已成立的小区域基线上，引入更明确的战斗变化、可选支路与轻量成长反馈
- `阶段 11：可交付试玩 Demo 切片`
  - 目标：把前面验证成立的系统与内容收成更完整的 demo 级体验

## Next Recommended Steps

1. 在当前 stage10 worktree 中先完成 preflight 文档与 fresh 验证
2. 然后进入“空中攻击 / 第 3 类敌人 / 区域成长反馈”三块实现拆分
3. 在阶段收口前，明确补做一次完整人工复核，而不是只依赖自动化
