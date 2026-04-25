# Stage 12 Asset Pipeline and Demo Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 来按任务执行本计划。步骤使用 checkbox (`- [ ]`) 语法跟踪。

**Goal:** 在 Stage 11 demo 基线上建立资产管线，并完成第一轮轻量 Demo 表现升级。

**Architecture:** 继续复用现有 `Main`、房间流转契约、HUD 快照接口、checkpoint、敌人基础契约与 Stage 11 灰盒主线验证。不新增新核心玩法、不新增新区域、不重做 UI 系统；本阶段只建立资产目录、资产清单、资产接入检查方式，并接入少量关键可读性资产作为样例。

**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell、Markdown 文档

---

## Task 1: 完成 Stage 12 preflight、开发现场与 fresh 基线

**Files:**
- Create: `spec-design/2026-04-25-stage-12-asset-pipeline-and-demo-polish-design.md`
- Create: `docs/implementation-plans/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
- Create: `plan/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-25.md`

- [ ] 从最新 `main` 创建 `codex/stage-12-asset-pipeline-and-demo-polish`
- [ ] 创建对应 worktree，记录本轮采用 `分支 + worktree`
- [ ] 运行 Godot MCP 进场 dry-run，必要时按联通指南排障
- [ ] 明确本轮固定选择：`规范 + 轻替换`
- [ ] 明确不做项：不新增新区域、不新增新核心玩法、不重做存档、不做大规模正式美术替换
- [ ] 完成 fresh 基线验证：
  - `godot --headless --path . --import`
  - Stage 1-11 全量 GUT
  - `git diff --check`

## Task 2: 建立资产目录、资产清单与接入检查清单

**Files:**
- Create: `docs/assets/asset-manifest.md`
- Create: `docs/assets/asset-ingestion-checklist.md`
- Create: `assets/art/characters/player/`
- Create: `assets/art/characters/enemies/`
- Create: `assets/art/environment/biome_01_lab/`
- Create: `assets/art/vfx/`
- Create: `assets/art/ui/`
- Create: `assets/audio/sfx/`
- Create: `assets/audio/music/`
- Create: `assets/source/references/`
- Create: `assets/source/ai_generated/`
- Create: `assets/source/editable/`

- [ ] 固定 asset manifest 字段：资产 ID、用途、目标路径、规格、来源、授权状态、接入状态、阶段、优先级、备注
- [ ] 预置 Stage 12 第一批资产条目
- [ ] 固定状态值：`needed`、`placeholder_ready`、`integrated`、`deferred`
- [ ] 建立资产接入检查清单：导入、路径、显示、碰撞、HUD、测试、授权记录
- [ ] 不把资产清单扩成正式资源数据库

## Task 3: 接入第一批轻量可读性资产

**Files:**
- Modify: `scenes/player/player_placeholder.tscn`
- Modify: `scenes/combat/basic_melee_enemy.tscn`
- Modify: `scenes/combat/ground_charger_enemy.tscn`
- Modify: `scenes/combat/aerial_sentinel_enemy.tscn`
- Modify/Create: minimal VFX/UI assets under `assets/art/`

- [ ] 为玩家和 3 类敌人接入更清晰的轮廓表现
- [ ] 保留现有 collision shape、攻击判定、敌人 AI 和配置资源契约
- [ ] 接入最小攻击 slash 与命中 spark 表达
- [ ] 接入 checkpoint、门控、终点提示图形
- [ ] 资产不可用时保留几何占位 fallback

## Task 4: 完成 HUD、门控、checkpoint 与终点反馈 polish

**Files:**
- Modify: `scripts/ui/tutorial_hud.gd`
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/rooms/stage11_demo_end_room.gd`
- Modify: relevant room scenes/configs only as needed

- [ ] 优化 HUD 文案与提示节奏
- [ ] 让生命、冲刺、成长、demo 目标和完成反馈更容易读懂
- [ ] 强化 checkpoint、门控、终点方向提示
- [ ] 不把本轮 HUD 修改扩成正式 UI 系统重构
- [ ] 不改变主流程房间切换契约

## Task 5: Stage 12 自动化验证

**Files:**
- Create: `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`

- [ ] 覆盖资产目录存在
- [ ] 覆盖 `asset-manifest.md` 和 `asset-ingestion-checklist.md` 存在且包含 Stage 12 必要字段
- [ ] 覆盖玩家和 3 类敌人的可视节点仍存在
- [ ] 覆盖 HUD 关键文本和 demo 完成反馈不回归
- [ ] 覆盖 Stage 11 灰盒主线仍可完成

## Task 6: 人工复核与阶段收口

**Files:**
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-25.md`

- [ ] 手动从 `Main.tscn` 完整跑到 `stage11_demo_end_room`
- [ ] 至少进入一次 Stage 10 支路
- [ ] 至少进入一次挑战房
- [ ] 至少触发一次失败 / 重来
- [ ] 至少触发一次 demo 完成和重开入口
- [ ] 记录人工复核结论：可读性、资产遮挡、碰撞误导、HUD 理解、卡点、下一步建议
- [ ] 若启用 subagents，补写 Delegation Log

## Delegation Requirement

阶段 12 默认允许并推荐按需启用 subagents：

- 代理 A：资产目录、asset manifest、asset ingestion checklist
- 代理 B：玩家 / 敌人 / VFX 轻量可读性接入
- 代理 C：Stage 12 GUT、HUD polish、进度文档与人工复核模板

若多个任务会同时修改同一核心场景或脚本，由主代理负责整合。

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- `git diff --check`
- 人工复核：`godot --path .`

## Completion Criteria

- [ ] Stage 12 资产目录规范已落地
- [ ] `docs/assets/asset-manifest.md` 已建立并预置第一批资产条目
- [ ] `docs/assets/asset-ingestion-checklist.md` 已建立
- [ ] 玩家、3 类敌人、HUD、门控、checkpoint、终点反馈完成第一轮轻量可读性接入
- [ ] Stage 12 专项 GUT 通过
- [ ] Stage 1-12 全量 GUT 通过
- [ ] 完整人工复核完成并写回进度文档
