# Seal Magic VFX Atlas Preview Binding

## Summary

将 `vfx_seal_magic_atlas_ai01` 的 Godot `SpriteFrames` 作为隐藏 VFX 预览层接入玩家场景和 Seal Guardian Boss 场景，推进 P0 runtime replacement，但不替换正式 VFX 播放、hitbox、damage source、mask / blend 或 gameplay timing。

## Scope

- 目标资源：`res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres`。
- 动画名：`seal_magic`。
- 目标场景：
  - `scenes/player/player_placeholder.tscn`
  - `scenes/enemies/seal_guardian_boss.tscn`
- 测试更新：
  - Stage14 玩家场景资产引用测试覆盖 `SealMagicVfxPreview`。
  - Stage15 Boss 场景资产引用测试覆盖 `SealMagicVfxPreview`。

## Source Safety

- `vfx_seal_magic_atlas_ai01` 至少包含 1 个 `project_session_confirmed` candidate。
- 同资产仍有 `workspace_provenance_recorded_review_required` 与 `explicit_mapping_review_required` candidate，必须保留人工来源复核边界。

## Non-Goals

- 不替换玩家 Air Dash VFX 播放逻辑。
- 不替换 Boss 攻击预警或攻击命中逻辑。
- 不新增碰撞、伤害、Area2D、Particle 或 AnimationPlayer 行为。
- 不声明 VFX mask、blend、anchor、timing 或最终美术已完成。

## Validation

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
python scripts\assets\audit_p0_runtime_replacement_plan.py --strict
python scripts\assets\audit_p0_target_scene_replacement_matrix.py --strict
python scripts\assets\audit_p0_scene_replacement_batches.py --strict
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Exit Criteria

- Stage14 与 Stage15 GUT 均通过。
- P0 runtime replacement plan 推进到 `2 planned replacements, 26 already referenced`。
- P0 scene replacement batches 推进到 `21 planned scene-asset replacements, 34 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `35 passed, 20 blocked`。
- 整体仍保持 `0/55 final-ready`，不误报最终美术完成。
