# Stage15 战斗高潮与首个精英 Boss 原型正式开发计划

## Summary

Stage15 基于已合并的 Stage14 `main`，目标是建立 Demo 后半段第一场战斗高潮：新增 `Seal Guardian / 封印守卫` 精英 Boss 原型，并加入唯一新战斗扩展机制 `Recovery Charge / 恢复充能`。

本阶段继续使用固定永久工作树与阶段分支 `codex/stage-15-combat-climax-and-elite-boss`，强制采用 subagent 分工。自动化通过不等于阶段完成，Godot MCP 运行态人工复核是阶段收口硬门槛。

## Stage Boundary

- 前置基线：Stage14 已完成并合并回 `main`，包含 Air Dash、回溯链路、能力门和 3 个回溯收益点。
- 阶段入口：Stage14 `stage14_loop_return_room` 完成后进入 Stage15 前置压迫段。
- 阶段出口：玩家完成 Boss 房战斗，进入 Stage15 completion room，并在 `Main.get_demo_progress_snapshot()` 中标记 `stage15_boss_defeated=true`。
- 工作模式：固定永久工作树 + 阶段分支。

## Goals

- 新增单阶段精英 Boss `SealGuardianBoss`。
- 新增战斗容错机制 `Recovery Charge`。
- 从 Stage14 回环房接入 Stage15 前置段、混合遭遇房、Boss 房、挑战支线和完成房。
- HUD 显示恢复充能、Boss 生命、Boss 状态，并保留 Stage14 Air Dash 与回溯收益信息。
- 通过 Stage15 专项 GUT、全量 GUT、Godot import、`git diff --check` 和 Godot MCP 运行态人工复核完成收口。

## Non-Goals

- 不做完整 Boss 框架。
- 不做多阶段 Boss、剧情演出或正式过场。
- 不做第二个核心能力。
- 不做技能树、正式资源系统、药瓶系统或正式经济。
- 不做正式美术替换，只记录 Stage15 占位视觉需求。

## Key Changes

- 新增 Stage15 文档三件套：
  - `spec-design/2026-04-27-stage-15-combat-climax-and-elite-boss-design.md`
  - `docs/implementation-plans/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
  - `plan/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
- Stage14 回环房接入 Stage15：
  - Boss 前置压迫段
  - 混合遭遇房
  - 精英 Boss 专用房
  - 战斗挑战支线
  - Boss 击败后的阶段完成反馈
- 新增 `SealGuardianBoss`：
  - 沿用 `receive_attack(...)` 与 `defeated`
  - 提供 `idle / close_pressure / ground_impact / air_punish / staggered / defeated` 状态读值
  - 暴露生命、最大生命、当前状态与击败状态
- 新增 `Recovery Charge`：
  - 命中或击败敌人积累
  - 满充能后可恢复 1 点生命
  - 不扩展为正式经济系统

## Public Interfaces

`PlayerPlaceholder` 新增：

- `add_recovery_charge(amount: float) -> void`
- `can_spend_recovery_charge() -> bool`
- `spend_recovery_charge() -> bool`
- `get_recovery_charge_ratio() -> float`

`get_hud_status_snapshot()` 新增：

- `recovery_charge_ratio`
- `recovery_charge_ready`

`SealGuardianBoss` 暴露：

