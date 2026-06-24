# HUD Core UI Atlas Source Confirmation

## Summary

本计划记录 `hud_core_ui_atlas_ai01` 的来源确认重建。该资产此前已被 `scenes/ui/tutorial_hud.tscn` 运行时引用，但 provenance 中没有记录 selected source 实际来自哪个 candidate，因此 runtime source safety 将它标记为 `project_candidate_exists_output_derivation_unverified`。

本轮只使用 `project_session_confirmed` 的 `hud_core_ui_atlas_ai01_candidate_01.png` 重建 selected items 与 atlas，不使用 `candidate_02` / `candidate_03` 这两个 review-required 候选。

## Scope

- `assets/source/ai_generated/batch_08/hud_core_ui_atlas_ai01/selected_items/`
- `assets/art/ui/atlases/hud_core_ui_atlas_ai01.png`
- `assets/art/ui/atlases/hud_core_ui_atlas_ai01.regions.json`
- `assets/art/editor_resources/`
- `docs/assets/imagegen-candidate-pool-report.json`
- `docs/assets/asset-provenance-records.json`
- `docs/assets/imagegen-source-safety-report.json`
- `docs/assets/runtime-source-safety-report.json`
- `docs/assets/runtime-source-safety-report.md`
- `docs/assets/asset-package-audit-report.json`

## Non-Goals

- 不切换到 `hud_core_ui_atlas_ai01_candidate_02` 或 `candidate_03`。
- 不改变 `tutorial_hud.tscn` 的节点结构或 HUD 交互逻辑。
- 不声明 UI 图集已经完成清稿、最终读值、授权或 `final_ready`。

## Verification

```powershell
python scripts\assets\prepare_selected_sources.py --only hud_core_ui_atlas_ai01 --target target --candidate-index 1 --dry-run
python scripts\assets\prepare_selected_sources.py --only hud_core_ui_atlas_ai01 --target target --candidate-index 1 --overwrite
python scripts\assets\build_asset_atlases.py --only hud_core_ui_atlas_ai01 --strict
python scripts\assets\audit_asset_target_coverage.py --strict
python scripts\assets\build_editor_atlas_textures.py
python scripts\assets\audit_editor_atlas_textures.py --strict
python scripts\assets\audit_imagegen_candidate_pool.py --write-report --strict
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_runtime_source_safety.py --write-report
godot --headless --path . --import
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Current Result

- `prepare_selected_sources.py`：`hud_core_ui_atlas_ai01: prepared 16/16 via chroma-components from hud_core_ui_atlas_ai01_candidate_01.png`。
- `build_asset_atlases.py`：重新写出 `hud_core_ui_atlas_ai01.png` 与 `.regions.json`。
- Editor AtlasTextures：`302` 个资源审计通过。
- Provenance：`hud_core_ui_atlas_ai01.selected_candidate_indices = [1]`，`unselected_candidate_indices = [2, 3]`。
- Runtime source safety：从 `16` 个 review-required runtime assets 降到 `15` 个，`0` unsafe。
- Asset package audit：通过，`67` 个 unselected candidates、`67` 张 candidate review cards、`0` unsafe source candidates。

## Risks

- `candidate_02` / `candidate_03` 仍保留在评审池，不能自动视为可替换源。
- 当前 HUD core 只完成来源确认和 Godot 结构可用，不代表 UI 小尺寸读值、NinePatch、主题套用或最终清稿完成。
