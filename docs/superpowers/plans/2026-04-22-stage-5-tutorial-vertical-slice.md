# Stage 5 Tutorial Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 4 稳定基线上做出一个“单场景、低压、可理解”的教程区垂直切片，把 `move / jump / dash / attack` 串成最小主流程，并接入最小 HUD。

**Architecture:** 将 `Main` 从“TestRoom 专用入口”迁移为“主房间契约入口”，默认实例化新的 `TutorialRoom`。保留 `TestRoom` 作为回归与调参沙盒。教程区采用单场景线性流程，战斗教学继续沿用最小受击契约，不引入正式敌人 AI、完整生命/死亡循环或房间系统重构。

**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口阶段 5 前置文档与开发现场

**Files:**
- Create: `spec-design/2026-04-22-stage-5-tutorial-vertical-slice-design.md`
- Create: `docs/superpowers/plans/2026-04-22-stage-5-tutorial-vertical-slice.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 在 `codex/stage-5-tutorial-vertical-slice` 与对应 `.worktrees/` 中启动本轮 preflight。
- [ ] 记录本轮采用 `分支 + worktree` 的原因、阶段目标、开发边界与验证预期。
- [ ] 明确本轮只做教程区垂直切片，不混入完整敌人 AI、正式死亡循环或房间系统重构。

## Task 2: 迁移 Main 的主房间契约

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] 先补失败测试，暴露 `Main` 仍固定依赖 `TestRoom` 的历史耦合。
- [ ] 将主房间节点迁移为通用命名，例如 `Room`。
- [ ] 保持 `Main` 继续只依赖 `get_camera_limits() -> Rect2i` 契约。
- [ ] 保证玩家生成、相机限位与现有启动骨架在新契约下仍成立。

## Task 3: 新建 TutorialRoom 与教程门控

**Files:**
- Create: `scenes/rooms/tutorial_room.tscn`
- Create: `scripts/rooms/tutorial_room.gd`
- Possibly Modify: `scenes/combat/training_dummy.tscn` or add tutorial blocker variant
- Test: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`

- [ ] 新建单场景 `TutorialRoom`，承载“移动/跳跃 -> dash -> 攻击 -> 出口”的线性流程。
- [ ] 加入低压门控，允许玩家原地重复尝试，不接正式失败重来。
- [ ] 战斗教学优先复用 `TrainingDummy` 契约，或新增同契约的教程阻挡目标。
- [ ] 保持 `TestRoom` 不承担主流程入口职责。

## Task 4: 接入最小 HUD

**Files:**
- Create: `scenes/ui/tutorial_hud.tscn`
- Create: `scripts/ui/tutorial_hud.gd`
- Modify: `scenes/main/main.tscn` or `TutorialRoom` integration point
- Test: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`

- [ ] 新增教学提示区，显示当前目标与按键提示。
- [ ] 新增最小战斗面板区，只做展示，不接完整扣血 / 死亡 / 恢复循环。
- [ ] 让 HUD 能随教程步骤推进更新提示内容。
- [ ] 保持 HUD 服务于理解，不遮挡主要游玩区域。

## Task 5: 自动化验证与文档收口

**Files:**
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Create: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 覆盖 `Main` 默认进入教程主房间，而不是 `TestRoom`。
- [ ] 覆盖主房间契约、HUD 默认显示与第一条教程提示。
- [ ] 覆盖教程顺序推进、`dash` 门槛、攻击阻挡目标与出口解锁。
- [ ] 若使用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`。

## Recommended Delegation

- `multi-agent` 推荐拆分：
- 代理 A：`Main` 与主房间契约迁移
- 代理 B：`TutorialRoom`、HUD 与门控流程
- 代理 C：Stage 1 契约迁移测试、Stage 5 GUT 与文档留痕
- 主代理负责：
- 边界约束
- 结果整合
- 最终验证
- 合并收口
- 若出现多个子任务同时写入同一批核心文件，先降级为 `subagent` 或转回主代理串行处理

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `git diff --check`

## Completion Criteria

- `Main` 已迁移为主房间契约入口，并默认进入教程区
- 教程区可顺序完成移动/跳跃、`dash`、攻击与出口流程
- 最小 HUD 已上线，且战斗面板只做展示
- 阶段 1 / 2 / 3 / 4 / 5 自动化验证全部通过
- 当前结果足以作为下一轮垂直切片扩展的稳定基线
