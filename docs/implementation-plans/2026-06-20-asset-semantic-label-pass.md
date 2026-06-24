# ImageGen Asset Semantic Label Pass

Date: 2026-06-20

## Summary

本计划为已生成的 image gen 图集和 standalone 图标组补第一版语义标签，解决自动切片只有 `auto_001`、`auto_002` 之类编号、后续接入时难以判断用途的问题。

## Scope

- 新增 `scripts/assets/build_asset_semantics.py`。
- 新增 `scripts/assets/audit_asset_semantics.py`。
- 新增 `docs/assets/asset-semantics-index.json`。
- 为 `26` 个 atlas-linked outputs 生成 `.semantics.json`。
- 为 standalone 图标组 `stage16_demo_menu_icons_ai01` 新增 `assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json`。
- 扩展 `scripts/assets/audit_art_readiness.py`，把 semantic naming blocker 降级为 `semantic_labels_manual_review`。
- 扩展 `scripts/assets/audit_asset_package.py`，把语义标签覆盖纳入综合资产包审计。

## Outputs

- Atlas / SpriteFrames / TileSet / UI / VFX / Spine / Promo / Storyboard semantics：`26` assets / `538` entries。
- Standalone menu icon semantics：`1` asset / `6` entries。
- 综合语义标签：`544` entries。

## Boundary

- 这些是 first-pass machine semantic labels。
- 语义标签解决“自动编号不可读”的问题，但不代表人工确认完成。
- 运行时接入前仍需检查图像内容是否真的匹配语义名、是否需要裁切、是否满足小尺寸读值、动画帧序、TileSet collision、VFX anchor、Spine pivot 和 UI layout。

## Commands

```powershell
python scripts/assets/build_asset_semantics.py
python scripts/assets/audit_asset_semantics.py --strict
python scripts/assets/audit_art_readiness.py --strict --write-report
python scripts/assets/audit_asset_package.py --strict --write-report
```

## Current Result

2026-06-20 当前结果：

- `Asset semantics OK: 26 assets, 538/538 semantic entries.`
- 综合资产包审计输出 `544 semantic labels`。
- Readiness blocker 中 `semantic_icon_naming`、`semantic_item_naming`、`semantic_part_naming`、`semantic_tile_naming` 已被 atlas-linked / standalone semantics 覆盖并转为 `semantic_labels_manual_review`。
- `final_ready` 仍为 `0/55`，因为人工确认、授权记录和运行时替换尚未完成。

## Next Steps

- 人工打开 Gallery / Integration Showcase 逐项确认语义标签是否匹配真实图像内容。
- 将确认后的语义名用于 TileSet collision 配置、UI region 裁切、VFX anchor、Spine pivot 和运行时引用替换。
