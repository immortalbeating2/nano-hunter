# Nano Hunter Image Gen Prompt Library

Last Updated: 2026-06-19

## 用途

本文件保存可复制到 Image2 / GPT Image、Nano Banana / Gemini Image、Seedance / Veo 等工具的批量提示词模板。具体资产开始生成前，从 `asset-completion-matrix.md` 抽取资产组，再把 `{asset_id}`、`{target_size}`、`{state}`、`{action}`、`{biome}` 等占位字段替换为实际内容。

## Global Positive Anchor

```text
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no text, no watermark
```

## Global Negative Anchor

```text
photorealistic, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, low contrast, blurry edges, noisy background, gore, logo, readable text, watermark, front-facing portrait unless requested
```

## Batch 06 - Character Sprite Sheet Prompt

```text
Use case: stylized-concept
Asset type: 2D metroidvania character animation sprite sheet, target asset {asset_id}
Primary request: Create a clean animation keyframe sheet for {character_name}, action set: {actions}. Keep the same character proportions, costume, palette, and silhouette across every frame. The character belongs to a Northern and Southern Dynasties inspired Chinese dark fantasy world with Buddhist talisman seal magic and Shanhaijing monster mythology.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D game sprite sheet, ink wash and gongbi-inspired accents, soft Ori-like glow, readable side-view platformer animation.
Composition/framing: side-view frames in a regular grid, facing {direction}, fixed foot baseline, consistent scale, generous padding inside each cell.
Color palette: {palette}, avoid using #00ff00 in the subject.
Constraints: no background scene, no cast shadow, no floor plane, no text, no watermark, no logo, consistent frame size, readable silhouette at gameplay distance.
Avoid: {global_negative_anchor}
```

## Batch 06 - Luna High Frame Sprite Sheet Prompt

```text
Use case: stylized-concept
Asset type: high-frame-count 2D protagonist animation sprite sheet, target asset {asset_id}
Primary request: Create a high-consistency animation sprite sheet for Luna, the player protagonist of Nano Hunter. Action: {action}. Target candidate frame count: {candidate_frame_count}. This is source material that will later be cleaned and extended to the final frame count in Aseprite / Krita. Keep Luna's proportions, costume, moon-white and ink-teal palette, cyan-white talisman glow, vermilion seal accents, hair / sash / talisman paper follow-through, and side-view silhouette consistent across every frame.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D metroidvania sprite sheet, ink wash and gongbi-inspired accents, soft Ori-like glow, readable at 640x360 gameplay distance, not pixel art.
Composition/framing: regular grid of {candidate_frame_count} frames, fixed cell size {cell_size}, facing right, fixed foot baseline, consistent scale, generous padding inside each cell, no frame overlap, no frame numbers, no labels.
Motion notes: {motion_notes}
Color palette: moon white, ink teal, cyan-white spiritual glow, tiny vermilion talisman accents; avoid using #00ff00 in the character.
Constraints: Luna only, no enemies, no background scene, no cast shadow, no floor plane, no text, no numbers, no labels, no watermark, no logo, no camera angle changes, no costume drift, no face redesign, no frame-to-frame scale drift.
Avoid: photorealistic, 3D render, front-facing portrait, modern laboratory, biotech, sci-fi armor, cyberpunk, excessive tiny detail, low contrast, blurry edges, unreadable silhouette.
```

Recommended Luna prompt values:

| Action | Candidate frame count | Final target frame count | Cell size | Motion notes |
| --- | --- | --- | --- | --- |
| `run` | 12 | 16-24 | `160x160` | energetic run cycle, clear contact / passing / airborne beats, stable foot baseline |
| `air_dash` | 12 | 12-16 | `192x160` | explosive horizontal dash, compact body, talisman trail implied but not covering silhouette |
| `attack_01` | 10-12 | 12-16 | `192x160` | anticipation, slash active frame, recovery, ritual blade or charm weapon arc |
| `idle` | 8-12 | 12-16 | `160x160` | breathing, subtle sash and talisman paper motion |
| `death` | 12 | 16-24 | `192x160` | dramatic but not gory, seal light fading, readable restart timing |

## Batch 07 - TileSet / Texture Prompt

```text
Use case: stylized-concept
Asset type: Godot 2D TileSet / seamless texture sheet, target asset {asset_id}
Primary request: Create a tile sheet for {biome}: {tile_types}. The tiles should support platforms, ground edges, wall pieces, decorative variants, and hazard boundaries without misleading collision.
Scene/backdrop: clean tile sheet layout on perfectly flat solid #00ff00 chroma-key or neutral matte background.
Style/medium: hand-painted 2D environment tiles, ink wash surface texture, gongbi line accents, ancient Chinese dark fantasy.
Composition/framing: regular grid, each tile visually isolated, consistent perspective for side-view metroidvania.
Color palette: {palette}; interaction and hazard colors must remain readable against the background.
Constraints: no text, no watermark, no photoreal texture, no modern lab shapes, no sci-fi panels, tile edges must be clear.
Avoid: {global_negative_anchor}
```

## Batch 08 - UI / Icon Atlas Prompt

```text
Use case: stylized-concept
Asset type: Godot UI atlas and icon sheet, target asset {asset_id}
Primary request: Create a cohesive UI icon and panel sheet for Nano Hunter: {ui_elements}. Use Buddhist talisman circles, bamboo slips, seal stamps, bronze-gold trim, moon-white paper, ink-teal outlines, cyan-white spiritual glow, and small vermilion accents.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: clean 2D game UI atlas, hand-painted but crisp, readable at 64x64 and 32x32, ancient Chinese dark fantasy.
Composition/framing: regular grid, consistent padding, consistent line width, icons and panels separated clearly.
Color palette: moon white, ink teal, cyan-white, vermilion, muted gold.
Constraints: no readable text, no watermark, no logo lettering, no modern app UI, no sci-fi panels, no medical cross, no battery shape unless explicitly requested.
Avoid: {global_negative_anchor}
```

