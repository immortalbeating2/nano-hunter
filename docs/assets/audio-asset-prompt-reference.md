# Nano Hunter Audio Asset Prompt Reference

Last Updated: 2026-06-27

## 目的

本文件是 Batch 04 音频资产的全量生成参考包，服务 Stage16 Alpha Demo 后续 audio pass，并为 Stage17+ 继续扩展音频资产库预留统一分类、prompt、路径和配置资产入口。它对齐当前美术背景：南北朝东方奇幻、佛门符印、镇妖卫、瘴泽妖域、Seal Guardian、柔和灵光与水墨 / 工笔色系。

本轮只提供高质量 prompt、生成 / 后处理命令、存放地址和验收标准；不直接接入 Godot，不新增完整音频系统。

## 覆盖结论

上一版文档覆盖的是 Stage16 最小音频包，不是全量音频资产。本版已扩展为全量参考口径，覆盖下列资产族：

| 资产族 | 当前文档覆盖 | 首批执行建议 | 目标路径 |
| --- | --- | --- | --- |
| 角色动作音效 | 已覆盖 | P0 | `assets/audio/sfx/characters/player/` |
| 战斗音效 | 已覆盖 | P0 | `assets/audio/sfx/combat/` |
| UI 音效 | 已覆盖 | P1 | `assets/audio/sfx/ui/` |
| 环境音效 / 氛围声 | 已覆盖 | P1 | `assets/audio/ambient/` |
| 物品与交互音效 | 已覆盖 | P0 | `assets/audio/sfx/interactions/` |
| 载具 / 机械音效 | 已覆盖为“机关 / 古代机械”，当前无现代载具 | P2 | `assets/audio/sfx/mechanics/` |
| 怪物 / NPC 音效 | 已覆盖 | P0 | `assets/audio/sfx/characters/enemies/`、`assets/audio/voice/` |
| 音乐资产 BGM | 已覆盖 | P1 | `assets/audio/music/` |
| 语音资产 | 已覆盖为无台词短 vocal 与后续 NPC voice placeholder | P2 | `assets/audio/voice/` |
| 系统反馈音 | 已覆盖 | P1 | `assets/audio/sfx/system/` |
| 音频配置资产 | 已覆盖为配置文件入口，不生成声音 | P1 | `assets/audio/config/` |

边界：`Nano Hunter` 当前世界观没有现代载具和工业机械；该类统一改写为古代机关、石门、木构机括、封印链、升降平台和寺庙机关声，不引入现代引擎、枪械、液压门或科幻设备。

## 总体声音方向

核心听感：

- 古琴、箫、低鼓、铜铃、木鱼、纸符、石门、风息、湿润瘴气。
- Luna 的声音轻、短、克制，偏镇妖卫与佛门符印能量，不做现代科幻冲击。
- 妖域和 Seal Guardian 偏低频、石质、兽性、封印裂响，不做血腥恐怖。
- UI 和完成反馈使用朱砂印、竹简、铜铃、法阵轻脉冲，不用现代按钮 beep。

全局负向约束：

```text
no modern sci-fi laser, no cyberpunk synth lead, no EDM drop, no gun, no explosion blockbuster, no English speech, no spoken words, no pop vocal, no horror scream, no gore, no comedy cartoon, no overly long cinematic tail, no distorted clipping, no background music in one-shot SFX
```

## 输出与路径规则

| 类型 | 原始候选路径 | 可接入路径 | 推荐规格 |
| --- | --- | --- | --- |
| SFX | `assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav` | `assets/audio/sfx/stage16_demo_sfx_pack/<asset_id>_ai01.ogg` | 48 kHz，mono 或 narrow stereo，0.2-2.5 秒 |
| Voice / monster | `assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav` | `assets/audio/sfx/stage16_demo_voice_pack/<asset_id>_ai01.ogg` | 48 kHz，mono，0.2-1.5 秒 |
| Ambient loop | `assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav` | `assets/audio/music/<asset_id>_ai01.ogg` | 48 kHz，stereo，30-90 秒，无缝 loop |
| BGM loop | `assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav` | `assets/audio/music/<asset_id>_ai01.ogg` | 48 kHz，stereo，45-90 秒，无缝 loop |
| Audio config | `docs/assets/audio-asset-prompt-reference.md` | `assets/audio/config/<config_id>.json` | 事件名、bus、音量、随机变体、冷却、优先级 |

