# Nano Hunter Godot Atlas Build Pipeline

Last Updated: 2026-06-24

## 用途

本文件说明如何把 image gen 落盘后的 PNG 候选整理为 Godot 可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、VFX 图集和九宫格图片。

当前阶段重点是建立可执行管线，不伪造任何尚未生成的图片。

## 输入与输出

构建规格：

- `docs/assets/asset-atlas-build-manifest.json`

构建脚本：

- `scripts/assets/build_asset_atlases.py`

目标数量审计脚本：

- `scripts/assets/audit_asset_target_coverage.py`

内置 image gen 输出定位 / 导入脚本：

- `scripts/assets/import_imagegen_outputs.py`

生产队列校验脚本：

- `scripts/assets/validate_asset_production_queue.py`

批次执行单导出脚本：

- `scripts/assets/export_imagegen_batch_plan.py`

候选拆分脚本：

- `scripts/assets/prepare_selected_sources.py`

单体候选导出脚本：

- `scripts/assets/export_standalone_candidates.py`

候选池审计脚本：

- `scripts/assets/audit_imagegen_candidate_pool.py`

资产来源 / prompt / hash 记录生成脚本：

- `scripts/assets/build_asset_provenance.py`

资产来源 / prompt / hash 审计脚本：

- `scripts/assets/audit_asset_provenance.py`

资产运行时 / 发布接入 map 生成脚本：

- `scripts/assets/build_asset_runtime_map.py`

资产运行时 / 发布接入 map 审计脚本：

- `scripts/assets/audit_asset_runtime_map.py`

编辑器 AtlasTexture 资源生成脚本：

- `scripts/assets/build_editor_atlas_textures.py`

编辑器 AtlasTexture 静态审计脚本：

- `scripts/assets/audit_editor_atlas_textures.py`

Godot AtlasTexture 加载审计脚本：

- `scripts/dev/audit_editor_atlas_textures.gd`

Godot TileSet 资源生成脚本：

- `scripts/dev/build_editor_tilesets.gd`

Godot TileSet 加载审计脚本：

- `scripts/dev/audit_editor_tilesets.gd`

Godot StyleBoxTexture 资源生成脚本：

- `scripts/dev/build_editor_styleboxes.gd`

Godot StyleBoxTexture 加载审计脚本：

- `scripts/dev/audit_editor_styleboxes.gd`

Godot UI Theme / skin 规则生成脚本：

- `scripts/dev/build_editor_ui_skin.gd`

Godot UI Theme / skin 规则加载审计脚本：

- `scripts/dev/audit_editor_ui_skin.gd`

Spine-style 拆件导出脚本：

- `scripts/assets/build_spine_cutout_manifests.py`

Spine-style 拆件导出审计脚本：

- `scripts/assets/audit_spine_cutout_manifests.py`

VFX anchor / blend 规则生成脚本：

- `scripts/assets/build_vfx_rules.py`

VFX anchor / blend 规则审计脚本：

- `scripts/assets/audit_vfx_rules.py`

角色 / 敌人动画规则生成脚本：

- `scripts/assets/build_animation_rules.py`

角色 / 敌人动画规则审计脚本：

- `scripts/assets/audit_animation_rules.py`

资产语义标签生成脚本：

- `scripts/assets/build_asset_semantics.py`

资产语义标签审计脚本：

- `scripts/assets/audit_asset_semantics.py`

综合资产包审计脚本：

- `scripts/assets/audit_asset_package.py`

美术接入就绪审计脚本：

- `scripts/assets/audit_art_readiness.py`

Godot 资产 Gallery 生成脚本：

- `scripts/dev/build_imagegen_asset_gallery.gd`

Godot 资产 Gallery 审计脚本：

- `scripts/dev/audit_imagegen_asset_gallery.gd`

Godot 资产 Gallery 渲染烟测脚本：

- `scripts/dev/capture_imagegen_asset_gallery.gd`

Godot 资产节点级接入演示生成脚本：

- `scripts/dev/build_imagegen_asset_integration_showcase.gd`

Godot 资产节点级接入演示审计脚本：

- `scripts/dev/audit_imagegen_asset_integration_showcase.gd`

Godot raw candidate 评审 Gallery 生成脚本：

- `scripts/dev/build_imagegen_candidate_review_gallery.gd`

Godot raw candidate 评审 Gallery 审计脚本：

- `scripts/dev/audit_imagegen_candidate_review_gallery.gd`

Godot runtime asset catalog 生成脚本：

- `scripts/dev/build_imagegen_runtime_asset_catalog.gd`

Godot runtime asset catalog 审计脚本：

- `scripts/dev/audit_imagegen_runtime_asset_catalog.gd`

输入目录约定：

