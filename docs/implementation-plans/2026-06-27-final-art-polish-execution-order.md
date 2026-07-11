# 2026-06-27 Final Art Polish Execution Order / 最终美术精修执行顺序

## 目标和边界

目标：在 `55/55 scene_reference_verified` 和 `55/55 final ready` 门禁已通过的基础上，继续做最终视觉 QA / polish，优先处理已接入但仍只是 visual preview、atlas preview 或 editor resource 的资产。

边界：本计划不新增玩法、不改碰撞 / 伤害 / 门控 / AI / 玩家控制，不默认重新生图。只有现有图无法通过裁切、region、缩放、alpha、TileSet 规则或 UI 布局修复时，才进入 image_gen 重生成。

## 当前基线

- `python scripts/assets/audit_art_readiness.py --strict --write-report`：通过，`55/55 structural ready, 55/55 final ready`。
- `python scripts/assets/audit_asset_runtime_map.py --strict`：通过，`55` entries / `9` tracks。
- `python scripts/assets/audit_asset_package.py --strict --write-report`：通过，覆盖 `55 runtime map entries` 与 `55 runtime catalog resources`。
- 后续工作口径：不是补“正式计入”，而是做最终视觉精修和人工读值复核。

## 执行顺序

### Batch FP-01 - 运行态读值截图复核

状态：2026-06-27 已完成第一轮自动截图 / JSON 复核。

范围：Stage13 entry、Stage14 shrine / gate、Stage15 Boss room、Stage16 seal release threshold、DemoShell、TutorialHUD。

检查项：

- 背景 / visual preview 不遮挡玩家、敌人、门、危险区、出口和 HUD。
- visual preview 透明度、缩放和位置不会误导为碰撞体或可交互物。
- 本轮新增的 13 个 visual preview 节点只承担氛围 / 参考，不改变灰盒 gameplay 读值。

退出条件：每个目标场景有截图或 JSON 复核记录；若遮挡或误读，先调节点位置 / alpha / scale，不直接重生图。

验证记录：

- `godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_final_art_polish_fp01_review.gd`：通过。
- 报告：`tests/artifacts/local/final-art-polish/fp01_runtime_readability/fp01_runtime_readability_report.json`。
- 覆盖场景：Stage13 entry、Stage14 shrine、Stage14 gate、Stage15 Boss room、Stage16 seal release threshold。
- 结论：目标 visual preview 节点均存在、可见、资源引用正确、`asset_id` 正确，且没有误挂 Area / Collision 子节点。截图报告仅证明运行态读值 smoke 通过，最终审美和 atlas / TileSet 语义仍进入后续批次。

### Batch FP-02 - Atlas / 大图语义拆分精修

状态：2026-06-27 已完成第一轮自动审计。

范围：`shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01`、`material_texture_atlas_ai01`、`reusable_seal_props_ai01`。

检查项：

- atlas region 是否可读、命名是否能表达实际用途。
- 是否需要把当前 preview 改为明确 `AtlasTexture` region 或独立 Sprite2D 引用。
- 小尺寸道具 / 装备是否仍能看出类别。

退出条件：每个 atlas 至少保留可用 region 清单；不能读的 region 标记为 P2 清稿 / 重生候选。

验证记录：

- `python scripts/assets/audit_final_art_polish_fp02_atlas_split.py --write-report --strict`：通过。
- 报告：`docs/assets/final-art-polish-fp02-atlas-split-report.md` 与 `.json`。
- 结论：`shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01`、`material_texture_atlas_ai01` 均为 `split_ready`，region / semantic / editor AtlasTexture 数量分别为 `24/24/24`、`24/24/24`、`16/16/16`；`reusable_seal_props_ai01` 当前为 `standalone_preview_ready`，当前 visual preview 用途不强制拆 region，只有进入逐物件 runtime 使用时再补 regions。
- 本轮未发现必须进入 P2 重生图的 atlas 失败项。

### Batch FP-03 - TileSet 语义和 collision 复核

状态：2026-06-27 已完成第一轮自动审计和相关 Stage 回归。

范围：`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`。

检查项：

- solid、one-way、hazard visual-only 和 decor tile 是否语义清楚。
- TileSet preview 是否误导正式碰撞边界。
- 是否需要 terrain/autotile 或仅保留手工摆放候选。

退出条件：TileSet rules 更新或确认不改；Godot TileSet audit 与相关 Stage13 / Stage14 GUT 通过。

验证记录：

- `python scripts/assets/audit_final_art_polish_fp03_tileset_semantics.py --write-report --strict`：通过。
- 报告：`docs/assets/final-art-polish-fp03-tileset-review-report.md` 与 `.json`。
- `godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd`：通过，`Editor TileSet resources OK: 2`。
- Stage13 GUT：`test_stage_13_second_content_zone_production.gd` 通过 `9/9`、`68` asserts；`test_stage_13_manual_review_closure.gd` 通过 `1/1`、`22` asserts。
- Stage14 GUT：`test_stage_14_backtracking_and_ability_gating.gd` 通过 `15/15`、`274` asserts。
- 结论：两个 TileSet 均为 `tileset_semantics_ready`，`miasma_marsh_tileset_ai01` 保留 `8` 个 hazard visual-only tiles，`shrine_trial_tileset_ai01` 保持无 hazard visual-only；当前规则仍是保守 first-pass，正式 runtime TileMap 替换前仍需人工边缘拟合、autotile / terrain 复核和危险 Area author。
- 本轮未发现必须进入 P2 重生图的 TileSet 失败项。

