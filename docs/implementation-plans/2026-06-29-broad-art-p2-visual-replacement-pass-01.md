# Broad Art P2 Visual Replacement Pass 01-05

## Summary

本计划承接 `LL-00` 到 `LL-06` 第一轮关卡 / 地图审计后的剩余 `P2=21`，目标不是扩大新图生成量，而是先把已经通过资产管线验证的美术资源接入正式运行场景，减少 `no_asset_bound_visuals` 和 `graybox_visual_dominant`，并为后续视觉复核建立可复跑节奏。

当前 Pass 01-05 已完成：复用现有 miasma / shrine / seal / UI 资产补齐 27 个审计房间的视觉绑定，LL-00 审计从 `P0=0 / P1=0 / P2=21` 推进到 `P0=0 / P1=0 / P2=0`。本轮不触发新 image_gen。

## Source Evidence

- `tests/artifacts/local/level-layout-map-polish/ll00_audit/ll00_level_layout_audit_report.md`：第一轮审计为 `P0=0 / P1=0 / P2=21`，剩余问题集中在 `no_asset_bound_visuals` 与 `graybox_visual_dominant`。
- `docs/assets/asset-production-roadmap.md`：本轮对应 Batch 03 区域表现资产与 Batch 07 TileSet / 贴图，不改变玩法 Stage 边界。
- `docs/assets/asset-generation-brief.md`：如后续缺口需要重生成，应继续遵守东方奇幻、山海经 / 佛门符印、透明背景和 Godot 可接入规范。

## Scope

Pass 01 首批处理房间：

- `scenes/rooms/stage13_miasma_marsh_miasma_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_gate_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_goal_room.tscn`

Pass 02 / 03 追加处理房间：

- `scenes/rooms/tutorial_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn`
- `scenes/rooms/stage13_miasma_marsh_return_room.tscn`
- `scenes/rooms/stage14_backtrack_hub_room.tscn`
- `scenes/rooms/stage14_loop_return_room.tscn`
- `scenes/rooms/stage15_completion_room.tscn`
- `scenes/rooms/stage16_backtrack_confirmation_room.tscn`
- `scenes/rooms/stage16_corruption_purge_room.tscn`
- `scenes/rooms/stage16_alpha_demo_end_room.tscn`

新增内容：

- Stage13 P2 房间新增 `MiasmaBackgroundArt`、`MiasmaTileSheetArt` 和 visual-only `MiasmaTilesetPreview`。
- Tutorial / Stage14 / Stage15 / Stage16 P2 房间新增 shrine / seal / UI 方向的 Sprite2D 或 visual-only `ShrineTrialTilesetPreview`。
- 新增或扩展 Stage13 / Stage14 / Stage16 GUT 断言，保护 asset_id、resource path、TileSet resource path 和 used cells。

## Non-Goals

- 不重铺正式 runtime collision。
- 不替换 StaticBody2D / Area2D 玩法碰撞。
- 不改攻击、跳跃、门控、房间跳转、敌人 AI 或 HUD。
- 不生成新图片，不引入开源或购买资产包。
- 不把 visual-only TileMapLayer 误声明为最终 autotile / terrain 完成。

## Image Gen Decision

本轮 Pass 04 判定不调用 image_gen。原因：

- 目标缺口已由现有 `miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`、biome 背景 / tile sheet、seal props、Stage16 UI / VFX 候选图覆盖。
- LL-00 审计已从 `P2=21` 清到 `P2=0`，没有剩余必须靠新图解决的自动审计缺口。
- 新生成图不会比复用已审计资产更快、更稳地改善当前运行场景。

后续若触发 image_gen，优先目标是：

- `stage13_miasma_checkpoint_prop_ai02`
- `stage13_miasma_branch_signpost_ai02`
- `stage14_backtrack_hub_shrine_props_ai02`
- `stage15_completion_seal_gate_feedback_ai02`
- `stage16_backtrack_confirmation_marker_ai02`
- `tutorial_room_training_layout_visual_ai02`