- 原始候选仍按 `asset-storage-policy.md` 默认不进入普通 Git。
- 入选帧 / 入选小图放在 `assets/source/ai_generated/batch_XX/<asset_id>/selected_frames/` 或 `selected_items/`。
- 这些目录被 `.gitignore` 忽略，用于本地或外部资产库同步。

输出目录约定：

- 主角 sprite sheet：`assets/art/characters/player/sprite_sheets/`
- 敌人 / Boss sprite sheet：`assets/art/characters/enemies/sprite_sheets/`
- TileSet：`assets/art/tilesets/`
- 通用 Texture Atlas / Prop Atlas：`assets/art/atlases/`
- UI Atlas / 九宫格：`assets/art/ui/atlases/`、`assets/art/ui/`
- VFX Atlas：`assets/art/vfx/atlases/`
- Spine 拆件图集：`assets/art/spine_parts/`
- 贴图：`assets/art/textures/`
- 宣传图：`assets/art/promo/`
- 分镜图：`assets/art/storyboards/`

## 内置 image gen 落盘导入

Codex 内置 `image_gen` 的预期默认落盘位置是 `$CODEX_HOME/generated_images/...`。如果客户端把生成结果保存成可访问 PNG，先用下面命令扫描最近输出：

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 30 --limit 20
```

如果扫描结果确认是本项目的生成图，可以导入最新候选：

```powershell
python scripts/assets/import_imagegen_outputs.py --copy-latest --batch 01 --asset-id stage14_air_dash_icon_ai01
```

如果用户手动保存了会话预览图，或从外部资产库同步了候选图，使用显式路径导入：

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage14_air_dash_icon_ai01
```

项目内手动保存入口为：

```text
assets/source/imagegen_inbox/
```

该目录用于临时接收 Codex Desktop 下载 / 另存的 image_gen 预览图，实际图片默认不进入普通 Git。扫描该 inbox：

```powershell
python scripts/assets/import_imagegen_outputs.py --include-inbox --since-minutes 1440 --limit 50
```

确认图片后仍使用 `--source` 显式导入，避免把无关截图或旧候选误归档到某个 asset id。

如果怀疑客户端把图片缓存为无扩展名文件，或扩展名不可靠，可以用文件头扫描：

```powershell
python scripts/assets/import_imagegen_outputs.py --include-codex-home --include-temp --include-inbox --magic-scan --since-minutes 1440 --limit 50
```

`--magic-scan` 会按 PNG / JPEG / WebP 文件头识别候选，并排除 `.tmp/plugins`、插件缓存、浏览器缓存和 Godot 缓存等噪音目录。扫描结果仍需人工确认，不能因为出现在 Temp 或 clipboard 文件名中就直接归档。

导入默认写入：

```text
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png
```

生成图进入正式 sheet / atlas 前，应由人工筛选后移动或复制到对应 `selected_frames/` 或 `selected_items/`。如果扫描不到本轮生成图，还可以检查 Codex session JSONL 中是否存在 `image_generation_call.result`。该字段是 base64 PNG 结果，可按已确认的 `asset_id` 映射恢复到候选目录；当前项目的 2026-06-19 恢复记录见 `docs/assets/image-gen-session-recovery-log.md`。只有恢复出的真实 PNG 进入 `assets/source/ai_generated/` 后，才可记为原始候选已落盘；这仍不等于 `integrated`。恢复后仍需人工筛选、清稿、切片、去文字、去背景或重排，再复制到对应 `selected_frames/` / `selected_items/`，然后才运行 atlas build。

如果需要先验证完整管线，可用自动拆分脚本把 raw candidate 生成第一版 `selected_*` 源图：

```powershell
python scripts/assets/prepare_selected_sources.py --dry-run
python scripts/assets/prepare_selected_sources.py --overwrite
```

该脚本会优先用绿幕连通区域提取独立帧 / 物件；非绿幕图或 TileSet / 分镜类图会使用保守网格裁切。自动输出文件名带 `auto` 或 `duplicate`，表示它们是管线候选，不是人工清稿结果。

如果要直接抽取到 `asset-atlas-build-manifest.json` 的 `expected_target` 数量，用：

```powershell
python scripts/assets/prepare_selected_sources.py --target target --dry-run
python scripts/assets/prepare_selected_sources.py --target target --overwrite
```

`prepare_selected_sources.py` 支持同一 asset 下存在多个候选：

```text
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_02.png
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_03.png
```

对 component-based sheet / atlas，脚本会按候选编号顺序合并抽取，直到达到 `expected_min` 或 `expected_target`。自动输出文件名会带来源标记，例如 `<asset_id>_auto_001_c01.png`、`<asset_id>_auto_017_c02.png`；只有所有候选都不足时才写出 `<asset_id>_duplicate_*.png` 补位。这样后续补帧不需要覆盖 `candidate_01`，只要追加 `candidate_02+` 并重跑对应 asset 即可。

