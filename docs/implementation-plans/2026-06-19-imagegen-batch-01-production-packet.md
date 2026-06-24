# Image Gen Production Packet - Batch 01

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`8`
- Atlas-linked 条目数：`0`
- 生成方式：Codex 内置 `image_gen` 优先
- 原始候选默认位置：`assets/source/ai_generated/batch_XX/<asset_id>/candidates/` 或外部资产库

## Batch Rules

- 每个 asset 先生成 queue 指定数量的候选。
- 每次生成后先运行导入命令；扫描不到本地文件时，不把会话预览记为已落盘。
- 透明类资产优先使用 #00ff00 chroma-key 背景，再本地去背景。
- 只有入选并清稿后的 PNG 才进入 `selected_frames`、`selected_items`、`selected_tiles`、`selected_parts` 或 `selected_panels`。
- 接入 Godot 前必须回填来源、prompt、授权和状态。

## Global Style Anchor

```text
2D side-view metroidvania game asset for Nano Hunter, Northern and Southern Dynasties inspired Chinese dark fantasy, demon-suppressing bureau bounty hunter world, Buddhist talisman seal magic, Shanhaijing monster mythology, ink wash and gongbi-inspired color accents, soft Ori-like glow, clean readable silhouette, high gameplay readability at 640x360, moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, no watermark.
```

## Global Negative Anchor

```text
Avoid photorealistic rendering, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, modern warning sign, excessive tiny detail, blurry edges, noisy background, gore, watermark, and readable text unless the asset is explicitly a logo direction.
```

## Assets

### stage16_luna_player_readability_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `character_direction`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage16_luna_player_readability_ai01/candidates`
- Output path: `assets/art/characters/player/stage16_luna_player_readability_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Luna player readability concept. Create a clean side-view playable character direction for Luna, a demon-suppressing bureau bounty hunter with hidden Buddhist demon-hybrid identity. She should read clearly at 640x360 gameplay distance, with moon-white clothing, ink-teal cloth and hair accents, cyan-white talisman glow, small vermilion seal papers, light weapon or charm silhouette, and agile metroidvania proportions. Background: perfectly flat solid #00ff00 chroma-key for removal. Constraints: one character only, no text, no watermark, no modern armor, no sci-fi, no background scene, no cast shadow, do not use #00ff00 in the subject.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage16_luna_player_readability_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage16_luna_player_readability_ai01
```

### stage14_air_dash_icon_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `icon`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage14_air_dash_icon_ai01/candidates`
- Output path: `assets/art/ui/stage14_air_dash_icon_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 64x64 HUD icon source. Create a readable Air Dash ability icon using a compact Luna silhouette, Buddhist talisman ring, cyan-white horizontal motion streak, and tiny vermilion seal spark. Style: crisp 2D game UI, ancient Chinese dark fantasy, ink-teal outline, moon-white paper, muted gold trim. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no readable text, no letters, no numbers, no watermark, no modern app UI, no sci-fi arrow, do not use #00ff00 in the icon.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage14_air_dash_icon_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage14_air_dash_icon_ai01
```

### stage14_air_dash_trail_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `vfx_direction`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage14_air_dash_trail_ai01/candidates`
- Output path: `assets/art/vfx/stage14_air_dash_trail_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Air Dash VFX source. Create a horizontal dash trail made of cyan-white talisman energy, ink-brush streaks, small vermilion seal sparks, and faint moon-white afterimage arcs. It must be readable as movement, not damage. Background: perfectly flat solid #00ff00 chroma-key. Composition: VFX only, centered, generous padding, no character body. Constraints: no text, no watermark, no floor plane, no sci-fi laser, no noisy smoke blob, do not use #00ff00 in the effect.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage14_air_dash_trail_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage14_air_dash_trail_ai01
```

### stage14_air_dash_shrine_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `prop`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage14_air_dash_shrine_ai01/candidates`
- Output path: `assets/art/props/stage14_air_dash_shrine_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: ability shrine prop. Create a side-view Air Dash shrine for a shrine trial room: aged stone altar, Buddhist talisman circle, hanging seal paper, muted gold bronze rim, cyan-white energy hovering above it, and inactive / active readability potential. Background: perfectly flat solid #00ff00 chroma-key. Style: hand-painted 2D metroidvania prop, Northern and Southern Dynasties Chinese dark fantasy. Constraints: no readable text, no modern machine, no sci-fi capsule, no watermark, do not use #00ff00 in the prop.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage14_air_dash_shrine_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage14_air_dash_shrine_ai01
```

### stage14_air_dash_gate_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `prop`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage14_air_dash_gate_ai01/candidates`
- Output path: `assets/art/props/stage14_air_dash_gate_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: ability gate prop. Create an Air Dash gate obstacle for a 2D metroidvania room: stone arch, talisman barrier, cyan-white horizontal dash channel, vermilion seal locks, and clear passable-after-air-dash visual language. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no text, no warning label, no sci-fi door, no modern lab, no watermark, readable silhouette, do not use #00ff00 in the prop.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage14_air_dash_gate_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage14_air_dash_gate_ai01
```

### stage15_seal_guardian_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `boss_direction`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage15_seal_guardian_ai01/candidates`
- Output path: `assets/art/characters/enemies/stage15_seal_guardian_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Seal Guardian boss direction. Create a large side-view boss creature made of ancient stone armor, Buddhist seal chains, beast-mask silhouette, Shanhaijing-inspired guardian anatomy, cyan-white seal core, muted gold edges, and dark miasma cracks. It must read as powerful but fair in a 2D metroidvania boss room. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no gore, no modern biotech, no sci-fi armor, no text, no watermark, do not use #00ff00 in the boss.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage15_seal_guardian_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage15_seal_guardian_ai01
```

### stage15_boss_attack_warning_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `vfx_warning`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage15_boss_attack_warning_ai01/candidates`
- Output path: `assets/art/vfx/stage15_boss_attack_warning_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: boss attack warning VFX. Create a readable warning marker made of vermilion Buddhist seal geometry, dark ink brush pulse, cyan-white edge glow, and aggressive but non-modern danger language. Background: perfectly flat solid #00ff00 chroma-key. Composition: VFX only, centered, readable at small size. Constraints: no exclamation mark, no readable text, no modern warning triangle, no sci-fi hologram, no watermark, do not use #00ff00 in the effect.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage15_boss_attack_warning_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage15_boss_attack_warning_ai01
```

### stage15_recovery_charge_icon_ai01

- Batch: `Batch 01`
- Priority: `P0`
- Target kind: `icon`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_01/stage15_recovery_charge_icon_ai01/candidates`
- Output path: `assets/art/ui/stage15_recovery_charge_icon_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 64x64 Recovery Charge HUD icon source. Create a compact healing / recovery charge icon using a lotus-shaped Buddhist seal, cyan-white refill glow, moon-white talisman paper, and vermilion stamp accent. Style: crisp ancient Chinese fantasy UI, readable at 32x32. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no medical cross, no battery icon, no readable text, no letters, no watermark, do not use #00ff00 in the icon.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage15_recovery_charge_icon_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage15_recovery_charge_icon_ai01
```
