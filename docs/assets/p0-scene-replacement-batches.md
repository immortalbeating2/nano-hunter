# P0 Scene Replacement Batches / P0 场景替换批次

本报告把 P0 target scene replacement matrix 拆成可以逐批执行和验证的场景替换顺序。
它不直接修改 `.tscn`，不关闭 `runtime_replacement` gate，也不代表最终美术批准完成。

## Summary

- 批次数：`9`
- 覆盖场景数：`14`
- 唯一资产数：`30`
- 场景-资产引用项：`60`
- 仍需替换项：`22`
- 已引用项：`38`
- 缺失场景数：`0`
- 未分批场景数：`0`
- 被 family polish 阻塞的批次数：`5`

## Batches

### 00. `batch_00_dev_reference` - 开发参考基线

- 状态：`reference_only_already_bound`
- 目的：先保留已绑定的全局风格板作为参考基线，再进入正式玩法场景替换。
- 范围：场景 `1`，唯一资产 `1`，场景-资产引用 `1`
- 仍需替换：`0`，已引用：`1`
- Resource types: `{"CompressedTexture2D": 1}`
- Risks: `{"already_referenced_reference_only": 1}`
- 场景：`scenes/dev/imagegen_asset_gallery.tscn`
- 资产：`style_board_global_ai01`
- 验证：godot --headless --path . --import | Run the closest focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 01. `batch_01_ui_shell` - Demo 壳 UI

- 状态：`planned_manual_replacement`
- 目的：把 DemoShell 主菜单、暂停、重开和完成反馈相关 UI 资源作为一个可复核的 UI 壳批次处理。
- 范围：场景 `1`，唯一资产 `9`，场景-资产引用 `9`
- 仍需替换：`5`，已引用：`4`
- Resource types: `{"AtlasTexture": 2, "CompressedTexture2D": 6, "StyleBoxTexture": 1}`
- Risks: `{"already_referenced_reference_only": 8, "requires_runtime_review": 1}`
- 场景：`scenes/ui/demo_shell.tscn`
- 资产：`hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage14_ability_status_hud_ai01`, `stage15_boss_hud_frame_ai01`, `stage16_alpha_demo_completion_ai01`, `stage16_completion_panel_ui_ai01`, `stage16_demo_menu_icons_ai01`, `stage16_pause_panel_ui_ai01`
- 验证：godot --headless --path . --import | Run DemoShell / Stage16 UI focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 02. `batch_02_hud` - 教程 HUD

