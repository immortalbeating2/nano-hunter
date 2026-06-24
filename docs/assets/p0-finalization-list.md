# P0 Finalization List / 首批 P0 美术收口清单

本清单用于把当前 `55/55 structural-ready` 的 image_gen 资产包推进到第一批 P0 收口路径，并延续记录 Pass 02 后续 mini pack。当前已有 `55/55` final-ready 资产，P0 / P1 / P2 blocked assets 均已清零；剩余工作是 release polish、正式运行时替换、公开营销图、最终 logo 字体和 narrative / cinematic polish，不再是 final-ready blocker。

## Current Gap

- Structural-ready：`55/55`
- Final-ready：`55/55`
- Runtime review-required：`18`
- 本轮审图已给出结论：`18/18`
- 第一批可进入 cleanup / rebuild：`15/15`
- 已批准 final-ready：`55`

剩余资产尚未完成 `final_ready` 的主要原因：

- `license_terms_manual_review = 0`
- 运行时替换和复核仍有未关闭项
- 动画帧序、脚底基线、timing 未人工验收
- UI / icon / VFX 的小尺寸读值、NinePatch、anchor / blend 未人工验收
- 最终美术批准尚未记录

## Batch 01 - Approved Final-Ready Mini Pack

目标：先收口 4 个已 runtime 引用、无 family-specific blocker 的 P0 单体图标 / VFX。

- `stage14_air_dash_icon_ai01`
- `stage15_recovery_charge_icon_ai01`
- `stage14_air_dash_trail_ai01`
- `stage15_boss_attack_warning_ai01`

证据：

- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/asset-finalization-review-records.md`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`

## Batch 02 - Approved Runtime Direction / Stage16 Feedback Pack

目标：继续收口 4 个已 runtime 引用、无 family-specific blocker 的 P0 / Stage16 runtime 方向稿与反馈图。

- `stage15_seal_guardian_ai01`
- `stage16_luna_player_readability_ai01`
- `stage16_alpha_demo_completion_ai01`
- `stage16_title_background_ai01`

证据：

- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/asset-finalization-review-records.md`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`

## Batch 03 - Approved Runtime Props / Internal Style Pack

目标：继续收口 3 个已 runtime 引用、无 family-specific blocker 的 prop 资产，以及 1 个内部风格锁定参考。

- `stage14_air_dash_shrine_ai01`
- `stage14_air_dash_gate_ai01`
- `stage16_seal_release_threshold_ai01`
- `style_board_global_ai01`

证据：

- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/asset-finalization-review-records.md`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`

## Batch 04 - Approved Stage16 Region-Bound VFX Pack

目标：把 `stage16_talisman_relay_ai01` 从整张 sheet 预览推进为 Stage16 relay / purge 房间可用的 region-bound runtime VFX。

- `stage16_talisman_relay_ai01`

证据：

- `assets/art/vfx/vfx_rules/stage16_talisman_relay_ai01.vfx_rules.json`
- `scenes/rooms/stage16_talisman_relay_room.tscn`
- `scenes/rooms/stage16_corruption_purge_room.tscn`
- `tests/stage16/test_stage_16_alpha_demo_candidate.gd`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/final-art-acceptance-gates.json`

边界：

- 只批准 Stage16 当前 relay / purge 房间的显式 `region_rect` 视觉引用。
- 不批准整张 sheet 直接上屏、伤害判定、通用动画序列或商业宣传用途。

## Batch 05 - Approved Stage16 Corruption Purge VFX Pack

目标：把 `stage16_corruption_purge_ai01` 从 review-required purge VFX sheet 推进为 Stage16 purge 房间可用的 region-bound runtime VFX。

- `stage16_corruption_purge_ai01`

证据：

- `assets/art/vfx/vfx_rules/stage16_corruption_purge_ai01.vfx_rules.json`
- `assets/art/vfx/stage16_corruption_purge_ai01.source.json`
- `scenes/rooms/stage16_corruption_purge_room.tscn`
- `tests/stage16/test_stage_16_alpha_demo_candidate.gd`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/final-art-acceptance-gates.json`

边界：

