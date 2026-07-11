# Nano Hunter Timeline

本文件只记录项目里程碑级事件。每日细节、命令输出、MCP 复核过程、分支操作原因和误判修正过程保存在 `docs/progress/logs/YYYY-MM-DD.md`。每条里程碑默认包含范围、结果、关键验证、详情日志；重要阶段收口或工具链修复可补提交 hash 与遗留风险。

## 2026-07-11

- **AGENTS repository contract slimming**：把根代理说明从阶段手册和工具知识库收敛为稳定的仓库执行契约。
  结果：`AGENTS.md` 从 `530` 行缩减为 `108` 行；保留北极星、中文协作、任务分级、项目接口、文档门禁、验证和 Git 安全原则，移除动态阶段、端口、Batch、插件候选、worktree 操作手册和单次故障经验。
  关键验证或结论：八段式结构成立；`9` 个专题引用路径全部存在，陈旧词和常见乱码扫描均为 `0`，`git diff --check` 退出码为 `0`；本轮不修改 Stage17 运行时代码。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；设计：`spec-design/2026-07-11-agents-md-slimming-design.md`；执行清单：`docs/implementation-plans/2026-07-11-agents-md-slimming.md`。

- **Stage17 preflight and Formal Demo rollback point**：在动作运行态实现前收口当前大规模未提交工作树，并冻结可回退基线。
  结果：Formal Demo 39 房重排、资产接入、运行态脚本与文档范围形成同一份本地回退提交；Stage17 专用分支从该验证基线分叉。修正 TileSet 包审计仍按旧资源数计数、运行态资产表仍宣称 4 个已替换独立资产直接引用的陈旧口径，没有把旧资产重新接回场景。
  关键验证或结论：全量 GUT `31` scripts、`219/219` tests、`6105` asserts；Godot import 通过；39 房 OpenGL 运行态构图复核 `P0=0 / P1=0 / P2=0`；动作候选 `15/15 active ready`；最终美术审计 `5/5 FP batches, 2/2 final gates`；资产包、source safety、provenance、background alpha 和 runtime map 严格审计全部通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；分支：`codex/stage-17-animation-runtime-stabilization`；边界：未合并 `main`、未推送远端，Stage17 动作缺陷尚未进入实现。

- **Stage17 animation runtime stabilization planning**：把动作审计结论升级为正式阶段边界和可执行修复计划。
  结果：确定采用“保留玩法时长、按状态映射关键帧”的方案；Luna 固定 Model Lock v1，Jump 拆 start / rise / fall / land；普通敌人在 BaseEnemy 共享入口启动播放并补最小死亡动作；Boss 拆分 recovery 与 guard-break staggered。最小 `2 元素 + 2 姿态 + 2 步序列` 明确留给下一独立阶段。
  关键验证或结论：计划直接对应现有代码根因——玩家状态已有 startup / active / recovery、普通敌人共同经过 `BaseEnemy`、Boss 当前 `stagger_duration` 未独立使用；本轮只完成设计和计划，不修改运行代码。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；设计：`spec-design/2026-07-11-stage-17-animation-runtime-stabilization-design.md`；正式计划：`plan/2026-07-11-stage-17-animation-runtime-stabilization.md`；执行清单：`docs/implementation-plans/2026-07-11-stage-17-animation-runtime-stabilization.md`；前置：先收口当前脏工作树并建立 Stage17 分支。

- **Animation / room content / North Star implementation audit**：纠正“资源已生成或几何审计通过即代表动作和玩法完成”的口径。
  结果：确认 Luna 跨动作比例与状态时序未锁定；四类普通敌人运行态不播放 cycle；Seal Guardian attack / VFX 被状态截断且 staggered 隐藏；完成 39 房敌人、机关、奖励和门控目录；北极星完整实现估算约 `25-30%`，元素 / 姿态 / 序列核心约 `0-10%`。
  关键验证或结论：runtime probe 记录四类普通敌人 `frame 0 -> 0 / is_playing=false`、Boss `staggered / visible=false`；runtime candidate geometry audit 为 Luna `7/7`、综合候选 `15/15`，证明问题位于跨动作与运行绑定层。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；动作审计：`docs/assets/2026-07-11-character-enemy-animation-runtime-audit.md`；房间目录：`spec-design/2026-07-11-alpha-demo-room-content-catalog.md`；北极星审计：`spec-design/2026-07-11-north-star-implementation-audit.md`。

- **Formal Demo Map Redesign 39-room closure**：完成 Stage16 Batch 9，并收口当前全部 39 个可运行房间的正式 Demo 排版。
  结果：三类样板与 Batch 1-9 全部完成；Stage16 五房形成释放、中继、回溯确认、净化和终局大厅；其余 38 房使用正式 TileMap collision / visual surface，`test_room` 保留精确 shape 机制沙盒契约。
  关键验证或结论：全量 GUT `31` scripts、`219/219` tests、`6105` asserts；39 房 Windows/OpenGL 截图审计 `P0=0 / P1=0 / P2=0`；Stage16 自动主线到达 Alpha Demo End；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；正式计划：`plan/2026-07-10-formal-demo-map-redesign.md`；Batch9：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-09-stage16.md`；遗留：尚未合并 `main`，仍需真人连续试玩和最终美术签核。

- **Formal Demo map Batch 8 Stage15 remaining rooms**：完成 Pressure、Challenge、Boss、Completion，Stage15 战斗高潮链收口。
  结果：双敌前置清场、危险挑战支路、宽 Boss arena 和封印完成大厅成立；正式进度推进到 `34/39` 房。
  关键验证或结论：Batch8 `5/5` / `193` asserts；Stage15/16 + formal remap `45/45` / `1106` asserts；六图运行态 `ok=true`；Boss 到 Completion、Completion 到 Stage16 真实切房；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-08-stage15-remaining.md`。

- **Formal Demo map Batch 7 Stage14 remaining rooms**：完成 Shrine、Backtrack Hub、Loop Return，Stage14 能力与回溯链收口。
  结果：能力获得、Air Dash Gate、三收益回溯和进入 Stage15 的上层目标形成完整链路；正式进度推进到 `30/39` 房。
  关键验证或结论：Batch7 `4/4` / `137` asserts；Stage14-16 + formal remap `61/61` / `1504` asserts；五图运行态 `ok=true`；Loop Goal 高度误配经运行图拒绝后修正；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-07-stage14-remaining.md`。

- **Formal Demo map Batch 6 Stage13 branches and goal**：完成瘴泽区域剩余五房，Stage13 正式重排收口。
  结果：Hub 三路高低分叉、资源支路两级上行、挑战支路清敌门、Return 汇流降压和 Goal 上层祭器成立；正式进度推进到 `27/39` 房。
  关键验证或结论：Batch6 `5/5` / `214` asserts；Stage13/manual/Stage14/Stage16/formal remap `58/58` / `1464` asserts；六图运行态 `ok=true`；Goal 真实切入 Stage14；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-06-stage13-branches-goal.md`。

- **Formal Demo map Batch 5 Stage13 mid chain**：完成 Gate、Crossfire、Checkpoint、Pressure 四房正式重排。
  结果：四房分别形成符印门控、三层交叉火力、恢复缓冲和瘴气绕行职责；补齐双向连接、安全 spawn 和正式 TileMap collision / surface；Gate 的不可见 SealNode 补现有符印桩运行资产。
  关键验证或结论：Batch5 `4/4` / `197` asserts；Stage13/manual/Stage14/Stage16/formal remap `58/58` / `1479` asserts；七图运行态 `ok=true`；Checkpoint 背景空白边经拒绝和修正后通过；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-05-stage13-mid.md`。

- **Formal Demo map Batch 4 Stage11 end and Stage13 entry chain**：把 Demo 终点与瘴泽入口前三房推进为正式房间构图。
  结果：Stage11 三选择大厅、Stage13 checkpoint 揭示、三层 Caster 清敌房和 hazard bypass 房成立；Caster 补正式门，Miasma 警示 VFX 达到可读范围。
  关键验证或结论：Batch4 与相关 Stage11-16 回归共 `67/67` tests、`1698` asserts，六图运行态报告 `ok=true`，Godot import 通过；地面覆盖与 hazard 测试已改读正式运行层。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-04-stage11-stage13-entry.md`；遗留：下一批继续 Stage13 中段 4 房。

- **Formal Demo map Batch 3 Stage10 vertical route set**：把三间同规格单层房重排为主线空中战、奖励支路和全清挑战房。
  结果：Aerial / Branch / Challenge 分别采用 `24x9 / 18x8 / 26x10`；支路 return spawn、反向连接和全清门规则成立，奖励与恢复点位于可达上行路线。
  关键验证或结论：Batch3 与 Stage10/11/12/16 共 `49/49` tests、`1066` asserts，五图运行态报告 `ok=true`，Godot import 通过；支路初版 `16x8` 因运行态露出大块空底色被拒绝并扩大为 `18x8`。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-03-stage10.md`；遗留：下一批处理 Stage11 终点与 Stage13 入口链。

- **Formal Demo map Batch 2 Stage9 five-room zone**：把五间同规格单层房重排为第一个具有连续节拍差异的小区域。
  结果：Entry / Combat / Charger / Switch / Final 分别采用 `18x6 / 20x8 / 22x8 / 20x9 / 24x9`，形成区域揭示、双层首战、冲锋长廊、两级机关和上下层混合终点；双向连接、安全 spawn、checkpoint 表现和每房相机边界已补齐。
  关键验证或结论：Batch2 与 Stage9-16 相关回归共 `94/94` tests、`2362` asserts，七图运行态报告 `ok=true`，Godot import 通过；`miasma_marsh_tileset_ai01` 继续保持 source-only，不进入正式道路。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-02-stage9.md`；遗留：下一批进入 Stage10 三房。

- **Formal Demo map Batch 1 first-chain promotion**：把机制沙盒、首战房和目标房按已验收样板规则重新接入。
  结果：`test_room` 的精确 shape bounds 获得可读顶沿 / cap；`combat_trial_room` 成为 `18x6` 单敌锁门房；`goal_trial_room` 成为 `20x8` 下层战斗 + 上层目标房；背景硬边、旧随机 tile 和错误 spawn 坐标已修正。
  关键验证或结论：Batch 1、Stage1/3/4/6/7、formal remap 共 `47/47` tests 通过，运行态五图报告 `ok=true`，Godot import 通过；首战短链的碰撞、重试、门控、目标和返回契约未回归。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；实施计划：`docs/implementation-plans/2026-07-11-formal-demo-map-redesign-batch-01.md`；遗留：下一批进入 Stage9 五房区域级推广。

- **Stage15 mixed gauntlet formal combat-room sample**：把单层三敌横排房推进为第三类正式房间样板。
  结果：房间扩为 `26x9`；Basic Melee、Ground Charger、Aerial Sentinel 分别占据近战区、冲锋通道和空中层；新增上层规避台与空中接敌平台，挑战支路移到左上可选路径，清场门前后保持连续地面；单张 Boss arena 背景覆盖完整房间。
  关键验证或结论：gauntlet template GUT `5/5` tests / `309` asserts；Stage15 GUT `17/17` / `402` asserts；Godot import 通过；四视角运行态报告 `ok=true`，支路不误触、冲锋高度带、空中层、三敌全清开门和门前安全区均通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；遗留：区域专用平台吊挂 / 支撑视觉仍待后续清稿；三类样板完成后进入首批 `3-5` 房推广。

- **Stage14 Air Dash gate formal ability-room sample**：把旧门房从碰撞跟随素材试铺推进为第二类正式房间样板。
  结果：房间扩为 `24x9` 显式蓝图，包含下层失败回落、两段起跳、`192px` Air Dash 缺口、右侧连续崖台和门前后安全区；随机视觉 tile 清空，单张背景覆盖完整房间，崖体采用低对比石质 underlay；入口 spawn 避开左出口，双向连接和能力门流程字段由生成器与测试共同守护。
  关键验证或结论：gate template GUT `5/5` tests / `555` asserts；formal remap GUT `8/8` / `189` asserts；Stage14 GUT `16/16` / `389` asserts；Godot import 通过；四状态运行态报告 `ok=true`，普通跳失败回落、Air Dash 落地、脚底对齐、锁门 / 开门和门前后安全区均通过。
  详情日志链接：`docs/progress/logs/2026-07-11.md`；遗留：现有 underlay 满足样板可读性但不等于最终区域 cliff-side 清稿；下一样板为 Stage15 mixed gauntlet。

## 2026-07-10

- **Tutorial room formal composition and pixel-grounding sample**：把教学房从“网格正确但仍像素材试排”推进到首个房间级正式构图样板。
  结果：保留 `24x6` 四段教学节拍；重复背景收敛为单张完整房间覆盖；路面随机石物删除，入口灯弱化，跳跃平台自身承担地标，Air Dash 神龛安装在实体低顶上方；共享训练目标从误标链门切片改为人工复核试炼碑。通过 Atlas alpha bounds 和运行态坐标将 `GroundSurfaceVisual` 上移 `7px`，统一 Luna、入口灯和训练目标的 `y=160` 落地基线。
  关键验证或结论：tutorial template GUT `6/6` tests / `502` asserts；Stage3 GUT `5/5` / `18` asserts；Stage5 GUT `9/9` / `100` asserts；Godot import 通过；四点运行态截图复核 `ok=true`，且 `background_coverage_ok=true`、`landmark_layout_ok=true`、`start_ground_alignment_ok=true`、`training_target_ok=true`。目检确认背景无接缝 / 露空，Luna 和试炼碑脚底与可见地表一致。
  详情日志链接：`docs/progress/logs/2026-07-10.md`；遗留：当前仍是碰撞层与可见表面层分离的过渡结构，三类样板验证后再决定正式 TileSet 单层整合；下一样板为 Stage14 Air Dash gate。

- **Tutorial room thin platform visual replacement**：把教学房两段空中平台从厚石梁视觉换成薄平台上沿。
  结果：新增 `tutorial_thin_platform_visual_ai01`，从既有 `shrine_trial_tileset_ai01` 平台件裁出 24px 高薄上沿；`tutorial_room.tscn` 新增 / 刷新 `ThinPlatformSurfaceVisual`，只覆盖跳台与 dash 门低顶；`GroundSurfaceVisual` 只保留主路地面；碰撞仍由 `TerrainCollisionVisual` / `PlatformCollisionVisual` 承担。
  关键验证或结论：tutorial template GUT `3/3` tests / `452` asserts；Stage5 GUT `9/9` tests / `100` asserts；运行态截图复核 `ok=true`，且 `thin_platform_surface_visible=true`、`surface_visual_ok=true`、`platform_floor_ok=true`、`gate_blocks_without_dash=true`；Godot import 和 `git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-07-10.md`；遗留：本轮未使用 image gen 重生整套平台资产，先采用同源裁薄方案。

## 2026-07-09

- **Tutorial room 64px grid blueprint demo layout**：把真正第一关从碰撞块试铺推进为 64px 网格驱动的正式 demo 样板房。
  结果：`tutorial_room.tscn` 由 `apply_formal_terrain_kit_tutorial_trial.gd` 按固定蓝图铺设：主路 `x=-7..15, y=2` 连续 23 格，跳台收紧为 `x=-4..-3, y=1` 连续 2 格，dash 门低顶 `x=2..3, y=1`，出口安全落点 `x=10..14, y=2`；新增 `GroundSurfaceVisual` 复用 `shrine_trial_tileset_ai01` 的 left / center / right 地面件做 visual-only 连续主路视觉，带格线的 `GroundUnderlayVisual` 已隐藏退役；本房 `DoorVisual` / `BackgroundVisual` / `DecorVisual` / `ForegroundVisual` 保持空 TileMap，避免孤立门柱、重复墙件、地面下碎石和漂浮小台座误读；保留 `ExitBarrier` / `ExitZone` / `TutorialDummy` 独立逻辑碰撞。
  关键验证或结论：tutorial template GUT `3/3` tests / `432` asserts；Stage5 GUT `9/9` tests / `100` asserts；运行态截图复核 `ok=true`，且 `grid_blueprint_ok=true`、`surface_visual_ok=true`、`ground_underlay_retired=true`、`start_floor_ok=true`、`platform_floor_ok=true`、`gate_blocks_without_dash=true`；Godot import 和 `git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-07-09.md`；遗留：本轮只把 `tutorial_room` 做成样板房，不全图推广，不新建通用关卡生成器。

- **Stage14 gate terrain template copy validation**：把 tutorial_room 已验证的房间级 Terrain 模板复制到 Stage14 Air Dash gate 房间。
  结果：`stage14_air_dash_gate_room.tscn` 新增 / 刷新 `TerrainCollisionVisual`、`DoorVisual`、`BackgroundVisual`、`DecorVisual`、`ForegroundVisual`；`LeftWall` / `Floor` 的真实地形碰撞迁移到 `TerrainCollisionVisual`，旧试铺层隐藏并显式禁用碰撞，门框 / 背景 / 装饰 / 前景保持 visual-only；`GateBarrier` / `ExitZone` / `LeftExitZone` / `AirDashGateSensor` 保持独立逻辑节点。
  关键验证或结论：Stage14 gate template GUT `3/3` tests / `200` asserts；Stage14 GUT `16/16` tests / `389` asserts；运行态截图复核 `ok=true`，确认 layer authority、visual-only layers、旧碰撞禁用、出生点落地和 Air Dash 解锁过门均通过。
  详情日志链接：`docs/progress/logs/2026-07-09.md`；遗留：本轮不全图推广，不处理 Stage14 其它房间，也不处理房间长度 / 层级扩展。

- **Tutorial room terrain template rebuild**：把真正第一关从视觉试铺升级为房间级 Terrain 模板。
  结果：`tutorial_room.tscn` 新增 / 更新 `TerrainCollisionVisual`、`PlatformCollisionVisual`、`DoorVisual`、`BackgroundVisual`、`DecorVisual`、`ForegroundVisual` 六层；地形和薄平台由 `formal_terrain_kit_ai01` TileSet collision 承担权威碰撞，门、背景、装饰、前景保持 visual-only；旧地形 StaticBody2D 碰撞禁用但保留 authoring bounds，`ExitBarrier` / `ExitZone` / `TutorialDummy` 保持独立节点。同步冻结房间元素清单和 TileSet 语义清洗表。
  关键验证或结论：formal terrain kit GUT `3/3` tests / `183` asserts；tutorial template GUT `3/3` tests / `300` asserts；Stage5 GUT `9/9` tests / `100` asserts；运行态截图复核 `ok=true`；Godot import 通过。排障结论：隐藏 TileMapLayer 仍会参与碰撞，`ShrineTrialTilesetPreview` 必须显式 `collision_enabled=false`，窄落点至少两格才能避免 dash 门前空气墙。
  详情日志链接：`docs/progress/logs/2026-07-09.md`；遗留：本轮不全图推广，不处理 Stage14 gate，不处理房间长度 / 层级扩展；这些进入后续独立 pass。

## 2026-07-05

- **DemoShell main menu composition correction**：把标题主菜单从中心大弹窗收敛为左侧紧凑导航面板。
  结果：`DemoShell` 主菜单改为按 viewport 动态计算的左侧面板，宽度限制在 `300-420`，按钮高度约 `31`，保留六项入口但不再遮住标题背景主体；不改开始、暂停、详情页、失败提示或完成提示流程。
  关键验证或结论：Stage16 GUT `18/18` tests、`463` asserts；Godot import 通过；`capture_demo_shell_layout_hover_review.gd` 与 `capture_demo_shell_start_review.gd` 均为 `ok=true`；`menu_normal_2048x1152.png` / `menu_hover_2048x1152.png` 目检确认背景成为主视觉，hover 不压扁按钮。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式标题 Logo、完整设置 / 选关系统或主菜单动效完成。

- **Stage14 backtrack reward pedestal runtime replacement**：把 Stage14 回溯 hub 的三个漂浮奖励晶体落到现有 prop atlas 的小型奖励标识上。
  结果：`stage14_backtrack_hub_room.tscn` 的 `BacktrackRewardOne/Two/Three` 均新增 `RewardPedestalArt`，绑定 `shrine_gate_prop_atlas_ai01.reward_marker_idle` AtlasTexture；`RewardArt` 保持为上层奖励晶体；不改奖励计数、收集距离、隐藏逻辑、出口或玩家路线。
  关键验证或结论：Stage14 GUT `16/16` tests、`379` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage14_backtrack_hub.png` 目检确认奖励点不再只是孤立漂浮晶体，且未遮挡 Luna、HUD、地面、平台或出口路线。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式奖励经济、拾取动画、拾取音效、背包 UI 或 Stage14 回溯链路终稿完成。

- **Stage16 purge focus base runtime replacement**：把 Stage16 purge 房的净化确认光点落到现有 prop atlas 的小型符印器物上。
  结果：`stage16_corruption_purge_room.tscn` 的 `CorruptionPurgeNode` 新增 `PurgeFocusBaseArt`，并从远景较弱的 `shrine_gate_prop_atlas_ai01.seal_ring_active` 收敛为 `shrine_gate_prop_atlas_ai01.miasma_ward_purged` AtlasTexture；`TalismanRelayEchoArt` 保持为上层确认 VFX；不改妖瘴危险 Area、净化接近距离、门控、出口或玩家路线。
  关键验证或结论：Stage16 GUT `18/18` tests、`462` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_purge.png` 目检确认净化点有石质机关底座和上层净化光效，且未遮挡 Luna、HUD、地面、门禁或出口路线。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于专用净化激活动画、危险区 VFX 全套清稿、净化音效或 Stage16 终局演出完成。

- **Stage16 relay focus base runtime replacement**：把 Stage16 relay 房的三枚悬浮符印光点落到现有 prop atlas 的小型符印器物上。
  结果：`stage16_talisman_relay_room.tscn` 的 `TalismanRelayA/B/C` 均新增 `RelayFocusBaseArt`，绑定 `shrine_gate_prop_atlas_ai01.seal_ring_idle` AtlasTexture；`RelayArt` 保持为上层符印 VFX；不改 `required_talisman_relay_count`、接近距离、门控、出口或玩家路线。
  关键验证或结论：Stage16 GUT `18/18` tests、`452` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_relay.png` 目检确认 relay 不再只是孤立光点，且未遮挡 Luna、HUD、地面、门禁或出口路线。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于专用 relay 激活动画、三段收集音效、完整终局演出或 Stage16 关卡终稿完成。

- **Stage15 pressure focus prop runtime replacement**：把 Stage15 pressure 房的悬浮封印 VFX 标记落到现有 prop atlas 的场景机关底座上。
  结果：`stage15_seal_pressure_room.tscn` 新增 `PressureFocusArt`，绑定 `shrine_gate_prop_atlas_ai01.seal_pillar_intact` AtlasTexture；`PressureSigilArt` 保持为上层能量 VFX；不改压力逻辑、敌人、出口、碰撞或房间推进。
  关键验证或结论：Stage15 GUT `17/17` tests、`404` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage15_pressure.png` 目检确认压力点不再像悬浮 UI 标记，且未遮挡 Luna、HUD、敌人、路线或出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于专用封印压力动画、机关交互音效、完整危险 VFX sheet、Boss 前压迫演出或 Stage15 关卡终稿完成。

- **Luna runtime render layer correction**：修正玩家运行态身体被正式前景边缘压住、读成嵌入地面的层级问题。
  结果：`scenes/player/player_placeholder.tscn` 的 `PlayerPlaceholder.z_index` 设为 `3`，高于全房间 `FormalForegroundEdgeDecor.z_index=2`；不改碰撞体、动作帧、相机、房间地形或门禁资源。
  关键验证或结论：Stage14 GUT `16/16` tests、`352` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；2K 专项复核 `ok=true`、`camera_zoom=[3.2, 3.2]`；`stage14_gate.png` 与 `stage16_threshold.png` 目检确认 Luna 不再被前景边缘盖脚，当前 `seal_gate_locked` 图集切片为石质封印门。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整角色动作二次清稿、碰撞盒重制、手工 autotile 终稿或门禁新资产重生。