命名原则：`stage16_<用途>_<动作或对象>_sfx_ai01`，同一资产变体使用 `_var01`、`_var02`、`_var03`。

## 通用执行命令

先建目录：

```powershell
New-Item -ItemType Directory -Force `
  assets/source/ai_generated/batch_04/audio `
  assets/audio/sfx/stage16_demo_sfx_pack `
  assets/audio/sfx/stage16_demo_voice_pack `
  assets/audio/sfx/characters/player `
  assets/audio/sfx/characters/enemies `
  assets/audio/sfx/combat `
  assets/audio/sfx/ui `
  assets/audio/sfx/interactions `
  assets/audio/sfx/mechanics `
  assets/audio/sfx/system `
  assets/audio/ambient `
  assets/audio/voice/luna `
  assets/audio/voice/npc `
  assets/audio/config `
  assets/audio/music
```

把生成器导出的 WAV 转为 Godot 可用 OGG：

```powershell
ffmpeg -y -i assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav `
  -ar 48000 -ac 1 -af "loudnorm=I=-16:TP=-1.5:LRA=11,afade=t=out:st=<fade_start>:d=0.04" `
  assets/audio/sfx/stage16_demo_sfx_pack/<asset_id>_ai01.ogg
```

BGM / 环境 loop 保留 stereo，并先人工确认首尾可循环：

```powershell
ffmpeg -y -i assets/source/ai_generated/batch_04/audio/<asset_id>/candidate_01.wav `
  -ar 48000 -ac 2 -af "loudnorm=I=-18:TP=-1.5:LRA=12" `
  assets/audio/music/<asset_id>_ai01.ogg