- 只批准 Stage16 当前 purge 房间的显式 `region_rect` 视觉引用。
- 不批准整张 sheet 直接上屏、伤害判定、通用动画序列、通用 VFX atlas 或商业宣传用途。

## Batch 06 - Approved TutorialHUD Runtime Frame Pack

目标：把 `stage15_boss_hud_frame_ai01` 与 `stage14_ability_status_hud_ai01` 从 chroma-key preview 推进为 TutorialHUD 可用的透明 runtime frame。

- `stage15_boss_hud_frame_ai01`
- `stage14_ability_status_hud_ai01`

证据：

- `assets/art/ui/stage15_boss_hud_frame_ai01.source.json`
- `assets/art/ui/stage14_ability_status_hud_ai01.source.json`
- `scenes/ui/tutorial_hud.tscn`
- `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/final-art-acceptance-gates.json`

边界：

- 只批准当前 `TutorialHUD` 中的 runtime frame preview。
- 不批准切成通用 UI atlas、按钮状态、独立图标集、Boss 血量逻辑或商业宣传用途。

## Batch 07 - Approved DemoShell Runtime Panel Pack

目标：把 `stage16_pause_panel_ui_ai01` 与 `stage16_completion_panel_ui_ai01` 从 chroma-key preview 推进为 DemoShell 可用的透明 runtime panel preview。

- `stage16_pause_panel_ui_ai01`
- `stage16_completion_panel_ui_ai01`

证据：

