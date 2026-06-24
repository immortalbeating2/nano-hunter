# Asset Finalization Pass 02 / 完整美术 final-ready 扩展目标

## Summary

本目标承接用户提出的完整 image gen 美术补齐方向：角色类、关卡地图场景类、UI / 界面类、图标类、道具与装备类、特效类、动画帧 / 序列帧、贴图类、宣传与运营类、LOGO、CG、分镜图、叙事与剧情类，以及 Godot 编辑可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集和九宫格图片。

当前不是“没有生成资产”，而是“生成和结构化已经完成，最终批准还没有完成”。截至 2026-06-24：

- 结构层：`55/55` structural-ready。
- 资产族覆盖：`10/10` families structurally covered。
- Godot 产物覆盖：`7/7` formats structurally covered。
- 最终可用：`55/55` final-ready。
- 剩余缺口：`0/55` blocked，其中 P0 `0`、P1 `0`、P2 `0`。
- 主要 blocker：`0`；`source_traceability`、`godot_structural_resource`、`editor_review_card`、`runtime_replacement`、`license_terms`、`family_specific_polish` 与 `final_approval` 当前均为 `55/55` passed。

## Goal

把当前 `55` 个 structural-ready image gen 资产全部推进到可复核、可清稿、可接入或可作为 source / direction handoff 的 final-ready 状态。优先目标不是继续无限生成新图，而是把已落盘的 `55` 个结构化资产包从 prototype-ready 推进到 Alpha Demo 可用的 final-ready 包；只有当某个资产在人工审图中确认风格、构图、读值或来源不可靠时，才使用内置 `image_gen` 重生成替代候选。

## Current Final-Ready Assets

以下 `55` 个资产已通过 finalization review：

- `stage14_air_dash_icon_ai01`
- `stage14_air_dash_trail_ai01`
- `stage15_boss_attack_warning_ai01`
- `stage15_seal_guardian_ai01`
- `stage16_luna_player_readability_ai01`
- `stage16_alpha_demo_completion_ai01`
- `stage16_title_background_ai01`
- `stage15_recovery_charge_icon_ai01`
- `stage14_air_dash_shrine_ai01`
- `stage14_air_dash_gate_ai01`
- `stage16_seal_release_threshold_ai01`
- `style_board_global_ai01`
- `stage16_talisman_relay_ai01`
- `stage16_corruption_purge_ai01`
- `stage15_boss_hud_frame_ai01`
- `stage14_ability_status_hud_ai01`
- `stage16_pause_panel_ui_ai01`
- `stage16_completion_panel_ui_ai01`
- `menu_ninepatch_ui_ai01`
- `stage16_demo_menu_icons_ai01`
- `icon_sheet_core_ai01`
- `hud_core_ui_atlas_ai01`
- `vfx_seal_magic_atlas_ai01`
- `vfx_combat_atlas_ai01`
- `luna_idle_sheet_ai01`
- `luna_run_sheet_ai01`
- `luna_air_dash_sheet_ai01`
- `luna_attack_01_sheet_ai01`
- `luna_jump_fall_sheet_ai01`
- `seal_guardian_boss_sheet_ai01`
- `luna_hit_death_sheet_ai01`
- `enemies_core_sheet_ai01`
- `luna_spine_parts_ai01`
- `seal_guardian_spine_parts_ai01`
- `biome01_air_dash_shrine_room_ai01`
- `biome01_shrine_trial_background_ai01`
- `biome01_shrine_trial_room_parallax_ai01`
- `biome01_shrine_trial_tiles_ai01`
- `biome02_miasma_hazard_room_ai01`
- `biome02_miasma_marsh_background_ai01`
- `biome02_miasma_marsh_tiles_ai01`
- `miasma_marsh_tileset_ai01`
- `shrine_trial_tileset_ai01`
- `stage15_seal_guardian_boss_room_ai01`
- `equipment_pickup_atlas_ai01`
- `material_texture_atlas_ai01`
- `reusable_seal_props_ai01`
- `shrine_gate_prop_atlas_ai01`
- `capsule_art_alpha_demo_ai01`
- `cg_seal_guardian_reveal_ai01`
- `nano_hunter_logo_direction_ai01`
- `promo_key_art_sheet_ai01`
- `storyboard_intro_bounty_ai01`
- `storyboard_miasma_marsh_ai01`
- `storyboard_narrative_sheet_ai01`

