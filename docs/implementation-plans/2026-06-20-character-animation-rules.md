# Character Animation Rules Plan

## Summary

为 Luna、Seal Guardian 和 core enemies 的 Sprite Sheet 补 first-pass animation rules，让角色 / 敌人动画从“有 PNG、metadata 和 SpriteFrames”推进到“有可审计的 clip、fps、loop、pivot、脚底基线和 frame duration 候选”。该层服务后续 Godot 运行时替换和人工复核，不直接替换当前玩家、Boss 或敌人动画引用。

## Scope

- 覆盖 `8` 个角色 / 敌人 Sprite Sheet：
  - `luna_run_sheet_ai01`
  - `luna_air_dash_sheet_ai01`
  - `luna_attack_01_sheet_ai01`
  - `luna_idle_sheet_ai01`
  - `luna_jump_fall_sheet_ai01`
  - `luna_hit_death_sheet_ai01`
  - `seal_guardian_boss_sheet_ai01`
  - `enemies_core_sheet_ai01`
- 新增：
  - `scripts/assets/build_animation_rules.py`
  - `scripts/assets/audit_animation_rules.py`
  - `assets/art/characters/animation_rules/*.animation_rules.json`
  - `assets/art/characters/animation_rules/animation_rules.index.json`

## Key Changes

- 生成 `172` 条 animation frame rules。
- 每条规则记录：
  - `phase`
  - `pivot_px`
  - `pivot_normalized`
  - `foot_baseline_y`
  - `frame_duration_sec`
- 每个 asset 记录：
  - `animation_name`
  - `speed_fps`
  - `loop`
  - `default_pivot_px`
  - `default_foot_baseline_y`
- 综合资产包审计纳入 animation rules。
- Art readiness 将角色 / 敌人动画 blocker 从 `frame_order_review`、`foot_baseline_and_anchor_cleanup`、`animation_timing_review` 推进为对应 manual review blocker。

## Non-Goals

- 不替换当前玩家、敌人或 Boss 运行时动画引用。
- 不确认最终帧序、角色一致性、脚底基线、碰撞盒或动画速度。
- 不生成正式 AnimationPlayer / AnimationTree 状态机。
- 不声明任何角色动画为 final-ready。

## Validation

```powershell
python -m py_compile scripts\assets\build_animation_rules.py scripts\assets\audit_animation_rules.py scripts\assets\audit_art_readiness.py scripts\assets\audit_asset_package.py
python scripts\assets\build_animation_rules.py --dry-run
python scripts\assets\build_animation_rules.py
python scripts\assets\audit_animation_rules.py --strict
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

## Exit Criteria

- `audit_animation_rules.py --strict` 通过。
- 综合资产包审计记录 `172 animation rules`。
- Readiness report 对 `8` 个角色 / 敌人 Sprite Sheet 记录 `animation_rules`。
- `final_ready_count` 仍保持 `0`，不误报最终完成。

## Boundary

当前 animation rules 是 `placeholder_ready` 接入规则候选。它证明角色 / 敌人 Sprite Sheet 已有 clip、fps、loop、pivot 和脚底基线的 first-pass 规则，不证明最终帧序、碰撞读值、角色一致性、动画时序或运行时替换完成。
