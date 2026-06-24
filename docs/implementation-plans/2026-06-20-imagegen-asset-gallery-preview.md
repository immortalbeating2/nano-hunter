# ImageGen Asset Gallery Preview Layer

Date: 2026-06-20

## Summary

新增一个 Godot 编辑器内可打开的 image gen 资产 Gallery，用于集中预览当前资产包的角色、关卡、UI、图标、道具、VFX、动画帧、贴图、宣传图、CG 和分镜资产。该层补足“结构审计通过但人工扫图入口分散”的缺口。

## Goals

- 生成 `scenes/dev/imagegen_asset_gallery.tscn`。
- 生成 `docs/assets/imagegen-asset-gallery-manifest.json`。
- 在 Gallery 中集中展示：
  - `55` 个 queue output PNG。
  - `302` 个 Godot `AtlasTexture` region。
  - `2` 个 TileSet sheet 预览入口。
  - `8` 个 `StyleBoxTexture` 九宫格候选。
  - `2` 个 Spine-style cutout atlas 预览入口 / `48` 个 part descriptors。
- 增加 Godot headless 审计脚本，确认 scene 和 manifest 可加载。
- 强化审计脚本，确认预览卡片实际绑定可加载的 `Texture2D` 或 `StyleBoxTexture`，避免空卡片通过。

## Non-Goals

- 不做最终美术清稿。
- 不替换运行时场景、HUD、Boss、VFX 或 UI 引用。
- 不判断授权可商用状态。
- 不配置 TileSet collision、terrain sets、NinePatch 最终边距、VFX 锚点或 Spine rig。

## Key Changes

- 新增 `scripts/dev/build_imagegen_asset_gallery.gd`。
- 新增 `scripts/dev/audit_imagegen_asset_gallery.gd`。
- 新增 `scenes/dev/imagegen_asset_gallery.tscn`。
- 新增 `docs/assets/imagegen-asset-gallery-manifest.json`。
- 更新 `scripts/assets/audit_asset_package.py`，把 Gallery manifest / scene 纳入综合审计。

## Commands

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Exit Criteria

- Gallery scene 成功生成。
- Gallery manifest 记录的关键计数与当前资产包一致。
- `audit_imagegen_asset_gallery.gd` 通过，并输出 `Imagegen asset gallery OK`。
- 审计确认 `361` 个普通纹理预览和 `8` 个 `StyleBoxTexture` 预览均有有效资源绑定。
- `audit_asset_package.py --strict --write-report` 继续通过，报告 `ok=true`。

## Risks

- Gallery 是人工预览入口，不是最终 runtime integration。
- 场景节点数量较多，只用于开发 / 审计，不作为正式游戏场景。
- 后续 queue 或 atlas 数量变化时，必须同步重建 Gallery、更新 manifest 和综合审计期望。