- **Marker-backed trigger visual cleanup batch**：清理已经由正式 marker / GoalDevice 覆盖的目标点和支路入口弱触发区底板。
  结果：隐藏 Stage10 `BranchZone/BranchVisual`、Stage13 branch hub 三块 route visual、Stage13 goal `GoalZone/GoalVisual`、Stage14 loop return `GoalZone/GoalVisual`、Stage15 gauntlet `ChallengeBranchZone/ChallengeVisual`；不改 Area2D 碰撞、支路跳转、目标推进、奖励或敌人逻辑。
  关键验证或结论：Stage10 GUT `11/11` tests、`108` asserts；Stage13 GUT `13/13` tests、`368` asserts；Stage14 GUT `16/16` tests、`351` asserts；Stage15 GUT `17/17` tests、`394` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮只处理已有 marker / GoalDevice 覆盖的目标与支路入口，不处理普通房间边界 `ExitZone`，也不等于小地图、正式选关 UI、奖励经济、目标动画或音效完成。

- **Stage11 endpoint trigger visual cleanup**：把终点房三处低透明触发区底板从运行态画面中清掉，只保留正式 marker 承担重开 / 完成 / 继续读值。
  结果：`stage11_demo_end_room.tscn` 的 `ReplayVisual`、`GoalVisual`、`ContinueVisual` 均设为隐藏；不改 `ReplayZone` / `GoalZone` / `ContinueZone` 碰撞、重开、完成或继续逻辑。
  关键验证或结论：Stage12 GUT `10/10` tests、`243` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage11_end.png` 目检确认三枚 marker 仍可读，弱触发区底板不再显示。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式结算页、入口动画、音效、可选路线 UI 或完整 Demo 终局演出完成。

- **GoalTrial target marker runtime replacement**：把战斗试炼目标区从低透明触发区推进到可见目标 token。
  结果：`goal_trial_room.tscn/GoalZone` 新增 / 调整 `GoalMarkerArt`，绑定 `equipment_pickup_atlas_ai01.demo_completion_token` AtlasTexture，并隐藏 `GoalZone/ZoneVisual`；不改 `GoalZone` 碰撞、战斗清敌、门禁、左侧返回或 Stage9 入口推进。
  关键验证或结论：formal remap GUT `6/6` tests、`142` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；formal remap 运行态复核 `P0=0 / P1=0 / P2=0`；本地聚焦图 `goal_trial_target_focus.png` 目检确认目标 token 可读且不再显示弱触发区底板。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式拾取逻辑、目标动画、目标音效、小地图、选关系统或 Stage9 后续关卡终稿完成。

- **Stage10 main optional branch marker runtime replacement**：把 Stage10 主房左侧可选奖励支路入口从低透明触发区推进到现有 equipment atlas 的可见收益标识。
  结果：`stage10_zone_aerial_room.tscn/BranchZone` 新增 `BranchMarkerArt`，绑定 `equipment_pickup_atlas_ai01.reward_orb_small` AtlasTexture；不改 `BranchZone` 碰撞、可选支路跳转、空中攻击价值点、敌人遭遇或 HUD 读值。
  关键验证或结论：Stage10 GUT `11/11` tests、`106` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage10_aerial.png` 目检确认可选支路标识可读且未遮挡 Luna、HUD、空中价值标识、敌人、平台或主线出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整小地图、选关系统、支路奖励经济、入口动画、音效或 Stage10 关卡终稿完成。

- **Stage15 gauntlet challenge branch marker runtime replacement**：把 Stage15 mixed gauntlet 左侧挑战支路入口从低透明触发区推进到现有 equipment atlas 的可见挑战标识。
  结果：`stage15_mixed_gauntlet_room.tscn/ChallengeBranchZone` 新增 `ChallengeMarkerArt`，绑定 `equipment_pickup_atlas_ai01.boss_core_shard` AtlasTexture；不改 `ChallengeBranchZone` 碰撞、支路跳转、敌人遭遇、Boss 门控或 HUD 读值。
  关键验证或结论：Stage15 GUT `17/17` tests、`392` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage15_gauntlet.png` 目检确认挑战支路标识可读且未遮挡 Luna、HUD、敌人、地面或右侧 Boss 门路线。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整挑战房系统、支路奖励经济、入口动画、门禁音效或 Stage15 关卡终稿完成。

- **Stage14 loop return goal marker runtime replacement**：把 Stage14 回环房右侧目标入口从低透明触发区推进到现有 equipment atlas 的可见路线标识。
  结果：`stage14_loop_return_room.tscn/GoalZone` 新增 `GoalMarkerArt`，绑定 `equipment_pickup_atlas_ai01.map_scrap` AtlasTexture；不改 `GoalZone` 碰撞、Stage14 到 Stage15 的房间推进、checkpoint 或 HUD 读值。
  关键验证或结论：Stage14 GUT `16/16` tests、`349` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage14_loop_return.png` 目检确认目标标识未遮挡 Luna、HUD、地面、右侧门槛或出口路线。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整小地图、选关系统、出口动画、门禁音效或 Stage14 关卡终稿完成。

- **Stage10 value / recovery / reward marker runtime replacement**：把 Stage10 空中攻击价值点、恢复点和奖励点从不可见逻辑 Marker 推进到现有 atlas 的可见运行态标识。
  结果：`stage10_zone_aerial_room.tscn/AirAttackValueMarker` 新增 `ValueArt` 并绑定 `equipment_pickup_atlas_ai01.air_dash_charm`；`stage10_zone_branch_room.tscn/RecoveryPoint` 新增 `CheckpointArt` 并绑定 `shrine_gate_prop_atlas_ai01.checkpoint_active`；`BranchCollectible` 新增 `CollectibleArt` 并绑定 `equipment_pickup_atlas_ai01.reward_orb_small`；`stage10_zone_challenge_room.tscn/ChallengeCollectible` 新增 `CollectibleArt` 并绑定 `equipment_pickup_atlas_ai01.boss_core_shard`；不改触发距离、收集计数、恢复逻辑、支路跳转或挑战房推进。
  关键验证或结论：Stage10 GUT `11/11` tests、`98` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage10_aerial.png`、`stage10_branch.png` 与 `stage10_challenge.png` 目检确认新增标识可读且不遮挡 Luna、HUD、敌人、平台、门禁或出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式奖励经济、拾取动画、拾取音效、checkpoint 激活动画、空中攻击专用教学演出或背包 UI 完成。

- **Stage13 checkpoint runtime prop replacement**：把 Stage13 checkpoint 从纯逻辑恢复点推进到现有 prop atlas 的可见恢复点标识。
  结果：`stage13_miasma_marsh_checkpoint_room.tscn/RecoveryPoint` 下新增 `CheckpointArt`，绑定 `shrine_gate_prop_atlas_ai01.checkpoint_active` AtlasTexture；不改 checkpoint 信号、重生、碰撞、出口或房间推进。
  关键验证或结论：Stage13 GUT `13/13` tests、`360` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage13_checkpoint.png` 目检确认 checkpoint prop 可读且不遮挡 Luna、HUD、平台或出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式存档系统、保存 UI、checkpoint 音效或激活动画完成。

- **Stage13 branch reward marker runtime replacement**：把 Stage13 资源 / 挑战支路的逻辑奖励点推进到现有 equipment atlas 的可见奖励标识。
  结果：`stage13_miasma_marsh_resource_branch_room.tscn` 与 `stage13_miasma_marsh_challenge_branch_room.tscn` 的 `Stage13Reward` 下新增 `RewardArt`；资源支路绑定 `equipment_pickup_atlas_ai01.seal_fragment`，挑战支路绑定 `equipment_pickup_atlas_ai01.reward_orb_large`；挑战支路奖励点轻微左移，避免贴近运行态截图右边缘；不改奖励计数、支路返回、碰撞或房间推进。
  关键验证或结论：Stage13 GUT `13/13` tests、`351` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage13_resource_branch.png` 与 `stage13_challenge_branch.png` 目检确认奖励点可读且不遮挡 Luna、HUD、平台或出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于正式奖励经济、拾取动画、拾取音效、背包 UI 或奖励平衡完成。

- **Stage13 branch hub route marker runtime replacement**：把 Stage13 支路枢纽从弱触发区读值推进到现有 equipment atlas 的路线标识。
  结果：`stage13_miasma_marsh_branch_hub_room.tscn` 的 `ResourceBranchZone`、`ChallengeBranchZone`、`ExitZone` 分别新增 `ResourceMarkerArt`、`ChallengeMarkerArt`、`ExitMarkerArt`，绑定 `equipment_pickup_atlas_ai01.reward_orb_small`、`boss_core_shard` 和 `map_scrap` AtlasTexture；不改 Area2D 碰撞、支路跳转、主线出口或 checkpoint。
  关键验证或结论：Stage13 GUT `13/13` tests、`335` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage13_branch_hub.png` 目检确认标识不遮挡 Luna、HUD、平台或出口。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整小地图、正式选关系统、支路奖励经济、专用拾取动画或音效完成。

- **Stage15/16 seal-chain split foreground prop expansion**：把已验证的拆分链锚 prop 从 Stage16 threshold 扩展到同一封印链上的 Stage15 completion 和 Stage16 backtrack。
  结果：`stage15_completion_room.tscn/CompletionSeal` 与 `stage16_backtrack_confirmation_room.tscn/BacktrackConfirmationNode` 新增 `SealChainAnchorLeftArt` / `SealChainAnchorRightArt`，继续绑定 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；对应 `ReusableSealPropsPreviewArt` 仍隐藏，不改 Stage15 到 Stage16 接入、backtrack 门禁、ExitZone、checkpoint 或房间推进。
  关键验证或结论：Stage16 GUT `18/18` tests、`422` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage15_completion.png` 与 `stage16_backtrack.png` 目检确认链锚 prop 不遮挡路线、HUD、敌人或门禁。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整区域前景装饰包、手工 autotile、专用门禁动画或音效完成。

- **Stage16 threshold split foreground prop integration**：把 Stage16 第一房从“隐藏整张 reusable seal source sheet”推进到“可见拆分单件前景 prop”。
  结果：`stage16_seal_release_threshold_room.tscn/SealReleaseNode` 新增 `SealChainAnchorLeftArt` 和 `SealChainAnchorRightArt`，分别绑定 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；`ReusableSealPropsPreviewArt` 继续隐藏，不改门禁碰撞、ExitZone、checkpoint 或房间推进。
  关键验证或结论：Stage16 GUT `18/18` tests、`378` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_threshold.png` 目检确认链锚 prop 不遮挡路线、HUD 或门禁。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整区域前景装饰包、手工 autotile、专用门禁动画或音效完成。

- **TutorialHUD core icon, objective marker and panel art unification**：把常驻 HUD 小图标从混用 standalone PNG 收敛为同一 core icon atlas，把普通目标行徽标从旧 SVG 切到 HUD atlas，并给 HUD / 提示面板补现有 UI atlas 贴图层。
  结果：`DashIcon` 改用 `icon_sheet_core_ai01.air_dash`，`RecoveryChargeIcon` 改用 `icon_sheet_core_ai01.recovery_charge`，与既有 `HealthIcon` 的 `icon_sheet_core_ai01.health` 保持同一图集和 64px 单元；`ObjectiveIcon` 改用 `hud_core_ui_atlas_ai01.room_goal_marker`，只在普通目标行显示，恢复 / Boss 行隐藏；`PromptPanelArt` / `BattlePanelArt` 复用 `menu_ninepatch_ui_ai01` 深色 atlas 贴图层，不改 HUD 数值、恢复机制或 Boss 条。
  关键验证或结论：Stage12 GUT `10/10` tests、`237` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`tutorial_room.png`、`stage13_entry.png`、`stage15_pressure.png` 与 `stage15_boss.png` 目检确认图标和面板贴图统一、未变形、未遮挡。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整 HUD 设计系统、Boss / 能力 HUD 清稿、设置 / 选关 UI 或音频完成。

- **Stage13 goal device runtime prop replacement**：把 Stage13 目标房的亮色几何目标装置替换为现有正式 prop atlas。
  结果：`stage13_miasma_marsh_goal_room.tscn/GoalDevice` 从 `Polygon2D` 改为 `Sprite2D`，绑定 `shrine_gate_prop_atlas_ai01.miasma_ward_idle` / `016_shrine_gate_prop_atlas_ai01_auto_017_c02`，并设置 `z_index=1`；不改 `GoalZone` 碰撞、主线跳转或 checkpoint。
  关键验证或结论：Stage13 GUT `13/13` tests、`332` asserts；Godot import 通过；全内容流程截图证据 `P0=0 / P1=0 / P2=0`；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage13_goal_device.png` 目检确认不再是亮色几何块。
  详情日志链接：`docs/progress/logs/2026-07-05.md`；遗留：本轮不等于完整区域前景装饰包、手工 autotile、专用目标交互动画或音效完成。

## 2026-07-04

- **DemoShell semantic button icon polish**：把菜单 icon sheet 从“隐藏整图预览”推进到语义匹配按钮图标的最小运行态接入。
  结果：新增 `continue_play`、`restart`、`back` 三个 AtlasTexture editor resource，并只接入暂停继续、暂停重开、失败继续和详情返回按钮；主菜单六项因现有 icon sheet 缺少准确语义而暂不硬套图标。`capture_demo_shell_layout_hover_review.gd` 增加 `2048x1152` 复核 case，保留 normal / hover 截图证据。
  关键验证或结论：Stage16 GUT `18/18` tests、`356` asserts；Godot import 通过；DemoShell 启动四态截图复核 `ok=true`；菜单布局 / hover 复核覆盖 `640x360`、`1024x576`、`2048x1152` 三档并返回 `ok=true`。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于完整主菜单 icon set、正式设置 / 选关系统、UI 动效或最终按钮清稿完成。

- **Stage16 seal release prop readability polish**：把三状态封印释放 prop 从“已接入但远景像噪点”收敛到运行态可读尺寸。
  结果：Stage15 completion、Stage16 threshold、Stage16 backtrack 继续复用 `stage16_seal_release_threshold_ai01` locked / active / released 三个 AtlasTexture，只把对应 Sprite2D 从 `scale=0.055 / y=-12` 调到 `scale=0.085 / y=8`；不新增图片、不改变门控、碰撞、房间推进或 source sheet 隐藏策略。
  关键验证或结论：Stage16 GUT `18/18` tests、`341` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；三张目标截图目检确认 prop 可读且未遮挡路径或门禁。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于专用开门动画、门禁 SFX、完整机关状态机或最终 prop 清稿完成。

- **Stage16 completion art safe-area polish**：把终点房完成反馈从“有正式图但贴右边裁切”收敛到 640 基准镜头安全区内。
  结果：`stage16_alpha_demo_end_room.tscn` 继续复用 `stage16_alpha_demo_completion_ai01` 与 `stage16_completion_panel_ui_ai01`，只把 `AlphaDemoCompletionArt` 从 `position=(256,30) / scale=0.26` 调到 `position=(150,30) / scale=0.18`，并同步移动文字牌；不新增图片、不改变完成触发、ExitZone、HUD 完成态或房间推进。
  关键验证或结论：Stage16 GUT `18/18` tests、`326` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_end.png` 目检确认完成图完整留在右侧区域内，文案可读且未遮挡玩家路径。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于结算页、完成动画、音效或最终 UI 清稿完成。

- **Stage16 talisman relay readability polish**：把终局符印中继从“已接入但运行态太小”收敛到 640 基准镜头下可读。
  结果：`stage16_talisman_relay_room.tscn` 的三个 `RelayArt` 继续复用 `stage16_talisman_relay_ai01` region-bound VFX，只把视觉层 `scale` 从 `0.045` 调到 `0.065`；Stage16 测试新增可读性上下限，避免回退成微小几何点或过大遮挡门禁。
  关键验证或结论：Stage16 GUT `18/18` tests、`322` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_relay.png` 目检确认中继可读，未遮挡路径、门禁或 HUD。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不新增图片、不改门控 / 碰撞 / 房间推进，也不等于专用机关动画或门禁音效完成。

- **TutorialHUD meter rail runtime polish**：把每局稳定可见的 HUD 条形读值从裸 ColorRect 收敛为正式 HUD atlas 轨道装饰。
  结果：`TutorialHUD/BattlePanel` 新增生命、冲刺、恢复和 Boss 四个 `*MeterFrameArt` TextureRect，统一绑定 `hud_core_ui_atlas_ai01.meter_rail`；恢复 / Boss 轨道复用原有显隐逻辑，只在 Stage15 / Boss 房显示；不改变血量、冲刺冷却、恢复充能或 Boss 生命计算。
  关键验证或结论：Stage12 GUT `10/10` tests、`221` asserts；Godot import 通过；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`test_room.png` 原图目检确认红 / 青条上有细金线轨道，不遮挡文字和目标面板；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于完整 HUD icon set、Boss HUD 专用清稿、字体清稿、设置 / 选关系统或音频完成。

- **FP-01 visible runtime asset review gate**：补强最终美术 FP-01 运行态读值复核，避免隐藏 source preview 误当作可见资产替换完成。
  结果：`capture_final_art_polish_fp01_review.gd` 的目标清单改为检查当前真实可见的背景、TileMap、Stage14 shrine / gate prop、Stage15 Boss runtime visual 和 Stage16 gate / threshold prop；Stage14 shrine / gate 显式覆盖 `shrine_gate_prop_atlas_ai01` 的 `ShrineArt`、`GatePreviewArt`、`ShrineEchoArt`、`GateArt`，并要求资源路径有效、`asset_id` 精确匹配、节点可见、无碰撞子节点。
  关键验证或结论：FP-01 非 headless 截图复核 `ok=true`；Demo remap GUT `5/5` tests、Stage14 GUT `16/16` tests、Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0`、`git diff --check` 均通过。该复核确认红绿门禁不是当前 Stage14 运行态资产状态，剩余正式 Demo 缺口转向音频、完整 UI 系统、手工 autotile / 前景装饰和发布级清稿。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不新增图片、不改碰撞、不实现门禁动画 / SFX 或完整机关系统。

- **DAC player grounded capture gate**：修正全房间运行态截图验收证据，避免把切房下落帧误判为 Luna 默认姿态或动作资产问题。
  结果：`capture_demo_art_composition_review.gd` 切房后等待玩家物理落地再截图，并在报告表新增 `Player` 姿态列；玩家未落地或静态截图仍处于 dash / jump / air attack 时会进入 P2；本地 `dac03_contact_sheet.png` 已刷新。
  关键验证或结论：全 `39` 房 DAC 复核仍为 `P0=0 / P1=0 / P2=0`，报告中所有房间均为 `floor`；`stage13_entry.png`、`tutorial_room.png`、`stage16_end.png` 与 contact sheet 目检确认 Luna 落地、idle、脚底贴合，不再以空中 / dash 姿态作为静态签核证据。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不新增动作帧、不改玩家控制、碰撞、房间布局或相机，只修正运行态视觉验收口径。

- **Stage15/16 reusable seal source sheet cleanup**：清理正式流程房间中可见的 reusable seal source sheet。
  结果：`stage15_completion_room.tscn`、`stage16_seal_release_threshold_room.tscn`、`stage16_backtrack_confirmation_room.tscn` 的 `ReusableSealPropsPreviewArt` 改为隐藏并标记为 `hidden_source_sheet_not_runtime_prop`；Stage16 测试从“引用整图”改为“source sheet 只能隐藏保留”，DAC 新增 `reusable_seal_props_ai01` 可见 source sheet 检查。
  关键验证或结论：Stage16 GUT `18/18` tests、`313` asserts；Stage15 GUT `17/17` tests、`388` asserts；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检确认小型 props sheet 不再上屏；Godot import 和 `git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不拆分 reusable seal props 单件、不新增 prop atlas、碰撞、动画或音效。

- **Stage14 shrine source preview and trigger rectangle cleanup**：清理 Air Dash 神龛房右侧硬边矩形。
  结果：`stage14_air_dash_shrine_room.tscn` 隐藏 `ShrineTrialParallaxArt`、`AirDashShrineRoomArt` 和已有正式门禁 prop 覆盖的 `ExitZone/ZoneVisual`，保留主背景、TileSet、神龛、门禁 prop、Air Dash trail、碰撞和房间切换逻辑。
  关键验证或结论：Stage14 GUT `16/16` tests、`345` asserts；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage14_shrine.png` 目检确认源图 / 触发区硬边块收敛。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于正式 parallax split、完整背景清稿、宽屏背景资产包或最终美术签核。

