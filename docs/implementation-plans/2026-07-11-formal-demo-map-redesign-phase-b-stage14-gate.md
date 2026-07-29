# Formal Demo Map Redesign Phase B - Stage14 Gate

## 目标

把 `stage14_air_dash_gate_room` 从旧的 `15x6` 碰撞跟随试铺，重做为 `24x9` 能力门正式样板；保留 Air Dash、双向连接、checkpoint、门禁和出口契约。

## 执行清单

- [x] 固定下层失败回落、两段起跳、三格 Air Dash 缺口、右侧连续崖台和门前后安全区。
- [x] 用显式网格蓝图生成 `TerrainCollisionVisual` / `PlatformCollisionVisual`，不再从 shape bounds 随机铺 tile。
- [x] 用 `GroundSurfaceVisual` / `ThinPlatformSurfaceVisual` 表达连续可踩面与明确 cap。
- [x] 复用单张神龛背景、门禁 atlas、神龛回声和低对比石质 underlay；不新增 Image Gen 资产。
- [x] 隐藏旧试铺层并禁用旧 `LeftWall` / `Floor` 碰撞，逻辑碰撞保持独立。
- [x] 恢复并测试 next / previous room、spawn、checkpoint、HUD step 与 `air_dash_gate_room` 导出字段。
- [x] 验证普通跳失败回落、Air Dash 成功落地、锁门 / 开门和门前后安全区。
- [x] 完成 GUT、Godot import、四状态运行态截图和人工构图复核。

## 房间蓝图

- 相机边界：`Rect2i(-512, -288, 1536, 576)`，即 `24x9` 个 64px 单位。
- 下层地面：`x=-8..5, y=3`，失败后可回退重试。
- 起跳平台：`x=-6..-4, y=2` 与 `x=-1..2, y=1`。
- Air Dash 缺口：`x=3..5, y=1`，净宽 `192px`。
- 右侧崖台：`x=6..15, y=1..4`，顶面连续，内部只作低对比实体承托。
- 门禁：`x=672`；右出口：`x=928`；入口出生点：`x=-384`，不与左出口触发区重叠。

## 验证结果

- Stage14 gate template GUT：`5/5` tests，`555` asserts。
- Formal remap GUT：`8/8` tests，`189` asserts。
- Stage14 GUT：`16/16` tests，`389` asserts。
- 运行态复核：`stage14_gate_formal_room_review`，`ok=true`。
- Godot import：通过。

## Completion Criteria

- 普通跳不能越过能力缺口，并安全落回下层。
- Air Dash 能跨越缺口并落在右侧可见地表。
- Luna 脚底与下层 / 右侧地表 alpha 顶边一致。
- 门前后有连续安全地面，锁门和开门贴图、碰撞同步。
- 背景、崖体和神龛不被误读为额外道路。
- 双向连接、spawn、checkpoint 和 HUD 步骤不因场景重打包丢失。