```

导入 Godot：

```powershell
godot --headless --path . --import
```

## SFX Prompt Pack

本节是 Stage16 首批可执行 SFX，后续全量分类见下方各资产族章节。

### Luna Jump

Asset ID: `stage16_luna_jump_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_luna_jump_sfx_ai01.ogg`

Prompt:

```text
Short game sound effect for Luna jumping in a 2D metroidvania, light cloth movement, soft leather step release, tiny paper talisman flutter, subtle bronze bell shimmer, Northern and Southern Dynasties Chinese dark fantasy, clean responsive player feedback, dry and readable, under 0.45 seconds, no music, no voice, no modern sci-fi.
```

### Luna Air Dash

Asset ID: `stage16_luna_air_dash_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_luna_air_dash_sfx_ai01.ogg`

Prompt:

```text
Short air dash sound effect for Luna, cyan-white Buddhist talisman trail, fast paper charm snap, soft wind slice, light bronze ring, ink-wash spiritual energy whoosh, elegant Ori-like motion but ancient Chinese dark fantasy, 0.55 seconds, crisp attack and clean tail, no laser, no jet engine, no EDM, no voice.
```

### Luna Basic Attack

Asset ID: `stage16_luna_attack_slash_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_luna_attack_slash_sfx_ai01.ogg`

Prompt:

```text
Short melee slash sound effect for a demon-suppressing bounty hunter, ritual blade cutting air, paper talisman ignition, subtle vermilion seal spark, tight transient, elegant ink arc, ancient Chinese fantasy combat, 0.35 seconds, dry punchy game feel, no metal sci-fi sword, no gore, no voice, no long reverb.
```

### Enemy Hit Spark

Asset ID: `stage16_enemy_hit_spark_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_enemy_hit_spark_sfx_ai01.ogg`

Prompt:

```text
Short enemy hit spark sound effect, talisman seal impact against corrupted spirit, small stone crack, paper charm flare, muted bronze chime, dark miasma puff, readable combat confirmation, 0.25 seconds, no blood, no scream, no explosion, no music, no modern electronic beep.
```

### Luna Hit

Asset ID: `stage16_luna_hit_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_luna_hit_sfx_ai01.ogg`

Prompt:

```text
Short player damage feedback sound, cloth stumble, light body impact, faint talisman shield crack, restrained and readable, ancient Chinese dark fantasy, 0.35 seconds, no gore, no horror, no voice line, no cartoon bounce, no long tail.
```

### Seal Gate Open

Asset ID: `stage16_seal_gate_open_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_seal_gate_open_sfx_ai01.ogg`

Prompt:

```text
Ancient talisman-sealed stone gate opening sound effect, heavy stone shift, paper seals tearing free, low ritual drum pulse, bronze bell resonance, cyan-white seal energy release, satisfying unlock feedback, 1.4 seconds, no modern machinery, no sci-fi door, no voice, no music bed.
```

### Seal Gate Close

Asset ID: `stage16_seal_gate_close_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_seal_gate_close_sfx_ai01.ogg`

Prompt:

```text
Ancient demon-sealing gate closing sound effect, stone slab settling, talisman paper snapping into place, low seal thump, short bronze decay, serious but clean gameplay feedback, 1.1 seconds, no hydraulic sound, no metal sci-fi lock, no voice, no music.
```

### Talisman Relay Activate

Asset ID: `stage16_talisman_relay_activate_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_talisman_relay_activate_sfx_ai01.ogg`

Prompt:

```text
Short talisman relay activation sound effect, brushstroke spark, paper charm ignition, gentle bronze bell, cyan spiritual pulse traveling through a ritual circle, clear success feedback for a 2D metroidvania, 0.8 seconds, no speech, no EDM, no sci-fi interface beep.
```

### Recovery Charge Ready

Asset ID: `stage16_recovery_charge_ready_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_recovery_charge_ready_sfx_ai01.ogg`

Prompt:

```text
Short healing charge ready sound effect, warm moon-white talisman glow, tiny bronze bell, soft breath of spiritual energy, restrained positive feedback, ancient Chinese fantasy UI cue, 0.7 seconds, no modern medical monitor, no arcade jingle, no voice, no long music phrase.
```

### Recovery Charge Use

Asset ID: `stage16_recovery_charge_use_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_recovery_charge_use_sfx_ai01.ogg`

Prompt:

```text
Short recovery use sound effect, paper charm unfurling, warm spiritual pulse, soft cloth and breath, low bronze shimmer, calm but immediate healing feedback, 0.9 seconds, no angelic choir, no modern UI beep, no vocal, no long reverb.
```

### Boss Warning

Asset ID: `stage16_seal_guardian_warning_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_seal_guardian_warning_sfx_ai01.ogg`

Prompt:

```text
Boss attack warning sound effect for Seal Guardian, low stone beast growl blended with cracking talisman seal, distant ritual drum, miasma pressure swell, clear readable danger telegraph, 1.0 second, no horror scream, no gore, no modern siren, no speech.
```

### Boss Ground Impact

Asset ID: `stage16_seal_guardian_ground_impact_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_seal_guardian_ground_impact_sfx_ai01.ogg`

Prompt:

```text
Seal Guardian ground impact sound effect, heavy stone paw slam, cracked temple floor, dark miasma burst, low drum hit, short seal energy shock, powerful but not cinematic-overblown, 0.8 seconds, no explosion blockbuster, no sci-fi bass drop, no gore, no voice.
```

### Corruption Purge

Asset ID: `stage16_corruption_purge_sfx`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_corruption_purge_sfx_ai01.ogg`

Prompt:

```text
Corruption purge sound effect, dark miasma hiss dissolving into moon-white talisman light, paper seals fluttering, bronze bell cleansing ring, soft ritual pulse, satisfying stage completion feedback, 1.8 seconds, no horror scream, no pop music, no spoken words, no sci-fi beam.
```

### Alpha Demo Complete

Asset ID: `stage16_alpha_demo_complete_stinger`

目标路径：`assets/audio/sfx/stage16_demo_sfx_pack/stage16_alpha_demo_complete_stinger_ai01.ogg`

Prompt:

```text
Short completion stinger for a 2D Chinese dark fantasy metroidvania demo, guqin harmonic, low ritual drum, bronze bell, talisman seal release shimmer, mysterious but hopeful, 3.5 seconds, no vocals, no orchestral trailer boom, no EDM, no spoken words, loop not required.
```

## Voice / Monster Prompt Pack

这些先作为候选，不默认大量接入。输出建议 `3-5` 个短变体。

### Luna Effort

Asset ID: `stage16_luna_effort_voice`

目标路径：`assets/audio/sfx/stage16_demo_voice_pack/stage16_luna_effort_voice_var01_ai01.ogg`

Prompt:

