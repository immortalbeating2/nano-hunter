# P0 Runtime Replacement Plan Implementation Plan

## Summary

为 priority `P0` 的 runtime map 条目生成运行时替换执行计划，明确每个资产应替换到哪些目标场景、使用哪种 Godot 资源形态、当前是否已经被目标场景引用，以及替换后需要跑哪些验证。

本计划不直接修改运行时场景引用，不关闭 `runtime_replacement` gate，也不批准最终美术。

## Scope

- 新增 `scripts/assets/build_p0_runtime_replacement_plan.py`
- 新增 `scripts/assets/audit_p0_runtime_replacement_plan.py`
- 生成 `docs/assets/p0-runtime-replacement-plan.json`
- 生成 `docs/assets/p0-runtime-replacement-plan.md`
- 扩展 `scripts/assets/audit_asset_package.py`
- 更新资产矩阵、status、timeline 和当日日志

## Rules

- 只覆盖 `docs/assets/asset-runtime-integration-map.json` 中 priority 为 `P0` 的 runtime entries。
- 每个条目必须有 output、runtime catalog resource、目标场景、替换模式和验证命令。
- 脚本必须扫描目标场景是否已经引用该资源，避免误报 runtime replacement 状态。
- 当前报告只做计划与审计，不改 `.tscn` 引用。

## Verification

```powershell
python -m py_compile scripts\assets\build_p0_runtime_replacement_plan.py scripts\assets\audit_p0_runtime_replacement_plan.py scripts\assets\audit_asset_package.py
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\audit_p0_runtime_replacement_plan.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- P0 runtime replacement plan 覆盖当前 `28` 个 P0 runtime entries。
- 所有条目资源存在、目标场景存在、替换模式存在。
- 综合资产包审计纳入 `28 P0 runtime replacement-plan entries`。

## Risks

- 计划存在不等于替换完成；正式替换仍需按目标 Stage / HUD / room 分批修改场景并运行对应 GUT。
- 动画、TileSet、UI 和 VFX 仍受 family-specific polish blockers 约束，不应直接替换进正式玩法节点。
