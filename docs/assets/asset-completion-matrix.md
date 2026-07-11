# Nano Hunter Asset Completion Matrix

Last Updated: 2026-06-24

## 用途

本文件把“当前项目所需美术资产”从单个 Batch 扩展为完整资产矩阵，覆盖角色、关卡地图场景、UI / 界面、图标、道具与装备、特效、动画帧 / 序列帧、贴图、宣传运营、LOGO、CG、分镜图、叙事与剧情资产，以及 Godot 可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集和九宫格图片。

本矩阵不代表所有资产已经生成或接入；它是后续 image gen、清稿、图集整理和 Godot 导入的总控入口。具体资产进入游戏前仍必须回填 `asset-manifest.md` 并通过 `asset-ingestion-checklist.md`。

批量提示词模板保存在 `docs/assets/image-gen-prompt-library.md`。动画帧数规格保存在 `docs/assets/animation-frame-spec.md`。具体生产队列保存在 `docs/assets/image-gen-production-backlog.md`，可执行 prompt queue 保存在 `docs/assets/image-gen-prompt-queue.json`。
Godot 图集构建流程保存在 `docs/assets/godot-atlas-build-pipeline.md`，构建规格保存在 `docs/assets/asset-atlas-build-manifest.json`，内置 image gen 输出定位与导入脚本为 `scripts/assets/import_imagegen_outputs.py`，原始候选拆分为 `selected_*` 源图的脚本为 `scripts/assets/prepare_selected_sources.py`，单体候选导出脚本为 `scripts/assets/export_standalone_candidates.py`，候选池审计脚本为 `scripts/assets/audit_imagegen_candidate_pool.py`，未选 raw candidate 的 Godot 评审入口为 `scenes/dev/imagegen_candidate_review_gallery.tscn`，资产来源 / prompt / hash 记录为 `docs/assets/asset-provenance-records.json`，运行时 / 发布接入映射为 `docs/assets/asset-runtime-integration-map.json`，Godot runtime catalog 为 `scenes/dev/imagegen_runtime_asset_catalog.tscn`。

多项目并行时，`C:\Users\peng8\.codex\generated_images` 只能视为全局候选来源，不能按“最新 PNG”自动归属到 Nano Hunter。导入前必须使用明确 session、明确 `--source` 路径或 `image_id -> batch / asset_id` import map；`scripts/assets/import_imagegen_outputs.py --copy-latest` 对全局目录默认加安全拒绝，防止其它项目资产污染当前候选池。

2026-06-24 当前来源安全报告为 `133` 个 raw candidates，其中 `35` 个为 `project_session_confirmed`，`30` 个为 `explicit_mapping_review_required`，`68` 个为 `workspace_provenance_recorded_review_required`，`0` 个为 `unknown_or_unsafe`。综合资产包审计已纳入该层并要求 `unsafe_candidate_count = 0`。运行时来源安全报告覆盖 `30` 个 P0 runtime assets，其中 `18` 个仍需来源或派生复核、`0` 个 unsafe。这只证明跨项目来源风险受控，不代表最终美术质量、授权、清稿或运行时替换完成。

同日针对“多个项目同时开发是否混用资产”的风险，新增 `scripts/assets/audit_project_asset_isolation.py` 与 `docs/assets/project-asset-isolation-report.json` / `.md`。当前扫描 `assets/`、`docs/assets/` 与 `scripts/assets/` 下 `1936` 个资产相关文件，结果为 `0` 个已知外项目标识、`0` 个外项目绝对路径、`0` 个 `project_key` 错误。该报告只证明资产记录层未发现已知外项目污染证据；`review-required` 候选仍必须走来源复核或重生成。

## 统一风格锁

- 世界观：南北朝东方奇幻、镇妖卫、佛门符印、山海经妖物、瘴泽妖域。
- 视觉：2D 横版类银河恶魔城，水墨 / 工笔色系，柔和 Ori-like glow。
- 色板：月白、墨青、青蓝灵光、朱砂符印、铜金；瘴泽和 Boss 可用黛紫、墨绿、病态黄绿。
- 读值：角色、敌人、危险物、交互物优先清晰轮廓；背景和贴图不能抢玩家读值。
- 禁止：现代实验室、生物科技、科幻装甲、现代 UI 面板、文字水印、写实 3D、难读的过度细节。

## 资产矩阵

| 类别 | 资产组 | 当前优先级 | 生成方式 | Godot 目标产物 | 目标目录 | 当前状态 |
| --- | --- | --- | --- | --- | --- | --- |
| 角色类 | Luna idle / run / jump / fall / attack / hit / death / air dash | P0 | Image2 / GPT Image 出角色方向与 8-12 帧候选，Aseprite / Krita 清稿补到 12-24 帧正式动作 | 高帧数 Sprite Sheet、Spine 拆件图集 | `assets/art/characters/player/`、`assets/art/characters/player/sprite_sheets/`、`assets/art/spine_parts/` | 需要生成；主角高帧数标准见 `animation-frame-spec.md` |
| 角色类 | 基础近战、冲锋、空中哨兵、瘴气妖术投射者 | P1 | Image2 / GPT Image 统一敌人轮廓，Nano Banana 做变体 | Enemy Sprite Sheet | `assets/art/characters/enemies/`、`assets/art/characters/enemies/sprite_sheets/` | 占位已接入，正式图待生成 |
| 角色类 | Seal Guardian Boss idle / attack / warning / hit / defeat | P0 | Image2 / GPT Image 出 Boss 主方向，Seedance / Veo 做动作参考 | Boss Sprite Sheet、Boss Spine 拆件 | `assets/art/characters/enemies/`、`assets/art/spine_parts/` | 需要生成 |
| 关卡地图场景类 | 山门古刹 / 镇妖试炼场背景层 | P1 | Image2 / GPT Image 出 16:9 分层背景，后续拆前中后景 | Parallax 背景层、Texture Atlas | `assets/art/environment/biome_01_shrine_trial/`、`assets/art/atlases/` | 需要生成 |
| 关卡地图场景类 | 瘴泽妖域背景层 | P1 | Image2 / GPT Image 出气氛板，Nano Banana 做局部变体 | Parallax 背景层、Texture Atlas | `assets/art/environment/biome_02_miasma_marsh/`、`assets/art/atlases/` | 占位已接入，正式图待生成 |
| 关卡地图场景类 | 平台、地面、墙面、危险池、边缘 tile | P0 | 先生成 tile style sheet，再手工切 TileSet | Tile Set、Tile Texture Atlas | `assets/art/tilesets/`、`assets/art/environment/` | 需要生成 |
| UI / 界面类 | 主菜单、暂停、重开、完成反馈面板 | P0 | Image2 / GPT Image 出 UI 氛围，Nano Banana / Inkscape 清图标和面板 | UI Atlas、九宫格 Panel | `assets/art/ui/`、`assets/art/ui/atlases/` | 需要生成 |
| UI / 界面类 | HUD 血量、能力状态、Boss 状态、Recovery Charge | P0 | Nano Banana 生成符印小图案，Krita / Inkscape 清稿 | UI Atlas | `assets/art/ui/`、`assets/art/ui/atlases/` | 部分占位，正式图待生成 |
| 图标类 | Air Dash、Recovery Charge、checkpoint、门控、终点、奖励 | P0 | Nano Banana / Gemini Image 生成小图标，统一线宽和色板 | Icon Sheet、UI Atlas | `assets/art/ui/`、`assets/art/ui/atlases/` | 需要生成 |
| 道具与装备类 | 能力 shrine、封印门、符桩、石碑、石龛、悬赏榜、佛印石灯 | P0-P1 | Image2 / GPT Image 出大型道具，Nano Banana 做状态变体 | Prop Atlas | `assets/art/props/`、`assets/art/atlases/` | 部分占位，正式图待生成 |
| 道具与装备类 | Luna 武器、符纸、念珠、铜铃、镇妖令牌、奖励物 | P1 | Image2 / GPT Image 方向稿，Nano Banana 做小件变体 | Equipment / Pickup Atlas | `assets/art/props/`、`assets/art/ui/` | 需要生成 |
| 特效类 | slash、hit spark、Air Dash trail、Boss warning、talisman relay、corruption purge | P0 | Image2 / GPT Image 出主 VFX，Nano Banana 做帧变体 | VFX Sprite Sheet、VFX Atlas | `assets/art/vfx/`、`assets/art/vfx/atlases/` | 部分占位，正式图待生成 |
| 动画帧 / 序列帧 | Luna 行走、奔跑、空中冲刺、攻击、受击、死亡 | P0-P1 | Image2 / GPT Image 出 8-12 帧候选，Seedance / Veo 做动作参考，Aseprite / Krita 清稿补到 run 16-24、air dash 12-16、attack 12-16、death 16-24 | 高帧数 Sprite Sheet、AnimationPlayer 切片 | `assets/art/characters/player/sprite_sheets/` | 需要生成；历史 Luna walk lane 曾被单独排除 |
| 动画帧 / 序列帧 | Seal Guardian 攻击、Boss 入场、击败 | P1 | Seedance / Veo 参考，手工提炼关键帧 | Boss Sprite Sheet / Spine parts | `assets/art/characters/enemies/sprite_sheets/`、`assets/art/spine_parts/` | 需要生成 |
| 贴图类 | 石材、木构、符纸、瘴气地表、腐化水面、布料、金属边饰 | P1 | Image2 / GPT Image 生成 seamless texture 方向，Krita 清理 | Texture Atlas、TileSet 贴图 | `assets/art/textures/`、`assets/art/tilesets/` | 需要生成 |
| 宣传与运营类 | 项目 LOGO / 标题字方向 | P2 | Image2 / GPT Image 或手工字体设计；正式字形需单独清稿 | Logo raster / vector candidate | `assets/art/promo/` | 需要生成 |
| 宣传与运营类 | Key Art、Steam capsule、社媒图、Demo 封面 | P2 | Image2 / GPT Image 主视觉，Krita 清稿 | Promo Atlas / Standalone PNG | `assets/art/promo/` | 需要生成 |
| 叙事与剧情类 | CG 图、分镜图、剧情插图、过场氛围图 | P2 | Image2 / GPT Image 出 CG，Seedance / Veo 做镜头参考 | Storyboard Sheet、CG PNG | `assets/art/storyboards/`、`assets/art/promo/` | 需要生成 |