```text
Very short restrained female effort vocalization for Luna, agile demon-suppressing bounty hunter, focused breath while attacking or air dashing, East Asian dark fantasy tone, no words, no language, no anime exaggeration, no pain scream, 0.25 seconds, dry close voice.
```

### Luna Hurt

Asset ID: `stage16_luna_hurt_voice`

目标路径：`assets/audio/sfx/stage16_demo_voice_pack/stage16_luna_hurt_voice_var01_ai01.ogg`

Prompt:

```text
Very short restrained female hurt vocalization for Luna, controlled and quiet, no spoken words, no scream, no gore, no melodrama, 0.3 seconds, dry close voice, suitable for repeated gameplay damage feedback.
```

### Seal Guardian Growl

Asset ID: `stage16_seal_guardian_growl`

目标路径：`assets/audio/sfx/stage16_demo_voice_pack/stage16_seal_guardian_growl_var01_ai01.ogg`

Prompt:

```text
Short non-verbal monster growl for Seal Guardian, ancient stone guardian corrupted by miasma, low throat texture, cracked stone resonance, restrained boss presence, 0.8 seconds, no human words, no horror scream, no gore, no dragon roar cliche.
```

## Ambient / BGM Prompt Pack

### Main Menu Loop

Asset ID: `stage16_main_menu_loop`

目标路径：`assets/audio/music/stage16_main_menu_loop_ai01.ogg`

Prompt:

```text
Seamless instrumental loop for the main menu of a 2D metroidvania Chinese dark fantasy game, Northern and Southern Dynasties mood, solo guqin, distant xiao flute, soft bronze bell, very low ritual drum, moon-white talisman glow, mysterious and calm, 60 seconds, 68 BPM, no vocals, no modern EDM, no cinematic trailer percussion, loopable ending.
```

### Miasma Marsh Exploration Loop

Asset ID: `stage16_miasma_marsh_loop`

目标路径：`assets/audio/music/stage16_miasma_marsh_loop_ai01.ogg`

Prompt:

```text
Seamless exploration loop for a miasma marsh demon realm in a 2D metroidvania, ancient Chinese dark fantasy, sparse guqin harmonics, breathy xiao, low wind, damp swamp ambience, distant bronze bell, subtle ritual drum heartbeat, uneasy but not horror, 75 seconds, 64 BPM, no vocals, no modern synth lead, no EDM, loopable ending.
```

### Seal Guardian Boss Loop

Asset ID: `stage16_seal_guardian_boss_loop`

目标路径：`assets/audio/music/stage16_seal_guardian_boss_loop_ai01.ogg`

Prompt:

```text
Seamless boss battle loop for Seal Guardian in a 2D Chinese dark fantasy metroidvania, low ritual drums, tense guqin ostinato, xiao fragments, cracked stone percussion, dark miasma ambience, bronze bell accents, focused readable combat energy, 70 seconds, 92 BPM, no vocals, no EDM, no modern orchestra trailer hits, loopable ending.
```

### Seal Release Ambient Loop

Asset ID: `stage16_seal_release_ambient_loop`

目标路径：`assets/audio/music/stage16_seal_release_ambient_loop_ai01.ogg`

Prompt:

```text
Seamless ambient loop for a final seal release threshold, ancient shrine ruin, moon-white talisman light, dissolving dark miasma, soft wind through stone, distant bronze bell and low ritual drone, hopeful but mysterious, 45 seconds, no melody crowding gameplay, no vocals, no modern electronics, loopable ending.
```

## 全量资产族 Prompt Pack

