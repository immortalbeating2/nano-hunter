# ImageGen Target-Count Atlas Rebuild

## Summary

本计划把已落盘的 image gen raw candidates 从 `expected_min` 图集构建推进到 `expected_target` 图集构建。目标是让 Sprite Sheet、Texture Atlas、TileSet、Spine 拆件图集、UI 图集、VFX 图集、九宫格和分镜 / 宣传 sheet 在数量上达到 `docs/assets/asset-atlas-build-manifest.json` 的目标规格，方便后续 Godot 编辑器预览和人工清稿。

## Scope

- `docs/assets/asset-atlas-build-manifest.json` 中的 `26` 个 atlas-linked outputs。
- `assets/source/ai_generated/**/selected_frames/`
- `assets/source/ai_generated/**/selected_items/`
- `assets/source/ai_generated/**/selected_tiles/`
- `assets/source/ai_generated/**/selected_parts/`
- `assets/source/ai_generated/**/selected_panels/`
- `assets/art/**` 下由 `build_asset_atlases.py` 生成的 PNG、metadata JSON 与 `.spriteframes.tres`。

## Non-Goals

- 不生成新的 raw image gen 候选。
- 不替换运行时玩家、敌人、HUD、场景、TileSet 或 VFX 引用。
- 不承诺最终清稿、最终帧序、最终 TileSet 语义或 UI 小尺寸读值。
- 不启用 Spine / Aseprite 类插件。

## Execution

```powershell
python scripts\assets\prepare_selected_sources.py --target target --dry-run
python scripts\assets\prepare_selected_sources.py --target target --overwrite
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\build_asset_atlases.py
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
```

## Result

- `26/26` atlas-linked outputs 达到 `expected_target`。
- selected source 数量：
  - `selected_frames`: `236`
  - `selected_items`: `122`
  - `selected_tiles`: `96`
  - `selected_parts`: `48`
  - `selected_panels`: `36`
- `assets/art/**/*.png`: `55`
- `assets/art/**/*.png.import`: `55`
- `assets/art/**/*.frames.json` / `*.regions.json`: `26`
- `assets/art/**/*.spriteframes.tres`: `10`
- `godot --headless --path . --import` 退出码为 `0`
- `audit_asset_target_coverage.py --strict` 通过，同时记录到部分输出存在 duplicate 补位：
  - `luna_run_sheet_ai01`: `12`
  - `vfx_combat_atlas_ai01`: `17`
  - `enemies_core_sheet_ai01`: `16`
  - `shrine_gate_prop_atlas_ai01`: `16`
  - 其它 duplicate 详情以脚本输出为准。

## Boundary

- 本轮是 target-count editor-ready rebuild，不是 final art polish。
- 多个动画、VFX、prop / equipment、icon 和 NinePatch 输出仍包含 duplicate 补位，需要后续重新生成更多候选或人工替换。
- TileSet、Promo、CG 和 Storyboard 中的自动网格裁切仍需人工重切和语义整理。
- UI / VFX / Spine parts 需要继续清稿、锚点、mask、九宫格边界、线宽和小尺寸读值复核。