- **TutorialHUD compact prompt panel polish**：收紧房间标题-only 状态下的右上 HUD 空提示面板。
  结果：`TutorialHUD/PromptPanel` 根据提示正文是否为空自动切换完整高度 / 宽度和紧凑高度 / 宽度；正文为空时隐藏 `PromptLabel`，只保留窄标题条，不再在运行态截图中留下大块空黑框或长黑条；有正文时恢复完整提示框；不改变房间上下文、教程推进、玩家控制或 HUD 资产绑定。
  关键验证或结论：Stage12 GUT `10/10` tests、`197` asserts；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage13_entry.png` 目检确认右上提示区已收紧，`tutorial_room.png` 目检确认教程正文未被挤压。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不实现完整 HUD icon set、字体清稿、设置页或控制说明系统。

- **Stage16 completion room text overlay**：补齐终点房完成反馈牌面的运行态文案。
  结果：`stage16_alpha_demo_end_room.tscn` 在现有 `AlphaDemoCompletionArt` / `CompletionPanelEchoArt` 上新增 `CompletionMessageLabel`，显示 `Alpha Demo 已完成`，使用浅金字与 1px 深色描边适配深色牌面；不改完成触发、ExitZone、房间切换或交付物。
  关键验证或结论：Stage16 GUT `18/18` tests、`303` asserts；全 `39` 房 DAC 截图复核 `P0=0 / P1=0 / P2=0`；`stage16_end.png` 目检确认完成文字在牌面安全区内可读。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不实现结算页、完成动画、音效或最终 UI 清稿。

- **DemoShell main menu and prompt panel polish**：把主菜单中仍像占位提示的次级入口收敛为可读详情页，并修正提示面板文字可读性。
  结果：新增 `DemoShell/DetailPanel`，`继续游戏`、`选择关卡`、`设置`、`控制说明` 复用同一个详情页和返回按钮；主菜单 / 详情页 / 暂停 / 失败 / 完成提示的羊皮纸文字改为深色，失败提示面板加高以完整包住当前按钮视觉和遮挡层。
  关键验证或结论：Stage16 GUT `18/18` tests、`298` asserts；`capture_demo_shell_start_review.gd` 输出 `ok=true`，并记录 `controls_detail_text_ok=true`、`pause_text_ok=true`、`failure_text_ok=true`；Godot import 通过，截图目检确认控制说明、暂停提示和失败提示文字可读，失败提示不再露出角色身体。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不实现真实存档、选关、音量设置或按键重绑定，只完成正式 Demo 菜单读值和说明页。

- **Stage16 relay gate asset semantic correction**：根据用户运行态截图复核修正 Stage16 relay 右侧门禁误读。
  结果：`stage16_talisman_relay_room.tscn` 的 `GateBarrier/GateArt` 从容易读成红绿竖杆的 `boss_gate_locked` 特殊切片改回通用 `seal_gate_locked` 关闭石门切片；`Stage9RoomBase._apply_gate_lock_state()` 移除对 `boss_gate_locked` 的特殊保留逻辑，Stage16 relay 现在跟其它常规封印门统一走 locked / open 状态口径。
  关键验证或结论：Godot import 通过；Stage14 GUT `16/16` tests、`339` asserts；Stage16 GUT `18/18` tests、`269` asserts；formal remap 运行态复核 `P0=0 / P1=0 / P2=0`；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；2K 专项复核 `ok=true`、`camera_zoom=[3.2, 3.2]`；`stage16_relay_to_threshold_entry.png` 目检确认不再出现红绿竖杆门禁。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮修正的是错误切片 / 语义选择，不等于专用 Boss 门动画、门禁 SFX、正式机关状态机或完整门禁资产包完成。

- **DemoShell pause panel preview hidden**：清理暂停菜单中错位叠显的整图面板预览。
  结果：`DemoShell/PauseMenu/PausePanelArt` 改为隐藏，保留 `stage16_pause_panel_ui_ai01` 纹理资源引用供后续清稿；Stage16 测试新增断言，防止带预制槽位的整图再次覆盖当前“继续 / 重开”按钮；`capture_demo_shell_start_review.gd` 扩展为 menu / started / pause / failure 四态截图复核。
  关键验证或结论：Godot import 通过；Stage16 GUT `18/18` tests、`269` asserts；四态 DemoShell 截图复核 `ok=true`；`demo_shell_pause.png` 目检确认预制横向槽位已消失。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮只隐藏错误预览，不等于正式暂停菜单图标、设置页、控制说明页或完整 UI 设计系统完成。

- **DemoShell menu icon sheet preview hidden**：清理主菜单中误上屏的整张菜单图标 source sheet 预览。
  结果：`DemoShell/MainMenu/MenuIconStrip` 改为隐藏，保留 `stage16_demo_menu_icons_ai01` 纹理资源引用供后续正式切图；Stage16 测试新增断言，防止 2x3 source sheet 再被压缩成运行态底部装饰条。
  关键验证或结论：Godot import 通过；Stage16 GUT `18/18` tests、`267` asserts；菜单 hover 复核 `ok=true`；2K 专项复核 `ok=true`、`camera_zoom=[3.2, 3.2]`；`demo_shell_menu_2k.png` 目检确认按钮间的小图标条已消失。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮只隐藏错误预览，不等于完整主菜单 icon set、设置页、选关页或控制说明页完成。

- **TutorialHUD health icon runtime polish**：清理运行态 HUD 中每局可见的生命图标色块。
  结果：`TutorialHUD/BattlePanel/HealthIcon` 从红色 `ColorRect` 改为 `TextureRect`，绑定 `icon_sheet_core_ai01.health` / `009_icon_sheet_core_ai01_auto_010_c02.atlas_texture.tres`，保持 `12x12` HUD 小尺寸；Stage12 测试新增资源路径、asset_id 和尺寸断言，防止回退为调试色块或原图拉伸。
  关键验证或结论：Godot import 通过；Stage12 / Stage14 / Stage15 / Stage16 GUT `61/61` tests、`1181` asserts；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`tutorial_room.png` 与 `stage15_pressure.png` 目检确认生命图标未拉伸或遮挡。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮只处理生命图标，不等于完整 HUD icon set、设置页、控制说明或最终 UI 设计系统完成。

- **Miasma purge warning VFX runtime subresource pass**：把腐瘴危险 / 压制提示从整段通用 combat VFX 收敛为腐瘴专用运行态子资源。
  结果：新增 `miasma_purge_warning_vfx_runtime_ai01.spriteframes.tres`，复用 `vfx_combat_atlas_ai01.png` 后 8 个 `purge` 语义帧；Stage13 miasma / pressure、Stage15 challenge branch 和 MiasmaCaster 压制环改用 `miasma_purge_warning` 动画，不改变伤害 Area、敌人 AI、碰撞、房间推进或音效。
  关键验证或结论：Godot import 通过；Stage13 / Stage15 GUT `30/30` tests、`710` asserts；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`stage13_miasma.png`、`stage13_pressure.png`、`stage15_challenge_branch.png` 目检确认没有回退为大色块、绿底或几何占位。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮是现有 atlas 子资源拆分，不等于全新腐瘴专用 VFX sheet、粒子系统、完整 timing 或危险音效。

- **Gate and switch unlock VFX feedback pass**：给已完成 atlas 替换的门禁 / 机关补第一轮运行态状态反馈。
  结果：新增 `GateStateVfx` helper，复用 `vfx_seal_magic_atlas_ai01` 的 `seal_magic` 动画；教程门、战斗门、目标门、Stage9+ 通用门和 Stage9 switch 激活后会播放 visual-only 短封印 VFX，不改变碰撞、门控状态机、房间推进或音效。
  关键验证或结论：Godot import 通过；Stage5 / Stage6 / Stage7 / Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `87/87` tests、`1598` asserts；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；本地门禁聚焦脚本 `17` 个门禁用例 `ok=true`。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不等于专用门体开合逐帧动画、正式机关多状态、钥匙系统或门禁 SFX。

- **FormalForegroundEdgeDecor foreground edge pass**：继续补全全房间地表与背景之间的前景边缘融合。
  结果：复用现有 `shrine_trial_tileset_ai01` / `miasma_marsh_tileset_ai01`，为全 `39` 房新增 / 重刷 `FormalForegroundEdgeDecor` TileMapLayer，共 `149` 个稀疏 edge tile；该层只做视觉，`collision_enabled=false`，不改变房间拓扑、碰撞或跳跃落点；DAC 新增 `missing_foreground_edge_decor` P2 gate，并把该层从普通 sparse tilemap 误报中排除。
  关键验证或结论：`apply_dac_formal_terrain_tilemaps.gd` 成功重写 `39` 房；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`stage9_switch.png`、`stage14_gate.png`、`stage16_threshold.png` 目检确认地表顶边增加断石 / 草根 / 破损边缘层，未遮挡 Luna、门禁、机关、HUD 或出口提示。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮仍不等于手工 autotile、区域前景 prop 包、完整 parallax split 或美术总监最终签核。

- **FormalTerrain underlay visual weight pass**：继续收敛全房间连续地形承托层的灰盒读值。
  结果：全 `39` 房 `dac_continuous_stone_underlay.png` 视觉层从 `alpha=0.20` 降到 `0.12`；`apply_dac_formal_terrain_tilemaps.gd` 与 `apply_dac_terrain_texture.gd` 同步默认值；DAC 的 `heavy_textured_underlay` 阈值从 `0.24` 收紧到 `0.16`；Stage13 门禁测试同步补齐 `002` locked / `003` open 两态断言。
  关键验证或结论：Godot import 通过；formal remap + Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `73/73` tests、`1485` asserts 通过；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`stage9_switch.png`、`stage14_gate.png` 与 `stage16_threshold.png` 目检确认暗色矩形底板退为弱材质过渡。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改碰撞、房间拓扑、TileSet 选择、相机或背景；正式手工 autotile、前景融合和完整 parallax split 仍属后续 polish。

- **All-content seal gate runtime prop atlas binding**：统一清理主流程旧封印门 SVG 运行态绑定。
  结果：教程、战斗试炼、GoalTrial、Stage9、Stage10、Stage13、Stage15、Stage16 常规门禁统一使用 `shrine_gate_prop_atlas_ai01` 状态切片；锁定态为关闭石门 `002_shrine_gate_prop_atlas_ai01_auto_003_c01` / `seal_gate_locked`，开启态为 `003_shrine_gate_prop_atlas_ai01_auto_004_c01` / `seal_gate_open`；同步修正 `shrine_gate_prop_atlas_ai01.semantics.json` 中 `002` / `003` 的旧机器语义；DAC 新增 `visible_legacy_gate_sprite` P1 检查，防止 legacy SVG 封印门再次进入运行态。后续同日复核发现 Stage16 relay 保留的 `boss_gate_locked` 特殊切片在运行态距离下误读，已由上方 `Stage16 relay gate asset semantic correction` 改回通用 `seal_gate_locked`。
  关键验证或结论：Godot import 通过；Stage3 / Stage5 / Stage6 / Stage7 / Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `91/91` tests、`1518` asserts 通过；状态复核补跑 Stage5 / Stage6 / Stage7 / Stage9 / Stage14 / Stage16 GUT `57/57` tests、`850` asserts；FP-02 atlas split audit `0` errors；asset semantics audit `26` assets、`538/538` entries；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；本地门禁聚焦脚本 `17` 个门禁用例 `ok=true`；`scenes/rooms` 中旧 `stage13_seal_gate_01.svg` 运行态绑定检索为 `0`。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改门禁状态机、碰撞、开门动画、SFX 或正式钥匙系统，只完成正式 Demo 当前运行态门禁视觉统一。

- **Formal Demo 2K runtime adaptation, camera zoom, and menu hover correction**：复核修正运行态分辨率、相机高分屏视野、主菜单交互和 Luna 脚底视觉锚点。
  结果：项目显示适配从 `viewport / keep / integer` 改为 `canvas_items / expand / fractional`；`Main` 按 `640x360` 基准给当前玩家 Camera2D 补高分屏 zoom，2048x1152 下 zoom 为 `Vector2(3.2, 3.2)`，不再一次暴露 3.2 倍设计视野和背景拼接缝；`DemoShell` 主菜单收敛为 640x360 基准内的 `520x336` 居中面板，六项主菜单按钮改为 `360x32` 左右的 StyleBoxFlat 交互态，不再 hover 变扁；`LunaRuntimeAnimationVisual.position` 调整为 `Vector2(0, -32)`，按可见地表顶面对齐。
  关键验证或结论：Godot import 通过；Stage1 GUT `11/11` tests、`73` asserts；formal remap GUT `5/5` tests、`128` asserts；Stage14 GUT `16/16` tests、`335` asserts；Stage16 GUT `18/18` tests、`260` asserts；全房间 DAC OpenGL 复核 `39` 房间、`P0=0 / P1=0 / P2=0`；主菜单 hover 复核 `ok=true`；2K 专项运行态复核 `ok=true`。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮没有生成真正的超宽屏无缝背景或 parallax split，后续若要支持 21:9 大幅横向视野仍需独立资产批次。

- **Stage16 seal release threshold state-sliced runtime prop binding**：修正三状态封印柱源图被整张缩小上屏的问题。
  结果：新增 `stage16_seal_release_threshold_ai01` 的 locked / active / released 三个 `AtlasTexture` editor resource；Stage16 threshold、Stage15 completion 和 Stage16 backtrack confirmation 分别引用单状态切片，不再显示三枚并排样张。
  关键验证或结论：Godot import 通过；Stage16 GUT `18/18` tests、`256` asserts 通过；Stage15 GUT `17/17` tests、`376` asserts 通过；全房间 DAC OpenGL 复核 `39` 房间、`P0=0 / P1=0 / P2=0`；`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检确认无整图上屏或绿底。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改封印链逻辑、回溯收益计数、碰撞、门禁、音效或正式状态动画。

- **TrainingDummy and Stage11 endpoint marker runtime prop replacement**：清理训练目标绿色十字占位与 Stage11 终点房高亮箭头占位。
  结果：`TrainingDummy/DummyArt` 从 `stage13_seal_node_01.svg` 改为 `shrine_gate_prop_atlas_ai01.seal_pillar_cracked` editor AtlasTexture；Stage11 终点房隐藏 `Stage12ReplayArrow`、`Stage12GoalArrow`、`Stage13ContinueArrow`，新增 `ReplayMarkerArt`、`GoalMarkerArt`、`ContinueMarkerArt`，复用 `equipment_pickup_atlas_ai01` 的 bronze bell / demo token / shrine key AtlasTexture；DAC 新增可见高 alpha `*Arrow` Polygon 检查。
  关键验证或结论：Godot import 通过；Stage3 GUT `5/5` tests、`17` asserts 通过；Stage5 GUT `9/9` tests、`82` asserts 通过；Stage12 GUT `10/10` tests、`184` asserts 通过；全房间 DAC OpenGL 复核 `39` 房间、`P0=0 / P1=0 / P2=0`；`test_room.png` 与 `stage11_end.png` 目检确认目标占位已消失。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改训练目标攻击契约、Stage11 replay / goal / continue 逻辑、碰撞、教程推进、音效或正式入口动画，只完成运行态视觉替换。

- **Stage14 / Stage15 reward and Stage16 purge runtime visual cleanup**：把 Stage14 回溯收益点、Stage15 支路奖励黄菱形和 Stage16 purge 大紫色危险块收敛到正式图集 / 弱氛围读值。
  结果：`BacktrackRewardOne/Two/Three` 的 `RewardVisual` 已隐藏，新增 `RewardArt` 引用 `equipment_pickup_atlas_ai01.reward_orb_large`；Stage15 支路 `Stage13Reward` 从 `Polygon2D` 改为 `Marker2D`，新增 `Stage13RewardArt` 引用同一 reward orb AtlasTexture；`CorruptionMiasma` alpha 从 `0.28` 降为 `0.045`，`stage16_corruption_purge_ai01` 的 `PurgeArt` 承担主视觉；DAC 高 alpha gameplay warning Polygon 检查新增 `CorruptionMiasma` 覆盖。
  关键验证或结论：Godot import 通过；Stage14 GUT `16/16` tests、`334` asserts 通过；Stage15 GUT `17/17` tests、`372` asserts 通过；Stage16 GUT `18/18` tests、`256` asserts 通过；全房间 DAC OpenGL 复核 `39` 房间、`P0=0 / P1=0 / P2=0`；`stage14_backtrack_hub.png`、`stage15_challenge_branch.png` 与 `stage16_purge.png` 目检通过。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改奖励逻辑、净化触发、碰撞、伤害、门控、音效或正式 pickup 经济，只处理运行态高可见视觉。

- **Stage15 pressure and miasma warning runtime VFX replacement**：把 Stage15 压力房、Stage13 / Stage15 腐瘴危险和 MiasmaCaster 压制范围的几何占位提示替换并收敛为正式 VFX 读值。
  结果：`PressureSigil`、腐瘴 `WarningVisual` / `MiasmaWarningArt` 和 MiasmaCaster `MiasmaPressureVisual` 在运行态隐藏；新增并收敛 `PressureSigilArt`、低 alpha / 小缩放 `MiasmaWarningVfxArt` 和低 alpha / 小缩放 `MiasmaPressureVfxVisual`，首轮分别引用 `vfx_seal_magic_atlas_ai01.spriteframes.tres` 与 `vfx_combat_atlas_ai01.spriteframes.tres`，后续已由 `Miasma purge warning VFX runtime subresource pass` 把腐瘴 / 压制绑定收敛到专用子资源；敌人脚本同步降低压制环脉冲 alpha，DAC 新增过亮 / 过大 gameplay warning VFX 检查。
  关键验证或结论：Godot import 通过；Stage13 + Stage15 GUT `29/29` tests、`666` asserts 通过；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`stage13_caster.png`、`stage13_miasma.png`、`stage13_pressure.png`、`stage15_challenge_branch.png` 目检确认高可见几何占位消失，黄色地面环、施法者压制环和压力符印不再读作大面积调试范围圈。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不改敌人配置、AI 半径、伤害来源、碰撞、hitbox、VFX 时序、音效或 Boss 流程，只完成运行态危险 / 压制提示视觉替换与强度收敛。

- **GoalTrial gate and Stage9 switch controller runtime prop replacement**：把 GoalTrial 红绿门禁读值和 Stage9 残留测试色块控制器替换为正式 prop atlas 读值。
  结果：`GoalBarrier/BarrierArt` 改为 `shrine_gate_prop_atlas_ai01.seal_gate_locked` editor AtlasTexture；`GateSwitch/SwitchVisual` 黄色 Polygon 和旧 `Stage12CheckpointMarker` 绿色图标在运行态隐藏；新增 `GateSwitch/SwitchArt` 并接入 idle / lit 两态，默认 `006_shrine_gate_prop_atlas_ai01_auto_007_c01` / `talisman_stake_idle`，触发后切到 `007_shrine_gate_prop_atlas_ai01_auto_008_c01` / `talisman_stake_lit`。
  关键验证或结论：Godot import 通过；Stage9 GUT `4/4` tests、`43` asserts 通过；Stage7 + formal remap GUT `7/7` tests、`168` asserts 通过；全房间 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；`goal_trial.png` 与 `stage9_switch.png` 目检确认红绿 / 黄绿测试色块已消失，Stage9 开关默认不再读作已激活。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮不做逐帧机关动画、正式交互按钮、通用门禁系统、SFX 或完整开关系统，只完成运行态视觉和单控制器两态替换。

- **Formal Demo remaining runtime asset gap review**：按当前运行态截图和资产文档复核剩余待生成资产量。
  结果：新增 `docs/assets/formal-demo-runtime-asset-gap-review-2026-07-04.md`；当前新增 image-gen 运行态阻断数为 `0`，正式 Demo polish 仍建议保留 `6` 个视觉资产包和 `1` 个音频资产包，高标准公开试玩可扩到 `8-10` 个资产包。
  关键验证或结论：依据全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`、资产族 coverage、final-art polish completion 和当前截图目检；门禁 / 机关和腐瘴 / 压制 VFX 已完成第一轮运行态反馈，后续优先转向最小 SFX / BGM、UI / HUD 小图标、手工 autotile 与区域前景装饰 polish。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：该复核不替代真人试玩、美术总监签核、授权复核、音频接入或商业级清稿。

- **FormalTerrainTilemapDecor edge-tile refresh**：收敛全房间地形装饰层的大方砖重复感。
  结果：复用现有 `dac_formal_terrain_tileset_ai01_64`，将普通 `FloorVisual` 的视觉 tile 映射从大方砖行改为地表边缘行；用现有脚本重刷全 `39` 房 `FormalTerrainTilemapDecor`，共更新 `620` 个视觉 tile；DAC 新增 `blocky_floor_tilemap` P2 检查。
  关键验证或结论：全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；formal remap + Stage9-16 GUT `98/98` tests、`1715` asserts 通过；Godot import 和 `git diff --check` 通过；`stage9_switch.png`、`stage13_miasma.png`、`stage15_challenge_branch.png` 目检确认地面读值从方砖拼块转向破损地表边缘。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮仍是 tileset 装配层，不等同商业级手工 autotile、逐房间地貌清稿、前景层或最终美术签核。

- **P0 runtime visual acceptance pass 01**：修复用户运行态截图暴露的首批正式 Demo 视觉验收问题。
  结果：首轮曾恢复 Godot `640x360` viewport + `viewport/keep/integer` stretch 契约并修正 Luna ai03 body 运行态脚底基线；同日后续 2K 复核确认该分辨率策略不适合当前正式 Demo 大图资产，已由上方 `Formal Demo 2K runtime adaptation, camera zoom, and menu hover correction` 改为 `canvas_items / expand / fractional`，并将 Luna 视觉锚点进一步调整到可见地表顶面对齐。Stage14 Air Dash shrine / gate 运行态改用 `shrine_gate_prop_atlas_ai01` 的正式 AtlasTexture，移除样本链路中的红绿调试门禁读值。
  关键验证或结论：`godot --headless --path . --import` 通过；Stage1 + Stage14 + Stage16 GUT `44/44` tests、`638` asserts 通过；formal remap headless 与 OpenGL 运行态复核均为 `P0=0 / P1=0 / P2=0`；`stage14_gate_to_shrine_gate_focus.png` 人工目检通过；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-07-04.md`；遗留：本轮是 P0 运行态观感修复，不等同全部 Demo 资产完成，完整音频、敌人 / Boss 清稿、门禁状态动画和全房间审美签核仍属后续资产生产线。

## 2026-07-03

- **Luna unified runtime body ai03 replacement**：用 image_gen 生成并接入 Luna 当前运行态 body 全套动作帧。
  结果：新增 `idle`、`run`、`jump_fall`、`attack_body`、`air_dash_body`、`hit_react`、`death_idle` 7 张单动作透明 PNG sprite sheet，共 `128` 帧、统一 `192x192` 固定格；玩家运行态 SpriteFrames、Stage14 资产断言和 Luna attack / air dash 本地复核脚本均切到 `luna_*_runtime_sheet_ai03`。
  关键验证或结论：像素检查确认角落 alpha、格边 alpha、下半部孤立残线均为 `0`；专项动作替换严格审计 `7/7 active ready, 0 active blocked`；`godot --headless --path . --import` 通过；Stage12 / Stage14 / Stage15 / Stage16 GUT `57/57` tests、`1013` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-07-03.md`；遗留：本轮是 Alpha Demo 运行态 body 替换，不改变玩法 timing、碰撞、VFX 伤害或商业最终清稿；release 前仍需人工复核生成式资产授权条款。

## 2026-07-02

- **Alpha Demo formal level remap execution closure**：按正式 Demo 级横版类银河城关卡逻辑完成运行态重排修复。
  结果：普通非锁门房间补双向返回、反向 spawn 和安全落点；`Stage9RoomBase`、`CombatTrialRoom`、`GoalTrialRoom` 支持 previous-room / scene-level spawn 契约；Combat / Goal / Stage9 entry / Stage13 caster / Stage14 gate / Stage16 relay 等样本链路均可从下个房间返回上个房间；Goal 绿色悬浮台阶改为正式石质平台读值；新增 Phase 6 运行态复核脚本 `scripts/dev/capture_demo_formal_remap_review.gd`。
  关键验证或结论：Godot import 通过；formal remap GUT `4/4` tests、`125` asserts；Stage5、Stage9-16 GUT `97/97` tests、`1476` asserts；formal remap Phase 6 报告覆盖 `6` 条链路，`bidirectional_pass_count=6`、`route_end_safety_issues=0`、`visual_readability_issues=0`、`P0=0 / P1=0 / P2=0`；DAC strict gate、full-flow evidence 和 input replay 均为 `P0=0 / P1=0 / P2=0`，input replay `rooms_seen=37`；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-07-02.md`；遗留：本轮是 Alpha Demo 级关卡读值和拓扑修复，不等同商业最终 autotile、完整小地图、全部支路真人录屏或美术总监级清稿；Codex 直连 MCP 工具仍返回 editor 未连接，Phase 6 采用 Godot MCP CLI / 生产脚本证据闭环。

- **Alpha Demo formal level remap planning**：根据运行态截图复核修正关卡完成口径，生成正式 Demo 级横版类银河城关卡重排计划。
  结果：新增 `spec-design/2026-07-02-demo-level-formal-remap.md`、`plan/2026-07-02-demo-level-formal-remap.md`、`docs/implementation-plans/2026-07-02-demo-level-formal-remap-plan.md`；明确普通房间默认双向通行、连接处必须有安全落点、红绿封印门和绿色台阶不得误导玩家、关键房间长度由玩法节奏决定、背景通过可延展层适配；阶段六指定 Godot MCP Pro 运行态复核，图形缺口允许按边界使用 image_gen。
  关键验证或结论：本轮只生成正式计划和实施文档，尚未修改运行态关卡；后续执行必须先写正式 remap 契约测试，再分阶段改共享房间契约、场景拓扑、资产读值和 MCP 运行态证据。
  详情日志链接：`docs/progress/logs/2026-07-02.md`；后续：已在同日按该计划完成执行收口，见上方 `Alpha Demo formal level remap execution closure`。

