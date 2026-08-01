# Final Art Acceptance Gates / 最终美术验收门槛

本文件把最终美术从 `structural_ready` 推进到 `final_ready` 所需的门槛拆成机器可审计清单。
它不是最终批准记录；当前所有未通过项仍需要人工清稿、授权确认、运行时替换或玩法读值复核。

## Summary

- 资产总数：`60`
- Final ready：`55`
- 仍有阻塞门槛的资产：`5`
- 每个资产验收门槛数：`7`

## Gate Summary

- `source_traceability` / 来源 / prompt / hash 可追溯: passed `56`, blocked `4`
- `license_terms` / 商业使用条款人工复核: passed `55`, blocked `5`
- `godot_structural_resource` / Godot 结构资源可用: passed `60`, blocked `0`
- `editor_review_card` / 编辑器复核卡可用: passed `60`, blocked `0`
- `runtime_replacement` / 运行时引用替换与验证: passed `56`, blocked `4`
- `family_specific_polish` / 按资产族清稿 / 读值 / 帧序 / 布局复核: passed `59`, blocked `1`
- `final_approval` / 最终美术批准: passed `55`, blocked `5`

## Blocked Assets

- [ ] `P1` `biome01_air_dash_shrine_room_ai01` (environment / environment_room_background) - blocked gates `0`
- [ ] `P1` `biome01_shrine_trial_background_ai01` (environment / environment_background) - blocked gates `0`
- [ ] `P1` `biome01_shrine_trial_room_parallax_ai01` (environment / environment_room_background) - blocked gates `0`
- [ ] `P1` `biome01_shrine_trial_tiles_ai01` (environment / environment_tiles) - blocked gates `0`
- [ ] `P1` `biome02_miasma_hazard_room_ai01` (environment / environment_room_background) - blocked gates `0`
- [ ] `P1` `biome02_miasma_marsh_background_ai01` (environment / environment_background) - blocked gates `0`
- [ ] `P1` `biome02_miasma_marsh_tiles_ai01` (environment / environment_tiles) - blocked gates `0`
- [ ] `P2` `capsule_art_alpha_demo_ai01` (promo_logo_cg / promo_capsule) - blocked gates `0`
- [ ] `P2` `cg_seal_guardian_reveal_ai01` (promo_logo_cg / cg_illustration) - blocked gates `0`
- [ ] `P0` `enemies_core_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P1` `equipment_pickup_atlas_ai01` (props_equipment / equipment_atlas) - blocked gates `0`
- [ ] `P0` `hud_core_ui_atlas_ai01` (ui / ui_atlas) - blocked gates `0`
- [ ] `P0` `icon_sheet_core_ai01` (icons / icon_sheet) - blocked gates `0`
- [ ] `P0` `luna_air_dash_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_attack_01_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_hit_death_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_idle_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_jump_fall_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_run_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `luna_spine_parts_ai01` (characters / spine_cutout_parts) - blocked gates `0`
- [ ] `P1` `material_texture_atlas_ai01` (textures / texture_atlas) - blocked gates `0`
- [ ] `P0` `menu_ninepatch_ui_ai01` (ui / ninepatch_sheet) - blocked gates `0`
- [ ] `P1` `miasma_marsh_tileset_ai01` (environment / tileset_sheet) - blocked gates `0`
- [ ] `P2` `nano_hunter_logo_direction_ai01` (promo_logo_cg / logo_direction) - blocked gates `0`
- [ ] `P2` `promo_key_art_sheet_ai01` (promo_logo_cg / promo_key_art) - blocked gates `0`
- [ ] `P1` `reusable_seal_props_ai01` (props_equipment / prop_sheet) - blocked gates `0`
- [ ] `P0` `seal_guardian_boss_sheet_ai01` (animation / sprite_sheet) - blocked gates `0`
- [ ] `P0` `seal_guardian_spine_parts_ai01` (characters / spine_cutout_parts) - blocked gates `0`
- [ ] `P1` `shrine_gate_prop_atlas_ai01` (props_equipment / prop_atlas) - blocked gates `0`
- [ ] `P1` `shrine_trial_tileset_ai01` (environment / tileset_sheet) - blocked gates `0`
- [ ] `P0` `stage14_ability_status_hud_ai01` (ui / hud_frame) - blocked gates `0`
- [ ] `P1` `stage14_air_dash_gate_ai01` (props_equipment / prop) - blocked gates `0`
- [ ] `P0` `stage14_air_dash_icon_ai01` (icons / icon) - blocked gates `0`
- [ ] `P1` `stage14_air_dash_shrine_ai01` (props_equipment / prop) - blocked gates `0`
- [ ] `P0` `stage14_air_dash_trail_ai01` (vfx / vfx_direction) - blocked gates `0`
- [ ] `P0` `stage15_boss_attack_warning_ai01` (vfx / vfx_warning) - blocked gates `0`
- [ ] `P0` `stage15_boss_hud_frame_ai01` (ui / hud_frame) - blocked gates `0`
- [ ] `P0` `stage15_recovery_charge_icon_ai01` (icons / icon) - blocked gates `0`
- [ ] `P0` `stage15_seal_guardian_ai01` (characters / boss_direction) - blocked gates `0`
- [ ] `P1` `stage15_seal_guardian_boss_room_ai01` (environment / environment_boss_room_background) - blocked gates `0`
- [ ] `P0` `stage16_alpha_demo_completion_ai01` (ui / completion_ui) - blocked gates `0`
- [ ] `P0` `stage16_completion_panel_ui_ai01` (ui / ui_panel) - blocked gates `0`
- [ ] `P0` `stage16_corruption_purge_ai01` (vfx / vfx_sheet) - blocked gates `0`
- [ ] `P0` `stage16_demo_menu_icons_ai01` (icons / icon_sheet) - blocked gates `0`
- [ ] `P0` `stage16_luna_player_readability_ai01` (characters / character_direction) - blocked gates `0`
- [ ] `P0` `stage16_pause_panel_ui_ai01` (ui / ui_panel) - blocked gates `0`
- [ ] `P1` `stage16_seal_release_threshold_ai01` (props_equipment / prop) - blocked gates `0`
- [ ] `P0` `stage16_talisman_relay_ai01` (vfx / vfx_sheet) - blocked gates `0`
- [ ] `P0` `stage16_title_background_ai01` (ui / title_background) - blocked gates `0`
- [ ] `P0` `stage19_discovery_map_base_ai01` (ui / ui_map_foundation) - blocked gates `3`
  - `license_terms`: license_terms_manual_review
  - `family_specific_polish`: small_size_readability_review, text_safe_area_review, runtime_layout_review
  - `final_approval`: readiness_final_ready_false, upstream_acceptance_gate_blocked
- [ ] `P2` `stage27_core_combat_vfx_ai01` (other / combat_vfx) - blocked gates `4`
  - `source_traceability`: source_or_hash_record_missing
  - `license_terms`: license_terms_manual_review
  - `runtime_replacement`: runtime_catalog_ready_manual_replacement
  - `final_approval`: readiness_final_ready_false, upstream_acceptance_gate_blocked
- [ ] `P2` `stage27_luna_formal_combat_body_ai01` (other / player_animation) - blocked gates `4`
  - `source_traceability`: source_or_hash_record_missing
  - `license_terms`: license_terms_manual_review
  - `runtime_replacement`: runtime_catalog_ready_manual_replacement
  - `final_approval`: readiness_final_ready_false, upstream_acceptance_gate_blocked
- [ ] `P2` `stage27_seal_guardian_formal_motion_ai01` (other / boss_animation) - blocked gates `4`
  - `source_traceability`: source_or_hash_record_missing
  - `license_terms`: license_terms_manual_review
  - `runtime_replacement`: runtime_catalog_ready_manual_replacement
  - `final_approval`: readiness_final_ready_false, upstream_acceptance_gate_blocked
- [ ] `P2` `stage27_seal_guardian_vfx_ai01` (other / boss_vfx) - blocked gates `4`
  - `source_traceability`: source_or_hash_record_missing
  - `license_terms`: license_terms_manual_review
  - `runtime_replacement`: runtime_catalog_ready_manual_replacement
  - `final_approval`: readiness_final_ready_false, upstream_acceptance_gate_blocked
- [ ] `P2` `storyboard_intro_bounty_ai01` (story / storyboard_sheet) - blocked gates `0`
- [ ] `P2` `storyboard_miasma_marsh_ai01` (story / storyboard_sheet) - blocked gates `0`
- [ ] `P2` `storyboard_narrative_sheet_ai01` (story / storyboard_sheet) - blocked gates `0`
- [ ] `P1` `style_board_global_ai01` (style / style_board) - blocked gates `0`
- [ ] `P0` `vfx_combat_atlas_ai01` (vfx / vfx_atlas) - blocked gates `0`
- [ ] `P0` `vfx_seal_magic_atlas_ai01` (vfx / vfx_atlas) - blocked gates `0`
