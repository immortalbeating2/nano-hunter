# ImageGen Duplicate Reduction Pass 01

Date: 2026-06-20

## Summary

本计划处理 target-count 图集重建后的高 duplicate 补位资产。目标不是接入最终美术，而是把本轮内置 `image_gen` 默认落盘的补充 PNG 复制到项目候选目录，并让 selected source 准备脚本从多个 `candidate_XX` 合并抽取，降低重复帧 / 重复小图数量。

## Scope

本轮只处理 duplicate 数量较高、且适合继续用 image gen 补候选的 5 个 atlas-linked outputs：

- `luna_run_sheet_ai01`
- `vfx_combat_atlas_ai01`
- `enemies_core_sheet_ai01`
- `shrine_gate_prop_atlas_ai01`
- `equipment_pickup_atlas_ai01`

## Source Mapping

默认 image gen 目录：

```text
C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613
```

本轮复制映射：

- `ig_089a810e5fa4f084016a35699c7240819bb4cc85e8ec183fa7.png` -> `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_02.png`
- `ig_089a810e5fa4f084016a356bee5750819b9b1095e70ed0b5fc.png` -> `assets/source/ai_generated/batch_10/vfx_combat_atlas_ai01/candidates/vfx_combat_atlas_ai01_candidate_02.png`
- `ig_089a810e5fa4f084016a356c29253c819b8c14fed4d0a32500.png` -> `assets/source/ai_generated/batch_06/enemies_core_sheet_ai01/candidates/enemies_core_sheet_ai01_candidate_02.png`
- `ig_089a810e5fa4f084016a356c67be6c819b8098bdb2c2dd77fd.png` -> `assets/source/ai_generated/batch_09/shrine_gate_prop_atlas_ai01/candidates/shrine_gate_prop_atlas_ai01_candidate_02.png`
- `ig_089a810e5fa4f084016a356ca62acc819b9e033db86ee3937b.png` -> `assets/source/ai_generated/batch_09/equipment_pickup_atlas_ai01/candidates/equipment_pickup_atlas_ai01_candidate_02.png`
- `ig_089a810e5fa4f084016a356cd4b878819b83561c2b41aa47e6.png` -> `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_03.png`

## Implementation Steps

1. 保留默认 image gen 目录原图，只复制到项目候选目录。
2. 更新 `scripts/assets/prepare_selected_sources.py`，让 component-based 输出按 `candidate_01`、`candidate_02`、`candidate_03` 顺序合并抽取。
3. 对本轮 5 个目标执行：

```powershell
python scripts\assets\prepare_selected_sources.py --target target --only <asset_id> --overwrite
python scripts\assets\build_asset_atlases.py --only <asset_id>
```

4. 运行 `python scripts\assets\audit_asset_target_coverage.py --strict` 记录 duplicate 变化。
5. 运行 queue、atlas dry-run、Python 编译、Godot import 与 `git diff --check` 验证。
6. 更新资产文档、status、timeline 和当日日志。

## Duplicate Result

| Asset ID | Before | After |
| --- | ---: | ---: |
| `luna_run_sheet_ai01` | 12 | 0 |
| `vfx_combat_atlas_ai01` | 17 | 1 |
| `enemies_core_sheet_ai01` | 16 | 0 |
| `shrine_gate_prop_atlas_ai01` | 16 | 0 |
| `equipment_pickup_atlas_ai01` | 13 | 0 |

## Exit Criteria

- 本轮补充 candidate 已复制到项目候选目录。
- 相关 selected source 已从多个 candidates 合并抽取。
- 相关 `assets/art` sheet / atlas 已重建。
- 严格审计通过，并记录 duplicate 变化。
- 仍未接入运行时引用，状态保持 `placeholder_ready`。
