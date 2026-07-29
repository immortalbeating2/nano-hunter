# Demo Art Composition and Asset Configuration Plan

## Summary

本计划用于修正当前 Alpha Demo 的资产配置口径：此前 `LL-00`、Broad Art P2 和 P1-P3 主要证明“房间有资产引用、流程能跑、GUT 能过”，但用户运行截图暴露出更真实的问题：背景只覆盖局部、地面视觉不连续、TileMap 像散块堆放、角色脚底与道路错位、走到边界直接掉落死亡，导致游戏不像一个完成度 Demo。

新的目标不是继续无差别生成图片，而是把所有关键房间按“可试玩 Demo 场景美术装配”重做一轮：背景、道路、碰撞、镜头、交互物、前景遮挡、HUD 安全区和路线可读性必须同时成立。

## 2026-07-02 Strict Art Kit Addendum

本轮新增 `docs/assets/environment-art-kit-spec.md` 作为场景美术 Kit 冻结入口，并加严 `scripts/dev/capture_demo_art_composition_review.gd`：可见 `visual_preview_only`、`graybox`、无纹理 Polygon 地形、背景覆盖不足和 HUD 大面积贴图都会阻止完成签核。

初始严格审计输出：

- 覆盖房间：`39`
- 结果：`P0=0 / P1=61 / P2=0`
- 主要问题：
  - `visible_untextured_polygon_terrain`：`39`
  - `visible_preview_only_binding`：`9`
  - `visible_graybox_binding`：`8`
  - `background_coverage_too_low`：`5`
- 报告：`tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/demo_art_composition_review.md`

2026-07-02 第一轮修复输出：

- 覆盖房间：`39`
- 结果：`P0=0 / P1=0 / P2=0`
- 已处理：
  - `background_coverage_too_low`：`5 -> 0`
  - `visible_preview_only_binding`：`9 -> 0`
  - `visible_graybox_binding`：`8 -> 0`
  - `visible_untextured_polygon_terrain`：`39 -> 0`
  - `visible_trigger_zone_placeholder`：`45 -> 0`
  - `visible_prop_placeholder_polygon`：`8 -> 0`
- 运行截图：`tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/screenshots/`
- Contact sheet：`tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/dac03_contact_sheet.png`
- 说明：本轮使用连续暗石 underlay 和现有场景素材完成 Demo 级结构修正；正式透明背景规则网格 TileSet 仍作为后续 image_gen / art polish 候选，不把本轮 fallback 说成最终商业清稿。

后续执行顺序调整为：

1. 先修 `background_coverage_too_low` 的 5 个房间，避免画面底层断裂。
2. 再处理 `visual_preview_only` / `graybox` 可见节点，不能继续用 source preview 或灰盒说明签核。
3. 全房间统一替换无纹理 Polygon 地形：优先复用现有 shrine / miasma / seal kit；不够时才进入 DAC-06 image_gen。
4. 处理可见触发区和道具 Polygon 底板，避免运行态出现红 / 绿 / 黄调试色块。
5. 最后再做人工 contact sheet 和输入式 replay 复核，不再用旧结构审计清零口径宣布完成。

## Problem Statement

当前自动化和试玩测试覆盖不足：

- GUT 可以检测流程、门控、攻击、能力和房间状态，但不能判断背景是否铺满视口。
- `asset_id` / resource path 审计可以检测资产是否接入，但不能判断资产摆放是否像地形。
- `visual-only TileMapLayer` 可以降低“无资产绑定”报警，但如果 tile 语义、边缘、连续面和碰撞没有人工 author，会出现散块地面。
- MCP 或截图抽样如果只看少数节点、低缩放 editor screenshot，不能替代运行态人工视觉验收。
- 前一轮 `P2=0` 只能说明旧审计规则清零，不代表发布级或 Demo 级美术配置完成。

因此后续验收必须增加“场景构图 / 地形连续 / 视觉碰撞一致性”门槛。

## Goals

- 让 Alpha Demo 主路线的每个关键房间都像一个统一关卡，而不是素材散放测试场。
- 背景覆盖完整相机视口，并符合山门古刹 / 瘴泽妖域 / 封印禁地的东方奇幻方向。
- 道路、平台和墙面形成连续可读的地形轮廓，角色脚底与可站区域对齐。
- 视觉地形和实际碰撞保持一致；玩家不会被图片误导，也不会看起来悬空。
- 交互物、敌人、危险、出口和奖励在画面上有层级，不被背景或 HUD 遮挡。
- 建立可复跑的人工式 QA 截图 / 运行态检查流程，用于发现资产配置合理性问题。

