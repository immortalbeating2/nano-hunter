# Image Gen Production Packet - Batch 10

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

### vfx_seal_magic_atlas_ai01

- Batch: `Batch 10`
- Priority: `P0`
- Target kind: `vfx_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_10/vfx_seal_magic_atlas_ai01/selected_frames`
- Output path: `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png`
- Atlas output id: `vfx_seal_magic_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D VFX sequence sheet. Create VFX frames for seal magic: Air Dash trail, talisman relay pulse, corruption purge burst, boss warning pulse, hit spark, and slash arc. Style: ink-brush motion, cyan-white spiritual energy, vermilion seal sparks, dark miasma accents, crisp readable timing. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular frame grid, fixed center point, generous padding. Constraints: VFX only, no text, no watermark, no sci-fi laser, no excessive particle noise.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 10 --asset-id vfx_seal_magic_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 10 --asset-id vfx_seal_magic_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_10/vfx_seal_magic_atlas_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only vfx_seal_magic_atlas_ai01
```

### vfx_combat_atlas_ai01

- Batch: `Batch 10`
- Priority: `P1`
- Target kind: `vfx_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_10/vfx_combat_atlas_ai01/selected_frames`
- Output path: `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png`
- Atlas output id: `vfx_combat_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 2D combat VFX sequence sheet for Nano Hunter. Create separate frame groups for basic slash arc, enemy hit spark, boss impact burst, guard break flash, recovery charge pickup sparkle, and short warning pulse. Style: crisp metroidvania VFX, ink-brush motion, cyan-white spiritual energy, vermilion talisman sparks, dark miasma impact accents, readable timing and silhouettes at 640x360. Background: perfectly flat solid #00ff00 chroma-key. Composition: regular frame grid, fixed center point, generous padding, VFX only. Constraints: no readable text, no numbers, no watermark, no sci-fi laser, no modern warning icon, no excessive particle noise, do not use #00ff00 in the effects.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 10 --asset-id vfx_combat_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 10 --asset-id vfx_combat_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_10/vfx_combat_atlas_ai01/selected_frames` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only vfx_combat_atlas_ai01
```
