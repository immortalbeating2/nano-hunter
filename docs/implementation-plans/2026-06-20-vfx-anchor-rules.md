# VFX Anchor Rules Plan

## Summary

为已生成的 VFX 资产补第一版 anchor / blend / collision boundary 规则，让 Batch10 VFX atlas 和 standalone VFX PNG 从“有图和 SpriteFrames”推进到“有可复核的接入规则”。该层只服务 Godot 编辑器与后续运行时接入规划，不直接替换游戏内 VFX 引用。

## Scope

- 覆盖 VFX assets：
  - `stage14_air_dash_trail_ai01`
  - `stage15_boss_attack_warning_ai01`
  - `vfx_seal_magic_atlas_ai01`
  - `vfx_combat_atlas_ai01`
  - `stage16_talisman_relay_ai01`
  - `stage16_corruption_purge_ai01`
- 新增：
  - `scripts/assets/build_vfx_rules.py`
  - `scripts/assets/audit_vfx_rules.py`
  - `assets/art/vfx/vfx_rules/*.vfx_rules.json`
  - `assets/art/vfx/vfx_rules/vfx_rules.index.json`

## Key Changes

- 为 VFX atlas 的 `64` 帧、Stage16 talisman relay 的 `3x2` 分格和其余 standalone VFX 的 `3` 张纹理生成共 `73` 条规则。
- 每条规则记录：
  - `anchor_px`
  - `anchor_normalized`
  - `spawn_offset_px`
  - `recommended_blend`
  - `role`
  - `gameplay_collision=false`
  - `damage_source=false`
- 综合资产包审计纳入 VFX rules。
- Art readiness 将 VFX blocker 从 `anchor_cleanup` / `mask_and_blend_review` 推进为 `anchor_manual_review` / `mask_and_blend_manual_review`。

## Non-Goals

- 不创建正式 hitbox / hurtbox / damage Area。
- 不替换运行时 VFX 引用。
- 不确认最终动画时序、透明边缘、混合模式、缩放和 gameplay readability。
- 不把 VFX 当作碰撞或伤害来源。

## Validation

```powershell
python -m py_compile scripts\assets\build_vfx_rules.py scripts\assets\audit_vfx_rules.py scripts\assets\audit_art_readiness.py scripts\assets\audit_asset_package.py
python scripts\assets\build_vfx_rules.py --dry-run
python scripts\assets\build_vfx_rules.py
python scripts\assets\audit_vfx_rules.py --strict
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

## Exit Criteria

- `audit_vfx_rules.py --strict` 通过。
- 综合资产包审计记录 `73 VFX rules`，并从 `vfx_rules.index.json` 动态读取期望值。
- Readiness report 对 VFX assets 记录 `vfx_rules`。
- 所有 VFX rules 均显式 `gameplay_collision=false` 和 `damage_source=false`。

## Boundary

当前 VFX rules 是 `placeholder_ready` 接入规则候选。它证明 VFX 已有锚点、blend 和禁用碰撞/伤害的 first-pass 约束，不证明最终 mask 清稿、动画时序、实际运行时 VFX 节点、伤害判定或玩法读值完成。
