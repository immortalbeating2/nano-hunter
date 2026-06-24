# P0 Target Scene Replacement Matrix Implementation Plan

## Summary

把 `docs/assets/p0-runtime-replacement-plan.json` 中的 P0 runtime entries 按目标场景聚合，形成后续正式替换时的场景级执行矩阵。

本计划不直接修改 `.tscn` 引用，不关闭 `runtime_replacement` gate，不批准最终美术。

## Scope

- 新增 `scripts/assets/build_p0_target_scene_replacement_matrix.py`
- 新增 `scripts/assets/audit_p0_target_scene_replacement_matrix.py`
- 生成 `docs/assets/p0-target-scene-replacement-matrix.json`
- 生成 `docs/assets/p0-target-scene-replacement-matrix.md`
- 扩展 `scripts/assets/audit_asset_package.py`
- 更新资产矩阵、status、timeline 和当日日志

## Matrix Rules

- 按目标场景聚合 P0 runtime replacement entries。
- 每个场景必须记录资产列表、资源类型计数、风险计数、场景是否存在和建议验证命令。
- 高影响场景由 asset count 标记，供后续优先拆分 Stage / HUD / room polish 任务。
- 该矩阵只记录计划，不写入正式场景引用。

## Verification

```powershell
python -m py_compile scripts\assets\build_p0_target_scene_replacement_matrix.py scripts\assets\audit_p0_target_scene_replacement_matrix.py scripts\assets\audit_asset_package.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\audit_p0_target_scene_replacement_matrix.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Matrix 覆盖当前 `28` 个 P0 runtime assets。
- Matrix 记录 `13` 个目标场景和 `55` 个 scene-asset references。
- 缺失目标场景数为 `0`。
- 综合资产包审计纳入 `13 P0 target scenes`。

## Risks

- 目标场景矩阵不等于替换完成；正式替换仍需逐场景修改、导入、GUT 和人工试玩。
- 场景中存在动画、TileSet、UI 和 VFX 的 family-specific polish blockers，替换顺序必须服从这些 blocker。