## Godot 产物规范

| 产物 | 推荐用途 | 默认输出 | 注意事项 |
| --- | --- | --- | --- |
| Sprite Sheet | 角色、敌人、Boss、VFX 序列帧 | `assets/art/characters/**/sprite_sheets/`、`assets/art/vfx/atlases/` | 主角优先高帧数；单表先按动作拆，后续再合并；帧格尺寸必须固定 |
| Texture Atlas | props、textures、区域装饰 | `assets/art/atlases/` | 先小图集，避免一次性大图塞满仓库 |
| Tile Set | 地形、墙体、危险池、平台边缘 | `assets/art/tilesets/` | Godot TileSet 接入前先验证碰撞边界不误导 |
| Spine 拆件图集 | Luna / Boss 后续骨骼动画候选 | `assets/art/spine_parts/` | 当前不启用 Spine 插件；先按拆件 PNG 管理 |
| UI 图集 | HUD、菜单按钮、图标、面板 | `assets/art/ui/atlases/` | 面板优先九宫格，图标需 64x64 下读值清楚 |
| 特效图集 | slash、dash、seal、warning、purge | `assets/art/vfx/atlases/` | 不能参与碰撞；只做显示层 |
| 九宫格图片 | UI 面板、提示框、菜单容器 | `assets/art/ui/` | Godot 接入时使用 NinePatchRect 或 StyleBoxTexture |

## 生成顺序

1. `Style Lock`：先固定 Luna、Seal Guardian、符印视觉、两大区域色板。
2. `Gameplay Readability`：优先补 P0 玩家、能力、Boss、HUD、门控和预警。
3. `Environment Pass`：补 TileSet、背景层和 props。
4. `UI Atlas Pass`：补菜单、HUD、图标、九宫格。
5. `Animation Pass`：补角色 / Boss 动作帧、Sprite Sheet、Spine 拆件；Luna run / air dash / attack / death 按高帧数规格优先。
6. `VFX Atlas Pass`：补 slash、dash、seal、purge、warning 的序列帧。
7. `Texture Pass`：补材质贴图和可复用装饰纹理。
8. `Promo / Narrative Pass`：最后做 LOGO、CG、分镜和运营图，避免早期方向未锁定时过度消耗。

## 当前落盘与图集化状态

