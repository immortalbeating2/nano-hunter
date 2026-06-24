# Image Gen Production Packet - Batch 07

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`3`
- Atlas-linked 条目数：`3`
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

### miasma_marsh_tileset_ai01

- Batch: `Batch 07`
- Priority: `P0`
- Target kind: `tileset_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_07/miasma_marsh_tileset_ai01/selected_tiles`
- Output path: `assets/art/tilesets/miasma_marsh_tileset_ai01.png`
- Atlas output id: `miasma_marsh_tileset_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Godot 2D TileSet source sheet. Create tile concepts for miasma marsh: safe ground, platform edge, wall, inner corner, outer corner, hanging root, corrupted water hazard edge, and decorative stone seal fragments. Style: hand-painted side-view metroidvania, ancient Chinese dark fantasy, ink wash surfaces, gongbi line accents. Background: clean tile sheet layout on flat #00ff00 chroma-key or neutral matte. Constraints: no text, no watermark, no modern lab shapes, no sci-fi panels, collision edges must read clearly, hazards must be visually distinct from safe ground.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 07 --asset-id miasma_marsh_tileset_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 07 --asset-id miasma_marsh_tileset_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_07/miasma_marsh_tileset_ai01/selected_tiles` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only miasma_marsh_tileset_ai01
```

### shrine_trial_tileset_ai01

- Batch: `Batch 07`
- Priority: `P1`
- Target kind: `tileset_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_07/shrine_trial_tileset_ai01/selected_tiles`
- Output path: `assets/art/tilesets/shrine_trial_tileset_ai01.png`
- Atlas output id: `shrine_trial_tileset_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Godot 2D TileSet source sheet for Nano Hunter shrine trial rooms. Create modular side-view tiles for ancient shrine ground, platform edge, vertical wall, inner corner, outer corner, cracked stair stone, carved Buddhist seal floor, mossy roof tile, hanging talisman strip, and broken stone trim. Style: hand-painted metroidvania, Northern and Southern Dynasties Chinese dark fantasy, ink wash stone surfaces, gongbi line accents, moon-white and ink-teal lighting with restrained vermilion seal marks. Background: clean tile sheet layout on flat #00ff00 chroma-key or neutral matte. Constraints: no readable text, no watermark, no modern lab shapes, no sci-fi panels, collision edges must read clearly, safe ground and decorative trim must be easy to separate.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 07 --asset-id shrine_trial_tileset_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 07 --asset-id shrine_trial_tileset_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_07/shrine_trial_tileset_ai01/selected_tiles` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only shrine_trial_tileset_ai01
```

### material_texture_atlas_ai01

- Batch: `Batch 07`
- Priority: `P1`
- Target kind: `texture_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_07/material_texture_atlas_ai01/selected_items`
- Output path: `assets/art/textures/material_texture_atlas_ai01.png`
- Atlas output id: `material_texture_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: hand-painted material texture atlas for Nano Hunter 2D environments. Create separate square material swatches for aged shrine stone, wet miasma mud, dark lacquered wood, moon-white talisman paper, tarnished bronze, mossy root bark, corrupted water surface, and cracked seal-carved stone. Style: 2D Chinese dark fantasy metroidvania materials, ink wash softness, gongbi accent lines, soft cyan spiritual glow and vermilion seal hints where appropriate. Background: clean atlas layout on flat #00ff00 chroma-key or neutral matte. Constraints: no readable text, no watermark, no PBR realism, no sci-fi panels, no modern lab materials, swatches must tile or crop cleanly for Godot texture usage.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 07 --asset-id material_texture_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 07 --asset-id material_texture_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_07/material_texture_atlas_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only material_texture_atlas_ai01
```
