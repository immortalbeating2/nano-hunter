# Runtime Source Regeneration Packet / 运行时来源重生图执行包

本执行包用于把只来自 review-required 候选的运行时 UI / VFX 资产重新生成 Nano Hunter 专属候选。它不是生成完成证明；只有 PNG 真实落盘、导入候选池、通过来源审计并完成人工审图后，才允许替换 selected source 或 runtime 输出。

## Summary

- Regeneration assets: `9`
- Project key: `nano-hunter`
- Source review strategy: `manual_source_review_or_regenerate`

## Rules

- 优先使用内置 `image_gen`；当前环境无可调用工具时，只执行本 packet 的准备和审计。
- 每个资产生成后保存为对应 `candidate_XX.png`，不要覆盖旧候选。
- 新候选只进入 `assets/source/ai_generated/.../candidates/`，不得直接覆盖 `assets/art/`。
- 导入后先跑 source safety，再决定是否清稿、导出 standalone 或重建 atlas。

## Assets

### stage16_demo_menu_icons_ai01

- Batch: `Batch 02`
- Target kind: `icon_sheet`
- Save as: `assets/source/ai_generated/batch_02/stage16_demo_menu_icons_ai01/candidates/stage16_demo_menu_icons_ai01_candidate_05.png`
- Runtime scenes: `scenes/ui/demo_shell.tscn`
- Current output: `assets/art/ui/stage16_demo_menu_icons_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: Alpha Demo menu icon sheet. Create one clean 2x3 icon sheet with exactly six separate menu icons: pause, continue/play, restart, completion/seal-finished, back arrow, and locked/disabled. Use Buddhist talisman geometry, dark jade enamel, aged bronze-gold trim, pale cyan spirit glow, moon-white parchment accents, and vermilion tassel accents only when useful. Background: perfectly flat solid #ff00ff chroma-key. Composition: strict 2 rows by 3 columns, generous padding, equal spacing, no labels, no letters, no numbers, readable at 48px and 64px. Constraints: no pseudo-text, no signatures, no stamps that look like readable characters, no modern app styling, no sci-fi UI, no watermark, do not use #ff00ff inside icons.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage16_demo_menu_icons_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage16_demo_menu_icons_ai01 --batch 02
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage16_talisman_relay_ai01

- Batch: `Batch 02`
- Target kind: `vfx_sheet`
- Save as: `assets/source/ai_generated/batch_02/stage16_talisman_relay_ai01/candidates/stage16_talisman_relay_ai01_candidate_03.png`
- Runtime scenes: `scenes/rooms/stage16_talisman_relay_room.tscn, scenes/rooms/stage16_corruption_purge_room.tscn`
- Current output: `assets/art/vfx/stage16_talisman_relay_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: talisman relay VFX sheet. Create a compact sequence sheet for a talisman relay activation: dormant seal circle, cyan-white pulse, vermilion talisman sparks, ink-brush light path, relay confirmation burst, and fading purified motes. Background: perfectly flat solid #00ff00 chroma-key. Style: crisp 2D metroidvania VFX, Buddhist seal magic, readable at 640x360. Composition: regular frame groups, fixed center point, VFX only, no labels. Constraints: no readable text, no numbers, no sci-fi hologram, no modern warning signs, no watermark, do not use #00ff00 in effects.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage16_talisman_relay_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage16_talisman_relay_ai01 --batch 02
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage16_alpha_demo_completion_ai01