### 角色动作音效 / Player Movement

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `luna_footstep_stone_var01` | 石地脚步 | `assets/audio/sfx/characters/player/luna_footstep_stone_var01_ai01.ogg` | `Short light footstep on ancient stone floor, soft leather boot, tiny cloth movement, restrained metroidvania player movement cue, Northern and Southern Dynasties Chinese dark fantasy, 0.18 seconds, no modern sneaker, no echoing hallway, no music.` |
| `luna_footstep_wood_var01` | 木构平台脚步 | `assets/audio/sfx/characters/player/luna_footstep_wood_var01_ai01.ogg` | `Short light footstep on old temple wood, soft leather boot, subtle wooden creak, cloth flutter, clean repeatable gameplay footstep, 0.18 seconds, no modern floor, no comedic squeak, no music.` |
| `luna_land_light_sfx` | 轻落地 | `assets/audio/sfx/characters/player/luna_land_light_sfx_ai01.ogg` | `Short light landing sound, cloth settling, leather foot on stone, tiny talisman flutter, responsive but subtle player feedback, 0.28 seconds, no heavy thud, no voice, no sci-fi.` |
| `luna_land_heavy_sfx` | 重落地 / 高处落下 | `assets/audio/sfx/characters/player/luna_land_heavy_sfx_ai01.ogg` | `Short heavier landing sound for agile hunter, stone dust puff, cloth snap, low soft impact, ancient shrine floor, 0.38 seconds, readable but not overpowering, no bone crack, no voice, no cinematic boom.` |
| `luna_wall_slide_sfx` | 贴墙 / 滑墙候选 | `assets/audio/sfx/characters/player/luna_wall_slide_sfx_ai01.ogg` | `Short loopable wall slide texture, cloth brushing stone, faint talisman paper scrape, soft granular stone dust, ancient temple wall, 0.6 seconds, seamless loop candidate, no metal grind, no modern climbing gear.` |

### 战斗音效 / Combat

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `combat_parry_seal_sfx` | 符印格挡 / 反制候选 | `assets/audio/sfx/combat/combat_parry_seal_sfx_ai01.ogg` | `Short successful parry sound, talisman seal flash, bronze bell snap, dry impact click, moon-white spiritual pulse, crisp 2D combat feedback, 0.35 seconds, no shield clang cliche, no sci-fi, no voice.` |
| `combat_enemy_defeat_puff_sfx` | 小敌人消散 | `assets/audio/sfx/combat/combat_enemy_defeat_puff_sfx_ai01.ogg` | `Short defeated corrupted spirit dissolve sound, miasma puff, paper seal tightening, soft stone dust, muted bronze tail, 0.7 seconds, no gore, no scream, no explosion, no music.` |
| `combat_projectile_cast_sfx` | 敌方法术投射 | `assets/audio/sfx/combat/combat_projectile_cast_sfx_ai01.ogg` | `Short corrupted talisman projectile cast, dark miasma hiss, wet ink spark, low paper snap, readable enemy attack cue, 0.45 seconds, no laser, no gun, no modern magic wand sparkle.` |
| `combat_projectile_break_sfx` | 投射物碎裂 | `assets/audio/sfx/combat/combat_projectile_break_sfx_ai01.ogg` | `Short miasma projectile break sound, brittle ink shell crack, tiny talisman ember scatter, 0.3 seconds, no glass shatter cliche, no explosion, no voice.` |

### UI 音效 / UI

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `ui_confirm_seal_sfx` | 菜单确认 | `assets/audio/sfx/ui/ui_confirm_seal_sfx_ai01.ogg` | `Short UI confirm sound, vermilion seal stamp, soft bamboo slip tap, tiny bronze chime, ancient Chinese fantasy menu feedback, 0.25 seconds, no modern button beep, no voice, no music.` |
| `ui_cancel_scroll_sfx` | 返回 / 取消 | `assets/audio/sfx/ui/ui_cancel_scroll_sfx_ai01.ogg` | `Short UI cancel sound, bamboo scroll roll-back, paper talisman flutter, soft muted click, 0.22 seconds, no error beep, no comedic sound, no voice.` |
| `ui_focus_move_sfx` | 菜单焦点移动 | `assets/audio/sfx/ui/ui_focus_move_sfx_ai01.ogg` | `Very short UI focus movement tick, brushstroke cursor, light bronze bead, clean repeatable interface cue, 0.12 seconds, no electronic beep, no harsh click, no music.` |
| `ui_pause_open_sfx` | 暂停打开 | `assets/audio/sfx/ui/ui_pause_open_sfx_ai01.ogg` | `Short pause menu open sound, parchment panel unfurl, talisman glow pulse, soft bronze ring, 0.45 seconds, no modern UI swipe, no voice, no music bed.` |
| `ui_pause_close_sfx` | 暂停关闭 | `assets/audio/sfx/ui/ui_pause_close_sfx_ai01.ogg` | `Short pause menu close sound, parchment fold, seal light fading, soft wooden tap, 0.35 seconds, no modern UI swoosh, no voice, no music.` |