- **Strict environment art kit closure**：复核修正全内容场景美术完成口径，并完成 Alpha Demo 级场景资产配置收口。
  结果：新增 `docs/assets/environment-art-kit-spec.md`；`scripts/dev/capture_demo_art_composition_review.gd` 加严背景覆盖、visible preview-only、visible graybox、无纹理 Polygon 地形、触发区色块、道具底板、HUD 大面积贴图、缺少正式 TileMap 装饰层和高 alpha gameplay warning Polygon 检查；修复 `39` 房间背景覆盖 / preview / graybox / 连续地形 underlay / 触发区 / prop 底板问题；使用内置 `image_gen` 生成透明规则网格地形 kit，规范化为 `64x64` sheet 和 Godot TileSet，并为 `39` 房间接入 `FormalTerrainTilemapDecor` / `607` 个视觉 tile；瘴气敌人压力圈和 hazard warning 改为低 alpha aura / 正式 warning SVG。
  关键验证或结论：初始 strict gate 为 `P0=0 / P1=61 / P2=0`；修复后 OpenGL DAC-03 覆盖 `39` 房间且截图均为 `captured`，结果为 `P0=0 / P1=0 / P2=0`，且没有 `visible_tilemap_count=0` 的房间；contact sheet 保存到 `tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/dac03_contact_sheet.png`；full-flow 生产流程证据 `P0=0 / P1=0 / P2=0`；输入式 replay wrapper `rooms_seen=35`、`P0=0 / P1=0 / P2=0`；Stage5、Stage9-16、Stage12 GUT `97/97` tests、`1476` asserts 通过；追加瘴气敌人 / hazard 视觉修正后 Stage13 / Stage15 GUT `27/27` tests、`593` asserts 通过；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-07-02.md`；遗留：本轮达到 Alpha Demo 级资产配置验收，不等同最终商业清稿、手工 autotile、完整 parallax split、真人录屏或美术总监级审美签核；Codex MCP 直连工具侧仍未恢复，不宣称 MCP 工具连接已修好。

## 2026-07-01

- **Full content Demo QA closure**：将 Demo 级视觉验收从 27 个关键房间扩展到全部 39 个房间，并补全从主菜单开始的 MCP 输入式主线 replay。
  结果：`scripts/dev/capture_demo_art_composition_review.gd` 输出到 `tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/`，覆盖全部 `scenes/rooms/*.tscn` 并检测可见源图 / 图集预览、高不透明纯色地形 underlay、出口 / 目标可见性和地表材质过渡；`scripts/dev/capture_full_content_flow_evidence.gd` 沿生产 `Main.tscn` 捕获 `34` 个主线房与 `5` 个支路 / 内部房；`scripts/dev/mcp_player_input_replay_probe.gd` 从主菜单点击 `开始` 后只用输入动作跑到 Stage16 完成；补修 Stage13 地面覆盖 / checkpoint、Stage15 地面覆盖 / 支路触发位置 / gauntlet checkpoint，并让 headless 证据脚本在 dummy renderer 下不再卡住或误报截图。
  关键验证或结论：Godot import 通过；全 Stage1-16 GUT `142/142` tests、`1716` asserts 通过；Stage13 专项 `12/12`、Stage15 专项 `15/15` 通过；LL-00 审计 `27` 房间、`P0=0 / P1=0 / P2=0`；DAC-03 全内容视觉门禁为 `39` 房间、`P0=0 / P1=0 / P2=0`；full-flow 证据为 `34+5` 房间、`P0=0 / P1=0 / P2=0`；MCP 输入式 replay 为 `rooms_seen=35`、`elapsed=269.6s`、`stage16_alpha_demo_completed=true`、`P0=0 / P1=0 / P2=0`；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-07-01.md`；遗留：当前达到 Alpha Demo 级主线可玩和资产配置验收，不等于商业最终清稿或真人录屏；支路 / 内部房由 full-flow 证据覆盖，不宣称每条支路都有逐步手操视频。

## 2026-06-30

- **DAC-02 branch art signoff audit**：扩展 Alpha Demo 支路审计，并推进发布级美术签核口径。
  结果：`scripts/dev/capture_demo_art_composition_review.gd` 从 `20` 房扩到 `27` 房，新增 `Decor` / `Signoff` 字段；Stage13 caster / pressure / crossfire / challenge branch 补瘴泽背景、TileSheet 和 TileMap decor；Stage15 pressure / gauntlet / challenge branch、Stage16 relay 补地表材质过渡层；Stage15 challenge branch 以封印门图替换红色占位门。
  关键验证或结论：`godot --headless --path . --import` 通过；DAC-02 报告 `P0=0 / P1=0 / P2=0`；`dac02_contact_sheet.png` 人工目检未发现明显背景空洞、红色占位、材质带遮挡或 HUD 遮挡；Stage13 / Stage15 / Stage16 GUT `43/43` tests、`698` asserts 通过；`git diff --check` 通过但仍有既有 CRLF warning。
  详情日志链接：`docs/progress/logs/2026-06-30.md`；遗留：本轮是 Alpha Demo 级运行态截图 + 人工目检签核，不等于商业最终清稿或正式 autotile / terrain author 完成。

- **DAC-01 main route asset composition repair**：完成 Alpha Demo 主路线第一轮 Demo 级资产配置修复。
  结果：Stage13 entry 和五个 P3 样板房恢复连续地形 underlay、背景相机覆盖和可见出口 / 目标标记；Stage13 / Stage14 / Stage15 / Stage16 主路线缺背景房间补入同区域背景；主路线可见红色 `BarrierVisual` 封印柱替换为现有封印门图；新增 `scripts/dev/capture_demo_art_composition_review.gd`，运行态截图审计覆盖 `20` 个关键房间并检测可见 `BarrierVisual`。
  关键验证或结论：`godot --headless --path . --import` 通过；DAC-01 报告 `P0=0 / P1=0 / P2=0`；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT `67/67` tests、`1069` asserts 通过；`git diff --check` 通过但仍有既有 CRLF warning。MCP 工具入口已暴露，但编辑器桥接未连接，本轮没有 MCP 截图证据。
  详情日志链接：`docs/progress/logs/2026-06-30.md`；遗留：正式 autotile / terrain 清稿、支路房间扩展审计和 MCP 桥接排障仍待后续推进。

- **Demo Art Composition audit correction**：修正关卡美术配置完成口径，并生成 DAC 整体资产配置方案。
  结果：新增 `docs/implementation-plans/2026-06-30-demo-art-composition-asset-configuration-plan.md`，明确旧 `P2=0` 只代表资源绑定 / 结构审计清零，不代表 Demo 级背景覆盖、道路连续、脚底贴合、视觉碰撞一致和路线末端安全完成。
  关键验证或结论：用户运行态截图证明普通通关测试、GUT 和 asset reference 审计不能检测资产配置合理性；后续需要 DAC-00 到 DAC-07 的运行态截图审计、背景修正、连续地形修正、碰撞 / hazard / 出口对齐和人工式 QA。
  详情日志链接：`docs/progress/logs/2026-06-30.md`；遗留：下一步先修 Stage13 entry 和五个 P3 样板房，再扩展到 Alpha Demo 主路线。

- **P1 / P2 / P3 sample art polish**：完成 UI、教程首屏和五个样板房的第一轮正式化闭环。
  结果：主菜单 / 暂停 / 失败 / 完成面板和 HUD 文案收紧；训练木桩替换为封印训练靶；教程出口红色多边形改为封印门视觉；Tutorial、Stage13 entry、Stage14 gate、Stage15 boss、Stage16 end 的主要灰盒地形视觉隐藏，TileMapLayer 承担主要地形视觉。
  关键验证或结论：Godot import 通过；Stage5 / Stage6 / Stage12 / Stage13 / Stage14 / Stage15 / Stage16 GUT `83/83` tests、`1290` asserts 通过；LL-00 审计 `P0=0 / P1=0 / P2=0`；当前文件树截图保存到 `tests/artifacts/local/p1-p3-sample-polish-2026-06-30/current_tree/`。
  详情日志链接：`docs/progress/logs/2026-06-30.md`；遗留：本轮不是全 `39` 房最终美术替换，后续进入 P4 全房间地形替换和 P5 物件 / 敌人正式化。

## 2026-06-29

- **Broad Art P2 visual replacement Pass 01-05**：完成广义美术资产管线后续运行场景 P2 视觉替换收口。
  结果：Tutorial、Stage13、Stage14、Stage15、Stage16 剩余 P2 房间补入 miasma / shrine / seal / UI 方向 asset-bound visual；新增 Stage13 / Stage14 / Stage16 资源绑定回归；`docs/implementation-plans/2026-06-29-broad-art-p2-visual-replacement-pass-01.md` 更新为 Pass 01-05 收口记录；新增 RoleMux / agy 交叉核验任务。
  关键验证或结论：Godot import 通过；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT `65/65` tests、`1035` asserts 通过；LL-00 审计从 `P0=0 / P1=0 / P2=21` 改善为 `P0=0 / P1=0 / P2=0`；Godot MCP Pro 抽样读取 Stage13 / Stage14 / Stage16 TileMap info 并保存 editor screenshot；RoleMux / agy reviewer 交叉核验 `PASS`。本轮不触发 image_gen。
  详情日志链接：`docs/progress/logs/2026-06-29.md`；遗留：当前完成口径为自动审计和第一轮抽样复核，不替代商业发布级细节审美签核。

- **Level layout LL-00 to LL-06 first execution**：完成关卡场景和地图布置第一轮执行。
  结果：新增逐房审计脚本，审计 `27` 个关键房间并生成本地报告 / 截图；`P0` 与 `P1` 清零；`stage14_air_dash_shrine_room`、`stage15_seal_guardian_boss_room`、`stage16_seal_release_threshold_room` 补 visual-only TileMapLayer；`stage16_corruption_purge_room` 补 `CorruptionMiasmaHazardArea`。
  关键验证或结论：LL-00 最终审计为 `P0=0 / P1=0 / P2=21`；Godot import 通过；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT 合计 `61/61` tests、`832` asserts 通过；Godot MCP Pro 抽样确认 Stage14 gate 的 scene tree、collision info、TileMap info 和 editor screenshot。
  详情日志链接：`docs/progress/logs/2026-06-29.md`；遗留：剩余 P2 为灰盒视觉和未接入 asset-bound visuals，后续按现有资产复用 / 批量 visual replacement 推进。

- **Level layout and map polish planning**：生成系统性关卡场景和地图布置整体计划与 LL-00 到 LL-06 分计划。
  结果：新增 `spec-design/2026-06-29-level-layout-map-polish-direction.md`、`plan/2026-06-29-level-layout-map-polish.md`、`docs/implementation-plans/2026-06-29-level-layout-map-polish-ll00-ll06.md`；明确 Godot MCP Pro 用于审计、截图、TileMap 小批调整和运行态验证，image_gen 只在真实地图资产缺口出现时触发。
  关键验证或结论：计划对齐当前 Stage16 Alpha Demo、现有 `miasma_marsh_tileset_ai01` / `shrine_trial_tileset_ai01` 资源状态、final-art polish 边界和 LL-00 到 LL-06 退出条件；本轮不改运行态场景。
  详情日志链接：`docs/progress/logs/2026-06-29.md`；遗留：下一步执行 LL-00 逐房截图审计。

## 2026-06-28

- **Tutorial attack barrier and compact HUD fix**：修复教程攻击步骤红色封印柱不可攻击解锁，以及教程 / 状态 HUD 过大和文案压框问题。
  结果：`ExitBarrier` 挂接教程专用攻击接收脚本，攻击教学阶段命中训练假人或红色封印柱均会打开出口；教程提示文案缩短，`TutorialHUD` 左右面板缩小并给九宫格装饰保留文字安全区。
  关键验证或结论：Godot MCP Pro 点击“开始”进入游戏，运行态真实 `attack` 输入命中红柱后返回 `step=exit; unlocked=true; barrier_collision_disabled=true; barrier_hit_count=1`；截图保存到 `tests/artifacts/local/tutorial-gate-ui-review/`；Stage5 GUT `8/8` 通过，Stage12 + Stage16 GUT `23/23` 通过。
  详情日志链接：`docs/progress/logs/2026-06-28.md`；遗留：本轮只修教程卡点和明显 HUD 越界，不替代发布级 HUD 重设计和 typography。

- **Godot MCP Pro full UI smoke and layout cleanup**：完成 Godot MCP Pro 运行态 UI / 主流程 smoke，并修复明显布局问题。
  结果：通过 MCP 启动主场景、点击开始、打开暂停、临时显示完成面板并截图；教程提示字号降为 `15`，避免明显裁切；暂停菜单加高，`PausePanelArt` / `CompletionPanelArt` 默认隐藏但保留资源引用，避免候选面板图与九宫格面板叠加产生破碎边缘。
  关键验证或结论：MCP 截图保存到 `tests/artifacts/local/mcp-full-game-review/`；MCP 压力输入 5 秒发送 `294` 个事件，未崩溃、无新错误；Stage1 / Stage2 / Stage5 / Stage12 / Stage14 / Stage16 GUT 合计 `62/62` tests、`727` asserts 通过。
  详情日志链接：`docs/progress/logs/2026-06-28.md`；遗留：本轮只处理明显 UI 布局问题，不替代发布级 UI 清稿和 typography。

- **Tutorial placeholder cleanup and jump step fix**：修复玩家旧占位视觉与正式 Luna 动画叠加，并调整教程第一跳平台可达性和下方通行。
  结果：玩家场景保留旧 `Body` / Stage12 / readability 节点作为历史资产和测试契约，但默认隐藏；运行态只显示正式 `LunaRuntimeAnimationVisual`。`JumpGuidePlatform` 调整为 `Vector2(-144, 84)`，玩家 `jump_velocity` 调整为 `-420.0`，教程 `move_jump_goal_y` 调整为 `64.0`，让玩家能从平台下方通过，也能跳到平台上方推进 dash 教程；`project.godot` 恢复 `640x360` 基准 viewport 与 `1280x720` 窗口契约。
  关键验证或结论：Stage1 GUT 通过，确认显示缩放契约；Stage5 GUT 包含真实物理跳跃和平台下方通行回归；Stage12 / Stage14 GUT 通过；运行态截图确认旧蓝色身体块和黄色头标不再覆盖 Luna。
  详情日志链接：`docs/progress/logs/2026-06-28.md`；遗留：本轮不改变玩家全局跳跃手感，后续如重做地形表现应继续用真实物理回归保护可达性。

- **DemoShell start UI fix**：修复开始界面错位和开始后标题背景遮挡游戏的问题。
  结果：`TitleBackground` 现在只在主菜单显示，点击开始 / 重开进入运行态后隐藏；主菜单面板加宽并调整标题、状态文案、开始按钮和装饰图位置；新增 Stage16 回归测试和运行态截图复核脚本。
  关键验证或结论：Stage16 GUT 通过 `14/14`、`137` asserts；`capture_demo_shell_start_review.gd` 通过并输出主菜单 / 开始后截图和 JSON 报告，确认开始后标题背景和主菜单均隐藏且玩家实例存在。
  详情日志链接：`docs/progress/logs/2026-06-28.md`；遗留：完整发布级 UI typography / 按钮状态 / 动效仍属于后续 polish。

## 2026-06-27

- **Batch 04 full audio prompt reference**：完成全量音频资产族生成参考文档。
  结果：`docs/assets/audio-asset-prompt-reference.md` 从 Stage16 最小音频包扩展为全量参考，覆盖角色动作、战斗、UI、环境 / 氛围、物品交互、古代机关 / 机械、怪物 / NPC、BGM、语音、系统反馈和音频配置资产；同步 `asset-production-roadmap.md`、`asset-generation-brief.md` 与 `asset-manifest.md`。
  关键验证或结论：文档对齐 `assets/source/ai_generated/batch_04/audio/` 原始候选路径、`assets/audio/sfx/`、`assets/audio/ambient/`、`assets/audio/voice/`、`assets/audio/music/` 与 `assets/audio/config/` 目标路径，并提供 PowerShell 建目录、`ffmpeg` 转 OGG / 响度统一和 Godot import 命令；本轮不生成实际音频、不接入运行时代码。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；参考文档：`docs/assets/audio-asset-prompt-reference.md`；遗留：真实生成前需确认工具授权，接入时再补 AudioStreamPlayer / 音量策略 / 运行态验证。

- **Final Art Polish FP-05 animation / VFX audit and completion**：完成动作帧 / VFX 第一轮最终复核，并通过 FP-01 到 FP-05 完成审计。
  结果：新增 `scripts/assets/audit_final_art_polish_fp05_animation_vfx.py`、`scripts/assets/audit_final_art_polish_completion.py` 和对应 `docs/assets/final-art-polish-fp05-animation-vfx-report.*`、`docs/assets/final-art-polish-completion-audit-report.*`；active animation candidates 为 `15/15 active ready`，VFX rules 为 `7 assets / 86 frame rules`，animation rules 为 `8 assets / 172 frame rules`。
  关键验证或结论：Luna attack / Air Dash、Seal Guardian attack VFX、enemy hit spark 四个运行态截图复核均通过；Stage14 / Stage15 GUT 分别通过 `15/15`、`14/14`；最终完成审计通过 `5/5 FP batches, 2/2 final gates, 0 errors`。本轮 FP-01 到 FP-05 均没有触发 image_gen 重生成。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；报告：`docs/assets/final-art-polish-fp05-animation-vfx-report.md`、`docs/assets/final-art-polish-completion-audit-report.md`；遗留：商业发布级手工清稿、最终 typography、正式 autotile / hazard Area author 和完整人工审美签核仍属于后续 polish。

- **Final Art Polish FP-04 UI small readability audit**：完成 UI / NinePatch / HUD 小尺寸第一轮自动审计。
  结果：新增 `scripts/assets/audit_final_art_polish_fp04_ui_small_readability.py` 和 `docs/assets/final-art-polish-fp04-ui-small-readability-report.*`；`menu_ninepatch_ui_ai01` 的 `8` 个 StyleBoxTexture、`9` 个 Theme mappings、DemoShell / TutorialHUD runtime references、`4` 个 standalone UI panel rules、`2` 个小图标源图与 `3` 个 UI atlas regions 均通过结构和引用审计。
  关键验证或结论：FP-04 审计通过，输出 `0 errors, 0 warnings`；editor StyleBox、editor UI skin 与 runtime UI skin binding 三个 Godot 审计通过；Stage12 / Stage14 / Stage15 / Stage16 GUT 分别通过 `9/9`、`15/15`、`14/14`、`13/13`；asset package strict 与 art readiness strict 通过。本轮没有发现必须进入 P2 重生图的 UI / HUD 失败项。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；报告：`docs/assets/final-art-polish-fp04-ui-small-readability-report.md`；遗留：不替代最终伪文字清理、字体排版和人工审美；下一步进入 FP-05 动作帧和 VFX 最终复核。

- **Final Art Polish FP-03 TileSet semantics audit**：完成 TileSet 语义和 collision 第一轮自动审计。
  结果：新增 `scripts/assets/audit_final_art_polish_fp03_tileset_semantics.py` 和 `docs/assets/final-art-polish-fp03-tileset-review-report.*`；`miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 均为 `tileset_semantics_ready`。
  关键验证或结论：FP-03 审计通过，输出 `2/2 ready, 0 errors, 0 warnings`；Godot TileSet audit 通过 `Editor TileSet resources OK: 2`；Stage13 GUT 通过 `9/9` 与 `1/1`，Stage14 GUT 通过 `15/15`；asset package strict 与 art readiness strict 通过。本轮没有发现必须进入 P2 重生图的 TileSet 失败项。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；报告：`docs/assets/final-art-polish-fp03-tileset-review-report.md`；遗留：正式 runtime TileMap 替换前仍需人工边缘拟合、autotile / terrain 复核和 hazard damage Area author；下一步进入 FP-04 UI / NinePatch / HUD 小尺寸复核。

- **Final Art Polish FP-02 atlas split audit**：完成 atlas / 大图语义拆分第一轮自动审计。
  结果：新增 `scripts/assets/audit_final_art_polish_fp02_atlas_split.py` 和 `docs/assets/final-art-polish-fp02-atlas-split-report.*`；`shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01`、`material_texture_atlas_ai01` 均为 `split_ready`；`reusable_seal_props_ai01` 明确为 `standalone_preview_ready`。
  关键验证或结论：FP-02 审计通过，输出 `3 split-ready atlases, 1 standalone preview-ready sheets, 0 errors`；asset package strict 与 art readiness strict 通过。本轮没有发现必须进入 P2 重生图的 atlas 失败项。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；报告：`docs/assets/final-art-polish-fp02-atlas-split-report.md`；遗留：下一步进入 FP-03 TileSet 语义和 collision 复核。

- **Final Art Polish FP-01 runtime readability smoke**：完成最终美术精修第一批运行态读值截图 / JSON 复核。
  结果：新增 `scripts/dev/capture_final_art_polish_fp01_review.gd`；对 Stage13 entry、Stage14 shrine、Stage14 gate、Stage15 Boss room、Stage16 seal release threshold 保存本地截图和 JSON 报告，确认目标 visual preview 节点可见、资源和 `asset_id` 正确，且没有误挂 Area / Collision 子节点。
  关键验证或结论：capture 脚本通过；Stage13 / Stage14 / Stage15 / Stage16 GUT 分别通过 `9/9`、`15/15`、`14/14`、`13/13`；asset runtime map strict 与 asset package strict 通过。本轮没有发现必须进入 P2 重生图的失败项。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；实施计划：`docs/implementation-plans/2026-06-27-final-art-polish-execution-order.md`；遗留：下一步进入 FP-02 atlas / 大图语义拆分精修。

- **Remaining Art Asset Pipeline P0 / P1 收束**：处理剩余美术资产管线的第一轮证据链和已接入资源验证。
  结果：资产包 / provenance / source safety 审计已区分 Git 可重放资产包与 ordinary Git 外 raw candidate 原始证据；promo / CG / storyboard opaque preview evidence 已重建；13 个环境 / TileSet / 材质 / prop atlas 条目以 visual preview 接入目标场景；runtime integration map 已推进为 `55/55 scene_reference_verified`；P2 未触发，本轮没有新增 image_gen 输出；后续动作帧生成规则锁定为透明背景、标准规则网格、固定格子、角色比例 / 视角 / 根部锚点稳定的单动作 sprite sheet。
  关键验证或结论：asset provenance strict 通过 `55 records, 133 candidate hashes, 55 output hashes`；imagegen source safety strict 通过 `133 candidates, 0 unsafe`；final art acceptance gates strict 通过 `55 assets, 0 blocked assets, 55 final-ready assets`；asset runtime map strict 通过；asset package strict 通过；Godot import 通过；TileSet editor audit 通过 `Editor TileSet resources OK: 2`；Stage13 / Stage14 / Stage15 / Stage16 GUT 分别通过 `9/9`、`15/15`、`14/14`、`13/13`。
  详情日志链接：`docs/progress/logs/2026-06-27.md`；实施计划：`docs/implementation-plans/2026-06-27-remaining-art-asset-pipeline-plan.md`；遗留：后续仍需按资产族做遮挡复核、TileSet 语义 / collision 复核、atlas 拆区和运行态截图读值检查。

## 2026-06-24

- **Animation Runtime Replacement Pass ARP-19 Enemy hit spark runtime VFX binding**：把普通敌人受击 spark 从 Stage12 占位迁移到独立 runtime VFX visual。
  结果：新增 `enemy_hit_spark_vfx_runtime_ai01.spriteframes.tres`；`basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn`、`miasma_caster_enemy.tscn` 均新增 `EnemyHitSparkVfxVisual`；旧 `Stage12HitSpark` 仅保留为 hidden fallback。
  关键验证或结论：Godot import 通过；Stage12 GUT `9/9 passed`、`147` asserts；Stage15 GUT `14/14 passed`、`267` asserts；`capture_enemy_hit_spark_vfx_review.gd` 写出本地截图和 JSON 报告，确认基础敌人受击时 runtime VFX 可见、resource / metadata OK 且无 Area / Collision 子节点。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换普通敌人受击闪视觉，不改变 `receive_attack()`、击败契约、hurtbox、collision、defeated 信号或敌人 AI。

- **Animation Runtime Replacement Pass ARP-18 Luna attack slash / seal arc VFX runtime binding**：把 Luna 攻击表现从旧 Stage12 单张 SVG 预览，推进到 clean attack body + 独立 slash VFX + 独立 seal arc VFX 三层运行态视觉。
  结果：新增 `luna_attack_slash_vfx_runtime_ai01.spriteframes.tres` 与 `luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres`，分别引用 `vfx_combat_atlas_ai01` slash 段与 `vfx_seal_magic_atlas_ai01` seal burst 段；玩家攻击起手播放两个 VFX，攻击结束 / 受击 / 恢复时隐藏；旧 `Stage12SlashPreview` 保留为 legacy hidden preview。
  关键验证或结论：Godot import 通过；Stage14 GUT `15/15 passed`、`274` asserts；`capture_luna_attack_vfx_review.gd` 写出本地截图和 JSON 报告，确认玩家处于 `attack`、body / slash / seal arc 均可见、旧 Stage12 SVG 隐藏、两个 VFX resource / metadata OK 且无 Area / Collision 子节点。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Luna 攻击 VFX visual，不改变攻击时序、hitbox / hurtbox、伤害窗口、取消窗口、恢复充能或敌人受击逻辑。

- **Animation Runtime Replacement Pass ARP-17 active candidate / archived reference audit split**：把动作替换候选审计从混合 `candidate / reference` 数字拆成活跃 runtime candidates 与归档 references。
  结果：`docs/assets/animation-runtime-replacement-candidates.json` 中 8 个历史失败稿 / 已替代参考保留为 `archived_*` 或 `superseded_reference`，并声明 `superseded_by`；`audit_animation_runtime_replacement.py` 默认 strict gate 只阻塞活跃候选，同时验证归档参考的替代资产存在。
  关键验证或结论：candidate strict audit 通过 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`；这证明当前活跃 runtime sheet 几何 / 资源门禁已清零，不代表完整商业动作库或所有后续状态动画已完成。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只修正审计门禁与清单状态，不改变玩家、敌人、Boss 或 VFX 的 runtime 引用。

- **Animation Runtime Replacement Pass ARP-16 Luna Air Dash trail VFX runtime binding**：把 `stage14_air_dash_trail_ai01` 接入玩家 `dash` 状态的纯视觉拖尾层，并完成第一轮本地运行态截图复核。
  结果：`player_placeholder.gd` 新增 Air Dash trail 同步；`AirDashTrailArt` 只在 `STATE_DASH` 显示，跟随朝向位于角色身后，metadata 显式 `gameplay_collision=false` 与 `damage_source=false`；clean body 仍由 `luna_air_dash_body_runtime_sheet_ai02` 承担。
  关键验证或结论：Stage14 GUT `15/15 passed`、`225` asserts；`capture_luna_air_dash_vfx_review.gd` 写出本地截图和 JSON 报告，确认玩家处于 `dash`、clean body / trail 均可见、trail resource / metadata OK 且无 Area / Collision 子节点；本轮不新增角色动作候选，candidate / reference audit 保持 `16/23 ready, 7 blocked`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只绑定 Air Dash trail visual，不改变 dash 物理、能力消耗 / 恢复、碰撞、hurtbox / hitbox 或门控；后续仍可继续 polish mask / blend / alpha。

- **Animation Runtime Replacement Pass ARP-15 Seal Guardian attack VFX runtime binding**：把 `seal_guardian_attack_vfx_atlas_ai01` 接入 Seal Guardian `ground_impact` / `air_punish` 的纯视觉 VFX 层，并完成第一轮本地运行态截图复核。
  结果：`seal_guardian_boss.tscn` 新增 `SealGuardianAttackVfxVisual`；`seal_guardian_boss.gd` 按 Boss 攻击状态显示 `boss_attack_vfx`，非攻击状态隐藏；VFX 节点 metadata 继续显式 `gameplay_collision=false` 与 `damage_source=false`；运行态复核后把 VFX 下移到接近 Boss origin 并置于 body 后方，降低遮挡。
  关键验证或结论：VFX rules audit 通过 `7 assets, 86 frame rules`；asset package audit 通过；Godot import 通过；Stage15 GUT `14/14 passed`、`267` asserts；Stage14 GUT `15/15 passed`、`211` asserts；`capture_animation_runtime_replacement_review.gd` 写出本地截图和 JSON 报告，确认 Boss 处于 `ground_impact`、body / VFX 均可见、VFX resource / metadata OK 且无 Area / Collision 子节点；candidate / reference audit 保持 `16/23 ready, 7 blocked`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只绑定 Boss attack VFX visual，不改变 AttackArea、真实伤害、碰撞、hurtbox / hitbox、Boss AI 或房间流程；后续仍可继续 polish VFX 亮度、blend 和节奏。

- **Animation Runtime Replacement Pass ARP-14 Seal Guardian attack body AI02 runtime binding**：用内置 `image_gen` 重新生成 clean Boss attack body，并接入 Seal Guardian `ground_impact` / `air_punish` runtime visual。
  结果：新增 `imagegen_seal_guardian_attack_body_clean_source_ai02.png`、`seal_guardian_attack_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `16/23 ready, 7 blocked`；旧 Boss attack / attack body 候选继续作为 blocked references。
  关键验证或结论：Godot import 通过；Stage15 GUT `14/14 passed`、`244` asserts；Stage14 GUT `15/15 passed`、`211` asserts；asset package audit 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Boss attack body visual，不改变 Boss 攻击时序、AttackArea、伤害窗口、hurtbox / hitbox、AI 或房间流程。

- **Animation Runtime Replacement Pass ARP-13 Luna air dash body AI02 runtime binding**：用内置 `image_gen` 重新生成 clean Air Dash body，并接入玩家 `dash` runtime visual。
  结果：新增 `imagegen_luna_air_dash_body_clean_source_ai02.png`、`luna_air_dash_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `15/22 ready, 7 blocked`；旧 `luna_air_dash_runtime_sheet_ai01` 因 baked cyan energy / trail 继续作为 reference，不接 live dash。
  关键验证或结论：Godot import 通过；Stage14 GUT `15/15 passed`、`211` asserts；Stage15 GUT `14/14 passed`、`239` asserts；asset package audit 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 dash body visual，不改变 dash 速度、持续时间、冷却、Air Dash 消耗 / 恢复、碰撞、hurtbox / hitbox 或能力门控。

- **Animation Runtime Replacement Pass ARP-12 Luna hit / death runtime binding**：把已通过几何审查的 Luna `hit_react` 与 `death_idle` 短 clip 接入玩家受击 / 死亡运行时视觉层。
  结果：`player_placeholder.gd` 在非致命 `receive_damage()` 后切到 `luna_hit_react_runtime_sheet_ai01`，在 defeated 状态优先切到 `luna_death_idle_runtime_sheet_ai01`；恢复满血后退出 death / hit visual。
  关键验证或结论：Godot import 通过；Stage14 GUT `14/14 passed`、`202` asserts；Stage15 GUT `14/14 passed`、`239` asserts；candidate audit 保持 `14/21 ready, 7 blocked`，因为本轮接入既有 ready clips。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换受击 / 死亡视觉层，不改变扣血、无敌、击退、defeated signal、checkpoint、hurtbox / hitbox 或 HUD 逻辑。

- **Animation Runtime Replacement Pass ARP-11 Luna attack body AI02 runtime binding**：用内置 `image_gen` 重新生成 Luna 干净攻击身体层，并接入玩家 `attack` / `air_attack` runtime visual。
  结果：新增 `imagegen_luna_attack_body_clean_source_ai02.png`、`luna_attack_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `14/21 ready, 7 blocked`；旧 `luna_attack_body_runtime_sheet_ai01` 继续作为 blocked reference。
  关键验证或结论：Godot import 通过；Stage14 GUT `13/13 passed`、`184` asserts；strict candidate audit 仍按预期失败 `14/21 ready, 7 blocked`，因为其他旧 blocker 仍保留。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Luna attack body 视觉层，不改变攻击判定、slash VFX、hitbox / hurtbox 或伤害窗口。

- **Animation Runtime Replacement Pass ARP-10 enemy core runtime binding**：把四个普通敌人单体 runtime clips 接入对应场景的可见视觉层。
  结果：`basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn` 与 `miasma_caster_enemy.tscn` 均新增 `EnemyRuntimeAnimationVisual`；`BaseEnemy.receive_attack()` 在敌人清除时隐藏 runtime visual。
  关键验证或结论：Godot import 通过；Stage15 GUT `14/14 passed`、`239` asserts；candidate / reference audit 仍保留 `13/20 ready, 7 blocked`，其中 `enemies_core_runtime_sheet_ai01` 继续作为 blocked roster reference。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换普通敌人视觉层，不改变 AI、伤害、碰撞或多状态动画时序。

- **Animation Runtime Replacement Pass ARP-09 Seal Guardian runtime binding**：把通过几何审查的 Boss `idle`、`warning` 与 `defeat` 三段动作接入可见运行态动作层。
  结果：`seal_guardian_boss.tscn` 新增 `SealGuardianRuntimeAnimationVisual`；`seal_guardian_boss.gd` 按 `idle` / `close_pressure` / `defeated` 切换 runtime SpriteFrames；攻击和硬直状态继续隐藏该 visual，避免误用 blocked Boss attack frames。
  关键验证或结论：Godot import 通过；Stage15 GUT `13/13 passed`、`184` asserts；candidate / reference strict audit 仍按预期为 `13/20 ready, 7 blocked`，Boss attack body 仍需重新生成或人工清稿。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 Boss 三段非攻击动作 live visual binding，不是 Boss attack 正式替换。

- **Animation Runtime Replacement Pass ARP-08 Seal Guardian attack VFX rules**：为 ARP-07 拆出的 `seal_guardian_attack_vfx_atlas_ai01` 补 first-pass VFX rule sidecar 和索引。
  结果：新增 `assets/art/vfx/vfx_rules/seal_guardian_attack_vfx_atlas_ai01.vfx_rules.json`；`vfx_rules.index.json` 更新为 `7 assets / 86 frame rules`；`audit_asset_package.py` 的 VFX rules 数量校验改为读取索引预期。
  关键验证或结论：`audit_vfx_rules.py --strict` 通过，`7 assets, 86 frame rules`；综合资产包审计通过并重写 `asset-package-audit-report.json`，记录 `86 VFX rules`；所有新增 VFX rule 都显式禁用 gameplay collision 与 damage source。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 VFX anchor / blend / no-damage 规则层，不是 Boss attack live binding。

- **Animation Runtime Replacement Pass ARP-07 Seal Guardian attack VFX split attempt**：尝试把 blocked Boss attack 拆成身体层和独立地面冲击 VFX atlas。
  结果：新增 `seal_guardian_attack_body_runtime_sheet_ai01` 和 `seal_guardian_attack_vfx_atlas_ai01`；VFX atlas 放入 `assets/art/vfx/atlases/`，不参与角色动作 ready 数字；attack body 因残留上方 cyan slash、底部清理洞和 detached fragments 标记为 blocked reference。
  关键验证或结论：ARP-07 构建 `2 assets, 16 frames`；candidate / reference audit 当前为 `13/20 ready, 7 blocked`；Godot import 通过并重新导入 Boss attack body PNG 与 attack VFX atlas PNG；当前 Boss attack 仍需重新生成或人工清稿，不能 live binding。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 VFX 分层尝试和失败样本留痕，不是 Boss attack 正式替换完成。

- **Animation Runtime Replacement Pass ARP-06 Seal Guardian Boss split candidates**：把 `seal_guardian_boss_runtime_sheet_ai01` 从 Boss 多动作串联 sheet 误用风险中分离出来，拆成 Boss `idle`、`warning`、`attack` 与 `defeat` 短 clip。
  结果：`seal_guardian_boss_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；新增四个 Boss split runtime PNG、frames JSON、SpriteFrames 和 source records；`seal_guardian_attack_runtime_sheet_ai01` 因 cyan ground slash / impact VFX 烘在攻击帧里，也标记为 blocked reference。
  关键验证或结论：Boss split 构建 `4 assets, 20 frames`；candidate / reference audit 当前为 `13/19 ready, 6 blocked`；Godot import 通过并重新导入 4 张 Boss split PNG；Boss `idle`、`warning`、`defeat` 只批准为 geometry-ready candidates，尚未替换 live Boss room 或状态机。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 Boss 候选池治理和动作短 clip 准备，不是 Stage15 Boss 正式动画替换。

- **Animation Runtime Replacement Pass ARP-05 enemy core split candidates**：把 `enemies_core_runtime_sheet_ai01` 从多敌人 roster 误用风险中分离出来，拆成四个单敌人 runtime candidates。
  结果：`enemies_core_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；新增 `enemy_basic_melee_runtime_sheet_ai01`、`enemy_ground_charger_runtime_sheet_ai01`、`enemy_aerial_sentinel_runtime_sheet_ai01` 与 `enemy_miasma_caster_runtime_sheet_ai01` 的 runtime PNG、frames JSON、SpriteFrames 和 source records；`build_animation_runtime_split_candidates.py` 支持 per-spec 输出目录与 `--only`。
  关键验证或结论：enemy split 构建 `4 assets, 32 frames`；candidate / reference audit 当前为 `11/15 ready, 4 blocked`；Godot import 通过并重新导入 6 张相关 PNG；四个单敌人 clip 只批准为 geometry-ready candidates，尚未替换 live enemy animation、AI 状态机、攻击窗口或 hurtbox。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是敌人候选池治理和单体 clip 准备，不是敌人场景正式替换。

- **Animation Runtime Replacement Pass ARP-04 split correction**：根据用户截图复核，撤回 `luna_attack_body_runtime_sheet_ai01` 的 ready 口径，并把相邻帧残片 / baked slash debris 纳入正式审计门槛。
  结果：新增 `scripts/assets/build_animation_runtime_split_candidates.py`；拆出 `luna_attack_body_runtime_sheet_ai01`、`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01`；`luna_attack_body_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；`audit_animation_runtime_replacement.py` 新增 `detached_frame_fragments` 与 `blocked_candidate_reference` gate。
  关键验证或结论：split 构建 `3 assets, 28 frames`；candidate / reference strict audit 当前为 `6/9 ready, 3 blocked`；`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01` 几何审计通过但未接 live hit/death；`attack_body` 需要重新生成或从干净逐帧源重切。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是人工复核修正和候选池治理，不新增 live attack / hit / death 替换。

- **Animation Runtime Replacement Pass ARP-03 Luna attack / hit-death blocked candidates**：继续从现有 final-ready source 派生 Luna attack 与 hit/death 的 runtime-normalized candidates，但用 strict audit 阻止它们误入 live controller。
  结果：新增 `luna_attack_01_runtime_sheet_ai01` 与 `luna_hit_death_runtime_sheet_ai01` 的 runtime PNG、frames JSON、SpriteFrames 和 source records；candidate manifest 扩展到 `6` 个候选；Godot import 可正常导入两个 blocked candidates。
  关键验证或结论：ARP-03 构建 `2 assets, 40 frames`；candidate strict audit 当前 `4/6 ready, 2 blocked`；两个新候选均被 `unstable_content_scale` 阻止。attack 还存在 slash / cyan arc 烘入角色帧的问题；hit/death 站立受击到倒地跨度过大，不适合作为单个正式运行时 clip 直接替换。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：不接 live attack、air attack、hit reaction 或 death 状态；后续需要拆独立 attack VFX，并把 hit/death 拆成更稳定的语义 clips。

- **Animation Runtime Replacement Pass ARP-02 Luna jump/fall runtime binding**：继续从现有 final-ready source 派生 Luna jump/fall 与 air dash 的 runtime-normalized 候选，并把通过审计的 jump/fall 接入玩家可见运行时动画节点。
  结果：`scripts/assets/build_animation_runtime_candidates.py` 支持 `--pass-id` 与 `--merge-existing`；`docs/assets/animation-runtime-replacement-candidates.json` 扩展到 `4` 个候选；新增 jump/fall 与 air dash runtime PNG、frames JSON、SpriteFrames 和 source records；`scripts/player/player_placeholder.gd` 根据 `current_state` 在 `jump_rise` / `jump_fall` 状态切换到 `luna_jump_fall_runtime_sheet_ai01`。
  关键验证或结论：ARP-02 构建 `2 assets, 38 frames`；candidate strict audit 当前 `4/4 ready, 0 blocked`；`luna_jump_fall_runtime_sheet_ai01` 最小边距 `left=24, top=40, right=24, bottom=8`、脚底基线漂移 `1`；`luna_air_dash_runtime_sheet_ai01` 去除 2 个 duplicate frames，最小边距 `left=24, top=35, right=24, bottom=8`、脚底基线漂移 `0`；Godot import 通过；Stage14 GUT `12/12 passed`、`176` asserts。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只正式替换 Luna jump/fall 运行时视觉层；air dash 目前只批准为 geometry-ready candidate，未接 live dash，仍需复核与独立 `AirDashTrailArt` 的 VFX 分层关系。

- **Animation Runtime Replacement Pass ARP-01 Luna idle / run runtime binding**：从现有 final-ready source 派生 Luna idle / run 的 runtime-normalized 候选，并把通过严格审计的两个候选接入玩家可见运行时动画节点。
  结果：新增 `scripts/assets/build_animation_runtime_candidates.py`、`docs/assets/animation-runtime-replacement-candidates.json`、candidate audit 报告，以及 `assets/art/characters/player/sprite_sheets/runtime_replacement/` 下的 idle / run PNG、frames JSON、SpriteFrames 和 source records；`scenes/player/player_placeholder.tscn` 新增 `LunaRuntimeAnimationVisual`；`scripts/player/player_placeholder.gd` 根据 `current_state` 切换 idle / run runtime SpriteFrames。
  关键验证或结论：候选构建 `2 assets, 37 frames`；candidate strict audit 为 `2/2 ready, 0 blocked`；`luna_idle_runtime_sheet_ai01` 最小边距 `left=36, top=8, right=36, bottom=8`、脚底基线漂移 `0`；`luna_run_runtime_sheet_ai01` 移除 3 个 exact duplicate frames，最小边距 `left=16, top=18, right=16, bottom=8`、脚底基线漂移 `0`；Godot import 通过；Stage14 GUT `12/12 passed`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只正式替换 Luna idle / run 运行时视觉层；跳跃、攻击、dash、受击、敌人和 Boss 动作仍未达到正式替换标准。

- **Animation Runtime Replacement Pass ARP-00 audit gate**：启动动作正式替换批次，把当前 hidden/runtime animation preview 资产升级到 formal runtime replacement 审计标准。
  结果：新增 `scripts/assets/audit_animation_runtime_replacement.py`、`docs/assets/animation-runtime-replacement-audit-report.json` / `.md`、`spec-design/2026-06-24-animation-runtime-replacement-pass.md` 与 `docs/implementation-plans/2026-06-24-animation-runtime-replacement-pass.md`；当前 8 张角色 / 敌人 / Boss animation sheets 均被阻止直接替换 live controller。
  关键验证或结论：Animation runtime replacement audit `0/8 ready, 8 blocked`；`audit_animation_runtime_replacement.py --strict` 按预期失败；`audit_animation_rules.py --strict` 仍通过 `8 assets, 172 frame rules`，说明现有 rules 可审计但不足以证明正式替换。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只建立正式替换门槛和 blocker 报告，不替换 live player / enemy / Boss controller 动画。

- **P2 final-ready mini pack 26**：将 `capsule_art_alpha_demo_ai01`、`cg_seal_guardian_reveal_ai01`、`nano_hunter_logo_direction_ai01`、`promo_key_art_sheet_ai01`、`storyboard_intro_bounty_ai01`、`storyboard_miasma_marsh_ai01` 与 `storyboard_narrative_sheet_ai01` 推进为当前 Alpha Demo presentation / promo / narrative direction source。
  结果：不新增图片生成；复核既有 image_gen promo / logo / CG / storyboard outputs；生成 P2 promo / story contact sheet；扩展 finalization review records；final-art queue 刷新为 `0` 个 manual-review entries、`55` 个 final-ready assets；Pass 02 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `55/55 approved final-ready records`；Art readiness `55/55 structural ready, 55/55 final ready`；final acceptance gates `0 blocked assets, 55 final-ready assets`；asset package audit 通过并记录 `55 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 55 final-ready`；final-art workbench `55 cards, 0 manual-review assets, 55 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 direction source，不批准最终 logo 字体、平台裁切、公开营销图、商店页素材、最终剧情脚本、对白、本地化、过场成片或发布级 CG。

- **P1 final-ready mini pack 25**：将 `equipment_pickup_atlas_ai01`、`reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01` 与 `material_texture_atlas_ai01` 推进为当前 Alpha Demo source atlas / prop source / material reference source。
  结果：不新增图片生成；复核既有 image_gen equipment / pickup atlas、shrine / gate prop atlas、reusable seal prop sheet 和 material texture atlas；生成 P1 props / texture contact sheet；扩展 finalization review records；final-art queue 刷新为 `7` 个 manual-review entries、`48` 个 final-ready assets；P0 / P1 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `48/48 approved final-ready records`；Art readiness `55/55 structural ready, 48/55 final ready`；final acceptance gates `7 blocked assets, 48 final-ready assets`，blocked by priority 为 P2 `7`；asset package audit 通过并记录 `48 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 48 final-ready`；final-art workbench `55 cards, 7 manual-review assets, 48 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 source atlas / prop source / material reference source，不批准最终 pickup 逻辑、reward balance、shrine / gate 状态机、collision、room placement、runtime scale、无缝贴图、shader/material binding 或 terrain replacement。

- **P1 final-ready mini pack 24**：将 `biome01_air_dash_shrine_room_ai01`、`biome01_shrine_trial_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome02_miasma_hazard_room_ai01`、`biome02_miasma_marsh_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01` 与 `stage15_seal_guardian_boss_room_ai01` 推进为当前 Alpha Demo environment visual source / editor TileSet source。
  结果：不新增图片生成；复核既有 image_gen 环境背景、房间图、tile visual pass 和两套 TileSet source；扩展 finalization review records；final-art queue 刷新为 `11` 个 manual-review entries、`44` 个 final-ready assets；P0 blocked assets 继续保持清零。
  关键验证或结论：Asset finalization reviews `44/44 approved final-ready records`；Art readiness `55/55 structural ready, 44/55 final ready`；final acceptance gates `11 blocked assets, 44 final-ready assets`，blocked by priority 为 P1 `4`、P2 `7`；asset package audit 通过并记录 `44 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 44 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 environment visual source / editor TileSet source，不批准最终 autotile、collision polygon、hazard damage Area、navigation、occlusion、完整 parallax split、全场景替换或商业级背景清稿。

- **P0 final-ready mini pack 23**：将 `seal_guardian_spine_parts_ai01` 从 structural-ready Spine 拆件图集，推进为当前 Alpha Demo 后续 rigging handoff 的 Seal Guardian Spine-style cutout source / export package。
  结果：复核既有 image_gen `24` part atlas、frames / regions metadata、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 与总索引；扩展 finalization review records；final-art queue 刷新为 `21` 个 manual-review entries、`34` 个 final-ready assets；P0 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `34/34 approved final-ready records`；Art readiness `55/55 structural ready, 34/55 final ready`；final acceptance gates `21 blocked assets, 34 final-ready assets`，blocked by priority 为 P1 `14`、P2 `7`；asset package audit 通过并记录 `34 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 34 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 future rigging handoff cutout source，不批准正式 Spine rig、Skeleton2D / Bone2D 绑定、运行时动画替换、Boss 状态机时序、hitbox / hurtbox、damage window、公开 sprite source、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 22**：将 `luna_spine_parts_ai01` 从 structural-ready Spine 拆件图集，推进为当前 Alpha Demo 后续 rigging handoff 的 Luna Spine-style cutout source / export package。
  结果：复核既有 image_gen `24` part atlas、regions、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 与总索引；扩展 finalization review records；final-art queue 刷新为 `22` 个 manual-review entries、`33` 个 final-ready assets；剩余 P0 只剩 `seal_guardian_spine_parts_ai01`。
  关键验证或结论：Asset finalization reviews `33/33 approved final-ready records`；Art readiness `55/55 structural ready, 33/55 final ready`；final acceptance gates `22 blocked assets, 33 final-ready assets`；asset package audit 通过并记录 `33 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 33 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过；Godot import 通过；final-art workbench `55 cards, 22 manual-review assets, 33 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 future rigging handoff cutout source，不批准正式 Spine rig、Skeleton2D / Bone2D 绑定、运行时动画替换、hitbox / hurtbox、攻击时序、公开 sprite source、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 21**：将 `enemies_core_sheet_ai01` 从旧版跨格 VFX、错误最终格和 duplicate fallback 风险的 core enemies sheet，推进为当前 Alpha Demo hidden/runtime core enemy roster animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_06`；按项目管线抽取 `32/32` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；基础近战敌人场景新增隐藏 `EnemiesCoreAnimationPreview` 引用；扩展 finalization review records；final-art queue 刷新为 `23` 个 manual-review entries、`32` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `32/32 approved final-ready records`；ImageGen candidate pool `133 candidates, 102 unselected candidates`；Asset provenance `55 records, 133 candidate hashes, 55 output hashes`；ImageGen source safety `133 candidates, 0 unsafe`；Runtime source safety `30 runtime assets, 18 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 32/55 final ready`；final acceptance gates `23 blocked assets, 32 final-ready assets`；asset package audit 通过并记录 `32 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 32 final-ready`；candidate review gallery `102 candidates, 55 assets`；final-art workbench `55 cards, 23 manual-review assets, 32 final-ready assets`；runtime source workbench `18 assets, 72 candidates`；P0 runtime rehearsal `30 nodes`；Godot import 通过；Stage15 GUT `12/12`、`156` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime core enemy roster animation preview，不批准正式敌人 AI 动画替换、攻击判定、hurtbox / hitbox、逐敌人状态机、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 20**：将 `luna_hit_death_sheet_ai01` 从旧版混合比例、残留绿边和动作不连续的 hit/death sheet，推进为当前 Alpha Demo hidden/runtime Luna hit/death animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_04`；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；玩家场景新增隐藏 `LunaHitDeathAnimationPreview` 引用；扩展 finalization review records；final-art queue 刷新为 `24` 个 manual-review entries、`31` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `31/31 approved final-ready records`；ImageGen candidate pool `131 candidates, 99 unselected candidates`；Asset provenance `55 records, 131 candidate hashes, 55 output hashes`；ImageGen source safety `131 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 31/55 final ready`；final acceptance gates `24 blocked assets, 31 final-ready assets`；asset package audit 通过并记录 `31 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 31 final-ready`；candidate review gallery `99 candidates, 55 assets`；final-art workbench `55 cards, 24 manual-review assets, 31 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、`149` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna hit/death animation preview，不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、受击无敌时序、失败 / 重开逻辑、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 19**：将 `seal_guardian_boss_sheet_ai01` 从旧版混合四足兽 / 人形守卫 sheet，推进为当前 Alpha Demo hidden/runtime Seal Guardian boss attack animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_04`；按项目管线抽取 `20/20` selected frames，重建 `256x192` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `25` 个 manual-review entries、`30` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `30/30 approved final-ready records`；ImageGen candidate pool `130 candidates, 97 unselected candidates`；Asset provenance `55 records, 130 candidate hashes, 55 output hashes`；ImageGen source safety `130 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 30/55 final ready`；final acceptance gates `25 blocked assets, 30 final-ready assets`；asset package audit 通过并记录 `30 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 30 final-ready`；candidate review gallery `97 candidates, 55 assets`；final-art workbench `55 cards, 25 manual-review assets, 30 final-ready assets`；Godot import 通过；Stage15 GUT `12/12`、`148` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Seal Guardian boss attack animation preview，不批准正式 Boss 状态机动画替换、攻击判定、damage window、受击 / 击败动作、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 18**：将 `luna_jump_fall_sheet_ai01` 从旧版需要 duplicate 补位的 jump / fall sheet，推进为当前 Alpha Demo hidden/runtime Luna jump/fall animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_05` 与 `candidate_06`，最终采用 `candidate_06`；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `26` 个 manual-review entries、`29` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `29/29 approved final-ready records`；ImageGen candidate pool `129 candidates, 95 unselected candidates`；Asset provenance `55 records, 129 candidate hashes, 55 output hashes`；ImageGen source safety `129 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 29/55 final ready`；final acceptance gates `26 blocked assets, 29 final-ready assets`；asset package audit 通过并记录 `29 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 29 final-ready`；candidate review gallery `95 candidates, 55 assets`；final-art workbench `55 cards, 26 manual-review assets, 29 final-ready assets`；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna jump/fall animation preview，不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、跳跃物理时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 17**：将 `luna_attack_01_sheet_ai01` 从旧版混合概念 attack sheet，推进为当前 Alpha Demo hidden/runtime Luna attack 01 animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `27` 个 manual-review entries、`28` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `28/28 approved final-ready records`；ImageGen candidate pool `127 candidates, 94 unselected candidates`；Asset provenance `55 records, 127 candidate hashes, 55 output hashes`；ImageGen source safety `127 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 28/55 final ready`；final acceptance gates `27 blocked assets, 28 final-ready assets`；asset package audit 通过并记录 `28 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 28 final-ready`；candidate review gallery `94 candidates, 55 assets`；final-art workbench `55 cards, 27 manual-review assets, 28 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna attack 01 animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、伤害时序、取消窗口、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 16**：将 `luna_air_dash_sheet_ai01` 从旧版混合姿态 Air Dash sheet，推进为当前 Alpha Demo hidden/runtime Luna Air Dash animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `28` 个 manual-review entries、`27` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `27/27 approved final-ready records`；ImageGen candidate pool `126 candidates, 91 unselected candidates`；Asset provenance `55 records, 126 candidate hashes, 55 output hashes`；ImageGen source safety `126 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 27/55 final ready`；final acceptance gates `28 blocked assets, 27 final-ready assets`；asset package audit 通过并记录 `27 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 27 final-ready`；candidate review gallery `91 candidates, 55 assets`；final-art workbench `55 cards, 28 manual-review assets, 27 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna Air Dash animation preview；candidate 06 含两个显式 duplicate recovery frames，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗或位移时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 15**：将 `luna_run_sheet_ai01` 从旧版混合概念 run sheet，推进为当前 Alpha Demo hidden/runtime Luna run animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `29` 个 manual-review entries、`26` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `26/26 approved final-ready records`；ImageGen candidate pool `125 candidates, 89 unselected candidates`；Asset provenance `55 records, 125 candidate hashes, 55 output hashes`；ImageGen source safety `125 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 26/55 final ready`；final acceptance gates `29 blocked assets, 26 final-ready assets`；asset package audit 通过并记录 `26 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 26 final-ready`；candidate review gallery `89 candidates, 55 assets`；final-art workbench `55 cards, 29 manual-review assets, 26 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna run animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 14**：将 `luna_idle_sheet_ai01` 从旧版混合姿态 idle sheet，推进为当前 Alpha Demo hidden/runtime Luna idle animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_05`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `30` 个 manual-review entries、`25` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `25/25 approved final-ready records`；ImageGen candidate pool `124 candidates, 87 unselected candidates`；Asset provenance `55 records, 124 candidate hashes, 55 output hashes`；ImageGen source safety `124 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 25/55 final ready`；final acceptance gates `30 blocked assets, 25 final-ready assets`；asset package audit 通过并记录 `25 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 25 final-ready`；candidate review gallery `87 candidates, 55 assets`；final-art workbench `55 cards, 30 manual-review assets, 25 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna idle animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 13**：将 `vfx_combat_atlas_ai01` 从 review-required combat VFX atlas，推进为当前 Alpha Demo hidden/runtime combat VFX preview。
  结果：确认既有 atlas 为无文字、透明、32 帧战斗反馈图集；在玩家与 Seal Guardian 场景中增加隐藏 `CombatVfxPreview` runtime 预览引用；关闭该资产 semantics / VFX rules 的人工复核标记，并扩展 finalization review records；final-art queue 刷新为 `31` 个 manual-review entries、`24` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `24/24 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；ImageGen source safety `123 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 24/55 final ready`；final acceptance gates `31 blocked assets, 24 final-ready assets`；asset package audit 通过并记录 `24 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 24 final-ready`；final-art workbench `55 cards, 31 manual-review assets, 24 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime combat VFX preview，不批准最终战斗时序、玩法碰撞、伤害来源、受击窗口、公开 VFX 图集、商店页素材或宣传素材。

- **P0 final-ready mini pack 12**：将 `vfx_seal_magic_atlas_ai01` 从旧版带英文标签的 seal magic VFX atlas 候选，推进为当前 Alpha Demo hidden/runtime seal magic VFX preview。
  结果：使用内置 `image_gen` 重生 `candidate_05`，复制到项目候选目录，重建 `32/32` selected frames、atlas、SpriteFrames、semantics 和 VFX rules；扩展 finalization review records；final-art queue 刷新为 `32` 个 manual-review entries、`23` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `23/23 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；Art readiness `55/55 structural ready, 23/55 final ready`；final acceptance gates `32 blocked assets, 23 final-ready assets`；asset package audit 通过并记录 `23 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 23 final-ready`；candidate review gallery `85 candidates, 55 assets`；final-art workbench `55 cards, 32 manual-review assets, 23 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime seal magic VFX preview，不批准最终战斗时序、玩法碰撞、伤害来源、公开 VFX 图集、商店页素材或宣传素材。

- **P0 final-ready mini pack 11**：将 `hud_core_ui_atlas_ai01` 从旧版 gameplay HUD 语义待复核状态，推进为当前 `TutorialHUD` source atlas preview。
  结果：修正 `assets/art/ui/atlases/hud_core_ui_atlas_ai01.semantics.json`，把旧版 health / ability / boss status 等机器语义改为可见 HUD 装饰、符旗、面板、分隔线和莲花徽章描述；扩展 finalization review records；final-art queue 刷新为 `33` 个 manual-review entries、`22` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `22/22 approved final-ready records`；Art readiness `55/55 structural ready, 22/55 final ready`；final acceptance gates `33 blocked assets, 22 final-ready assets`；asset package audit 通过并记录 `22 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 22 final-ready`；final-art workbench `55 cards, 33 manual-review assets, 22 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 `TutorialHUD` source atlas preview / editor AtlasTexture resource set，不批准直接 gameplay HUD 语义绑定、最终 Theme mapping、完整 HUD 设计系统、商店页 UI 或宣传素材。

- **P0 final-ready mini pack 10**：将 `icon_sheet_core_ai01` 从旧版核心图标语义待复核状态，推进为当前 Alpha Demo 内部核心图标源图集。
  结果：修正 `assets/art/ui/atlases/icon_sheet_core_ai01.semantics.json`，把旧版 gameplay / HUD / menu 语义替换为图像可见语义描述；扩展 finalization review records；final-art queue 刷新为 `34` 个 manual-review entries、`21` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `21/21 approved final-ready records`；Art readiness `55/55 structural ready, 21/55 final ready`；final acceptance gates `34 blocked assets, 21 final-ready assets`；asset package audit 通过并记录 `21 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 21 final-ready`；final-art workbench `55 cards, 34 manual-review assets, 21 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 internal core icon source atlas / editor AtlasTexture preview，不批准直接 gameplay HUD/menu 语义绑定、完整最终图标体系、商店页 UI 或宣传素材。

## 2026-06-23

- **P0 final-ready mini pack 09**：将 `stage16_demo_menu_icons_ai01` 从旧版 menu icon preview 推进为当前 DemoShell 六宫格 runtime menu icon strip。
  结果：用内置 `image_gen` 生成 `candidate_04`，显式导入项目候选目录，转换为 RGBA alpha PNG，并补齐 `source.json`、`regions.json`、`semantics.json` 与 finalization review；final-art queue 刷新为 `35` 个 manual-review entries、`20` 个 final-ready assets。
  关键验证或结论：ImageGen candidate pool `122 candidates, 83 unselected candidates`；ImageGen source safety `122 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 20/55 final ready`；final acceptance gates `35 blocked assets, 20 final-ready assets`；asset package audit 通过并记录 `20 asset finalization approvals`；candidate review gallery `83 candidates, 55 assets`；final art review workbench `55 cards, 35 manual-review assets, 20 final-ready assets`；Godot import 通过；Stage16 GUT `13/13` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` 六宫格 runtime menu icon strip，不批准完整最终图标体系、未来按钮状态重做、HUD atlas 无关区域、商店页 UI 或宣传素材。

- **P0 final-ready mini pack 08**：将 `menu_ninepatch_ui_ai01` 从 NinePatch / StyleBoxTexture preview 推进为当前 runtime Theme / StyleBox skin。
  结果：`8` 个 StyleBoxTexture、`9` 个 Theme style mappings、DemoShell / TutorialHUD runtime UI skin binding 均通过审计；final-art queue 刷新为 `36` 个 manual-review entries、`19` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 19/55 final ready`；final acceptance gates `36 blocked assets, 19 final-ready assets`；asset package audit 通过并记录 `19 asset finalization approvals`；Godot import 通过；Editor StyleBoxTexture resources `8`、Editor UI skin `9 style mappings, 4 standalone panels`、runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage12 GUT `9/9`、Stage16 GUT `13/13` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` / `TutorialHUD` runtime Theme / StyleBoxTexture skin，不批准完整最终 UI 设计系统、未来按钮状态重做、商店页 UI 或无关 atlas 区域。

- **P0 final-ready mini pack 07**：将 `stage16_pause_panel_ui_ai01` 与 `stage16_completion_panel_ui_ai01` 从 chroma-key preview 推进为 DemoShell runtime panel preview。
  结果：两个 Stage16 panel 输出均转换为 RGBA alpha PNG，四角透明且无不透明绿残留；final-art queue 刷新为 `37` 个 manual-review entries、`18` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 18/55 final ready`；final acceptance gates `37 blocked assets, 18 final-ready assets`；asset package audit 通过并记录 `18 asset finalization approvals`；Godot import 通过；runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage16 GUT `13/13`、Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` pause / completion runtime panel preview，不批准通用 UI atlas、最终按钮状态、菜单图标语义、商店页完成图或商业宣传素材。

- **P0 final-ready mini pack 06**：将 `stage15_boss_hud_frame_ai01` 与 `stage14_ability_status_hud_ai01` 从 chroma-key preview 推进为 TutorialHUD runtime frame。
  结果：两个 HUD frame 输出均转换为 RGBA alpha PNG，四角透明且无不透明绿残留；final-art queue 刷新为 `39` 个 manual-review entries、`16` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 16/55 final ready`；final acceptance gates `39 blocked assets, 16 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 16 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `TutorialHUD` runtime frame preview，不批准通用 UI atlas、按钮状态、独立图标集、Boss 血量逻辑或商业宣传素材。

- **P0 final-ready mini pack 05**：将 `stage16_corruption_purge_ai01` 从 review-required VFX sheet 推进为 region-bound Stage16 purge runtime VFX。
  结果：补齐 `stage16_corruption_purge_ai01` finalization review；该资产使用 `3x2` / `6` frame VFX rules，Stage16 purge 房间继续通过显式 `region_rect` 引用单格视觉帧；final-art queue 刷新为 `41` 个 manual-review entries、`14` 个 final-ready assets。
  关键验证或结论：VFX rules `6 assets, 78 frame rules`；Art readiness `55/55 structural ready, 14/55 final ready`；final acceptance gates `41 blocked assets, 14 final-ready assets`；asset package audit 通过并记录 `14 asset finalization approvals` 与 `78 VFX rules`。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 Stage16 region-bound visual VFX，不批准整张 sheet 上屏、伤害判定、通用动画序列、商业宣传素材或剩余 `41` 个 blocked 资产。

## 2026-06-21

- **P0 final-ready mini pack 04**：将 `stage16_talisman_relay_ai01` 从整图 VFX sheet 预览推进为 region-bound Stage16 runtime VFX。
  结果：`build_vfx_rules.py` 为该资产生成 `3x2` / `6` frame region rules；Stage16 relay / purge 房间的 talisman relay Sprite2D 改为显式 `region_rect`，避免整张候选 sheet 上屏；final-art queue 刷新为 `42` 个 manual-review entries、`13` 个 final-ready assets。
  关键验证或结论：VFX rules `6 assets, 73 frame rules`；Art readiness `55/55 structural ready, 13/55 final ready`；final acceptance gates `42 blocked assets, 13 final-ready assets`；asset package audit 通过并记录 `13 asset finalization approvals`；Godot import 通过；Stage16 GUT `13/13`、`125` asserts 通过。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；边界：只批准当前 Stage16 region-bound visual VFX，不批准整张 sheet 上屏、伤害判定、通用动画序列或 `stage16_corruption_purge_ai01`。

- **ImageGen runtime review-required 资产统一重生候选落盘**：按统一 Nano Hunter 美术风格为 15 个 runtime review-required 资产追加新 raw candidates，不覆盖当前 `assets/art/` 输出或运行时引用。
  结果：新增 15 张候选 PNG，其中 8 张用于混合来源资产的统一风格对照，7 张用于 `manual_source_review_or_regenerate` 的必须重生路径；落盘报告推进到 `7/7 runtime source regeneration landed`；candidate review gallery 刷新为 `82 candidates, 55 assets`。
  关键验证或结论：Candidate pool 输出 `120 candidates, 547 selected sources, 82 unselected candidates, 55 review-required assets`；source safety 输出 `120 candidates, 35 project-session confirmed, 30 ledger review-required, 55 provenance review-required, 0 unsafe`；Godot import 通过；project isolation 输出 `1936 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；综合资产包审计通过，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-regeneration-candidate-pass.md`。

- **ImageGen runtime source safety 与确认来源 P0 接入**：针对多项目并行开发风险，新增运行态来源门禁，并只接入当前 Nano Hunter 会话确认来源的 `luna_jump_fall_sheet_ai01` 与 `stage16_seal_release_threshold_ai01`。
  结果：新增 runtime source safety 报告；`luna_jump_fall_sheet_ai01` 从 `candidate_04` 重建并接入玩家场景隐藏预览，`stage16_seal_release_threshold_ai01` 从 `candidate_02` 导出并接入 Stage16 封印阈值房 visual preview；P0 runtime replacement plan 推进到 `0 planned replacements, 28 already referenced`。
  关键验证或结论：Source safety 输出 `103 candidates, 35 project-session confirmed, 0 unsafe`；runtime source safety 输出 `28 runtime assets, 16 review-required, 0 unsafe`；Godot import 通过；Stage14 GUT `11/11`、Stage16 GUT `13/13` 通过；P0 scene replacement batches 为 `9 batches, 14 scenes, 28 assets, 54 scene-asset references`；acceptance gates 的 `runtime_replacement` 推进到 `36 passed, 19 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-safety-and-confirmed-p0-binding.md`。

- **ImageGen Seal Magic VFX Atlas 预览接入**：继续推进 P0 runtime replacement，把 `vfx_seal_magic_atlas_ai01` 接入玩家场景和 Seal Guardian Boss 场景作为隐藏 VFX 预览层。
  结果：`PlayerPlaceholder` 与 `SealGuardianBoss` 均新增隐藏 `SealMagicVfxPreview`，引用 `vfx_seal_magic_atlas_ai01.spriteframes.tres` 的 `seal_magic` 动画；该资产至少包含 1 个 `project_session_confirmed` candidate。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过；P0 replacement plan 推进到 `2 planned replacements, 26 already referenced`，P0 scene replacement batches 推进到 `21 planned scene-asset replacements, 34 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `35 passed, 20 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Luna 核心 SpriteFrames 预览接入**：继续推进 P0 runtime replacement，把 Luna run / air dash / attack / idle 四个 SpriteFrames 接入正式玩家场景作为隐藏动画预览层。
  结果：`PlayerPlaceholder` 新增 `LunaRunAnimationPreview`、`LunaAirDashAnimationPreview`、`LunaAttackAnimationPreview` 与 `LunaIdleAnimationPreview`，均引用当前项目 session 已确认的 Luna 核心动作 SpriteFrames；`luna_jump_fall_sheet_ai01` 因缺少 `project_session_confirmed` candidate 仍保持未接入。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11` 通过；P0 replacement plan 推进到 `3 planned replacements, 25 already referenced`，P0 scene replacement batches 推进到 `23 planned scene-asset replacements, 32 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `34 passed, 21 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 项目键来源门禁**：针对多项目并行开发风险，为 image_gen provenance 与 source-safety 层补齐 `project_key = nano-hunter` 强制检查。
  结果：`asset-provenance-records.json` 顶层和 55 条记录均带有 `project_key = nano-hunter`，`imagegen-source-safety-report.json` 顶层带有 `project_key = nano-hunter`；后续非 Nano Hunter 来源记录会在 strict 审计中失败。
  关键验证或结论：`audit_asset_provenance.py --strict` 通过，输出 `55 records, 101 candidate hashes, 55 output hashes`；`audit_imagegen_source_safety.py --write-report --strict` 通过，输出 `101 candidates, 33 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Seal Guardian SpriteFrames 预览接入**：继续推进 P0 runtime replacement，把 Boss SpriteFrames 接入正式 Boss 场景 / Boss 房作为隐藏动画预览层。
  结果：`SealGuardianBoss` 新增 `SealGuardianAnimationPreview`，`Stage15SealGuardianBossRoom` 新增 `SealGuardianRoomAnimationPreview`，均引用 `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.spriteframes.tres`；P0 replacement plan 推进到 `7 planned replacements, 21 already referenced`，P0 scene replacement batches 推进到 `27 planned scene-asset replacements, 28 already referenced`。
  关键验证或结论：Godot import 通过；Stage15 GUT `12/12` 通过；acceptance gates 的 `runtime_replacement` 推进到 `30 passed, 25 blocked`，但 Boss 动画仍需 frame order / baseline / timing 人工复核，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 瘴泽 TileSet 预览接入**：继续推进 P0 scene replacement，把 `miasma_marsh_tileset_ai01` 的 Godot `TileSet` 资源接入 Stage13 / Stage14 正式房间作为视觉预览层。
  结果：`Stage13MiasmaMarshEntryRoom` 与 `Stage14AirDashGateRoom` 均新增 `MiasmaTilesetPreview` `TileMapLayer`，引用 `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`；该资产为 `project_session_confirmed`；P0 replacement plan 推进到 `8 planned replacements, 20 already referenced`，P0 scene replacement batches 推进到 `28 planned scene-asset replacements, 27 already referenced`。
  关键验证或结论：Godot import 通过；Stage13 GUT `9/9`、Stage14 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `29 passed, 26 blocked`，但 TileSet 仍需 collision / terrain / hazard 人工复核，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 玩家可读性与 Air Dash trail 接入**：继续推进 P0 runtime replacement，把 Luna 方向稿和 Air Dash trail 接入正式玩家 / Stage14 神龛房。
  结果：`PlayerPlaceholder` 新增 `LunaReadabilityArt` 与 `AirDashTrailArt`，`Stage14AirDashShrineRoom` 新增 `AirDashTrailPreviewArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `9 planned replacements, 19 already referenced`，P0 scene replacement batches 推进到 `30 planned scene-asset replacements, 25 already referenced`。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `28 passed, 27 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage15 Boss 资产接入**：继续推进 P0 runtime replacement，把 Seal Guardian Boss 方向稿和攻击预警图接入正式 Boss 场景 / Boss 房。
  结果：`SealGuardianBoss` 新增 `SealGuardianArt` 与 `AttackWarningArt`，`Stage15SealGuardianBossRoom` 新增 `SealGuardianRoomArt` 与 `BossWarningRoomArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `11 planned replacements, 17 already referenced`，P0 scene replacement batches 推进到 `33 planned scene-asset replacements, 22 already referenced`。
  关键验证或结论：Godot import 通过；Stage15 GUT `12/12` 通过；acceptance gates 的 `runtime_replacement` 推进到 `26 passed, 29 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage14 Air Dash 道具接入**：继续推进 P0 runtime replacement，把 Air Dash shrine / gate 两个静态道具接入正式 Stage14 房间。
  结果：`Stage14AirDashShrineRoom` 新增 `ShrineArt` 与 `GatePreviewArt`，`Stage14AirDashGateRoom` 新增 `ShrineEchoArt` 与 `GateArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `13 planned replacements, 15 already referenced`，P0 scene replacement batches 推进到 `37 planned scene-asset replacements, 18 already referenced`。
  关键验证或结论：Godot import 通过；Stage14 GUT `10/10` 通过；acceptance gates 的 `runtime_replacement` 推进到 `24 passed, 31 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 corruption purge VFX 接入**：继续推进 Stage16 VFX runtime binding，把 `stage16_corruption_purge_ai01` 接入正式 purge 房间。
  结果：`Stage16CorruptionPurgeRoom` 的 `CorruptionMiasma` 新增 `PurgeArt`，直接引用 `assets/art/vfx/stage16_corruption_purge_ai01.png`；该资产的 `runtime_replacement` gate 已通过。
  关键验证或结论：Stage16 GUT `12/12` 通过；acceptance gates 的总体 `runtime_replacement` 刷新到 `22 passed, 33 blocked`，但 `stage16_corruption_purge_ai01` 仍保留 `workspace_provenance_recorded_review_required` 来源边界，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 relay VFX 接入**：继续推进 `batch_06_stage16_chain`，把 `stage16_talisman_relay_ai01` 接入正式 Stage16 relay / purge 房间。
  结果：`Stage16TalismanRelayRoom` 三个 relay marker 新增 `RelayArt`，`Stage16CorruptionPurgeRoom` 的 purge node 新增 `TalismanRelayEchoArt`；P0 replacement plan 推进到 `15 planned replacements, 13 already referenced`，P0 scene replacement batches 推进到 `41 planned scene-asset replacements, 14 already referenced`。
  关键验证或结论：Godot import 通过；Stage16 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `13 passed, 42 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 来源安全审计层**：针对多项目并行开发时全局 `generated_images` 可能混入其它项目 PNG 的风险，新增候选来源安全审计。
  结果：新增 `imagegen-source-safety-report.json`，把 `101` 个 raw candidates 分类为 `33` 个 project-session confirmed、`30` 个 ledger review-required、`38` 个 provenance review-required 和 `0` 个 unknown / unsafe；综合资产包审计纳入 `0 unsafe source candidates`。
  关键验证或结论：`audit_imagegen_source_safety.py --write-report --strict` 通过；`audit_asset_package.py --strict --write-report` 通过。该层只证明来源风险受控，不代表最终美术、授权或运行时接入完成。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD HUD atlas 资源绑定**：继续推进 `batch_02_hud`，把 HUD core atlas 与 icon sheet 的 Godot `AtlasTexture` 资源纳入正式 HUD 场景引用。
  结果：`TutorialHUD/BattlePanel` 新增隐藏 `HudCoreAtlasPreview` 与 `IconSheetCorePreview`，分别引用 `hud_core_ui_atlas_ai01` 与 `icon_sheet_core_ai01` 的首个 `AtlasTexture`；P0 replacement plan 推进到 `16 planned replacements, 12 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `12 passed, 43 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD HUD frame 资源绑定**：继续推进 `batch_02_hud`，把 Stage14 ability status 与 Stage15 Boss HUD frame 资源纳入正式 HUD 场景引用。
  结果：`TutorialHUD/BattlePanel` 新增隐藏 `AbilityStatusFrameArt` 与 `BossHudFrameArt`，分别引用 `stage14_ability_status_hud_ai01.png` 与 `stage15_boss_hud_frame_ai01.png`；P0 replacement plan 推进到 `18 planned replacements, 10 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `10 passed, 45 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD P0 图标接入**：继续推进 `batch_02_hud`，把 Air Dash 与 Recovery Charge 图标接入正式 HUD。
  结果：`TutorialHUD/BattlePanel/DashIcon` 改为引用 `stage14_air_dash_icon_ai01.png` 的 `TextureRect`，新增 `RecoveryChargeIcon` 引用 `stage15_recovery_charge_icon_ai01.png`；P0 replacement plan 推进到 `20 planned replacements, 8 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `8 passed, 47 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 完成反馈资产接入**：继续推进 P0 runtime replacement，把 `stage16_alpha_demo_completion_ai01` 接入正式 Stage16 终点房。
  结果：`stage16_alpha_demo_end_room.tscn` 新增 `AlphaDemoCompletionArt`，直接引用 `assets/art/ui/stage16_alpha_demo_completion_ai01.png`；P0 replacement plan 推进到 `22 planned replacements, 6 already referenced`。
  关键验证或结论：Stage16 专项 GUT `10/10` 通过；P0 scene replacement batches 审计通过；acceptance gates 的 `runtime_replacement` 推进到 `6 passed, 49 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen DemoShell UI 壳纹理接入**：继续推进 `batch_01_ui_shell`，把 DemoShell 标题背景、菜单图标、暂停面板和完成面板候选接入正式 UI 场景。
  结果：`DemoShell` 新增 `TitleBackground`、`MainMenu/MenuIconStrip`、`PauseMenu/PausePanelArt` 和 `CompletionPanel/CompletionPanelArt`；综合资产包审计纳入 `5 runtime UI skin panels` 与 `4 runtime UI skin textures`。
  关键验证或结论：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 5 panels, 4 textures`；Stage16 专项 GUT `9/9` 通过；P0 replacement plan 推进到 `23 planned replacements, 5 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `5 passed, 50 blocked`，但 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

## 2026-06-20

- **ImageGen runtime UI skin binding**：将 UI skin 从 dev showcase / rehearsal 推进到正式 UI 场景引用。
  结果：`DemoShell` 与 `TutorialHUD` 根 Control 绑定 `nano_hunter_imagegen_ui.theme.tres`，`MainMenu`、`PauseMenu`、`PromptPanel` 与 `BattlePanel` 绑定 `menu_ninepatch_ui_ai01` 的 `StyleBoxTexture`；综合资产包审计纳入 `9 UI Theme mappings` 与 `4 runtime UI skin panels`。
  关键验证或结论：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 4 panels`；P0 replacement plan 推进到 `26 planned replacements, 2 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `2 passed, 53 blocked`，但 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 场景替换批次**：将 P0 target scene replacement matrix 拆成可逐批执行的替换顺序。
  结果：新增 `p0-scene-replacement-batches.json` 与 `p0-scene-replacement-batches.md`，覆盖 `9` 个替换批次、`13` 个目标场景、`28` 个唯一 P0 资产和 `55` 个 scene-asset references；综合资产包审计纳入 `9 P0 scene replacement batches`。
  关键验证或结论：批次审计通过，输出 `9 batches, 13 scenes, 28 assets, 55 scene-asset references`；该层只做执行顺序和验证范围规划，不修改正式 `.tscn`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 目标场景替换矩阵**：将 P0 runtime replacement plan 按目标场景聚合。
  结果：新增 `p0-target-scene-replacement-matrix.json` 与 `p0-target-scene-replacement-matrix.md`，覆盖 `13` 个目标场景、`28` 个唯一 P0 资产和 `55` 个 scene-asset references；综合资产包审计纳入 `13 P0 target scenes`。
  关键验证或结论：矩阵审计通过，输出 `13 scenes, 28 assets, 55 scene-asset references`；该层只做场景级替换排程，不修改正式 `.tscn`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 运行时替换排练场景**：将 P0 replacement plan 中的资源绑定到 Godot 兼容节点。
  结果：新增 `p0_runtime_replacement_rehearsal.tscn` 与 `p0-runtime-replacement-rehearsal-manifest.json`，覆盖 `28` 个 P0 resource-bound nodes；综合资产包审计纳入 `28 P0 runtime rehearsal nodes`。
  关键验证或结论：Godot build / audit 通过，输出 `P0 runtime replacement rehearsal OK: 28 nodes`；该场景是正式替换前排练，不修改目标 gameplay / HUD / room 场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 运行时替换计划**：将 P0 runtime map 条目拆成目标场景、资源路径、替换模式和验证命令。
  结果：新增 `p0-runtime-replacement-plan.json` 与 `p0-runtime-replacement-plan.md`，覆盖 `28` 个 P0 runtime entries；`27` 个仍需手动替换，`1` 个已被 dev Gallery 引用；综合资产包审计纳入 `28 P0 runtime replacement-plan entries`。
  关键验证或结论：P0 replacement plan 初始审计通过，输出 `28 entries, 27 planned replacements, 1 already referenced`；后续 runtime UI skin binding 已推进到 `26 planned replacements, 2 already referenced`；该计划本身不自动修改正式场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术验收门槛**：将 `55` 个结构可用资产拆成 7 道 final-ready gate。
  结果：新增 `final-art-acceptance-gates.json` 与 `final-art-acceptance-gates.md`，明确来源追踪、授权条款、Godot 结构资源、编辑器复核卡、运行时替换、资产族专项清稿和最终批准的通过 / 阻塞状态；综合资产包审计纳入 `55 final-art acceptance-gated assets`。
  关键验证或结论：Acceptance gates 审计通过，输出 `55 assets, 55 blocked assets, 0 final-ready assets`；当前只有结构 / 追踪 / 复核入口通过，授权、运行时替换和最终批准仍全部阻塞。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术复核 Workbench**：将最终美术复核队列转成 Godot 编辑器可打开的审图工作台。
  结果：新增 `final_art_review_workbench.tscn` 与 `final-art-review-workbench-manifest.json`，按 priority / family 展示 `55` 个资产预览、blockers、next actions 和资源路径；综合资产包审计纳入 `55 final-art workbench cards`。
  关键验证或结论：Godot build / audit 通过，输出 `55 cards, 55 manual-review assets, 0 final-ready assets`；该层是编辑器复核入口，不代表最终美术或运行时替换完成。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术复核队列**：将 `55` 个结构可用资产的 readiness blockers 转换为可逐项勾选的人工复核任务。
  结果：新增 `final-art-review-queue.json` 与 `final-art-review-queue.md`，按 family / priority / blocker / next action 记录每个资产的清稿、授权、运行时替换和 Godot 复核入口；综合资产包审计纳入 `55 final-art review entries`。
  关键验证或结论：`audit_final_art_review_queue.py --strict` 通过，输出 `55 assets, 55 manual-review entries, 0 final-ready assets`；`audit_asset_package.py --strict --write-report` 通过。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 背景 alpha 策略**：为 `11` 个背景类 alpha 输出补齐策略记录和 opaque preview。
  结果：`background_asset_contains_alpha` warning 清零；tile / atlas 类保留 alpha padding 策略，promo / CG / storyboard 类生成 opaque preview；综合资产包审计纳入 `11 background alpha policies`。
  关键验证或结论：`audit_background_alpha_policy.py --strict` 通过；Art readiness 输出 `warnings_by_type={}`、`alpha_padding_policy_manual_review=5`、`opaque_preview_manual_review=6`；`audit_asset_package.py --strict --write-report` 通过。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 多项目导入安全修正**：修正全局 `.codex/generated_images` 在多项目并行时可能混入其它项目 PNG 的风险。
  结果：`scripts/assets/import_imagegen_outputs.py --copy-latest` 默认拒绝从全局 `generated_images` 直接复制最新图，必须改用明确 `--source`、明确 session JSONL 恢复、import map，或人工确认后加 `--allow-global-latest`；已删除本轮误导入的 5 个候选副本并记录边界。
  关键验证或结论：`python -m py_compile scripts\assets\import_imagegen_outputs.py` 通过；默认 `--copy-latest` 按预期拒绝全局最新图；显式 `--source --dry-run` 仍能规划目标路径且不复制。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

## 2026-06-19

- **完整资产补齐矩阵与图集化路线**：将资产生产线从 Batch 00-05 扩展到完整美术资产族与 Godot 图集化目标。
  结果：新增 `docs/assets/asset-completion-matrix.md`、`docs/assets/animation-frame-spec.md`、`docs/assets/image-gen-production-backlog.md`、`docs/assets/image-gen-prompt-library.md`、`docs/assets/image-gen-prompt-queue.json`、`docs/assets/image-gen-preview-log.md`、`docs/assets/godot-atlas-build-pipeline.md`、`docs/assets/asset-atlas-build-manifest.json`、`scripts/assets/build_asset_atlases.py`、`scripts/assets/import_imagegen_outputs.py`、`scripts/assets/validate_asset_production_queue.py`、`scripts/assets/export_imagegen_batch_plan.py`、`docs/implementation-plans/2026-06-19-full-asset-completion-and-atlas-plan.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`，扩展 `asset-production-roadmap.md` 与 `asset-manifest.md` 到 Batch 06-13，并新增 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件、UI 图集、VFX 图集、贴图、宣传和分镜目录骨架；主角 Luna 动作升级为高帧数规格。
  关键验证或结论：prompt queue 已扩展到 33 个具体 image gen 任务和 23 个 atlas-linked 输出，Batch00 / Batch01 / Batch06 / Batch07 / Batch08 / Batch09 / Batch10 / Batch11 / Batch12 / Batch13 已导出 production packet；内置 `image_gen` 已生成 Batch00 `1/1`、Batch01 `8/8`、Batch06 `5/5`、Batch07 `3/3`、Batch08 `3/3`、Batch09 `2/2`、Batch10 `2/2`、Batch11 `2/2`、Batch12 `4/4` 与 Batch13 `3/3` 会话预览并记录 preview log，当前 queue `33/33` 条目已有预览记录；`import_imagegen_outputs.py` 已支持 `--include-inbox` 扫描 `assets/source/imagegen_inbox/` 手动保存落点，并支持 `--magic-scan` 按文件头排查无扩展名缓存；当前默认目录、inbox、Temp 和 Codex home 均未发现本轮可复制 PNG，当前改动不声称正式资产已落盘或接入。
  详情日志链接：`docs/progress/logs/2026-06-19.md`。

## 2026-03-31

- **仓库治理基线**：建立 Godot 4.6 原型仓库治理基线。
  结果：明确 `spec-design/`、`docs/progress/`、`plan/` 与 GUT 测试方向。
  详情：`docs/progress/logs/2026-03-31.md`。

## 2026-04-01

- **Stage1 启动骨架**：完成 `Main.tscn`、测试房间、相机、基础碰撞和首批 GUT。
  结果：项目进入可启动原型状态。
  详情：`docs/progress/logs/2026-04-01.md`。

## 2026-04-06

- **分支 / worktree 规则雏形**：建立分支与 worktree 使用规则。
  结果：确认主工作区保留稳定基线。
  详情：`docs/progress/logs/2026-04-06.md`。

## 2026-04-10

- **阶段推进节奏调整**：强化“设计、实现、验证、留痕”闭环。
  结果：阶段开发流程从经验约定转为可追踪规则。
  详情：`docs/progress/logs/2026-04-10.md`。

## 2026-04-11

- **早期治理整理**：继续整理项目治理、阶段文档和验证命令记录。
  结果：早期原型流程留痕更完整。
  详情：`docs/progress/logs/2026-04-11.md`。

## 2026-04-20

- **Stage5 后续准备**：更新早期原型推进记录。
  结果：为 Stage5 后续可试玩切片做准备。
  详情：`docs/progress/logs/2026-04-20.md`。

## 2026-04-21

- **Stage5 教程切片推进**：推进教程垂直切片与早期 HUD / 房间链路验证。
  结果：教程区短流程进入可验证状态。
  详情：`docs/progress/logs/2026-04-21.md`。

## 2026-04-22

- **Stage5-Stage6 前置验证**：补强阶段前置验证和进度文档。
  结果：继续收敛原型期流程。
  详情：`docs/progress/logs/2026-04-22.md`。

## 2026-04-23

- **Stage5-Stage8 收口**：Stage5 教程垂直切片完成，随后完成 Stage6 最小真实战斗循环、Stage7 短链路主流程串联与 Stage8 系统稳固 / 内容生产前准备。
  结果：项目从早期手感验证推进到内容生产前准备。
  详情：`docs/progress/logs/2026-04-23.md`。

## 2026-04-24

- **Stage9-Stage11 内容推进**：完成首个小区域内容生产、战斗变化与轻量成长循环、可交付试玩 Demo 切片的主要实现与验证。
  结果：第一版可交付试玩 Demo 切片形成。
  详情：`docs/progress/logs/2026-04-24.md`。

## 2026-04-25

- **Stage12-Stage16 路线规划**：规划更大颗粒度路线，开始 Stage12 资产管线与第一轮 Demo 表现升级。
  结果：后续 Alpha Demo 候选路线明确。
  详情：`docs/progress/logs/2026-04-25.md`。

## 2026-04-26

- **Stage12-Stage13 推进**：Stage12 收口并合并，Stage13 第二小区域内容生产完成主要实现与验证。
  结果：Demo 表现升级与第二小区域内容形成阶段基线。
  详情：`docs/progress/logs/2026-04-26.md`。

## 2026-04-27

- **Stage14 稳定基线**：完成回溯与能力门控成型。
  结果：新增 `Air Dash / 空中二段冲刺`、能力门、回溯链路与 `3` 个回溯收益点。
  详情：`docs/progress/logs/2026-04-27.md`。

- **Stage15 主体启动**：启动战斗高潮与首个精英 Boss 原型。
  结果：实现 Seal Guardian、Recovery Charge、Stage15 房间链路、HUD 与专项测试主体内容。
  详情：`docs/progress/logs/2026-04-27.md`。

- **客户端 / 插件治理整理**：整理客户端 / CLI、Godot MCP 和插件治理文档。
  结果：降低 AGENTS 对单一客户端实现的绑定。
  详情：`docs/progress/logs/2026-04-27.md`。

## 2026-04-28

- **Stage15 运行态复核与修复**：完成 Godot MCP 运行态人工复核，并修复 completion room HUD 问题。
  结果：完成房不再显示旧主目标、恢复充能或旧收集行；补入回归测试。
  详情：`docs/progress/logs/2026-04-28.md`。

- **Stage15 QA 收口**：发现并修复混合遭遇和挑战支线可绕过问题。
  结果：补全清门控、挑战支线出口门和回归测试；Stage15 分支合并回 `main`。
  验证：Godot import、Stage15 专项 GUT `11/11`、全量 GUT `107/107`、`git diff --check HEAD` 和乱码扫描通过。
  详情：`docs/progress/logs/2026-04-28.md`。

- **进度文档治理初步调整**：日日志迁入 `docs/progress/logs/`，MCP 截图改为 `tests/artifacts/local/` 本地证据产物。
  结果：降低 `status.md` 与 `timeline.md` 的重复度。
  详情：`docs/progress/logs/2026-04-28.md`。

## 2026-04-29

- **Stage12-13 北极星回收修正**：创建并完成 `codex/north-star-realign-stage12-13`。
  结果：将现代实验室 / 生物废液表达回收到山门古刹、镇妖试炼场、瘴泽妖域、符印封印机关和瘴气妖术投射者。
  验证：Godot MCP 人工复核完成，分支合并到 `main` 并推送 `origin/main`。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 Alpha Demo 候选**：从固定永久工作树创建 `codex/stage-16-alpha-demo-candidate` 并完成主体实现。
  结果：五房终局封印链、Stage15 completion 接入、最小 Demo 壳、Main / HUD Stage16 完成态、Stage16 专项 GUT、Alpha Demo 灰盒 driver、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与资产 / 音频 manifest 条目完成。
  验证：Godot MCP 运行态复核覆盖主菜单、暂停 / 继续 / 重开、Stage15 completion、Stage16 五房运行态节点、导出 next-room 链路与 Alpha Demo 终点。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 合并基线**：Stage16 Alpha Demo 打包候选合并回 `main`。
  结果：`main` 成为 Stage16 Alpha Demo 候选稳定基线。
  验证：Godot import、Stage16 专项 GUT `8/8`、Stage15 专项 GUT `11/11`、全量 GUT `115/115`、`git diff --check HEAD` 通过。
  详情：`docs/progress/logs/2026-04-29.md`。

## 2026-04-30

- **Godot MCP bridge lifecycle hardening**：启动并完成工具链修复分支 `codex/fix-godot-mcp-bridge-lifecycle` 的第一轮 hardening。
  结果：扩展 stdio bridge 端口规划，保留 `godot-cli` 端口，新增 bridge lock/heartbeat、workspace handshake、lazy reconnect、诊断脚本和插件升级后可重放补丁源。
  验证：Node `npm test` / `npm run build`、Godot import、诊断脚本 dry-run、补丁脚本 dry-run 和 `git diff --check` 通过。
  提交：`ddaad7d`。
  遗留：该阶段不等于完整根治，Godot 插件仍可能优先连接旧低端口 bridge。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 通用补丁工具**：将 hardening 补丁脚本通用化为可搬移、可跨项目使用的工具。
  结果：默认只覆盖全局 Node server 与目标项目 `addons/godot_mcp`；项目诊断脚本改为 `-IncludeProjectScripts` 可选项。
  验证：补丁脚本 dry-run 矩阵、外部 Node server 构建测试、Godot import、诊断脚本和乱码扫描通过。
  提交：`fd7638f`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 文档入口收敛**：将脚本速查与排障流程合并进 `docs/dev/godot-mcp-pro-connectivity-guide.md`。
  结果：connectivity guide 成为唯一权威入口，`AGENTS.md` 只保留项目级原则和指针。
  验证：旧引用扫描和 `git diff --check` 通过。
  提交：`a41ea03`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP hardening 复核修正**：人工复核确认当前方案仍缺 session/port rendezvous。
  结果：文档状态修正为“hardening 已完成，完整根治未完成”；后续需新增独立 rendezvous 计划。
  关键证据：当前会话工具入口存在，但 MCP 只读工具返回 Godot editor 未连接；Godot editor 可被旧 `6505` bridge 抢先连接。
  详情：`docs/progress/logs/2026-04-30.md`。

## 2026-05-01

- **Godot MCP 端口迁移与 rendezvous 根治**：在 `codex/fix-godot-mcp-bridge-lifecycle` 上继续工具链根治。
  结果：stdio 主端口迁移到 `17605-17619`，CLI 主端口迁移到 `17620-17624`，旧 `6505-6509` / `6510-6514` 降级为 legacy；Node 写项目本地 rendezvous，Godot 插件优先连接当前会话指定端口。
  关键验证：外部 Node server `npm test` / `npm run build` 通过；完整 Godot 与脚本验证见当日日志。
  详情：`docs/progress/logs/2026-05-01.md`。

## 2026-05-13

- **Godot MCP Pro 1.13.1 增量合并**：启动 `codex/upgrade-godot-mcp-1-13-1-increments`，审查并吸收 1.13.1 可用增量。
  结果：保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，同时合入 ping/pong、heartbeat timeout、idle/stale UI 与输入 `unhandled=false` 修正。
  关键验证：外部 Node server `npm test` / `npm run build`、补丁脚本 dry-run、MCP 诊断脚本、入口脚本 dry-run、Godot import 和 `git diff --check` 通过。
  详情：`docs/progress/logs/2026-05-13.md`。

## 2026-05-14

- **资产生产线治理落地**：建立 Asset Production Track 文档基线。
  结果：新增 `asset-storage-policy.md` 与 `asset-production-roadmap.md`，补强资产生成 brief、manifest、接入 checklist、`.gitignore` 与 `AGENTS.md`。
  目标范围：Batch 00-05 的资产生产、存储、工具分工、授权记录和后续 Stage 补充规则。
  详情：`docs/progress/logs/2026-05-14.md`。

## 2026-05-22

- **资产生产线治理合并**：按用户要求合并并推送除 Luna 行走关键帧生成内容外的其它主线内容。
  结果：`codex/asset-production-track-governance` 合并到 `main`；Luna 行走关键帧目录、5 月 5 日日志和对应 manifest 行保留为本地未提交内容。
  详情：`docs/progress/logs/2026-05-22.md`。

## 2026-06-19

- **ImageGen 会话 PNG 恢复落盘**：按用户提供的 `Export-CodexImageGenResults.ps1` 思路，从当前 Codex session JSONL 的 `image_generation_call.result` 恢复 Nano Hunter 本轮生成图。
  结果：Batch00 / Batch01 / Batch06-Batch13 共 `33/33` 个原始候选 PNG 已写入 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`；源候选按资产存储策略默认不进入普通 Git。
  关键验证或结论：Pillow 成功打开并读取 `33` 个 PNG 尺寸；当前仍不是正式 `assets/art/` 可运行资产，后续需清稿、切片、图集化和 Godot 导入验证。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **第一版 Godot 候选图集生成**：新增 raw candidate 自动拆分脚本和 standalone 导出脚本，并把恢复出的 image gen 候选推进到 `assets/art/` 可导入候选。
  结果：生成 `33` 张候选 PNG、`23` 个 frames / regions JSON、`7` 个 `SpriteFrames` `.tres`，覆盖 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集、九宫格 sheet、宣传图、LOGO 方向、分镜图和 Batch01 P0 单体方向稿。
  关键验证或结论：`prepare_selected_sources.py --overwrite`、`export_standalone_candidates.py --overwrite`、`build_asset_atlases.py --dry-run --strict`、`build_asset_atlases.py` 和 `godot --headless --path . --import` 通过；当前仍是 provisional first pass，未达到 `expected_target`，未接入玩法。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch02 Stage16 UI 与终局反馈候选补齐**：把 Stage16 标题背景、菜单图标、终局封印、relay / purge VFX 和 Alpha Demo completion UI 加入 prompt queue 并生成候选。
  结果：queue 从 `33` 项扩展为 `39` 项；新增 `6` 张 Batch02 standalone PNG，`assets/art/**/*.png` 总数推进到 `39`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`39` items、`23` atlas-linked outputs；`export_standalone_candidates.py --overwrite` 和 `godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未接入 Stage16 UI / 完成反馈。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch03 区域表现候选落盘**：为 `biome_01_shrine_trial` 与 `biome_02_miasma_marsh` 生成 tile / background 候选，并补充 reusable seal props。
  结果：queue 从 `39` 项扩展为 `44` 项；新增 `5` 张 Batch03 standalone PNG，`assets/art/**/*.png` 总数推进到 `44`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`44` items、`23` atlas-linked outputs；`export_standalone_candidates.py --overwrite` 和 `godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未切片为正式 TileSet 或替换场景背景 / props。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch06 supplemental 动画覆盖补齐**：补齐 Luna jump/fall、Luna hit/death 与 core enemies 三组角色 / 敌人动画候选。
  结果：queue 从 `44` 项扩展为 `47` 项；新增 `3` 张 Batch06 supplemental Sprite Sheet、`3` 个 frames JSON、`3` 个 SpriteFrames，`assets/art/**/*.png` 总数推进到 `47`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`47` items、`26` atlas-linked outputs；三组 `prepare_selected_sources.py --only <asset_id> --overwrite` 均拆出 `16/16` selected frames；三组 `build_asset_atlases.py --only <asset_id>` 均成功；`godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未替换运行时动画。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch03 supplemental 房间背景补齐**：补齐 shrine trial room、Air Dash shrine room、miasma hazard room 与 Seal Guardian boss room 四张具体房间 / 视差源图。
  结果：queue 从 `47` 项扩展为 `51` 项；新增 `4` 张 Batch03 supplemental standalone PNG，`assets/art/**/*.png` 总数推进到 `51`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`51` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未替换场景引用或配置视差层。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch08 supplemental UI 面板补齐**：补齐 Stage16 pause / completion panel、Stage15 Boss HUD frame 与 Stage14 ability status HUD 四张 UI 候选。
  结果：queue 从 `51` 项扩展为 `55` 项；新增 `4` 张 Batch08 supplemental standalone PNG，`assets/art/**/*.png` 总数推进到 `55`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 通过；透明度检查确认四张图角落 alpha 为 `0` 且无不透明绿幕像素。当前状态为 `placeholder_ready`，仍未替换 DemoShell / Boss HUD / ability HUD。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **ImageGen target-count 图集重建**：把已落盘 image gen 候选从 minimum first pass 推进到 target-count editor-ready rebuild。
  结果：`26/26` 个 atlas-linked outputs 达到 `expected_target`；selected source 变为 `selected_frames=236`、`selected_items=122`、`selected_tiles=96`、`selected_parts=48`、`selected_panels=36`；`assets/art/**/*.png` 保持 `55` 张，metadata JSON 为 `26` 个，`.spriteframes.tres` 为 `10` 个。
  关键验证或结论：`prepare_selected_sources.py --target target --overwrite`、`build_asset_atlases.py --dry-run --strict`、`build_asset_atlases.py`、`audit_asset_target_coverage.py --strict` 与 `godot --headless --path . --import` 通过。当前状态仍为 `placeholder_ready`，未替换运行时引用；部分动画、VFX、prop / equipment、icon 和 NinePatch 输出仍含 duplicate 补位。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；实施计划：`docs/implementation-plans/2026-06-19-imagegen-target-count-atlas-rebuild.md`。

