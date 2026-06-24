# Asset Finalization Pass 01 / 首批 P0 美术收口计划

## Summary

本计划承接完整 image_gen 美术补齐目标。当前资产包已经完成 `55/55` structural-ready、`10/10` 资产族覆盖和 `7/7` Godot 编辑格式覆盖。

2026-06-21 收口更新：Pass 01 已把首批 `4` 个 P0 runtime 单体资产推进到 `final-ready`，当前总状态为 `55/55` structural-ready、`4/55` final-ready、`51/55` blocked。后续完整美术收口从 `docs/implementation-plans/2026-06-21-asset-finalization-pass-02-final-ready-expansion.md` 接续。

本轮不继续扩大新图生成数量，而是把第一批 P0 runtime 资产从“候选已落盘 / 可预览”推进到“人工视觉结论明确 / 可进入清稿和重建”。首批范围聚焦 `15` 个 runtime source review-required 资产。

## Scope

- Luna core animation：`luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01`、`luna_idle_sheet_ai01`
- Seal Guardian / Boss：`seal_guardian_boss_sheet_ai01`
- Core HUD / UI atlas：`icon_sheet_core_ai01`、`menu_ninepatch_ui_ai01`
- Seal / ability VFX：`vfx_seal_magic_atlas_ai01`、`stage16_talisman_relay_ai01`
- Stage16 UI / completion：`stage16_demo_menu_icons_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01`
- Stage14-15 HUD：`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`

## Non-Goals

- 不在没有人工 finalization record 的情况下把资产直接标记为 `final_ready`。
- 不伪造商业授权、来源人工批准或最终美术批准。
- 不覆盖 `assets/art/` 当前运行时输出，除非后续单独执行 rebuild / replacement pass。
- 不新增完整商业版资产量；后续只按 Stage polish / 资产 Batch 继续追加。

## Evidence

- 本地审图联系表：`tests/artifacts/local/asset-finalization-pass-01/runtime-source-review-contact-sheet-1.png`
- 本地审图联系表：`tests/artifacts/local/asset-finalization-pass-01/runtime-source-review-contact-sheet-2.png`
- 本地审图联系表：`tests/artifacts/local/asset-finalization-pass-01/runtime-source-review-contact-sheet-3.png`
- 联系表 manifest：`tests/artifacts/local/asset-finalization-pass-01/runtime-source-review-contact-sheets.json`
- 审图结论：`docs/assets/runtime-source-review-decisions.json`
- 审图结论文档：`docs/assets/runtime-source-review-decisions.md`
- P0 收口清单：`docs/assets/p0-finalization-list.md`

## Decisions

- `15/15` runtime review-required 资产已完成第一轮视觉复核结论。
- 本轮未发现明显外项目混入、现代实验室 / 科幻生化偏移或与 Nano Hunter 方向严重冲突的图。
- `8` 个 `manual_compare_selected_mix` 资产保留当前 runtime preview，进入清稿、帧序 / anchor / 小尺寸读值复核。
- `7` 个 `manual_source_review_or_regenerate` 资产改为“可继续清稿”的人工视觉结论；不需要先整批重生图，但仍需保留 source review / license blocker。

## Next Goal For Follow-Up Development

**Goal: Nano Hunter P0 Art Cleanup and Runtime Rebuild Pass 02**

将 `docs/assets/runtime-source-review-decisions.json` 中 `decision_status = confirmed_for_cleanup` 的 `15` 个 P0 runtime 资产推进到首批可接入 cleaned package。

成功标准：

- 为 15 个资产建立 cleaned/rebuild 输出清单，明确是否重建 `assets/art/` 输出、SpriteFrames、AtlasTexture、StyleBoxTexture、VFX rules 或 animation rules。
- Luna / Seal Guardian 动画至少完成帧序、脚底基线、透明背景、frame size、pivot / anchor 和 fps 复核记录。
- HUD / UI / icon 至少完成小尺寸读值、NinePatch margin、text-safe area、Theme / StyleBox 映射复核记录。
- VFX 至少完成 alpha mask、blend、anchor、spawn offset 和 gameplay-collision-disabled 复核记录。
- 只在清稿和重建通过后更新 runtime scene references；受影响 Stage 运行对应 GUT。
- `final_ready` 仍需等待授权条款和最终美术批准；若未拿到授权结论，只能推进到 `runtime_cleaned` / `integration_ready`，不能写成 `final_ready`。
- 2026-06-21 已通过 `asset-finalization-review-records` 批准 `4` 个小范围 P0 runtime 单体资产；剩余 `51` 个资产继续走 Pass 02。

## Test Plan

- `python scripts\assets\audit_runtime_source_review_decisions.py --strict`
- `python scripts\assets\audit_asset_package.py --write-report --strict`
- `godot --headless --path . --import`
- 若下轮替换运行时引用：运行 Stage14 / Stage15 / Stage16 对应 GUT。
- 每次替换后更新 `docs/progress/status.md`、`docs/progress/timeline.md` 和当日日志。

## Risks

- 商业使用条款仍是 `55/55` 资产的统一 blocker，不能由视觉审图自动关闭。
- 动画类资产仍有帧序、脚底基线和 timing blocker；若直接接入正式播放，可能导致动作抖动或读值错误。
- UI / icon / VFX 当前多为预览级输出，清稿前不应作为最终发布素材。