- Batch: `Batch 02`
- Target kind: `completion_ui`
- Save as: `assets/source/ai_generated/batch_02/stage16_alpha_demo_completion_ai01/candidates/stage16_alpha_demo_completion_ai01_candidate_03.png`
- Runtime scenes: `scenes/rooms/stage16_alpha_demo_end_room.tscn`
- Current output: `assets/art/ui/stage16_alpha_demo_completion_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: Alpha Demo completion UI emblem. Create a completion glyph and small UI panel source: purified Buddhist seal circle, broken miasma chain, moon-white talisman paper, cyan-white completion glow, vermilion stamp accent, muted gold frame. Background: perfectly flat solid #00ff00 chroma-key. Style: crisp 2D game UI for Chinese dark fantasy metroidvania. Composition: centered emblem plus simple panel shape, no final text baked in, no labels. Constraints: no readable text, no letters, no numbers, no modern achievement badge, no watermark, readable at HUD scale, do not use #00ff00 in the emblem.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage16_alpha_demo_completion_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage16_alpha_demo_completion_ai01 --batch 02
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### luna_hit_death_sheet_ai01

- Batch: `Batch 06`
- Target kind: `sprite_sheet`
- Save as: `assets/source/ai_generated/batch_06/luna_hit_death_sheet_ai01/selected_frames/luna_hit_death_sheet_ai01_candidate_01.png`
- Runtime scenes: `scenes/player/player_placeholder.tscn`
- Current output: `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: technical 2D player animation sprite source sheet for Nano Hunter, target asset luna_hit_death_sheet_ai01 candidate 04. Primary request: Create exactly 24 separate full-body animation poses for Luna, the player protagonist, showing one coherent right-facing side-view hit reaction, heavy stagger, collapse, and clean non-gory defeat sequence. Arrange the poses as a strict 8 columns by 3 rows grid. The output must contain twenty-four distinct Luna sprites, no fewer and no extra. Subject: Luna, a young Nanbei dynasty demon-suppressing bounty hunter with long black hair, moon-white layered robe, ink-teal sash and cloth streamers, small vermilion Buddhist talisman papers, subtle cyan-white seal magic glow. Keep identical costume, body proportions, face shape, hair mass, robe colors, and side-view silhouette in all 24 poses. Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal. No floor, no shadow, no scenery. Style/medium: hand-painted 2D metroidvania animation source sheet, ink wash and gongbi-inspired accents, soft Ori-like glow, readable gameplay silhouette, not pixel art, not 3D. Composition/framing: strict 8x3 technical sprite sheet. Each Luna pose must sit alone in its own invisible cell with generous green empty space around it. Keep all talisman papers, hair trails, robe trails, and cyan glow attached to the same pose and inside that pose's cell. Do not let any VFX, paper charm, hair strand, robe cloth, weapon trail, or body part cross into another cell. Stable scale, stable foot baseline before collapse, stable side-view camera across all cells. Full body visible in every frame, no cropped feet, no cropped hair, no cropped robe. Motion sequence: row 1 frames 1-8 light hit reaction and recoil: ready stance, impact flinch, head/shoulder snap back, robe shock, step back, regain balance, second flinch, guard broken. Row 2 frames 9-16 heavy stagger and collapse: stronger impact, body bends forward, one knee buckles, kneel, hand reaches down, talisman glow dims, collapse sideways, near-ground fall. Row 3 frames 17-24 clean non-gory defeat / restart-readable pose: prone recovery attempt, low crouched collapse, lying side pose, talisman papers settle, robe streamers settle, faint seal glow pulse, still defeat pose, final readable restart pose. Every frame must be meaningfully different and ordered left to right, top to bottom. Color palette: moon white robes, ink teal fabric, cyan-white spiritual glow, tiny vermilion talisman accents. Do not use #00ff00 anywhere in Luna, talismans, robe, hair, or VFX. Constraints: Luna only, one full-body Luna sprite per cell, no enemies, no weapons detached from the body, no gore, no blood, no injury detail, no background scene, no cast shadow, no floor plane, no text, no numbers, no labels, no watermark, no logo, no frame borders, no duplicated pose, no mirrored duplicate, no idle-pose repeats, no detached fragments between cells. Avoid: photorealistic, 3D render, chibi, front-facing portrait, modern lab, sci-fi armor, cyberpunk, excessive tiny detail, blurry edges, unreadable silhouette, overlapping frames, cropped body parts, huge VFX arcs crossing cell boundaries, green edge speckles on the sprite.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: luna_hit_death_sheet_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id luna_hit_death_sheet_ai01 --batch 06
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### enemies_core_sheet_ai01

