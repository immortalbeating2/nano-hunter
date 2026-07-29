# Formal Demo Map Redesign

## Summary

重做 Nano Hunter 当前 39 个可运行房间的空间与地图表现，使其达到正式 Demo 级类银河恶魔城标准。先完成教学、能力门、战斗场三类样板，再按区域每批 `3-5` 房推广；保留有效玩法逻辑、房间连接、门控与 checkpoint 契约。

## Stage Boundary / Preflight

- 基准：Godot 4.6、64px 网格、640x360 世界视野、当前 39 房可运行链路。
- 当前问题：多数房间统一为约 `960x384` 横向短房，背景和地面重复，自动视觉审计不足以证明正式构图。
- 分支：继续使用固定永久工作树当前 `codex/demo-level-formal-remap` 分支，保留现有脏现场；本阶段不清理或回退用户已有改动。
- 设计入口：`spec-design/2026-07-10-formal-demo-metroidvania-map-redesign.md`。

## Goals

- 冻结房间原型、尺寸分级、地图节拍、TileMapLayer 与 Terrain Kit 语义。
- 完成 `tutorial_room`、`stage14_air_dash_gate_room`、`stage15_mixed_gauntlet_room` 三类正式样板。
- 审计并复用现有运行态资产，归档未选候选，只补缺失语义资源。
- 按 Batch 1-9 推广到全部 39 房，并验证正向、反向、能力门、回溯和完整流程。

## Non-Goals

- 不重写玩家控制、战斗系统、敌人 AI、门控状态机或正式存档。
- 不在样板验证前创建全局随机铺图或通用房间生成器。
- 不把全部资产推倒重生，不把未批准候选接入运行时。

## Content Scope

- 39 个 `scenes/rooms/*.tscn` 房间。
- 三类首轮样板与九个推广批次。
- 房间 Camera Limits、Terrain 网格、敌人 / 机关位置、入口出口、支路、回环和地标构图。

## Asset Scope

- 保留：当前已验证角色、敌人、HUD、VFX、门禁、奖励、背景和 props。
- 重做 / 清稿：正式 Terrain Kit、区域地形变体、背景分层、前景边缘和区域装饰。
- 归档：未选 image-gen 候选、失败稿、重复 source sheet 和未经批准的 inbox 文件。
- 仅缺失语义才生成新图；正式静态 terrain tile 必须视觉与碰撞一致。

## Key Changes

- 统一 64px 网格和 640x360 基准视野。
- 用房间职责决定尺寸，不再让所有房间共享 `960x384`。
- 建立 `TerrainSolid`、`TerrainOneWay`、`HazardVisual`、背景 / 装饰 / 前景分层契约。
- 先灰盒玩法，再反推 TileSet 语义和资产缺口。
- 房间验收从素材引用与截图冒烟升级为入口 / 核心 / 出口三点运行态与完整流程试玩。

## Public Interfaces

- 保留 `get_camera_limits()`、`get_spawn_position()`、`room_transition_requested`、`checkpoint_requested`、`get_hud_context()` 等房间公共契约。
- 保留敌人 `defeated`、门禁碰撞和现有 ability state 接口。
- 场景可调整 Camera Limits、spawn positions、出口节点和地形，但不得改变接口语义。

## Implementation Plan

1. Phase A：冻结设计契约、资产去留和三类样板蓝图。
2. Phase B：完成 tutorial 正式教学样板。
3. Phase C：完成 Stage14 Air Dash 能力门样板。
4. Phase D：完成 Stage15 mixed gauntlet 战斗场样板。
5. Phase E：提取三样板共同规则，只在确有重复时补最小 helper。
6. Phase F：按 Batch 1-9 每批 `3-5` 房推广。
7. Phase G：完整流程试玩、全房截图、GUT、import、文档和交付口径收口。

## Test Plan

- 每个样板和批次补最接近的 GUT 房间契约测试。
- Godot `--import`。
- 入口 / 核心 / 出口三点运行态截图。
- 正向与反向房间切换、checkpoint、能力门、门前后落点和完整主线试玩。
- 最终覆盖全部 39 房，不能用单房或结构 smoke 推断全图完成。

## Manual Review / Runtime Review

- 逐房检查路线、地标、可踩面、危险、敌人空间和背景误读。
- 每批 contact sheet 比较房间轮廓与区域重复度。
- 三类样板必须由实际运行截图证明，而不是只看编辑器或 TileSet 资源。

## Documentation Updates

- 更新设计文档、Phase 执行清单、资产去留表、当日日志、status 和 timeline。
- 每批记录已完成房间、截图证据、测试和遗留资产缺口。

## Exit Criteria

- 39 房均具有明确职责、可区分轮廓和有效玩法节拍。
- 正式静态地形视觉与碰撞一致，背景装饰无空气路 / 空气墙误读。
- 入口出口安全，能力门、回溯、支路和 checkpoint 链路成立。
- 所有房间完成运行态截图与完整流程试玩，相关 GUT、Godot import 和差异检查通过。
- 资产与进度文档同步，未批准候选不进入运行时。

## Risks

- 当前工作树改动量很大，阶段提交前必须严格按目标文件分组，不能带入无关资产噪音。
- Image Gen 不能保证 tile 边缘连续和碰撞准确，生成后仍需切片与人工校准。
- 统一扩大房间会稀释节奏；尺寸必须由玩法原型决定。

## Assumptions

- 现有玩家移动、dash、Air Dash、敌人和门控逻辑继续作为稳定基线。
- 现有 39 房连接关系先保留，只有在回溯或安全落点明确失败时才调整连接或 spawn。

## Completion Record

- 2026-07-11：三类样板与 Batch 1-9 已完成，正式重排达到 `39/39` 房。
- 全量 GUT：`31` scripts，`219/219` tests，`6105` asserts。
- 39 房运行态截图审计：`P0=0 / P1=0 / P2=0`，并生成总览 contact sheet 完成人工轮廓复核。
- Godot import 通过；完整主线由 Stage16 graybox driver 从教程链推进到 Alpha Demo End。
- 边界：当前结果位于 `codex/demo-level-formal-remap` 分支，尚未合并到 `main`；发布前仍建议进行真人手柄 / 键鼠连续试玩与最终美术签核。
