# Full Asset Completion and Atlas Plan

日期：2026-06-19

## Summary

本计划面向长期目标：按照当前项目资产安排，通过 image gen 补齐 Nano Hunter 的完整美术资产族，并最终整理为 Godot 可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集和九宫格图片。

本计划不把所有资产一次性塞进当前 Stage；资产生产仍作为 `Asset Production Track` 并行推进。玩法 Stage 继续使用灰盒 / 占位验证，资产在稳定后分批接入。

## Current Evidence

- 当前仓库已有 Stage12-13 占位 SVG 和 `.import`，但正式 AI / 外部美术尚未落盘。
- `asset-manifest.md` 已有 Batch 00-05 需求，主要覆盖 Alpha Demo polish。
- 2026-06-19 已使用内置 `image_gen` 生成 Batch 01 与全局风格板会话预览，但未找到本地可复制文件路径。
- 2026-06-19 已新增 `scripts/assets/import_imagegen_outputs.py`，用于扫描 `$CODEX_HOME/generated_images`、Codex home 和系统临时目录，并把显式源 PNG 或确认后的最新候选导入 `assets/source/ai_generated/batch_XX/<asset_id>/`。
- 2026-06-19 已新增 `docs/assets/image-gen-prompt-queue.json` 和 `scripts/assets/validate_asset_production_queue.py`，把第一轮核心资产变成可校验的具体生成任务。
- 2026-06-19 已新增 `scripts/assets/export_imagegen_batch_plan.py`，并导出 `Batch 01` 与 `Batch 06` 首轮 image gen production packet。
- 2026-06-19 已新增 `docs/assets/image-gen-preview-log.md`，用于记录内置 image gen 已生成但未落盘的会话预览与扫描证据。
- 当前环境未暴露 `OPENAI_API_KEY`，不能直接使用 CLI/API fallback 生成可落盘图片。

## Batch Expansion

| Batch | 主题 | 目标 |
| --- | --- | --- |
| Batch 00 | 风格锁定 | 统一 Luna、Seal Guardian、符印、区域色板和全局 asset bible |
| Batch 01 | P0 玩法可读资产 | 玩家、Air Dash、Seal Guardian、Boss warning、Recovery Charge |
| Batch 02 | Stage16 UI 与终局反馈 | 主菜单、暂停、重开、完成反馈、终局封印链 |
| Batch 03 | 区域表现资产 | 山门古刹 / 镇妖试炼场与瘴泽妖域背景、tile、props |
| Batch 04 | 音频资产 | SFX、BGM、人声和怪物声 |
| Batch 05 | 动画参考与宣传素材 | 动作参考、Boss 入场、trailer 草案 |
| Batch 06 | 角色与敌人动画帧 | Luna 高帧数动作帧、敌人 / Seal Guardian 动作帧与 sprite sheets |
| Batch 07 | TileSet 与贴图 | 地形 tile、材质贴图、危险池、平台边缘 |
| Batch 08 | UI / Icon Atlas | HUD、菜单、图标、九宫格和 UI atlas |
| Batch 09 | Prop / Equipment Atlas | shrine、gate、符桩、石碑、武器、奖励物 |
| Batch 10 | VFX Atlas | slash、hit、dash、seal、warning、purge 的序列帧 |
| Batch 11 | Spine 拆件图集 | Luna 与 Boss 的后续骨骼动画拆件候选 |
| Batch 12 | Promo / LOGO / CG | LOGO、key art、封面、运营图、CG |
| Batch 13 | Narrative Storyboard | 分镜图、剧情插图、过场氛围图 |

## Work Packages

### WP1 - 可落盘生成入口

