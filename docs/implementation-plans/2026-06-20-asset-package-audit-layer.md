# Asset Package Audit Layer

Date: 2026-06-20

## Summary

新增一个综合资产包审计入口，把 image gen queue、atlas manifest、Godot editor resources 和 Spine-style exports 的关键结构性事实汇总到同一份报告。该步骤用于后续判断资产包当前状态，不替代人工清稿、运行时接入、授权确认或玩法读值复核。

## Goals

- 审计 `docs/assets/image-gen-prompt-queue.json` 的 `55` 个资产条目。
- 确认每个 queue 条目都有原始候选 PNG 和 `assets/art` 输出。
- 审计 `docs/assets/asset-atlas-build-manifest.json` 的 `26` 个 atlas-linked 输出。
- 汇总 selected source 数量、SpriteFrames、AtlasTexture、TileSet、StyleBoxTexture 和 Spine-style cutout exports。
- 输出结构化报告 `docs/assets/asset-package-audit-report.json`。
- 把 `docs/assets/imagegen-asset-gallery-manifest.json` 与 `scenes/dev/imagegen_asset_gallery.tscn` 纳入综合审计。

## Non-Goals

- 不判断最终美术质量。
- 不判断运行时场景 / HUD / 音频 / VFX 是否已经替换。
- 不判断授权可商用状态。
- 不判断 TileSet collision、NinePatch 拉伸、VFX 锚点、Spine pivot 或剧情分镜语义是否正确。

## Key Changes

- 新增 `scripts/assets/audit_asset_package.py`。
- 新增 `docs/assets/asset-package-audit-report.json`。
- 报告覆盖：
  - `55` queue items
  - `71` candidate PNGs
  - `26` atlas-linked outputs
  - `236` selected frames
  - `122` selected items
  - `96` selected tiles
  - `48` selected parts
  - `36` selected panels
  - `302` AtlasTexture resources
  - `2` TileSet resources
  - `8` StyleBoxTexture resources
  - `2` Spine-style cutout exports / `48` parts
  - ImageGen Asset Gallery scene / manifest

## Commands

```powershell
python scripts\assets\audit_asset_package.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
```

Recommended full validation after this step:

```powershell
python -m py_compile scripts\assets\audit_asset_package.py
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\audit_asset_target_coverage.py --strict
python scripts\assets\audit_editor_atlas_textures.py --strict
python scripts\assets\audit_spine_cutout_manifests.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `audit_asset_package.py --strict` 通过。
- `docs/assets/asset-package-audit-report.json` 中 `ok` 为 `true`，`errors` 为空。
- 报告中的 `gallery` 段能确认 Gallery scene 和 manifest 存在，关键计数匹配。
- 文档明确记录当前报告是结构审计，不证明最终美术、授权或运行时集成。

## Risks

- 综合报告会让资产包状态更清晰，但容易被误读为“最终完成”。必须保留 `placeholder_ready` 边界。
- 后续新增资产批次时，需要同步扩展 queue、manifest 和综合审计期望值。