2026-06-19 本轮已使用 Codex 内置 `image_gen` 完成 Batch00 / Batch01 / Batch02 / Batch03 / Batch06-Batch13 的 `55/55` 个原始候选 PNG。Batch00 / Batch01 / Batch06-Batch13 首轮从当前 Codex session JSONL 的 `image_generation_call.result` 恢复到 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`；Batch02、Batch03、Batch03 supplemental、Batch06 supplemental 与 Batch08 supplemental 从默认保存目录 `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613` 复制到项目候选目录。恢复证据见 `docs/assets/image-gen-session-recovery-log.md`。

2026-06-20 已继续从当前 Codex Desktop 默认生成图目录恢复 `30` 张新增 PNG，作为 raw candidates 进入 Batch06、Batch08、Batch09、Batch10 与 Batch11 的候选池；完整 inbox 副本位于 `assets/source/imagegen_inbox/recovered-2026-06-20-current-thread/`，ledger 位于同目录 `recovery-ledger.json`。2026-06-21 继续为 `stage16_seal_release_threshold_ai01` 和 `luna_jump_fall_sheet_ai01` 追加当前 Nano Hunter 会话确认候选，并追加 `stage16_demo_menu_icons_ai01_candidate_02` 与 `stage14_air_dash_icon_ai01_candidate_02` 两个评审候选；其中 `stage14_air_dash_icon_ai01` 已重新从 `candidate_01` 导出 runtime PNG 并写出 `.source.json`，另有 standalone runtime UI / VFX PNG 已补齐 `candidate_01` `.source.json` 派生记录。随后已补强 standalone `.source.json` 项目键，9 个 standalone 派生记录均包含 `project_key = nano-hunter` 与 `project_name = Nano Hunter`。同日继续为 15 个 runtime review-required 资产追加统一风格重生候选，当前 `docs/assets/imagegen-candidate-pool-report.json` 记录 `120` 张 raw candidates、`547` 个 selected source 切片 / 条目、`82` 个尚未被 selected source 使用的候选和 `55` 个需要人工审图的 asset。新增候选不自动覆盖 `assets/art/`，也不自动重建图集或替换运行时引用。

2026-06-21 已对上述 raw candidates 增加来源安全审计：`docs/assets/imagegen-source-safety-report.json` 当前显示 `121` 个 raw candidates、`0` 个 `unknown_or_unsafe`，其中 `86` 个候选仍需人工来源 / 视觉复核。后续如果使用这些 review-required 候选替换 selected sources，必须先确认它们确属 Nano Hunter 当前资产方向，再执行 `prepare_selected_sources.py`、atlas rebuild、Godot import 和对应审计。

同日已为当前 `82` 个未选 raw candidates 生成 Godot 评审 Gallery：`scenes/dev/imagegen_candidate_review_gallery.tscn`，manifest 为 `docs/assets/imagegen-candidate-review-gallery-manifest.json`。该场景用于人工分拣候选，不代表选中、清稿、图集重建、最终美术或运行时接入完成。

同日已新增 provenance 记录层：`docs/assets/asset-provenance-records.json` 当前记录 `55` 条 asset provenance、`121` 个 candidate hashes、`55` 个 output hashes 和 `55` 个 prompt hashes；`scripts/assets/audit_asset_provenance.py --strict` 通过。Art readiness 中的授权相关 blocker 已从 `license_record_pending` 推进为 `license_terms_manual_review`，表示来源记录已补齐，但商业发布条款仍需人工复核。

同日已新增运行时 / 发布接入 map：`docs/assets/asset-runtime-integration-map.json` 记录 `55` 条 integration entries 和 `9` 个 tracks，覆盖 runtime gameplay、runtime animation、runtime environment、runtime UI、runtime VFX、animation pipeline、art direction、release promo 和 narrative / release。Art readiness 中的运行时相关 blocker 已从 `runtime_reference_not_replaced` 推进为 `runtime_binding_map_ready_manual_replacement`，表示接入路径已明确，但场景引用尚未正式替换。

同日已新增 Godot runtime asset catalog：`scenes/dev/imagegen_runtime_asset_catalog.tscn`，manifest 为 `docs/assets/imagegen-runtime-asset-catalog-manifest.json`。该场景用 `ResourcePreloader` 集中加载 `55` 个资源；Art readiness 中的运行时相关 blocker 已进一步推进为 `runtime_catalog_ready_manual_replacement`，表示资源可被 Godot 集中加载，但正式场景 / HUD / Boss / TileMap / VFX 引用仍未替换。

同日已新增 `scripts/assets/prepare_selected_sources.py`，把 raw candidates 自动拆分到 `selected_frames/`、`selected_items/`、`selected_tiles/`、`selected_parts/` 与 `selected_panels/`。当前已执行 target-count rebuild，自动拆分数量为：

- `selected_frames`: `236`
- `selected_items`: `122`
- `selected_tiles`: `96`
- `selected_parts`: `48`
- `selected_panels`: `36`

同日已通过 `scripts/assets/build_asset_atlases.py` 和 `scripts/assets/export_standalone_candidates.py` 生成第一版 Godot 可用候选：

- `55` 张 `assets/art/**/*.png`
- `26` 个 `frames / regions` JSON
- `10` 个 `SpriteFrames` `.tres`
- 其中 `25` 张为 standalone PNG，覆盖全局风格板、Batch01 P0 单体方向稿、Batch02 Stage16 UI / 终局反馈、Batch03 区域表现候选、Batch08 supplemental UI 面板和 LOGO 方向；新增 3 张 Batch06 supplemental Sprite Sheet，补齐 Luna jump/fall、Luna hit/death 和 core enemies；新增 4 张 Batch03 supplemental room/background PNG，补齐 shrine trial、Air Dash shrine、miasma hazard 和 Seal Guardian boss room 场景源图；新增 4 张 Batch08 supplemental UI panel PNG，补齐 Stage16 pause / completion、Stage15 Boss HUD frame 和 Stage14 ability status HUD。

当前状态仍是 `provisional / target-count pass`：`26/26` 个 atlas-linked 输出已经达到 manifest 的 `expected_target`，并通过 `scripts/assets/audit_asset_target_coverage.py --strict`。这证明 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集、九宫格 sheet、Promo / CG / Storyboard sheet 在数量和 Godot 资源文件层面可供编辑器预览；duplicate 补位已在 2026-06-20 清零，但 TileSet / storyboard / promo 类输出包含自动网格裁切结果，所有资产仍需人工清稿、语义命名、锚点 / mask / NinePatch 边界和运行态接入验证，不等于最终美术完成或游戏内正式接入。

2026-06-20 已完成两轮 duplicate reduction / clearance：从内置 `image_gen` 默认目录复制补充候选到项目候选目录，并让 `prepare_selected_sources.py` 支持同一 asset 的多个 `candidate_XX` 合并抽取。当前 `26/26` 个 atlas-linked 输出均达到 `duplicates=0`，不再依赖自动 duplicate 补位。后续重点从“补数量”转为人工清稿、语义命名、帧序整理、锚点 / mask / NinePatch 边界和运行态接入验证。

同日已新增 Godot 编辑器资源层：`sprite_sheet` / VFX sheet 继续使用 `.spriteframes.tres`，非 SpriteFrames 的 `atlas`、`tileset_sheet` 与 `ninepatch_sheet` 通过 `scripts/assets/build_editor_atlas_textures.py` 生成 `302` 个 `AtlasTexture` `.tres`，索引位于 `assets/art/editor_resources/editor_atlas_textures.index.json`。这些资源已通过 Python 静态审计和 Godot headless 加载审计，能在编辑器中作为单个 atlas region 使用。

同日继续为 Batch07 两套 `tileset_sheet` 生成 Godot `TileSet` 编辑器候选：`assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres` 与 `assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres`，并新增对应 `.tileset_rules.json` sidecar。两个资源均通过 `scripts/dev/audit_editor_tilesets.gd` 加载审计，当前包含 texture、tile size、atlas source、`48` 个 tile 坐标、`1` 个 physics layer、`1` 个 terrain set 和按语义分类的保守碰撞候选。综合审计当前记录 `96` 个 tile rules、`64` 个 collision-ready tiles 和 `8` 个 hazard visual-only tiles。TileSet autotile、navigation、occlusion、正式伤害 Area、运行时 TileMap / TileMapLayer 引用和 gameplay readability 仍需后续人工处理。

同日继续为 Batch08 `menu_ninepatch_ui_ai01` 生成 Godot `StyleBoxTexture` 资源骨架：`assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/` 下已有 `8` 个 `.stylebox_texture.tres` 和索引 JSON。资源已通过 `scripts/dev/audit_editor_styleboxes.gd` 加载审计，当前证明 texture、region 和保守 `24px` 九切边距可用。

同日进一步新增 UI skin / Theme 规则层：`assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres` 已映射 `9` 个 styleboxes，覆盖 `Panel`、`PanelContainer`、`Button`、`PopupPanel`、`TooltipPanel` 和 `AcceptDialog`；`assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json` 记录 `4` 个 standalone panel / HUD 规则，覆盖 Stage16 pause / completion panel、Stage15 Boss HUD frame 和 Stage14 ability status HUD 的推荐 Control、尺寸与保守 text-safe area。资源已通过 `scripts/dev/audit_editor_ui_skin.gd` 加载审计，综合资产包审计也记录 `9` 个 UI Theme mappings 和 `4` 个 standalone UI skin panel rules。当前仍不等于 UI 清稿、伪文字清理、拉伸失真检查或完整运行时 UI 替换完成。

同日继续新增 runtime UI skin binding：`scenes/ui/demo_shell.tscn` 与 `scenes/ui/tutorial_hud.tscn` 已绑定 `nano_hunter_imagegen_ui.theme.tres`，并为 `MainMenu`、`PauseMenu`、`PromptPanel` 与 `BattlePanel` 显式绑定 `menu_ninepatch_ui_ai01` 的首个 `StyleBoxTexture`。新增 `scripts/dev/audit_runtime_ui_skin_binding.gd` 验证 `2` 个正式 UI 场景和 `4` 个 Panel 节点已引用 image gen UI skin。P0 runtime replacement plan 因此从 `27` 个 planned replacements / `1` 个 already referenced 推进到 `26` 个 planned replacements / `2` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 从 `0 passed / 55 blocked` 推进为 `2 passed / 53 blocked`。当前仍不代表 UI 最终清稿、独立面板 PNG 接入、图标 atlas 替换、HUD frame 替换或最终美术批准。

2026-06-21 继续新增 DemoShell UI shell texture binding：`scenes/ui/demo_shell.tscn` 已新增 `TitleBackground`、`MainMenu/MenuIconStrip`、`PauseMenu/PausePanelArt` 和 `CompletionPanel/CompletionPanelArt`，分别引用 `stage16_title_background_ai01.png`、`stage16_demo_menu_icons_ai01.png`、`stage16_pause_panel_ui_ai01.png` 与 `stage16_completion_panel_ui_ai01.png`。`scripts/dev/audit_runtime_ui_skin_binding.gd` 当前验证 `2` 个正式 UI 场景、`5` 个 Panel 节点和 `4` 个 DemoShell TextureRect。P0 runtime replacement plan 因此推进到 `23` 个 planned replacements / `5` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `5 passed / 50 blocked`。当前仍不代表 UI 最终清稿、HUD atlas、Boss HUD frame、ability status HUD 或 `stage16_alpha_demo_completion_ai01` 已接入。

同日继续新增 Stage16 completion art runtime binding：`scenes/rooms/stage16_alpha_demo_end_room.tscn` 已新增 `AlphaDemoCompletionArt`，引用 `stage16_alpha_demo_completion_ai01.png` 作为终点房完成反馈装饰。Stage16 专项 GUT 已新增引用保护并通过。P0 runtime replacement plan 因此推进到 `22` 个 planned replacements / `6` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `6 passed / 49 blocked`。当前仍不代表 completion UI 最终清稿、授权确认或最终美术批准。

同日继续新增 TutorialHUD P0 icon runtime binding：`scenes/ui/tutorial_hud.tscn` 已将 `BattlePanel/DashIcon` 改为引用 `stage14_air_dash_icon_ai01.png` 的 `TextureRect`，并新增 `BattlePanel/RecoveryChargeIcon` 引用 `stage15_recovery_charge_icon_ai01.png`。Stage12 / Stage14 / Stage15 专项 GUT 已通过。P0 runtime replacement plan 因此推进到 `20` 个 planned replacements / `8` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `8 passed / 47 blocked`。当前仍不代表 HUD atlas、Boss HUD frame、ability status HUD、图标小尺寸清稿或最终美术批准完成。

同日继续新增 TutorialHUD frame resource binding：`scenes/ui/tutorial_hud.tscn` 已新增隐藏 `BattlePanel/AbilityStatusFrameArt` 与 `BattlePanel/BossHudFrameArt`，分别引用 `stage14_ability_status_hud_ai01.png` 与 `stage15_boss_hud_frame_ai01.png`。Stage12 / Stage14 / Stage15 专项 GUT 已通过。P0 runtime replacement plan 因此推进到 `18` 个 planned replacements / `10` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `10 passed / 45 blocked`。当前仍不代表 HUD frame 最终布局、裁切 / NinePatch、小尺寸读值或最终美术批准完成。

同日继续新增 TutorialHUD atlas resource binding：`scenes/ui/tutorial_hud.tscn` 已新增隐藏 `BattlePanel/HudCoreAtlasPreview` 与 `BattlePanel/IconSheetCorePreview`，分别引用 `hud_core_ui_atlas_ai01` 与 `icon_sheet_core_ai01` 的首个 Godot `AtlasTexture`。Stage12 / Stage14 / Stage15 专项 GUT 已通过。P0 runtime replacement plan 因此推进到 `16` 个 planned replacements / `12` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `12 passed / 43 blocked`。当前仍不代表 HUD atlas region 语义确认、正式图标替换、小尺寸读值或最终美术批准完成。

同日继续新增 Stage16 talisman relay VFX binding：`scenes/rooms/stage16_talisman_relay_room.tscn` 的三个 relay marker 已新增 `RelayArt`，`scenes/rooms/stage16_corruption_purge_room.tscn` 的 purge node 已新增 `TalismanRelayEchoArt`，均引用 `stage16_talisman_relay_ai01.png`。后续 final-ready mini pack 04 已把该资产从整图 VFX sheet 预览推进为 `3x2` / `6` frame region grid，并让 Stage16 relay / purge 房间的 Sprite2D 显式使用 `region_rect`。Stage16 专项 GUT 已通过。当前批准边界只覆盖当前 Stage16 region-bound visual VFX，不覆盖整张 sheet 上屏、通用动画序列或伤害逻辑。

同日继续新增 Stage16 corruption purge VFX binding：`scenes/rooms/stage16_corruption_purge_room.tscn` 的 `CorruptionMiasma` 下已新增 `PurgeArt`，引用 `stage16_corruption_purge_ai01.png`。Stage16 专项 GUT 已新增引用保护并通过；final-art acceptance gates 中 `runtime_replacement` 刷新为 `22 passed / 33 blocked`，其中 `stage16_corruption_purge_ai01` 的运行时引用 gate 已通过。该资产 source safety 当前仍为 `workspace_provenance_recorded_review_required`，表示有当前仓库 provenance 与 Nano Hunter prompt 记录，但缺少机器可读 source ledger；因此本次只证明当前项目候选可运行引用，不代表来源人工复核、授权、VFX polish 或最终美术批准完成。

同日继续新增 Stage14 Air Dash prop runtime binding：`scenes/rooms/stage14_air_dash_shrine_room.tscn` 已新增 `ShrineArt` 与 `GatePreviewArt`，`scenes/rooms/stage14_air_dash_gate_room.tscn` 已新增 `ShrineEchoArt` 与 `GateArt`，分别引用 `stage14_air_dash_shrine_ai01.png` 与 `stage14_air_dash_gate_ai01.png`。两个资产 source safety 均为 `project_session_confirmed`。Stage14 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `13` 个 planned replacements / `15` 个 already referenced；P0 scene replacement batches 推进到 `37` 个 planned scene-asset replacements / `18` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `24 passed / 31 blocked`。当前仍不代表 prop 最终清稿、缩放遮挡、授权确认或最终美术批准完成。

2026-07-04 复核修正：Stage14 shrine / gate 运行态节点已从单张 prop source 改为引用 `shrine_gate_prop_atlas_ai01` 的 editor AtlasTexture（`001_shrine_gate_prop_atlas_ai01_auto_002_c01.atlas_texture.tres` 与 `003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres`），以修复用户截图中的红绿调试门禁读值。Stage14 专项 GUT 和 formal remap 运行态 gate focus 复核均已保护该绑定；旧 `stage14_air_dash_*_ai01.png` 仍保留为已批准 source / 历史候选，不再代表当前样本链路实际显示。

同日继续新增 Stage9 switch controller runtime prop binding：`scenes/rooms/stage9_zone_switch_room.tscn` 已隐藏 `GateSwitch/SwitchVisual` 与 `GateSwitch/Stage12CheckpointMarker`，新增 `GateSwitch/SwitchArt` 引用 `shrine_gate_prop_atlas_ai01.talisman_stake_lit` 的 editor AtlasTexture。Stage9 专项 GUT 已新增引用保护并通过；全房间 DAC OpenGL 复核为 `P0=0 / P1=0 / P2=0`。当前仍不代表正式机关交互按钮、状态动画、SFX、通用机关系统或最终美术批准完成。

同日继续新增 GoalTrial gate runtime prop binding：`scenes/rooms/goal_trial_room.tscn` 的 `GoalBarrier/BarrierArt` 已改为引用 `shrine_gate_prop_atlas_ai01.seal_gate_locked` 的 editor AtlasTexture，并保留旧 `GoalBarrier/BarrierVisual` 隐藏。Stage7 + formal remap GUT 已新增引用保护并通过；全房间 DAC OpenGL 复核为 `P0=0 / P1=0 / P2=0`，`goal_trial.png` 目检确认红绿调试门禁读值已消失。当前仍不代表正式门禁状态机、解锁动画、音效、碰撞重做或最终美术批准完成。

同日继续新增 Stage14 reward marker runtime binding：`scenes/rooms/stage14_backtrack_hub_room.tscn` 已隐藏三个 `RewardVisual` 黄色菱形，并新增 `RewardArt` 引用 `equipment_pickup_atlas_ai01.reward_orb_large` 的 editor AtlasTexture。Stage14 GUT 已新增引用保护并通过；全房间 DAC OpenGL 复核为 `P0=0 / P1=0 / P2=0`，`stage14_backtrack_hub.png` 目检确认黄色调试收益点已替换。当前仍不代表正式 pickup 经济、奖励平衡、拾取音效、动画或最终美术批准完成。

同日继续新增 Stage15 challenge reward marker runtime binding：`scenes/rooms/stage15_challenge_branch_room.tscn` 已将 `Stage13Reward` 从黄色菱形 `Polygon2D` 改为定位用 `Marker2D`，并新增 `Stage13RewardArt` 引用 `equipment_pickup_atlas_ai01.reward_orb_large` 的 editor AtlasTexture。Stage15 GUT 已新增引用保护并通过；全房间 DAC OpenGL 复核为 `39` 房、`P0=0 / P1=0 / P2=0`，`stage15_challenge_branch.png` 目检未再看到黄色奖励菱形。当前仍不代表正式 pickup 经济、奖励平衡、拾取音效、动画或最终美术批准完成。

同日继续收敛 Stage16 purge hazard tint：`scenes/rooms/stage16_corruption_purge_room.tscn` 的 `CorruptionMiasma` alpha 已从 `0.28` 降至 `0.045`，净化主读值保留给 `stage16_corruption_purge_ai01` 的 `PurgeArt`。Stage16 GUT 与全房间 DAC OpenGL 复核通过，`capture_demo_art_composition_review.gd` 已把 `CorruptionMiasma` 纳入高 alpha gameplay warning Polygon 检查。当前仍不代表正式危险区 VFX 时序、音效、伤害或碰撞重做完成。

同日继续新增 TrainingDummy runtime prop binding：`scenes/combat/training_dummy.tscn` 的 `DummyArt` 已从绿色十字 / 准星状 `stage13_seal_node_01.svg` 改为 `shrine_gate_prop_atlas_ai01.seal_pillar_cracked` editor AtlasTexture，并在 `scripts/combat/training_dummy.gd` 中同步收敛受击反馈缩放基线。Stage3 / Stage5 GUT 与全房间 DAC OpenGL 复核通过，`test_room.png` 目检确认绿色训练目标占位已消失。当前仍不代表正式训练目标动画、音效、生命系统、碰撞或教程推进逻辑变化。

同日继续新增 Stage11 endpoint marker runtime binding：`scenes/rooms/stage11_demo_end_room.tscn` 已隐藏 `Stage12ReplayArrow`、`Stage12GoalArrow`、`Stage13ContinueArrow` 三个高亮 Polygon 箭头，并新增 `ReplayMarkerArt`、`GoalMarkerArt`、`ContinueMarkerArt`，分别引用 `equipment_pickup_atlas_ai01.bronze_bell`、`equipment_pickup_atlas_ai01.demo_completion_token` 与 `equipment_pickup_atlas_ai01.shrine_key_token` editor AtlasTexture。Stage12 GUT 与全房间 DAC OpenGL 复核通过，`stage11_end.png` 目检确认大黄色箭头占位已消失；DAC 已新增可见高 alpha `*Arrow` Polygon 检查。当前仍不代表 Stage11 结算 UI、入口动画、音效、checkpoint 或房间切换逻辑变化。

同日继续新增 Stage15 Boss art runtime binding：`scenes/enemies/seal_guardian_boss.tscn` 已新增 `SealGuardianArt` 与 `AttackWarningArt`，`scenes/rooms/stage15_seal_guardian_boss_room.tscn` 已新增 `SealGuardianRoomArt` 与 `BossWarningRoomArt`，分别引用 `stage15_seal_guardian_ai01.png` 与 `stage15_boss_attack_warning_ai01.png`。两个资产 source safety 均为 `project_session_confirmed`。Stage15 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `11` 个 planned replacements / `17` 个 already referenced；P0 scene replacement batches 推进到 `33` 个 planned scene-asset replacements / `22` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `26 passed / 29 blocked`。当前仍不代表 Boss 最终清稿、攻击预警时序、damage Area、动画帧序、授权确认或最终美术批准完成。

同日继续新增 Player readability and Air Dash trail binding：`scenes/player/player_placeholder.tscn` 已新增 `LunaReadabilityArt` 与 `AirDashTrailArt`，分别引用 `stage16_luna_player_readability_ai01.png` 与 `stage14_air_dash_trail_ai01.png`；`scenes/rooms/stage14_air_dash_shrine_room.tscn` 已新增 `AirDashTrailPreviewArt`。两个资产 source safety 均为 `project_session_confirmed`。Stage14 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `9` 个 planned replacements / `19` 个 already referenced；P0 scene replacement batches 推进到 `30` 个 planned scene-asset replacements / `25` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `28 passed / 27 blocked`。当前仍不代表 Luna 最终清稿、Air Dash trail 时序、动画播放、粒子系统、授权确认或最终美术批准完成。

同日继续新增 Miasma TileSet preview binding：`scenes/rooms/stage13_miasma_marsh_entry_room.tscn` 与 `scenes/rooms/stage14_air_dash_gate_room.tscn` 已新增 `MiasmaTilesetPreview` `TileMapLayer`，引用 `miasma_marsh_tileset_ai01.tileset.tres`。该资产 source safety 为 `project_session_confirmed`。Stage13 / Stage14 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `8` 个 planned replacements / `20` 个 already referenced；P0 scene replacement batches 推进到 `28` 个 planned scene-asset replacements / `27` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `29 passed / 26 blocked`。当前仍不代表正式地形替换、autotile、hazard Area、碰撞清稿、授权确认或最终美术批准完成。

同日继续新增 Seal Guardian SpriteFrames preview binding：`scenes/enemies/seal_guardian_boss.tscn` 已新增隐藏 `SealGuardianAnimationPreview`，`scenes/rooms/stage15_seal_guardian_boss_room.tscn` 已新增隐藏 `SealGuardianRoomAnimationPreview`，均引用 `seal_guardian_boss_sheet_ai01.spriteframes.tres`。该资产包含 `project_session_confirmed` 候选，同时仍有 provenance review-required 候选，因此只作为 preview binding 接入。Stage15 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `7` 个 planned replacements / `21` 个 already referenced；P0 scene replacement batches 推进到 `27` 个 planned scene-asset replacements / `28` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `30 passed / 25 blocked`。当前仍不代表 Boss 正式动画替换、帧序确认、脚底基线 / 锚点确认、攻击时序、授权确认或最终美术批准完成。

同日继续新增 Luna core SpriteFrames preview binding：`scenes/player/player_placeholder.tscn` 已新增隐藏 `LunaRunAnimationPreview`、`LunaAirDashAnimationPreview`、`LunaAttackAnimationPreview` 和 `LunaIdleAnimationPreview`，分别引用 `luna_run_sheet_ai01.spriteframes.tres`、`luna_air_dash_sheet_ai01.spriteframes.tres`、`luna_attack_01_sheet_ai01.spriteframes.tres` 与 `luna_idle_sheet_ai01.spriteframes.tres`。四个资产均至少包含 `project_session_confirmed` candidate；`luna_jump_fall_sheet_ai01` 因无当前项目 session 确认候选，本次不接入。Stage14 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `3` 个 planned replacements / `25` 个 already referenced；P0 scene replacement batches 推进到 `23` 个 planned scene-asset replacements / `32` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `34 passed / 21 blocked`。当前仍不代表玩家正式动画替换、帧序确认、脚底基线 / 锚点确认、攻击时序、碰撞盒读值、授权确认或最终美术批准完成。

同日继续新增 Seal Magic VFX atlas preview binding：`scenes/player/player_placeholder.tscn` 与 `scenes/enemies/seal_guardian_boss.tscn` 已新增隐藏 `SealMagicVfxPreview`，引用 `vfx_seal_magic_atlas_ai01.spriteframes.tres` 的 `seal_magic` 动画。该资产至少包含 1 个 `project_session_confirmed` candidate，同时仍有 review-required 候选，因此只作为预览绑定接入。Stage14 / Stage15 专项 GUT 已新增引用保护并通过；P0 runtime replacement plan 推进到 `2` 个 planned replacements / `26` 个 already referenced；P0 scene replacement batches 推进到 `21` 个 planned scene-asset replacements / `34` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `35 passed / 20 blocked`。当前仍不代表正式 VFX 播放、anchor / mask / blend、damage source、hitbox、授权确认或最终美术批准完成。

同日继续新增 Stage15 pressure sigil runtime binding：`scenes/rooms/stage15_seal_pressure_room.tscn` 已隐藏旧 `PressureSigil` Polygon2D，并新增 `PressureSigilArt` 引用 `vfx_seal_magic_atlas_ai01.spriteframes.tres` 的 `seal_magic` 动画作为 `seal_pressure_sigil` 运行态视觉；后续已把该符印 alpha / scale 收敛为弱压力提示，并由 Stage15 GUT 保护上限。Stage15 专项 GUT 与全房间 DAC OpenGL 复核已通过，`stage15_pressure.png` 目检确认高可见菱形占位消失且不再读作大 UI 标记。当前仍不代表 VFX hitbox、damage source、播放时序、音效或 Boss 流程变化。

同日继续新增 miasma warning / pressure VFX runtime binding：`stage13_miasma_marsh_miasma_room.tscn`、`stage13_miasma_marsh_pressure_room.tscn` 与 `stage15_challenge_branch_room.tscn` 已隐藏旧 `WarningVisual` / `MiasmaWarningArt`，新增低 alpha / 小缩放 `MiasmaWarningVfxArt` 引用 `vfx_combat_atlas_ai01.spriteframes.tres`；`scenes/combat/miasma_caster_enemy.tscn` 已隐藏旧 `MiasmaPressureVisual`，新增低 alpha / 小缩放 `MiasmaPressureVfxVisual`，并由脚本在敌人存活 / 击败时同步显示状态和收敛脉冲 alpha。Stage13 + Stage15 GUT 与全房间 DAC OpenGL 复核已通过，`stage13_crossfire.png`、`stage13_miasma.png`、`stage15_challenge_branch.png` 目检确认绿色几何 warning / 压制块消失，黄色地面环不再读作大面积调试范围圈。当前仍不代表腐瘴 Area、敌人 AI 半径、touch damage、hitbox、SFX 或最终 VFX timing 变化。

同日继续新增 runtime source safety 与确认来源 P0 binding：`scripts/assets/audit_runtime_source_safety.py` 会交叉检查 P0 runtime replacement plan、imagegen source safety 和 provenance selected source。当前 `30` 个 P0 runtime assets 中 `18` 个仍需来源 / 派生复核，`0` 个 unsafe。`luna_jump_fall_sheet_ai01` 已重新从 `project_session_confirmed` 的 `candidate_04` 拆出 `24` 个 selected frames，并作为隐藏 `LunaJumpFallAnimationPreview` 接入玩家场景；`stage16_seal_release_threshold_ai01` 已从 `project_session_confirmed` 的 `candidate_02` 导出，并作为 `SealReleaseThresholdArt` visual preview 接入 Stage16 封印阈值房；`hud_core_ui_atlas_ai01` 已从 `project_session_confirmed` 的 `candidate_01` 重建 `16/16` 个 selected items 与 UI atlas，使该运行时 HUD 图集不再处于派生未记录状态。Stage14 / Stage16 专项 GUT 已通过；P0 runtime replacement plan 推进到 `0` 个 planned replacements / `28` 个 already referenced；P0 scene replacement batches 为 `18` 个 planned scene-asset replacements / `36` 个 already referenced；final-art acceptance gates 中 `runtime_replacement` 推进为 `36 passed / 19 blocked`。当前仍不代表最终帧序、道具状态切分、授权确认或最终美术批准完成。

同日继续新增 Stage16 seal release threshold state-sliced runtime binding：`stage16_seal_release_threshold_ai01` 已新增 locked / active / released 三个 `AtlasTexture` editor resource，分别供 `stage16_seal_release_threshold_room.tscn`、`stage15_completion_room.tscn` 与 `stage16_backtrack_confirmation_room.tscn` 引用。Stage16 / Stage15 GUT 与全房间 DAC OpenGL 复核通过，`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检确认不再把整张三状态源图缩小上屏。当前仍不代表封印柱正式状态动画、音效、碰撞或门控逻辑变化。

