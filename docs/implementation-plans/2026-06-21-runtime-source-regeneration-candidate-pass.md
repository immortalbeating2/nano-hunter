# Runtime Source Regeneration Candidate Pass / 运行时来源重生候选落盘

## Summary

本计划执行 `runtime-source-review-queue` 中 15 个仍需复核的运行时美术资产重生成：其中 7 个 `manual_source_review_or_regenerate` 为必须重生候选，8 个 `manual_compare_selected_mix` 为建议统一风格重生候选。本轮只追加 raw candidates，不覆盖 `assets/art/`，也不替换当前运行时引用。

## Scope

- 追加 15 张 Nano Hunter 专属 image_gen PNG 到 `assets/source/ai_generated/.../candidates/`。
- 统一提示词方向：南北朝东方奇幻、镇妖卫、佛门符印、山海经妖物、水墨 / 工笔色系、Ori-like glow。
- 所有 UI / VFX / sprite sheet 均使用 `#00ff00` chroma-key 背景，等待后续清稿 / 切图 / alpha 处理。
- 不自动重建 selected sources、atlas、SpriteFrames、StyleBox、Theme 或正式 runtime 输出。

## Candidate Outputs

- `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_05.png`
- `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/candidates/luna_air_dash_sheet_ai01_candidate_05.png`
- `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/candidates/luna_attack_01_sheet_ai01_candidate_05.png`
- `assets/source/ai_generated/batch_06/luna_idle_sheet_ai01/candidates/luna_idle_sheet_ai01_candidate_04.png`
- `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/candidates/seal_guardian_boss_sheet_ai01_candidate_03.png`
- `assets/source/ai_generated/batch_08/icon_sheet_core_ai01/candidates/icon_sheet_core_ai01_candidate_05.png`
- `assets/source/ai_generated/batch_08/menu_ninepatch_ui_ai01/candidates/menu_ninepatch_ui_ai01_candidate_03.png`
- `assets/source/ai_generated/batch_10/vfx_seal_magic_atlas_ai01/candidates/vfx_seal_magic_atlas_ai01_candidate_04.png`
- `assets/source/ai_generated/batch_02/stage16_demo_menu_icons_ai01/candidates/stage16_demo_menu_icons_ai01_candidate_03.png`
- `assets/source/ai_generated/batch_02/stage16_talisman_relay_ai01/candidates/stage16_talisman_relay_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_02/stage16_alpha_demo_completion_ai01/candidates/stage16_alpha_demo_completion_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_08/stage16_pause_panel_ui_ai01/candidates/stage16_pause_panel_ui_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_08/stage16_completion_panel_ui_ai01/candidates/stage16_completion_panel_ui_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_08/stage15_boss_hud_frame_ai01/candidates/stage15_boss_hud_frame_ai01_candidate_02.png`
- `assets/source/ai_generated/batch_08/stage14_ability_status_hud_ai01/candidates/stage14_ability_status_hud_ai01_candidate_02.png`

## Process Notes

- 前 8 个建议重生候选使用内置 `image_gen` 生成后立即导入；后续发现全局 `generated_images` 同时存在其它会话 PNG，因此 7 个必须重生候选改为显式读取当前会话目录 `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`。
- `stage16_demo_menu_icons_ai01_candidate_03.png` 首次导入时曾被全局最新图误导入到错误会话来源；该文件已在同轮删除，并用当前会话目录中的正确 PNG 重新导入同一路径。
- `audit_runtime_source_regeneration_landing.py` 增加 `--accept-latest-existing`，用于处理导入后 packet 被重新生成、目标路径推进到下一 slot 的审计场景；默认行为不变。

## Validation

```powershell
python scripts\assets\audit_imagegen_candidate_pool.py --write-report --strict
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_runtime_source_safety.py --write-report
python scripts\assets\build_runtime_source_review_queue.py
python scripts\assets\build_runtime_source_regeneration_packet.py
python scripts\assets\audit_runtime_source_regeneration_landing.py --write-report --strict --accept-latest-existing
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/build_imagegen_candidate_review_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd
python scripts\assets\audit_project_asset_isolation.py --write-report --strict
python scripts\assets\audit_asset_package.py --write-report --strict
git diff --check
```

## Exit Criteria

- 15 张新候选 PNG 已落到对应 `assets/source/ai_generated/.../candidates/`。
- Runtime regeneration landing 为 `7/7 landed, 0 invalid`。
- Candidate review gallery 为 `82 candidates, 55 assets`。
- Source safety 为 `120 candidates, 0 unsafe`。
- Project isolation 为 `0 forbidden markers, 0 outside paths, 0 project_key errors`。
- 综合资产包审计通过。

## Non-Goals

- 不把任何新候选升级为 selected source。
- 不覆盖 `assets/art/` 正式输出。
- 不改变场景、HUD、Boss、VFX 或 TileSet 的当前运行时引用。
- 不把 `15` 个 runtime review-required 资产改为 confirmed；后续仍需人工审图、清稿、切片、导出和运行态复核。
