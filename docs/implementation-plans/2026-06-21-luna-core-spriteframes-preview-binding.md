# Luna Core SpriteFrames Preview Binding

## Summary

将当前项目 session 已确认的 Luna 核心动作 SpriteFrames 作为隐藏预览层接入正式玩家场景，推进 P0 runtime replacement，但不替换玩家控制器动画、碰撞盒、状态机或正式动画播放。

## Scope

- 接入 `luna_run_sheet_ai01.spriteframes.tres`，动画名 `run`。
- 接入 `luna_air_dash_sheet_ai01.spriteframes.tres`，动画名 `air_dash`。
- 接入 `luna_attack_01_sheet_ai01.spriteframes.tres`，动画名 `attack_01`。
- 接入 `luna_idle_sheet_ai01.spriteframes.tres`，动画名 `idle`。
- 目标场景为 `scenes/player/player_placeholder.tscn`。
- 扩展 Stage14 GUT，验证隐藏 `AnimatedSprite2D` 节点、`asset_id` metadata、SpriteFrames 路径、动画名和帧数。

## Source Safety

- 四个接入资产均至少包含一个 `project_session_confirmed` candidate。
- `luna_jump_fall_sheet_ai01` 当前没有 `project_session_confirmed` candidate，本次不接入。
- 每个接入资产仍保留 frame order、脚底基线 / anchor、timing、授权条款和最终美术批准 blocker。

## Non-Goals

- 不替换 `PlayerPlaceholder` 当前灰盒 Polygon / Sprite 显示。
- 不改变玩家移动、Air Dash、攻击、受击、碰撞盒、hurtbox 或 hitbox。
- 不把隐藏预览节点视为最终动画接入。

## Validation

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Exit Criteria

- Stage14 GUT 通过，并覆盖四个隐藏动画预览节点。
- P0 runtime replacement plan 推进到 `3 planned replacements, 25 already referenced`。
- P0 scene replacement batches 推进到 `23 planned scene-asset replacements, 32 already referenced`。
- Final art acceptance gates 的 `runtime_replacement` 推进到 `34 passed, 21 blocked`。
- 整体仍保持 `0/55 final-ready`，不误报最终美术完成。
