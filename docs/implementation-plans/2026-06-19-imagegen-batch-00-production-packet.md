# Image Gen Production Packet - Batch 00

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`1`
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

### style_board_global_ai01

- Batch: `Batch 00`
- Priority: `P0`
- Target kind: `style_board`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_00/style_board_global_ai01/candidates`
- Output path: `assets/art/promo/style_board_global_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Nano Hunter global visual style board. Create a cohesive style board showing Luna, a Seal Guardian boss silhouette, Buddhist talisman seals, shrine trial stonework, miasma marsh color notes, HUD icon motifs, and VFX swatches. Style: 2D side-view metroidvania, Northern and Southern Dynasties Chinese dark fantasy, demon-suppressing bureau, Shanhaijing monster mythology, ink wash and gongbi accents, soft Ori-like glow. Composition: clean board with grouped visual motifs and no readable labels. Palette: moon white, ink teal, cyan-white spiritual glow, vermilion talisman accents, muted gold, dark miasma purple and green. Constraints: no modern lab, no sci-fi, no watermark, no tiny unreadable clutter.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 00 --asset-id style_board_global_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 00 --asset-id style_board_global_ai01
```