示例：

```powershell
python scripts/assets/prepare_selected_sources.py --target target --only luna_run_sheet_ai01 --overwrite
python scripts/assets/build_asset_atlases.py --only luna_run_sheet_ai01
python scripts/assets/audit_asset_target_coverage.py --strict
```

不走 atlas manifest 的单体方向稿、风格板、图标、道具、VFX 和 logo direction，可以导出到 queue 的 `output_path`：

```powershell
python scripts/assets/export_standalone_candidates.py --dry-run
python scripts/assets/export_standalone_candidates.py --overwrite
```

## 命令

只检查缺图和配置：

```powershell
python scripts/assets/build_asset_atlases.py --dry-run
```

严格检查，缺少最低帧数时返回失败：

```powershell
python scripts/assets/build_asset_atlases.py --dry-run --strict
```

生成全部第一版候选：

```powershell
python scripts/assets/build_asset_atlases.py
```

只构建一个输出：

```powershell
python scripts/assets/build_asset_atlases.py --only luna_run_sheet_ai01
```

构建全部可满足最低源图数量的输出：

```powershell
python scripts/assets/build_asset_atlases.py
```

校验 image gen prompt queue、source_dir、output_path 与 atlas manifest：

```powershell
python scripts/assets/validate_asset_production_queue.py
```

校验所有 atlas-linked 输出是否达到 `expected_target`，metadata 数量是否匹配，SpriteFrames 是否存在：

```powershell
python scripts/assets/audit_asset_target_coverage.py --strict
```

从 prompt queue 导出执行单：

```powershell
python scripts/assets/export_imagegen_batch_plan.py --batch 06 --date 2026-06-19
```

生成综合资产包审计报告：

```powershell
python scripts/assets/audit_asset_package.py --strict --write-report
```

生成 raw candidate / selected source 使用关系报告：

```powershell
python scripts/assets/audit_imagegen_candidate_pool.py --strict --write-report
```

生成资产来源 / prompt / hash 记录：

```powershell
python scripts/assets/build_asset_provenance.py
python scripts/assets/audit_asset_provenance.py --strict
```

生成运行时 / 发布接入 map：

```powershell
python scripts/assets/build_asset_runtime_map.py
python scripts/assets/audit_asset_runtime_map.py --strict
```

生成 Godot runtime asset catalog：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_runtime_asset_catalog.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_runtime_asset_catalog.gd
```

生成美术接入就绪审计报告：

```powershell
python scripts/assets/audit_art_readiness.py --strict --write-report
```

生成并审计 atlas / frame / region 语义标签：

```powershell
python scripts/assets/build_asset_semantics.py
python scripts/assets/audit_asset_semantics.py --strict
```

默认报告输出：

```text
docs/assets/asset-package-audit-report.json
```

该报告只证明 queue、候选文件、atlas 输出和 editor resources 的结构性完整，不证明最终美术质量、授权、运行时接入或玩法读值。

## 输出文件

脚本会为每个可构建项输出：

- PNG sheet / atlas。
- `.frames.json` 或 `.regions.json`，记录每个帧 / 小图的 region。
- 对 `sprite_sheet` 类型，额外输出 `.spriteframes.tres`，作为 Godot `SpriteFrames` 候选资源。

`.spriteframes.tres` 是候选接入资源；正式接入前仍需要在 Godot 中打开检查动画名、速度、循环、贴图 region 和导入设置。

## Godot Editor AtlasTexture 资源

`atlas`、`tileset_sheet` 和 `ninepatch_sheet` 类型默认没有 `SpriteFrames`，但它们可以进一步拆成 Godot 可直接加载的 `AtlasTexture` `.tres` 资源，便于在编辑器中拖拽单个图标、tile、prop、Spine part、宣传图 region 或分镜格。

生成命令：

```powershell
python scripts/assets/build_editor_atlas_textures.py --clean
```

默认输出：

```text
assets/art/editor_resources/<asset_id>/<index>_<region_name>.atlas_texture.tres
assets/art/editor_resources/editor_atlas_textures.index.json
```

当前默认不为 `sprite_sheet` 生成逐帧 `AtlasTexture`，因为 Sprite Sheet / VFX Sheet 已有 `.spriteframes.tres`。如果后续确实需要逐帧编辑器资源，可显式加：

```powershell
python scripts/assets/build_editor_atlas_textures.py --include-sprite-sheets --clean
```

静态审计：

```powershell
python scripts/assets/audit_editor_atlas_textures.py --strict
```

Godot 加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
```

2026-06-20 当前结果：`302` 个 `AtlasTexture` resources，覆盖 `16` 个非 SpriteFrames atlas-linked assets，并通过 Python 静态审计与 Godot headless 加载审计。

