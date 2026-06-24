# Image Gen Production Packet - Batch 08

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

### hud_core_ui_atlas_ai01

- Batch: `Batch 08`
- Priority: `P0`
- Target kind: `ui_atlas`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_08/hud_core_ui_atlas_ai01/selected_items`
- Output path: `assets/art/ui/atlases/hud_core_ui_atlas_ai01.png`
- Atlas output id: `hud_core_ui_atlas_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: Godot HUD UI atlas. Create separate HUD elements: health seal pips, recovery charge ring, ability slot frame, boss status trim, checkpoint indicator, completion seal, small talisman divider, and soft glow states. Style: crisp 2D game UI, Buddhist talisman circles, bamboo-slip shapes, moon-white paper, ink-teal outlines, cyan-white glow, vermilion accents, muted gold. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no readable text, no letters, no numbers, no modern app UI, no watermark, do not use #00ff00 in the items.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 08 --asset-id hud_core_ui_atlas_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 08 --asset-id hud_core_ui_atlas_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_08/hud_core_ui_atlas_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only hud_core_ui_atlas_ai01
```

### icon_sheet_core_ai01

- Batch: `Batch 08`
- Priority: `P0`
- Target kind: `icon_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_08/icon_sheet_core_ai01/selected_items`
- Output path: `assets/art/ui/atlases/icon_sheet_core_ai01.png`
- Atlas output id: `icon_sheet_core_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: 64x64 game icon sheet. Create separate icons for Air Dash, Recovery Charge, checkpoint shrine, sealed gate, boss warning, talisman relay, corruption purge, and demo completion. Style: ancient Chinese dark fantasy UI, Buddhist seal geometry, moon-white paper, ink-teal outline, cyan-white glow, vermilion seal accents. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no readable text, no letters, no numbers, no modern UI symbols, no watermark, icons readable at 32x32.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 08 --asset-id icon_sheet_core_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 08 --asset-id icon_sheet_core_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_08/icon_sheet_core_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only icon_sheet_core_ai01
```

### menu_ninepatch_ui_ai01

- Batch: `Batch 08`
- Priority: `P0`
- Target kind: `ninepatch_sheet`
- Candidate count: `6`
- Source directory: `assets/source/ai_generated/batch_08/menu_ninepatch_ui_ai01/selected_items`
- Output path: `assets/art/ui/menu_ninepatch_ui_ai01.png`
- Atlas output id: `menu_ninepatch_ui_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: NinePatch UI panel source. Create stretchable menu and dialog panel pieces: large paper panel, dark shrine stone panel, small tooltip panel, button frame, and divider strip. Style: crisp 2D UI, moon-white talisman paper, ink-teal brush border, muted gold trim, subtle vermilion seal corners. Background: perfectly flat solid #00ff00 chroma-key. Constraints: no text, no letters, no numbers, no modern app card, no watermark, corners and borders should support nine-slice cleanup.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 08 --asset-id menu_ninepatch_ui_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 08 --asset-id menu_ninepatch_ui_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_08/menu_ninepatch_ui_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only menu_ninepatch_ui_ai01
```
