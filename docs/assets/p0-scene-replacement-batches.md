# P0 Scene Replacement Batches / P0 场景替换批次

本报告把 P0 target scene replacement matrix 拆成可以逐批执行和验证的场景替换顺序。
它不直接修改 `.tscn`，不关闭 `runtime_replacement` gate，也不代表最终美术批准完成。

## Summary

- 批次数：`6`
- 覆盖场景数：`12`
- 唯一资产数：`11`
- 场景-资产引用项：`23`
- 仍需替换项：`6`
- 已引用项：`17`
- 缺失场景数：`0`
- 未分批场景数：`0`
- 被 family polish 阻塞的批次数：`0`

## Batches

### 00. `batch_01_ui_shell` - Demo 壳 UI

- 状态：`planned_manual_replacement`
- 目的：把 DemoShell 主菜单、暂停、重开和完成反馈相关 UI 资源作为一个可复核的 UI 壳批次处理。
- 范围：场景 `1`，唯一资产 `7`，场景-资产引用 `7`
- 仍需替换：`3`，已引用：`4`
- Resource types: `{"AtlasTexture": 2, "CompressedTexture2D": 4, "StyleBoxTexture": 1}`
- Risks: `{"already_referenced_reference_only": 6, "requires_runtime_review": 1}`
- 场景：`scenes/ui/demo_shell.tscn`
- 资产：`hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage16_alpha_demo_completion_ai01`, `stage16_completion_panel_ui_ai01`, `stage16_demo_menu_icons_ai01`, `stage16_pause_panel_ui_ai01`
- 验证：godot --headless --path . --import | Run DemoShell / Stage16 UI focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 01. `batch_02_hud` - 教程 HUD

- 状态：`planned_manual_replacement`
- 目的：把 HUD 图标、能力状态和反馈资源从菜单壳中拆出来单独替换和验证。
- 范围：场景 `1`，唯一资产 `4`，场景-资产引用 `4`
- 仍需替换：`1`，已引用：`3`
- Resource types: `{"AtlasTexture": 2, "CompressedTexture2D": 1, "StyleBoxTexture": 1}`
- Risks: `{"already_referenced_reference_only": 3, "requires_runtime_review": 1}`
- 场景：`scenes/ui/tutorial_hud.tscn`
- 资产：`hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01`, `stage16_demo_menu_icons_ai01`
- 验证：godot --headless --path . --import | Run HUD and closest Stage14 / Stage15 / Stage16 focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 02. `batch_03_player` - 玩家读值与动画

- 状态：`planned_manual_replacement`
- 目的：在帧序、pivot 和脚底基线复核后，替换 Luna 运行时贴图与 SpriteFrames。
- 范围：场景 `1`，唯一资产 `2`，场景-资产引用 `2`
- 仍需替换：`1`，已引用：`1`
- Resource types: `{"CompressedTexture2D": 1, "SpriteFrames": 1}`
- Risks: `{"already_referenced_reference_only": 1, "requires_runtime_review": 1}`
- 场景：`scenes/player/player_placeholder.tscn`
- 资产：`stage14_air_dash_trail_ai01`, `vfx_seal_magic_atlas_ai01`
- 验证：godot --headless --path . --import | Run player movement / combat focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 03. `batch_04_boss_core` - Seal Guardian 与封印压力

- 状态：`planned_manual_replacement`
- 目的：把 Seal Guardian 本体与 Stage15 封印压力符印资源放在同一批次复核。
- 范围：场景 `2`，唯一资产 `1`，场景-资产引用 `2`
- 仍需替换：`1`，已引用：`1`
- Resource types: `{"SpriteFrames": 2}`
- Risks: `{"requires_runtime_review": 2}`
- 场景：`scenes/enemies/seal_guardian_boss.tscn`, `scenes/rooms/stage15_seal_pressure_room.tscn`
- 资产：`vfx_seal_magic_atlas_ai01`
- 验证：godot --headless --path . --import | Run Stage15 Seal Guardian focused GUT after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report | Run Stage15 focused GUT and boss room manual review after real replacement.

### 04. `batch_05_stage14_air_dash` - Stage14 Air Dash 房间

- 状态：`reference_only_already_bound`
- 目的：替换 Stage14 能力循环中的 Air Dash shrine、gate、trail 和能力读值道具。
- 范围：场景 `1`，唯一资产 `1`，场景-资产引用 `1`
- 仍需替换：`0`，已引用：`1`
- Resource types: `{"CompressedTexture2D": 1}`
- Risks: `{"already_referenced_reference_only": 1}`
- 场景：`scenes/rooms/stage14_air_dash_shrine_room.tscn`
- 资产：`stage14_air_dash_trail_ai01`
- 验证：godot --headless --path . --import | Run Stage14 focused GUT and manual Air Dash room review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report

### 05. `batch_06_stage16_end_chain` - Stage16 终局链路

- 状态：`reference_only_already_bound`
- 目的：把阈值释放、Stage15 完成回声、回溯确认、Alpha Demo 终点、relay 和 purge 作为终局反馈批次处理。
- 范围：场景 `6`，唯一资产 `4`，场景-资产引用 `7`
- 仍需替换：`0`，已引用：`7`
- Resource types: `{"CompressedTexture2D": 7}`
- Risks: `{"already_referenced_reference_only": 7}`
- 场景：`scenes/rooms/stage16_seal_release_threshold_room.tscn`, `scenes/rooms/stage15_completion_room.tscn`, `scenes/rooms/stage16_backtrack_confirmation_room.tscn`, `scenes/rooms/stage16_alpha_demo_end_room.tscn`, `scenes/rooms/stage16_talisman_relay_room.tscn`, `scenes/rooms/stage16_corruption_purge_room.tscn`
- 资产：`stage16_alpha_demo_completion_ai01`, `stage16_completion_panel_ui_ai01`, `stage16_seal_release_threshold_ai01`, `stage16_talisman_relay_ai01`
- 验证：godot --headless --path . --import | Run Stage16 focused GUT and Alpha Demo flow review after real replacement. | python scripts\assets\audit_asset_package.py --strict --write-report | Run Stage15 focused GUT and boss room manual review after real replacement.