## Non-Goals

- 不新增 Stage17 玩法。
- 不重写玩家控制、攻击系统、Boss AI 或房间跳转系统。
- 不一次性追求商业发布级全部清稿。
- 不把当前 image_gen 候选直接声明为最终美术。
- 不把 visual-only TileMap 误当作正式 terrain / collision 完成。

## Success Criteria

每个纳入本轮的关键房间必须满足：

- **背景覆盖**：在 `640x360` 基准视口和默认 debug 窗口下，背景不能只覆盖局部矩形；边缘不得出现大块纯色空洞，除非该空洞是刻意的 playable foreground。
- **道路连续**：主路线地面必须形成连续可站轮廓；不得用零散 tile 片段替代完整道路。
- **脚底贴合**：角色站立时脚底应落在可见地面上，不能明显悬空或陷入贴图。
- **碰撞一致**：可见地面、平台和障碍与 StaticBody2D / TileMap collision 的边界一致；视觉装饰不得暗示错误可站区域。
- **路线完整**：主路线末端必须有明确出口、墙体、平台或过渡，不允许玩家在视觉正常前进时直接掉入无意义死亡。
- **关卡可读**：主目标、危险、出口、能力门控和支路入口在截图中能被识别。
- **HUD 安全**：教程 / 状态 UI 不遮挡核心跳跃、攻击、Boss 预警或出口。
- **风格统一**：同一房间内背景、地面、props、VFX 和 UI 不混合现代科幻 / 生化实验室语义。

## Room Scope

第一轮只处理 Alpha Demo 主路线和用户已指出问题的高风险房间：

- `tutorial_room`
- Stage13 miasma marsh 主线、checkpoint、gate、branch、return、goal 房间
- Stage14 shrine、gate、backtrack hub、loop return 房间
- Stage15 pressure、gauntlet、challenge、boss、completion 房间
- Stage16 seal release、relay、purge、backtrack confirmation、end 房间

第二轮再扩到可选支路和非主线房间。

## Visual Layer Contract

每个房间统一使用以下层级，不再把所有图堆在一个层：

1. `BackdropBase`：纯色兜底，只作为色调底，不承担最终美术。
2. `BackgroundArt`：覆盖相机视口的区域背景或视差背景，不能只有画面中间一块。
3. `TerrainUnderlay`：连续地面 / 平台基底，必须贴合碰撞，是主路线可站区域的读形基础。
4. `TerrainTilemapDecor`：TileMap 装饰层，用于边缘、裂纹、草、石块和材质变化；不能单独承担连续地面，除非 TileSet 已完成正式 terrain author。
5. `GameplayProps`：封印门、符桩、checkpoint、能力神龛、Boss 机关等可交互物。
6. `HazardVisuals`：瘴气、水池、腐化雾等危险视觉，必须与 Area2D author 分开但位置一致。
7. `ForegroundDecor`：前景草、雾、枝条，只能轻遮挡，不得遮住玩家脚底、敌人和出口。
8. `HUD`：固定安全区 UI，必须经过低分辨率截图复核。

## Asset Configuration Rules

- 背景图使用 `region / scale / positioning` 按房间相机覆盖，而不是随手放一张原图。
- 地面视觉优先用连续 underlay 保底，再叠 tile decor；只有正式 TileMap terrain 可读后才隐藏 underlay。
- TileMap cell 必须按规则网格连续填充主道路，不允许只摆几块样片。
- 所有平台必须有起点、终点、边缘和厚度；低台阶如果不能提供跳跃、遮挡、门控或路线语义，应删除或改成装饰。
- 所有无意义死亡边界必须改为墙、落点、过渡区或明确危险坑。
- 背景不能含强烈“可站平台”轮廓，以免玩家误读。
- props 不得覆盖 collision shape 的可读边缘。
- 角色、敌人、危险和出口的对比度优先高于背景细节。

## Execution Passes

### DAC-00 - 复核并冻结新验收口径

输出：本计划、房间验收表模板、截图命名规则。

任务：

- 把旧 `P2=0` 结论修正为“结构审计清零，不代表 Demo 场景美术配置完成”。
- 为每个关键房间增加 `background_coverage`、`terrain_continuity`、`collision_visual_alignment`、`route_end_safety`、`hud_occlusion` 五类评分。

