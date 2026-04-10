# Stage 2 Movement Feel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 1 骨架上完成阶段 2 的基础移动手感，包括跑停、跳跃、落地和高级手感窗口。

**Architecture:** 保持 `Main.tscn + Runtime + TestRoom + PlayerPlaceholder` 的现有骨架不变，在现有占位玩家上增量实现命名输入动作、导出调参字段和最小显式状态流转。验证优先依赖 GUT 自动化覆盖，再补 GUI 手动试玩复核。

**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口工程基线

**Files:**
- Modify: `project.godot`
- Test: `tests/stage2/test_stage_2_movement_feel.gd`

- [ ] 新增阶段 2 的失败测试，确认命名输入动作缺失且 `better-terrain` 仍被启用。
- [ ] 收口 `project.godot`，保留 `godot_mcp` 与 `gut`，新增 `move_left`、`move_right`、`jump`。
- [ ] 跑阶段 2 测试，确认输入契约与插件基线转绿。

## Task 2: 演进玩家移动原型

**Files:**
- Modify: `scripts/player/player_placeholder.gd`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage2/test_stage_2_movement_feel.gd`

- [ ] 为玩家补失败测试，覆盖状态字段、导出调参参数和平地跑停。
- [ ] 实现命名输入驱动、导出参数、最小状态流转。
- [ ] 为跳跃、高级手感窗口补失败测试。
- [ ] 实现 `coyote time`、`jump buffer`、`可变跳高`。
- [ ] 跑阶段 2 测试，确认所有行为契约转绿。

## Task 3: 扩展测试房间验证路径

**Files:**
- Modify: `scenes/rooms/test_room.tscn`
- Test: `tests/stage2/test_stage_2_movement_feel.gd`

- [ ] 在测试房间中增加中段平台，但不引入房间系统重构。
- [ ] 确认平台路径可覆盖平地跑跳、落地和离台补跳验证。

## Task 4: 回写设计与进度文档

**Files:**
- Create: `spec-design/2026-04-10-stage-2-movement-feel-design.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Create: `docs/progress/2026-04-10.md`

- [ ] 记录阶段 2 的范围收口与关键决策。
- [ ] 明确后续阶段安排：
  - 攻击：阶段 3
  - 冲刺：阶段 4
  - HUD：阶段 5
  - 房间系统重构：阶段 5
- [ ] 记录分支/worktree 模式、验证结果、遗留风险与下一步建议。

## Task 5: 最终验证

**Verification Commands:**
- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `git diff --check`

- [ ] 跑 `--import`，确认 `better-terrain` 解析错误已收口。
- [ ] 跑阶段 1 回归测试。
- [ ] 跑阶段 2 测试。
- [ ] 跑 `git diff --check`。
- [ ] 记录尚未完成的 GUI 手动试玩。
