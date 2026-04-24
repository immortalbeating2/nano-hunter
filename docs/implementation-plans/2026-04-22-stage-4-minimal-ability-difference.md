# Stage 4 Minimal Ability Difference Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 3 稳定基线上，通过“仅地面冲刺 + TestRoom 混合验证”证明最小能力差异已经具备实际玩法价值。

**Architecture:** 保持 `Main.tscn + Runtime + TestRoom + PlayerPlaceholder + TrainingDummy` 的现有骨架不变，在占位玩家上增量加入 `dash` 输入与状态，并只扩展 `TestRoom` 来验证探索门槛和战斗门槛。继续沿用阶段 3 的攻击与受击最小契约，不引入空中冲刺、无敌帧、攻击取消或 HUD。

**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口 Stage 4 前置文档与开发现场

**Files:**
- Create: `spec-design/2026-04-22-stage-4-minimal-ability-difference-design.md`
- Create: `docs/implementation-plans/2026-04-22-stage-4-minimal-ability-difference.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Create: `docs/progress/2026-04-22.md`
- Modify: `AGENTS.md`

- [ ] 在 `codex/stage-4-minimal-ability-difference` 与对应 `.worktrees/` 中启动本轮 preflight。
- [ ] 把 `AGENTS.md` 的代理协作规则同步到当前 worktree，避免实现阶段按旧规则误判。
- [ ] 记录本轮分支 / worktree 模式、阶段目标、延后项归属与验证预期。

## Task 2: 新增冲刺输入与最小状态机

**Files:**
- Modify: `project.godot`
- Modify: `scripts/player/player_placeholder.gd`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 为 `dash` 输入契约补失败测试。
- [ ] 在玩家脚本中新增 `dash` 状态与导出调参字段。
- [ ] 固定本轮冲刺边界：
  - 只允许地面触发
  - 只允许从 `idle` / `run` / `land` 进入
  - 不能在 `attack` 中触发
  - 不能在空中触发
- [ ] 跑阶段 4 测试，确认冲刺状态与方向契约转绿。

## Task 3: 扩展 TestRoom 的能力差异验证点

**Files:**
- Modify: `scenes/rooms/test_room.tscn`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 在 `TestRoom` 中新增一个探索门槛，证明不用冲刺难以稳定通过。
- [ ] 在 `TestRoom` 中新增一个战斗门槛，证明冲刺能明显改善接敌节奏或出手位置。
- [ ] 保持 `TrainingDummy` 与阶段 3 的最小受击契约不变。

## Task 4: 落地最小能力差异反馈

**Files:**
- Modify: `scripts/player/player_placeholder.gd`
- Possibly Modify: `scenes/rooms/test_room.tscn`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 为冲刺补最小可读性反馈，但只服务能力识别。
- [ ] 不引入无敌帧、攻击取消、姿态系统或元素系统。
- [ ] 若冲刺接入后暴露与现有移动 / 攻击节奏冲突，优先回调已有参数。

## Task 5: 自动化验证与文档收口

**Files:**
- Create: `tests/stage4/test_stage_4_minimal_ability_difference.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 覆盖 `dash` 输入、地面触发、空中禁止、攻击中禁止、方向规则、状态恢复。
- [ ] 覆盖探索门槛与战斗门槛的最小价值验证。
- [ ] 记录哪些反馈已在阶段 4 落地，哪些继续后延。
- [ ] 若使用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`。

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `git diff --check`

## Completion Criteria

- 玩家可稳定从地面触发冲刺，并与普通移动形成清晰差异。
- 同一测试房间内同时存在探索价值和战斗价值的最小验证点。
- 阶段 4 的轻量反馈足以表达“能力差异”，但没有扩写成完整演出系统。
- 阶段 1 / 2 / 3 / 4 自动化验证全部通过。
- 当前结果足以承接阶段 5 的教程区垂直切片设计。