### DAC-01 - 运行态截图全量审计

输出：`tests/artifacts/local/demo-art-composition/dac01_audit/`。

任务：

- 用 Godot MCP Pro 或 dev capture 脚本逐房截图。
- 每房保存默认视口、玩家站立点、主路线中点、出口 / 失败边界四类图。
- 标注 `P0`、`P1`、`P2`：
  - `P0`：无法通过、无意义死亡、视觉路线错误导致必死。
  - `P1`：可通过但地面 / 背景 / 碰撞明显错位。
  - `P2`：可通过但仍像灰盒或美术不统一。

### DAC-02 - 背景覆盖与相机框架修正

目标：先让每个房间有完整画面底。

任务：

- 对 Stage13 / Stage14 / Stage15 / Stage16 背景进行统一 scale、position 和 alpha 配置。
- 没有合适背景的房间先使用同区域背景延展，不立刻生图。
- 若同区域背景无法覆盖，才进入 DAC-06 image_gen。

退出条件：

- 主路线房间截图不再出现背景只覆盖一小块的问题。
- 背景不遮挡玩家、出口和 Boss 预警。

### DAC-03 - 连续道路与平台读形修正

目标：修复“散块 tile 堆放”和角色悬空。

任务：

- 恢复或新增 `TerrainUnderlay` 连续地形基底，并对齐现有碰撞。
- `TileMapLayer` 改为 decor overlay，直到正式 terrain author 完成。
- 对所有主路线平台补足左 / 中 / 右边缘和厚度。
- 删除无意义低台阶，或改成能从下方通过 / 能跳上去 / 有明确门控意义的平台。

退出条件：

- 玩家脚底视觉贴合地面。
- 主路线道路在截图中连续。
- 玩家走到主路线末尾不会因为视觉边界缺失直接掉死。

### DAC-04 - 碰撞、hazard、出口和死亡边界对齐

目标：让视觉和 gameplay 一致。

任务：

- 检查每个房间 floor / platform / wall / hazard Area。
- 可见危险必须有对应 Area 或明确标注为纯装饰。
- 可见安全道路不能没有碰撞。
- 房间末端必须有 transition、墙体、落点或明确危险坑提示。

退出条件：

- P0 无意义死亡和路线断裂清零。
- P1 视觉碰撞错位清零或有明确 backlog。

### DAC-05 - Props、敌人、VFX 和 HUD 层级收敛

目标：让 Demo 从“地图能站”推进到“内容像完成版本”。

任务：

- 封印门、训练靶、Boss、checkpoint、能力门控使用正式 visual 层，不再露出红色 / 棕色多边形主视觉。
- 攻击残留、hit spark、dash trail、Boss warning 等 VFX 必须有生命周期验证，不能击杀后永久停留。
- HUD 面板在低分辨率下不压住路线、Boss 和教学目标。

退出条件：

- 主线截图中不再出现明显测试块主视觉。
- VFX 不残留。
- HUD 不挡主路线。

### DAC-06 - 缺口资产生成或外部资产评估

触发条件：

- 现有背景无法铺满视口且拉伸后不可接受。
- 现有 TileSet 无法形成连续地形边缘。
- 现有 props 缺少关键交互状态。

生成规则：

- 使用 image_gen 生成；不得使用绿色、白色、棋盘格背景作为最终透明资产。
- 背景：16:9、无 UI、无文字、前景 playable 区域留干净。
- TileSet：规则网格、32x32 或 64x64、边缘 / 内角 / 外角 / 平台厚度完整。
- Props：透明背景 PNG、单体居中、关闭 / 可触发 / 完成状态可区分。

目标路径：

```text
assets/source/ai_generated/demo_art_composition/dac06/
assets/art/backgrounds/demo_art_composition/
assets/art/tilesets/demo_art_composition/
assets/art/props/demo_art_composition/
assets/art/vfx/demo_art_composition/
```

### DAC-07 - 全流程人工式 QA 与收口

验证组合：

```powershell
godot --headless --path . --import
godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/stage5 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage15 -gdir=res://tests/stage16
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_demo_art_composition_review.gd
git diff --check
```

MCP / 人工路线：

- 主菜单开始。
- 教程移动、跳跃、攻击、出口。
- Stage13 瘴泽入口到目标房。
- Stage14 Air Dash 获取和 gate。
- Stage15 Boss 房、失败重试和 completion。
- Stage16 终局封印链和完成反馈。