同日新增 runtime source review queue：`scripts/assets/build_runtime_source_review_queue.py` 会把剩余 `15` 个 runtime review-required 资产写入 `docs/assets/runtime-source-review-queue.json` 与 `.md`。当前分为 `7` 个 `confirmed_candidate_rebuild_candidate`、`2` 个 `manual_compare_selected_mix` 和 `9` 个 `manual_source_review_or_regenerate`；前者需要人工比较混用候选，后者需要人工确认来源或重新 image gen 生成 Nano Hunter 专属候选。综合资产包审计已纳入该队列并要求队列数量与 runtime source safety 的 review-required 数量一致。

同日新增 runtime source regeneration packet：`scripts/assets/build_runtime_source_regeneration_packet.py` 已把当前 `9` 个 `manual_source_review_or_regenerate` 资产导出到 `docs/assets/runtime-source-regeneration-packet.json` 与 `.md`，包含下一候选文件名、目标路径、当前运行时场景和完整 image gen prompt。综合资产包审计已记录 `7 runtime source regeneration prompts`。当前环境未暴露可调用的内置 `image_gen`，因此该 packet 是下一轮真实生成入口，不代表 PNG 已经落盘。

同日新增 runtime source review workbench：`scenes/dev/runtime_source_review_workbench.tscn` 会在 Godot 编辑器中展示剩余 `18` 个 runtime source review-required 资产的当前输出和 `72` 张候选 PNG，并区分 `8` 个 `manual_compare_selected_mix` 与 `7` 个 `manual_source_review_or_regenerate`。该 workbench 已通过 Godot headless 审计，综合资产包审计已记录 `72 runtime source workbench candidates`。它是人工审图入口，不代表来源确认或 final-ready。