- 优先确认内置 `image_gen` 的生成文件路径是否可访问。
- 每次内置 `image_gen` 生成后，先运行 `python scripts/assets/import_imagegen_outputs.py --since-minutes 30 --limit 20` 定位新增候选。
- 如果扫描结果确认是当前资产，使用 `--copy-latest --batch XX --asset-id <asset_id>` 导入候选；如果用户手动保存了预览图，则使用 `--source <path>` 显式导入。
- 导入后的原始候选默认位于 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`，该目录按存储策略不进入普通 Git。
- 如果只得到会话预览且扫描不到文件，把 `asset_id`、prompt 来源、视觉评审和扫描命令记录到 `docs/assets/image-gen-preview-log.md`。
- 若不可访问，需用户确认使用 CLI/API fallback，并在本机设置 `OPENAI_API_KEY`。
- 只有可落盘后，才把 AI 候选转入 `assets/source/ai_generated/batch_XX/` 或外部资产库。

### WP2 - Asset Matrix 与 Manifest 扩展

- `docs/assets/asset-completion-matrix.md` 作为总控矩阵。
- `docs/assets/image-gen-production-backlog.md` 作为具体 image gen 生产队列。
- `docs/assets/image-gen-prompt-queue.json` 保存第一轮可复制到内置 image gen 的具体 prompt、source_dir、output_path 和 atlas_output_id。
- `scripts/assets/validate_asset_production_queue.py` 校验 queue 与 atlas manifest 不漂移。
- `scripts/assets/export_imagegen_batch_plan.py` 将 queue 导出为可执行 Markdown 批次单。
- `asset-manifest.md` 只记录准备生成或准备接入的具体资产，不一次性登记所有远期可能资产。
- 每个 Batch 开始前，从矩阵抽取具体资产 ID、目标路径、规格和 prompt。

### WP3 - Image Gen 批量生成

- 每个具体资产至少生成 `3-6` 张候选。
- 角色、Boss、背景和宣传图用 Image2 / GPT Image。
- 图标、小符印、状态变体和局部重绘用 Nano Banana / Gemini Image。
- 所有透明资产优先使用 chroma-key 背景，再用本地脚本抠图。
- Luna 动作采用高帧数策略：先用 image gen 生成 `8-12` 帧候选 sheet，再在 Aseprite / Krita 中清稿补到正式帧数；run 推荐 `16-24` 帧，air dash / attack 推荐 `12-16` 帧，death 推荐 `16-24` 帧。

### WP4 - 清稿与规格化

- 角色：统一帧格、朝向、脚底基线和攻击范围读值；Luna 动作不得低帧数交付正式版。
- Tile：固定 cell size，区分碰撞边界、装饰边界和危险边界。
- UI：图标统一线宽、色板和尺寸，面板准备九宫格。
- VFX：序列帧固定尺寸，确保播放时不改变碰撞或误导判定。

### WP5 - Godot 图集化

- Sprite Sheet：角色、敌人、Boss 和 VFX。
- Texture Atlas：props、环境装饰和贴图。
- Tile Set：地形、危险池、墙体、平台边缘。
- UI Atlas：HUD、菜单、图标和九宫格。
- Spine 拆件：先存 PNG 拆件，不默认启用插件。

### WP6 - 接入与验证

- 只生成未接入资产：验证命名、尺寸、透明背景、来源和授权。
- 接入 Godot：运行 `godot --headless --path . --import`。
- 接入 HUD、场景、Boss、音频或完成反馈：执行对应 GUT 或人工复核。
- 改变可试玩表现时，挂到对应 Stage polish / supplement。

## Directory Outputs

| 输出 | 目录 |
| --- | --- |
| 角色 sprite sheet | `assets/art/characters/player/sprite_sheets/` |
| 敌人 / Boss sprite sheet | `assets/art/characters/enemies/sprite_sheets/` |
| TileSet 图 | `assets/art/tilesets/` |
| 通用 Texture Atlas | `assets/art/atlases/` |
| UI Atlas / 九宫格 | `assets/art/ui/atlases/`、`assets/art/ui/` |
| VFX Atlas | `assets/art/vfx/atlases/` |
| Spine 拆件 | `assets/art/spine_parts/` |
| 贴图 | `assets/art/textures/` |
| 宣传图 / LOGO | `assets/art/promo/` |
| 分镜 / 叙事图 | `assets/art/storyboards/` |

## Exit Criteria

- 每个资产类别都有明确目标资产组、生成方式、目标目录和 Godot 产物类型。
- 每个进入接入候选的资产都有 prompt、来源、授权状态和 manifest 记录。
- Batch 06-13 的具体资产都有 asset ID、目标路径和生产顺序。
- 内置 image gen 生成后有明确的扫描 / 导入命令；未找到本地文件时不得把会话预览记为已落盘。
- 第一轮核心资产有可校验 prompt queue，且所有 atlas-linked queue 条目与 `asset-atlas-build-manifest.json` 对齐。
- 至少 `Batch 01` 与 `Batch 06` 已导出 production packet，后续可以逐项复制 prompt 到内置 image gen。
- P0 玩法读值资产优先落盘并完成 Godot import。
- 图集化输出可被 Godot 导入，且不误导碰撞、HUD 布局或流程理解。
- 宣传 / CG / 分镜资产不阻塞可玩 demo，但要与同一风格锚点一致。
