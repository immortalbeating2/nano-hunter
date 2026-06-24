# Asset Batch 01 P0 Art Generation Plan

日期：2026-06-19

## Summary

本计划收束当前 Alpha Demo 候选最需要的美术资产：`Batch 01 - P0 玩法可读资产`。本批只处理美术图像，不接入场景、不修改碰撞、不修改 HUD 布局、不改变 Stage14-16 的玩法契约。

本轮已使用 Codex 内置 `image_gen` 生成 8 张会话预览候选，但当前客户端未暴露可搬运的生成文件路径；因此本计划先记录资产清单、统一风格锚点、完整 prompt 和后续落库流程。实际写入 `assets/art/` 前，`asset-manifest.md` 中 Batch 01 条目仍保持 `needed`。

## Scope

本批资产：

| Asset ID | 目标路径 | 规格 | 用途 |
| --- | --- | --- | --- |
| `stage16_luna_player_readability_ai01` | `assets/art/characters/player/stage16_luna_player_readability_ai01.png` | 128x128 PNG，透明背景 | Luna 玩家可读轮廓方向 |
| `stage14_air_dash_icon_ai01` | `assets/art/ui/stage14_air_dash_icon_ai01.png` | 64x64 PNG，透明背景 | Air Dash HUD 图标 |
| `stage14_air_dash_trail_ai01` | `assets/art/vfx/stage14_air_dash_trail_ai01.png` | 128x64 PNG，透明背景 | Air Dash 视觉拖尾 |
| `stage14_air_dash_shrine_ai01` | `assets/art/props/stage14_air_dash_shrine_ai01.png` | 192x128 PNG，透明背景 | Air Dash 能力获得装置 |
| `stage14_air_dash_gate_ai01` | `assets/art/props/stage14_air_dash_gate_ai01.png` | 160x160 PNG，透明背景 | Air Dash 门控道具 |
| `stage15_seal_guardian_ai01` | `assets/art/characters/bosses/stage15_seal_guardian_ai01.png` | 192x192 PNG，透明背景 | Seal Guardian Boss 可读方向 |
| `stage15_boss_attack_warning_ai01` | `assets/art/vfx/stage15_boss_attack_warning_ai01.png` | 128x64 PNG，透明背景 | Boss 攻击预警 VFX |
| `stage15_recovery_charge_icon_ai01` | `assets/art/ui/stage15_recovery_charge_icon_ai01.png` | 64x64 PNG，透明背景 | Recovery Charge HUD 图标 |

## Unified Style Anchor

- 2D side-view metroidvania。
- 南北朝东方奇幻、镇妖卫、佛门符印、山海经妖物、瘴泽妖域。
- 水墨与工笔色系，柔和 Ori-like glow。
- 色板统一为月白、墨青、青蓝灵光、少量朱砂符印；Boss 可加入黛紫、墨绿、病态黄绿，但避免抢读值。
- 图像优先使用透明背景；内置 `image_gen` 默认先用纯色 chroma-key 背景，后续再抠图。
- 禁止现代实验室、生物科技、科幻装甲、现代 UI 面板、文字、水印和 logo。

## Generation Prompts

### stage16_luna_player_readability_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter game asset, player readability sprite concept, target file stage16_luna_player_readability_ai01.png
Primary request: Generate a single 2D side-view metroidvania protagonist sprite concept for Luna, a female demon-suppressing bounty hunter from Northern and Southern Dynasties inspired Chinese dark fantasy. She should have a compact readable silhouette suitable for 640x360 gameplay, a moon-white and ink-teal outfit, subtle cyan spiritual glow, a small vermilion Buddhist talisman accent, a ritual blade or charm weapon, and a restrained hint of demonic bloodline in the eyes or sash.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D game concept sprite, ink wash plus gongbi-inspired accents, soft Ori-like glow, side-view platformer readability, not pixel art.
Composition/framing: single full-body side-view character, standing neutral/ready pose facing right, generous padding around the figure, no ground shadow.
Lighting/mood: soft rim light from upper left, mystical but readable.
Color palette: moon white, ink teal, cyan-white glow, tiny vermilion seal accent; do not use #00ff00 in the subject.
Constraints: one character only; crisp edges; no text; no watermark; no logo; no cast shadow; no floor plane; transparent-background-ready chroma key; preserve clean gameplay silhouette.
Avoid: photorealistic, 3D render, anime portrait close-up, front-facing portrait, modern laboratory, biotech, sci-fi armor, cyberpunk, excessive detail, blurry edges, gore, unreadable silhouette.
```

### stage14_air_dash_icon_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter HUD icon, target file stage14_air_dash_icon_ai01.png
Primary request: Generate a single compact 2D game HUD icon for Air Dash. The icon should read as a Buddhist talisman seal forming a forward crescent dash, with cyan-white spiritual wind, one small vermilion seal mark, and ink-teal outline. It must be readable at 64x64 and still understandable at 32x32.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: clean hand-painted 2D icon, gongbi-inspired line control, soft Ori-like glow, ancient Chinese dark fantasy UI glyph.
Composition/framing: centered single icon, square-safe silhouette, generous padding, no frame unless it is part of the glyph.
Lighting/mood: luminous but restrained, high contrast for gameplay HUD.
Color palette: cyan-white, moon white, ink teal, tiny vermilion accent; do not use #00ff00 in the subject.
Constraints: one icon only; crisp edges; no text; no watermark; no logo; no cast shadow; no floor plane; chroma-key-ready background; not a modern app icon.
Avoid: photorealistic, 3D render, modern UI panel, sci-fi particles, cyberpunk, battery symbol, medical cross, low contrast, excessive detail, blurry edges.
```

