# Nano Hunter Status

Last Updated: 2026-04-25

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 11：可交付试玩 Demo 切片（已完成并收口）`

> Update: 2026-04-25 `stage11` 已完成并收口进 `main`：主线已从 `Main.tscn` 稳定推进到 `stage11_demo_end_room`，Stage 11 专项 GUT `5/5 passed`，Stage 1-11 全量 GUT `69/69 passed`，并且本轮新增的 `godot-mcp-pro` 联通脚本与排障文档已随阶段结果进入主线。

## Stage Goal

把当前 `stage1-10` 已验证成立的内容收成一个可连续试玩、可失败重来、可到达终点并给出明确完成反馈的 demo 级切片。本轮固定不新增新的核心动作、敌人类别、第二个大区域、正式经济系统或完整剧情系统，重点收束：

- 主线推进到 demo 终点
- 支路与挑战房的保留价值
- HUD / 门控 / 终点反馈的可读性
- `stage11` 触达代码的注释可维护性

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
  - `stage11_demo_end_room`
- 当前 demo 已具备：
  - 明确终点房
  - 最小完成反馈
  - 重开试玩入口
  - 支路 / 挑战房保留
  - 失败 / 重来继续成立

## Adjustable Now

- 玩家关键参数继续统一由 `res://scenes/player/player_placeholder_config.tres` 驱动
- 房间与敌人关键参数继续由只读配置资源驱动
- 当前 demo 收束仍主要通过以下入口调整：
  - `scripts/main/main.gd`
  - `scripts/ui/tutorial_hud.gd`
  - `scripts/rooms/stage11_demo_end_room.gd`
  - `assets/configs/rooms/stage9_zone_*.tres`
  - `assets/configs/rooms/stage10_zone_*.tres`

## Exit Criteria

- demo 主链路可从开始稳定推进到终点
- 支路与挑战房仍可进入且不破坏主线
- 失败 / 重来仍能回到正确推进点
- HUD / 门控 / 终点反馈足以支撑试玩理解
- `stage11` 触达的核心脚本满足新的注释最低覆盖标准
- Stage 1-11 自动化验证通过
- 人工复核与运行态证据已留痕，可支持本轮收口判断

当前状态：以上条件已满足，阶段 11 已成为当前新的稳定主线基线。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主
- 本轮重点不是正式美术替换，而是把现有内容收成 demo 级体验
- 只有在当前 demo 反馈稳定后，才继续进入更正式的视觉替换

## Next Stage

`待阶段 11 收口后再定`

## Current Goal

当前 `main` 的下一步固定为：

- 基于已收口的 demo 基线决定后续方向
- 如继续新阶段，先从当前 `main` 开新分支 / worktree

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 11：可交付试玩 Demo 切片` 当前已完成并合并进主线
- 本轮继续采用 `分支 + worktree`
- 本轮已固定并完成的关键选择：
  - demo 形态：`扩成完整 Demo`
  - 内容策略：`复用 stage9-10 内容 + 新增最小终点表达`
  - 注释要求：`文件头职责注释 + 关键流程分段注释`
  - 工程补充：`godot-mcp-pro` 联通脚本与排障文档`

## Recently Completed

- 阶段 10 已完成并作为当前稳定前置基线
- `main` 已补录 stage11 的正式阶段计划：
  - `plan/2026-04-24-stage-11-playable-demo-slice.md`
- 阶段 1-10 的关键脚本与测试文件已补做一轮注释补强
- stage11 已新增：
  - `stage11_demo_end_room`
  - `tests/stage11/test_stage_11_playable_demo_slice.gd`
  - Stage 11 灰盒主线自动化驾驶器
  - `docs/dev/godot-mcp-pro-connectivity-guide.md`
  - `scripts/dev/check / safe-repair / force-repair / open / enter-worktree`

## Risks And Blockers

- 当前最主要的剩余风险不是玩法，而是文档是否完整、收口是否干净
- `godot_mcp` 当前已被工程化留痕，但后续新会话仍需按文档顺序进场，不能把脚本误当成“永远自动恢复”
- 当前 worktree 内 `git` 命令仍需要显式处理 `safe.directory`

## Recommended Roadmap

- 当前已形成一条可交付试玩 demo 的稳定主线
- 后续路线待下一轮设计确认后再定

## Next Recommended Steps

1. 以当前 `main` 作为新的稳定基线
2. 再决定是否进入下一阶段的设计与 preflight
