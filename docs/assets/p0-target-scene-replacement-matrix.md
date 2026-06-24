# P0 Target Scene Replacement Matrix / P0 目标场景替换矩阵

本矩阵把 P0 runtime replacement plan 按目标场景聚合，帮助后续按场景分批替换资源。
它不直接修改 `.tscn`，也不关闭 `runtime_replacement` gate。

## Summary

- 目标场景数：`14`
- 唯一资产数：`30`
- 场景-资产引用项：`60`
- 高影响场景数：`5`
- 缺失场景数：`0`
- 已引用项：`38`
- 仍需替换项：`22`

## Scenes

- [ ] `scenes/combat/basic_melee_enemy.tscn` (combat) - assets `8`, planned `7`
  - Resource types: {"SpriteFrames": 8}
  - Risks: {"blocked_by_family_polish": 1, "requires_runtime_review": 7}
  - Assets: `luna_run_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_idle_sheet_ai01`, `seal_guardian_boss_sheet_ai01`, `luna_jump_fall_sheet_ai01`, `luna_hit_death_sheet_ai01`, `enemies_core_sheet_ai01`
  - Validation: godot --headless --path . --import | Run closest enemy / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/dev/imagegen_asset_gallery.tscn` (dev) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `style_board_global_ai01`
  - Validation: godot --headless --path . --import | Run the closest focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/enemies/seal_guardian_boss.tscn` (combat) - assets `11`, planned `7`
  - Resource types: {"CompressedTexture2D": 2, "SpriteFrames": 9}
  - Risks: {"already_referenced_reference_only": 2, "blocked_by_family_polish": 1, "requires_runtime_review": 8}
  - Assets: `stage15_seal_guardian_ai01`, `stage15_boss_attack_warning_ai01`, `luna_run_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_idle_sheet_ai01`, `seal_guardian_boss_sheet_ai01`, `vfx_seal_magic_atlas_ai01`, `luna_jump_fall_sheet_ai01`, `luna_hit_death_sheet_ai01`, `enemies_core_sheet_ai01`
  - Validation: godot --headless --path . --import | Run Stage15 Seal Guardian focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/player/player_placeholder.tscn` (player) - assets `11`, planned `2`
  - Resource types: {"CompressedTexture2D": 2, "SpriteFrames": 9}
  - Risks: {"already_referenced_reference_only": 2, "blocked_by_family_polish": 1, "requires_runtime_review": 8}
  - Assets: `stage16_luna_player_readability_ai01`, `stage14_air_dash_trail_ai01`, `luna_run_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_idle_sheet_ai01`, `seal_guardian_boss_sheet_ai01`, `vfx_seal_magic_atlas_ai01`, `luna_jump_fall_sheet_ai01`, `luna_hit_death_sheet_ai01`, `enemies_core_sheet_ai01`
  - Validation: godot --headless --path . --import | Run player movement / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage13_miasma_marsh_entry_room.tscn` (stage13) - assets `1`, planned `0`
  - Resource types: {"TileSet": 1}
  - Risks: {"blocked_by_family_polish": 1}
  - Assets: `miasma_marsh_tileset_ai01`
  - Validation: godot --headless --path . --import | Run Stage13 / TileSet room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage14_air_dash_gate_room.tscn` (stage14) - assets `3`, planned `0`
  - Resource types: {"CompressedTexture2D": 2, "TileSet": 1}
  - Risks: {"already_referenced_reference_only": 2, "blocked_by_family_polish": 1}
  - Assets: `stage14_air_dash_shrine_ai01`, `stage14_air_dash_gate_ai01`, `miasma_marsh_tileset_ai01`
  - Validation: godot --headless --path . --import | Run Stage14 focused GUT and manual Air Dash room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage14_air_dash_shrine_room.tscn` (stage14) - assets `3`, planned `0`
  - Resource types: {"CompressedTexture2D": 3}
  - Risks: {"already_referenced_reference_only": 3}
  - Assets: `stage14_air_dash_trail_ai01`, `stage14_air_dash_shrine_ai01`, `stage14_air_dash_gate_ai01`
  - Validation: godot --headless --path . --import | Run Stage14 focused GUT and manual Air Dash room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage15_seal_guardian_boss_room.tscn` (stage15) - assets `2`, planned `0`
  - Resource types: {"CompressedTexture2D": 2}
  - Risks: {"already_referenced_reference_only": 2}
  - Assets: `stage15_seal_guardian_ai01`, `stage15_boss_attack_warning_ai01`
  - Validation: godot --headless --path . --import | Run Stage15 Seal Guardian focused GUT after real replacement. | Run Stage15 focused GUT and boss room manual review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_alpha_demo_end_room.tscn` (stage16) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_alpha_demo_completion_ai01`
  - Validation: godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_corruption_purge_room.tscn` (stage16) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_talisman_relay_ai01`
  - Validation: godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_seal_release_threshold_room.tscn` (stage16) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_seal_release_threshold_ai01`
  - Validation: godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_talisman_relay_room.tscn` (stage16) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_talisman_relay_ai01`
  - Validation: godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/ui/demo_shell.tscn` (ui) - assets `9`, planned `5`
  - Resource types: {"AtlasTexture": 2, "CompressedTexture2D": 6, "StyleBoxTexture": 1}
  - Risks: {"already_referenced_reference_only": 8, "requires_runtime_review": 1}
  - Assets: `hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage16_demo_menu_icons_ai01`, `stage16_alpha_demo_completion_ai01`, `stage16_pause_panel_ui_ai01`, `stage16_completion_panel_ui_ai01`, `stage15_boss_hud_frame_ai01`, `stage14_ability_status_hud_ai01`
  - Validation: godot --headless --path . --import | Run DemoShell / Stage16 UI focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/ui/tutorial_hud.tscn` (ui) - assets `7`, planned `1`
  - Resource types: {"AtlasTexture": 2, "CompressedTexture2D": 5}
  - Risks: {"already_referenced_reference_only": 7}
  - Assets: `stage14_air_dash_icon_ai01`, `stage15_recovery_charge_icon_ai01`, `hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `stage16_demo_menu_icons_ai01`, `stage15_boss_hud_frame_ai01`, `stage14_ability_status_hud_ai01`
  - Validation: godot --headless --path . --import | Run HUD and closest Stage14 / Stage15 / Stage16 focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
