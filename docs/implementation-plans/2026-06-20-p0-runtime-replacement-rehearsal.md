# P0 Runtime Replacement Rehearsal Implementation Plan

## Summary

为 `docs/assets/p0-runtime-replacement-plan.json` 中的 `28` 个 P0 runtime entries 生成 Godot 编辑器排练场景，验证 P0 资源能够绑定到兼容节点：`Sprite2D`、`AnimatedSprite2D`、`TileMapLayer`、`PanelContainer` 和 `Sprite2D + AtlasTexture`。

本计划不修改正式 gameplay / HUD / room 场景引用，不关闭 `runtime_replacement` gate，不批准最终美术。

## Scope

- 新增 `scripts/dev/build_p0_runtime_replacement_rehearsal.gd`
- 新增 `scripts/dev/audit_p0_runtime_replacement_rehearsal.gd`
- 生成 `scenes/dev/p0_runtime_replacement_rehearsal.tscn`
- 生成 `docs/assets/p0-runtime-replacement-rehearsal-manifest.json`
- 扩展 `scripts/assets/audit_asset_package.py`
- 更新资产矩阵、status、timeline 和当日日志

## Node Coverage

- `CompressedTexture2D / Texture2D` -> `Sprite2D`
- `SpriteFrames` -> `AnimatedSprite2D`
- `TileSet` -> `TileMapLayer`
- `StyleBoxTexture` -> `PanelContainer`
- `AtlasTexture` -> `Sprite2D`

## Verification

```powershell
godot --headless --path . --script res://scripts/dev/build_p0_runtime_replacement_rehearsal.gd
godot --headless --path . --script res://scripts/dev/audit_p0_runtime_replacement_rehearsal.gd
python -m py_compile scripts\assets\audit_asset_package.py
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- Rehearsal scene 包含 `28` 个 P0 resource-bound nodes。
- Manifest 记录 `17` 个 Texture2D 节点、`7` 个 SpriteFrames 节点、`1` 个 TileSet 节点、`1` 个 StyleBoxTexture 节点和 `2` 个 AtlasTexture 节点。
- Godot audit 确认每类节点都能加载并消费资源。
- 综合资产包审计纳入 `28 P0 runtime rehearsal nodes`。

## Risks

- Rehearsal 是正式替换前的编辑器排练，不会自动修改目标场景。
- 正式替换仍需按 Stage / HUD / room 分批处理，并运行对应 GUT、Godot import、人工试玩和 `asset-ingestion-checklist.md`。
