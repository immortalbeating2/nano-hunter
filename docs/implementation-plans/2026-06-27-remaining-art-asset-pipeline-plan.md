# 2026-06-27 Remaining Art Asset Pipeline Plan / 剩余美术资产管线处理计划

## 目标和影响范围

本计划用于收束 Stage16 之后剩余美术资产处理：先确认之前已生成但未正式接入、未能在当前永久工作树重放完整证据链的美术资产，再按已有资产管线节奏处理或重新生成。

影响范围限定为美术资产管线、资产证据、Godot editor/runtime visual 资源和相关文档；不改变玩家控制、敌人 AI、Boss 状态机、伤害判定、房间流程、音频或 Stage17 玩法边界。

## 当前盘点结论

- 2026-06-27 执行状态：P0 证据链恢复与审计口径已收束，P1 已生成运行态 / editor 资源的第一轮最小验证已完成，并把 runtime integration map 从全量保守 `manual replacement required` 推进为 `55/55 scene_reference_verified`；P2 未触发，本轮没有新增 image_gen 输出。
- `docs/assets/asset-family-coverage-report.md` 记录完整美术资产族已结构覆盖：`10/10` asset families、`7/7` Godot formats、`55` structural-ready / final-ready assets。
- `docs/progress/status.md` 的 2026-06-25 复核结论已确认动作正式替换批次当前为 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
- 本轮复跑验证：
  - `python scripts/assets/build_runtime_source_review_queue.py`：`0 review-required assets, 0 unsafe`。
  - `python scripts/assets/audit_runtime_source_safety.py --write-report`：`30 runtime assets, 0 review-required, 0 unsafe`。
  - `python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict`：`15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
- 本永久工作树中 `assets/source/ai_generated/` 只保留占位目录，历史 raw candidate PNG 池未随普通 Git 提交；P0 已按 `docs/assets/asset-storage-policy.md` 修正审计口径：raw candidates 属于 ordinary Git 外的可选原始证据，不再阻塞当前 Git 可重放资产包审计。
- `asset-runtime-integration-map.json` 仍标记 `55` 个生成资产为 `binding_map_ready_manual_replacement_required`，说明它们有目标系统和场景候选，但不是全部都已经替换为正式 runtime 引用。

## 2026-06-27 执行记录

- P0 已完成：`audit_asset_package.py`、`audit_asset_provenance.py` 与 `audit_imagegen_source_safety.py` 已区分 Git 可重放资产包和普通 Git 外原始候选证据；promo / CG / storyboard opaque preview evidence 已通过 `build_background_alpha_policy.py` 重建。
- P1 第一轮已完成：Godot import、TileSet editor resource audit、Stage13 / Stage14 / Stage15 / Stage16 GUT 均通过，确认当前已接入的动作、UI、VFX、TileSet editor 资源没有被 P0 审计口径调整破坏；`asset-runtime-integration-map.json` 已能记录直接场景引用，当前 `55/55` 条目已识别为 `scene_reference_verified`。
- P2 未触发：当前没有因小尺寸读值、透明背景、TileSet、NinePatch、VFX 或动作帧几何问题需要立即重生图。后续若生成动作帧，必须使用本计划 P2 的透明背景规则网格 sprite sheet 规格。

### 本轮新增 visual preview 接入的 13 个美术条目

- 环境 / TileSet / 材质：`shrine_trial_tileset_ai01`、`material_texture_atlas_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome01_shrine_trial_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`biome02_miasma_marsh_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_air_dash_shrine_room_ai01`、`biome02_miasma_hazard_room_ai01`、`stage15_seal_guardian_boss_room_ai01`。
- 道具 / 装备 atlas：`shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01`、`reusable_seal_props_ai01`。
- 接入边界：本轮只接 visual preview 节点或 TileMapLayer preview，均带 `asset_id` / `visual_preview_only` 类 metadata；不改变碰撞、伤害、门控、敌人 AI、玩家控制或正式 parallax / shader / atlas split 语义。
- 后续建议：下一批不再处理“是否有场景引用”这个缺口，而是按资产族做美术 polish、遮挡复核、TileSet 语义复核、atlas 拆区和运行态截图读值检查；如果背景遮挡玩法或 atlas 语义不可读，再进入 P2 重生成 / 清稿。

## 剩余美术资产分组

### A. 已正式接入运行态，继续保留

当前已验证的正式运行态视觉替换包括：

- Luna：idle、run、jump/fall、attack clean body、attack slash VFX、attack seal arc VFX、air dash clean body、air dash trail、hit/death runtime clips。
- 普通敌人：基础近战、地面冲锋、空中哨卫、瘴气施法敌 runtime visual clips。
- Seal Guardian：idle、warning、defeat、attack clean body、attack VFX。
- 战斗反馈：enemy hit spark runtime VFX。

处理原则：不重新生成，不降级回旧 preview；后续只做运行态截图复核、offset / alpha / timing 微调或新 Stage 内容扩展。

### B. 已生成但仍是 source / editor / preview，不算完整正式接入

以下资产已存在于 `assets/art/` 或 editor resource 层，但当前主要身份仍是 source、preview、direction 或 manual replacement candidate：