- `assets/art/ui/stage16_pause_panel_ui_ai01.source.json`
- `assets/art/ui/stage16_completion_panel_ui_ai01.source.json`
- `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`
- `scenes/ui/demo_shell.tscn`
- `tests/stage16/test_stage_16_alpha_demo_candidate.gd`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/final-art-acceptance-gates.json`

边界：

- 只批准当前 `DemoShell` 中的 pause / completion runtime panel preview。
- 不批准切成通用 UI atlas、最终按钮状态、菜单图标语义、商店页完成图或商业宣传用途。

## Batch 08 - Approved Runtime Theme / StyleBox Pack

目标：把 `menu_ninepatch_ui_ai01` 从 NinePatch / StyleBoxTexture preview 推进为 DemoShell 与 TutorialHUD 当前可用的 runtime Theme skin。

- `menu_ninepatch_ui_ai01`

证据：

- `assets/art/ui/menu_ninepatch_ui_ai01.regions.json`
- `assets/art/ui/menu_ninepatch_ui_ai01.semantics.json`
- `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json`
- `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres`
- `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`
- `scenes/ui/demo_shell.tscn`
- `scenes/ui/tutorial_hud.tscn`
- `scripts/dev/audit_editor_styleboxes.gd`
- `scripts/dev/audit_editor_ui_skin.gd`
- `scripts/dev/audit_runtime_ui_skin_binding.gd`

边界：

- 只批准当前 Alpha Demo runtime Theme / StyleBoxTexture skin。
- 不批准完整最终 UI 设计系统、未来按钮状态重做、商店页 UI 或无关 atlas 区域。

## Batch 09 - Approved Stage16 DemoShell Menu Icon Strip

目标：把 `stage16_demo_menu_icons_ai01` 从旧版 menu icon preview 推进为 DemoShell 当前可用的六宫格 runtime menu icon strip。

- `stage16_demo_menu_icons_ai01`

证据：

- `assets/source/ai_generated/batch_02/stage16_demo_menu_icons_ai01/candidates/stage16_demo_menu_icons_ai01_candidate_04.png`
- `assets/art/ui/stage16_demo_menu_icons_ai01.source.json`
- `assets/art/ui/stage16_demo_menu_icons_ai01.regions.json`
- `assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json`
- `scenes/ui/demo_shell.tscn`
- `tests/artifacts/local/asset-finalization-pass-02/stage16_demo_menu_icons_ai01_48px_preview.png`

边界：

- 只批准当前 DemoShell 的六宫格 menu icon strip。
- 不批准完整最终图标体系、未来按钮状态重做、HUD atlas 无关区域、商店页 UI 或宣传素材。

## Batch 10 - Approved Internal Core Icon Source Atlas

目标：把 `icon_sheet_core_ai01` 从旧版 gameplay 语义待复核状态，收口为当前 Alpha Demo 可用的内部核心图标源图集和编辑器 `AtlasTexture` 预览。

- `icon_sheet_core_ai01`

证据：

- `assets/art/ui/atlases/icon_sheet_core_ai01.png`
- `assets/art/ui/atlases/icon_sheet_core_ai01.regions.json`
- `assets/art/ui/atlases/icon_sheet_core_ai01.semantics.json`
- `assets/art/editor_resources/icon_sheet_core_ai01/000_icon_sheet_core_ai01_auto_001_c01.atlas_texture.tres`
- `tests/artifacts/local/asset-finalization-pass-02/icon_sheet_core_ai01_contact_sheet.png`
- `tests/artifacts/local/asset-finalization-pass-02/icon_sheet_core_ai01_48px_sheet.png`

边界：

- 只批准当前 Alpha Demo 的内部核心图标源图集和编辑器预览。
- 语义文件记录的是图像实际可见含义，不批准按旧版 Air Dash / Recovery / pause / restart 等 gameplay / HUD / menu 语义直接绑定。
- 不替代 `stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01` 或 `stage16_demo_menu_icons_ai01` 这些专用 runtime icon 资产。

## Batch 11 - Approved TutorialHUD Source Atlas Preview

目标：把 `hud_core_ui_atlas_ai01` 从旧版 HUD gameplay 语义待复核状态，收口为当前 `TutorialHUD` 可加载的 source atlas preview 和编辑器 `AtlasTexture` 资源集。

- `hud_core_ui_atlas_ai01`

证据：

- `assets/art/ui/atlases/hud_core_ui_atlas_ai01.png`
- `assets/art/ui/atlases/hud_core_ui_atlas_ai01.regions.json`
- `assets/art/ui/atlases/hud_core_ui_atlas_ai01.semantics.json`
- `assets/art/editor_resources/hud_core_ui_atlas_ai01/000_hud_core_ui_atlas_ai01_auto_001.atlas_texture.tres`
- `scenes/ui/tutorial_hud.tscn`
- `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`
- `tests/artifacts/local/asset-finalization-pass-02/hud_core_ui_atlas_ai01_contact_sheet.png`
- `tests/artifacts/local/asset-finalization-pass-02/hud_core_ui_atlas_ai01_48px_sheet.png`

边界：

- 只批准当前 `TutorialHUD` 的 source atlas preview 和 editor AtlasTexture 资源集。
- 语义文件记录的是可见 HUD 装饰、符旗、面板、分隔线和莲花徽章，不批准按旧版 gameplay health / boss health / recovery / Air Dash state 语义直接替换运行时 HUD。
- 不批准完整最终 HUD 设计系统、最终 Theme mapping、按钮状态、商店页 UI 或宣传素材。

## Batch 12 - Approved Seal Magic VFX Atlas Preview

目标：把 `vfx_seal_magic_atlas_ai01` 从带文字标签的旧 atlas 候选，重生并收口为当前 Alpha Demo 可加载的隐藏/runtime seal magic VFX preview。

- `vfx_seal_magic_atlas_ai01`

证据：

- `assets/source/ai_generated/batch_10/vfx_seal_magic_atlas_ai01/candidates/vfx_seal_magic_atlas_ai01_candidate_05.png`
- `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png`
- `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.frames.json`
- `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres`
- `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.semantics.json`
- `assets/art/vfx/vfx_rules/vfx_seal_magic_atlas_ai01.vfx_rules.json`
- `scenes/player/player_placeholder.tscn`
- `scenes/enemies/seal_guardian_boss.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`
- `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime seal magic VFX preview。
- VFX rules 继续显式 `gameplay_collision=false` 与 `damage_source=false`。
- 不批准最终战斗时序、玩法碰撞、伤害来源、通用公开 VFX 图集、商店页素材或宣传素材。

## Batch 13 - Approved Combat VFX Atlas Preview

目标：把 `vfx_combat_atlas_ai01` 从 review-required combat VFX atlas 推进为当前 Alpha Demo 可加载的隐藏/runtime combat VFX preview。

- `vfx_combat_atlas_ai01`

证据：

