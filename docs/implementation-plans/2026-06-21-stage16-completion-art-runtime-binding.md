# Stage16 Completion Art Runtime Binding / Stage16 完成反馈资产接入

## Summary

本计划继续推进 P0 runtime replacement，把 `stage16_alpha_demo_completion_ai01` 从 runtime catalog / rehearsal 状态推进到正式 Stage16 终点房引用。该工作只接入当前项目内已有 PNG，不从全局 `C:\Users\peng8\.codex\generated_images` 导入新图。

## Scope

- 目标资产：`assets/art/ui/stage16_alpha_demo_completion_ai01.png`
- 目标场景：`scenes/rooms/stage16_alpha_demo_end_room.tscn`
- 接入方式：新增 `Sprite2D` 完成反馈装饰节点，保留现有 `AlphaDemoSeal`、`ExitZone` 和完成触发逻辑。
- 不做项：不修改 Stage16 流程、不改 HUD 文案、不声明最终 UI 清稿或 `final_ready`。

## Key Changes

- `stage16_alpha_demo_end_room.tscn` 新增 `AlphaDemoCompletionArt`，引用 `stage16_alpha_demo_completion_ai01.png`。
- `tests/stage16/test_stage_16_alpha_demo_candidate.gd` 新增终点房 image gen completion art 引用断言。
- 刷新 art readiness、final art review queue、final art acceptance gates、P0 replacement plan、P0 scene matrix、P0 scene batches 和综合 asset package report。
- 审计期望从上一轮 `5 passed / 50 blocked` 推进到 `6 passed / 49 blocked`。

## Validation

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
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
python scripts\assets\audit_p0_runtime_replacement_plan.py --strict
python scripts\assets\audit_p0_target_scene_replacement_matrix.py --strict
python scripts\assets\audit_p0_scene_replacement_batches.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Exit Criteria

- Stage16 专项 GUT 通过，并包含终点房 completion art 引用测试。
- P0 runtime replacement plan 显示 `22 planned replacements, 6 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 显示 `6 passed, 49 blocked`。
- 综合资产包审计通过。

## Remaining Risk

- 该资产仍需要 UI 清稿、伪文字 / 细节读值复核、授权条款复核和最终美术批准。
- 整体资产目标仍为 `55/55 structural_ready, 0/55 final_ready`。