## Godot Editor StyleBoxTexture 资源

`ninepatch_sheet` 类型除了 PNG sheet、`.regions.json` 和 `AtlasTexture` region 外，还会生成 Godot `StyleBoxTexture` 候选资源，便于后续把菜单、暂停、完成反馈、HUD 面板或按钮背景接入 Theme / PanelContainer / Button 样式。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd
```

默认输出：

```text
assets/art/ui/styleboxes/<asset_id>/<index>_<region_name>.stylebox_texture.tres
assets/art/ui/styleboxes/<asset_id>/<asset_id>.styleboxes.index.json
```

Godot 加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
```

2026-06-20 当前结果：`8` 个 `StyleBoxTexture` resources，覆盖 `menu_ninepatch_ui_ai01` 的全部 `8` 个 region。每个资源绑定 `assets/art/ui/menu_ninepatch_ui_ai01.png`、对应 `region_rect` 和保守 `24px` 九切边距，并通过 Godot headless 加载审计。

边界：当前 `StyleBoxTexture` 是 editor resource skeleton，只证明资源可加载和九切 margin 可配置；尚未完成 UI 清稿、伪文字清理、线宽统一、文字安全区、拉伸失真检查、Theme 接入或运行时 UI 引用替换。

## Godot Editor UI Skin / Theme 候选

`StyleBoxTexture` 资源之上继续生成一层 Godot `Theme` 候选和 UI skin rules，用于把九宫格 region 映射到常见 Control 样式，并记录 standalone UI / HUD 图的 text-safe area 规则。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_ui_skin.gd
```

默认输出：

```text
assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres
assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json
```

Godot 加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_editor_ui_skin.gd
```

2026-06-21 当前结果：`nano_hunter_imagegen_ui.theme.tres` 已映射 `9` 个 styleboxes，覆盖 `Panel`、`PanelContainer`、`Button`、`PopupPanel`、`TooltipPanel` 和 `AcceptDialog` 的基础样式；`nano_hunter_imagegen_ui.rules.json` 还记录 `4` 个 standalone panel / HUD 规则，覆盖 Stage16 pause / completion panel、Stage15 Boss HUD frame 和 Stage14 ability status HUD 的推荐 Control、尺寸与保守 text-safe area。`audit_editor_ui_skin.gd` 已通过并输出 `Editor UI skin OK: 9 style mappings, 4 standalone panels`；`audit_runtime_ui_skin_binding.gd` 额外验证 `DemoShell` 与 `TutorialHUD` 中 `5` 个正式 Panel 和 `4` 个 DemoShell TextureRect 已绑定 image gen UI 资源。

边界：当前 Theme / rules 是 UI 接入候选，不是最终运行时 UI 替换。正式接入 DemoShell、Boss HUD 或 ability HUD 前，仍需清理伪文字、复核 640x360 / 32x32 读值、检查 NinePatch 拉伸失真、统一线宽和对比度，并按 `asset-ingestion-checklist.md` 做人工复核。

## Spine-Style Cutout 导出

`assets/art/spine_parts/` 下的 Luna 与 Seal Guardian 拆件图集，会额外导出一组 Spine-style cutout 描述文件，便于后续手工绑定骨骼、外部动画工具整理或 Godot cutout rig 规划。

生成命令：

```powershell
python scripts/assets/build_spine_cutout_manifests.py
```

默认输出：

```text
assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json
assets/art/spine_parts/spine_exports/<asset_id>/<asset_id>.atlas
assets/art/spine_parts/spine_exports/<asset_id>/<asset_id>.spine_style.json
assets/art/spine_parts/spine_exports/<asset_id>/<asset_id>.cutout_manifest.json
```

审计命令：

```powershell
python scripts/assets/audit_spine_cutout_manifests.py --strict
```

2026-06-20 当前结果：`2` 个 Spine-style cutout exports，覆盖 `luna_spine_parts_ai01` 与 `seal_guardian_spine_parts_ai01`，总计 `48` 个 part descriptors，并通过审计。

边界：这些文件是拆件图集的交接描述，不是正式 Spine 工程，也不代表 Spine Runtime 可直接播放。当前没有 bone hierarchy、IK、mesh、weights、动画曲线或精修 pivot；正式进入动画管线前仍需人工语义命名、层级顺序、遮挡边缘、透明边缘和左右肢体复核。

## VFX Anchor / Blend Rules

VFX 图集和 standalone VFX PNG 会额外生成一层接入规则 sidecar，用来记录锚点、推荐混合方式、用途和碰撞边界。该层的核心原则是：VFX 只负责视觉反馈，不作为 gameplay collision 或 damage source。

生成命令：

```powershell
python scripts/assets/build_vfx_rules.py
```

默认输出：