- `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png`
- `assets/art/vfx/atlases/vfx_combat_atlas_ai01.frames.json`
- `assets/art/vfx/atlases/vfx_combat_atlas_ai01.spriteframes.tres`
- `assets/art/vfx/atlases/vfx_combat_atlas_ai01.semantics.json`
- `assets/art/vfx/vfx_rules/vfx_combat_atlas_ai01.vfx_rules.json`
- `scenes/player/player_placeholder.tscn`
- `scenes/enemies/seal_guardian_boss.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`
- `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime combat VFX preview。
- VFX rules 继续显式 `gameplay_collision=false` 与 `damage_source=false`。
- 不批准最终战斗时序、玩法碰撞、伤害来源、受击窗口、通用公开 VFX 图集、商店页素材或宣传素材。

## Batch 14 - Approved Luna Idle Animation Preview

目标：把 `luna_idle_sheet_ai01` 从混合姿态旧 sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna idle animation preview。

- `luna_idle_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_idle_sheet_ai01/candidates/luna_idle_sheet_ai01_candidate_05.png`
- `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_idle_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna idle animation preview。
- 不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 15 - Approved Luna Run Animation Preview

目标：把 `luna_run_sheet_ai01` 从混合概念旧 sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna run animation preview。

- `luna_run_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_06.png`
- `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_run_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna run animation preview。
- 不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 16 - Approved Luna Air Dash Animation Preview

目标：把 `luna_air_dash_sheet_ai01` 从旧版混合姿态 sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna Air Dash animation preview。

- `luna_air_dash_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/candidates/luna_air_dash_sheet_ai01_candidate_06.png`
- `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/selected_frames/luna_air_dash_sheet_ai01_duplicate_015_c06.png`
- `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/selected_frames/luna_air_dash_sheet_ai01_duplicate_016_c06.png`
- `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_air_dash_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna Air Dash animation preview。
- Candidate 06 抽帧结果包含两个显式标记的 duplicate recovery frames。
- 不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗或位移时序、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 17 - Approved Luna Attack 01 Animation Preview

目标：把 `luna_attack_01_sheet_ai01` 从旧版混合概念 sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna attack 01 animation preview。

- `luna_attack_01_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/candidates/luna_attack_01_sheet_ai01_candidate_06.png`
- `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_attack_01_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna attack 01 animation preview。
- 不批准正式玩家控制器动画替换、hitbox / hurtbox、伤害时序、取消窗口、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 18 - Approved Luna Jump / Fall Animation Preview

目标：把 `luna_jump_fall_sheet_ai01` 从旧版需要 duplicate 补位的 jump / fall sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna jump/fall animation preview。

- `luna_jump_fall_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_jump_fall_sheet_ai01/candidates/luna_jump_fall_sheet_ai01_candidate_06.png`
- `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_jump_fall_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna jump/fall animation preview。
- Candidate 06 抽取 `24/24` selected frames，且没有 duplicate recovery-frame fallback。
- 不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、跳跃物理时序、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 19 - Approved Seal Guardian Boss Attack Animation Preview

目标：把 `seal_guardian_boss_sheet_ai01` 从旧版混合四足兽 / 人形守卫 sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Seal Guardian boss attack animation preview。

- `seal_guardian_boss_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/candidates/seal_guardian_boss_sheet_ai01_candidate_04.png`
- `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.frames.json`
- `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.spriteframes.tres`
- `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/seal_guardian_boss_sheet_ai01.animation_rules.json`
- `scenes/enemies/seal_guardian_boss.tscn`
- `scenes/rooms/stage15_seal_guardian_boss_room.tscn`
- `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Seal Guardian boss attack animation preview。
- Candidate 04 抽取 `20/20` selected frames，修正旧版四足兽 / 人形守卫混合漂移。
- 不批准正式 Boss 状态机动画替换、攻击判定、damage window、受击 / 击败动作、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 20 - Approved Luna Hit / Death Animation Preview

目标：把 `luna_hit_death_sheet_ai01` 从旧版混合比例 hit/death sheet 重生并收口为当前 Alpha Demo 可加载的隐藏/runtime Luna hit/death animation preview。

- `luna_hit_death_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/luna_hit_death_sheet_ai01/candidates/luna_hit_death_sheet_ai01_candidate_04.png`
- `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/luna_hit_death_sheet_ai01.animation_rules.json`
- `scenes/player/player_placeholder.tscn`
- `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime Luna hit/death animation preview。
- Candidate 04 抽取 `24/24` selected frames，且没有 duplicate recovery-frame fallback。
- 不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、受击无敌时序、失败 / 重开逻辑、公开 sprite sheet、商店页素材或商业动画清稿。

