# Miasma Tileset Preview Binding

## Summary

本轮继续推进 Nano Hunter image gen 资产接入，但只使用当前项目已确认的 `project_session_confirmed` 资产，不从全局 `generated_images` 或其它项目候选中引入新图。

目标是把 `miasma_marsh_tileset_ai01` 的 Godot `TileSet` 资源作为视觉预览层接入正式 Stage13 / Stage14 房间，让瘴泽 TileSet 从 dev showcase 进入正式房间可审计引用；本轮不替换灰盒碰撞、不配置正式 autotile、不新增 hazard Area。

## Scope

- 接入资源：`res://assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`
- 目标场景：
  - `scenes/rooms/stage13_miasma_marsh_entry_room.tscn`
  - `scenes/rooms/stage14_air_dash_gate_room.tscn`
- 测试：
  - `tests/stage13/test_stage_13_second_content_zone_production.gd`
  - `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

## Key Changes

- 在 Stage13 瘴泽入口房新增 `MiasmaTilesetPreview` `TileMapLayer`，绑定 `miasma_marsh_tileset_ai01.tileset.tres`。
- 在 Stage14 Air Dash gate 房新增 `MiasmaTilesetPreview` `TileMapLayer`，绑定同一 TileSet，作为能力门区域的瘴泽视觉预览。
- 两个节点均标记 `metadata/asset_id = "miasma_marsh_tileset_ai01"` 和 `metadata/asset_binding_note = "visual_preview_only_collision_still_graybox"`。
- 测试只验证 TileSet 资源路径、source count 和 used cells，不把本轮视为最终碰撞或地形替换完成。

## Validation

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage13/test_stage_13_second_content_zone_production.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd
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

- Stage13 / Stage14 正式房间均引用 `miasma_marsh_tileset_ai01` 的 Godot TileSet 资源。
- Stage13 / Stage14 GUT 均通过。
- P0 runtime replacement plan 推进到 `8 planned replacements, 20 already referenced`。
- P0 scene replacement batches 推进到 `28 planned scene-asset replacements, 27 already referenced`。
- final-art acceptance gates 推进到 `29 runtime_replacement passed, 26 blocked`，但仍保持 `0/55 final-ready`，且 `miasma_marsh_tileset_ai01` 继续保留 collision / terrain / hazard manual review blocker。

## Boundaries

- 不改变 Stage13 / Stage14 的 StaticBody2D 灰盒碰撞。
- 不把 TileSet 预览当作正式地形替换。
- 不关闭 `miasma_marsh_tileset_ai01` 的 final approval、license terms、collision / terrain 或 hazard safe boundary blocker。
- 不使用任何未确认属于 Nano Hunter 的 review-required 候选。
