# P0 Scene Replacement Batches Implementation Plan

## Summary

把 `docs/assets/p0-target-scene-replacement-matrix.json` 中的 `13` 个 P0 目标场景拆成可逐批执行的替换顺序，服务后续真正修改 `.tscn` 前的排程、风险隔离和验证规划。

## Scope

- 新增 `docs/assets/p0-scene-replacement-batches.json`
- 新增 `docs/assets/p0-scene-replacement-batches.md`
- 新增生成脚本 `scripts/assets/build_p0_scene_replacement_batches.py`
- 新增审计脚本 `scripts/assets/audit_p0_scene_replacement_batches.py`
- 将该层纳入 `scripts/assets/audit_asset_package.py`

## Batch Order

1. `batch_00_dev_reference`
2. `batch_01_ui_shell`
3. `batch_02_hud`
4. `batch_03_player`
5. `batch_04_boss_core`
6. `batch_05_stage14_air_dash`
7. `batch_06_stage16_end_chain`
8. `batch_07_stage13_tileset`
9. `batch_08_combat_enemy_animation`

## Non-Goals

- 不自动修改正式 `.tscn`。
- 不替换 gameplay / HUD / room / Boss / VFX / TileMap 场景引用。
- 不把任何资产标记为 `final_ready`。
- 不从全局 `C:\Users\peng8\.codex\generated_images` 导入图片。

## Validation

```powershell
python -m py_compile scripts\assets\build_p0_scene_replacement_batches.py scripts\assets\audit_p0_scene_replacement_batches.py scripts\assets\audit_asset_package.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_p0_scene_replacement_batches.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `9` 个替换批次覆盖 `13` 个目标场景。
- `28` 个唯一 P0 资产全部进入至少一个批次。
- `55` 个 scene-asset references 全部进入批次。
- 缺失场景数为 `0`，未分批场景数为 `0`。
- 综合资产包审计纳入 P0 scene replacement batches。

## Risks

- 批次计划仍只是排程，不代表运行时引用已替换。
- 包含 `SpriteFrames`、`TileSet`、`StyleBoxTexture` 的批次需要 Godot 编辑器和人工复核。
- animation / UI / TileSet / VFX 相关批次仍受 family polish blockers 约束。
