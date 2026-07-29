# Level Layout and Map Polish LL-00 to LL-06 Execution Plan

## 目标

按 `LL-00` 到 `LL-06` 系统推进关卡场景和地图布置：先审计、再修通关阻塞、再做地图语义、TileSet 样板、碰撞 / hazard author、image_gen 补图和完整 QA。

边界：本计划不新增 Stage17 玩法，不重写玩家控制，不默认购买资产包，不一次性重铺全部房间。

## 当前基线

- Stage16 Alpha Demo 候选已经可运行。
- `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 已有 Godot TileSet editor resources 和第一轮语义审计。
- Stage13-16 环境、props、VFX、UI 等资产已经有 scene reference 和 final-art polish 审计记录。
- 仍缺：完整逐房截图审计、P0/P1/P2 问题表、正式 runtime TileMap 样板、hazard Area author、地图美术和碰撞一致性复核。

## 执行状态 - 2026-06-29

- `LL-00` 已执行：新增 `scripts/dev/audit_level_layout_map_ll00.gd`，逐房审计 `27` 个关键房间并输出 `tests/artifacts/local/level-layout-map-polish/ll00_audit/ll00_level_layout_audit_report.md/json` 与截图证据。
- `LL-01` 已执行：有效审计结果为 `P0=0`，无需新增 P0 阻塞修复；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT 均通过。
- `LL-02` 已执行第一轮分流：关键房间语义以审计脚本 `intent` 字段和报告问题表落地；当前没有新的玩法 API 需求。
- `LL-03` 已执行样板补齐：在 `stage14_air_dash_shrine_room`、`stage15_seal_guardian_boss_room`、`stage16_seal_release_threshold_room` 新增 visual-only `TileMapLayer`，与既有 `stage13_miasma_marsh_entry_room`、`stage14_air_dash_gate_room` 形成 `5` 个样板房。
- `LL-04` 已执行首批 author：`stage16_corruption_purge_room` 新增 `CorruptionMiasmaHazardArea`，把可见腐化雾记录为独立 hazard author 区域，但不改变当前净化触发和伤害逻辑。
- `LL-05` 已执行缺口判断：本轮不触发新 image_gen，也不引入开源 / 购买资产包；剩余 `21` 条 P2 均为灰盒视觉和未接入 asset-bound visuals，优先进入后续现有资产复用 / 批量 visual replacement，而非立即重生图。
- `LL-06` 已执行验证：`godot --headless --path . --import` 通过；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT 合计 `61/61` tests、`832` asserts 通过；Godot MCP Pro 抽样验证 `stage14_air_dash_gate_room` scene tree、collision info、TileMap info 和 editor screenshot。

当前审计收束口径：

```text
P0 = 0
P1 = 0
P2 = 21
```

剩余 P2 不阻塞当前 Alpha Demo 主链路；下一轮若继续推进，应优先处理 `no_asset_bound_visuals` 房间和 `graybox_visual_dominant` 房间，而不是扩玩法体量。

## 统一分级

- `P0`：玩家无法通关、卡死、跳不上、过不去、攻击/门控无效、transition 失败。
- `P1`：可通关但读值差，平台没有意义，路线不清，摄像机 / HUD 遮挡，视觉误导碰撞。
- `P2`：美术粗糙，灰盒明显，背景 / props / TileSet 不够统一，但不影响试玩。

## 统一证据路径

本地证据默认放入：

```text
tests/artifacts/local/level-layout-map-polish/
```

建议子目录：

```text
ll00_audit/
ll01_p0_fixes/
ll02_layout_semantics/
ll03_tileset_samples/
ll04_collision_hazard/
ll05_art_generation/
ll06_full_route_qa/
```

## LL-00 - 关卡场景和地图布置审计

目标：不改大结构，先得到完整问题清单。

范围：

- `tutorial_room`
- Stage13 miasma marsh 主线与支线房间
- Stage14 Air Dash shrine / gate / backtrack rooms
- Stage15 pressure / gauntlet / challenge / Boss / completion rooms
- Stage16 seal release / relay / purge / end rooms

工具：

- Godot MCP Pro：`play_scene`、`get_game_screenshot`、`capture_frames`、`get_game_scene_tree`、`get_collision_info`。
- 现有 GUT：Stage5 / Stage13 / Stage14 / Stage15 / Stage16。
- 可新增一个最小 dev capture 脚本，仅用于逐房截图和 JSON 报告。

任务：

1. 逐房列出：房间路径、主目标、当前视觉层、碰撞层、hazard、出口、spawn、camera limits。
2. 保存关键房间截图。
3. 标注 P0 / P1 / P2 问题。
4. 形成 `ll00_level_layout_audit_report.md/json`。

退出条件：

- 每个关键房间至少有一条审计记录。
- 所有 P0 问题进入 LL-01。
- 所有 TileSet / image_gen / asset pack 缺口进入 LL-03 或 LL-05。

## LL-01 - P0 通关阻塞修复

目标：先让整条 Alpha Demo 路线稳定可通，不追求好看。

范围：

- 跳跃高度 / 平台位置 / 一路通过空间。
- dash 门高度和长度。
- 攻击门、Boss 门、终局门控。
- spawn、checkpoint、room transition。
- 明显碰撞卡死点。

工具：

- Godot MCP Pro 运行态输入和截图。
- `update_property` / `batch_set_property` 做小范围场景参数修正。
- GUT 回归。

任务：

1. 对 LL-00 的 P0 逐条修复。
2. 每个修复优先修改房间 scene export / node property，不新增系统。
3. 每个非平凡修复补一条最小回归或 MCP 运行态证据。

退出条件：

- P0 列表清零。
- Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT 通过。
- MCP 至少能从开始推进到 Stage16 终点或用灰盒 driver 证明主链路仍可达。

## LL-02 - 地图语义重排

目标：让每个关键房间有明确玩法意图，不再出现“低台阶没有意义”或“门控目标不清”。

房间意图模板：

```text
房间：
主要意图：
次要意图：
玩家入口：
玩家出口：
核心交互：
危险：
奖励 / 支路：
美术语义：
```

优先样板：

- 教程：移动 / 跳跃 / dash / 攻击四段各自清楚。
- Stage13 entry：瘴泽区域入口，低压读值。
- Stage14 shrine/gate：Air Dash 能力价值。
- Stage15 Boss room：战斗空间、预警、失败重试。
- Stage16 threshold/purge：终局封印链和妖瘴净化。

任务：

1. 为关键房间补房间意图表。
2. 删除或调整无意义台阶、障碍、装饰碰撞。
3. 保持每房一个主机制。
4. 记录哪些灰盒块将由 TileSet / prop / VFX 替换。

退出条件：

- 关键样板房都有意图表。
- P1 “读不懂”问题有明确修复策略。
- 不新增玩法 API。

## LL-03 - TileSet / Visual Replacement 样板

目标：把现有 TileSet 和环境图先接到 3-5 个样板房，证明视觉层可工作。

策略：

- 第一轮 visual-only：保留现有 StaticBody2D 碰撞，TileMapLayer / Sprite2D 只做视觉。
- 只对样板房做，不全图铺开。
- 使用现有 `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01`。

样板候选：

- `stage13_miasma_marsh_entry_room`
- `stage14_air_dash_shrine_room`
- `stage14_air_dash_gate_room`
- `stage15_seal_guardian_boss_room`
- `stage16_seal_release_threshold_room`

工具：

- Godot MCP Pro TileMap 工具：`tilemap_get_used_cells`、`tilemap_set_cell`、`tilemap_fill_rect`。
- 大量格子优先 dev 脚本，MCP 只复核。
- `get_game_screenshot` 做小尺寸读值。

任务：

1. 选 3-5 个样板房。
2. 为每房定义 tileset source、目标 TileMapLayer、visual-only metadata。
3. 铺最小地面 / 平台 / 边缘 / 装饰。
4. 确认玩家、敌人、出口、门控不被遮挡。

退出条件：

- 样板房截图可读。
- Stage13 / Stage14 / Stage15 / Stage16 相关 GUT 通过。
- 未把 visual-only TileMap 当作正式 collision。

## LL-04 - Collision / Hazard / Camera Author

目标：把样板房从 visual-only 推进到可玩的 collision / hazard / camera 基线。

范围：

- StaticBody2D / CollisionShape2D。
- One-way 平台。
- Hazard Area2D。
- Camera2D limits。
- Spawn / checkpoint / transition zone。

工具：

- Godot MCP Pro：`get_collision_info`、`get_physics_layers`、`update_property`。
- GUT：spawn lands on floor、hazard damages、transition works、jump/dash reachability。

任务：

1. 对样板房标注真实可站区域。
2. hazard 视觉和 Area2D 对齐，不靠图片造成伤害。
3. camera limits 不裁切关键平台和出口。
4. spawn 不落进危险区、不卡墙、不直接触发错误 transition。

退出条件：

- 样板房 collision / hazard / camera 有审计记录。
- 相关 GUT 和 MCP 运行态验证通过。
- 没有把背景或前景错误挂到碰撞层。

## LL-05 - Image Gen / 外部资产补缺

目标：根据 LL-03 / LL-04 的真实缺口补图，不提前生成一堆可能用不上的素材。

优先顺序：

1. 现有资产裁切 / 缩放 / region / TileSet 规则能解决，就不生图。
2. 现有资产缺关键 tile / prop / state，使用 image_gen。
3. image_gen 仍无法稳定满足，才评估开源或购买资产包。

Image Gen 输出路径建议：

```text
assets/source/ai_generated/level_layout_map_polish/ll05/
assets/art/tilesets/level_layout_map_polish/
assets/art/backgrounds/level_layout_map_polish/
assets/art/props/level_layout_map_polish/
assets/art/vfx/level_layout_map_polish/
```

TileSet prompt 基线：

```text
High quality 2D side-view metroidvania tileset for a Southern and Northern Dynasties eastern fantasy demon-sealing shrine and miasma marsh, orthographic pixel-painting / painterly game art, modular 32x32 grid, ground tiles, wall tiles, platform edges, inner corners, outer corners, cracked stone, moss, talisman paper seals, corrupted miasma hazard tiles, no characters, no UI, no text, no logo, no perspective, no freeform layout, each tile centered in its fixed grid cell, transparent background PNG if possible.
```

Parallax prompt 基线：

```text
Layered 2D metroidvania parallax background, Southern and Northern Dynasties eastern fantasy demon-sealing shrine ruins over a misty miasma marsh, readable gameplay foreground left empty, no characters, no UI, no text, no obvious walkable platform silhouettes in background, cinematic but game-readable, 16:9, separated depth layers, soft ink-and-gongbi inspired palette, moonlit cyan talisman glow, high quality production game background.
```

Prop prompt 基线：

```text
Transparent background PNG, single centered eastern fantasy demon-sealing shrine prop, talisman gate / stone seal pillar / miasma purifier, side-view 2D game asset, readable at 64-128 px, no text, no logo, no ground shadow baked beyond object footprint, enough padding, clean silhouette, three state design language: locked, active, completed.
```

外部资产包评估清单：

- 授权：商业 demo、修改、再分发、团队协作是否允许。
- 格式：是否提供 PNG、PSD/ASE、TileSet、分层背景。
- 风格：是否能回收到东方奇幻。
- 技术：是否能拆 collision / hazard / decor。
- 成本：是否比 image_gen + 清稿更省。

退出条件：

- 每个新图都有 source、prompt、输出路径和接入目标。
- 没有授权不清资产进入 runtime。
- image_gen 输出通过透明 / 切片 / 小尺寸读值 / Godot import 检查。

## LL-06 - 全流程 QA 与收口

目标：证明本轮地图布置计划和已实现批次没有破坏 Alpha Demo。

验证：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage13/test_stage_13_second_content_zone_production.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
git diff --check
```

MCP 复核：

- 主菜单开始。
- 教程 1/4 到 4/4。
- Stage13 瘴泽主线。
- Stage14 Air Dash 获取和 gate。
- Stage15 Boss 房与完成房。
- Stage16 终局链路。
- 暂停 / 重开 / 完成反馈。

收口产物：

- `ll06_full_route_review_report.md/json`
- 本地截图证据。
- 更新 `docs/progress/status.md`、`timeline.md`、当日日志。
- 若新增图，更新 `docs/assets/asset-manifest.md` 和 provenance / source safety。

退出条件：

- P0 清零。
- 样板房通过截图和运行态复核。
- 自动化通过。
- 文档留痕完成。
- 后续剩余 P1 / P2 有明确 backlog，不伪称商业级完成。

## 推荐执行顺序

1. 先执行 LL-00。
2. 如果发现 P0，立即进入 LL-01。
3. P0 清零后做 LL-02。
4. 只选择 3-5 个样板房进入 LL-03 / LL-04。
5. LL-05 只补样板房暴露的真实缺口。
6. LL-06 收口后再决定是否扩到全房间。