## Batch 21 - Approved Core Enemies Animation Preview

目标：把 `enemies_core_sheet_ai01` 从旧版跨格 VFX、行身份漂移和 duplicate fallback 风险，重建并收口为当前 Alpha Demo 可加载的隐藏/runtime core enemy roster animation preview。

- `enemies_core_sheet_ai01`

证据：

- `assets/source/ai_generated/batch_06/enemies_core_sheet_ai01/candidates/enemies_core_sheet_ai01_candidate_06.png`
- `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.frames.json`
- `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.spriteframes.tres`
- `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.semantics.json`
- `assets/art/characters/animation_rules/enemies_core_sheet_ai01.animation_rules.json`
- `scenes/combat/basic_melee_enemy.tscn`
- `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

边界：

- 只批准当前 Alpha Demo 的隐藏/runtime core enemy roster animation preview。
- Candidate 06 抽取 `32/32` selected frames，修正旧版跨格 VFX、错误最终格和 duplicate fallback 风险。
- 不批准正式敌人 AI 动画替换、攻击判定、hurtbox / hitbox、逐敌人状态机、公开 sprite sheet、商店页素材或商业动画清稿。


## Batch 22 - Approved Luna Spine Cutout Source

目标：把 `luna_spine_parts_ai01` 从 structural-ready Spine 拆件图集推进为当前 Alpha Demo 后续 rigging handoff 可用的 Luna Spine-style cutout source / export package。

- `luna_spine_parts_ai01`

证据：

- `assets/art/spine_parts/luna_spine_parts_ai01.png`
- `assets/art/spine_parts/luna_spine_parts_ai01.regions.json`
- `assets/art/spine_parts/luna_spine_parts_ai01.semantics.json`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.atlas`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.spine_style.json`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.cutout_manifest.json`
- `assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json`
- `scripts/assets/audit_spine_cutout_manifests.py --strict`

边界：

- 只批准当前 Alpha Demo 后续 rigging handoff 的 Luna cutout source / export package。
- 不批准正式 Spine rig、Godot Skeleton2D / Bone2D 绑定、运行时动画替换、hitbox / hurtbox、攻击时序、公开 sprite source、商店页素材或商业动画清稿。


## Batch 23 - Approved Seal Guardian Spine Cutout Source

目标：把 `seal_guardian_spine_parts_ai01` 从 structural-ready Spine 拆件图集推进为当前 Alpha Demo 后续 rigging handoff 可用的 Seal Guardian Spine-style cutout source / export package。

- `seal_guardian_spine_parts_ai01`

证据：

- `assets/art/spine_parts/seal_guardian_spine_parts_ai01.png`
- `assets/art/spine_parts/seal_guardian_spine_parts_ai01.regions.json`
- `assets/art/spine_parts/seal_guardian_spine_parts_ai01.semantics.json`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.atlas`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.spine_style.json`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.cutout_manifest.json`
- `assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json`
- `scripts/assets/audit_spine_cutout_manifests.py --strict`

边界：

- 只批准当前 Alpha Demo 后续 rigging handoff 的 Seal Guardian cutout source / export package。
- 当前拆件仍需后续动画阶段复核 pivot、layer order、边缘清理和 rigging polish。
- 不批准正式 Spine rig、Godot Skeleton2D / Bone2D 绑定、运行时动画替换、Boss 状态机时序、hitbox / hurtbox、damage window、公开 sprite source、商店页素材或商业动画清稿。

## Batch 24 - Approved Environment Visual Source / Editor TileSet Source Pack

目标：把 P1 / P2 中已具备 source traceability、Godot structural resource、editor review card 与 finalization review 证据的环境资产，从 structural-ready 推进为当前 Alpha Demo 可用的 environment visual source / editor TileSet source。

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

证据：

- `assets/art/environment/biome_01_shrine_trial/biome01_air_dash_shrine_room_ai01.png`
- `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_background_ai01.png`
- `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_room_parallax_ai01.png`
- `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_tiles_ai01.png`
- `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_hazard_room_ai01.png`
- `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_background_ai01.png`
- `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_tiles_ai01.png`
- `assets/art/tilesets/miasma_marsh_tileset_ai01.png`
- `assets/art/tilesets/shrine_trial_tileset_ai01.png`
- `assets/art/environment/boss_rooms/stage15_seal_guardian_boss_room_ai01.png`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`
- `tests/artifacts/local/asset-finalization-pass-02/environment_review_contact_sheet.png`