## Remaining Gap By Family

| Family | Blocked Count | 主要缺口 |
| --- | ---: | --- |
| animation | 0 | `luna_idle_sheet_ai01`、`luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01`、`luna_jump_fall_sheet_ai01`、`luna_hit_death_sheet_ai01`、`enemies_core_sheet_ai01` 与 `seal_guardian_boss_sheet_ai01` 已批准为 hidden/runtime animation preview；正式可玩动画替换仍需另起 animation polish batch |
| characters | 0 | Luna / Seal Guardian 方向稿、Boss preview sheet 与两套 Spine-style cutout source 均已按当前 Alpha Demo 边界批准；正式 Spine rig、Skeleton2D / Bone2D 绑定和商业级动画清稿仍需另起 animation / rigging polish batch |
| environment | 0 | biome 01 / biome 02 背景、房间图、环境 tile visual pass 与两套 TileSet 已批准为当前 Alpha Demo environment visual source / editor TileSet source；正式 autotile、collision polygon、hazard Area、navigation、occlusion 与完整 parallax split 仍需另起 environment polish batch |
| ui | 0 | `hud_core_ui_atlas_ai01` 已批准为 TutorialHUD source atlas preview；完整最终 HUD 设计系统仍需单独 polish |
| props_equipment | 0 | `equipment_pickup_atlas_ai01`、`reusable_seal_props_ai01` 与 `shrine_gate_prop_atlas_ai01` 已批准为 Alpha Demo source atlas / prop source；正式 runtime pickup、gate 状态机、collision、scale 和 room placement 仍需另起 content polish |
| vfx | 0 | seal magic atlas 与 combat VFX atlas 均已批准为当前 Alpha Demo hidden/runtime preview；二者仍不批准为最终战斗时序、玩法碰撞、伤害来源或公开宣传素材 |
| icons | 0 | `icon_sheet_core_ai01` 已批准为内部核心图标源图集；最终 HUD / menu 语义图标体系仍按专用资产另行推进 |
| promo_logo_cg | 0 | Logo、Key Art、capsule 与 CG 已批准为 Alpha Demo presentation / promo direction source；最终 logo 字体、平台裁切、公开营销图和商业发布素材仍需另起 release polish |
| story | 0 | 三套 storyboard 已批准为 Alpha Demo narrative direction source；最终脚本锁定、对白、本地化、过场成片和发布级 CG 仍需另起 narrative/cinematic polish |
| textures | 0 | `material_texture_atlas_ai01` 已批准为 Alpha Demo material reference source atlas；无缝贴图、shader / material binding 和 runtime terrain replacement 仍需另起 texture polish |
| style | 0 | 风格板已批准为内部风格锁定参考；公开宣传用途仍另行复核 |

## Scope

- P0 当前已清零：`0` 个 blocked P0 assets。
- P1 当前已清零：`0` 个 blocked P1 assets。
- P2 当前已清零：`0` 个 blocked P2 assets。
- 运行时 blocker 与 P2 blocker 均已清零；剩余工作不再是 final-ready blocker，而是商业发布级 polish、公开营销图、最终 logo 字体、过场成片和剧情脚本锁定。
- 第三优先处理高风险清稿：动画、UI、VFX、TileSet。
- P1 / P2 宣传、CG、分镜、运营图先达到候选和授权记录完整，不阻塞 Alpha Demo runtime。

## Recommended Pass Order

