# TutorialHUD Atlas Resource Binding / TutorialHUD HUD Atlas 资源绑定

## Summary

本计划继续推进 `batch_02_hud`，把 `hud_core_ui_atlas_ai01` 与 `icon_sheet_core_ai01` 的首个 Godot `AtlasTexture` 资源接入正式 `TutorialHUD`。当前只做隐藏 atlas preview 绑定，保留现有可读 HUD；正式替换需要后续语义复核、图标选择和布局调整。

## Scope

- 目标场景：`scenes/ui/tutorial_hud.tscn`
- 目标资源：
  - `res://assets/art/editor_resources/hud_core_ui_atlas_ai01/000_hud_core_ui_atlas_ai01_auto_001.atlas_texture.tres`
  - `res://assets/art/editor_resources/icon_sheet_core_ai01/000_icon_sheet_core_ai01_auto_001_c01.atlas_texture.tres`
- 接入方式：
  - 新增隐藏 `BattlePanel/HudCoreAtlasPreview`。
  - 新增隐藏 `BattlePanel/IconSheetCorePreview`。
  - 写入 `metadata/asset_id`，让 P0 runtime replacement plan 记录正式场景引用。

## Non-Goals

- 不替换当前 `DashIcon` / `RecoveryChargeIcon` 的 standalone 图标。
- 不改变 HUD 文本、位置、可见性或 Stage14 / Stage15 玩法反馈。
- 不声明 atlas region 语义人工复核、最终图标选择、小尺寸读值或授权完成。

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

- Stage12 HUD polish 测试确认两个 AtlasTexture 资源路径、metadata 和隐藏状态。
- Stage14 / Stage15 专项 GUT 继续通过。
- P0 runtime replacement plan 推进到 `16 planned replacements, 12 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `12 passed, 43 blocked`。

## Remaining Risk

- 这两个节点只是正式场景里的 atlas 资源绑定占位。
- 后续仍需人工确认 atlas region 语义、替换目标、可见布局、小尺寸读值和最终授权。