## 2026-06-20

- **ImageGen runtime asset catalog**：把 runtime map 中的 `55` 个资产生成 Godot `ResourcePreloader` 目录场景。
  结果：新增 `scripts/dev/build_imagegen_runtime_asset_catalog.gd`、`scripts/dev/audit_imagegen_runtime_asset_catalog.gd`、`scenes/dev/imagegen_runtime_asset_catalog.tscn`、`docs/assets/imagegen-runtime-asset-catalog-manifest.json` 和对应实施计划；readiness / package audit 纳入 runtime catalog。
  关键验证或结论：Godot catalog build / audit 均输出 `55 resources`；Art readiness 中 `runtime_catalog_ready_manual_replacement=55`；综合审计输出 `55 runtime catalog resources`。当前仍需正式替换运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-runtime-asset-catalog.md`。

- **Asset runtime integration map**：为当前 image gen 资产包生成运行时 / 发布接入映射。
  结果：新增 `scripts/assets/build_asset_runtime_map.py`、`scripts/assets/audit_asset_runtime_map.py`、`docs/assets/asset-runtime-integration-map.json` 和对应实施计划；readiness / package audit 纳入 runtime map。
  关键验证或结论：runtime map 审计输出 `55 entries, 9 tracks`；Art readiness 中 `runtime_reference_not_replaced=0`、`runtime_binding_map_ready_manual_replacement=55`；综合审计输出 `55 runtime map entries`。当前仍需按 Stage polish 人工替换场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-runtime-integration-map.md`。