- Batch: `Batch 06`
- Target kind: `sprite_sheet`
- Save as: `assets/source/ai_generated/batch_06/enemies_core_sheet_ai01/selected_frames/enemies_core_sheet_ai01_candidate_01.png`
- Runtime scenes: `scenes/combat/basic_melee_enemy.tscn`
- Current output: `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: technical 2D core enemy roster sprite source sheet for Nano Hunter, target asset enemies_core_sheet_ai01 candidate 06. Primary request: Create exactly 32 separate full-body enemy animation poses for Nano Hunter. Arrange the poses as a strict 8 columns by 4 rows grid. The output must contain thirty-two distinct sprites, no fewer and no extra. Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal. No floor, no shadow, no scenery. Style/medium: clean hand-painted 2D metroidvania enemy sprite sheet, Nanbei dynasty Chinese dark fantasy, Shanhaijing demon mythology, Buddhist talisman seals, ink wash and gongbi accents, readable gameplay silhouettes, restrained detail, not pixel art, not 3D. Composition/framing: strict 8x4 technical sprite sheet. One complete enemy sprite per invisible cell. Each row is one enemy type with 8 ordered animation frames left to right. Stable side-view camera, stable scale inside each row, consistent silhouette and costume within each row. Large empty #00ff00 gutters between all sprites. Keep every robe edge, weapon, talisman paper, smoke wisp, and glow attached to the same enemy body and fully inside that cell. No overlapping frames, no detached fragments between cells, no isolated projectiles, no separate slash arcs, no separate smoke clouds. Row 1 enemy type: basic melee ward guard. Humanoid talisman-mask ward, paper seal over face, ragged monk-warrior robe, short bronze blade held close to body, dark teal cloth, vermilion talismans. Frames 1-8: idle, ready, small step, wind-up with blade close, compact slash with blade close to body, follow-through, recoil, return to guard. No wide slash VFX. Row 2 enemy type: ground charger demon beast. Low quadruped stone-and-miasma beast, cracked teal-gray armor plates, black smoke mane attached to body, bronze bells, vermilion talisman tags, no gore. Frames 9-16: crouch, sniff, paw scrape, charge wind-up, compact lunge, skid, recover, guarded crouch. No long dust trail. Row 3 enemy type: aerial sentinel talisman spirit. Floating lantern-mask spirit with hanging seal papers, small bronze ring, cyan seal core, dark ink smoke lower body attached to body. Frames 17-24: hover idle, bob up, drift forward, charge seal close to chest, tiny glow pulse close to body, recoil, drift back, settle. No detached orb projectile. Row 4 enemy type: miasma caster. Robed corrupted talisman shaman silhouette, long sleeves, seal staff or talisman fan attached to body, dark miasma smoke attached close to robe, cyan cracked seal glow. Frames 25-32: idle, raise sleeve, gather miasma close to hands, cast warning pose, release glow close to body, recoil, lower stance, return idle. No separate cloud projectile. Color palette: dark ink teal, teal-gray stone, moon-white cloth accents, muted bronze, cyan-white seal glow, small vermilion talisman accents, miasma green only in subtle attached smoke. Do not use #00ff00 anywhere in enemies, smoke, glow, talismans, cloth, or weapons. Constraints: exactly four enemy types, exactly one row per enemy type, one enemy sprite per cell, no Luna, no Seal Guardian boss, no extra characters, no background scene, no cast shadow, no floor plane, no text, no numbers, no labels, no watermark, no logo, no frame borders, no duplicated pose, no mirrored duplicate, no cropped body parts, no detached weapons, no detached limbs, no huge VFX crossing cell boundaries. Avoid: photorealistic, 3D render, chibi, cyberpunk, modern laboratory, biotech, sci-fi armor, gore, blood, excessive tiny detail, blurry edges, unreadable silhouette, overlapping frames, mixed enemy type inside a row, wrong enemy type in the final cell, concept drift, scale drift, green edge speckles on sprites.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: enemies_core_sheet_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id enemies_core_sheet_ai01 --batch 06
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage16_pause_panel_ui_ai01

- Batch: `Batch 08`
- Target kind: `ui_panel`
- Save as: `assets/source/ai_generated/batch_08/stage16_pause_panel_ui_ai01/candidates/stage16_pause_panel_ui_ai01_candidate_03.png`
- Runtime scenes: `scenes/ui/demo_shell.tscn`
- Current output: `assets/art/ui/stage16_pause_panel_ui_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: pause menu panel source for Nano Hunter Alpha Demo. Create a reusable game UI panel for a paused state: Buddhist talisman frame, moon-white paper surface, ink-teal brush outline, muted gold trim, subtle cyan-white seal glow, tiny vermilion stamp accents, empty center and button slots for text to be added later in Godot. Background: perfectly flat solid #00ff00 chroma-key for background removal. Composition: one large central panel plus 3 small button plate variants, clean padding, no readable text, no letters, no numbers. Style: crisp 2D Chinese dark fantasy metroidvania UI, not modern app UI. Constraints: no baked labels, no watermark, no sci-fi hologram, no cyberpunk, no modern rectangular glass panel, no clutter, readable at 640x360, do not use #00ff00 in the panel artwork.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage16_pause_panel_ui_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage16_pause_panel_ui_ai01 --batch 08
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage16_completion_panel_ui_ai01

