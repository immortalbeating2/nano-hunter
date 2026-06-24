# Seal Guardian SpriteFrames Preview Binding

## Summary

本轮继续推进 Nano Hunter image gen 资产运行时接入，把 `seal_guardian_boss_sheet_ai01` 的 Godot `SpriteFrames` 资源接入 Seal Guardian Boss 正式场景与 Boss 房，作为动画预览层。

该资源当前包含 `project_session_confirmed` 候选，也包含 provenance review-required 候选，因此本轮只做隐藏预览节点绑定，不替换 Boss 状态机、攻击时序、damage Area 或正式动画播放逻辑。

## Scope

- 接入资源：`res://assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.spriteframes.tres`
- 目标场景：
  - `scenes/enemies/seal_guardian_boss.tscn`
  - `scenes/rooms/stage15_seal_guardian_boss_room.tscn`
- 测试：
  - `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

## Key Changes

- `SealGuardianBoss` 新增隐藏 `SealGuardianAnimationPreview` `AnimatedSprite2D`。
- `Stage15SealGuardianBossRoom` 新增隐藏 `SealGuardianRoomAnimationPreview` `AnimatedSprite2D`。
- 两个节点均绑定 `seal_guardian_boss_sheet_ai01.spriteframes.tres`，默认动画为 `attack`。
- 两个节点均标记 `metadata/asset_id = "seal_guardian_boss_sheet_ai01"` 和 `metadata/asset_binding_note = "animation_preview_only_state_machine_still_graybox"`。
- Stage15 专项测试新增 AnimatedSprite2D 资源断言，验证 SpriteFrames 路径、动画名和帧数。

## Validation

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_asset_package.py --write-report --strict
python scripts\assets\audit_imagegen_source_safety.py --strict
python scripts\assets\audit_asset_provenance.py --strict
git diff --check
```

## Exit Criteria

- Boss 场景与 Boss 房均引用 `seal_guardian_boss_sheet_ai01.spriteframes.tres`。
- Stage15 GUT 通过。
- P0 runtime replacement plan 推进到 `7 planned replacements, 21 already referenced`。
- P0 scene replacement batches 推进到 `27 planned scene-asset replacements, 28 already referenced`。
- final-art acceptance gates 推进到 `30 runtime_replacement passed, 25 blocked`，但仍保持 `0/55 final-ready`。

## Boundaries

- 不替换 Boss 的 Polygon2D 灰盒表现、状态机、攻击时序、damage Area 或 hitbox。
- 不自动播放正式 Boss 动画。
- 不关闭 frame order、foot baseline / anchor、animation timing、license terms 或 final approval blocker。
- 不使用其它项目资产；source safety 仍要求 `unsafe_candidate_count = 0`，混合来源候选继续保留人工复核边界。