- **Asset provenance records**：为当前 image gen 资产包生成来源、prompt 和 hash 追踪记录。
  结果：新增 `scripts/assets/build_asset_provenance.py`、`scripts/assets/audit_asset_provenance.py`、`docs/assets/asset-provenance-records.json` 和对应实施计划；readiness / package audit 纳入 provenance。
  关键验证或结论：provenance 审计输出 `55 records, 120 candidate hashes, 55 output hashes`；Art readiness 中授权 blocker 从 `license_record_pending` 推进为 `license_terms_manual_review`；综合审计输出 `55 provenance records`。当前仍需商业条款人工复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-provenance-records.md`。

- **ImageGen candidate review gallery**：把未进入 selected source 的 raw candidates 生成 Godot 编辑器评审场景。
  结果：新增 `scripts/dev/build_imagegen_candidate_review_gallery.gd`、`scripts/dev/audit_imagegen_candidate_review_gallery.gd`、`scenes/dev/imagegen_candidate_review_gallery.tscn`、`docs/assets/imagegen-candidate-review-gallery-manifest.json` 和对应实施计划；综合资产包审计纳入 candidate review gallery。
  关键验证或结论：Godot 审计输出 `72 candidates, 53 assets`；综合审计输出 `72 unselected candidates, 72 candidate review cards`。当前仍是人工分拣入口，不代表 atlas 重建、最终清稿或运行时接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-candidate-review-gallery.md`。