- `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
- `is_defeated() -> bool`
- `get_current_health() -> int`
- `get_max_health() -> int`
- `get_boss_state() -> StringName`

`Main.get_demo_progress_snapshot()` 新增：

- `stage15_boss_defeated`
- `stage15_recovery_charge_ready`

Stage15 房间沿用：

- `room_transition_requested`
- `checkpoint_requested`
- `goal_completed`
- `get_hud_context() -> Dictionary`

## Content Scope

- `stage15_seal_pressure_room`：Stage14 后的战斗压迫入口。
- `stage15_mixed_gauntlet_room`：混合敌人遭遇，验证恢复充能与 Stage14 移动能力在战斗中的读法。
- `stage15_seal_guardian_boss_room`：Boss 专用房，包含 checkpoint、失败重试、Boss 读招与击败转场。
- `stage15_challenge_branch_room`：可选战斗挑战支线。
- `stage15_completion_room`：Boss 击败后的阶段完成反馈。

## Asset Scope

- `docs/assets/asset-manifest.md` 追加 Stage15 占位需求：
  - Boss 剪影
  - Boss 攻击预警
  - Boss 血量 / 状态 HUD
  - 恢复充能 UI 图标
  - Boss 房封印机关视觉
- 本阶段不要求正式素材接入，只要求灰盒可读、HUD 可追踪、manifest 可追溯。

## Subagent Execution Model

Stage15 必须使用 subagent，但主协调者负责最终整合，禁止多个 subagent 同时修改同一核心文件。

- `design`：阶段边界、Boss 招式范围、不做项、文档三件套。
- `gameplay`：Boss、恢复充能、玩家命中 / 击败充能接口。
- `content`：前置段、Boss 房、挑战支线、混合遭遇和资产 manifest。
- `qa`：Stage15 GUT、灰盒 driver、验证清单。
- `godot_runtime`：Godot MCP 联通、运行态人工复核、截图 / 场景树 / 状态读值记录。
- `production`：进度文档、阶段收口、分支 / worktree / MCP 留痕。

## Implementation Plan

- 第一批并行：`design`、`qa`、`godot_runtime` 做计划、红测和 MCP preflight。
- 第二批并行：`gameplay` 与 `content` 分别实现 Boss / 恢复机制与房间内容，主协调者整合接口。
- 第三批：`qa` 与 `godot_runtime` 做自动化 + MCP 人工复核，`production` 做文档与收口记录。
- 实现顺序：
  - 写 Stage15 专项 GUT 红测。
  - 实现 `Recovery Charge` 与 HUD 快照。
  - 实现 `SealGuardianBoss` 和 Boss 房流程。
  - 接入 Stage15 房间链路与 Stage14 回环入口。
  - 扩展 Main snapshot 和灰盒 driver。
  - 做 MCP 运行态复核并修复发现问题。

## Test Plan

- 恢复充能默认为空，命中敌人后增长，满后可恢复 1 点生命。
- 满血时消费恢复充能不超过最大生命，也不清空充能。
- Boss 可受击、减血、击败并发出 `defeated`。
- Boss 房支持开始、失败、重试、击败和完成转场。
- Main snapshot 标记 `stage15_boss_defeated=true`。
- HUD 同时显示恢复充能与 Boss 状态。
- Stage14 loop return 能进入 Stage15 前置段。
- 灰盒 driver 覆盖 Stage14 回环 -> Stage15 前置段 -> 混合遭遇 -> Boss 房 -> 击败 Boss -> 阶段完成反馈。
- 回归命令：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

## Manual Review / Runtime Review

- 必须从固定工作树启动开发会话并确认 Godot MCP 工具可用。
- 必须运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1` 并记录连接状态。
- 必须用 MCP 从 `Main.tscn` 复核：
  - Stage14 -> Stage15 入口
  - Boss 房出生点
  - Boss 攻击读招
  - 恢复充能 HUD
  - 失败重试
  - Boss 击败反馈
  - Stage15 completion room 反馈
- MCP 发现的问题必须修复；可自动化的行为必须至少补 1 条回归测试。
- MCP 动态注入到 `project.godot` 的 autoload diff 必须在复核结束后清理。
- MCP 截图等一次性证据默认放在 `tests/artifacts/local/<topic>/`，不放入 `docs/progress/`。

## Documentation Updates

- 更新 `docs/progress/status.md`。
- 更新 `docs/progress/timeline.md`。
- 更新当日日志 `docs/progress/logs/YYYY-MM-DD.md`。
- 更新 `docs/assets/asset-manifest.md`。
- 若 Boss、恢复充能或房间链路实现偏离设计，回写 `spec-design/` 与 `docs/implementation-plans/`。

## Exit Criteria

- `SealGuardianBoss`、`Recovery Charge`、Stage15 房间链路和完成反馈实现完成。
- Stage15 专项 GUT、全量 GUT、Godot import 和 `git diff --check` 通过。
- Godot MCP 运行态人工复核完成，且 MCP 发现问题已修复并有回归测试保护。
- `project.godot` 无 MCP autoload 残留 diff。
- 进度文档、资产 manifest 和阶段收口记录已更新。
- 分支结果可作为 Stage16 Alpha Demo 打包候选的稳定前置基线。

## Risks

- Boss 状态过多会滑向完整 Boss 框架，超出单阶段精英原型范围。
- Recovery Charge 若过强，可能抵消失败重试和 Boss 压力。
- Boss HUD 与 Stage14 HUD 信息可能拥挤，需要运行态复核确认可读性。
- MCP 连接状态和脚本判定可能不一致，必须以工具实测、项目路径和 bridge 归属综合判断，不盲目清理其他会话。

## Assumptions

- Stage15 唯一新增战斗扩展固定为 `Recovery Charge`。
- Stage15 首个 Boss 原型固定为 `Seal Guardian / 封印守卫`。
- Boss 是单阶段精英 Boss，允许 2-3 个清晰招式。
- Stage15 不引入第二个核心能力、正式存档、技能树、剧情演出或完整 Boss 框架。
