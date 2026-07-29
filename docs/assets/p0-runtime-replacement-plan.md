# P0 Runtime Replacement Plan / P0 运行时替换计划

本计划只覆盖 runtime map 中 priority 为 `P0` 的资产条目，用于关闭 `runtime_replacement` gate 前的执行排程。
它不直接替换场景引用，也不代表 final art 已批准。

## Summary

- P0 runtime entries：`11`
- 仍需手动替换：`0`
- 当前已被目标场景引用：`11`
- 缺失资源：`0`
- 缺失目标场景：`0`

## Entries

- [ ] `stage14_air_dash_trail_ai01` (runtime_vfx / vfx_direction / CompressedTexture2D)
  - Target system: Air Dash VFX direction replacement
  - Resource: `res://assets/art/vfx/stage14_air_dash_trail_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/player/player_placeholder.tscn`, `scenes/rooms/stage14_air_dash_shrine_room.tscn`
- [ ] `hud_core_ui_atlas_ai01` (runtime_ui / ui_atlas / AtlasTexture)
  - Target system: HUD/menu atlas replacement
  - Resource: `res://assets/art/editor_resources/hud_core_ui_atlas_ai01/000_hud_core_ui_atlas_ai01_auto_001.atlas_texture.tres`
  - Mode: Use the selected AtlasTexture region for TextureRect/Sprite2D after semantic region review.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/ui/tutorial_hud.tscn`
- [ ] `icon_sheet_core_ai01` (runtime_ui / icon_sheet / AtlasTexture)
  - Target system: menu/HUD icon atlas replacement
  - Resource: `res://assets/art/editor_resources/icon_sheet_core_ai01/000_icon_sheet_core_ai01_auto_001_c01.atlas_texture.tres`
  - Mode: Use the selected AtlasTexture region for TextureRect/Sprite2D after semantic region review.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/ui/tutorial_hud.tscn`
- [ ] `menu_ninepatch_ui_ai01` (runtime_ui / ninepatch_sheet / StyleBoxTexture)
  - Target system: menu/panel NinePatch theme replacement
  - Resource: `res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres`
  - Mode: Apply through Theme or add_theme_stylebox_override after NinePatch margin and stretch review.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/ui/tutorial_hud.tscn`
- [ ] `vfx_seal_magic_atlas_ai01` (runtime_vfx / vfx_atlas / SpriteFrames)
  - Target system: VFX atlas animation replacement
  - Resource: `res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres`
  - Mode: Assign to AnimatedSprite2D.sprite_frames after animation clip, fps and frame order review.
  - Status: `already_referenced`
  - Target scenes: `scenes/player/player_placeholder.tscn`, `scenes/enemies/seal_guardian_boss.tscn`, `scenes/rooms/stage15_seal_pressure_room.tscn`
- [ ] `stage16_demo_menu_icons_ai01` (runtime_ui / icon_sheet / CompressedTexture2D)
  - Target system: menu/HUD icon atlas replacement
  - Resource: `res://assets/art/ui/stage16_demo_menu_icons_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/ui/tutorial_hud.tscn`
- [ ] `stage16_seal_release_threshold_ai01` (runtime_gameplay / prop / CompressedTexture2D)
  - Target system: room prop visual replacement
  - Resource: `res://assets/art/props/stage16_seal_release_threshold_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/rooms/stage16_seal_release_threshold_room.tscn`, `scenes/rooms/stage15_completion_room.tscn`, `scenes/rooms/stage16_backtrack_confirmation_room.tscn`
- [ ] `stage16_talisman_relay_ai01` (runtime_vfx / vfx_sheet / CompressedTexture2D)
  - Target system: room progression VFX replacement
  - Resource: `res://assets/art/vfx/stage16_talisman_relay_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/rooms/stage16_talisman_relay_room.tscn`, `scenes/rooms/stage16_corruption_purge_room.tscn`
- [ ] `stage16_alpha_demo_completion_ai01` (runtime_ui / completion_ui / CompressedTexture2D)
  - Target system: Alpha Demo completion feedback
  - Resource: `res://assets/art/ui/stage16_alpha_demo_completion_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/rooms/stage16_alpha_demo_end_room.tscn`
- [ ] `stage16_pause_panel_ui_ai01` (runtime_ui / ui_panel / CompressedTexture2D)
  - Target system: pause/completion panel replacement
  - Resource: `res://assets/art/ui/stage16_pause_panel_ui_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`
- [ ] `stage16_completion_panel_ui_ai01` (runtime_ui / ui_panel / CompressedTexture2D)
  - Target system: pause/completion panel replacement
  - Resource: `res://assets/art/ui/stage16_completion_panel_ui_ai01.png`
  - Mode: Texture2D direct reference; use Sprite2D.texture, TextureRect.texture, or exported Texture2D on a target script.
  - Status: `already_referenced`
  - Target scenes: `scenes/ui/demo_shell.tscn`, `scenes/rooms/stage16_alpha_demo_end_room.tscn`