### stage14_air_dash_trail_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter VFX sprite concept, target file stage14_air_dash_trail_ai01.png
Primary request: Generate a single horizontal 2D game VFX trail for Air Dash: a fast cyan-white talisman energy streak with ink-brush taper, faint vermilion seal sparks, and subtle crescent motion. It should look like Luna has dashed from left to right through Buddhist seal magic.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D VFX sprite, ink wash brush edge, gongbi accents, soft Ori-like glow, side-view metroidvania readability.
Composition/framing: wide horizontal effect, left-to-right motion, centered, no character body, generous padding, no shadow.
Lighting/mood: bright spiritual pulse, clean gameplay telegraph.
Color palette: cyan-white glow, ink teal edges, very small vermilion talisman sparks; do not use #00ff00 in the subject.
Constraints: VFX only; crisp edges; no text; no watermark; no logo; no floor plane; transparent-background-ready chroma key; readable when downscaled to 128x64.
Avoid: photorealistic, 3D render, modern sci-fi particles, laser beam, neon cyberpunk, smoky background, excessive clutter, blurry edges.
```

### stage14_air_dash_shrine_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter prop sprite concept, target file stage14_air_dash_shrine_ai01.png
Primary request: Generate a single 2D side-view metroidvania ability shrine for Air Dash. It should be an ancient Buddhist stone niche / demon-suppressing talisman altar from Northern and Southern Dynasties inspired Chinese fantasy, with suspended paper charms, crescent wind motif, cyan-white spiritual seams, tiny vermilion seal marks, and enough design space for inactive, active, and claimed states later.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D game prop, ink wash and gongbi accents, soft Ori-like glow, readable side-view prop.
Composition/framing: single shrine prop, 3/4 side-readable but suitable for 2D side-view platformer, centered, generous padding, no ground shadow.
Lighting/mood: ancient, sacred, slightly eerie, clear interaction focus.
Color palette: aged stone, moon white, ink teal, cyan glow, small vermilion talisman accents; do not use #00ff00 in the subject.
Constraints: one prop only; crisp silhouette; no text; no watermark; no logo; no modern machinery; no cast shadow; no floor plane; chroma-key-ready background; readable when downscaled to 192x128.
Avoid: photorealistic, 3D render, futuristic door, biotech lab, metal pipes, cyberpunk, excessive background, gore, blurry edges.
```

### stage14_air_dash_gate_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter gate prop sprite concept, target file stage14_air_dash_gate_ai01.png
Primary request: Generate a single 2D side-view metroidvania gate prop for an Air Dash ability lock. It should be an ancient talisman-sealed stone-and-wood gate, Buddhist seal magic, crescent wind motif, cyan-white spiritual seams showing where Air Dash can pass, and vermilion ward paper charms. It must read as a traversal gate, not a sci-fi door.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D game prop, ink wash and gongbi accents, ancient Chinese dark fantasy, soft Ori-like glow.
Composition/framing: single vertical gate prop, centered, clean side-view silhouette, generous padding, no ground shadow.
Lighting/mood: sealed but inviting once unlocked, readable interactive object.
Color palette: aged stone, dark wood, moon white, ink teal, cyan glow, vermilion seal accents; do not use #00ff00 in the subject.
Constraints: one gate only; clear closed/open design language potential; crisp edges; no text; no watermark; no logo; no cast shadow; no floor plane; chroma-key-ready background; readable at 160x160.
Avoid: photorealistic, 3D render, modern lab door, biotech pod, metal pipes, cyberpunk, futuristic UI, excessive detail, blurry edges.
```

### stage15_seal_guardian_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter boss sprite concept, target file stage15_seal_guardian_ai01.png
Primary request: Generate a single 2D side-view metroidvania elite boss concept called Seal Guardian. It is a Shanhaijing-inspired corrupted guardian beast fused with ancient Buddhist ward stone, sealed talisman chains, and miasma swamp energy. The body should be large, squat and readable, with a clear weak-point glow on the chest or forehead, stone-mask features, clawed forelimbs, and ritual seal fragments. It should feel like a sealed temple guardian gone corrupt, not a modern monster.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for background removal.
Style/medium: hand-painted 2D game boss sprite concept, ink wash and gongbi-inspired accents, soft Ori-like glow, side-view platformer readability.
Composition/framing: single boss only, side-view facing left, broad readable silhouette, centered, generous padding, no ground shadow.
Lighting/mood: ominous ancient seal magic, dangerous but readable.
Color palette: ink purple, dark teal stone, sickly yellow-green miasma, cyan-white seal glow, small vermilion talisman accents; do not use #ff00ff in the subject.
Constraints: one creature only; crisp silhouette; no text; no watermark; no logo; no cast shadow; no floor plane; chroma-key-ready background; readable at 192x192; no gore.
Avoid: photorealistic, 3D render, front-facing portrait, modern biotech, laboratory creature, sci-fi armor, cyberpunk, excessive tiny parts, blurry edges, gore.
```

