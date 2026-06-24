# Image Gen Production Packet - Batch 11

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`2`
- Atlas-linked 条目数：`2`
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

### luna_spine_parts_ai01

- Batch: `Batch 11`
- Priority: `P1`
- Target kind: `spine_cutout_parts`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_11/luna_spine_parts_ai01/selected_parts`
- Output path: `assets/art/spine_parts/luna_spine_parts_ai01.png`
- Atlas output id: `luna_spine_parts_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D character cutout parts sheet for future Spine-style rigging. Create separated parts for Luna: head, hair front, hair back, torso, upper arms, forearms, hands, thighs, calves, feet, sash, talisman papers, weapon or charm. All parts must match the same character design and palette. Background: perfectly flat solid #00ff00 chroma-key. Composition: parts arranged separately in a grid, no overlap, no labels. Constraints: no assembled full animation, no readable text, no watermark, no costume drift, do not use #00ff00 in parts.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 11 --asset-id luna_spine_parts_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 11 --asset-id luna_spine_parts_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_11/luna_spine_parts_ai01/selected_parts` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only luna_spine_parts_ai01
```

### seal_guardian_spine_parts_ai01

- Batch: `Batch 11`
- Priority: `P2`
- Target kind: `spine_cutout_parts`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_11/seal_guardian_spine_parts_ai01/selected_parts`
- Output path: `assets/art/spine_parts/seal_guardian_spine_parts_ai01.png`
- Atlas output id: `seal_guardian_spine_parts_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D boss cutout parts sheet for future Spine-style rigging in Nano Hunter. Create separated parts for the Seal Guardian: beast-mask head, stone torso core, left and right shoulders, upper arms, forearms, claw hands, seal chains, talisman locks, back armor plates, legs or base stones, cyan-white seal core, and miasma crack fragments. Style: ancient stone beast guardian, Buddhist seal chains, Shanhaijing-inspired silhouette, Chinese dark fantasy, muted gold trim, vermilion locks, cyan spiritual glow. Background: perfectly flat solid #00ff00 chroma-key. Composition: parts arranged separately in a tidy grid, no overlap, no labels, no assembled full animation. Constraints: no readable text, no watermark, no sci-fi armor, no modern biotech, no gore, do not use #00ff00 in parts.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 11 --asset-id seal_guardian_spine_parts_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 11 --asset-id seal_guardian_spine_parts_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_11/seal_guardian_spine_parts_ai01/selected_parts` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only seal_guardian_spine_parts_ai01
```