边界：

- 只批准当前 Alpha Demo 的 environment visual source、room background source、tile visual source 和 editor TileSet source。
- 不批准最终 autotile、collision polygon、hazard damage Area、navigation、occlusion、完整 parallax split、全场景替换或商业级背景清稿。
- `reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01` 和 `material_texture_atlas_ai01` 仍需后续 P1 props / equipment / texture polish。

## Batch 25 - Approved Props / Equipment / Texture Source Pack

目标：把剩余 P1 props / equipment / texture 资产从 structural-ready 推进为当前 Alpha Demo 可用的 source atlas、prop source sheet 和 material reference source。

- `equipment_pickup_atlas_ai01`
- `reusable_seal_props_ai01`
- `shrine_gate_prop_atlas_ai01`
- `material_texture_atlas_ai01`

证据：

- `assets/art/atlases/equipment_pickup_atlas_ai01.png`
- `assets/art/atlases/equipment_pickup_atlas_ai01.regions.json`
- `assets/art/atlases/equipment_pickup_atlas_ai01.semantics.json`
- `assets/art/atlases/shrine_gate_prop_atlas_ai01.png`
- `assets/art/atlases/shrine_gate_prop_atlas_ai01.regions.json`
- `assets/art/atlases/shrine_gate_prop_atlas_ai01.semantics.json`
- `assets/art/props/reusable_seal_props_ai01.png`
- `assets/art/textures/material_texture_atlas_ai01.png`
- `assets/art/textures/material_texture_atlas_ai01.regions.json`
- `assets/art/textures/material_texture_atlas_ai01.semantics.json`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`
- `tests/artifacts/local/asset-finalization-pass-02/p1_props_texture_review_contact_sheet.png`

边界：

- 只批准当前 Alpha Demo 的 equipment / pickup source atlas、shrine / gate prop source atlas、reusable seal prop source sheet 和 material texture reference source atlas。
- 不批准最终 pickup 逻辑、reward balance、shrine / gate 状态机、collision、room placement、runtime scale、无缝贴图、shader/material binding 或 terrain replacement。
- `reusable_seal_props_ai01` 的可见绿底经 alpha 检查为透明背景，不是不透明绿幕。
- P1 blocked assets 已清零；剩余 blocker 当时只集中在 P2 promo / CG / storyboard，已由 Batch 26 关闭。

## Batch 26 - Approved Promo / CG / Story Direction Source Pack

目标：把剩余 P2 promo / logo / CG / storyboard 资产从 structural-ready 推进为当前 Alpha Demo 可用的 presentation / promo direction source 与 narrative direction source，关闭 Pass 02 最后 `7` 个 blocked assets。

- `capsule_art_alpha_demo_ai01`
- `cg_seal_guardian_reveal_ai01`
- `nano_hunter_logo_direction_ai01`
- `promo_key_art_sheet_ai01`
- `storyboard_intro_bounty_ai01`
- `storyboard_miasma_marsh_ai01`
- `storyboard_narrative_sheet_ai01`

证据：

- `assets/art/promo/capsule_art_alpha_demo_ai01.png`
- `assets/art/promo/cg_seal_guardian_reveal_ai01.png`
- `assets/art/promo/nano_hunter_logo_direction_ai01.png`
- `assets/art/promo/promo_key_art_sheet_ai01.png`
- `assets/art/promo/promo_key_art_sheet_ai01.regions.json`
- `assets/art/promo/promo_key_art_sheet_ai01.semantics.json`
- `assets/art/storyboards/storyboard_intro_bounty_ai01.png`
- `assets/art/storyboards/storyboard_miasma_marsh_ai01.png`
- `assets/art/storyboards/storyboard_narrative_sheet_ai01.png`
- `assets/art/storyboards/storyboard_narrative_sheet_ai01.regions.json`
- `assets/art/storyboards/storyboard_narrative_sheet_ai01.semantics.json`
- `docs/assets/asset-finalization-review-records.json`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-acceptance-gates.json`
- `tests/artifacts/local/asset-finalization-pass-02/p2_promo_story_review_contact_sheet.png`