- **ImageGen candidate pool audit layer**：新增 raw candidate / selected source 使用关系审计，避免新增 PNG 落盘后被误判为已进入图集或最终资产。
  结果：新增 `scripts/assets/audit_imagegen_candidate_pool.py`、`docs/assets/imagegen-candidate-pool-report.json` 和 `docs/implementation-plans/2026-06-20-imagegen-candidate-pool-audit.md`；综合资产包审计纳入 candidate pool 证据。
  关键验证或结论：`python scripts\assets\audit_imagegen_candidate_pool.py --strict --write-report` 通过，当前记录 `101` raw candidates、`538` selected sources、`72` unselected candidates、`53` review-required assets；`audit_asset_package.py --strict --write-report` 同步输出 `72 unselected candidates`。当前仍不自动重建 `assets/art` 或替换运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-candidate-pool-audit.md`。

- **ImageGen asset semantic label pass**：为 atlas-linked outputs 与 standalone menu icon sheet 生成 first-pass 语义标签。
  结果：新增 `scripts/assets/build_asset_semantics.py`、`scripts/assets/audit_asset_semantics.py`、`docs/assets/asset-semantics-index.json`、`assets/art/**/*.semantics.json`、`assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json` 和 `docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`。
  关键验证或结论：`python scripts\assets\audit_asset_semantics.py --strict` 输出 `Asset semantics OK: 26 assets, 538/538 semantic entries.`；综合资产包审计输出 `544 semantic labels`。当前仍是 first-pass machine semantic labels，需人工复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`。

