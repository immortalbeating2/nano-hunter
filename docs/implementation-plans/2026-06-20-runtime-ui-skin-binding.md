# Runtime UI Skin Binding Implementation Plan

## Summary

把 image gen 生成并图集化后的 UI skin 从 dev showcase / rehearsal 层推进到正式运行时 UI 场景引用。当前只接入 `menu_ninepatch_ui_ai01` 的 Theme / StyleBox，不改 UI 布局、不替换独立面板 PNG、不关闭最终美术批准。

## Scope

- 更新 `scripts/dev/build_editor_ui_skin.gd`，让 Theme 同时覆盖 `PanelContainer` 和运行时 UI 正在使用的 `Panel`。
- 更新 `scripts/dev/audit_editor_ui_skin.gd` 与综合审计期望，接受 `9` 个 UI Theme mappings。
- 修改 `scenes/ui/demo_shell.tscn` 与 `scenes/ui/tutorial_hud.tscn`：
  - 根 Control 绑定 `nano_hunter_imagegen_ui.theme.tres`
  - MainMenu / PauseMenu / PromptPanel / BattlePanel 绑定 `menu_ninepatch_ui_ai01` 的首个 `StyleBoxTexture`
- 新增 `scripts/dev/audit_runtime_ui_skin_binding.gd`。
- 更新 art readiness、final review queue、Workbench、acceptance gates、P0 replacement plan / matrix / batches 和综合审计报告。

## Non-Goals

- 不替换 DemoShell title background、pause / completion standalone panel PNG。
- 不替换 HUD icon atlas、Boss HUD frame 或 ability status HUD。
- 不调整布局、字体、文案或交互逻辑。
- 不把 UI 资产标为 `final_ready`。

## Validation

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_ui_skin.gd
godot --headless --path . --script res://scripts/dev/audit_editor_ui_skin.gd
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\audit_final_art_review_queue.py --strict
godot --headless --path . --script res://scripts/dev/build_final_art_review_workbench.gd
godot --headless --path . --script res://scripts/dev/audit_final_art_review_workbench.gd
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
git diff --check
```

## Exit Criteria

- `audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 4 panels`。
- 综合资产包审计输出 `9 UI Theme mappings` 和 `4 runtime UI skin panels`。
- P0 replacement plan 从 `27 planned / 1 referenced` 推进到 `26 planned / 2 referenced`。
- Final art acceptance gates 的 `runtime_replacement` 从 `0 passed / 55 blocked` 推进到 `2 passed / 53 blocked`。
- `final_ready` 保持 `0/55`，不冒进关闭授权、清稿或最终批准。

## Risks

- 当前 StyleBox 使用首个九宫格候选，仍需人工复核边距、拉伸失真和文字安全区。
- DemoShell / TutorialHUD 绑定了 Theme，但独立 UI 背景、图标 atlas 和 HUD frame 仍未正式替换。
- 后续若替换更多 UI 图，需要继续按 P0 scene replacement batches 拆分验证。
