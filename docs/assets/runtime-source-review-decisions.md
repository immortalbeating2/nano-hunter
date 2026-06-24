# Runtime Source Review Decisions

This document records cleanup-only visual decisions for runtime-bound image_gen assets.

## Summary

- Decision count: `18`
- Confirmed for cleanup: `18`
- Regenerate before cleanup: `0`
- Reject: `0`
- Defer: `0`
- Final ready: `0`

## Decisions

### `luna_run_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `p0-final-batch-02-stage16-alpha-demo-completion`
- Visual conclusion: 当前输出与候选 01/02 风格统一，符合 Luna 镇妖卫剪影和青白符印动势，可继续作为跑步动画清稿基础。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review`

### `luna_air_dash_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: Air Dash 方向、残影和符印速度感可读，未见明显外项目混入；可继续清稿并对齐 Luna 跑跳体型。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review, dash_trail_readability_review`

### `luna_attack_01_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 攻击挥砍与青白符印弧光方向成立，候选适合继续做第一段攻击动作清稿。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review, attack_arc_readability_review`

### `luna_idle_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 待机姿态保持 Luna 方向稿气质，适合作为正式 idle 清稿基础；需要统一帧尺寸和呼吸节奏。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review`

### `seal_guardian_boss_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: Seal Guardian 体型、甲壳 / 石兽质感和符印核心可读，适合继续做 Boss preview 动画清稿。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, boss_readability_and_camera_scale_review, animation_timing_manual_review`

### `icon_sheet_core_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_compare_selected_mix`
- Preferred output: `assets/art/ui/atlases/icon_sheet_core_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 核心图标的青白符印、门控、能量与系统反馈语义整体可用；小尺寸读值需要逐 icon 复核。
- Required cleanup: `small_size_readability_review, semantic_labels_manual_review, alpha_padding_policy_manual_review`

### `menu_ninepatch_ui_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_compare_selected_mix`
- Preferred output: `assets/art/ui/menu_ninepatch_ui_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 菜单边框和面板装饰符合青黑金 UI 方向，可继续做 NinePatch / StyleBoxTexture 收口。
- Required cleanup: `final_ninepatch_margin_manual_review, stretch_distortion_manual_review, theme_mapping_manual_review, text_safe_area_manual_review`

### `vfx_seal_magic_atlas_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png`
- Preferred candidates: `[1, 2]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 封印 VFX 图集方向明确，符环、能量爆发和 UI-like seal 反馈可用；需要处理透明边缘和 anchor。
- Required cleanup: `mask_and_blend_manual_review, anchor_manual_review, semantic_labels_manual_review, runtime_contrast_review`

### `stage16_demo_menu_icons_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage16_demo_menu_icons_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 当前输出的开始、重开、返回和暂停图标语义清楚，风格归属 Nano Hunter；candidate 03 可作为后续替换参考。
- Required cleanup: `small_size_readability_review, semantic_labels_manual_review, alpha_padding_policy_manual_review`

### `stage16_talisman_relay_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/vfx/stage16_talisman_relay_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 当前输出适合做 talisman relay 的静态 / 分段 VFX 基础；candidate 02 可作为后续长链路 relay 动效参考。
- Required cleanup: `mask_and_blend_manual_review, anchor_manual_review, runtime_contrast_review`

### `stage16_alpha_demo_completion_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage16_alpha_demo_completion_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 当前 completion UI 构图清楚，符印核心和横向文本板适合进入完成反馈布局复核。
- Required cleanup: `runtime_layout_manual_review, text_safe_area_manual_review, pseudo_text_cleanup`

### `stage16_pause_panel_ui_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage16_pause_panel_ui_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 当前 pause panel 具备大面板和按钮条，适合 DemoShell 暂停 UI 的 text-safe area / 九宫格复核。
- Required cleanup: `runtime_layout_manual_review, text_safe_area_manual_review, theme_mapping_manual_review`

### `stage16_completion_panel_ui_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage16_completion_panel_ui_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: 当前 completion panel 装饰强、中心留白足，适合完成面板清稿和安全区复核。
- Required cleanup: `runtime_layout_manual_review, text_safe_area_manual_review, pseudo_text_cleanup`

### `stage15_boss_hud_frame_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage15_boss_hud_frame_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: Boss HUD frame 横向结构明确，适合继续映射到 TutorialHUD / Boss HUD preview；需要小尺寸和血条安全区复核。
- Required cleanup: `runtime_layout_manual_review, small_size_readability_review, theme_mapping_manual_review`

### `stage14_ability_status_hud_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/ui/stage14_ability_status_hud_ai01.png`
- Preferred candidates: `[1]`
- Runtime action: `retain_current_preview_until_cleaned_rebuild`
- Later finalization record: `none`
- Visual conclusion: Ability status HUD 的冲刺、能量、状态图标可读，适合进入小尺寸切片和 HUD 布局复核。
- Required cleanup: `runtime_layout_manual_review, small_size_readability_review, semantic_labels_manual_review, theme_mapping_manual_review`

### `luna_jump_fall_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `confirmed_candidate_rebuild_candidate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png`
- Preferred candidates: `[7]`
- Runtime action: `retain_current_preview_after_finalization_record`
- Later finalization record: `p0-final-batch-18-luna-jump-fall-sheet`
- Visual conclusion: 跳跃 / 下落动作已在后续 finalization pass 中重建为统一 Luna 镇妖卫体型，帧序、脚点和动作读向可继续作为 Alpha Demo 隐藏预览清稿来源。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review`

### `luna_hit_death_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`
- Preferred candidates: `[5]`
- Runtime action: `retain_current_preview_after_finalization_record`
- Later finalization record: `p0-final-batch-20-luna-hit-death-sheet`
- Visual conclusion: 受击 / 死亡动作已由 candidate 05 重建，Luna 轮廓、青白符印光和南北朝衣装方向统一，可作为 Alpha Demo 隐藏运行时预览来源。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, foot_baseline_and_anchor_manual_review, animation_timing_manual_review, damage_readability_review`

### `enemies_core_sheet_ai01`

- Decision: `confirmed_for_cleanup`
- Strategy: `manual_source_review_or_regenerate`
- Preferred output: `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`
- Preferred candidates: `[6]`
- Runtime action: `retain_current_preview_after_finalization_record`
- Later finalization record: `p0-final-batch-21-enemies-core-sheet`
- Visual conclusion: 核心敌人表已由 candidate 06 重建为 4 行敌人类型、32 帧选源，无错误最终格和大型跨格 VFX，可作为基础敌人隐藏运行时预览来源。
- Required cleanup: `green_key_or_alpha_cleanup, frame_order_manual_review, enemy_row_identity_review, animation_timing_manual_review`
