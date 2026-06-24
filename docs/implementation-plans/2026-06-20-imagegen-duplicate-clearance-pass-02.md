# ImageGen Duplicate Clearance Pass 02

Date: 2026-06-20

## Summary

本计划继续处理 duplicate reduction pass 01 后剩余的 atlas-linked duplicate 补位。目标是让 `docs/assets/asset-atlas-build-manifest.json` 中全部 `26` 个 atlas-linked outputs 在 target-count 审计中达到 `duplicates=0`，同时保持当前状态为 `placeholder_ready`，不替换运行时引用。

## Scope

本轮分两组补齐：

第一组高 duplicate：

- `seal_guardian_boss_sheet_ai01`
- `luna_jump_fall_sheet_ai01`
- `luna_hit_death_sheet_ai01`
- `icon_sheet_core_ai01`
- `vfx_seal_magic_atlas_ai01`
- `luna_air_dash_sheet_ai01`

第二组最后剩余 duplicate：

- `luna_idle_sheet_ai01`
- `luna_attack_01_sheet_ai01`
- `menu_ninepatch_ui_ai01`
- `vfx_combat_atlas_ai01`

## Source Mapping

默认 image gen 目录：

```text
C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613
```

第一组复制映射：

- `ig_0af4cabc559d1707016a357020ec74819bb828d57d870fdc45.png` -> `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/candidates/seal_guardian_boss_sheet_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a35705a72e4819b8f8749a7d1e5f014.png` -> `assets/source/ai_generated/batch_06/luna_jump_fall_sheet_ai01/candidates/luna_jump_fall_sheet_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a3570a48554819bb4157a14d5f40bce.png` -> `assets/source/ai_generated/batch_06/luna_hit_death_sheet_ai01/candidates/luna_hit_death_sheet_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a3570e7ab9c819b9cc4103cd732993d.png` -> `assets/source/ai_generated/batch_08/icon_sheet_core_ai01/candidates/icon_sheet_core_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a35712043ac819ba58b4a6177d86ee2.png` -> `assets/source/ai_generated/batch_10/vfx_seal_magic_atlas_ai01/candidates/vfx_seal_magic_atlas_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a35716adfbc819b8b57e755bdfd0166.png` -> `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/candidates/luna_air_dash_sheet_ai01_candidate_02.png`

第二组复制映射：

- `ig_0af4cabc559d1707016a3574b510e4819b98842766b5021a30.png` -> `assets/source/ai_generated/batch_06/luna_idle_sheet_ai01/candidates/luna_idle_sheet_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a3574e3ee0c819bbc6f28ee2860a565.png` -> `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/candidates/luna_attack_01_sheet_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a3575175f00819bbe4e83e30a056afd.png` -> `assets/source/ai_generated/batch_08/menu_ninepatch_ui_ai01/candidates/menu_ninepatch_ui_ai01_candidate_02.png`
- `ig_0af4cabc559d1707016a357553cecc819b967028b9a2906afb.png` -> `assets/source/ai_generated/batch_10/vfx_combat_atlas_ai01/candidates/vfx_combat_atlas_ai01_candidate_03.png`

## Commands

对每个目标执行：

```powershell
python scripts\assets\prepare_selected_sources.py --target target --only <asset_id> --overwrite
python scripts\assets\build_asset_atlases.py --only <asset_id>
```

最终验证：

```powershell
python -m py_compile scripts\assets\prepare_selected_sources.py scripts\assets\export_standalone_candidates.py scripts\assets\build_asset_atlases.py scripts\assets\import_imagegen_outputs.py scripts\assets\validate_asset_production_queue.py scripts\assets\export_imagegen_batch_plan.py scripts\assets\audit_asset_target_coverage.py
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
git diff --check
```

## Duplicate Result

| Asset ID | Before Pass 02 | After Pass 02 |
| --- | ---: | ---: |
| `seal_guardian_boss_sheet_ai01` | 8 | 0 |
| `luna_jump_fall_sheet_ai01` | 8 | 0 |
| `luna_hit_death_sheet_ai01` | 8 | 0 |
| `icon_sheet_core_ai01` | 8 | 0 |
| `vfx_seal_magic_atlas_ai01` | 6 | 0 |
| `luna_air_dash_sheet_ai01` | 4 | 0 |
| `luna_idle_sheet_ai01` | 4 | 0 |
| `luna_attack_01_sheet_ai01` | 2 | 0 |
| `menu_ninepatch_ui_ai01` | 2 | 0 |
| `vfx_combat_atlas_ai01` | 1 | 0 |

Final audit result: `26/26` atlas-linked outputs report `duplicates=0`.

## Exit Criteria

- 全部补充 candidates 已复制到项目候选目录。
- 相关 selected sources 已从多个 `candidate_XX` 合并抽取。
- 相关 sheet / atlas / NinePatch sheet 已重建。
- `audit_asset_target_coverage.py --strict` 证明全部 atlas-linked outputs 均为 `duplicates=0`。
- Godot import 通过。
- 状态保持 `placeholder_ready`，仍不声称最终清稿或运行时接入完成。