退出条件：

- 主路线 `P0=0`。
- 关键房间 `P1=0`。
- 剩余 `P2` 仅为可接受的细节 polish，不再是背景缺块、道路断裂、悬空、散块堆放。
- 本地截图和报告可复查。
- 进度文档更新，不再用旧 P2 清零口径描述为“整体美术完成”。

## Required Tooling Improvements

新增或扩展一个 dev 审计脚本：

```text
scripts/dev/capture_demo_art_composition_review.gd
```

建议输出字段：

```text
room_path
room_id
camera_rect
background_nodes
background_coverage_estimate
terrain_visual_nodes
floor_collision_shapes
player_feet_sample
route_end_safety
hazard_visual_alignment
hud_occlusion_notes
priority
notes
```

自动脚本不做最终审美判断，只负责收集一致证据；最终 P0 / P1 / P2 仍需人工看截图确认。

## Immediate Fix Order

1. 先修用户截图对应的 Stage13 entry：背景铺满、连续地面 underlay、tile decor 降级为装饰、末端安全边界。
2. 同步修 Tutorial / Stage14 gate / Stage15 boss / Stage16 end 五个 P3 样板房，撤销“散块 tile 直接承担主地形”的错误口径。
3. 跑 DAC-01 全量截图审计，把所有同类房间列入 P0 / P1 / P2。
4. 按 P0、P1、P2 顺序批量处理，不再按“是否有 asset_id”排序。
5. 只有当现有背景 / tile / prop 不能满足连续地形和完整画面时，进入 DAC-06 image_gen。

## Execution Status - 2026-06-30

- DAC-00：完成。旧 `P2=0` 口径已修正为结构审计通过，不再视为 Demo 级资产配置完成。
- DAC-01：完成第一轮主路线审计。新增 `scripts/dev/capture_demo_art_composition_review.gd`，覆盖 `20` 个 Alpha Demo 主路线关键房间。
- DAC-02：完成第一轮主路线修复。Stage13 / Stage14 / Stage15 / Stage16 主路线房间均有可见背景图；用户截图对应 Stage13 entry 已改为相机覆盖背景。
- DAC-03：完成第一轮样板修复。Tutorial、Stage13 entry、Stage14 shrine / gate、Stage15 boss、Stage16 end 恢复连续地形 underlay，TileMap 改为 decor overlay。
- DAC-04：完成第一轮路线末端读值修正。DAC-01 报告中主路线出口 / 目标标记为 `20/20` 可见。
- DAC-05：完成第一轮结构检查和测试块主视觉清理。Stage13 gate、Stage15 mixed gauntlet、Stage16 threshold / relay / backtrack / purge 中的可见红色 `BarrierVisual` 已替换为现有封印门图；DAC 审计脚本已增加可见 `BarrierVisual` 检测。当前 DAC-01 报告为 `P0=0 / P1=0 / P2=0`。
- DAC-06：未触发。本轮复用现有背景、TileSet 和 props，不新增 image_gen。
- DAC-07：部分完成。Godot import、DAC 截图审计、GUT 和 `git diff --check` 已通过；Godot MCP Pro 工具入口已暴露但编辑器桥接未连接，本轮未取得 MCP 截图证据。

## Execution Status - DAC-02 Branch Art Signoff - 2026-06-30

- 支路扩展审计：完成。`capture_demo_art_composition_review.gd` 覆盖从 `20` 房扩展到 `27` 个主线 / 支路关键房间，输出目录为 `tests/artifacts/local/demo-art-composition/dac02_branch_art_signoff/`。
- 发布级签核口径：完成第一轮。审计表新增 `Decor` 与 `Signoff` 字段，把“纯色地形 underlay 缺少地表边缘 / 裂纹 / 草石 / 材质过渡”标为 `P2:flat_terrain_without_material_transition`。
- P1 修复：完成。Stage13 pressure / crossfire / challenge branch 补瘴泽背景、TileSheet 和 TileMap decor；Stage15 challenge branch 补 Boss 区背景，红色 `BarrierVisual` 改为隐藏 fallback，并新增封印门图。
- P2 修复：完成。Stage13 caster 补瘴泽 TileSheet 与 TileMap decor；Stage15 pressure / gauntlet / challenge branch、Stage16 relay 补 `material_texture_atlas_ai01` 地表材质过渡层；审计脚本把 `MaterialTexturePreviewArt` 纳入 Decor 统计。
- 当前结果：DAC-02 报告为 `27` 房间、`P0=0 / P1=0 / P2=0`，`27/27` 房间进入 `manual_review_candidate`。
- 人工目检：`dac02_contact_sheet.png` 未发现明显背景空洞、红色占位门、地表装饰缺口、材质带遮挡玩家 / 敌人 / 出口 / HUD 的问题。
- 验证：Godot import 通过；Stage13 / Stage15 / Stage16 GUT `43/43` tests、`698` asserts 通过；`git diff --check` 通过但仍有既有 CRLF warning。

