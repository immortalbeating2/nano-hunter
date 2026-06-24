# Asset Family Coverage Report

## Summary

本计划新增完整美术资产族覆盖报告，把用户目标中的资产类别和 Godot 可用格式映射到当前仓库真实产物。该报告证明当前已经达到 `structural pass`，但不证明最终清稿、授权、运行时表现或 `final-ready`。

## Scope

- 新增 `scripts/assets/build_asset_family_coverage.py`。
- 新增 `docs/assets/asset-family-coverage-report.json`。
- 新增 `docs/assets/asset-family-coverage-report.md`。
- 更新 `scripts/assets/audit_asset_package.py`，让综合资产包审计校验覆盖报告。

## Coverage Requirements

- 资产族：角色类、关卡地图 / 场景类、UI / 界面类、图标类、道具与装备类、特效类、动画帧图 / 序列帧、贴图类、宣传 / 运营 / LOGO / CG、叙事 / 剧情 / 分镜。
- Godot 格式：Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集、九宫格图片 / StyleBox。

## Verification

```powershell
python -m py_compile scripts\assets\build_asset_family_coverage.py scripts\assets\audit_asset_package.py
python scripts\assets\build_asset_family_coverage.py
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Current Result

- Asset family coverage：`10/10` families。
- Godot format coverage：`7/7` formats。
- Structural-ready assets：`55`。
- Final-ready assets：`0`。
- Asset package audit：通过，并记录 `10/10 asset families covered` 与 `7/7 Godot formats covered`。

## Risks

- 本报告只证明类别和格式已覆盖到结构层，不代表 `final_ready`。
- 下一步仍需继续处理来源确认、授权记录、人工清稿、运行时读值、动画帧序、TileSet 碰撞、VFX anchor / mask 和 NinePatch 边界。
