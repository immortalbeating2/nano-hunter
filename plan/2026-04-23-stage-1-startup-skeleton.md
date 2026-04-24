# 阶段 1：可启动骨架最终计划记录

> 说明：本文档用于留存 `stage1` 的最终确认版计划。
> 原始执行用计划仍保留在 [2026-03-31-stage-1-startup-skeleton.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-03-31-stage-1-startup-skeleton.md) 和 [2026-04-01-stage-1-display-and-camera-tuning.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-01-stage-1-display-and-camera-tuning.md)。

## Summary

`stage1` 的最终目标是建立项目第一版“可启动、可看、可调”的试玩检查点，而不是提前进入移动、战斗、HUD 或关卡系统开发。
这一阶段最终由两部分组成：

- 启动骨架
- 画面与相机调优

完成后，项目应能直接从 `Main.tscn` 启动，进入 `TestRoom`，看到占位玩家、基础碰撞、固定基准分辨率与受房间边界约束的相机。

## Key Changes

### 启动骨架

- 新建 `Main.tscn` 作为阶段 1 的启动场景
- 在 `project.godot` 中设置 `run/main_scene`
- 新建 `PlayerPlaceholder` 占位玩家场景与最小脚本
- 新建 `TestRoom` 作为第一版测试房间壳体
- 通过 `Main` 在运行时把玩家生成到 `Runtime` 容器，而不是直接硬写在场景树里

### 画面与相机调优

- 固定基准分辨率为 `640x360`
- 初始窗口尺寸固定为 `1280x720`
- 使用：
  - `viewport`
  - `keep`
  - `integer`
  的缩放策略
- 为 `TestRoom` 暴露最小相机边界契约
- 让玩家的 `Camera2D` 读取并应用该房间边界

### 阶段边界

- 本轮明确不做：
  - 移动输入
  - 跳跃
  - 攻击
  - HUD
  - 房间切换
  - 正式关卡系统

## Test Plan

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . --import`
- `godot --path .`

## Assumptions

- `stage1` 固定以“启动骨架 + 构图稳定”作为目标，不承接移动、战斗或 HUD 开发
- `Main`、`Runtime`、`PlayerSpawn` 与 `TestRoom` 的基础结构会在后续阶段继续复用
