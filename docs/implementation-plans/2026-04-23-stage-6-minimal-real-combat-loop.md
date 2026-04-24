# Stage 6 Minimal Real Combat Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 5 稳定基线上，做出“教程后独立战斗房 + 1 个基础近战敌人 + 玩家生命 / 受击 / 本段即时重置”的最小真实战斗闭环。
**Architecture:** 保留 `TutorialRoom` 作为教学入口，新增 `CombatTrialRoom` 承载真实战斗压力；`Main` 只补最小房间过渡与当前房间重置；玩家新增生命 / 受击 / defeated 信号；HUD 升级为真实战斗状态读取。
**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口 stage6 preflight 文档与开发现场

**Files:**
- Create: `spec-design/2026-04-23-stage-6-minimal-real-combat-loop-design.md`
- Create: `docs/implementation-plans/2026-04-23-stage-6-minimal-real-combat-loop.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 在 `codex/stage-6-minimal-real-combat-loop` 与对应 `.worktrees/` 中启动本轮 preflight
- [ ] 记录本轮采用 `分支 + worktree` 的原因、目标范围与不做项
- [ ] 明确本轮采用 `multi-agent` 优先评估策略，并预留 `Delegation Log`

## Task 2: 为 Main 增加最小房间过渡与重置能力

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 先补红测，暴露当前 `Main` 还不支持教程后切入独立战斗房与战斗房重置
- [ ] 让 `Main` 能响应房间发出的过渡请求，并切到目标房间与目标出生点
- [ ] 让 `Main` 能在玩家 defeated 后重置当前战斗房与玩家状态
- [ ] 保持这套能力只服务 `TutorialRoom -> CombatTrialRoom` 与战斗房本段重置，不扩成正式房间系统

## Task 3: 玩家生命、受击与 defeated 闭环

**Files:**
- Modify: `scripts/player/player_placeholder.gd`
- Possibly Modify: `scenes/player/player_placeholder.tscn`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 先补红测，暴露当前玩家缺少生命、受击、无敌时间与 defeated 信号
- [ ] 新增最小生命系统，默认 `max_health = 3`
- [ ] 新增 `receive_damage(...)`、`health_changed(...)` 与 `defeated()`
- [ ] 接入最小受击击退、短暂无敌与可读性反馈
- [ ] 保持当前移动、攻击、地面 `dash` 的既有契约不被回归破坏

## Task 4: 新建 CombatTrialRoom 与基础近战敌人

**Files:**
- Create: `scenes/rooms/combat_trial_room.tscn`
- Create: `scripts/rooms/combat_trial_room.gd`
- Create: `scenes/combat/basic_melee_enemy.tscn`
- Create: `scripts/combat/basic_melee_enemy.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 新建独立战斗房，作为教程后的第一段真实战斗
- [ ] 新建 1 个基础近战敌人，采用“小范围巡逻 + 接触伤害 + 1 次被命中即失效”的最小模型
- [ ] 战斗房默认出口锁定，敌人被击败后出口解锁
- [ ] 房间暴露最小契约：重置、提示文本、出生点与过渡请求
- [ ] 不引入多敌人、远程敌人、复杂 AI 或完整数值系统

## Task 5: HUD 升级为真实战斗状态读取

**Files:**
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/tutorial_hud.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 让战斗面板真实反映玩家生命值，而不再只显示固定文本
- [ ] 保持 `dash` 状态显示继续可用
- [ ] 让提示区能够在 `TutorialRoom` 和 `CombatTrialRoom` 之间切换对应文案
- [ ] 保持 HUD 仍然是最小运行时面板，不扩为完整前台系统

## Task 6: Stage 6 自动化验证与文档收口

**Files:**
- Create: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 覆盖玩家初始生命、受击掉血、无敌窗口与 defeated 信号
- [ ] 覆盖 `TutorialRoom` 完成后请求切到 `CombatTrialRoom`
- [ ] 覆盖战斗房出口初始锁定、敌人被击败后解锁
- [ ] 覆盖玩家在战斗房死亡后会被本段即时重置且生命回满
- [ ] 覆盖 HUD 生命显示与当前提示同步更新
- [ ] 若使用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`

## Recommended Delegation

- `multi-agent` 推荐拆分：
- 代理 A：`Main` 的房间过渡与本段重置
- 代理 B：玩家生命 / 受击 / 基础近战敌人 / `CombatTrialRoom`
- 代理 C：HUD 真实状态读取、Stage 6 GUT 与文档留痕
- 主代理负责：
- 边界约束
- 结果整合
- 最终验证
- 合并收口
- 若多个子任务需要同时改同一批核心文件，先降级为 `subagent` 或主代理串行处理

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage6/test_stage_6_minimal_real_combat_loop.gd -gexit`
- `git diff --check`

## Completion Criteria

- 教程完成后能稳定进入 `CombatTrialRoom`
- 玩家拥有最小生命、受击、无敌与 defeated 闭环
- 战斗房的基础近战敌人能稳定制造第一次真实压力
- 玩家死亡后会被低摩擦地重置到战斗房本段起点
- HUD 能真实反映生命值与当前战斗提示
- 阶段 1 / 2 / 3 / 4 / 5 / 6 自动化验证全部通过
- 当前结果足以作为阶段 7 的稳定前置基线