同日新增 asset family coverage report：`docs/assets/asset-family-coverage-report.md` 将用户要求的 `10` 个资产族和 `7` 种 Godot 可用格式映射到当前仓库证据。当前 `10/10` 资产族和 `7/7` Godot 格式已达到 structural coverage，`55` 个资产为 structural-ready；后续已有 `55` 个 runtime / prop / internal style / UI panel preview / Theme skin / menu icon strip / internal icon source atlas / TutorialHUD source atlas preview / hidden VFX preview / hidden animation preview / Spine cutout source / environment visual source / editor TileSet source / props-equipment source / material reference source / promo direction source / storyboard direction source 资产通过 finalization review 推进为 final-ready。后续重点从继续扩类别转为来源确认、授权复核、人工清稿、运行时读值和格式细节 polish。

同日继续为 Batch11 `luna_spine_parts_ai01` 与 `seal_guardian_spine_parts_ai01` 生成 Spine-style cutout export：`assets/art/spine_parts/spine_exports/` 下已有 `2` 个 `.atlas`、`2` 个 `.spine_style.json`、`2` 个 `.cutout_manifest.json` 和总索引。当前 `48` 个 part descriptors 已通过 `scripts/assets/audit_spine_cutout_manifests.py --strict` 审计；这些文件是拆件交接描述，不是正式 Spine rig、Godot 骨骼绑定或运行时动画。

