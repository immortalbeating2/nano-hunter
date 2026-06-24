# Editor TileSet Collision Rule Pass

## Summary

为 Batch07 两套 image gen TileSet 候选补一层保守 Godot 编辑器规则：在 `.tileset.tres` 中加入 physics layer、terrain set 和第一版碰撞候选，并输出 `.tileset_rules.json` sidecar 供审计和人工复核。

本计划不把 TileSet 推进为最终运行时资产；它只把地图场景类资产从 texture / atlas source 骨架推进到可在 Godot 中检查碰撞候选和危险边界的状态。

## Scope

- `miasma_marsh_tileset_ai01`
- `shrine_trial_tileset_ai01`
- `scripts/dev/build_editor_tilesets.gd`
- `scripts/dev/audit_editor_tilesets.gd`
- `scripts/assets/audit_asset_package.py`
- `scripts/assets/audit_art_readiness.py`
- 相关资产文档和进度留痕

## Implementation

1. 读取 `assets/art/tilesets/<asset_id>.semantics.json`。
2. 给每个 TileSet 添加 `1` 个 physics layer 和 `1` 个 terrain set。
3. 按语义分类生成规则：
   - `ground` / `wall` / `transition`：完整 cell 碰撞候选。
   - `platform_edge`：顶部 one-way platform 碰撞候选。
   - `hazard`：只记录危险视觉区，不自动加物理碰撞。
   - `decor` / `ornament`：只做装饰视觉 tile，不加物理碰撞。
4. 输出 `assets/art/tilesets/editor_tilesets/<asset_id>.tileset_rules.json`。
5. 扩展 Godot 审计，检查 `.tileset.tres`、physics layer、terrain set、规则 JSON、碰撞多边形和 hazard visual-only 分类。
6. 扩展综合资产包审计和 art readiness 报告。

## Verification

```powershell
python -m py_compile scripts\assets\audit_art_readiness.py scripts\assets\audit_asset_package.py
godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Result

- TileSet resources: `2`
- Rule sidecars: `2`
- Total rule entries: `96`
- Collision-ready tiles: `64`
- Hazard visual-only tiles: `8`
- Art readiness: `55/55` structural ready, `0/55` final ready

## Boundary

- 当前碰撞只是 conservative candidate，不是最终碰撞体。
- miasma hazard 只记录为 visual-only；正式伤害区域必须在运行时场景中单独 author。
- 仍未配置 autotile、navigation、occlusion、正式 TileMap / TileMapLayer 引用或 gameplay readability 验证。
