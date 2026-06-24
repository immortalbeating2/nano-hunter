# Final Art Acceptance Gates Implementation Plan

## Summary

把 `55` 个结构可用 image gen 资产从“复核队列”进一步拆成机器可审计的最终美术验收门槛，明确每个资产距离 `final_ready` 还缺哪些 gate。

本计划不批准任何资产为最终美术，不修改运行时引用，不新增或替换 PNG。

## Scope

- 新增 `scripts/assets/build_final_art_acceptance_gates.py`
- 新增 `scripts/assets/audit_final_art_acceptance_gates.py`
- 生成 `docs/assets/final-art-acceptance-gates.json`
- 生成 `docs/assets/final-art-acceptance-gates.md`
- 扩展 `scripts/assets/audit_asset_package.py`
- 更新资产矩阵、status、timeline 和当日日志

## Gates

- `source_traceability`：来源、prompt、candidate hash、output hash 可追溯。
- `license_terms`：商业使用条款已人工复核。
- `godot_structural_resource`：输出 PNG / Godot 资源在结构层可用。
- `editor_review_card`：Godot 编辑器复核卡存在并可加载。
- `runtime_replacement`：目标场景 / HUD / Boss / VFX / TileSet 已替换并验证。
- `family_specific_polish`：动画帧序、UI 布局、TileSet 碰撞、VFX anchor、宣传图安全区等专项清稿已完成。
- `final_approval`：最终美术批准。

## Verification

```powershell
python -m py_compile scripts\assets\build_final_art_acceptance_gates.py scripts\assets\audit_final_art_acceptance_gates.py scripts\assets\audit_asset_package.py
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Acceptance gates report 覆盖全部 `55` 个资产。
- 每个资产都有 `7` 个 gate。
- 报告明确 `55` 个资产仍 blocked、`0` 个 final-ready。
- 综合资产包审计纳入 `55 final-art acceptance-gated assets`。

## Risks

- Gate report 只证明缺口被明确化，不会自动完成授权、清稿或运行时替换。
- 当前 `source_traceability`、`godot_structural_resource`、`editor_review_card` 通过，不应被解释成最终美术已完成。
