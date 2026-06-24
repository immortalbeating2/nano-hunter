# Stage15 Boss Art Runtime Binding

## Summary

本计划继续推进 P0 runtime replacement，把 `stage15_seal_guardian_ai01` 与 `stage15_boss_attack_warning_ai01` 接入正式 Seal Guardian Boss 场景和 Stage15 Boss 房。

两个资产在 `docs/assets/imagegen-source-safety-report.json` 中均为 `project_session_confirmed`，来源证据来自当前项目 session recovery summary；本次不从全局 `generated_images` 导入新图。

## Scope

- 更新 `scenes/enemies/seal_guardian_boss.tscn`：
  - 新增 `SealGuardianArt`，引用 Boss 方向稿。
  - 新增 `AttackWarningArt`，引用 Boss attack warning VFX。
- 更新 `scenes/rooms/stage15_seal_guardian_boss_room.tscn`：
  - 新增 `SealGuardianRoomArt` 与 `BossWarningRoomArt`，让目标房间直接引用两张资源。
- 更新 `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`，新增 Boss 资产引用保护测试。
- 刷新 P0 replacement plan、scene matrix、scene batches、final art gates 和综合资产包报告。

## Non-Goals

- 不改变 Boss 血量、受击、击败信号、重试或完成房跳转逻辑。
- 不把 warning 图接入真实攻击时序、damage Area、hitbox 或 hurtbox。
- 不确认 Boss 方向稿最终清稿、动画帧序、mask / blend、授权或最终美术批准。
- 不扩大到 SpriteFrames Boss 动画替换。

## Verification Plan

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Stage15 专项 GUT 新增资产引用测试通过。
- 两个 Boss 相关资产在 P0 replacement plan 中进入 `already_referenced`。
- P0 scene replacement batches 从 `37 planned / 18 referenced` 推进到 `33 planned / 22 referenced`。
- final-art `runtime_replacement` 从 `24 passed / 31 blocked` 推进到 `26 passed / 29 blocked`。
