# TileSet 切片完整性审计 - 2026-07-06

- 审计输出数：`27`
- 当前正式运行道路资产：`dac_formal_terrain_tileset_ai01_64`
- 当前 worktree 中缺少 source_dir、无法做源图逐张对比的输出数：`26`

## 重点结论

### miasma_marsh_tileset_ai01

- 类型 / 批次：`tileset_sheet` / `Batch 07`
- 切片数：`48`，贴边切片：`46` (`0.9583`)
- 当前 source_dir 是否存在：`False`
- 生产运行目录引用文件数：`13`
- 房间节点可见 / 隐藏：`0` / `13`
- 当前处理结论：`keep_as_hidden_preview_or_source_only`
- 是否需要重生：`not_now; regenerate only as a new biome-specific formal terrain kit`

### shrine_trial_tileset_ai01

- 类型 / 批次：`tileset_sheet` / `Batch 07`
- 切片数：`48`，贴边切片：`47` (`0.9792`)
- 当前 source_dir 是否存在：`False`
- 生产运行目录引用文件数：`11`
- 房间节点可见 / 隐藏：`0` / `11`
- 当前处理结论：`keep_as_hidden_preview_or_source_only`
- 是否需要重生：`not_now; regenerate only as a new biome-specific formal terrain kit`

### dac_formal_terrain_tileset_ai01_64

- 类型 / 批次：`tileset_sheet` / `DAC-06`
- 切片数：`48`，贴边切片：`0` (`0.0`)
- 当前 source_dir 是否存在：`False`
- 生产运行目录引用文件数：`39`
- 房间节点可见 / 隐藏：`78` / `0`
- 当前处理结论：`active_limited_formal_ground_palette`
- 是否需要重生：`partial; keep flat stone cells, regenerate missing stairs/cliffs/door transitions if needed`

## 判读说明

- `edge_touch_cells` 表示不透明像素贴到 cell 边界。对地形连接块这可能是刻意的，但它也证明该格不适合当作独立 prop 或无脑连续平地使用。
- `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 是 Batch07 第一版 editor/source TileSet，不应在没有手工 terrain 规则和边缘拟合的情况下承担正式道路主体。
- 当前正式道路主体是 `dac_formal_terrain_tileset_ai01_64`。它可保留用于平地石板循环，但台阶、断崖、门口衔接仍应按新的正式 terrain kit 规则补齐或重生。
- 许多已生成资产本来就是 catalog、preview、style board、storyboard、promo 或未来 rigging source；生成不等于必须立即上屏。

## 当前未被 production runtime 直接引用的生成输出

| Asset ID | Kind | Batch | 当前结论 |
| --- | --- | --- | --- |
| `luna_spine_parts_ai01` | `atlas` | `Batch 11` | `catalog_or_candidate` |
| `promo_key_art_sheet_ai01` | `atlas` | `Batch 12` | `catalog_or_candidate` |
| `storyboard_narrative_sheet_ai01` | `atlas` | `Batch 13` | `catalog_or_candidate` |
| `seal_guardian_spine_parts_ai01` | `atlas` | `Batch 11` | `catalog_or_candidate` |
| `capsule_art_alpha_demo_ai01` | `atlas` | `Batch 12` | `catalog_or_candidate` |
| `cg_seal_guardian_reveal_ai01` | `atlas` | `Batch 12` | `catalog_or_candidate` |
| `storyboard_intro_bounty_ai01` | `atlas` | `Batch 13` | `catalog_or_candidate` |
| `storyboard_miasma_marsh_ai01` | `atlas` | `Batch 13` | `catalog_or_candidate` |