```text
assets/art/vfx/vfx_rules/<asset_id>.vfx_rules.json
assets/art/vfx/vfx_rules/vfx_rules.index.json
```

审计命令：

```powershell
python scripts/assets/audit_vfx_rules.py --strict
```

2026-06-23 更新结果：`6` 个 VFX assets，`78` 条 VFX rules，覆盖 `vfx_seal_magic_atlas_ai01`、`vfx_combat_atlas_ai01` 两个 VFX atlas 的 `64` 帧，`stage16_talisman_relay_ai01` 的 `3x2` / `6` 个 region frame，`stage16_corruption_purge_ai01` 的 `3x2` / `6` 个 region frame，以及 Air Dash trail、Boss attack warning 两个 standalone VFX。全部规则均显式记录 `gameplay_collision=false` 和 `damage_source=false`，并通过 `audit_vfx_rules.py --strict`。

边界：这些规则是 first-pass anchor / blend 候选，不是最终特效清稿或运行时接入。正式替换 VFX 前仍需人工复核 mask、透明边缘、播放速度、缩放、spawn offset、遮挡层级和 gameplay readability；真实伤害判定必须由 gameplay code 或 scene Area 单独 author。

## Character Animation Rules

角色、敌人和 Boss 的 Sprite Sheet 会额外生成 animation rules sidecar，用来记录 first-pass clip、fps、loop、pivot、脚底基线、每帧 phase 和 frame duration。这一层用于后续运行时替换前的人工复核和接入规划。

生成命令：

```powershell
python scripts/assets/build_animation_rules.py
```

默认输出：

```text
assets/art/characters/animation_rules/<asset_id>.animation_rules.json
assets/art/characters/animation_rules/animation_rules.index.json
```

审计命令：

```powershell
python scripts/assets/audit_animation_rules.py --strict
```

2026-06-20 当前结果：`8` 个角色 / 敌人 animation rule sidecars，`172` 条 frame rules，覆盖 Luna run / air dash / attack / idle / jump-fall / hit-death、Seal Guardian boss attack 和 core enemies cycle。`audit_animation_rules.py --strict` 已通过。

边界：当前 animation rules 是 first-pass timing / anchor 候选，不是最终帧序或运行时替换。正式接入前仍需人工复核角色一致性、脚底基线、动画速度、循环点、攻击/受击时机、碰撞盒读值和试玩手感。

## Asset Package 综合审计

综合审计入口用于把本页各个分散验证结果汇总为一份结构化报告：

```powershell
python scripts/assets/audit_asset_package.py --strict --write-report
```

报告路径：

```text
docs/assets/asset-package-audit-report.json
```

2026-06-24 当前结果：报告 `ok=true`，覆盖 `55` 个 queue 条目、`26` 个 atlas-linked outputs、`302` 个 `AtlasTexture`、`2` 个 `TileSet`、`8` 个 `StyleBoxTexture`、`9` 个 UI Theme mappings、`5` 个 runtime UI skin panels、`4` 个 runtime UI skin textures、`4` 个 standalone UI skin panel rules、`78` 条 VFX rules、`172` 条 animation rules、`48` 个 Spine cutout parts、`55` 个 structural-ready art outputs、`55` 个 asset finalization approvals，以及 Godot 资产 Gallery scene / manifest 和 Integration Showcase scene / manifest。

边界：综合审计是结构性 gate，只证明文件、数量和 editor resource descriptors 存在；不证明最终 art polish、语义清稿、运行时接入、授权 readiness 或 gameplay readability。

## ImageGen Candidate Pool Audit

候选池审计用于把 raw candidates 与 selected sources 的关系显式化，防止“新图已经落盘”被误读为“已经进入图集”或“已经可运行”。

命令：

```powershell
python scripts/assets/audit_imagegen_candidate_pool.py --strict --write-report
```

默认报告：

```text
docs/assets/imagegen-candidate-pool-report.json
```

2026-06-20 当前结果：

- raw candidates: `133`
- selected sources: `548`
- unselected candidates: `102`
- review-required assets: `55`

边界：候选池审计只证明 PNG 候选存在、可打开，并统计哪些候选已经被 selected source 使用。它不做主观美术审批，不自动选择新候选，不自动重建 `assets/art`，也不替换运行时引用。

## Asset Provenance Records

资产来源记录用于把 image gen prompt、raw candidate hash、`assets/art` 输出 hash 和当前授权边界固定下来，避免后续只凭文件名判断来源。

生成命令：

```powershell
python scripts/assets/build_asset_provenance.py
```

审计命令：

```powershell
python scripts/assets/audit_asset_provenance.py --strict
```

输出：

```text
docs/assets/asset-provenance-records.json
```

2026-06-20 当前结果：