## Execution Status - Strict Art Kit Closure - 2026-07-02

- DAC-00 / DAC-01：完成复核修正。全内容主线可玩证据仍有效，但旧 `P2=0`、旧 DAC 结构审计和少量 editor screenshot 不再作为场景美术完成依据；strict gate 改为同时检查背景覆盖、visible preview-only、visible graybox、无纹理 Polygon 地形、可见触发区色块、prop 底板、HUD 大图遮挡和正式 TileMap 装饰层。
- DAC-02 / DAC-03：完成第二轮地形修复。使用内置 `image_gen` 生成 `8x6` 规则网格地形 kit 源图，先以 `#ff00ff` chroma key 约束生成，再转透明 PNG 并规范化为 `64x64` Godot TileSet sheet；最终运行资源为 `assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.png`，TileSet 为 `assets/art/tilesets/editor_tilesets/dac_formal_terrain_tileset_ai01_64.tileset.tres`。
- DAC-03 / DAC-04：完成正式 TileMap 装饰层接入。`scripts/dev/apply_dac_formal_terrain_tilemaps.gd` 为 `39` 个房间补齐 / 更新 `FormalTerrainTilemapDecor`，共写入 `607` 个视觉 tile；该层禁用碰撞，实际碰撞仍由现有 StaticBody2D / CollisionShape2D 承担，避免视觉修复改变玩法数值。
- DAC-05：完成遮挡和占位主视觉收敛。HUD 巨大图标遮挡已通过 `TextureRect.expand_mode` 修复；触发区、prop Polygon 底板和 preview / graybox 可见节点已从主视觉中移除或弱化；`45` 个触发区提示压到 `0.025` alpha；瘴气投射敌压力圈和瘴气 hazard warning 已改为低 alpha aura / 正式 warning SVG，并纳入 strict DAC P1 检查。
- DAC-06：已触发并完成当前 Demo 级地形 kit。源图保存在 `assets/source/ai_generated/dac_formal_terrain_kit/dac_formal_terrain_tileset_chromakey_ai01.png`；透明版、规范化版、regions 和 semantics sidecar 均已落入 `assets/art/tilesets/`。
- DAC-07：完成当前 Demo 级收口。Godot import 通过；DAC-03 strict gate 覆盖 `39` 房间且为 `P0=0 / P1=0 / P2=0`，并确认没有 `visible_tilemap_count=0` 的房间；full-flow 生产流程证据为 `P0=0 / P1=0 / P2=0`；输入式 replay wrapper 从主菜单开始跑到 Stage16 完成，`rooms_seen=35` 且 `P0=0 / P1=0 / P2=0`；Stage5、Stage9-16、Stage12 GUT `97/97` tests、`1476` asserts 通过；`git diff --check` 通过但仍有既有 CRLF warning。
- 边界：当前达到 Alpha Demo 级资产配置验收，不等同商业最终清稿、手工 autotile、完整 parallax split、地貌美术总监签核或真人录屏。Codex MCP 直连工具侧仍出现 editor 未连接 / CLI 指向其它项目的问题；本轮用项目桥接文件、生产入口脚本、OpenGL 截图、full-flow 证据和输入式 replay wrapper 作为可复查证据。

## Risks

- 当前部分 TileSet 是自动裁切候选，不一定适合直接做正式 terrain。
- 背景图若强行拉伸可能带来模糊或透视误导，需要必要时重生成。
- 若继续保留 StaticBody2D 作为兜底碰撞，必须让可见地面覆盖它，否则仍会出现脚底悬空。
- 正式 image_gen TileSet 已能承担当前 Demo 级主视觉补强，但仍是自动生成规则网格，不是商业级手工 autotile；后续仍可继续做地表边缘精修、平台材质过渡、区域地貌统一和 parallax 分层清稿。
- 全房间处理会触及大量 `.tscn`，需要分批提交和截图验证，避免一次性改坏主线。