同日继续为 Batch10、standalone VFX 与 ARP-07 Boss attack VFX atlas 生成 VFX anchor / blend 规则层：`assets/art/vfx/vfx_rules/` 下已有 `7` 个 `.vfx_rules.json` 和 `vfx_rules.index.json`，覆盖 `vfx_seal_magic_atlas_ai01`、`vfx_combat_atlas_ai01`、Air Dash trail、Boss warning、talisman relay、corruption purge 和 `seal_guardian_attack_vfx_atlas_ai01`。当前 `86` 条 frame / texture rules 已通过 `scripts/assets/audit_vfx_rules.py --strict` 审计，全部显式 `gameplay_collision=false` 与 `damage_source=false`。这些文件是 VFX 接入规则候选；其中 `stage16_talisman_relay_ai01` 与 `stage16_corruption_purge_ai01` 已进一步批准为当前 Stage16 region-bound runtime visual VFX，`seal_guardian_attack_vfx_atlas_ai01` 仍只是 Boss attack VFX atlas candidate，不代表正式 hitbox、hurtbox、damage Area 或最终运行时 VFX 替换。

同日继续为 Batch06 角色 / 敌人 Sprite Sheet 生成 animation rules 层：`assets/art/characters/animation_rules/` 下已有 `8` 个 `.animation_rules.json` 和 `animation_rules.index.json`，覆盖 Luna run / air dash / attack / idle / jump-fall / hit-death、Seal Guardian boss attack 和 core enemies cycle。当前 `172` 条 frame rules 已通过 `scripts/assets/audit_animation_rules.py --strict` 审计。它们记录 first-pass clip、fps、loop、pivot、脚底基线和 frame duration，不是最终帧序、角色一致性、碰撞盒读值或运行时动画替换。