### Batch FP-04 - UI / NinePatch / HUD 小尺寸复核

状态：2026-06-27 已完成第一轮自动审计和相关 UI / HUD 回归。

范围：`menu_ninepatch_ui_ai01`、DemoShell title / menu / pause / completion、TutorialHUD icons / frames。

检查项：

- NinePatch 拉伸不明显变形。
- UI 图里没有伪文字、脏边、错误透明区。
- 32 / 64px 图标仍可读。

退出条件：DemoShell / TutorialHUD GUT 通过；必要时只调 StyleBox / TextureRect，不重做 UI 体系。

验证记录：

- `python scripts/assets/audit_final_art_polish_fp04_ui_small_readability.py --write-report --strict`：通过。
- 报告：`docs/assets/final-art-polish-fp04-ui-small-readability-report.md` 与 `.json`。
- `godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd`：通过，`Editor StyleBoxTexture resources OK: 8`。
- `godot --headless --path . --script res://scripts/dev/audit_editor_ui_skin.gd`：通过，`Editor UI skin OK: 9 style mappings, 4 standalone panels`。
- `godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd`：通过，`Runtime UI skin binding OK: 2 scenes, 5 panels, 4 textures`。
- Stage12 / Stage14 / Stage15 / Stage16 GUT 分别通过 `9/9`、`15/15`、`14/14`、`13/13`。
- 结论：`menu_ninepatch_ui_ai01` 的 `8` 个 StyleBoxTexture、`9` 个 Theme mappings、DemoShell / TutorialHUD runtime references、`4` 个 standalone UI panel rules、`2` 个小图标源图、`3` 个 UI atlas regions 均通过结构和引用复核；当前仍保留 `manual_review_required` 和伪文字清理边界。
- 本轮未发现必须进入 P2 重生图的 UI / HUD 失败项。

### Batch FP-05 - 动作帧和 VFX 最终复核

状态：2026-06-27 已完成第一轮自动审计、运行态截图复核和相关 Stage 回归。

范围：已接入 Luna、普通敌人、Seal Guardian、attack / dash / hit spark VFX。

检查项：

- 帧序、脚底基线、根部锚点、VFX offset、alpha、遮挡和命中读值。
- 攻击 / Air Dash / Boss VFX 仍保持独立 VFX 层，不烘回角色动作。

退出条件：现有 Stage14 / Stage15 GUT 通过；必要时补运行态截图复核。只有动作帧几何不合格才进入 image_gen 重生成。

验证记录：

- `python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --write-report --report-json docs/assets/animation-runtime-replacement-candidate-audit-report.json --report-md docs/assets/animation-runtime-replacement-candidate-audit-report.md --strict`：通过，`15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
- `python scripts/assets/audit_vfx_rules.py --strict`：通过，`7 assets, 86 frame rules, 86 collision-disabled rules`。
- `python scripts/assets/audit_animation_rules.py --strict`：通过，`8 assets, 172 frame rules`。
- `python scripts/assets/audit_final_art_polish_fp05_animation_vfx.py --write-report --strict`：通过。
- 报告：`docs/assets/final-art-polish-fp05-animation-vfx-report.md` 与 `.json`。
- 运行态截图复核：`capture_luna_attack_vfx_review.gd`、`capture_luna_air_dash_vfx_review.gd`、`capture_animation_runtime_replacement_review.gd`、`capture_enemy_hit_spark_vfx_review.gd` 均通过。
- Stage14 / Stage15 GUT 分别通过 `15/15`、`14/14`。
- 结论：active runtime animation candidates、first-pass animation rules、VFX no-collision / no-damage rules 与关键 runtime references 均自洽；归档 blocked references 均有替代资源，不再构成活跃阻塞。
- 本轮未发现必须进入 P2 重生图的动作帧 / VFX 失败项。

## Completion Audit / 完成审计

状态：2026-06-27 已完成。

验证记录：

- `python scripts/assets/audit_final_art_polish_completion.py --write-report --strict`：通过，`5/5 FP batches, 2/2 final gates, 0 errors`。
- 报告：`docs/assets/final-art-polish-completion-audit-report.md` 与 `.json`。
- 完成口径：FP-01 到 FP-05 计划批次均已有通过报告，`art-readiness` 与 `asset-package` 两个最终门禁通过；这证明最终美术精修计划的结构 / 运行态 / 审计收口完成，不等于商业发布级手工清稿、最终 typography、正式 autotile / hazard Area author 或完整人工审美签核完成。

## P2 重生成规则

动作帧重生成必须使用 image_gen，并严格要求：透明背景 PNG；不要绿色、白色或棋盘格背景；标准规则网格 sprite sheet；单动作一张优先；每帧同一角色、同一大小、同一比例、同一视角、固定格子、居中；不自由排布、不沿跳跃弧线散布、不重叠、不裁切头发 / 衣袖 / 衣摆 / 武器 / 特效；武器和特效不得跨格；根部锚点稳定，落地帧脚底清楚。

## 推荐下一步

先执行 FP-01。它成本最低，能直接判断后续是调场景参数、拆 atlas，还是少量进入 P2。
