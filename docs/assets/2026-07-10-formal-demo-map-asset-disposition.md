# Formal Demo Map Asset Disposition

## 目的

本表只服务 39 房正式地图重做，防止把“资产已生成 / 已引用”误当成“适合正式房间构图”。任何资产进入新房间前必须有明确语义和使用层。

## 当前证据

- 运行资产队列：`55` 项。
- Image Gen 候选：`133` 张，其中 `104` 张未选。
- 区域 TileSet：神龛与瘴泽各 `48` 格，当前只达到保守 editor 语义与碰撞候选口径，仍需人工 edge / jump-through 复核。
- `imagegen_inbox` 和 `assets/source/ai_generated` 是输入 / 来源区，不是运行时资产目录。

## 保留并复用

- Luna 与敌人运行态动画。
- HUD、图标、NinePatch、门禁、checkpoint、奖励和 VFX AtlasTexture。
- 神龛 / 瘴泽背景作为区域背景源。
- `shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01` 和已验证机关状态切片。
- 当前房间脚本、门控、spawn、checkpoint、出口与回溯契约。

## 清稿或重新接入

- `shrine_trial_tileset_ai01`：保留风格源，重做正式边缘、角件、平台、门槛和碰撞。
- `miasma_marsh_tileset_ai01`：保留风格源，重做危险边缘、墙体、平台、过渡和 hazard author。
- `formal_terrain_kit_ai01`：保留语义与碰撞实验结果，不直接作为全图正式视觉。
- 房间背景：按区域拆成远景 / 中景，修正重复整图和硬边。
- 区域 props：从 source sheet 拆成独立语义件，避免整张图或错误切片上屏。

## 已验证样板用法

- `tutorial_room`：正式碰撞层复用 `formal_terrain_kit_ai01`；可见主地面复用 `shrine_trial_tileset_ai01`；薄平台使用同源裁薄的 `tutorial_thin_platform_visual_ai01`；训练目标复用人工复核试炼碑切片。
- `stage14_air_dash_gate_room`：沿用同一碰撞 / 表面分层契约；门禁和神龛回声复用 `shrine_gate_prop_atlas_ai01`；右侧连续崖体复用低对比 `dac_continuous_stone_underlay`。本样板没有触发新 Image Gen 生成。
- `stage15_mixed_gauntlet_room`：复用现有三类敌人运行态动画、Boss arena 背景、通用封印门和 tutorial 同源薄平台；背景按单张完整覆盖重新接入，敌人资产不重生。当前缺口仅是区域专用平台吊挂 / 支撑装饰，不阻挡战斗场样板推广。
- Batch 1：`test_room` 复用 `dac_continuous_stone_underlay` 并按真实 shape bounds 生成顶沿 / cap，不新增运行资产；`combat_trial_room` / `goal_trial_room` 复用正式 terrain collision、神龛地面表面、薄平台、通用封印门、目标 token、敌人和单张神龛背景。旧随机 formal decor、材质大图和灰盒 Polygon 地形不再参与这两个主线房的运行态。
- Batch 2 / Stage9：复用 `biome02_miasma_marsh_background_ai01` 的单张不同取景、正式 terrain collision、连续石质表面、薄平台、封印门、checkpoint、开关、敌人和 VFX；没有新增 Image Gen。`miasma_marsh_tileset_ai01` 继续保持 `source-only / hidden preview`，其碎片化 64px 切片不进入五房正式道路。
- Batch 3 / Stage10：复用瘴泽背景、正式 terrain collision / surface、三类敌人、封印门、恢复点、奖励 marker 和现有 VFX；主线、奖励支路和挑战房只改变房间构图与运行接入，不新增 Image Gen。挑战房全清门属于玩法契约修正，不需要新资产。
- Batch 4 / Stage11-13：复用终点 marker、瘴泽背景、checkpoint、Miasma Caster、封印门和 `miasma_purge_warning` VFX；危险警示只调运行态透明度 / 尺度，不重生资产。`miasma_marsh_tileset_ai01` 继续只作隐藏来源引用。
- Batch 5 / Stage13 中段：复用瘴泽背景、Miasma Caster、封印门、checkpoint 和 hazard VFX；Gate 原不可见 `SealNode` 复用 `shrine_gate_prop_atlas_ai01.talisman_stake_idle` 补为可读符印目标，不新增 Image Gen。四房继续使用正式 terrain collision / surface，区域旧 TileSet 只作隐藏来源引用。
- Batch 6 / Stage13 支路与终点：复用三类 route marker、两种奖励 marker、Miasma Caster、封印门和 GoalDevice；Hub、Resource、Challenge、Return、Goal 只重排运行接入与碰撞，不新增 Image Gen。Stage13 全区域继续以单张瘴泽背景不同取景和正式 collision / surface 为基线。
- Batch 7 / Stage14：复用 Air Dash 神龛、门预览、dash trail、三枚奖励 pedestal / crystal 和 map scrap 目标；旧整房间概念图、瘴气房图、parallax 与 tile sheet 隐藏，不作为道路或前景。三房只重排正式 collision / surface 和运行 props，无新增 Image Gen。
- Batch 8 / Stage15：复用 Boss arena 背景、双敌、Seal Guardian runtime sheet、封印焦点、hazard VFX、门禁、completion seal 和 chain anchors；旧 Boss 静态方向稿、预警整图、动画 preview、材质大图与 reusable props source sheet 隐藏。无新增 Image Gen。
- Batch 9 / Stage16：复用神龛背景、符印中继、回溯确认、净化机关、封印门和 Alpha Demo 完成反馈；五房只重排碰撞、表面、节点高度和安全落点，无新增 Image Gen。
- 39 房收口：当前运行态没有接入 `imagegen_inbox` 未登记文件、未选候选、整张 source sheet 或整房概念图。`test_room` 作为非整格机制沙盒保留精确 shape bounds 表面；其余 38 房使用正式 TileMap collision 与独立 visual-only surface。
- 样板复用结论只覆盖已验收房间，不代表这些资产可以未经房间蓝图和运行态复核直接批量铺到其余房间。

## 归档，不进入运行时

- `104` 张未选候选和重复候选。
- 失败动作帧、错误门禁切片、未批准 source sheet。
- 宣传图、CG、分镜、style board 和概念整房图。
- `imagegen_inbox` 中未建立明确 asset_id / source record / selected mapping 的文件。

归档前先核对 selected mapping，不直接删除；普通 Git 只保留最终运行资源、必要 metadata 和可重放的小体积源文件。

## 允许补生成的地图资产

- 核心 Terrain Kit 缺失的 cap、corner、cliff、ceiling、stairs / ramp、door threshold、hazard edge、breakable / secret wall。
- 神龛与瘴泽区域的同语义视觉变体。
- 可拆分的区域前景 / 中景 props 和 `2-3` 层可延展背景。
- 当前 props atlas 无法表达的房间地标。

## 禁止直接生成后上屏

- 未先定义网格和语义的大型随机 tilesheet。
- 把整房概念图切成碰撞地形。
- 没有 left / center / right 或 corner 连续验证的平台和地面。
- 未验证 alpha、切片、脚底基线、collision polygon 和 terrain peering 的 Image Gen 输出。

## 资产通过标准

- 语义名称、使用层和碰撞角色明确。
- 游戏距离下能区分可踩面、背景、危险、门和奖励。
- TileSet 边缘连续，caps / corners 只出现在正确位置。
- 静态 terrain tile 的视觉与碰撞一致。
- 运行态截图通过后才允许复制到其它房间。
