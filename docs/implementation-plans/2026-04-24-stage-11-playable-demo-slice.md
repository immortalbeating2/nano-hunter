# Stage 11 Playable Demo Slice Implementation Plan

**Goal:** 把当前 `stage1-10` 已验证成立的内容收成一个可连续试玩、可失败重来、可到达终点并给出明确完成反馈的 demo 级切片。
**Architecture:** 继续复用现有 `Main`、房间流转契约、HUD 快照接口、checkpoint 与敌人基础契约，不再新增核心玩法系统。
**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本文档场景、GUT、PowerShell

---

## Task 1: 完成 Stage 11 preflight 文档与 fresh 基线

**Files:**
- Create: `spec-design/2026-04-24-stage-11-playable-demo-slice-design.md`
- Create: `docs/implementation-plans/2026-04-24-stage-11-playable-demo-slice.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [x] 记录本轮采用 `分支 + worktree` 的原因、demo 目标与不做项
- [x] 明确本轮固定选择：
  - demo 形态：`扩成完整 Demo`
  - 内容策略：`复用 stage9-10 + 新增最小终点表达`
  - 注释要求：`文件头职责注释 + 关键流程分段注释`
- [x] 完成 fresh 基线验证：
  - `godot --headless --path . --import`
  - Stage 1-10 GUT
  - `git diff --check`

## Task 2: 收成 Demo 主链路与终点闭环

**Files:**
- Modify: `scripts/main/main.gd`
- Modify: `scenes/rooms/stage10_zone_challenge_room.tscn`
- Create: `scripts/rooms/stage11_demo_end_room.gd`
- Create: `scenes/rooms/stage11_demo_end_room.tscn`

- [x] 先补红测，固定“当前主链路还没有明确 demo 终点”
- [x] 在不新开第二大区域的前提下，把现有内容推进到 demo 终点
- [x] 新增最小完成反馈与可返回 / 重开入口
- [x] 不新增新的核心战斗动作或敌人类型

## Task 3: 补 Demo 级 HUD / 提示与内容收束

**Files:**
- Modify: `scripts/ui/tutorial_hud.gd`
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `assets/configs/rooms/stage10_zone_challenge_room_flow.tres`

- [x] 让 HUD 能显示当前主目标与 demo 完成反馈
- [x] 强化支路 / 挑战房收益可读性
- [x] 强化关键门控、终点方向与完成态提示
- [x] 不把本轮 HUD 修改扩成正式 UI 系统重构

## Task 4: 同步注释补强到 Stage 11 触达代码

**Files:**
- Modify: `scripts/main/main.gd`
- Modify: `scripts/ui/tutorial_hud.gd`
- Create: `scripts/rooms/stage11_demo_end_room.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`

- [x] 为新增脚本补文件头职责注释
- [x] 为多职责核心脚本补分段注释
- [x] 为 Stage 11 测试文件补“保护什么能力”的文件头说明
- [x] 只补高信息量注释，不写逐行解释

## Task 5: 完成 Stage 11 自动化验证与人工复核收口

**Files:**
- Create: `tests/stage11/test_stage_11_playable_demo_slice.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [x] 覆盖主线推进到 demo 终点
- [x] 覆盖支路 / 挑战房仍可进入且不破坏主线
- [x] 覆盖失败 / 重来后仍能回到正确推进点
- [x] 覆盖 HUD 的 demo 目标 / 完成反馈读值
- [x] 确认 Stage 1-10 不回归
- [x] 完成最终人工复核并留痕：
  - 完整通一遍 demo
  - 至少进入一次支路
  - 至少进入一次挑战房
  - 至少验证一次失败 / 重来
  - 记录卡点、平衡问题与可读性问题

## Completion Criteria

- [x] demo 主链路可以从开始稳定推进到终点
- [x] 支路与挑战房仍具有明确价值
- [x] HUD / 门控 / 终点反馈足以支撑外部试玩理解
- [x] Stage 11 触达的核心脚本满足新注释标准
- [x] Stage 1-11 自动化验证通过
- [x] 最终人工复核完成并留痕
