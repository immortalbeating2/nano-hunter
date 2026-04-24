# 阶段 3：基础战斗手感最终计划记录

> 说明：本文档用于留存 `stage3` 的最终确认版计划。
> 原始执行用计划仍保留在 [2026-04-20-stage-3-combat-feel.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-20-stage-3-combat-feel.md)。

## Summary

`stage3` 的目标是在 `stage2` 稳定移动基线上，建立“玩家普通攻击 -> 命中 -> 木桩受击反馈”的最小战斗闭环。
本轮不扩展到敌人 AI、连段、冲刺、HUD 或房间系统重构，只验证第一版基础战斗手感是否成立。

## Key Changes

### 输入与状态契约

- 在 `project.godot` 中新增 `attack` 动作与默认键位
- 在玩家状态中新增 `attack`
- 保持现有移动状态与阶段 2 的手感结果不回退

### 玩家攻击实现

- 在 `PlayerPlaceholder` 中新增最小攻击窗口：
  - 前摇
  - 有效帧
  - 收招
- 攻击按当前朝向生成前方命中范围
- 同一次攻击对同一目标只命中一次
- 将关键攻击参数暴露为导出字段，便于后续继续调参

### 木桩目标与测试房间

- 新增固定木桩目标
- 统一使用最小受击契约：
  - `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
- 在 `TestRoom` 中加入单个固定木桩

### 自动化验证

- 新增阶段 3 GUT
- 覆盖以下契约：
  - `attack` 动作存在
  - 攻击状态可进入
  - 命中范围朝向正确
  - 木桩可被命中
  - 单次攻击单次命中
  - 攻击结束后状态恢复

## Test Plan

- `godot --headless --path . --import`
- Stage 1 GUT
- Stage 2 GUT
- Stage 3 GUT
- `git diff --check`

## Assumptions

- `stage3` 固定为“玩家攻击 + 木桩反馈”，不提前演进成完整敌人系统
- 当前受击契约会在后续阶段继续沿用
