# P0 Target Scene Replacement Matrix / P0 目标场景替换矩阵

本矩阵把 P0 runtime replacement plan 按目标场景聚合，帮助后续按场景分批替换资源。
它不直接修改 `.tscn`，也不关闭 `runtime_replacement` gate。

## Summary

- 目标场景数：`12`
- 唯一资产数：`11`
- 场景-资产引用项：`23`
- 高影响场景数：`2`
- 缺失场景数：`0`
- 已引用项：`17`
- 仍需替换项：`6`

## Scenes

- [ ] `scenes/enemies/seal_guardian_boss.tscn` (combat) - assets `1`, planned `1`
  - Resource types: {"SpriteFrames": 1}
  - Risks: {"requires_runtime_review": 1}
  - Assets: `vfx_seal_magic_atlas_ai01`
  - Validation: godot --headless --path . --import | Run Stage15 Seal Guardian focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/player/player_placeholder.tscn` (player) - assets `2`, planned `1`
  - Resource types: {"CompressedTexture2D": 1, "SpriteFrames": 1}
  - Risks: {"already_referenced_reference_only": 1, "requires_runtime_review": 1}
  - Assets: `stage14_air_dash_trail_ai01`, `vfx_seal_magic_atlas_ai01`
  - Validation: godot --headless --path . --import | Run player movement / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage14_air_dash_shrine_room.tscn` (stage14) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage14_air_dash_trail_ai01`
  - Validation: godot --headless --path . --import | Run Stage14 focused GUT and manual Air Dash room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage15_completion_room.tscn` (stage15) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_seal_release_threshold_ai01`
  - Validation: godot --headless --path . --import | Run Stage15 focused GUT and boss room manual review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage15_seal_pressure_room.tscn` (stage15) - assets `1`, planned `0`
  - Resource types: {"SpriteFrames": 1}
  - Risks: {"requires_runtime_review": 1}
  - Assets: `vfx_seal_magic_atlas_ai01`
  - Validation: godot --headless --path . --import | Run Stage15 focused GUT and boss room manual review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_alpha_demo_end_room.tscn` (stage16) - assets `2`, planned `0`
  - Resource types: {"CompressedTexture2D": 2}
  - Risks: {"already_referenced_reference_only": 2}
  - Assets: `stage16_alpha_demo_completion_ai01`, `stage16_completion_panel_ui_ai01`
  - Validation: godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/rooms/stage16_backtrack_confirmation_room.tscn` (stage16) - assets `1`, planned `0`
  - Resource types: {"CompressedTexture2D": 1}
  - Risks: {"already_referenced_reference_only": 1}
  - Assets: `stage16_seal_release_threshold_ai01`
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
- [ ] `scenes/ui/demo_shell.tscn` (ui) - assets `7`, planned `3`
  - Resource types: {"AtlasTexture": 2, "CompressedTexture2D": 4, "StyleBoxTexture": 1}
  - Risks: {"already_referenced_reference_only": 6, "requires_runtime_review": 1}
  - Assets: `hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage16_demo_menu_icons_ai01`, `stage16_alpha_demo_completion_ai01`, `stage16_pause_panel_ui_ai01`, `stage16_completion_panel_ui_ai01`
  - Validation: godot --headless --path . --import | Run DemoShell / Stage16 UI focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
- [ ] `scenes/ui/tutorial_hud.tscn` (ui) - assets `4`, planned `1`
  - Resource types: {"AtlasTexture": 2, "CompressedTexture2D": 1, "StyleBoxTexture": 1}
  - Risks: {"already_referenced_reference_only": 3, "requires_runtime_review": 1}
  - Assets: `hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage16_demo_menu_icons_ai01`
  - Validation: godot --headless --path . --import | Run HUD and closest Stage14 / Stage15 / Stage16 focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
