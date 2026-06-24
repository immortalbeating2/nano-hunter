# Image Gen Production Packet - Batch 06

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`5`
- Atlas-linked 条目数：`5`
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

### luna_run_sheet_ai01

- Batch: `Batch 06`
- Priority: `P0`
- Target kind: `sprite_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/selected_frames`
- Output path: `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
- Atlas output id: `luna_run_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: high-frame-count 2D protagonist run sprite sheet. Create a 12-frame candidate run cycle sheet for Luna, later cleaned and extended to 16-24 frames. Keep identical proportions, costume, moon-white and ink-teal palette, cyan-white talisman glow, vermilion seal accents, hair and sash follow-through. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular 12-frame grid, fixed 160x160 cell feel, facing right, fixed foot baseline, no frame overlap, no frame numbers, no labels. Constraints: Luna only, no enemies, no background, no text, no watermark, no costume drift, no scale drift, do not use #00ff00 in Luna.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 06 --asset-id luna_run_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 06 --asset-id luna_run_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only luna_run_sheet_ai01
```

### luna_air_dash_sheet_ai01

- Batch: `Batch 06`
- Priority: `P0`
- Target kind: `sprite_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/selected_frames`
- Output path: `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
- Atlas output id: `luna_air_dash_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D protagonist air dash sprite sheet. Create a 12-frame candidate air dash action for Luna, later cleaned to 12-16 frames. Motion: compact anticipation, explosive horizontal dash, talisman paper and sash follow-through, cyan-white trail implied but not hiding silhouette. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular grid, fixed 192x160 cell feel, facing right, fixed centerline, no frame numbers, no labels. Constraints: Luna only, no background, no text, no watermark, no costume drift, no scale drift, do not use #00ff00 in Luna.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 06 --asset-id luna_air_dash_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 06 --asset-id luna_air_dash_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_06/luna_air_dash_sheet_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only luna_air_dash_sheet_ai01
```

### luna_attack_01_sheet_ai01

- Batch: `Batch 06`
- Priority: `P0`
- Target kind: `sprite_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/selected_frames`
- Output path: `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
- Atlas output id: `luna_attack_01_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D protagonist attack sprite sheet. Create a 12-frame candidate basic attack for Luna, later cleaned to 12-16 frames. Motion: anticipation, active slash with ritual blade or charm arc, recovery, clear attack timing, cyan-white seal slash with vermilion spark accents. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular grid, fixed 192x160 cell feel, facing right, fixed foot baseline, no frame numbers, no labels. Constraints: Luna only, no enemies, no background, no text, no watermark, no costume drift, do not use #00ff00 in Luna.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 06 --asset-id luna_attack_01_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 06 --asset-id luna_attack_01_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only luna_attack_01_sheet_ai01
```

### luna_idle_sheet_ai01

- Batch: `Batch 06`
- Priority: `P0`
- Target kind: `sprite_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_06/luna_idle_sheet_ai01/selected_frames`
- Output path: `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png`
- Atlas output id: `luna_idle_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D protagonist idle sprite sheet. Create a 12-frame candidate idle cycle for Luna, later cleaned to 12-16 frames. Motion: breathing, subtle sash movement, talisman paper flutter, quiet cyan-white seal pulse. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular grid, fixed 160x160 cell feel, facing right, fixed foot baseline, no frame numbers, no labels. Constraints: Luna only, no background, no text, no watermark, no costume drift, no scale drift, do not use #00ff00 in Luna.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 06 --asset-id luna_idle_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 06 --asset-id luna_idle_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_06/luna_idle_sheet_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only luna_idle_sheet_ai01
```

### seal_guardian_boss_sheet_ai01

- Batch: `Batch 06`
- Priority: `P0`
- Target kind: `sprite_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/selected_frames`
- Output path: `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.png`
- Atlas output id: `seal_guardian_boss_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Seal Guardian boss attack sprite sheet. Create a 12-frame candidate boss attack sequence: idle wind-up, seal chain lift, heavy slam or sweeping seal strike, recovery. Boss design: ancient stone beast-mask guardian, Buddhist seal chains, cyan-white core, vermilion locks, dark miasma cracks. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular grid, fixed 256x192 cell feel, side-view, no frame numbers, no labels. Constraints: no text, no watermark, no gore, no sci-fi armor, no modern lab, do not use #00ff00 in the boss.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 06 --asset-id seal_guardian_boss_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 06 --asset-id seal_guardian_boss_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only seal_guardian_boss_sheet_ai01
```
