# Stage 10 Combat Variation and Light Progression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 来按任务执行本计划。步骤使用 checkbox (`- [ ]`) 语法跟踪。

**Goal:** 在 `stage9` 已成立的小区域基线之上，加入 `空中攻击`、第 `3` 类普通敌人、`恢复点 + 收集物` 的轻量成长反馈，以及 `1` 条可选支路与 `1` 个挑战房。

**Architecture:** 继续复用 `stage8/9` 已建立的房间配置、HUD 快照接口、checkpoint 与敌人模板入口，不重做主流程框架。实现重点放在“新战斗决策 + 新遭遇组合 + 轻量区域收益反馈”，而不是再扩系统基础设施。

**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 完成 stage10 preflight 文档与启动记录

**Files:**
- Create: `spec-design/2026-04-24-stage-10-combat-variation-and-light-progression-design.md`
- Create: `docs/implementation-plans/2026-04-24-stage-10-combat-variation-and-light-progression.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [x] 记录本轮采用 `分支 + worktree` 的原因、目标范围与不做项
- [x] 明确本轮固定选择：
  - 新动作：`空中攻击`
  - 敌人变化：第 `3` 类普通敌人
  - 成长反馈：`恢复点 + 收集物`
  - 区域结构：主线扩展 + `1` 条支路 + `1` 个挑战房
- [x] 先做 fresh 基线验证：
  - `godot --headless --path . --import`
  - Stage 1-9 GUT
  - `git diff --check`

## Task 2: 玩家侧接入 `空中攻击`

**Files:**
- Modify: player script / player scene / stage10 test file

- [x] 先补红测，暴露当前玩家没有 `空中攻击`
- [x] 新增最小 `空中攻击` 状态、判定与恢复逻辑
- [x] 明确与跳跃、落地、地面普通攻击、受击的互斥关系
- [x] 只做最小成立版本，不引入连段、浮空追打或第二个新动作

## Task 3: 新增第 `3` 类普通敌人与混合遭遇

**Files:**
- Create/Modify: enemy config / enemy scene / relevant room scenes / stage10 tests

- [x] 先补红测，固定当前仅有两类敌人
- [x] 新增第 `3` 类普通敌人，继续复用现有敌人模板与配置资源入口
- [x] 设计 `2-3` 组混合遭遇，确保其节奏与现有两类敌人明显不同
- [x] 至少有 `1` 个房间或遭遇节点明确体现 `空中攻击` 的价值

## Task 4: 接入 `恢复点 + 收集物` 的轻量成长反馈

**Files:**
- Modify/Create: room scripts / config resources / HUD read model / stage10 tests

- [x] 先补红测，固定当前区域没有本轮成长反馈
- [x] 新增恢复点激活、收集物计数或状态快照
- [x] 将其绑定到区域推进，而不是扩成正式经济 / 存档系统
- [x] 让支路与挑战房的收益通过恢复点或收集物被玩家明确感知

## Task 5: 区域扩展为“主线 + 支路 + 挑战房”

**Files:**
- Modify/Create: stage10 区域房间与配置 / stage10 tests

- [x] 在 stage9 主区域基线上新增 `1` 条可选支路
- [x] 新增 `1` 个挑战房
- [x] 保证主线推进仍稳定成立，不因支路扩展打断主链路
- [x] 不新开第二个大区域，不扩成半开放地图

## Task 6: Stage 10 自动化验证与人工复核收口

**Files:**
- Create: `tests/stage10/test_stage_10_combat_variation_and_light_progression.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: 当日日志

- [x] 覆盖 `空中攻击`、第 `3` 类敌人、支路、挑战房、恢复点与收集物快照
- [x] 确认 Stage 1-9 测试不回归
- [x] 完成 fresh 自动化验证：
  - `godot --headless --path . --import`
  - Stage 1-10 GUT
  - `git diff --check`
- [x] 完成最终人工复核并留痕：
  - 主线推进
  - 支路收益
  - 挑战房收益
  - `空中攻击` 的真实价值
  - 恢复点与收集物反馈是否可看、可玩、可调

## Completion Criteria

- [x] `stage10` 已在 `stage9` 基线上形成更完整的内容型里程碑
- [x] 玩家新增 `空中攻击` 并有明确玩法价值
- [x] 第 `3` 类普通敌人已接入，且遭遇节奏明显扩展
- [x] 区域内存在 `1` 条可选支路与 `1` 个挑战房
- [x] `恢复点 + 收集物` 的轻量成长反馈闭环已成立
- [x] Stage 1-10 自动化验证通过
- [x] 已完成最终人工复核并写回进度文档
