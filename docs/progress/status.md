# Nano Hunter Status

Last Updated: 2026-04-24

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 10：战斗变化与轻量成长循环（设计与 preflight 中）`

> Update: 2026-04-24 已从已收口的 `stage9` 稳定基线建立 `codex/stage-10-combat-variation-and-light-progression` 与对应 worktree。当前已锁定本轮关键选择为“`空中攻击` + `第 3 类普通敌人` + `恢复点 + 收集物` + `1` 条可选支路 + `1` 个挑战房”，并正在补齐 stage10 的设计、实现计划与进度启动记录。

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
- 玩家当前稳定具备：
  - 基础移动 / 跳跃
  - 地面 `dash`
  - 地面普通攻击
  - 基础生命 / 受击 / 无敌 / defeated 闭环
- 当前稳定敌人类型为：
  - `BasicMeleeEnemy`
  - `GroundChargerEnemy`
- 当前已成立的轻量区域基线为：
  - checkpoint 恢复
  - 开关门门控
  - 主线清房推进
  - HUD 稳定读取房间与玩家快照

## Adjustable Now

- 玩家关键参数继续统一由 `res://scenes/player/player_placeholder_config.tres` 驱动
- 基础敌人与房间关键参数继续由只读配置资源驱动
- 当前可直接调的 stage9 入口包括：
  - `res://scripts/configs/ground_charger_enemy_config.tres`
  - `res://assets/configs/rooms/stage9_zone_*.tres`
- 当前 stage10 尚未新增：
  - 空中攻击参数资源
  - 第 `3` 类敌人配置资源
  - 收集物 / 恢复点快照读值

## Exit Criteria

- 玩家新增 `空中攻击`，且在至少一个房间 / 遭遇中有明确玩法价值
- 第 `3` 类普通敌人已接入，且其节奏与现有两类敌人明显不同
- 区域内存在 `1` 条可选支路与 `1` 个挑战房
- `恢复点 + 收集物` 的轻量成长反馈闭环成立
- HUD 通过现有稳定接口读取本轮新增最小信息，不回退到分散探测
- Stage 1-10 自动化验证通过
- 已完成最终人工复核，并能作为进入 `阶段 11` 的稳定前置基线

当前状态：以上退出条件尚未开始实现验证，当前仅完成 stage10 的目标锁定与 preflight 启动。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主
- 本轮重点不是 demo 级 polish，而是让“战斗变化 + 轻量成长反馈”先可看、可玩、可调
- 只有在玩法反馈已验证成立后，才进入更正式的视觉替换

## Next Stage

`阶段 11：可交付试玩 Demo 切片`

## Current Goal

当前 `codex/stage-10-combat-variation-and-light-progression` worktree 的目标是先完成 stage10 preflight：

- 补齐设计文档
- 补齐实现计划
- 更新状态页、时间线与当日日志
- 明确本轮范围与不做项
- 完成 fresh 基线验证

然后再进入正式实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 10：战斗变化与轻量成长循环` 当前处于设计与 preflight 中
- 本轮继续采用 `分支 + worktree`
- 本轮已固定关键选择：
  - 新动作：`空中攻击`
  - 敌人变化：`第 3 类普通敌人`
  - 成长反馈：`恢复点 + 收集物`
  - 区域变化：`1` 条可选支路 + `1` 个挑战房
- 当前 preflight 只补设计、计划与进度启动记录，不混入玩法实现

## Recently Completed

- 阶段 9 的首个小区域内容生产已完成并收口为当前稳定基线
- `Main` 已支持 stage9 的 checkpoint 恢复
- `GroundChargerEnemy` 已稳定接入
- 阶段 1-9 自动化验证已在主线上全部通过
- `main` 已补录 stage10 的正式阶段计划：
  - `plan/2026-04-24-stage-10-combat-variation-and-light-progression.md`

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
