# Image Gen Production Packet - Batch 09

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

### shrine_gate_prop_atlas_ai01

- Batch: `Batch 09`
- Priority: `P1`
- Target kind: `prop_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_09/shrine_gate_prop_atlas_ai01/selected_items`
- Output path: `assets/art/atlases/shrine_gate_prop_atlas_ai01.png`
- Atlas output id: `shrine_gate_prop_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: prop atlas. Create separate side-view props: ability shrine inactive, ability shrine active, sealed gate locked, sealed gate open, talisman relay pillar, corruption purge stone, checkpoint lantern, ancient stone tablet. Style: hand-painted 2D metroidvania props, Northern and Southern Dynasties Chinese dark fantasy, Buddhist seal magic, aged stone, dark wood, moon-white paper, cyan spiritual glow, vermilion seals. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no readable text, no modern machinery, no sci-fi door, no watermark.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 09 --asset-id shrine_gate_prop_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 09 --asset-id shrine_gate_prop_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_09/shrine_gate_prop_atlas_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only shrine_gate_prop_atlas_ai01
```

### equipment_pickup_atlas_ai01

- Batch: `Batch 09`
- Priority: `P1`
- Target kind: `equipment_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_09/equipment_pickup_atlas_ai01/selected_items`
- Output path: `assets/art/atlases/equipment_pickup_atlas_ai01.png`
- Atlas output id: `equipment_pickup_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: equipment and pickup atlas for Nano Hunter. Create separate side-view pickups and small equipment props: talisman charm, seal fragment, recovery charge shard, jade token, spirit lantern core, monk-thread bracelet, ritual blade charm, and purified miasma crystal. Style: hand-painted 2D metroidvania item art, Northern and Southern Dynasties Chinese dark fantasy, Buddhist talisman seal magic, moon-white paper, ink-teal outline, cyan-white spiritual glow, muted gold metal, vermilion seal accents. Background: perfectly flat solid #00ff00 chroma-key with generous padding. Constraints: no readable text, no letters, no modern tech item, no sci-fi battery, no watermark, readable at small pickup size, do not use #00ff00 in items.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 09 --asset-id equipment_pickup_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 09 --asset-id equipment_pickup_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_09/equipment_pickup_atlas_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only equipment_pickup_atlas_ai01
```
