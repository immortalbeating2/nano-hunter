# Player Readability and Air Dash Trail Binding

## Summary

本计划继续推进 P0 runtime replacement，把 `stage16_luna_player_readability_ai01` 接入正式玩家场景，并把 `stage14_air_dash_trail_ai01` 接入玩家场景和 Stage14 Air Dash 神龛房。

两个资产在 `docs/assets/imagegen-source-safety-report.json` 中均为 `project_session_confirmed`，来源证据来自当前项目 session recovery summary；本次不从全局 `generated_images` 导入新图。

## Scope

- 更新 `scenes/player/player_placeholder.tscn`：
  - 新增 `LunaReadabilityArt`，引用 Luna 玩家可读性方向稿。
  - 新增 `AirDashTrailArt`，引用 Air Dash trail 候选图。
- 更新 `scenes/rooms/stage14_air_dash_shrine_room.tscn`：
  - 新增 `AirDashTrailPreviewArt`，在神龛房提供 Air Dash trail 视觉预览。
- 更新 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`，新增玩家场景与神龛房资产引用保护。
- 刷新 P0 replacement plan、scene matrix、scene batches、final art gates 和综合资产包报告。

## Non-Goals

- 不改变玩家移动、跳跃、攻击、Air Dash 状态机或碰撞盒。
- 不把 Air Dash trail 接入真实 dash 时序、动画播放或粒子系统。
- 不确认 Luna 最终角色清稿、动画帧序、Spine rig、授权或最终美术批准。
- 不扩大到 SpriteFrames 动画替换。

## Verification Plan

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Stage14 专项 GUT 新增玩家 / trail 资产引用测试通过。
- 两个资产在 P0 replacement plan 中进入 `already_referenced`。
- P0 scene replacement batches 从 `33 planned / 22 referenced` 推进到 `30 planned / 25 referenced`。
- final-art `runtime_replacement` 从 `26 passed / 29 blocked` 推进到 `28 passed / 27 blocked`。
