# 阶段 2：基础移动手感最终计划记录

> 说明：本文档用于留存本会话补归档后的 `stage2` 最终计划记录。  
> 原始执行用计划仍保留在 [2026-04-10-stage-2-movement-feel.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/superpowers/plans/2026-04-10-stage-2-movement-feel.md)。

## Summary

`stage2` 的目标是在 `stage1` 启动骨架之上，做出第一版可调整的基础移动手感，包括：

- 跑停
- 跳跃
- 落地
- 高级手感窗口

本轮保持 `Main + Runtime + TestRoom + PlayerPlaceholder` 的既有骨架不变，只在现有占位玩家上增量加入命名输入动作、导出调参字段与最小显式状态流转。

## Key Changes

### 工程基线

- 在 `project.godot` 中新增命名输入动作：
  - `move_left`
  - `move_right`
  - `jump`
- 明确当前阶段继续禁用 `better-terrain`
- 保持 `godot_mcp` 与 `gut` 作为当前阶段默认插件

### 玩家移动原型

- 在 `PlayerPlaceholder` 上实现基础移动输入
- 新增最小状态流转：
  - `idle`
  - `run`
  - `jump_rise`
  - `jump_fall`
  - `land`
- 暴露核心调参字段：
  - 最大速度
  - 地面加速度 / 减速度
  - 空中加速度
  - 跳跃速度
  - 落地时长

### 高级手感窗口

- `coyote time`
- `jump buffer`
- `可变跳高`

### 测试房间扩展

- 在 `TestRoom` 中加入中段平台
- 用最小平台路径验证：
  - 平地跑停
  - 起跳
  - 落地
  - 离台补跳

### 阶段边界

- 本轮明确不做：
  - 攻击
  - 冲刺
  - HUD
  - 房间系统重构
- 并显式把后续归属定为：
  - 攻击：`stage3`
  - 冲刺：`stage4`
  - HUD / 房间系统重构：`stage5`

## Test Plan

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `git diff --check`

## Completion Criteria

- 玩家能稳定跑停、起跳、下落与落地
- `coyote time`、`jump buffer` 与可变跳高全部成立
- 测试房间路径能稳定覆盖阶段 2 的关键动作
- 阶段 1 / 2 自动化验证全部通过
- 当前结果足以作为 `stage3` 的稳定前置基线
