# TutorialHUD P0 Icon Runtime Binding / TutorialHUD P0 图标接入

## Summary

本计划继续推进 P0 runtime replacement，把 `stage14_air_dash_icon_ai01` 与 `stage15_recovery_charge_icon_ai01` 接入正式 `TutorialHUD`。该工作只替换 HUD 图标显示层，不改变 HUD 文本逻辑、恢复充能规则或 Air Dash 玩法。

## Scope

- 目标场景：`scenes/ui/tutorial_hud.tscn`
- 目标资产：
  - `assets/art/ui/stage14_air_dash_icon_ai01.png`
  - `assets/art/ui/stage15_recovery_charge_icon_ai01.png`
- 接入方式：
  - 将 `BattlePanel/DashIcon` 从纯色 `ColorRect` 推进为 `TextureRect`，绑定 Air Dash 图标。
  - 新增 `BattlePanel/RecoveryChargeIcon`，绑定 Recovery Charge 图标。

## Non-Goals

- 不修改 `TutorialHUD.gd` 的文本拼接和阶段优先级。
- 不改变 Stage14 Air Dash 规则、Stage15 Recovery Charge 规则或 Boss HUD 逻辑。
- 不声明图标最终小尺寸读值、清稿或授权条款完成。

## Validation

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Exit Criteria

- Stage12 HUD polish 测试确认两个 image gen 图标节点和资源路径。
- Stage14 / Stage15 专项 GUT 继续通过，证明 HUD 文本和玩法契约未被破坏。
- P0 runtime replacement plan 推进到 `20 planned replacements, 8 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `8 passed, 47 blocked`。

## Remaining Risk

- 图标仍需 32x32 / 64x64 小尺寸读值复核、边缘清稿、授权条款复核和最终美术批准。
- `hud_core_ui_atlas_ai01`、`icon_sheet_core_ai01`、`stage14_ability_status_hud_ai01` 和 `stage15_boss_hud_frame_ai01` 仍未正式接入。