### 环境音效 / 氛围声

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `ambient_shrine_trial_loop` | 山门古刹 / 试炼场氛围 | `assets/audio/ambient/ambient_shrine_trial_loop_ai01.ogg` | `Seamless ambient loop for ancient demon-suppressing shrine trial, soft wind through old wood, distant bronze bell, temple cloth movement, faint talisman hum, calm mysterious Chinese dark fantasy, 45 seconds, no melody, no vocals, no modern machinery.` |
| `ambient_miasma_marsh_loop` | 瘴泽妖域氛围 | `assets/audio/ambient/ambient_miasma_marsh_loop_ai01.ogg` | `Seamless ambient loop for miasma marsh demon realm, damp air, low swamp bubbles, dark miasma hiss, distant ritual bell, subtle insect-like texture without realism overload, 50 seconds, eerie but not horror, no vocals, no sci-fi.` |
| `ambient_boss_room_tension_loop` | Boss 房低层氛围 | `assets/audio/ambient/ambient_boss_room_tension_loop_ai01.ogg` | `Seamless low tension ambient loop for sealed guardian boss room, cracked stone chamber, distant low drum resonance, talisman chains vibrating, dark miasma pressure, 40 seconds, no melody, no vocals, no modern drone synth.` |

### 物品与交互音效

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `interaction_checkpoint_activate_sfx` | checkpoint / 石龛激活 | `assets/audio/sfx/interactions/interaction_checkpoint_activate_sfx_ai01.ogg` | `Short checkpoint activation sound, Buddhist stone niche waking up, talisman paper glow, bronze bell, warm spiritual pulse, satisfying save-like feedback, 1.0 second, no modern save beep, no voice.` |
| `interaction_pickup_small_sfx` | 小奖励 / 符纸拾取 | `assets/audio/sfx/interactions/interaction_pickup_small_sfx_ai01.ogg` | `Short pickup sound for talisman paper or small charm, soft paper lift, tiny bronze bead, moon-white sparkle, 0.25 seconds, no coin arcade, no modern notification beep, no voice.` |
| `interaction_pickup_key_sfx` | 关键物 / 镇妖令拾取 | `assets/audio/sfx/interactions/interaction_pickup_key_sfx_ai01.ogg` | `Short important pickup sound, bronze demon-suppressing token, bamboo slip reveal, talisman seal pulse, noble but restrained, 0.9 seconds, no victory fanfare, no voice, no modern UI.` |
| `interaction_shrine_unlock_sfx` | 能力神龛解锁 | `assets/audio/sfx/interactions/interaction_shrine_unlock_sfx_ai01.ogg` | `Ability shrine unlock sound, ancient stone mechanism, paper seals igniting in sequence, low ritual drum, bronze bell shimmer, cyan-white talisman energy, 1.6 seconds, no sci-fi power-up, no vocals.` |

### 载具 / 机械音效：古代机关化处理

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `mechanism_lift_stone_loop` | 石质升降平台 loop | `assets/audio/sfx/mechanics/mechanism_lift_stone_loop_ai01.ogg` | `Short loopable ancient stone lift mechanism, stone grinding softly, wooden axle strain, talisman chain vibration, temple machinery, 1.2 seconds seamless loop, no motor, no hydraulic, no metal factory sound.` |
| `mechanism_chain_release_sfx` | 封印链释放 | `assets/audio/sfx/mechanics/mechanism_chain_release_sfx_ai01.ogg` | `Seal chain release sound, old bronze chain tension, stone lock crack, paper talisman snap, low ritual resonance, 1.0 second, no industrial machine, no sci-fi lock, no explosion.` |
| `mechanism_door_rune_lock_sfx` | 符印机关锁 | `assets/audio/sfx/mechanics/mechanism_door_rune_lock_sfx_ai01.ogg` | `Ancient rune lock sound, wooden mechanism click, stone pin sliding, vermilion seal pulse, short bronze tick, 0.55 seconds, no electronic keypad, no modern lock, no voice.` |

