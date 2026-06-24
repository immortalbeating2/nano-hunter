# ImageGen Supplemental Icon Candidates

## Summary

本计划记录 2026-06-21 追加的 Nano Hunter 图标候选补充，以及同日对 runtime standalone UI / VFX PNG 的 `.source.json` 派生记录补强。新增候选不替换当前 `assets/art/` 输出；`.source.json` 补强只记录当前 runtime PNG 来自哪个候选，不改变 HUD / DemoShell / Stage16 / Boss 房运行时引用语义。

## Scope

- `assets/source/ai_generated/batch_02/stage16_demo_menu_icons_ai01/candidates/stage16_demo_menu_icons_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_01/stage14_air_dash_icon_ai01/candidates/stage14_air_dash_icon_ai01_candidate_02.png`
- `assets/art/ui/stage14_air_dash_icon_ai01.source.json`
- `assets/art/ui/stage16_demo_menu_icons_ai01.source.json`
- `assets/art/vfx/stage16_talisman_relay_ai01.source.json`
- `assets/art/ui/stage16_alpha_demo_completion_ai01.source.json`
- `assets/art/ui/stage16_pause_panel_ui_ai01.source.json`
- `assets/art/ui/stage16_completion_panel_ui_ai01.source.json`
- `assets/art/ui/stage15_boss_hud_frame_ai01.source.json`
- `assets/art/ui/stage14_ability_status_hud_ai01.source.json`
- `scripts/assets/export_standalone_candidates.py`
- `scripts/assets/audit_imagegen_candidate_pool.py`
- `docs/assets/imagegen-candidate-pool-report.json`
- `docs/assets/asset-provenance-records.json`
- `docs/assets/imagegen-source-safety-report.json`
- `docs/assets/runtime-source-safety-report.json`
- `docs/assets/imagegen-candidate-review-gallery-manifest.json`
- `scenes/dev/imagegen_candidate_review_gallery.tscn`

## Non-Goals

- 不切换 `stage16_demo_menu_icons_ai01` 到 `candidate_02`。
- 不切换 `stage14_air_dash_icon_ai01` 到 `candidate_02`。
- 不重建 UI atlas、Icon atlas 或 HUD 运行时引用。
- 不把新增候选声明为 final-ready。

## Verification

```powershell
python scripts\assets\audit_imagegen_candidate_pool.py --write-report --strict
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/build_imagegen_candidate_review_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd
python scripts\assets\audit_asset_package.py --write-report --strict
python scripts\assets\audit_runtime_source_safety.py --write-report
git diff --check
```

## Current Result

- Candidate pool: `105` raw candidates, `547` selected sources, `67` unselected candidates, `47` review-required assets.
- Source safety: `35` project-session confirmed, `30` ledger review-required, `40` provenance review-required, `0` unsafe.
- Candidate review gallery: `67` candidates, `47` assets.
- Asset package audit: `55` queue items, `67` unselected candidates, `67` candidate review cards, `0` unsafe source candidates.
- Runtime source safety: `28` runtime assets, `16` review-required, `0` unsafe.

## Risks

- `stage14_air_dash_icon_ai01` 已重新从 `candidate_01` 导出并写出 `.source.json`，因此不再出现在 runtime source safety 的 review-required 列表中。
- 现有 9 个 standalone `.source.json` 已补齐 `project_key = nano-hunter` 与 `project_name = Nano Hunter`；`audit_imagegen_candidate_pool.py --strict` 后续会阻止缺项目键的 standalone 派生记录进入候选池。
- 其余 standalone runtime PNG 已能追踪到 `candidate_01`，但这些候选的 source safety 仍为 review-required，因此 runtime source safety 仍要求人工来源 / 视觉复核。
- `stage14_air_dash_icon_ai01_candidate_02` 和 `stage16_demo_menu_icons_ai01_candidate_02` 仍只供后续人工审图与小尺寸读值比较；若选中，需要再执行 standalone 导出、透明处理、Godot import、HUD 专项复核和文档更新。