- 环境和 TileSet：`biome01_*`、`biome02_*`、`stage15_seal_guardian_boss_room_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`。
- 道具与装备：`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`equipment_pickup_atlas_ai01`、`shrine_gate_prop_atlas_ai01`、`reusable_seal_props_ai01`。
- UI 和图标源：`hud_core_ui_atlas_ai01`、`icon_sheet_core_ai01`、`menu_ninepatch_ui_ai01`、Stage16 菜单 / 暂停 / 完成 UI 源图。
- Spine 拆件：`luna_spine_parts_ai01`、`seal_guardian_spine_parts_ai01`。
- 贴图、宣传、LOGO、CG、分镜：`material_texture_atlas_ai01`、`promo_*`、`nano_hunter_logo_direction_ai01`、`cg_*`、`storyboard_*`。

处理原则：优先补证据和接入验证；只有无法满足读值、透明、切片、九宫格、TileSet、parallax 或语义要求时才重新生成。

### C. 历史 blocked / archived references

旧的 8 个 source sheet blocker 已作为归档参考保留，不再阻塞当前运行态。它们只在需要扩展动作库、重做清稿或追溯失败原因时使用，不作为“未完成资产”反复处理。

## 执行计划

### P0 - 证据链恢复与审计口径收束

状态：2026-06-27 已完成。

1. 确认 raw candidate 缺失是否符合当前 asset storage policy。
2. 若 raw candidates 不应提交，则更新或补充 package audit 口径，让它区分：
   - 当前 Git 可重放的 runtime/editor package。
   - 本地或外部保存的 raw generation evidence。
   - 已归档但不再阻塞的 review workbench/contact sheet。
3. 补齐 opaque preview evidence 的当前状态记录，尤其是 promo / CG / storyboard 六个 opaque preview 项。
4. 重新跑：
   - `python scripts/assets/audit_asset_package.py --strict --write-report`
   - `python scripts/assets/audit_asset_provenance.py --strict --write-report`
   - `python scripts/assets/audit_final_art_acceptance_gates.py --strict --write-report`

退出条件：资产包审计不再因为旧候选池或归档 contact sheet 漂移失败；若 raw evidence 缺失是预期状态，报告必须明说而不是假装完整。

### P1 - 已生成未正式接入资产的最小运行态处理

状态：2026-06-27 已完成第一轮安全验证、13 个剩余条目的 visual preview 接入和 `55/55` runtime map 场景引用确认；更深的场景替换 polish 留到后续小批次。

1. 环境 / TileSet：挑 `shrine_trial_tileset_ai01` 与 `miasma_marsh_tileset_ai01` 做 Godot TileSet resource 加载和一间代表房间的 visual replacement 试接入。
2. 道具 / 装备：按 Stage14 / Stage16 场景候选接入 shrine、gate、seal threshold 的静态 visual 层，保持 collision 和 gameplay area 不变。
3. UI / 图标：复核 `menu_ninepatch_ui_ai01` StyleBox、DemoShell panel、HUD icon 小尺寸读值；只替换可安全显示的 Texture / StyleBox。
4. VFX / texture：保留现有已接入 runtime VFX；未接入 texture atlas 先作为 material reference，不强行绑定 shader。

退出条件：每个接入项都有目标场景、可见节点、资源路径、无碰撞副作用验证和最近 GUT / Godot import 记录。

### P2 - 需要重新生成或清稿的美术资产

状态：2026-06-27 未触发。

只在 P0/P1 复核后触发重生成。触发条件：

- 小尺寸读值失败且无法通过裁切 / padding / alpha 修复。
- NinePatch 拉伸明显变形。
- TileSet tile 语义、碰撞边界或 hazard 视觉不可用。
- 场景背景遮挡 gameplay path 或亮度影响可读性。
- UI / promo / storyboard 含伪文字、现代实验室、现代 UI、科幻或外项目风格污染。

重生成仍沿用现有 `docs/assets/runtime-source-regeneration-packet.md`、`image-gen-prompt-queue.json` 和 `import_imagegen_outputs.py` 流程：新图先进 `assets/source/ai_generated/.../candidates/`，通过 source safety / manual review 后再替换 `assets/art/`。

动作帧重生成必须覆盖用户补充规则：输出透明背景 PNG，不使用绿色、白色或棋盘格背景；使用标准规则网格 sprite sheet；按游戏需要确定尺寸，尽量单动作一张精灵图；每帧同一角色、同一大小、同一比例、同一视角、固定格子、居中显示；不得自由排布、沿跳跃弧线散布、相邻帧重叠、裁切头发 / 衣袖 / 衣摆 / 武器 / 特效；武器和特效不得跨格；角色根部锚点稳定，落地帧脚底清楚。

## 验证计划

- 资产与来源：
  - `python scripts/assets/audit_imagegen_source_safety.py --write-report --strict`
  - `python scripts/assets/audit_runtime_source_safety.py --write-report`
  - `python scripts/assets/audit_asset_runtime_map.py --strict --write-report`
- Godot 资源：
  - `godot --headless --path . --import`
  - 对应场景最小 GUT，例如 Stage14 / Stage15 / Stage16 当前测试。
- 接入复核：
  - 使用 Godot MCP 或现有 `scripts/dev/capture_*_review.gd` 类脚本做截图 / JSON 本地证据。
  - 本地证据继续放入 `tests/artifacts/local/<topic>/`，默认不提交。

## 风险和不做项

- 不把 `55/55 final-ready` 解释为商业发布级完整资产完成；它只覆盖 Alpha Demo source / editor / preview / internal direction 边界。
- 不把缺失 raw candidate PNG 简单判为资产失败；先按 storage policy 判断是否本来就不应提交。
- 不为了修 package audit 一次性提交大体积候选图。
- 不在本轮处理音频、视频、商业宣传最终稿或 Stage17 新玩法资产。

## 下一步

推荐先执行 P0。P0 收口后，再按 P1 选 2-3 个最靠近当前 Alpha Demo 的可见场景做小批量接入；每批只改一个资产族，验证通过后再继续下一批。