### 怪物 / NPC 音效

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `enemy_basic_melee_alert_sfx` | 基础近战敌警觉 | `assets/audio/sfx/characters/enemies/enemy_basic_melee_alert_sfx_ai01.ogg` | `Short corrupted melee spirit alert sound, dry throat rasp blended with miasma hiss, restrained readable enemy cue, 0.45 seconds, no human words, no horror scream, no gore.` |
| `enemy_charger_windup_sfx` | 冲锋敌蓄力 | `assets/audio/sfx/characters/enemies/enemy_charger_windup_sfx_ai01.ogg` | `Short enemy charge windup, claws scraping stone, low miasma inhale, tense body coil, clear attack preparation cue, 0.6 seconds, no engine rev, no sci-fi, no voice words.` |
| `enemy_aerial_sentinel_hover_loop` | 空中敌悬浮 loop | `assets/audio/sfx/characters/enemies/enemy_aerial_sentinel_hover_loop_ai01.ogg` | `Short loopable floating corrupted spirit sound, soft air flutter, talisman ash swirl, faint miasma hum, 0.8 seconds seamless loop, no drone motor, no insect swarm overload, no sci-fi.` |
| `npc_bureau_clerk_murmur_var01` | 后续 NPC 含混语音候选 | `assets/audio/voice/npc/npc_bureau_clerk_murmur_var01_ai01.ogg` | `Very short non-verbal murmured human vocal texture for ancient demon-suppressing bureau clerk, no intelligible words, calm official tone, dry close voice, 0.6 seconds, no modern language phrase, no comedy, no singing.` |

### 音乐资产 BGM

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `bgm_shrine_trial_explore_loop` | 山门古刹探索 | `assets/audio/music/bgm_shrine_trial_explore_loop_ai01.ogg` | `Seamless exploration BGM loop for ancient shrine trial in a 2D Chinese dark fantasy metroidvania, guqin sparse motif, xiao breath, soft ritual percussion, bronze bell accents, calm mystery, 70 seconds, no vocals, no EDM, no cinematic trailer hits, loopable ending.` |
| `bgm_miasma_marsh_combat_loop` | 瘴泽普通战斗 | `assets/audio/music/bgm_miasma_marsh_combat_loop_ai01.ogg` | `Seamless light combat loop for miasma marsh, tense guqin pattern, low hand drum, dark ambience, subtle bronze accents, focused but not boss-level, 60 seconds, no vocals, no modern rock, no EDM, loopable ending.` |
| `bgm_victory_stinger` | 战斗 / 区域完成短乐句 | `assets/audio/music/bgm_victory_stinger_ai01.ogg` | `Short victory stinger, guqin harmonic, bronze bell, soft talisman shimmer, mysterious hopeful release, 2.5 seconds, no vocals, no big orchestra, no pop chord progression.` |
| `bgm_defeat_stinger` | 失败短乐句 | `assets/audio/music/bgm_defeat_stinger_ai01.ogg` | `Short defeat stinger, muted guqin low note, soft drum, fading talisman crackle, solemn but not despair horror, 2.2 seconds, no vocals, no jump scare, no cinematic boom.` |

### 语音资产

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `voice_luna_attack_effort_var02` | Luna 攻击发力变体 | `assets/audio/voice/luna/voice_luna_attack_effort_var02_ai01.ogg` | `Very short restrained female attack effort for Luna, focused breath, agile hunter, no words, no language, no anime shout, dry close voice, 0.25 seconds.` |
| `voice_luna_dash_breath_var01` | Luna 冲刺呼吸 | `assets/audio/voice/luna/voice_luna_dash_breath_var01_ai01.ogg` | `Very short controlled breath for Luna air dash, quick exhale, calm and skilled, no words, no scream, no exaggerated anime style, 0.2 seconds.` |
| `voice_luna_low_health_breath_loop` | 低生命呼吸候选 | `assets/audio/voice/luna/voice_luna_low_health_breath_loop_ai01.ogg` | `Subtle loopable low health breathing texture for Luna, restrained tired breath, no words, no panic, no pain scream, 1.2 seconds seamless loop candidate, dry close voice.` |

### 系统反馈音

