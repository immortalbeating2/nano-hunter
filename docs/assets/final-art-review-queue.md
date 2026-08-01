# Final Art Review Queue / 最终美术复核队列

本队列把 art readiness blockers 转换为可逐项勾选的人工复核任务。它是复核计划，不是最终美术批准。

## Summary

- 资产总数：`63`
- 需要人工复核：`8`
- Final ready：`55`

## By Family

- `animation`: `8`
- `characters`: `4`
- `environment`: `11`
- `icons`: `4`
- `other`: `4`
- `promo_logo_cg`: `4`
- `props_equipment`: `7`
- `story`: `3`
- `style`: `1`
- `textures`: `1`
- `ui`: `10`
- `vfx`: `6`

## Queue

- [ ] `P0` `enemies_core_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_air_dash_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_attack_01_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_hit_death_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_idle_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_jump_fall_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_run_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `seal_guardian_boss_sheet_ai01` (animation / sprite_sheet) - 0 blockers
- [ ] `P0` `luna_spine_parts_ai01` (characters / spine_cutout_parts) - 0 blockers
- [ ] `P0` `seal_guardian_spine_parts_ai01` (characters / spine_cutout_parts) - 0 blockers
- [ ] `P0` `stage15_seal_guardian_ai01` (characters / boss_direction) - 0 blockers
- [ ] `P0` `stage16_luna_player_readability_ai01` (characters / character_direction) - 0 blockers
- [ ] `P0` `icon_sheet_core_ai01` (icons / icon_sheet) - 0 blockers
- [ ] `P0` `stage14_air_dash_icon_ai01` (icons / icon) - 0 blockers
- [ ] `P0` `stage15_recovery_charge_icon_ai01` (icons / icon) - 0 blockers
- [ ] `P0` `stage16_demo_menu_icons_ai01` (icons / icon_sheet) - 0 blockers
- [ ] `P0` `hud_core_ui_atlas_ai01` (ui / ui_atlas) - 0 blockers
- [ ] `P0` `menu_ninepatch_ui_ai01` (ui / ninepatch_sheet) - 0 blockers
- [ ] `P0` `stage14_ability_status_hud_ai01` (ui / hud_frame) - 0 blockers
- [ ] `P0` `stage15_boss_hud_frame_ai01` (ui / hud_frame) - 0 blockers
- [ ] `P0` `stage16_alpha_demo_completion_ai01` (ui / completion_ui) - 0 blockers
- [ ] `P0` `stage16_completion_panel_ui_ai01` (ui / ui_panel) - 0 blockers
- [ ] `P0` `stage16_pause_panel_ui_ai01` (ui / ui_panel) - 0 blockers
- [ ] `P0` `stage16_title_background_ai01` (ui / title_background) - 0 blockers
- [ ] `P0` `stage19_discovery_map_base_ai01` (ui / ui_map_foundation) - 4 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 按目标 HUD / icon 像素尺寸检查读值。
  - 需要人工复核 `text_safe_area_review`。
  - 需要人工复核 `runtime_layout_review`。
- [ ] `P0` `stage28_waystation_ui_sheet_ai01` (ui / ui_atlas) - 5 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。
  - 按目标 HUD / icon 像素尺寸检查读值。
  - 清理或重绘不可读的生成伪文字。
  - 确认 Theme / StyleBox 映射在目标 UI 场景中可用。
- [ ] `P0` `stage14_air_dash_trail_ai01` (vfx / vfx_direction) - 0 blockers
- [ ] `P0` `stage15_boss_attack_warning_ai01` (vfx / vfx_warning) - 0 blockers
- [ ] `P0` `stage16_corruption_purge_ai01` (vfx / vfx_sheet) - 0 blockers
- [ ] `P0` `stage16_talisman_relay_ai01` (vfx / vfx_sheet) - 0 blockers
- [ ] `P0` `vfx_combat_atlas_ai01` (vfx / vfx_atlas) - 0 blockers
- [ ] `P0` `vfx_seal_magic_atlas_ai01` (vfx / vfx_atlas) - 0 blockers
- [ ] `P1` `biome01_air_dash_shrine_room_ai01` (environment / environment_room_background) - 0 blockers
- [ ] `P1` `biome01_shrine_trial_background_ai01` (environment / environment_background) - 0 blockers
- [ ] `P1` `biome01_shrine_trial_room_parallax_ai01` (environment / environment_room_background) - 0 blockers
- [ ] `P1` `biome01_shrine_trial_tiles_ai01` (environment / environment_tiles) - 0 blockers
- [ ] `P1` `biome02_miasma_hazard_room_ai01` (environment / environment_room_background) - 0 blockers
- [ ] `P1` `biome02_miasma_marsh_background_ai01` (environment / environment_background) - 0 blockers
- [ ] `P1` `biome02_miasma_marsh_tiles_ai01` (environment / environment_tiles) - 0 blockers
- [ ] `P1` `miasma_marsh_tileset_ai01` (environment / tileset_sheet) - 0 blockers
- [ ] `P1` `shrine_trial_tileset_ai01` (environment / tileset_sheet) - 0 blockers
- [ ] `P1` `stage15_seal_guardian_boss_room_ai01` (environment / environment_boss_room_background) - 0 blockers
- [ ] `P1` `stage28_waystation_background_ai01` (environment / environment_room_background) - 3 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 把背景拆成前景、中景、远景等可配置 parallax 层。
  - 检查前景装饰不会遮挡玩家、危险物或交互物。
- [ ] `P1` `equipment_pickup_atlas_ai01` (props_equipment / equipment_atlas) - 0 blockers
- [ ] `P1` `reusable_seal_props_ai01` (props_equipment / prop_sheet) - 0 blockers
- [ ] `P1` `shrine_gate_prop_atlas_ai01` (props_equipment / prop_atlas) - 0 blockers
- [ ] `P1` `stage14_air_dash_gate_ai01` (props_equipment / prop) - 0 blockers
- [ ] `P1` `stage14_air_dash_shrine_ai01` (props_equipment / prop) - 0 blockers
- [ ] `P1` `stage16_seal_release_threshold_ai01` (props_equipment / prop) - 0 blockers
- [ ] `P1` `stage28_waystation_world_sheet_ai01` (props_equipment / prop_atlas) - 3 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 命名道具状态变体及其玩法含义。
  - 对照玩家体型检查道具比例读值。
- [ ] `P1` `style_board_global_ai01` (style / style_board) - 0 blockers
- [ ] `P1` `material_texture_atlas_ai01` (textures / texture_atlas) - 0 blockers
- [ ] `P2` `stage27_core_combat_vfx_ai01` (other / combat_vfx) - 2 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。
- [ ] `P2` `stage27_luna_formal_combat_body_ai01` (other / player_animation) - 2 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。
- [ ] `P2` `stage27_seal_guardian_formal_motion_ai01` (other / boss_animation) - 2 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。
- [ ] `P2` `stage27_seal_guardian_vfx_ai01` (other / boss_vfx) - 2 blockers
  - 确认 image gen / 外部来源的商业使用条款，并记录审批结论。
  - 在对应场景、HUD 或内容资源中替换占位引用，并记录运行时验证结果。
- [ ] `P2` `capsule_art_alpha_demo_ai01` (promo_logo_cg / promo_capsule) - 0 blockers
- [ ] `P2` `cg_seal_guardian_reveal_ai01` (promo_logo_cg / cg_illustration) - 0 blockers
- [ ] `P2` `nano_hunter_logo_direction_ai01` (promo_logo_cg / logo_direction) - 0 blockers
- [ ] `P2` `promo_key_art_sheet_ai01` (promo_logo_cg / promo_key_art) - 0 blockers
- [ ] `P2` `storyboard_intro_bounty_ai01` (story / storyboard_sheet) - 0 blockers
- [ ] `P2` `storyboard_miasma_marsh_ai01` (story / storyboard_sheet) - 0 blockers
- [ ] `P2` `storyboard_narrative_sheet_ai01` (story / storyboard_sheet) - 0 blockers