- **ImageGen art readiness audit**：新增美术接入就绪审计层，把结构性资产补齐和最终美术完成分开记录。
  结果：新增 `scripts/assets/audit_art_readiness.py`、`docs/assets/art-readiness-audit-report.json` 和 `docs/implementation-plans/2026-06-20-art-readiness-audit.md`；扩展 `scripts/assets/audit_asset_package.py` 纳入 readiness 报告；扩展 `scripts/assets/export_standalone_candidates.py` 支持绿色 / 洋红 chroma key，并重导出 `stage15_seal_guardian_ai01` 为带 alpha PNG。
  关键验证或结论：`python scripts\assets\audit_art_readiness.py --strict --write-report` 输出 `55/55 structural ready, 0/55 final ready`；`python scripts\assets\audit_asset_package.py --strict --write-report` 输出 `55 art-ready structures`。当前仍未完成最终清稿、授权和运行时替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-art-readiness-audit.md`。

- **ImageGen duplicate reduction pass 01**：确认本会话内置 `image_gen` 的默认生成目录可直接作为复制来源，并把补充候选纳入项目资产管线。
  结果：复制补充 PNG 到 `assets/source/ai_generated/.../candidates/`；`prepare_selected_sources.py` 支持多 `candidate_XX` 合并抽取；重建全部曾含 duplicate 的 atlas-linked 输出。
  关键验证或结论：`audit_asset_target_coverage.py --strict` 通过；`26/26` 个 atlas-linked outputs 当前全部为 `duplicates=0`。当前仍是 `placeholder_ready`，未接入运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-duplicate-reduction-pass-01.md`。

- **Godot 编辑器 AtlasTexture 资源层**：把非 SpriteFrames atlas-linked outputs 拆成 Godot 可加载的单 region 资源。
  结果：新增 `scripts/assets/build_editor_atlas_textures.py`、`scripts/assets/audit_editor_atlas_textures.py` 和 `scripts/dev/audit_editor_atlas_textures.gd`；生成 `302` 个 `AtlasTexture` `.tres`，索引为 `assets/art/editor_resources/editor_atlas_textures.index.json`。
  关键验证或结论：`audit_editor_atlas_textures.py --strict` 通过；`godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd` 输出 `Editor AtlasTexture resources OK: 302`；`godot --headless --path . --import` 通过。当前仍需正式 TileSet collision、NinePatch margins、VFX anchors 和运行时引用接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-atlastexture-resource-layer.md`。

- **Godot 编辑器 TileSet 资源层**：把 Batch07 两个 `tileset_sheet` 转成 Godot 可加载的 `TileSet` 候选资源。
  结果：新增 `scripts/dev/build_editor_tilesets.gd` 与 `scripts/dev/audit_editor_tilesets.gd`；生成 `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`、`assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres` 和对应 `.tileset_rules.json`。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd` 输出 `Editor TileSet resources built: 2`；`godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd` 输出 `Editor TileSet resources OK: 2`；综合审计记录 `96` 个 tile rules、`64` 个 collision-ready tiles、`8` 个 hazard visual-only tiles。当前仍未配置 autotile、navigation、正式 hazard Area 或运行时 TileMap 引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-tileset-resource-layer.md`、`docs/implementation-plans/2026-06-20-editor-tileset-collision-rules.md`。

- **Godot 编辑器 StyleBoxTexture 资源层**：把 Batch08 `menu_ninepatch_ui_ai01` 的九宫格 region 转成 Godot 可加载的 UI 样式候选资源。
  结果：新增 `scripts/dev/build_editor_styleboxes.gd` 与 `scripts/dev/audit_editor_styleboxes.gd`；生成 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/` 下 `8` 个 `.stylebox_texture.tres` 和索引 JSON。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources built: 8`；`godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources OK: 8`。当前仍未接入 Theme、运行时 UI、文字安全区或拉伸复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-stylebox-resource-layer.md`。

- **Godot 编辑器 UI skin / Theme 规则层**：把 Batch08 `menu_ninepatch_ui_ai01` 的 StyleBox 候选继续映射到 Godot `Theme` 候选，并为 standalone UI / HUD 图生成 text-safe area 规则。
  结果：新增 `scripts/dev/build_editor_ui_skin.gd` 与 `scripts/dev/audit_editor_ui_skin.gd`；生成 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres` 和 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`；初始综合资产包审计新增 `8` 个 UI Theme mappings 和 `4` 个 standalone UI skin panel rules，后续 runtime UI skin binding 已推进到 `9` 个 UI Theme mappings 和 `4` 个 runtime UI skin panels。
  关键验证或结论：初始 `audit_editor_ui_skin.gd` 输出 `Editor UI skin OK: 8 style mappings, 4 standalone panels`；后续已更新为 `9 style mappings` 并接入 DemoShell / TutorialHUD；`python scripts\assets\audit_art_readiness.py --strict --write-report` 保持 `55/55 structural ready, 0/55 final ready`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-ui-skin-rules.md`。

- **VFX anchor / blend rules layer**：为 Batch10 VFX atlas 和 standalone VFX PNG 生成 first-pass anchor / blend / collision boundary rules。
  结果：新增 `scripts/assets/build_vfx_rules.py` 与 `scripts/assets/audit_vfx_rules.py`；生成 `assets/art/vfx/vfx_rules/` 下 `6` 个 VFX rule sidecars 和 `vfx_rules.index.json`；综合资产包审计新增 `68` 条 VFX rules。
  关键验证或结论：`python scripts\assets\audit_vfx_rules.py --strict` 输出 `VFX rules OK: 6 assets, 68 frame rules, 68 collision-disabled rules.`；所有规则均显式 `gameplay_collision=false` 和 `damage_source=false`；Godot import、Gallery 与 Integration Showcase 审计继续通过。当前仍未替换运行时 VFX 或 author 真实伤害判定。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-vfx-anchor-rules.md`。

- **Character animation rules layer**：为 Luna、Seal Guardian 和 core enemies 的 Sprite Sheet 生成 first-pass clip / timing / pivot / baseline rules。
  结果：新增 `scripts/assets/build_animation_rules.py` 与 `scripts/assets/audit_animation_rules.py`；生成 `assets/art/characters/animation_rules/` 下 `8` 个 animation rule sidecars 和 `animation_rules.index.json`；综合资产包审计新增 `172` 条 animation rules。
  关键验证或结论：`python scripts\assets\audit_animation_rules.py --strict` 输出 `Animation rules OK: 8 assets, 172 frame rules.`；Godot import、Gallery 与 Integration Showcase 审计继续通过。当前仍未确认最终帧序、脚底基线、碰撞盒读值或运行时动画替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-character-animation-rules.md`。

- **Spine-style 拆件导出层**：把 Batch11 Luna / Seal Guardian 拆件图集转成可交接的 `.atlas`、`.spine_style.json` 和 cutout manifest。
  结果：新增 `scripts/assets/build_spine_cutout_manifests.py` 与 `scripts/assets/audit_spine_cutout_manifests.py`；生成 `assets/art/spine_parts/spine_exports/` 下 `2` 个 asset exports、`48` 个 part descriptors。
  关键验证或结论：`python scripts\assets\build_spine_cutout_manifests.py --dry-run` 计划 `2` assets / `48` parts；`python scripts\assets\audit_spine_cutout_manifests.py --strict` 输出 `Audited 2 Spine-style cutout exports with 48 parts.`。当前仍不是正式 Spine rig 或运行时骨骼动画。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-spine-cutout-export-layer.md`。

- **资产包综合审计层**：把本轮 image gen 资产包、atlas 输出和 editor resources 汇总为结构化审计报告。
  结果：新增 `scripts/assets/audit_asset_package.py`；生成 `docs/assets/asset-package-audit-report.json`。
  关键验证或结论：`python scripts\assets\audit_asset_package.py --strict --write-report` 通过；报告 `ok=true`，覆盖 `55` queue items、`101` candidate PNGs、`72` unselected raw candidates、`26` atlas-linked outputs、`302` AtlasTextures、`2` TileSets、`8` StyleBoxes 和 `48` spine parts。当前仍是结构性审计，不证明最终美术、授权或运行时集成。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-package-audit-layer.md`。

- **Godot ImageGen Asset Gallery**：把当前 image gen 资产包整理为 Godot 编辑器内可打开的集中预览场景。
  结果：新增 `scripts/dev/build_imagegen_asset_gallery.gd`、`scripts/dev/audit_imagegen_asset_gallery.gd`、`scripts/dev/capture_imagegen_asset_gallery.gd`、`scenes/dev/imagegen_asset_gallery.tscn` 和 `docs/assets/imagegen-asset-gallery-manifest.json`；综合审计报告同步纳入 Gallery scene / manifest。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_imagegen_asset_gallery.gd` 写入场景和 manifest；`godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd` 输出 `Imagegen asset gallery OK: res://scenes/dev/imagegen_asset_gallery.tscn`，并实际检查 `361` 个普通纹理预览和 `8` 个 `StyleBoxTexture` 预览的资源加载与绑定；`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_imagegen_asset_gallery.gd` 写出本地截图和 `ok=true` 采样报告。当前仍是预览验收入口，不证明运行时接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-asset-gallery-preview.md`。

- **Godot ImageGen Asset Integration Showcase**：把当前 image gen 资产包继续整理为节点级接入演示场景。
  结果：新增 `scripts/dev/build_imagegen_asset_integration_showcase.gd`、`scripts/dev/audit_imagegen_asset_integration_showcase.gd`、`scenes/dev/imagegen_asset_integration_showcase.tscn` 和 `docs/assets/imagegen-asset-integration-showcase-manifest.json`。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd` 写入场景和 manifest；`godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd` 输出 `Imagegen asset integration showcase OK: res://scenes/dev/imagegen_asset_integration_showcase.tscn`。manifest 记录 `10` 个 `AnimatedSprite2D`、`2` 个 `TileMapLayer`、`4` 个 `PanelContainer` 和 `8` 个 `Sprite2D`，当前只证明 Godot 节点可消费资源，不证明正式 runtime 引用替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-asset-integration-showcase.md`。

## 2026-06-21

- **Final-ready mini pack 03**：第三批 runtime prop 与内部风格参考完成 finalization review。
  结果：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`style_board_global_ai01` 进入 `final_ready`；final-art queue 刷新为 `43` 个 manual-review entries、`12` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 12/55 final ready`；final acceptance gates `43 blocked assets, 12 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 12 final-ready`；prop 图经像素检查确认绿色背景为 alpha=0，不是不透明绿底。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **P0 final-ready mini pack 02**：第二批 P0 / Stage16 runtime 方向稿与反馈图完成 finalization review。
  结果：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage15_seal_guardian_ai01`、`stage16_luna_player_readability_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_title_background_ai01` 进入 `final_ready`；final-art queue 刷新为 `47` 个 manual-review entries、`8` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 8/55 final ready`；final acceptance gates `47 blocked assets, 8 final-ready assets`；final art workbench 已重建；family coverage `10/10 families, 7/7 Godot formats, 8 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **P0 final-ready mini pack 01**：首批 P0 runtime 单体资产完成 finalization review，并从 structural-ready 推进为 final-ready。
  结果：新增 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01` 进入 `final_ready`；final-art queue 刷新为 `51` 个 manual-review entries、`4` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 4/55 final ready`；final acceptance gates `51 blocked assets, 4 final-ready assets`；asset package audit 通过并记录 `4 asset finalization approvals`；Godot import、Stage14 / Stage15 / Stage16 GUT 均通过。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **Asset finalization pass 01 decisions**：完成首批 P0 runtime 资产审图结论和下一目标定义。
  结果：新增 `docs/assets/runtime-source-review-decisions.json`、`docs/assets/runtime-source-review-decisions.md`、`docs/assets/p0-finalization-list.md`、`docs/implementation-plans/2026-06-21-asset-finalization-pass-01.md` 与 `scripts/assets/audit_runtime_source_review_decisions.py`；`15/15` runtime review-required 资产全部进入 `confirmed_for_cleanup`。
  关键验证或结论：决策审计输出 `15 decisions, 15 confirmed for cleanup, 0 final-ready`；综合资产包审计通过并记录 `15 runtime source cleanup decisions`。当前仍是 cleanup / rebuild 入口，不代表授权、清稿、运行时替换或 final-ready。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-asset-finalization-pass-01.md`。

- **Project asset isolation audit**：新增项目资产隔离审计，防止多项目并行时把其它项目 image_gen 输出误归属到 Nano Hunter。
  结果：新增 `scripts/assets/audit_project_asset_isolation.py`、`docs/assets/project-asset-isolation-report.json`、`docs/assets/project-asset-isolation-report.md` 和 `docs/implementation-plans/2026-06-21-project-asset-isolation-audit.md`；综合资产包审计纳入该门槛。
  关键验证或结论：`python scripts\assets\audit_project_asset_isolation.py --write-report --strict` 输出 `1918 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；综合资产包审计同样通过并记录 `0 forbidden project markers, 0 outside asset paths`。当前只证明资产记录层未发现已知外项目污染证据，不代表 `review-required` 候选已确认。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-project-asset-isolation-audit.md`。

- **Runtime source regeneration landing audit**：为 7 个 runtime UI / VFX 重生图候选新增落盘审计，确保后续 image gen 生成结果只进入项目候选池。
  结果：新增 `scripts/assets/audit_runtime_source_regeneration_landing.py`、`docs/assets/runtime-source-regeneration-landing-report.json`、`docs/assets/runtime-source-regeneration-landing-report.md` 和 `docs/implementation-plans/2026-06-21-runtime-source-regeneration-landing-audit.md`；综合资产包审计纳入该门槛。
  关键验证或结论：前置门禁阶段 `python scripts\assets\audit_runtime_source_regeneration_landing.py --write-report --strict` 输出 `7 assets, 7 pending, 0 landed, 0 invalid`；后续同日已执行实际候选落盘 pass，并在最新里程碑中推进到 `7/7 runtime source regeneration landed`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-regeneration-landing-audit.md`。

## 2026-06-25

- **Animation Runtime Replacement Pass 复核收口**：确认动作正式替换批次的活跃候选已收口，runtime source review queue 清零。
  结果：runtime source safety 为 `30 runtime assets, 0 review-required, 0 unsafe`；动作替换严格审计为 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
  关键验证或结论：`build_runtime_source_review_queue.py` 输出 `0 review-required assets, 0 unsafe`；`audit_runtime_source_safety.py --write-report` 输出 `30 runtime assets, 0 review-required, 0 unsafe`；`audit_animation_runtime_replacement.py --strict` 通过并确认活跃候选无阻塞。
  详情日志链接：`docs/progress/logs/2026-06-25.md`；遗留：8 个历史 blocked reference 保留为归档证据与重生成依据，不再构成活跃阻塞。
