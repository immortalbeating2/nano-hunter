# Stage14 Air Dash Prop Runtime Binding

## Summary

本计划继续推进 P0 runtime replacement，把 `stage14_air_dash_shrine_ai01` 与 `stage14_air_dash_gate_ai01` 接入正式 Stage14 Air Dash 神龛房和能力门房。

两个资产在 `docs/assets/imagegen-source-safety-report.json` 中均为 `project_session_confirmed`，来源证据来自当前项目 session recovery summary；本次不从全局 `generated_images` 导入新图。

## Scope

- 更新 `scenes/rooms/stage14_air_dash_shrine_room.tscn`：
  - 在 `AirDashShrine` 下新增 `ShrineArt`。
  - 在同一 marker 下新增 `GatePreviewArt`，作为能力门预览。
- 更新 `scenes/rooms/stage14_air_dash_gate_room.tscn`：
  - 在 `AirDashGateSensor` 下新增 `ShrineEchoArt`。
  - 在 `GateBarrier` 下新增 `GateArt`。
- 更新 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`，新增资产引用保护测试。
- 刷新 P0 replacement plan、scene matrix、scene batches、final art gates 和综合资产包报告。

## Non-Goals

- 不改 Stage14 Air Dash 解锁逻辑。
- 不改 `GateBarrier` 的碰撞形状或门控条件。
- 不确认最终 prop 清稿、授权、缩放、遮挡或读值完成。
- 不扩大到玩家动画、TileSet 或 Boss 资源替换。

## Verification Plan

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Stage14 专项 GUT 新增资产引用测试通过。
- 两个 prop 在 P0 replacement plan 中进入 `already_referenced`。
- P0 scene replacement batches 从 `41 planned / 14 referenced` 推进到 `37 planned / 18 referenced`。
- final-art `runtime_replacement` 从 `22 passed / 33 blocked` 推进到 `24 passed / 31 blocked`。
