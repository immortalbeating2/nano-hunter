# Stage 11 Graybox Mainline Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增一条从 `Main.tscn` 起步、依靠真实输入推进到 `stage11_demo_end_room` 并触发 demo 完成反馈的灰盒主线自动化验证。

**Architecture:** 复用现有 `Main / Room / Player / HUD` 运行时契约，在测试侧新增一个“灰盒主线驾驶器”。驾驶器分成输入脉冲、运行态观察和房间级策略三层；只通过输入推进，不直接切房或瞬移，但允许读取房间脚本、HUD 文本和玩家坐标来决定下一步动作。

**Tech Stack:** Godot 4.6、GDScript、GUT、InputMap 运行时输入、现有房间/HUD 快照接口

---

## Task 1: 计划与留痕落盘

**Files:**
- Create: `docs/implementation-plans/2026-04-25-stage-11-graybox-mainline-automation.md`
- Create: `spec-design/2026-04-25-stage-11-graybox-mainline-automation-design.md`

- [x] 写入灰盒主线自动化规格
- [x] 写入本实现计划

## Task 2: 新增失败测试入口

**Files:**
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`

- [ ] 写一条新的 Stage 11 测试，目标是“从 `Main.tscn` 起步，用灰盒驾驶器推进到 demo 完成”
- [ ] 测试先依赖一个尚不存在或返回失败的驾驶器结果，确保它先红
- [ ] 只跑新测试，确认它以“驾驶器未实现/未完成”失败

## Task 3: 实现最小驾驶器骨架

**Files:**
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`

- [ ] 新增驾驶器结果结构，至少包含：
  - `success`
  - `failure_reason`
  - `last_room_path`
  - `last_step_label`
  - `last_prompt_label`
  - `last_player_position`
  - `last_player_velocity`
  - `last_strategy_step`
- [ ] 新增统一输入脉冲辅助：
  - 右移短按
  - 跳跃短按
  - 攻击短按
  - 冲刺短按
- [ ] 新增统一运行态快照读取辅助
- [ ] 重新跑新测试，确认从“未实现失败”进入“策略未覆盖失败”

## Task 4: 打通 Tutorial / Combat / Goal 短链路

**Files:**
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`

- [ ] 给 `TutorialRoom` 写最小推进策略：
  - 推到 jump 平台
  - 过 dash gate
  - 近身攻击 dummy
  - 走出教程出口
- [ ] 给 `CombatTrialRoom` 写最小推进策略：
  - 靠近敌人
  - 反复攻击直到门开
  - 走到右侧出口
- [ ] 给 `GoalTrialRoom` 写最小推进策略：
  - 清守门敌人
  - 推到目标区
- [ ] 跑新测试，确认失败点推进到 stage9 之前

## Task 5: 打通 stage9 主线

**Files:**
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`

- [ ] 为 stage9 各房间按房间路径写最小推进策略
- [ ] 策略只允许：
  - 真实输入推进
  - 读取房间路径、HUD 和玩家位置
- [ ] 跑新测试，确认失败点推进到 stage10

## Task 6: 打通 stage10 到 demo 终点

**Files:**
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`

- [ ] 为 `stage10_zone_aerial_room`、`stage10_zone_challenge_room` 与 `stage11_demo_end_room` 写最小推进策略
- [ ] 明确主线优先，不主动进入支路
- [ ] 在 `stage11_demo_end_room` 用 HUD 或主流程快照确认 `demo_completed`
- [ ] 跑新测试，争取首次转绿

## Task 7: 收口错误信息与回归验证

**Files:**
- Create: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `tests/stage11/test_stage_11_playable_demo_slice.gd`
- Modify: `docs/progress/2026-04-25.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`

- [ ] 把失败输出补全成可诊断格式
- [ ] 跑：
  - 新灰盒主线测试
  - `tests/stage11/test_stage_11_playable_demo_slice.gd`
  - `godot --headless --path . --import`
- [ ] 记录验证结果与剩余风险
