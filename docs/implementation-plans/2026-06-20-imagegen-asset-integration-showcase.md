# ImageGen Asset Integration Showcase

Date: 2026-06-20

## Summary

本计划把本会话 image gen 已落盘资产继续推进到 Godot 节点级消费验证。目标不是替换正式游戏场景，而是证明当前 `assets/art/`、`SpriteFrames`、`TileSet`、`StyleBoxTexture` 与 `AtlasTexture` 资源可以被真实 Godot 节点加载。

## Scope

- 新增 `scenes/dev/imagegen_asset_integration_showcase.tscn`。
- 新增 `docs/assets/imagegen-asset-integration-showcase-manifest.json`。
- 新增生成脚本 `scripts/dev/build_imagegen_asset_integration_showcase.gd`。
- 新增审计脚本 `scripts/dev/audit_imagegen_asset_integration_showcase.gd`。

## Asset Inputs

- `docs/assets/asset-atlas-build-manifest.json`
- `assets/art/editor_resources/editor_atlas_textures.index.json`
- `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json`

## Godot Node Coverage

- `10` 个 `AnimatedSprite2D`：加载当前 `.spriteframes.tres`，覆盖角色、敌人、Boss 与 VFX sheet。
- `2` 个 `TileMapLayer`：加载 Batch07 两套 `.tileset.tres`，并放置少量 tile。
- `4` 个 `PanelContainer`：加载 Batch08 `StyleBoxTexture` 九宫格候选。
- `8` 个 `Sprite2D`：加载代表性的 `AtlasTexture` region，覆盖 icon、prop、equipment、texture、promo、storyboard 与 Spine part。

## Boundary

- 本计划只验证资源可以被 Godot 节点消费。
- 不替换运行时场景引用。
- 不配置 TileSet collision、terrain sets、navigation 或 autotile。
- 不调整 NinePatch 最终 margin、Theme、UI 文案安全区或运行时 UI 引用。
- 不验证动画速度、锚点、VFX mask、Spine rig、授权 readiness 或最终美术质量。

## Commands

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

## Exit Criteria

- 生成脚本成功写入 scene 与 manifest。
- manifest 计数为：
  - `animated_sprite_nodes=10`
  - `tilemap_layer_nodes=2`
  - `stylebox_nodes=4`
  - `atlas_sprite_nodes=8`
- 审计脚本加载 scene 后逐节点确认资源绑定存在。
- 后续完整验证链继续通过。

## Verification

2026-06-20 已执行：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

结果：审计输出 `Imagegen asset integration showcase OK: res://scenes/dev/imagegen_asset_integration_showcase.tscn`。

## Next Steps

- 若后续新增 Batch 资产，重建 atlas / editor resources 后同步重建本 showcase。
- 真正替换运行时场景时，另起对应 Stage polish / asset integration plan，并执行 `asset-ingestion-checklist.md`。
