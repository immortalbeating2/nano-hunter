# Nano Hunter Status

Last Updated: 2026-04-25

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 12：资产管线与第一轮 Demo 表现升级（preflight 已完成，可进入首轮实现）`

> Update: 2026-04-25 `stage12` 已从最新 `main` 创建 `codex/stage-12-asset-pipeline-and-demo-polish` 与 `.worktrees/stage-12-asset-pipeline-and-demo-polish`。本轮固定采用 `规范 + 轻替换`，先建立资产管线和第一轮 demo 可读性升级，不新增新区域、新核心玩法或大规模正式美术替换。Preflight fresh baseline 已通过：`godot --headless --path . --import` 通过，Stage 1-11 全量 GUT `69/69 passed`，`git diff --check` 通过。

## Stage Goal

在 Stage 11 已收口的可交付试玩 demo 基线上，建立后续资产生产与接入的稳定管线，并完成第一轮轻量 Demo 表现升级。本轮固定不新增新区域、新核心玩法、新敌人类型、正式存档、经济系统或完整剧情系统，重点收束：

- 资产目录规范
- `docs/assets/asset-manifest.md`
- `docs/assets/asset-ingestion-checklist.md`
- 玩家 / 敌人 / HUD / 门控 / checkpoint / 终点反馈的轻量可读性接入
- 自动化验证与人工复核收口

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

当前状态：Stage 12 preflight 已完成；Stage 11 仍是当前可试玩稳定基线。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主
- 本轮重点不是正式美术替换，而是把现有内容收成 demo 级体验
- 只有在当前 demo 反馈稳定后，才继续进入更正式的视觉替换

## Next Stage

`阶段 12：资产管线与第一轮 Demo 表现升级（首轮实现待开始）`

## Current Goal

当前 `main` 的下一步固定为：

- 建立资产管线和第一批轻量可读性接入任务边界
- 优先落地 `docs/assets/asset-manifest.md` 与 `docs/assets/asset-ingestion-checklist.md`
- 保持 Stage 11 demo 主链路作为当前稳定回归基线

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 12：资产管线与第一轮 Demo 表现升级` 当前 preflight 已完成，可进入首轮实现
- 本轮采用 `分支 + worktree`
- 本轮已固定的关键选择：
  - 资产强度：`规范 + 轻替换`
  - 阶段目标：`资产管线定型 + 第一轮 Demo 表现升级`
  - 开发现场：`codex/stage-12-asset-pipeline-and-demo-polish` + `.worktrees/stage-12-asset-pipeline-and-demo-polish`
  - 人工复核：阶段收口前必须完整跑 demo、支路、挑战房、失败 / 重来、完成反馈与重开入口

## Recently Completed

- 阶段 12-16 路线已正式补入主线并同步到 `AGENTS.md`
- Stage 12 正式开发计划已补入：
  - `plan/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
- Stage 12 独立设计文档与实现计划已启动：
  - `spec-design/2026-04-25-stage-12-asset-pipeline-and-demo-polish-design.md`
  - `docs/implementation-plans/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
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
- 后续路线已正式补为 Stage 12-16：
  - `阶段 12：资产管线与第一轮 Demo 表现升级`
  - `阶段 13：第二小区域内容生产`
  - `阶段 14：回溯与能力门控成型`
  - `阶段 15：战斗高潮与首个精英 / Boss 原型`
  - `阶段 16：Alpha Demo 打包候选`
- 路线总入口：
  - `spec-design/2026-04-25-stage-12-to-stage-16-roadmap.md`

## Next Recommended Steps

1. 进入资产目录、资产清单与接入检查清单实现
2. 按 `规范 + 轻替换` 接入第一批可读性资产样例
3. 完成 Stage 12 自动化验证与人工复核