同日新增综合资产包审计层：`scripts/assets/audit_asset_package.py --strict --write-report` 会生成 `docs/assets/asset-package-audit-report.json`。当前报告 `ok=true`，记录 `55` 个 queue 条目、`26` 个 atlas-linked outputs、`302` 个 `AtlasTexture`、`2` 个 `TileSet`、`8` 个 `StyleBoxTexture`、`9` 个 UI Theme mappings、`5` 个 runtime UI skin panels、`4` 个 runtime UI skin textures、`4` 个 standalone UI skin panel rules、`86` 条 VFX rules、`172` 条 animation rules、`48` 个 Spine cutout parts、`55` 个 asset finalization approvals 和 `0` 个 unsafe source candidates。该报告只证明结构性文件、候选池和部分运行时 UI skin 绑定完整，不证明最终美术质量、授权、语义清稿或完整运行时集成。

同日新增 Godot 资产 Gallery 预览层：`scripts/dev/build_imagegen_asset_gallery.gd` 会生成 `scenes/dev/imagegen_asset_gallery.tscn` 和 `docs/assets/imagegen-asset-gallery-manifest.json`。该场景集中展示 `55` 个 queue output PNG、`302` 个 `AtlasTexture` region、`2` 个 TileSet sheet 预览入口、`8` 个 `StyleBoxTexture` 九宫格候选和 `2` 个 Spine-style cutout atlas 预览入口 / `48` 个 part descriptors，并通过 `scripts/dev/audit_imagegen_asset_gallery.gd` 加载审计。当前审计已强化到实际加载并检查 `361` 个普通纹理预览和 `8` 个 StyleBoxTexture 预览的资源绑定。它是人工扫图和编辑器验收入口，不代表 runtime integration 已完成。

同日继续新增 Gallery 渲染烟测：`scripts/dev/capture_imagegen_asset_gallery.gd` 使用非 headless OpenGL 渲染器打开 Gallery，输出本地截图和采样报告到 `tests/artifacts/local/imagegen_asset_gallery/`。当前报告 `ok=true`、`samples=3600`、`non_transparent_ratio=1.0`、`varied_color_buckets=85`，证明 Gallery 视口能渲染出非空、有颜色变化的画面。该截图证据默认不提交，也不代表最终美术质量或运行时接入完成。

同日新增 Godot 节点级接入演示：`scripts/dev/build_imagegen_asset_integration_showcase.gd` 会生成 `scenes/dev/imagegen_asset_integration_showcase.tscn` 和 `docs/assets/imagegen-asset-integration-showcase-manifest.json`，把当前 image gen 资源绑定到真实 `AnimatedSprite2D`、`TileMapLayer`、`PanelContainer` 与 `Sprite2D`。当前 manifest 记录 `10` 个动画节点、`2` 个 TileMapLayer、`4` 个 StyleBox 面板和 `8` 个 AtlasTexture 精灵，并已通过 `scripts/dev/audit_imagegen_asset_integration_showcase.gd` 加载审计。该层证明资源可被 Godot 节点消费，但仍不代表正式 runtime 引用替换、TileSet collision、NinePatch 清稿、动画调速或玩法读值完成。

同日新增 Art readiness 审计：`scripts/assets/audit_art_readiness.py --strict --write-report` 会生成 `docs/assets/art-readiness-audit-report.json`，逐项检查 `55` 个 queue 输出 PNG 的存在性、可读性、尺寸、chroma key 残留和 atlas metadata count。当前报告 `ok=true`，`55/55` 为 `structural_ready`，`55/55` 为 `final_ready`；这表示完整资产族在结构层已补齐，且二十六批 runtime / prop / internal style / region-bound VFX / TutorialHUD frame / DemoShell panel preview / Theme skin / menu icon strip / internal icon source atlas / TutorialHUD source atlas preview / hidden seal magic VFX preview / hidden combat VFX preview / hidden Luna idle / run / Air Dash / attack 01 / jump-fall / hit-death animation preview / hidden core enemy roster preview / Seal Guardian boss attack animation preview / Luna 与 Seal Guardian Spine cutout source / environment visual source / editor TileSet source 资产已经通过 finalization review。其余资产仍需继续进入 Godot / 清稿管线。`stage15_seal_guardian_ai01` 的洋红 chroma key 背景已通过重导出修复为带 alpha 的 `RGBA` PNG，`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`、`stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01` 与 `stage16_demo_menu_icons_ai01` 也已从 chroma-key 候选转换为 alpha PNG；`luna_idle_sheet_ai01` 已用 `candidate_05` 重建为统一侧身 idle loop，`luna_run_sheet_ai01` 已用 `candidate_06` 重建为更一致的侧身 run loop，`luna_air_dash_sheet_ai01` 已用 `candidate_06` 重建为更一致的 Air Dash preview sheet，且记录了两个显式 duplicate recovery frames，`luna_attack_01_sheet_ai01` 已用 `candidate_06` 重建为更一致的 16 帧基础攻击 preview sheet，`luna_jump_fall_sheet_ai01` 已用 `candidate_06` 重建为 24/24 selected-frame jump / fall preview sheet 且无 duplicate fallback，`luna_hit_death_sheet_ai01` 已用 `candidate_04` 重建为 24/24 selected-frame hit / death preview sheet 且无 duplicate fallback，`seal_guardian_boss_sheet_ai01` 已用 `candidate_04` 重建为 20/20 selected-frame 四足封印守卫攻击 preview sheet，`enemies_core_sheet_ai01` 已用 `candidate_06` 重建为 32/32 selected-frame core enemy roster preview sheet 且无 duplicate fallback；`luna_spine_parts_ai01` 与 `seal_guardian_spine_parts_ai01` 已批准为 24-part future rigging handoff source；Batch 24 已将 8 个环境图和 2 个 TileSet 批准为 Alpha Demo visual/editor source；Batch 25 已将 3 个 props/equipment 源和 1 个 material texture reference 批准为 source/editor/reference；Batch 26 已将 promo / logo / CG / storyboard 批准为 presentation / narrative direction source。当前 final-ready blockers 已清零。