| Asset ID | 用途 | 目标路径 | Prompt |
| --- | --- | --- | --- |
| `system_checkpoint_saved_sfx` | 存档 / checkpoint 确认 | `assets/audio/sfx/system/system_checkpoint_saved_sfx_ai01.ogg` | `Short system feedback for checkpoint saved, soft seal stamp, bamboo slip tap, warm bronze chime, calm confirmation, 0.55 seconds, no modern notification, no spoken words.` |
| `system_ability_unlocked_sfx` | 能力解锁 | `assets/audio/sfx/system/system_ability_unlocked_sfx_ai01.ogg` | `Short ability unlocked feedback, ritual circle bloom, talisman paper flare, low drum and bronze shimmer, exciting but restrained, 1.5 seconds, no arcade level-up, no voice, no EDM.` |
| `system_error_locked_sfx` | 门未解锁 / 条件不足 | `assets/audio/sfx/system/system_error_locked_sfx_ai01.ogg` | `Short locked feedback, muted stone knock, sealed talisman dull pulse, low bamboo tap, clear negative cue, 0.35 seconds, no buzzer, no modern error beep, no voice.` |
| `system_demo_restart_sfx` | 重开 / retry | `assets/audio/sfx/system/system_demo_restart_sfx_ai01.ogg` | `Short retry sound, scroll rewind, talisman seal resetting, soft stone pulse, 0.7 seconds, no VHS rewind, no modern UI, no voice.` |

### 音频配置资产

这些不是生成音频，而是后续接入 Godot 时的配置文件入口。

| Config ID | 用途 | 目标路径 | 内容要求 |
| --- | --- | --- | --- |
| `audio_event_catalog` | 音频事件表 | `assets/audio/config/audio_event_catalog.json` | event id、asset paths、bus、volume_db、pitch_variation、cooldown_ms、priority、polyphony |
| `audio_mix_targets` | 混音目标 | `assets/audio/config/audio_mix_targets.json` | Music / Ambient / PlayerSfx / EnemySfx / UI / Voice 的默认音量和 ducking 规则 |
| `audio_generation_manifest` | 生成记录 | `docs/assets/audio-generation-manifest.json` | asset id、prompt、tool、candidate、license、selected output、review status |
| `audio_ingestion_checklist` | 接入验收 | `docs/assets/audio-ingestion-checklist.md` | 导入、响度、loop、事件绑定、重复播放、授权、运行态复核 |

最小 `audio_event_catalog.json` 形态：

```json
{
  "events": {
    "player.jump": {
      "bus": "PlayerSfx",
      "paths": ["res://assets/audio/sfx/characters/player/luna_jump_sfx_ai01.ogg"],
      "volume_db": -4.0,
      "pitch_variation": 0.04,
      "cooldown_ms": 80,
      "priority": 90
    }
  }
}
```

## 推荐生成顺序

1. P0 Gameplay SFX：角色动作、攻击、命中、受击、Boss warning、Boss impact、关键交互。
2. P1 UI / System / Ambient：菜单、暂停、能力解锁、checkpoint、区域氛围、seal release ambience。
3. P2 Voice / Monster / NPC：Luna 短 vocal、Seal Guardian growl、普通敌人警觉、NPC 含混语音候选。
4. P3 Music：main menu、shrine trial、miasma marsh、boss、victory / defeat stinger。
5. P4 Config：audio event catalog、mix targets、generation manifest、ingestion checklist。

## 最小验收标准

- SFX 不含音乐底，不含明显语言、英文词、现代 UI beep 或科幻激光。
- 同一 cue 至少保留 `3` 个候选，正式接入前选 `1-2` 个。
- Player SFX 优先级高于敌人、BGM 和环境音，必须短、清楚、可重复。
- Boss warning 和 Boss impact 必须能在 BGM 下听清，但不能盖过玩家受击 / 攻击反馈。
- BGM 必须首尾可循环；不能有明显 fade-out、尾巴断裂或旋律过满。
- 所有可接入音频必须回填 `docs/assets/asset-manifest.md`，写清来源、授权状态、生成工具、候选编号和接入边界。
- 音频配置资产必须能追溯到具体 event id，不能只记录“某个文件在目录里”。

## 后续接入边界

第一轮接入只建议绑定最小事件：

- Luna：jump、air dash、attack、hit。
- Combat：enemy hit spark、Boss warning、Boss ground impact。
- Stage16：talisman relay、corruption purge、completion stinger。
- DemoShell：main menu loop 或最小 menu ambience。

暂不做：完整 AudioBus 设计、动态音乐分层、区域混响系统、语音优先级 ducking、全敌人脚步声、完整 UI 声音皮肤。
