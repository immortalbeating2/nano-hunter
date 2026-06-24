# Runtime Source Safety and Confirmed P0 Binding Plan

Date: 2026-06-21

## Summary

针对用户提醒的多项目并行开发风险，本轮先补运行态来源安全审计，再只接入当前 Nano Hunter 会话确认的 P0 资产：`luna_jump_fall_sheet_ai01` 和 `stage16_seal_release_threshold_ai01`。

该计划不尝试把所有 review-required 资产升为正式资源；相反，它把已接入运行态的资产拆成 `source_confirmed`、`derivation_review_required` 和 `source_review_required`，避免其它项目 image gen 输出混入 Nano Hunter。

## Goals

- 新增运行态来源安全报告，交叉检查 P0 runtime replacement plan、source safety report 和 provenance records。
- 修复 selected source 候选索引记录，确保从 `candidate_04` 选帧时不会被误记为 `candidate_01`。
- 为 standalone 导出增加 `.source.json` sidecar，记录实际导出的 candidate index。
- 让 `luna_jump_fall_sheet_ai01` 确认从当前项目 `candidate_04` 派生。
- 让 `stage16_seal_release_threshold_ai01` 确认从当前项目 `candidate_02` 派生。
- 将这两个已确认来源资产接入正式场景的 preview 节点，并保留灰盒碰撞 / 玩法逻辑不变。

## Non-Goals

- 不把 16 个 runtime review-required 资产声明为最终安全来源。
- 不替换玩家控制器正式动画状态机。
- 不改变 Stage16 封印阈值房的碰撞、门控和流程逻辑。
- 不关闭 `license_terms`、`family_specific_polish` 或 `final_approval` gate。

## Key Changes

- 新增 `scripts/assets/audit_runtime_source_safety.py`。
- 新增 `docs/assets/runtime-source-safety-report.json` 与 `docs/assets/runtime-source-safety-report.md`。
- 更新 `scripts/assets/prepare_selected_sources.py`，保留真实 candidate index。
- 更新 `scripts/assets/export_standalone_candidates.py`，写出 `<asset>.source.json`。
- 更新 `scripts/assets/audit_imagegen_candidate_pool.py`，读取 standalone source sidecar。
- 更新 `scripts/assets/build_asset_runtime_map.py`，把 `stage16_seal_release_threshold_ai01` 的目标场景修正为 Stage16 阈值房。
- 更新 `scenes/player/player_placeholder.tscn`，新增隐藏 `LunaJumpFallAnimationPreview`。
- 更新 `scenes/rooms/stage16_seal_release_threshold_room.tscn`，新增 `SealReleaseThresholdArt` visual preview。
- 更新 Stage14 / Stage16 GUT 覆盖新增资源引用。

## Validation

```powershell
python scripts\assets\audit_imagegen_candidate_pool.py --write-report --strict
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_runtime_source_safety.py --write-report
python scripts\assets\audit_asset_package.py --write-report --strict
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
```

当前验证结果：

- Source safety：`103 candidates, 35 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`。
- Runtime source safety：`28 runtime assets, 16 review-required, 0 unsafe`。
- P0 runtime replacement：`28 entries, 0 planned replacements, 28 already referenced`。
- P0 target scene matrix：`14 scenes, 28 assets, 54 scene-asset references`。
- P0 scene replacement batches：`9 batches, 14 scenes, 28 assets, 54 scene-asset references`。
- Final art acceptance gates：`55 assets, 55 blocked assets, 0 final-ready assets`，其中 `runtime_replacement = 36 passed / 19 blocked`。
- Candidate review gallery：`74 candidates, 53 assets`。
- Stage14 GUT：`11/11 passed`，`135` asserts。
- Stage16 GUT：`13/13 passed`，`113` asserts。

## Risks / Follow-Up

- `runtime_source_safety` 仍有 16 个 review-required runtime assets；它们可以保留为临时 preview，但不能描述为最终来源确认。
- `luna_jump_fall_sheet_ai01` 当前由 `candidate_04` 拆出 `24` 个 selected frames，其中后 8 个是 duplicate 补位；后续仍需人工补帧和帧序清稿。
- `stage16_seal_release_threshold_ai01` 只是 visual preview，后续要按 Stage16 polish 做缩放、状态切分和交互读值复核。
- 下一步优先为 review-required runtime assets 逐项重新用当前 Nano Hunter 会话生成确认候选，或人工确认来源后重建 selected sources。