- Batch: `Batch 08`
- Target kind: `ui_panel`
- Save as: `assets/source/ai_generated/batch_08/stage16_completion_panel_ui_ai01/candidates/stage16_completion_panel_ui_ai01_candidate_03.png`
- Runtime scenes: `scenes/ui/demo_shell.tscn`
- Current output: `assets/art/ui/stage16_completion_panel_ui_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: Alpha Demo completion panel source for Nano Hunter. Create a celebratory but restrained completion UI panel: purified Buddhist seal circle, broken miasma chain motif, moon-white talisman paper center, ink-teal frame, muted gold trim, cyan-white completion glow, vermilion stamp accents, and empty title / body zones for text to be added later in Godot. Background: perfectly flat solid #00ff00 chroma-key for removal. Composition: one completion panel, one small seal emblem, one small divider ornament, generous padding, no readable text, no letters, no numbers. Constraints: no modern achievement badge, no sci-fi UI, no watermark, no fake logo, readable at 640x360, do not use #00ff00 in the artwork.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage16_completion_panel_ui_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage16_completion_panel_ui_ai01 --batch 08
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage15_boss_hud_frame_ai01

- Batch: `Batch 08`
- Target kind: `hud_frame`
- Save as: `assets/source/ai_generated/batch_08/stage15_boss_hud_frame_ai01/candidates/stage15_boss_hud_frame_ai01_candidate_03.png`
- Runtime scenes: `scenes/ui/tutorial_hud.tscn`
- Current output: `assets/art/ui/stage15_boss_hud_frame_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: Seal Guardian boss HUD status frame source for Nano Hunter. Create a long horizontal boss health frame and small status glyphs using ancient stone seal geometry, Buddhist ward chains, ink-teal outlines, muted gold trim, cyan-white weak-point glow, vermilion lock accents, and dark miasma crack details. Background: perfectly flat solid #00ff00 chroma-key for removal. Composition: one wide boss status bar frame, two small boss phase markers, one warning seal glyph, no labels, no letters, no numbers. Style: crisp 2D game HUD for Chinese dark fantasy metroidvania. Constraints: no readable text, no modern health bar UI, no sci-fi hologram, no watermark, readable over dark backgrounds at 640x360, do not use #00ff00 in the artwork.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage15_boss_hud_frame_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage15_boss_hud_frame_ai01 --batch 08
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```

### stage14_ability_status_hud_ai01

- Batch: `Batch 08`
- Target kind: `hud_frame`
- Save as: `assets/source/ai_generated/batch_08/stage14_ability_status_hud_ai01/candidates/stage14_ability_status_hud_ai01_candidate_03.png`
- Runtime scenes: `scenes/ui/tutorial_hud.tscn`
- Current output: `assets/art/ui/stage14_ability_status_hud_ai01.png`

Prompt to paste into image_gen:

```text
Use case: stylized-concept. Asset type: player ability and recovery HUD status source for Nano Hunter. Create compact HUD components for Air Dash availability, Recovery Charge readiness, checkpoint status, and small talisman cooldown pips. Visual language: Buddhist talisman circles, moon-white paper chips, ink-teal outlines, cyan-white active glow, muted gold trim, vermilion seal accent for spent / locked state. Background: perfectly flat solid #00ff00 chroma-key for removal. Composition: separate HUD widgets with generous padding, no readable text, no letters, no numbers, no labels. Style: crisp 2D Chinese dark fantasy metroidvania UI, readable at 32x32 and 640x360. Constraints: no modern app icons, no medical cross, no battery symbol, no sci-fi UI, no watermark, do not use #00ff00 in the artwork.

Regeneration pass requirements:
- Project key: nano-hunter. This image must belong to Nano Hunter only.
- Preserve the established Nano Hunter visual direction: Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, demon-suppressing bureau, Shanhaijing monster mythology.
- Keep the asset compatible with the existing Godot target path and current runtime use.
- Use a perfectly flat #00ff00 chroma-key background when the asset is a standalone cutout or UI/VFX source.
- Do not include readable text, watermark, modern laboratory, biotech, sci-fi UI, cyberpunk, or modern app styling.
- Favor clean silhouette, generous padding, and gameplay readability over decorative density.

Global style anchor:
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.

Global negative anchor:
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.

Asset id: stage14_ability_status_hud_ai01
```

After generation:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\generated.png --asset-id stage14_ability_status_hud_ai01 --batch 08
python scripts/assets/audit_imagegen_candidate_pool.py --write-report --strict
python scripts/assets/audit_imagegen_source_safety.py --write-report --strict
python scripts/assets/build_runtime_source_review_queue.py
python scripts/assets/build_runtime_source_regeneration_packet.py
```
