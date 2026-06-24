# DemoShell UI Shell Texture Binding Implementation Plan

## Summary

在 `Runtime UI Skin Binding` 的基础上，继续推进 `batch_01_ui_shell`：把 DemoShell 的标题背景、菜单图标 strip、暂停面板图和完成面板图接入正式 UI 场景。此步骤只做装饰性 UI 资源绑定和完成态展示，不改变 Demo 开始、暂停、继续、重开或房间推进逻辑。

## Scope

- 更新 `scenes/ui/demo_shell.tscn`
  - 新增 `TitleBackground`
  - 新增 `MainMenu/MenuIconStrip`
  - 新增 `PauseMenu/PausePanelArt`
  - 新增 `CompletionPanel/CompletionPanelArt`
- 更新 `scripts/ui/demo_shell.gd`
  - 读取 Main 快照控制 `CompletionPanel` 显示
  - 保持开始、暂停、继续和重开流程不变
- 更新 `scripts/dev/audit_runtime_ui_skin_binding.gd`
  - 验证 `2` 个 UI 场景、`5` 个 Panel 和 `4` 个 DemoShell TextureRect
- 更新 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`
  - 补 DemoShell image gen UI 壳资源引用测试
- 刷新 P0 replacement plan / target scene matrix / scene replacement batches、art readiness、final review queue、Workbench、acceptance gates 和综合资产包审计。

## Non-Goals

- 不替换 HUD atlas、Boss HUD frame 或 ability status HUD。
- 不调整 DemoShell 交互逻辑。
- 不把 UI 资产标为 `final_ready`。
- 不从全局 imagegen 目录导入新图。

## Validation

```powershell
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\audit_final_art_review_queue.py --strict
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_final_art_acceptance_gates.py --strict
godot --headless --path . --script res://scripts/dev/build_final_art_review_workbench.gd
godot --headless --path . --script res://scripts/dev/audit_final_art_review_workbench.gd
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_p0_runtime_replacement_plan.py --strict
python scripts\assets\audit_p0_target_scene_replacement_matrix.py --strict
python scripts\assets\audit_p0_scene_replacement_batches.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
git diff --check
```

## Exit Criteria

- Runtime UI binding 审计输出 `2 scenes, 5 panels, 4 textures`。
- Stage16 专项 GUT 通过，并包含 DemoShell UI shell asset reference 测试。
- P0 replacement plan 推进到 `23 planned replacements, 5 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `5 passed, 50 blocked`。
- 综合资产包审计输出 `5 runtime UI skin panels, 4 runtime UI skin textures`。
- `final_ready` 仍保持 `0/55`。

## Risks

- 当前 DemoShell 使用大图缩放到小 UI 区域，仍需人工复核裁切、对比度、小尺寸读值和伪文字。
- CompletionPanel 只是根据 Main 快照显示完成态，不代表完整终局 UI polish。
- 后续要继续按 batch 接入 HUD icon atlas、Boss HUD frame、ability status HUD 和其它 runtime UI 资源。
