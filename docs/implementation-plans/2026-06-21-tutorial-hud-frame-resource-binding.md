# TutorialHUD Frame Resource Binding / TutorialHUD HUD Frame 资源绑定

## Summary

本计划继续推进 `batch_02_hud`，把 `stage14_ability_status_hud_ai01` 与 `stage15_boss_hud_frame_ai01` 接入正式 `TutorialHUD` 的资源引用链。当前只做隐藏资源绑定，避免大图直接覆盖 HUD 文本；正式布局、裁切和读值复核后再切换为可见面板。

## Scope

- 目标场景：`scenes/ui/tutorial_hud.tscn`
- 目标资产：
  - `assets/art/ui/stage14_ability_status_hud_ai01.png`
  - `assets/art/ui/stage15_boss_hud_frame_ai01.png`
- 接入方式：
  - 新增隐藏 `TextureRect` `BattlePanel/AbilityStatusFrameArt`。
  - 新增隐藏 `TextureRect` `BattlePanel/BossHudFrameArt`。
  - 写入 `metadata/asset_id`，让 P0 runtime replacement plan 能追踪正式场景引用。

## Non-Goals

- 不改变当前 HUD 视觉布局和文本层级。
- 不让大图覆盖 `StatusLabel`、`DashLabel` 或 `ProgressLabel`。
- 不声明 Boss HUD frame / ability status frame 的最终切片、NinePatch、缩放、读值或授权完成。

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

- Stage12 HUD polish 测试确认两个 frame 资源路径、metadata 和隐藏状态。
- Stage14 / Stage15 专项 GUT 继续通过，证明 HUD 文本和玩法契约未被破坏。
- P0 runtime replacement plan 推进到 `18 planned replacements, 10 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `10 passed, 45 blocked`。

## Remaining Risk

- 这两个节点只是正式场景里的资源绑定占位，不是最终 HUD 面板布局。
- 后续仍需要裁切、缩放、text-safe area、可见性切换、Boss / ability 状态触发、授权条款和最终美术批准。
