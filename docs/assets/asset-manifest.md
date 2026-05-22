# Nano Hunter Asset Manifest

## 使用范围

本清单是 Stage 12 起的资产管线入口，用来记录“需要什么资产、放在哪里、现在是什么状态、来源和授权是否清楚”。当前阶段只做 `规范 + 轻替换`，不把清单扩展成数据库或编辑器插件。

## 状态值

- `needed`：已经确认需求，但尚未有可接入文件。
- `placeholder_ready`：已有占位或临时样例，可用于验证路径和可读性。
- `integrated`：已经接入当前 demo，并通过自动化或人工复核确认没有破坏流程。
- `deferred`：保留需求，但不进入当前阶段。

## 批次字段约定

Stage 16 之后的 AI 与外部资产生产额外记录 `Batch ID`。批次定义保存在 `asset-production-roadmap.md`：

- `Batch 00`：风格锁定。
- `Batch 01`：P0 玩法可读资产。
- `Batch 02`：Stage16 UI 与终局反馈。
- `Batch 03`：区域表现资产。
- `Batch 04`：音频资产。
- `Batch 05`：动画参考与宣传素材。

## 资产条目

| 资产 ID | 用途 | 目标路径 | 尺寸 / 规格 | 来源 | 授权状态 | 当前状态 | 接入阶段 | 替换优先级 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| stage12_player_silhouette | 玩家轮廓可读性样例 | `assets/art/characters/player/stage12_player_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 保留现有碰撞，场景内额外接入 `Stage12Silhouette` 与 `Stage12HelmetMark` |
| stage12_basic_melee_silhouette | 基础近战敌轮廓区分 | `assets/art/characters/enemies/stage12_basic_melee_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调近战威胁，不改变敌人 AI / Hurtbox |
| stage12_ground_charger_silhouette | 地面冲锋敌轮廓区分 | `assets/art/characters/enemies/stage12_ground_charger_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调尖锐和地面冲刺方向，不改变碰撞 |
| stage12_aerial_sentinel_silhouette | 空中哨兵轮廓区分 | `assets/art/characters/enemies/stage12_aerial_sentinel_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调悬浮空中威胁，不改变出生高度 |
| stage12_slash_vfx | 攻击 slash 最小表现 | `assets/art/vfx/stage12_slash_vfx.svg` | 64x32 SVG，占位 VFX | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P1 | 接入玩家 `Stage12SlashPreview`，只做攻击可读性，不参与判定 |
| stage12_hit_spark_vfx | 命中 spark 最小表现 | `assets/art/vfx/stage12_hit_spark_vfx.svg` | 48x48 SVG，占位 VFX | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P1 | 接入三类敌人的 `Stage12HitSpark`，只做受击可读性，不改变击败契约 |
| stage12_checkpoint_gate_goal_icons | checkpoint / 门控 / 终点提示图形 | `assets/art/ui/stage12_checkpoint_gate_goal_icons.svg` | 96x32 SVG，占位图标组 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | HUD 与终点房使用同一套视觉语义：生命、冲刺、目标 |
| stage12_shrine_trial_biome_reference | 第一区域镇妖试炼场环境参考 | `assets/art/environment/biome_01_shrine_trial/.gitkeep` | 目录占位 | To source | License pending | needed | Stage 13+ | P2 | Stage 12 只建立目录，不提前生产完整环境资产 |
| stage13_miasma_marsh_biome_reference | 瘴泽妖域环境主题参考 | `assets/art/environment/biome_02_miasma_marsh/` | 目录与 SVG 占位资产 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 第二小区域主题入口，地形、背景和装饰资产默认投放到该主题目录 |
| stage13_miasma_marsh_tiles | 腐瘴地面 / 平台可读性资产 | `assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_tiles_01.svg` | SVG 占位 tile，兼容当前灰盒平台尺寸 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 服务平台边界和腐瘴区域的碰撞可读性 |
| stage13_miasma_marsh_background | 瘴泽妖域背景层 | `assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_background_01.svg` | SVG 占位背景层，不干扰平台和敌人读值 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P1 | 第一轮占位背景，后续可替换为正式背景 |
| stage13_seal_gate | 封印门控视觉 | `assets/art/props/stage13_seal_gate_01.svg` | SVG 占位装置，表达关闭 / 开启状态 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 对应 Stage 13 新门控，不扩成正式钥匙系统 |
| stage13_seal_node | 镇妖印节点视觉 | `assets/art/props/stage13_seal_node_01.svg` | SVG 占位节点，表达可触发状态 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 用于封印门控解除条件 |
| stage13_miasma_caster_silhouette | 瘴气妖术投射者轮廓 | `assets/art/characters/enemies/stage13_miasma_caster_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 第 4 类敌人，需与近战、冲锋、空中敌轮廓明显区分 |
| stage13_miasma_hazard_warning | 腐瘴危险提示 | `assets/art/vfx/stage13_miasma_hazard_warning_01.svg` | SVG 占位警示，不改变碰撞边界 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 用于腐瘴池 / 瘴气地形的危险可读性 |
| stage13_miasma_marsh_goal_device | 第二小区域终点装置 | `assets/art/props/stage13_miasma_marsh_goal_device_01.svg` | SVG 占位终点装置，表达区域完成和 Stage 14 前置诱因 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P1 | 终点房承接 Stage 14 回溯能力前置，但 Stage 13 不发放新能力 |
| stage14_air_dash_icon | 空中二段冲刺 HUD 图标 | `assets/art/ui/stage14_air_dash_icon.svg` | 32x32 SVG，占位能力图标 | 项目内临时绘制 | 项目自有占位 | needed | Stage 14 | P0 | HUD 需要表达空中冲刺已解锁与本次空中是否可用 |
| stage14_air_dash_shrine | 空中冲刺能力获得装置 | `assets/art/props/stage14_air_dash_shrine_01.svg` | SVG 占位装置，表达能力获取点 | 项目内临时绘制 | 项目自有占位 | needed | Stage 14 | P0 | 能力获得房的第一眼视觉焦点，后续需回归符印 / 佛门机关方向 |
| stage14_air_dash_gate | 空中冲刺门控提示 | `assets/art/props/stage14_air_dash_gate_01.svg` | SVG 占位门控，表达锁定 / 可通过状态 | 项目内临时绘制 | 项目自有占位 | needed | Stage 14 | P0 | 用于第一条能力门控，不扩展为通用钥匙系统 |
| stage14_backtrack_reward_marker | 回溯收益点标记 | `assets/art/props/stage14_backtrack_reward_marker_01.svg` | SVG 占位奖励标记 | 项目内临时绘制 | 项目自有占位 | needed | Stage 14 | P0 | 至少 3 个旧区回溯收益点共享同一临时视觉语义 |
| stage12_demo_sfx_pack | Demo 最小音效包 | `assets/audio/sfx/.gitkeep` | Short OGG/WAV cues, exact list defined by audio batch | To source | License pending | deferred | Stage 16 | P2 | 不进入 Stage 12 实现 |
| stage12_demo_music_loop | Demo 最小 BGM 循环 | `assets/audio/music/.gitkeep` | 30-90 second OGG loop, final duration defined by audio batch | To source | License pending | deferred | Stage 16 | P3 | 不进入 Stage 12 实现 |

## 维护规则

- 新区域、新敌人、新能力、新 UI 或 Boss 需求默认追加到本清单，不重新创建另一套资产规划。
- 使用外部免费、购买、AI 生成或正式项目资产前，必须补齐来源与授权状态。
- 如果资产会改变碰撞、判定或玩家误读边界，必须先进入 `asset-ingestion-checklist.md` 做接入复核。
## Stage 15 placeholder requests

| Asset ID | Purpose | Target path | Size / spec | Source | License | Status | Stage | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| stage15_seal_guardian_silhouette | Seal Guardian Boss silhouette | `assets/art/characters/bosses/stage15_seal_guardian_silhouette.svg` | 128x128 SVG placeholder, readable large-body boss shape | Project placeholder | Project-owned placeholder | needed | Stage 15 | P0 | First elite boss prototype; later repaint toward sealed Buddhist guardian / corrupted ward style |
| stage15_boss_attack_warning | Boss attack warning VFX | `assets/art/vfx/stage15_boss_attack_warning.svg` | SVG warning arcs and floor shock marks | Project placeholder | Project-owned placeholder | needed | Stage 15 | P0 | Supports melee pressure, ground impact, and anti-air punishment readability |
| stage15_boss_hud_status | Boss HUD status strip | `assets/art/ui/stage15_boss_hud_status.svg` | HUD frame / status glyph placeholder | Project placeholder | Project-owned placeholder | needed | Stage 15 | P0 | Must coexist with Stage14 Air Dash and backtracking reward HUD lines |
| stage15_recovery_charge_icon | Recovery Charge HUD icon | `assets/art/ui/stage15_recovery_charge_icon.svg` | 32x32 SVG icon placeholder | Project placeholder | Project-owned placeholder | needed | Stage 15 | P0 | Communicates hit-earned heal charge readiness without becoming a formal resource economy |
| stage15_seal_gate_room_props | Boss room seal mechanism props | `assets/art/props/stage15_seal_gate_room_props.svg` | SVG room prop pack placeholder | Project placeholder | Project-owned placeholder | needed | Stage 15 | P1 | Boss room seal pillars, locked exit hint, and victory-release visual pass |

## Stage 16 Alpha Demo candidate requests

| Asset ID | Purpose | Target path | Size / spec | Source | License | Status | Stage | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| stage16_seal_release_threshold | Stage16 seal release threshold props | `assets/art/props/stage16_seal_release_threshold.svg` | SVG placeholder prop pack for cracked seal pillar and ward chains | Project placeholder | Project-owned placeholder | placeholder_ready | Stage 16 | P0 | Current scene uses Polygon2D graybox nodes; later repaint toward Buddhist ward / sealed demon ruin style |
| stage16_talisman_relay | Stage16 talisman relay VFX | `assets/art/vfx/stage16_talisman_relay.svg` | SVG placeholder relay glyphs and activation light paths | Project placeholder | Project-owned placeholder | placeholder_ready | Stage 16 | P0 | Supports Air Dash confirmation without introducing a new ability |
| stage16_backtrack_confirmation | Stage16 backtrack confirmation marker | `assets/art/props/stage16_backtrack_confirmation.svg` | SVG marker for reward tally and seal-chain confirmation | Project placeholder | Project-owned placeholder | placeholder_ready | Stage 16 | P0 | Shows Stage14 backtracking value before Alpha Demo end |
| stage16_corruption_purge | Stage16 corruption purge VFX | `assets/art/vfx/stage16_corruption_purge.svg` | SVG placeholder purge pulse and miasma fade | Project placeholder | Project-owned placeholder | placeholder_ready | Stage 16 | P1 | Reframes Stage13 bio-waste / acid language as 妖瘴 and seal leakage |
| stage16_alpha_demo_completion | Stage16 Alpha Demo completion UI | `assets/art/ui/stage16_alpha_demo_completion.svg` | HUD / completion room placeholder glyph | Project placeholder | Project-owned placeholder | placeholder_ready | Stage 16 | P0 | Used by final completion room and release candidate feedback |
| stage16_demo_sfx_pack | Stage16 minimal SFX pack | `assets/audio/sfx/stage16_demo_sfx_pack/` | Seal crack, talisman relay, purge, complete cues | To source | License pending | needed | Stage 16 | P1 | Minimum audio scope; not a full audio system |
| stage16_minimal_bgm | Stage16 minimal BGM loop | `assets/audio/music/stage16_minimal_bgm.ogg` | Seamless short OGG loop, final duration defined by audio batch | To source | License pending | needed | Stage 16 | P2 | Records BGM need for Alpha Demo release notes |

## Asset Production Track - Batch 00-05 Requests

| Batch ID | Asset ID | Purpose | Target path | Size / spec | Source | License | Status | Stage link | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Batch 00 | batch00_luna_style_board | Luna style lock board | `assets/source/ai_generated/batch_00/batch00_luna_style_board_candidate_01.png` | Concept board, source-only | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage16 asset line | P0 | Source-only style reference; do not wire into Godot |
| Batch 00 | batch00_talisman_visual_language | Buddhist talisman / demon-suppressing bureau visual language | `assets/source/ai_generated/batch_00/batch00_talisman_visual_language_candidate_01.png` | Concept board, source-only | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage16 asset line | P0 | Defines seal shapes, cyan-white glow, vermilion accents |
| Batch 00 | batch00_miasma_marsh_palette | Miasma marsh palette and mood board | `assets/source/ai_generated/batch_00/batch00_miasma_marsh_palette_candidate_01.png` | Concept board, source-only | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage16 asset line | P1 | Supports later biome replacements |
| Batch 00 | batch00_seal_guardian_style | Seal Guardian visual direction | `assets/source/ai_generated/batch_00/batch00_seal_guardian_style_candidate_01.png` | Concept board, source-only | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage15-16 polish | P0 | Source-only until Boss replacement scope is approved |
| Batch 01 | stage16_luna_player_readability_ai01 | Luna readable player concept | `assets/art/characters/player/stage16_luna_player_readability_ai01.png` | 128x128 PNG, transparent background | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage16 polish | P0 | Must not imply a collision size change |
| Batch 01 | stage14_air_dash_icon_ai01 | Air Dash HUD icon | `assets/art/ui/stage14_air_dash_icon_ai01.png` | 64x64 PNG, transparent background | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage14-16 polish | P0 | Must remain readable at 32x32 |
| Batch 01 | stage14_air_dash_trail_ai01 | Air Dash VFX trail | `assets/art/vfx/stage14_air_dash_trail_ai01.png` | 128x64 PNG or short strip, transparent background | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage14-16 polish | P0 | Visual-only; must not participate in collision |
| Batch 01 | stage14_air_dash_shrine_ai01 | Air Dash ability shrine | `assets/art/props/stage14_air_dash_shrine_ai01.png` | 192x128 PNG, transparent background | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage14-16 polish | P0 | Must support inactive / active / claimed state variants later |
| Batch 01 | stage14_air_dash_gate_ai01 | Air Dash gate prop | `assets/art/props/stage14_air_dash_gate_ai01.png` | 160x160 PNG, transparent background | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage14-16 polish | P0 | Must not alter traversal contract |
| Batch 01 | stage15_seal_guardian_ai01 | Seal Guardian Boss readable concept | `assets/art/characters/bosses/stage15_seal_guardian_ai01.png` | 192x192 PNG, transparent background | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage15-16 polish | P0 | Must preserve boss room readability |
| Batch 01 | stage15_boss_attack_warning_ai01 | Boss attack warning VFX | `assets/art/vfx/stage15_boss_attack_warning_ai01.png` | 128x64 PNG, transparent background | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage15-16 polish | P0 | Telegraph must be high contrast |
| Batch 01 | stage15_recovery_charge_icon_ai01 | Recovery Charge HUD icon | `assets/art/ui/stage15_recovery_charge_icon_ai01.png` | 64x64 PNG, transparent background | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage15-16 polish | P0 | Must not read as modern medical cross or battery |
| Batch 02 | stage16_title_background_ai01 | Alpha Demo title background | `assets/art/ui/stage16_title_background_ai01.png` | 1280x720 or 640x360 PNG | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage16 UI polish | P1 | No title text baked into image |
| Batch 02 | stage16_demo_menu_icons_ai01 | Pause / restart / completion icon set | `assets/art/ui/stage16_demo_menu_icons_ai01.png` | 32x32 or 64x64 icon sheet | To generate: Nano Banana / Gemini Image, cleaned in Inkscape / Krita | License pending - tool terms must be recorded before integration | needed | Stage16 UI polish | P0 | May later be converted to SVG |
| Batch 02 | stage16_seal_release_threshold_ai01 | Final seal threshold visual pass | `assets/art/props/stage16_seal_release_threshold_ai01.png` | 192x128 PNG, transparent background | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage16 completion polish | P0 | Replaces graybox seal pillar direction |
| Batch 02 | stage16_talisman_relay_ai01 | Talisman relay VFX visual pass | `assets/art/vfx/stage16_talisman_relay_ai01.png` | 128x64 PNG or short strip | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage16 completion polish | P0 | Confirms Air Dash without adding ability |
| Batch 02 | stage16_corruption_purge_ai01 | Corruption purge VFX visual pass | `assets/art/vfx/stage16_corruption_purge_ai01.png` | 128x128 PNG or short strip | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage16 completion polish | P1 | Reframes miasma language away from sci-fi |
| Batch 02 | stage16_alpha_demo_completion_ai01 | Alpha Demo completion UI | `assets/art/ui/stage16_alpha_demo_completion_ai01.png` | HUD / completion glyph, transparent background | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage16 completion polish | P0 | No baked final marketing text |
| Batch 03 | biome01_shrine_trial_tiles_ai01 | Shrine trial platform / tile visual pass | `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_tiles_ai01.png` | Tile sheet, exact cell size determined by integration target | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage13-16 visual pass | P1 | Platform edges must remain readable |
| Batch 03 | biome01_shrine_trial_background_ai01 | Shrine trial background layer | `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_background_ai01.png` | 640x360 or layered PNG | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage13-16 visual pass | P2 | Background must not overpower gameplay |
| Batch 03 | biome02_miasma_marsh_tiles_ai01 | Miasma marsh platform / hazard tile visual pass | `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_tiles_ai01.png` | Tile sheet, exact cell size determined by integration target | To generate: Image2 + Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage13-16 visual pass | P1 | Hazard color must remain distinct |
| Batch 03 | biome02_miasma_marsh_background_ai01 | Miasma marsh background layer | `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_background_ai01.png` | 640x360 or layered PNG | To generate: Image2 / GPT Image | License pending - tool terms must be recorded before integration | needed | Stage13-16 visual pass | P2 | Avoid modern lab or biotech shapes |
| Batch 03 | reusable_seal_props_ai01 | Reusable seal props pack | `assets/art/props/reusable_seal_props_ai01.png` | Prop sheet, transparent background | To generate: Nano Banana / Gemini Image | License pending - tool terms must be recorded before integration | needed | Stage13-16 visual pass | P1 | Stone lamps, talisman stakes, shrine fragments |
| Batch 04 | sfx_talisman_cast_ai01 | Talisman cast SFX | `assets/audio/sfx/stage16_demo_sfx_pack/sfx_talisman_cast_ai01.ogg` | Short OGG, under 1 second | To generate: ElevenLabs, edited in Audacity / Reaper | License pending - tool terms must be recorded before integration | needed | Stage16 audio pass | P0 | No voice or long reverb tail |
| Batch 04 | sfx_seal_gate_open_ai01 | Seal gate open SFX | `assets/audio/sfx/stage16_demo_sfx_pack/sfx_seal_gate_open_ai01.ogg` | Short OGG, loopless | To generate: ElevenLabs, edited in Audacity / Reaper | License pending - tool terms must be recorded before integration | needed | Stage16 audio pass | P0 | Must not mask combat feedback |
| Batch 04 | sfx_boss_warning_ai01 | Boss warning SFX | `assets/audio/sfx/stage16_demo_sfx_pack/sfx_boss_warning_ai01.ogg` | Short OGG, loopless | To generate: ElevenLabs, edited in Audacity / Reaper | License pending - tool terms must be recorded before integration | needed | Stage15-16 audio pass | P0 | Should read as warning cue |
| Batch 04 | stage16_minimal_bgm_ai01 | Alpha Demo minimal BGM loop | `assets/audio/music/stage16_minimal_bgm_ai01.ogg` | 30-90 second loop | To generate: Suno / Lyria 3, edited in Audacity / Reaper | License pending - tool terms must be recorded before integration | needed | Stage16 audio pass | P1 | No vocals, no modern EDM lead |
| Batch 05 | animref_luna_air_dash_ai01 | Luna Air Dash animation reference | `assets/source/ai_generated/batch_05/animref_luna_air_dash_ai01.mp4` | Video reference, source-only | To generate: Seedance 2 / Veo 3.1 | License pending - tool terms must be recorded before integration | needed | Future animation pass | P2 | Reference only; do not import as sprite animation |
| Batch 05 | animref_seal_guardian_attack_ai01 | Seal Guardian attack animation reference | `assets/source/ai_generated/batch_05/animref_seal_guardian_attack_ai01.mp4` | Video reference, source-only | To generate: Seedance 2 / Veo 3.1 | License pending - tool terms must be recorded before integration | needed | Future animation pass | P2 | Reference only; derive keyframes manually |
| Batch 05 | trailer_alpha_demo_draft_ai01 | Alpha Demo trailer draft | `assets/source/ai_generated/batch_05/trailer_alpha_demo_draft_ai01.mp4` | Video reference, source-only | To generate: Seedance 2 / Veo 3.1 | License pending - tool terms must be recorded before integration | deferred | Marketing / future | P3 | Not required for playable demo |
