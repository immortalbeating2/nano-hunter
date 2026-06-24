# Image Gen Production Packet - Batch 13

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

### storyboard_narrative_sheet_ai01

- Batch: `Batch 13`
- Priority: `P2`
- Target kind: `storyboard_sheet`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_13/storyboard_narrative_sheet_ai01/selected_panels`
- Output path: `assets/art/storyboards/storyboard_narrative_sheet_ai01.png`
- Atlas output id: `storyboard_narrative_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: illustration-story. Asset type: narrative storyboard sheet. Create a 6-panel storyboard for Luna accepting a demon-suppression bounty, entering shrine ruins, discovering miasma corruption, triggering a talisman gate, confronting the Seal Guardian, and purging the seal chain. Style: rough but polished ink-wash storyboard thumbnails with gongbi accents and cyan-white spiritual glow. Composition: six clean panels in a grid, clear camera staging, no dialogue. Constraints: no readable text, no speech balloons, no watermark, no modern objects, no sci-fi.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 13 --asset-id storyboard_narrative_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 13 --asset-id storyboard_narrative_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_13/storyboard_narrative_sheet_ai01/selected_panels` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only storyboard_narrative_sheet_ai01
```

### storyboard_intro_bounty_ai01

- Batch: `Batch 13`
- Priority: `P2`
- Target kind: `storyboard_sheet`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_13/storyboard_intro_bounty_ai01/selected_panels`
- Output path: `assets/art/storyboards/storyboard_intro_bounty_ai01.png`
- Atlas output id: `storyboard_intro_bounty_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: illustration-story. Asset type: intro bounty storyboard sheet for Nano Hunter. Create a 6-panel storyboard showing Luna receiving a demon-suppression bounty from the demon-suppressing bureau, inspecting a talisman warrant, preparing her charm weapon, leaving a rain-dark town gate, crossing into shrine ruins, and noticing the first miasma glow. Style: rough but polished ink-wash storyboard thumbnails, Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal motifs, cyan-white spiritual glow, vermilion accents. Composition: six clean panels in a grid, clear cinematic staging, no dialogue balloons, no captions, no labels. Constraints: no readable text, no watermark, no modern city, no sci-fi, no biotech lab.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 13 --asset-id storyboard_intro_bounty_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 13 --asset-id storyboard_intro_bounty_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_13/storyboard_intro_bounty_ai01/selected_panels` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only storyboard_intro_bounty_ai01
```

### storyboard_miasma_marsh_ai01

- Batch: `Batch 13`
- Priority: `P2`
- Target kind: `storyboard_sheet`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_13/storyboard_miasma_marsh_ai01/selected_panels`
- Output path: `assets/art/storyboards/storyboard_miasma_marsh_ai01.png`
- Atlas output id: `storyboard_miasma_marsh_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: illustration-story. Asset type: miasma marsh storyboard sheet for Nano Hunter. Create a 6-panel storyboard showing Luna entering the miasma marsh, reading corrupted water as a hazard, discovering broken Buddhist seal stones, activating a talisman relay pillar, seeing miasma lift from a shrine gate, and revealing a safe path forward. Style: rough but polished ink-wash storyboard thumbnails, Chinese dark fantasy metroidvania, Shanhaijing miasma mood, cyan-white seal glow, muted jade marsh and vermilion talisman sparks. Composition: six clean panels in a grid, clear camera staging and gameplay readability, no dialogue balloons, no captions, no labels. Constraints: no readable text, no watermark, no modern objects, no sci-fi panels, no biotech lab.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 13 --asset-id storyboard_miasma_marsh_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 13 --asset-id storyboard_miasma_marsh_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_13/storyboard_miasma_marsh_ai01/selected_panels` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only storyboard_miasma_marsh_ai01
```
