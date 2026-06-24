# Editor AtlasTexture Resource Layer

Date: 2026-06-20

## Summary

本计划把已生成的 image gen atlas / tileset sheet / UI atlas / NinePatch sheet / Spine parts / promo / storyboard sheet 进一步整理为 Godot 编辑器可直接加载的 `AtlasTexture` `.tres` 资源。Sprite Sheet 与 VFX Sprite Sheet 已由 `build_asset_atlases.py` 生成 `SpriteFrames`，本计划重点补齐非 SpriteFrames 输出的编辑器资源层。

## Scope

生成 `AtlasTexture` 的来源类型：

- `atlas`
- `tileset_sheet`
- `ninepatch_sheet`

默认不为 `sprite_sheet` 再生成逐帧 `AtlasTexture`，因为这些输出已有 `.spriteframes.tres`。

## Key Changes

- 新增 `scripts/assets/build_editor_atlas_textures.py`
  - 读取 `docs/assets/asset-atlas-build-manifest.json` 与各 `.regions.json`。
  - 为每个 region 输出一个 `.atlas_texture.tres`。
  - 输出索引：`assets/art/editor_resources/editor_atlas_textures.index.json`。
- 新增 `scripts/assets/audit_editor_atlas_textures.py`
  - 静态验证索引、源图、region 和 `.tres` 格式。
- 新增 `scripts/dev/audit_editor_atlas_textures.gd`
  - 在 Godot headless 下逐个 `ResourceLoader.load(...)`，验证资源可被 Godot 识别为 `AtlasTexture`。

## Outputs

- `302` 个 `AtlasTexture` `.tres` resources。
- 覆盖 `16` 个非 SpriteFrames atlas-linked assets：
  - UI atlas / icon sheet / NinePatch sheet
  - shrine / miasma TileSet sheets
  - prop / equipment atlas
  - Luna / Seal Guardian Spine parts atlas
  - material texture atlas
  - promo / CG / storyboard sheets

## Commands

```powershell
python scripts\assets\build_editor_atlas_textures.py --dry-run
python scripts\assets\build_editor_atlas_textures.py --clean
python scripts\assets\audit_editor_atlas_textures.py --strict
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
godot --headless --path . --import
```

## Validation

- `build_editor_atlas_textures.py --dry-run` planned `302` resources.
- `build_editor_atlas_textures.py --clean` wrote `302` resources and the index.
- `audit_editor_atlas_textures.py --strict` audited `302` resources across `16` assets.
- Godot script reported `Editor AtlasTexture resources OK: 302`.
- `godot --headless --path . --import` exited `0`.

## Boundary

- These resources make atlas regions easier to use in the editor; they do not replace manual art review.
- TileSet collision / terrain rules, NinePatch slice margins, UI text-safe regions, VFX anchors and runtime scene references still require separate polish and validation before `integrated` status.