## Batch 09 - Props / Equipment Atlas Prompt

```text
Use case: stylized-concept
Asset type: 2D metroidvania prop and equipment atlas, target asset {asset_id}
Primary request: Create a prop atlas for {prop_group}: {props}. These objects should belong to a demon-suppressing bureau and Buddhist seal magic setting, with readable inactive / active / completed state potential where relevant.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D side-view game props, ink wash and gongbi accents, soft Ori-like glow.
Composition/framing: individual props arranged in a grid, consistent scale family, no background scene, generous padding.
Color palette: aged stone, dark wood, moon white, ink teal, cyan spiritual seams, vermilion talisman paper, muted gold.
Constraints: no text, no watermark, no modern machinery, no sci-fi doors, no biotech pods, crisp silhouettes.
Avoid: {global_negative_anchor}
```

## Batch 10 - VFX Atlas Prompt

```text
Use case: stylized-concept
Asset type: 2D game VFX sequence sheet, target asset {asset_id}
Primary request: Create a VFX sequence sheet for {vfx_name}: {vfx_action}. The effect should communicate gameplay clearly and use Buddhist talisman seal magic, ink-brush motion, cyan-white spiritual energy, vermilion seal sparks, and dark miasma accents when appropriate.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D VFX sprite sheet, crisp edges, readable timing, soft glow.
Composition/framing: regular frame grid, consistent frame size, no character body unless requested, generous padding, fixed center point.
Color palette: {palette}; avoid using #00ff00 in the effect.
Constraints: VFX only, no text, no watermark, no floor plane, no background smoke cloud that prevents transparency cleanup.
Avoid: photorealistic, 3D render, laser beam, sci-fi hologram, cyberpunk UI, excessive particle noise, blurry edges.
```

## Batch 11 - Spine Cutout Parts Prompt

```text
Use case: stylized-concept
Asset type: 2D character cutout parts sheet for future Spine-style rigging, target asset {asset_id}
Primary request: Create separated cutout parts for {character_name}: {parts}. All parts must match one character design and be suitable for later manual rigging.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal.
Style/medium: hand-painted 2D game character parts, ink wash and gongbi-inspired accents, clean edges.
Composition/framing: parts arranged separately in a grid, no overlap, consistent scale, neutral side-view orientation.
Color palette: {palette}; avoid using #00ff00 in the subject.
Constraints: no assembled full pose unless included as a small reference thumbnail, no text labels, no watermark, no background, crisp cutout edges.
Avoid: {global_negative_anchor}
```

## Batch 12 - Promo / LOGO / CG Prompt

```text
Use case: stylized-concept
Asset type: promotional key art / CG concept, target asset {asset_id}
Primary request: Create a polished promotional concept image for Nano Hunter: {promo_scene}. It should present Luna, the demon-suppressing bureau, Buddhist talisman seal magic, and Shanhaijing-inspired threat in one cohesive ancient Chinese dark fantasy composition.
Scene/backdrop: {scene_backdrop}
Style/medium: cinematic 2D illustration, ink wash atmosphere, gongbi detail accents, soft Ori-like glow, not photorealistic.
Composition/framing: {composition}; leave safe space if later title treatment is needed.
Color palette: moon white, ink teal, cyan-white glow, vermilion accents, muted gold, dark miasma purple/green.
Constraints: no final logo text baked in unless explicitly requested, no watermark, no modern sci-fi, no biotech lab.
Avoid: {global_negative_anchor}
```

## Batch 13 - Narrative Storyboard Prompt

```text
Use case: illustration-story
Asset type: narrative storyboard sheet, target asset {asset_id}
Primary request: Create a 6-panel storyboard sheet for {story_moment}. The panels should communicate the story beat clearly without readable dialogue text. Use Luna, demon-suppressing bureau symbols, Buddhist talisman magic, shrine ruins, miasma marsh, or Seal Guardian imagery as appropriate.
Scene/backdrop: ancient Chinese dark fantasy environments, no modern objects.
Style/medium: rough but polished storyboard concept art, ink wash thumbnails with gongbi accent lines, consistent character silhouette.
Composition/framing: six rectangular panels in a clean grid, no text labels, clear camera staging and readable action.
Color palette: restrained ink wash with cyan-white spiritual glow and vermilion seal accents.
Constraints: no readable text, no speech balloons, no watermark, no logo, no photorealism.
Avoid: {global_negative_anchor}
```

## Naming Reminder

- 原始候选：`assets/source/ai_generated/batch_XX/<asset_id>_candidate_01.png`
- 可接入图像：`assets/art/<category>/<asset_id>_ai01.png`
- Sprite Sheet：`assets/art/characters/<group>/sprite_sheets/<asset_id>_sheet_ai01.png`
- Atlas：`assets/art/atlases/<asset_id>_atlas_ai01.png`
- UI Atlas：`assets/art/ui/atlases/<asset_id>_ui_atlas_ai01.png`
- VFX Atlas：`assets/art/vfx/atlases/<asset_id>_vfx_atlas_ai01.png`
- TileSet：`assets/art/tilesets/<asset_id>_tileset_ai01.png`
- 九宫格：`assets/art/ui/<asset_id>_ninepatch_ai01.png`