### stage15_boss_attack_warning_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter boss warning VFX, target file stage15_boss_attack_warning_ai01.png
Primary request: Generate a single 2D game VFX telegraph marker for a Boss attack warning. It should be a vermilion Buddhist talisman circle breaking into dark miasma cracks, with cyan-white seal edges and a sharp readable danger shape. It must clearly communicate incoming attack on the floor or near the player.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: clean hand-painted 2D VFX sprite, ancient Chinese fantasy talisman magic, ink wash cracks, gongbi-inspired seal lines.
Composition/framing: compact horizontal-oval warning marker, centered, no character, no background, generous padding.
Lighting/mood: urgent warning cue, high contrast, readable at 128x64 and smaller.
Color palette: vermilion red, dark ink purple cracks, cyan-white seal rim, small gold flecks; do not use #00ff00 in the subject.
Constraints: VFX marker only; crisp edges; no text; no watermark; no logo; no cast shadow; no floor plane; chroma-key-ready background.
Avoid: photorealistic, 3D render, modern warning triangle, sci-fi hologram, cyberpunk UI, excessive detail, smoky background, blurry edges.
```

### stage15_recovery_charge_icon_ai01

```text
Use case: stylized-concept
Asset type: Nano Hunter HUD icon, target file stage15_recovery_charge_icon_ai01.png
Primary request: Generate a single compact 2D game HUD icon for Recovery Charge. It should read as a Buddhist prayer bead / talisman seal charge filled with moon-white healing spirit, a cyan-white inner glow, ink-teal outline, and a tiny vermilion ward mark. It must communicate hit-earned healing readiness without looking like a modern medical cross, battery, potion, or sci-fi meter.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: clean hand-painted 2D icon, gongbi-inspired line work, ancient Chinese dark fantasy UI glyph, soft Ori-like glow.
Composition/framing: centered single icon, circular or bead-like silhouette, square-safe, generous padding, no frame unless part of the talisman design.
Lighting/mood: calm but clearly charged, readable at 64x64 and 32x32.
Color palette: moon white, ink teal, cyan-white glow, muted gold, tiny vermilion accent; do not use #00ff00 in the subject.
Constraints: one icon only; crisp edges; no text; no watermark; no logo; no medical cross; no battery shape; no cast shadow; no floor plane; chroma-key-ready background.
Avoid: photorealistic, 3D render, modern health icon, red cross, battery, potion bottle, sci-fi UI, cyberpunk, excessive detail, low contrast, blurry edges.
```

## Storage Plan

- 原始候选应进入：`assets/source/ai_generated/batch_01/`
- 目标可接入版应进入本计划 Scope 表中的 `assets/art/...` 路径。
- 如果继续使用内置 `image_gen`，必须先确认生成文件可从 `$CODEX_HOME/generated_images/` 或其它明确路径复制。
- 如果继续使用 CLI/API fallback，需用户确认并提供本机 `OPENAI_API_KEY` 环境变量；生成后再用 `remove_chroma_key.py` 做透明背景。
- 未落盘前，不修改场景引用、不运行 Godot import、不把 manifest 状态改为 `placeholder_ready`。

## Validation

落盘后再执行：

1. 检查每张图尺寸、透明背景或 chroma-key 可抠图性。
2. 运行 `godot --headless --path . --import`。
3. 若替换场景 / HUD 引用，按 `docs/assets/asset-ingestion-checklist.md` 做人工复核。
4. 影响 Stage14-16 可读性时，运行最接近的 GUT 或人工试玩复核。

## Exit Criteria

- 8 个 P0 资产都有至少 1 个可追溯候选。
- 入选文件落到目标路径。
- prompt、工具、来源和授权状态已回填 manifest 或批次记录。
- 未接入游戏前不得声称 `integrated`。