- 状态：`planned_manual_replacement`
- 目的：把 HUD 图标、能力状态和反馈资源从菜单壳中拆出来单独替换和验证。
- 范围：场景 `1`，唯一资产 `7`，场景-资产引用 `7`
- 仍需替换：`1`，已引用：`6`
- Resource types: `{"AtlasTexture": 2, "CompressedTexture2D": 5}`
- Risks: `{"already_referenced_reference_only": 7}`
- 场景：`scenes/ui/tutorial_hud.tscn`
- 资产：`hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `stage14_ability_status_hud_ai01`, `stage14_air_dash_icon_ai01`, `stage15_boss_hud_frame_ai01`, `stage15_recovery_charge_icon_ai01`, `stage16_demo_menu_icons_ai01`
- 验证：godot --headless --path . --import | Run HUD and closest Stage14 / Stage15 / Stage16 focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 03. `batch_03_player` - 玩家读值与动画

- 状态：`blocked_by_family_polish`
- 目的：在帧序、pivot 和脚底基线复核后，替换 Luna 运行时贴图与 SpriteFrames。
- 范围：场景 `1`，唯一资产 `11`，场景-资产引用 `11`
- 仍需替换：`2`，已引用：`9`
- Resource types: `{"CompressedTexture2D": 2, "SpriteFrames": 9}`
- Risks: `{"already_referenced_reference_only": 2, "blocked_by_family_polish": 1, "requires_runtime_review": 8}`
- 场景：`scenes/player/player_placeholder.tscn`
- 资产：`enemies_core_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_hit_death_sheet_ai01`, `luna_idle_sheet_ai01`, `luna_jump_fall_sheet_ai01`, `luna_run_sheet_ai01`, `seal_guardian_boss_sheet_ai01`, `stage14_air_dash_trail_ai01`, `stage16_luna_player_readability_ai01`, `vfx_seal_magic_atlas_ai01`
- 验证：godot --headless --path . --import | Run player movement / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 04. `batch_04_boss_core` - Seal Guardian Boss 核心

- 状态：`blocked_by_family_polish`
- 目的：把 Seal Guardian Boss、本体预警和 Boss 房间读值资源放在同一批次替换。
- 范围：场景 `2`，唯一资产 `11`，场景-资产引用 `13`
- 仍需替换：`7`，已引用：`6`
- Resource types: `{"CompressedTexture2D": 4, "SpriteFrames": 9}`
- Risks: `{"already_referenced_reference_only": 4, "blocked_by_family_polish": 1, "requires_runtime_review": 8}`
- 场景：`scenes/enemies/seal_guardian_boss.tscn`, `scenes/rooms/stage15_seal_guardian_boss_room.tscn`
- 资产：`enemies_core_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_hit_death_sheet_ai01`, `luna_idle_sheet_ai01`, `luna_jump_fall_sheet_ai01`, `luna_run_sheet_ai01`, `seal_guardian_boss_sheet_ai01`, `stage15_boss_attack_warning_ai01`, `stage15_seal_guardian_ai01`, `vfx_seal_magic_atlas_ai01`
- 验证：godot --headless --path . --import | Run Stage15 Seal Guardian focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report | Run Stage15 focused GUT and boss room manual review after real replacement.

### 05. `batch_05_stage14_air_dash` - Stage14 Air Dash 房间

- 状态：`blocked_by_family_polish`
- 目的：替换 Stage14 能力循环中的 Air Dash shrine、gate、trail 和能力读值道具。
- 范围：场景 `2`，唯一资产 `4`，场景-资产引用 `6`
- 仍需替换：`0`，已引用：`6`
- Resource types: `{"CompressedTexture2D": 5, "TileSet": 1}`
- Risks: `{"already_referenced_reference_only": 5, "blocked_by_family_polish": 1}`
- 场景：`scenes/rooms/stage14_air_dash_shrine_room.tscn`, `scenes/rooms/stage14_air_dash_gate_room.tscn`
- 资产：`miasma_marsh_tileset_ai01`, `stage14_air_dash_gate_ai01`, `stage14_air_dash_shrine_ai01`, `stage14_air_dash_trail_ai01`
- 验证：godot --headless --path . --import | Run Stage14 focused GUT and manual Air Dash room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 06. `batch_06_stage16_end_chain` - Stage16 终局链路

- 状态：`reference_only_already_bound`
- 目的：把 Alpha Demo 终点、talisman relay 和 corruption purge 资源作为终局流程反馈批次处理。
- 范围：场景 `4`，唯一资产 `3`，场景-资产引用 `4`
- 仍需替换：`0`，已引用：`4`
- Resource types: `{"CompressedTexture2D": 4}`
- Risks: `{"already_referenced_reference_only": 4}`
- 场景：`scenes/rooms/stage16_seal_release_threshold_room.tscn`, `scenes/rooms/stage16_alpha_demo_end_room.tscn`, `scenes/rooms/stage16_talisman_relay_room.tscn`, `scenes/rooms/stage16_corruption_purge_room.tscn`
- 资产：`stage16_alpha_demo_completion_ai01`, `stage16_seal_release_threshold_ai01`, `stage16_talisman_relay_ai01`
- 验证：godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 07. `batch_07_stage13_tileset` - Stage13 TileSet 房间

- 状态：`blocked_by_family_polish`
- 目的：在 tile 碰撞、危险区域和读值复核后，再单独替换瘴泽 TileSet。
- 范围：场景 `1`，唯一资产 `1`，场景-资产引用 `1`
- 仍需替换：`0`，已引用：`1`
- Resource types: `{"TileSet": 1}`
- Risks: `{"blocked_by_family_polish": 1}`
- 场景：`scenes/rooms/stage13_miasma_marsh_entry_room.tscn`
- 资产：`miasma_marsh_tileset_ai01`
- 验证：godot --headless --path . --import | Run Stage13 / TileSet room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 08. `batch_08_combat_enemy_animation` - 战斗敌人动画

- 状态：`blocked_by_family_polish`
- 目的：等玩家和 Boss 动画复核稳定后，再替换共享战斗敌人动画引用。
- 范围：场景 `1`，唯一资产 `8`，场景-资产引用 `8`
- 仍需替换：`7`，已引用：`1`
- Resource types: `{"SpriteFrames": 8}`
- Risks: `{"blocked_by_family_polish": 1, "requires_runtime_review": 7}`
- 场景：`scenes/combat/basic_melee_enemy.tscn`
- 资产：`enemies_core_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_hit_death_sheet_ai01`, `luna_idle_sheet_ai01`, `luna_jump_fall_sheet_ai01`, `luna_run_sheet_ai01`, `seal_guardian_boss_sheet_ai01`
- 验证：godot --headless --path . --import | Run closest enemy / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report