同日继续补充 background alpha policy：`scripts/assets/build_background_alpha_policy.py` 会读取 readiness 报告中的背景 alpha 项，生成 `docs/assets/background-alpha-policy-report.json`。当前 `11` 条记录已通过 `scripts/assets/audit_background_alpha_policy.py --strict`，其中 `5` 条 tile / atlas 类记录为 `alpha_allowed_for_tile_or_atlas_padding`，`6` 条 promo / CG / storyboard 类生成 opaque preview 到 `assets/art/promo/opaque_previews/` 与 `assets/art/storyboards/opaque_previews/`。Art readiness 中 `background_asset_contains_alpha` warning 已清零，并转为 `alpha_padding_policy_manual_review=5` 与 `opaque_preview_manual_review=6`；原始 PNG 保持不覆盖。

同日新增最终美术复核队列：`scripts/assets/build_final_art_review_queue.py` 会从 `docs/assets/art-readiness-audit-report.json` 生成 `docs/assets/final-art-review-queue.json` 与 `docs/assets/final-art-review-queue.md`，把 `55` 个资产的 blockers 转换为按 family / priority 排列的人工复核任务。当前记录 `0` 个 manual-review entries、`55` 个 final-ready assets；综合资产包审计已纳入 `0 final-art review entries`。该队列是后续清稿、授权确认、运行时替换和 Godot 复核的执行入口，只有 `docs/assets/asset-finalization-review-records.md` 中列出的资产完成了本轮 final-ready 批准。

同日继续新增 Godot 最终美术复核 Workbench：`scripts/dev/build_final_art_review_workbench.gd` 会读取 `docs/assets/final-art-review-queue.json`，生成 `scenes/dev/final_art_review_workbench.tscn` 与 `docs/assets/final-art-review-workbench-manifest.json`。该场景按 `P0 / P1 / P2` 和 family 展示全部 `55` 个资产预览、blocker count、主要 blockers、next actions 与资源路径；manifest 当前记录 `55` 张 review cards、`0` 个 manual-review assets、`55` 个 final-ready assets。该 Workbench 已通过 Godot headless 审计并纳入综合资产包审计，用于编辑器内扫图和复核排程。

同日继续新增最终美术验收门槛：`scripts/assets/build_final_art_acceptance_gates.py` 会生成 `docs/assets/final-art-acceptance-gates.json` 与 `docs/assets/final-art-acceptance-gates.md`，把每个资产拆成 `source_traceability`、`license_terms`、`godot_structural_resource`、`editor_review_card`、`runtime_replacement`、`family_specific_polish`、`final_approval` 七道 gate。当前 `source_traceability`、`godot_structural_resource`、`editor_review_card` 均为 `55/55` 通过；已有 `55` 个 runtime / prop / internal style / region-bound VFX / TutorialHUD frame / DemoShell panel preview / Theme skin / menu icon strip / internal icon source atlas / TutorialHUD source atlas preview / hidden VFX preview / hidden animation preview / Spine cutout source / environment visual source / editor TileSet source / props-equipment source / material reference source / promo direction source / storyboard direction source 资产通过 `license_terms` 和 `final_approval`，总计 `55` 个 final-ready、`0` 个仍 blocked。综合资产包审计已纳入 `55 final-art acceptance-gated assets`，该层用于明确从结构可用到最终美术批准的剩余门槛。

同日继续新增 P0 runtime replacement plan：`scripts/assets/build_p0_runtime_replacement_plan.py` 会读取 runtime map、runtime catalog 和 acceptance gates，生成 `docs/assets/p0-runtime-replacement-plan.json` 与 `docs/assets/p0-runtime-replacement-plan.md`。当前覆盖 `30` 个 P0 runtime entries，资源和目标场景均存在；`30` 个均已被正式或 dev 场景引用，`0` 个仍为 `planned_manual_replacement`。综合资产包审计已纳入 `30 P0 runtime replacement-plan entries`。该层把 `runtime_replacement` gate 从“全部阻塞”推进到可分批执行的替换清单，但不等于最终美术批准。

同日继续新增 P0 runtime replacement rehearsal：`scripts/dev/build_p0_runtime_replacement_rehearsal.gd` 会读取 P0 replacement plan，生成 `scenes/dev/p0_runtime_replacement_rehearsal.tscn` 与 `docs/assets/p0-runtime-replacement-rehearsal-manifest.json`。当前场景包含 `30` 个 P0 resource-bound nodes，其中 `17` 个 Texture2D 节点、`9` 个 SpriteFrames 节点、`1` 个 TileSet 节点、`1` 个 StyleBoxTexture 节点和 `2` 个 AtlasTexture 节点，已通过 Godot headless 审计。综合资产包审计已纳入 `30 P0 runtime rehearsal nodes`。该层证明 P0 资源可被兼容 Godot 节点消费，是正式替换前排练，不代表目标 gameplay / HUD / room 场景引用已经替换。

同日继续新增 P0 target scene replacement matrix：`scripts/assets/build_p0_target_scene_replacement_matrix.py` 会读取 P0 replacement plan，生成 `docs/assets/p0-target-scene-replacement-matrix.json` 与 `docs/assets/p0-target-scene-replacement-matrix.md`。当前矩阵覆盖 `14` 个目标场景、`30` 个唯一 P0 资产和 `60` 个 scene-asset references；目标场景缺失数为 `0`，仍需正式替换的 scene-asset references 为 `22`，已有 `38` 个 scene-asset references 被引用。综合资产包审计已纳入 `14 P0 target scenes`。该层用于后续按场景拆分正式替换任务，不直接关闭最终美术 gate。

同日继续新增 P0 scene replacement batches：`scripts/assets/build_p0_scene_replacement_batches.py` 会读取 P0 target scene replacement matrix，生成 `docs/assets/p0-scene-replacement-batches.json` 与 `docs/assets/p0-scene-replacement-batches.md`。当前批次计划覆盖 `9` 个可执行替换批次、`14` 个目标场景、`30` 个唯一 P0 资产和 `60` 个 scene-asset references；缺失场景数为 `0`，未分批场景数为 `0`，仍需正式替换的 scene-asset references 为 `22`，已有 `38` 个 scene-asset references 被引用。综合资产包审计已纳入 `9 P0 scene replacement batches`。该层用于后续按 UI、HUD、玩家、Boss、Stage14、Stage16、Stage13 TileSet 和战斗敌人动画逐批替换与验证。

同日新增语义标签层：`scripts/assets/build_asset_semantics.py` 会为 `26` 个 atlas-linked outputs 生成 `.semantics.json`，并写入 `docs/assets/asset-semantics-index.json`；`scripts/assets/audit_asset_semantics.py --strict` 当前通过，覆盖 `538/538` 个 frame / region 条目。另为 standalone `stage16_demo_menu_icons_ai01` 新增 `assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json`，记录 `6` 个 confirmed menu icon semantics，并由 `assets/art/ui/stage16_demo_menu_icons_ai01.regions.json` 锁定 2x3 grid regions。综合资产包审计当前记录 `544` 个 semantic labels。除已批准的 menu icon strip 外，其余语义层仍是 first-pass 入口，不代表全部人工确认或最终接入完成。
