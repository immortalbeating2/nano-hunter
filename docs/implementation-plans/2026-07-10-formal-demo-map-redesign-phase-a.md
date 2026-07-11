# Formal Demo Map Redesign Phase A

## 目标

冻结完整地图重做的生产契约，并把 `tutorial_room` 推进为第一个正式教学构图样板。Phase A 不批量改 39 房，也不提前抽通用生成器。

## 执行清单

- [x] 核实基准视野、64px 网格、当前房间数量和统一 `960x384` 问题。
- [x] 冻结房间原型、尺寸分级、玩法节拍和 TileMapLayer 契约。
- [x] 冻结三类样板和 Batch 1-9 推广顺序。
- [x] 写入资产保留 / 清稿 / 归档 / 补生成边界。
- [x] 为 `tutorial_room` 画正式 24x6 网格蓝图，分成四个教学子区。
- [x] 复核现有 Terrain / props 是否覆盖蓝图语义，只补真正缺失的 tile。
- [x] 实现 tutorial 正式地形、子区地标和视觉层。
- [x] 保持教程四步骤、门控、出口、碰撞和 Stage5 测试契约。
- [x] 运行 tutorial GUT、Stage3 / Stage5 GUT、Godot import和四点运行态截图。
- [x] 更新 status、timeline 和当日日志，记录 Phase A 结果与 Stage14 样板入口。

## Tutorial 蓝图边界

- 房间保留 `24x6`，不因空荡问题盲目继续加长。
- 子区顺序固定：入口移动 `6` 格、跳跃教学 `6` 格、dash 门 `6` 格、训练 / 出口 `6` 格。
- 四区之间用高度、门楣、地标或中景结构分隔，但主路保持连续和可回退。
- 跳台仍允许下方通过；dash 门前后保留安全落点；训练目标和出口门禁不互相遮挡。
- 背景 / 装饰层无碰撞，且不得形成可踩误读。

## 验证

```powershell
godot --headless --path . -s res://scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_tutorial_trial.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --path . --display-driver windows --rendering-driver opengl3 -s res://scripts/dev/capture_tutorial_collision_driven_terrain_review.gd
godot --headless --path . --import
git diff --check
```

## Completion Criteria

- tutorial 四段教学在一个房间内形成四个可识别子区。
- 每个子区都有玩法职责和地标，不再是一条空走廊。
- Luna 脚底、跳台、dash 门和出口碰撞读值一致。
- 旧误读 tile 不回归，现有教程逻辑与 Stage5 契约不变。