1. `Pass 02A - P0 Runtime Finalization`
   - 目标：把剩余 P0 runtime / finalization blocker 从 `23 blocked` 降到可接近 `0 blocked`。
   - 重点：Stage16 completion UI、DemoShell menu icons、HUD frame、ability HUD、seal / purge / relay VFX、Luna readability、Seal Guardian readability。

2. `Pass 02B - Animation Cleanup`
   - 目标：Luna 与 Seal Guardian 动画 SpriteFrames 从 preview 变成可试玩清稿版。
   - 重点：frame order、baseline、anchor、hit / attack / dash timing、透明背景、固定帧格。

3. `Pass 02C - Environment And TileSet Review`
   - 目标：biome 01 / biome 02 的背景、TileSet、房间图和 boss room 视觉达到不误导碰撞和路线的标准。
   - 重点：collision readability、hazard color、foreground occlusion、parallax split。

4. `Pass 02D - UI Atlas And NinePatch`
   - 目标：菜单、暂停、完成反馈、HUD 图集和九宫格面板完成小尺寸读值与 Theme / StyleBox 复核。
   - 重点：64px icon readability、text-safe area、stretch margins、button states。

5. `Pass 02E - Promo / Narrative Package`
   - 目标：LOGO、Key Art、CG、分镜图进入可展示候选包。
   - 重点：发布规格、无水印、标题字可读、叙事镜头不偏离南北朝东方奇幻。

## Generation Policy

- 图像生成继续优先使用内置 `image_gen`。
- 对于已落盘资产，先人工审图和清稿；只有确认不适合继续使用时再重生成。
- 每次重生成必须写入 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`，并更新 provenance、prompt、hash 和 source safety。
- 不从全局最新 PNG 自动拷贝到项目；必须使用明确 session、明确 source 或 import map。

## Required Updates

- 更新 `docs/assets/asset-finalization-review-records.json` 与 `.md`。
- 更新 `docs/assets/art-readiness-audit-report.json`。
- 更新 `docs/assets/final-art-review-queue.json` / `.md`。
- 更新 `docs/assets/final-art-acceptance-gates.json` / `.md`。
- 更新 `docs/assets/asset-manifest.md` 和 `docs/assets/asset-completion-matrix.md`。
- 若替换运行时引用，更新 `docs/assets/p0-runtime-replacement-plan.json`、相关场景、`.import` 和当日进度日志。

## Test Plan

- `python scripts\assets\audit_asset_finalization_reviews.py --strict`
- `python scripts\assets\audit_art_readiness.py --write-report --strict`
- `python scripts\assets\audit_final_art_review_queue.py --strict`
- `python scripts\assets\audit_final_art_acceptance_gates.py --strict`
- `python scripts\assets\audit_asset_package.py --write-report --strict`
- `python scripts\assets\audit_imagegen_source_safety.py --write-report --strict`
- `python scripts\assets\audit_asset_provenance.py --strict`
- `godot --headless --path . --import`
- 若影响 Stage14 / Stage15 / Stage16：运行对应 GUT。
- 每个子 pass 完成后运行 `git diff --check`，并更新 `docs/progress/status.md`、`docs/progress/timeline.md`、`docs/progress/logs/YYYY-MM-DD.md`。

## Exit Criteria

- P0 runtime assets 不再有 `runtime_replacement` blocker。
- P0 final-ready 数量明显提升，并能在 `final-art-acceptance-gates.json` 中追踪。
- 所有新增或重生成资产都有 source、prompt、hash、目标路径和授权 / finalization review 记录。
- Godot import、相关 GUT 和综合资产包审计全部通过。
- 仍未 final-ready 的 P1 / P2 资产必须列出明确 blocker 和下一步，不再只写“待生成”。

## Non-Goals

- 不一次性承诺完整商业版所有资产量。
- 不把未清稿、未授权、未批准的资产写成 final-ready。
- 不把 Seedance / Veo 等视频参考直接作为游戏内 sprite 动画源。
- 不在没有人工确认的情况下替换 selected source 或运行时引用。