- provenance records: `55`
- candidate hashes: `133`
- output hashes: `55`
- prompt hashes: `55`

边界：provenance 只证明来源、prompt 和文件 hash 可追踪；不等于商业发布授权完成、不等于最终美术审批、不等于运行时引用替换。Art readiness 会在 provenance 存在时把 `license_record_pending` 推进为 `license_terms_manual_review`，保留对外发布前的人工条款复核。

## Asset Runtime Integration Map

Runtime Integration Map 用于把每个 generated asset 绑定到目标 track、目标系统、推荐 Godot 资源类型和候选场景，后续 Stage polish 可以按这份表逐项替换引用。

生成命令：

```powershell
python scripts/assets/build_asset_runtime_map.py
```

审计命令：

```powershell
python scripts/assets/audit_asset_runtime_map.py --strict
```

输出：

```text
docs/assets/asset-runtime-integration-map.json
```

2026-06-20 当前结果：

- runtime map entries: `55`
- tracks: `9`
- missing outputs: `0`
- missing target scene candidates: `0`

边界：该 map 不是正式运行时接入；它只证明接入路径、资源类型和候选场景已经明确。Art readiness 会在 map 存在时把 `runtime_reference_not_replaced` 推进为 `runtime_binding_map_ready_manual_replacement`，表示后续仍需人工替换场景引用和做试玩复核。

## ImageGen Runtime Asset Catalog

Runtime Asset Catalog 用 Godot `ResourcePreloader` 集中加载 runtime map 中的 `55` 个资源。它把路径级 map 推进到 Godot 可加载资源目录，供后续 Stage polish 替换场景引用时直接取用。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_runtime_asset_catalog.gd
```

审计命令：

```powershell
godot --headless --path . --script res://scripts/dev/audit_imagegen_runtime_asset_catalog.gd
```

输出：

```text
scenes/dev/imagegen_runtime_asset_catalog.tscn
docs/assets/imagegen-runtime-asset-catalog-manifest.json
```

2026-06-20 当前结果：

- runtime catalog resources: `55`
- runtime catalog entries: `55`

边界：catalog 只证明资源可以被 Godot `ResourcePreloader` 加载；不代表 `player_placeholder`、`demo_shell`、Boss、HUD、TileMap、VFX 或发布素材引用已经替换。Art readiness 会在 catalog 存在时把 `runtime_binding_map_ready_manual_replacement` 推进为 `runtime_catalog_ready_manual_replacement`。

## ImageGen Candidate Review Gallery

Candidate Review Gallery 用于把候选池中尚未进入 selected source 的 raw candidates 放进 Godot 编辑器场景，方便人工逐张扫图和决定是否要替换当前 selected source。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_candidate_review_gallery.gd
```

审计命令：

```powershell
godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd
```

输出：

```text
scenes/dev/imagegen_candidate_review_gallery.tscn
docs/assets/imagegen-candidate-review-gallery-manifest.json
```

2026-06-20 当前结果：

- candidate review cards: `102`
- review-required assets: `55`

边界：该 Gallery 只用于 raw candidate 人工评审，不代表候选已被选中，不重建 `assets/art/`，不改变 atlas、SpriteFrames、TileSet、StyleBox、Theme、VFX rules、animation rules 或运行时引用。综合资产包审计会校验 Gallery 卡片数与候选池报告一致。

## Art Readiness 审计

Art readiness 审计用于把“资产已经生成并可被管线消费”和“资产可以正式替换运行时引用”分开。它会逐项检查 prompt queue 的 `55` 个输出 PNG 是否存在、可打开、尺寸有效、没有不透明 chroma key 残留，并对 atlas-linked 输出复核 metadata region count 是否匹配 `expected_target`。

命令：

```powershell
python scripts/assets/audit_art_readiness.py --strict --write-report
```

默认报告：

```text
docs/assets/art-readiness-audit-report.json
```