边界：

- 只批准当前 Alpha Demo 的 presentation / promo direction source、logo direction source、CG direction source 和 narrative storyboard direction source。
- `nano_hunter_logo_direction_ai01` 不批准为最终字体、矢量 logo、商标锁定或公开主视觉标题。
- `promo_key_art_sheet_ai01`、`capsule_art_alpha_demo_ai01` 与 `cg_seal_guardian_reveal_ai01` 不批准为最终商店页、平台裁切、公开营销图、title safe-area 或商业发布素材。
- 三套 storyboard 不批准为最终剧情脚本、对白、本地化、过场成片、cutscene timing 或发布级 CG。
- Batch 26 关闭 Pass 02 最后 P2 blocker 后，完整资产包达到 `55/55 final-ready`、`0/55 blocked`。

## Batch A - Animation Runtime Cleanup

状态：当前 P0 animation sheet cleanup 已由 Batch 14-21 分批关闭；`luna_spine_parts_ai01` 与 `seal_guardian_spine_parts_ai01` 已由 Batch 22-23 批准为 future rigging handoff 拆件源；P0 blocked assets 已清零。

后续如要从 hidden/runtime animation preview 推进到正式可播放动画，需要另起专门 animation polish batch，并重新定义逐动作帧序、pivot、脚底基线、state machine、hurtbox / hitbox、attack timing 和 controller / enemy AI 绑定。

## Batch B - HUD / UI Runtime Cleanup

状态：当前 P0 HUD / UI source atlas cleanup 已由 Batch 06-11 分批关闭；剩余 P0 不再集中在 UI atlas，而是 Spine 拆件。

后续如要从 source atlas preview 推进到完整最终 HUD 设计系统，需要另起专门 HUD polish batch，并重新定义 gameplay health、Boss health、Recovery Charge、Air Dash state、Theme mapping 和按钮状态的正式语义。

## Batch C - VFX Runtime Cleanup

状态：当前 P0 VFX atlas cleanup 已由 Batch 04、Batch 05、Batch 12 和 Batch 13 分批关闭；剩余 P0 不再集中在 VFX atlas。

后续如要从 hidden/runtime preview 推进到正式战斗 VFX，需要另起专门 combat VFX polish batch，并重新定义 spawn offset、mask、blend、节奏、角色动作同步、hit pause、hurtbox / hitbox 可读性和性能预算。

已完成条件：

- alpha mask / blend 清理完成
- anchor / spawn offset 复核完成
- gameplay collision 保持 disabled，不能误导碰撞范围
- Stage14 / Stage15 / Stage16 GUT 通过

## Required Reports To Update

- `docs/assets/runtime-source-review-decisions.json`
- `docs/assets/art-readiness-audit-report.json`
- `docs/assets/final-art-review-queue.json`
- `docs/assets/final-art-acceptance-gates.json`
- `docs/assets/asset-package-audit-report.json`
- `docs/progress/status.md`
- `docs/progress/timeline.md`
- `docs/progress/logs/YYYY-MM-DD.md`

## Exit Criteria For Pass 02

- 至少一个 Batch 完成 cleaned/rebuild 输出并进入 runtime verification。
- 相关 `.import` 正常生成。
- 相关 Godot scene references 或 hidden preview references 与新资源一致。
- 对应 GUT 通过。
- 若授权条款仍未人工批准，状态只能写 `runtime_cleaned` 或 `integration_ready`，不能写 `final_ready`。
