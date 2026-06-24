# ImageGen Runtime Asset Catalog Implementation Plan

Date: 2026-06-20

## Summary

在 runtime integration map 之后，为 `55` 个 image gen 资产生成 Godot `ResourcePreloader` 目录场景。该层证明资源不只是有路径和 map，而是可以被 Godot 运行时集中加载。它不替换正式 gameplay / HUD / room 引用，也不代表最终美术完成。

## Goals

- 为每个 runtime map entry 选择一个实际可加载的 Godot 资源。
- 动画优先使用 `SpriteFrames`。
- TileSet 优先使用 `.tileset.tres`。
- 九宫格优先使用 `StyleBoxTexture`。
- Atlas 类优先使用代表性 `AtlasTexture`。
- 其它 standalone 图像使用 `Texture2D`。
- 生成可由 Godot 加载的 runtime catalog scene 和 manifest。
- 将 runtime catalog 纳入 Art readiness 与综合资产包审计。

## Non-Goals

- 不替换游戏场景引用。
- 不把 catalog 作为 autoload。
- 不完成 UI layout、TileSet collision、VFX timing、动画帧序或玩法读值复核。
- 不改变 `final_ready`。

## Key Changes

- 新增 `scripts/dev/build_imagegen_runtime_asset_catalog.gd`。
- 新增 `scripts/dev/audit_imagegen_runtime_asset_catalog.gd`。
- 生成 `scenes/dev/imagegen_runtime_asset_catalog.tscn`。
- 生成 `docs/assets/imagegen-runtime-asset-catalog-manifest.json`。
- 扩展 `scripts/assets/audit_art_readiness.py`，把 runtime blocker 推进为 `runtime_catalog_ready_manual_replacement`。
- 扩展 `scripts/assets/audit_asset_package.py`，校验 runtime catalog scene / manifest / resources。

## Validation

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_runtime_asset_catalog.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_runtime_asset_catalog.gd
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
```

当前结果：

- `Imagegen runtime asset catalog built: 55 resources`
- `Imagegen runtime asset catalog OK: 55 resources`
- `runtime_binding_map_ready_manual_replacement=0`
- `runtime_catalog_ready_manual_replacement=55`
- `Asset package audit OK`，并记录 `55 runtime catalog resources`

## Exit Criteria

- catalog scene 存在。
- catalog manifest 存在。
- `ResourcePreloader` 中有 `55` 个资源。
- manifest 中有 `55` 条 entry。
- 每条 entry 的 `resource_path` 能被 Godot 加载。
- readiness / package audit 通过。

## Risks / Follow-Up

- Runtime catalog 是集中加载入口，不是正式引用替换。
- 后续 Stage polish 应从 catalog 中逐项取用资源，替换玩家、敌人、Boss、HUD、UI、房间、TileMap、VFX 或发布素材引用。
- 正式替换后必须运行对应 GUT、Godot import 和人工试玩复核。