2026-06-24 当前结果：报告 `ok=true`，`55/55` queue outputs 为 `structural_ready`，`55/55` queue outputs 为 `final_ready`。当前 final-ready 覆盖 `stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01`、`stage15_seal_guardian_ai01`、`stage16_luna_player_readability_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_title_background_ai01`、`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`stage16_talisman_relay_ai01`、`stage16_corruption_purge_ai01`、`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`、`stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01`、`menu_ninepatch_ui_ai01`、`stage16_demo_menu_icons_ai01`、`icon_sheet_core_ai01`、`hud_core_ui_atlas_ai01`、`vfx_seal_magic_atlas_ai01`、`vfx_combat_atlas_ai01`、`luna_idle_sheet_ai01`、`luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01`、`luna_jump_fall_sheet_ai01`、`luna_hit_death_sheet_ai01`、`seal_guardian_boss_sheet_ai01`、`enemies_core_sheet_ai01`、`luna_spine_parts_ai01`、`seal_guardian_spine_parts_ai01`、`biome01_air_dash_shrine_room_ai01`、`biome01_shrine_trial_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome02_miasma_hazard_room_ai01`、`biome02_miasma_marsh_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`、`stage15_seal_guardian_boss_room_ai01`、`equipment_pickup_atlas_ai01`、`material_texture_atlas_ai01`、`reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01`、`capsule_art_alpha_demo_ai01`、`cg_seal_guardian_reveal_ai01`、`nano_hunter_logo_direction_ai01`、`promo_key_art_sheet_ai01`、`storyboard_intro_bounty_ai01`、`storyboard_miasma_marsh_ai01`、`storyboard_narrative_sheet_ai01` 与 `style_board_global_ai01`；当前 55 个 queue outputs 均已进入 final-ready source / preview / direction 边界；商业发布级公开营销图、最终 logo 字体、平台裁切、过场成片和剧情脚本锁定仍需另起 release polish。

本轮同时修复 `scripts/assets/export_standalone_candidates.py` 的 chroma key 处理：standalone 导出现在同时支持绿色与洋红 key。`stage15_seal_guardian_ai01` 已重导出为带 alpha 的 `RGBA` PNG，清除了 `alpha_expected_but_not_detected` 警告。

边界：Art readiness 审计不做主观美术评分，也不自动升级 `asset-manifest.md` 状态。它只给出结构就绪、警告和人工 polish blocker；真正接入场景、HUD、Boss、VFX、TileSet 或 UI 时仍需走 `asset-ingestion-checklist.md` 和对应 Stage polish 计划。

## Asset Semantic Labels

语义标签层用于把自动切片生成的 `auto_001`、`auto_002` 等 frame / region 编号转换为可读的 first-pass 语义名，便于后续人工清稿、TileSet collision、UI region 裁切、VFX anchor、Spine pivot 和运行时引用替换。

生成命令：

```powershell
python scripts/assets/build_asset_semantics.py
```

审计命令：

```powershell
python scripts/assets/audit_asset_semantics.py --strict
```

默认输出：

```text
docs/assets/asset-semantics-index.json
assets/art/**/*.semantics.json
```

2026-06-20 当前结果：`26` 个 atlas-linked outputs 已生成 `538` 个 semantic entries，并通过 `audit_asset_semantics.py --strict`；standalone `stage16_demo_menu_icons_ai01` 另有 `6` 个 confirmed icon semantics 与 `2x3` regions sidecar。综合资产包审计当前记录 `544` 个 semantic labels。

边界：这些标签是 first-pass machine semantic labels，不是人工确认。Readiness 报告会把相关 blocker 记为 `semantic_labels_manual_review`，表示已经有可用语义入口，但仍需人工确认图像内容、裁切范围、运行时语义和 gameplay readability。

## Godot ImageGen Asset Gallery

资产 Gallery 是面向编辑器人工验收的预览场景，把分散在 `assets/art/`、`assets/art/editor_resources/`、`assets/art/tilesets/`、`assets/art/ui/styleboxes/` 和 `assets/art/spine_parts/` 的资源集中展示。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_gallery.gd
```

默认输出：

```text
scenes/dev/imagegen_asset_gallery.tscn
docs/assets/imagegen-asset-gallery-manifest.json
```

加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
```

2026-06-20 当前结果：Gallery manifest 记录 `55` 个 queue output PNG、`302` 个 `AtlasTexture` region、`2` 个 TileSet sheet 预览入口、`8` 个 `StyleBoxTexture` 九宫格候选和 `48` 个 Spine part descriptors；`audit_imagegen_asset_gallery.gd` 已通过并输出 `Imagegen asset gallery OK`。该审计会实际检查 `361` 个普通纹理预览资源和 `8` 个 `StyleBoxTexture` 预览资源是否可由 Godot 加载并绑定到预览节点。

边界：Gallery 是开发 / 审计场景，不是正式游戏场景；它用于扫图、发现清稿问题和后续替换接入前的人工复核，不代表运行时引用已经替换。

## Godot ImageGen Asset Gallery Render Smoke

渲染烟测用于确认 Gallery 在真实渲染器下能输出非空画面。该脚本会把一次性截图证据写入 `tests/artifacts/local/`，该目录默认被 `.gitignore` 忽略。

命令：

```powershell
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_imagegen_asset_gallery.gd
```

不要对该脚本使用 `--headless`；headless dummy 渲染器没有可读取的 viewport texture，会得到空图。

默认输出：

```text
tests/artifacts/local/imagegen_asset_gallery/gallery_viewport.png
tests/artifacts/local/imagegen_asset_gallery/gallery_viewport_report.json
```

2026-06-20 当前本地结果：报告 `ok=true`，`samples=3600`、`non_transparent_ratio=1.0`、`varied_color_buckets=85`，超过 `min_non_transparent_ratio=0.2` 与 `min_varied_color_buckets=32` 阈值。

边界：该烟测只证明 Gallery 视口能渲染出非空、有颜色变化的画面；不证明最终美术质量、运行时接入、授权 readiness 或玩法读值。

## Godot ImageGen Asset Integration Showcase

节点级接入演示用于确认当前 image gen 资产包不只停留在文件、图集或 Gallery 预览层，而是可以被真实 Godot 节点消费。它生成一个开发用场景，把 `.spriteframes.tres`、`.tileset.tres`、`.stylebox_texture.tres` 和 `.atlas_texture.tres` 分别绑定到 `AnimatedSprite2D`、`TileMapLayer`、`PanelContainer` 与 `Sprite2D`。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd
```

