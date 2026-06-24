# Image Gen Production Packet - Batch 12

日期：2026-06-19

## Summary

本执行单从 `docs/assets/image-gen-prompt-queue.json` 生成，用于逐项复制 prompt 到内置 `image_gen`，再把真实 PNG 导入 Nano Hunter 的资产批次目录。它不是资产完成证明；只有真实 PNG 落盘、筛选、清稿、图集化并验证后，才能更新 manifest 状态。

- 资产条目数：`4`
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

### promo_key_art_sheet_ai01

- Batch: `Batch 12`
- Priority: `P2`
- Target kind: `promo_key_art`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_12/promo_key_art_sheet_ai01/selected_items`
- Output path: `assets/art/promo/promo_key_art_sheet_ai01.png`
- Atlas output id: `promo_key_art_sheet_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: promotional key art concept. Create a cinematic 16:9 key art for Nano Hunter: Luna stands in a ruined shrine gate facing a looming Seal Guardian silhouette in a miasma marsh, Buddhist talisman seals floating between them, cyan-white spiritual glow cutting through ink-dark fog. Style: polished 2D illustration, ink wash atmosphere, gongbi detail accents, soft Ori-like glow. Composition: leave safe title space at top, no final title text. Constraints: no watermark, no modern objects, no sci-fi, no biotech lab, no readable text.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 12 --asset-id promo_key_art_sheet_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 12 --asset-id promo_key_art_sheet_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_12/promo_key_art_sheet_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only promo_key_art_sheet_ai01
```

### nano_hunter_logo_direction_ai01

- Batch: `Batch 12`
- Priority: `P2`
- Target kind: `logo_direction`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_12/nano_hunter_logo_direction_ai01/candidates`
- Output path: `assets/art/promo/nano_hunter_logo_direction_ai01.png`

Prompt to paste into built-in image_gen:

```text
Use case: logo-brand. Asset type: logo direction concept, not final production typography. Create a title-mark direction for Nano Hunter using talisman seal geometry, ink-brush strokes, muted gold and vermilion accents, and ancient Chinese dark fantasy mood. Include an abstract emblem option and a rough wordmark direction; text accuracy is not final and will be manually cleaned later. Constraints: no modern sci-fi logo, no cyberpunk, no watermark, no clutter, readable silhouette, no fake studio marks.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 12 --asset-id nano_hunter_logo_direction_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 12 --asset-id nano_hunter_logo_direction_ai01
```

### capsule_art_alpha_demo_ai01

- Batch: `Batch 12`
- Priority: `P2`
- Target kind: `promo_capsule`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_12/capsule_art_alpha_demo_ai01/selected_items`
- Output path: `assets/art/promo/capsule_art_alpha_demo_ai01.png`
- Atlas output id: `capsule_art_alpha_demo_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: stylized-concept. Asset type: promotional capsule art concept for Nano Hunter Alpha Demo. Create a wide capsule composition with Luna in the foreground, ruined shrine gate and miasma marsh behind her, Seal Guardian silhouette in the distance, cyan-white talisman glow cutting through ink fog, and clear empty safe space for a manually placed title. Style: polished 2D Chinese dark fantasy illustration, ink wash atmosphere, gongbi detail accents, soft Ori-like glow. Composition: wide marketing crop, strong silhouette, title-safe negative space, no final text baked in. Constraints: no readable text, no logo, no watermark, no modern objects, no sci-fi, no biotech lab, no fake store badges.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 12 --asset-id capsule_art_alpha_demo_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 12 --asset-id capsule_art_alpha_demo_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_12/capsule_art_alpha_demo_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only capsule_art_alpha_demo_ai01
```

### cg_seal_guardian_reveal_ai01

- Batch: `Batch 12`
- Priority: `P2`
- Target kind: `cg_illustration`
- Candidate count: `3`
- Source directory: `assets/source/ai_generated/batch_12/cg_seal_guardian_reveal_ai01/selected_items`
- Output path: `assets/art/promo/cg_seal_guardian_reveal_ai01.png`
- Atlas output id: `cg_seal_guardian_reveal_ai01`

Prompt to paste into built-in image_gen:

```text
Use case: illustration-story. Asset type: narrative CG illustration for Nano Hunter. Create a cinematic still of the Seal Guardian reveal: Luna stands small before a massive ancient stone guardian emerging from broken seal chains inside a ruined shrine chamber, cyan-white Buddhist talisman light exposing dark miasma cracks and vermilion locks. Style: polished 2D Chinese dark fantasy CG, ink wash fog, gongbi detail accents, dramatic metroidvania boss reveal. Composition: 16:9, strong depth, readable Luna silhouette, guardian dominates the frame, no title space required. Constraints: no readable text, no speech balloons, no watermark, no modern lab, no sci-fi armor, no gore, no UI frame.
```

After each generated image is saved or detected, import as a raw candidate:

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 12 --asset-id cg_seal_guardian_reveal_ai01
```

If the preview was manually saved to a file, import by explicit path:

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 12 --asset-id cg_seal_guardian_reveal_ai01
```

After review and cleanup, place selected PNGs in `assets/source/ai_generated/batch_12/cg_seal_guardian_reveal_ai01/selected_items` and build the atlas output:

```powershell
python scripts/assets/build_asset_atlases.py --only cg_seal_guardian_reveal_ai01
```
