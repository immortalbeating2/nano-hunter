# Editor TileSet Resource Layer

Date: 2026-06-20

## Summary

把已经完成 target-count 与 duplicate clearance 的 `tileset_sheet` 输出，进一步生成 Godot 可加载的 `.tileset.tres` 候选资源。该步骤服务于编辑器使用和后续场景替换，不改变运行时场景引用。

## Goals

- 为 `miasma_marsh_tileset_ai01` 生成 Godot `TileSet` 候选资源。
- 为 `shrine_trial_tileset_ai01` 生成 Godot `TileSet` 候选资源。
- 让每个 `TileSet` 使用对应 PNG sheet、manifest 中的 `cell` 尺寸和 `expected_target` tile 数量。
- 提供 Godot headless 审计脚本，验证资源可加载、source 类型正确、tile 数量匹配。

## Non-Goals

- 不配置 collision polygon。
- 不配置 terrain sets、autotile、navigation、occlusion 或 physics layer。
- 不替换任何运行时 TileMap / TileMapLayer 引用。
- 不宣称 TileSet 美术语义、危险边界或平台读值已经完成。

## Key Changes

- 新增 `scripts/dev/build_editor_tilesets.gd`，从 `docs/assets/asset-atlas-build-manifest.json` 读取 `tileset_sheet` 输出并生成 `.tileset.tres`。
- 新增 `scripts/dev/audit_editor_tilesets.gd`，用 Godot 加载 `.tileset.tres` 并验证 `TileSetAtlasSource`、tile count 和 region size。
- 新增输出目录 `assets/art/tilesets/editor_tilesets/`。
- 生成：
  - `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`
  - `assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres`

## Commands

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
godot --headless --path . --import
```

Recommended full asset validation after this step:

```powershell
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\audit_asset_target_coverage.py --strict
python scripts\assets\audit_editor_atlas_textures.py --strict
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- 两个 `.tileset.tres` 文件存在于 `assets/art/tilesets/editor_tilesets/`。
- Godot headless 审计输出 `Editor TileSet resources OK: 2`。
- 现有 atlas target-count 审计仍通过。
- Godot import 仍通过。
- 文档明确记录当前边界：这是 TileSet 资源骨架，不是最终 collision / terrain / runtime integration。

## Risks

- 自动网格 tile 只证明资源可加载，不证明 tile 语义正确。
- 后续如果人工重切 TileSet sheet，需要重新运行 build / audit。
- 运行时接入前必须补 collision、terrain、危险边界和读值复核。