默认输出：

```text
scenes/dev/imagegen_asset_integration_showcase.tscn
docs/assets/imagegen-asset-integration-showcase-manifest.json
```

加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

2026-06-20 当前结果：manifest 记录 `10` 个 `AnimatedSprite2D`、`2` 个 `TileMapLayer`、`4` 个 `PanelContainer` StyleBox 预览和 `8` 个 `Sprite2D` AtlasTexture 预览；`audit_imagegen_asset_integration_showcase.gd` 已通过并输出 `Imagegen asset integration showcase OK`。

边界：该场景是 node-consumption smoke，只证明资源能被 Godot 节点加载和绑定；不代表正式运行时引用已替换，也不证明 TileSet collision、terrain、NinePatch 最终 margin、动画速度、VFX 锚点、Spine rig、授权 readiness 或玩法读值已经完成。

## Godot Editor TileSet 资源

`tileset_sheet` 类型除了 PNG sheet、`.regions.json` 和单 region `AtlasTexture` 外，还会生成 Godot `TileSet` 候选资源，便于后续在编辑器中直接作为 TileMap / TileMapLayer 的 tileset 起点。

生成命令：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd
```

默认输出：

```text
assets/art/tilesets/editor_tilesets/<asset_id>.tileset.tres
assets/art/tilesets/editor_tilesets/<asset_id>.tileset_rules.json
```

Godot 加载审计：

```powershell
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
```

2026-06-20 当前结果：`2` 个 `TileSet` resources，覆盖 `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01`，每个资源包含 `1` 个 `TileSetAtlasSource`、`48` 个 tile、`64x64` region size、`1` 个 physics layer 和 `1` 个 terrain set，并通过 Godot headless 加载审计。

每个 TileSet 还会输出 `.tileset_rules.json` sidecar。当前规则按 first-pass semantics 做保守分类：

- `ground` / `wall` / `transition`：完整 cell 碰撞候选。
- `platform_edge`：顶部 one-way platform 碰撞候选。
- `hazard`：危险视觉区，不自动加物理碰撞。
- `decor` / `ornament`：装饰视觉 tile，不加物理碰撞。

2026-06-20 当前 rules 审计结果：`2` 个 rule files、`96` 个 tile rule entries、`64` 个 collision-ready tiles、`8` 个 hazard visual-only tiles。`audit_art_readiness.py` 已将 TileSet blocker 从 `collision_and_terrain_configuration` 推进为 `collision_and_terrain_manual_review` 与 `hazard_safe_boundary_manual_review`。

边界：当前 `.tileset.tres` 仍是 editor resource candidate，只提供保守碰撞候选和 terrain 分类入口；尚未配置 autotile、navigation、occlusion 或运行时 TileMap / TileMapLayer 引用。正式接入场景前，必须按 `asset-ingestion-checklist.md` 做碰撞误读、危险边界、安全边界、摄像机尺度和 tile 语义复核。miasma hazard tile 只记录视觉危险区，正式伤害区域必须在运行时场景中单独 author。

## Luna 高帧数要求

主角 Luna 的正式动作不能低帧数交付：

- `luna_run_sheet_ai01`：正式 `16-24` 帧。
- `luna_air_dash_sheet_ai01`：正式 `12-16` 帧。
- `luna_attack_01_sheet_ai01`：正式 `12-16` 帧。
- `luna_idle_sheet_ai01`：正式 `12-16` 帧。
- `luna_hit_death_sheet_ai01`：death 正式 `16-24` 帧。

Image gen 可以先输出 `8-12` 帧候选，但正式 sheet 必须经过 Aseprite / Krita 清稿、补帧和基线校准。

## Godot 验证

当真实 PNG 输出后，执行：

```powershell
godot --headless --path . --import
```

如果替换主角、HUD、Boss、VFX 或场景引用，还必须按 `asset-ingestion-checklist.md` 做人工复核，并运行对应 GUT 或试玩检查。