生成规则继续遵守：透明背景 PNG、无绿色 / 白色 / 棋盘格背景、Godot 可切片、对象居中、留白充足、不可裁切、与南北朝东方奇幻和瘴泽 / 符印 / 古刹方向一致。

## Execution Order

1. Pass 01：已完成。复用现有 TileSet，先处理 Stage13 高优先 `no_asset_bound_visuals` 房间。
2. Pass 02：已完成。继续清掉剩余 `no_asset_bound_visuals`，覆盖 Stage13 checkpoint / branch / return、Stage14 backtrack / loop、Stage15 completion、Stage16 backtrack confirmation。
3. Pass 03：已完成。降低 `graybox_visual_dominant`，为仍有大量 Polygon2D 灰盒块的房间补背景层、prop atlas、UI / marker 或局部 TileMapLayer。
4. Pass 04：已完成。现有资产覆盖本轮缺口，不调用 image_gen。
5. Pass 05：已完成本地 MCP 抽样截图，RoleMux / agy 交叉核验由独立 subagent 执行。

## Validation

- `godot --headless --path . --import`：通过。
- `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/stage5 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage15 -gdir=res://tests/stage16`：通过，`65/65` tests，`1035` asserts。
- `godot --rendering-driver opengl3 --path . --script res://scripts/dev/audit_level_layout_map_ll00.gd`：通过，审计从 `P0=0 / P1=0 / P2=21` 改善为 `P0=0 / P1=0 / P2=0`。
- Godot MCP Pro 抽样：
  - `stage13_miasma_marsh_checkpoint_room.tscn`：`MiasmaTilesetPreview used_cells=8`，TileSet source 指向 `res://assets/art/tilesets/miasma_marsh_tileset_ai01.png`。
  - `stage14_backtrack_hub_room.tscn`：`ShrineTrialTilesetPreview used_cells=8`，TileSet source 指向 `res://assets/art/tilesets/shrine_trial_tileset_ai01.png`。
  - `stage16_backtrack_confirmation_room.tscn`：`ShrineTrialTilesetPreview used_cells=8`，TileSet source 指向 `res://assets/art/tilesets/shrine_trial_tileset_ai01.png`。
- 本地截图证据：
  - `tests/artifacts/local/broad-art-p2-visual-replacement/pass05_mcp/stage13_checkpoint_editor.png`
  - `tests/artifacts/local/broad-art-p2-visual-replacement/pass05_mcp/stage14_backtrack_hub_editor.png`
  - `tests/artifacts/local/broad-art-p2-visual-replacement/pass05_mcp/stage16_backtrack_confirmation_editor.png`
- RoleMux / agy 交叉核验：独立 subagent 执行 `rolemux review --provider agy --role reviewer --task .\.rolemux\tasks\pass05-asset-cross-check-2026-06-29.md --workdir .`，结果 `status=success`，Agy 审阅结论 `PASS`。
  - RoleMux artifact：`.rolemux/tasks/20260629T095737-b87f3a/output.md`
  - Agy artifact：`C:/Users/peng8/.gemini/antigravity-cli/brain/c62aba1c-5f8b-4af4-a081-97e27f7097c1/p05_asset_cross_check_review.md`

## Exit Criteria

- Pass 01-03 的目标房间均有 asset-bound visual。
- Stage5 / Stage13 / Stage14 / Stage15 / Stage16 回归通过。
- LL audit 的 P2 数字清零。
- Pass 04 记录本轮不触发 image_gen 的原因。
- Pass 05 完成 MCP 抽样截图，并接入 RoleMux / agy 交叉核验。

## Remaining Risks

- 本轮清掉的是当前 LL 自动审计 P2，不等于商业发布级人工审美签核。
- visual-only TileMapLayer 不代表最终地形碰撞、one-way 平台、hazard Area 和 camera framing 完成。
- 后续正式 TileMap / terrain / parallax 仍应在单独关卡美术清稿阶段推进。
