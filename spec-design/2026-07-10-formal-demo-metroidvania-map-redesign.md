# Formal Demo Metroidvania Map Redesign

## 目标

把当前 39 个可运行房间从“流程可通、资产已引用”的 Alpha 灰盒，重做为正式 Demo 级类银河恶魔城地图。保留已经成立的玩家手感、敌人、门控、房间连接、checkpoint 和回溯状态，只重做房间尺度、玩法节拍、静态地形、敌人空间与环境构图。

本设计不把自动截图 `P0/P1/P2=0` 当作正式地图完成；最终验收必须同时证明房间可玩、可读、可区分、可回溯。

## 基础尺度

- 逻辑网格固定为 `64px`。
- 基准世界视野固定为 `640x360`，约 `10x5.6` 格；高分辨率只放大 Camera2D，不扩大设计视野。
- 出生点、门口、checkpoint 和出口至少保留 `3` 格连续安全地面。
- 普通跳台最小宽度 `2` 格；需要稳定战斗落脚时使用 `3-5` 格。
- 同一房间连续 `0.75-1.5` 屏必须出现一个有效玩法节拍：移动判断、战斗、门控、分支、奖励、地标揭示或回溯确认。

## 房间原型与尺寸分级

| 原型 | 推荐网格 | 主要职责 |
| --- | --- | --- |
| 连接 / 安全房 | `10-15 x 6` | 区域过渡、短叙事、恢复、入口缓冲 |
| 教学 / 标准房 | `20-30 x 6-10` | 2-4 个线性玩法节拍 |
| 能力门 / 移动挑战 | `24-36 x 8-14` | 能力展示、失败回落、门前后安全落点 |
| 战斗场 | `18-28 x 8-12` | 敌人分层、走位路线、清场门控 |
| 枢纽 / 支路房 | `24-40 x 12-20` | 2-4 个出口、上下层分流、捷径和奖励 |
| Boss 房 | `18-26 x 8-12` | 读招空间、边界安全、失败重试和胜利出口 |

尺寸由玩法职责决定，不统一把所有房间拉长。现有 `960x384` 房间继续用于连接房和短遭遇，其它房间按原型重新确定 Camera Limits 与地形网格。

## 房间节拍契约

每个正式房间至少包含：

1. 入口安全区：玩家进房后能识别方向，不立刻受击或坠落。
2. 场景建立：一个可辨识地标、轮廓或高度变化说明房间主题。
3. 核心玩法：本房唯一主要职责，避免同一小房堆叠无关机制。
4. 结果反馈：门开启、捷径、奖励、checkpoint 或路线确认。
5. 出口安全区：出口前后保留落点，反向进入时同样成立。

教程房可在一个场景中容纳四段教学，但必须用建筑轮廓、地标和高度变化分成四个子区，不再表现为一条空走廊。

## 类银河恶魔城地图结构

- 区域主路必须包含入口、压力提升、checkpoint、能力 / 目标验证和区域终点。
- 每个主要区域至少包含一个可选支路、一个回环或捷径、一个回溯收益点。
- 能力门必须同时设计首次阻挡、获得能力后的验证、反向通过和安全失败回落。
- 支路奖励必须能从主路读到诱因，但不能让背景装饰冒充路线。
- 房间连接先由世界图和玩法方向决定，再布置 TileMap；不得从现有 atlas 随机拼出路线。

## TileMapLayer 契约

| 层 | 碰撞 | 内容 |
| --- | --- | --- |
| `BackgroundFar` | 无 | 远景、天空、山体、建筑剪影 |
| `BackgroundMid` | 无 | 中景建筑、树、链条、符纹 |
| `TerrainSolid` | TileSet solid | 正式静态地面、墙、天花板、断崖 |
| `TerrainOneWay` | TileSet one-way | 薄平台、可下落平台 |
| `HazardVisual` | 无 | 尖刺、瘴气、火焰等危险读值 |
| `Decor` | 无 | 裂纹、苔藓、残旗、支撑、碎石 |
| `Foreground` | 无 | 前景遮挡和边缘框景，不遮玩家路线 |

门、机关、电梯、移动平台、破坏墙、敌人、危险 Area、出口、出生点和 checkpoint 保持独立场景节点。正式静态地形的视觉和碰撞必须在同一个语义 TileSet tile 中一致；当前 tutorial 的低透明碰撞层加独立视觉层只作为过渡实现。

## Terrain Kit 语义

正式核心 Terrain Kit 至少覆盖：

- `flat_center / left_cap / right_cap`
- `outer_corner / inner_corner`
- `cliff_top / cliff_side / cliff_bottom`
- `ceiling_center / ceiling_cap`
- `one_way_left / center / right`
- `stair_up / stair_down / ramp`
- `door_frame / door_threshold / transition`
- `hazard_left / center / right`
- `breakable_wall / secret_wall`
- `support / crack / vine / hanging / foreground_edge`

核心几何语义稳定后，再做神龛与瘴泽区域视觉变体。Image Gen 只补缺失语义源图；边缘连续、透明度、切片、collision polygon 和 terrain peering 必须在资产接入阶段人工或脚本校准。

## 三类正式样板

### tutorial_room

- 原型：教学 / 标准房。
- 尺寸：保留 `24x6` 起步，按四段教学切成移动入口、跳跃台、dash 门、训练封印四个子区。
- 必须新增：子区地标、有限中景支撑、入口 / 门口轮廓、训练区焦点。
- 保留：教程步骤、阈值、训练目标、出口门控和下一房连接。

### stage14_air_dash_gate_room

- 原型：能力门 / 移动挑战。
- 尺寸：从现有 `15x6` 扩为约 `24-30x9-12`，形成获得前阻挡、失败回落、能力执行和反向回溯路线。
- 保留：Air Dash 状态、左右出口、GateBarrier 和能力传感器。

### stage15_mixed_gauntlet_room

- 原型：战斗场。
- 尺寸：从现有 `15x6` 扩为约 `22-28x8-12`，建立地面近战层、冲锋通道、空中敌人层和挑战支路诱因。
- 保留：三类敌人、全清门控、挑战支路、checkpoint / 出口连接。

## 39 房推广批次

- 样板：`tutorial_room`、`stage14_air_dash_gate_room`、`stage15_mixed_gauntlet_room`。
- Batch 1：`test_room`、`combat_trial_room`、`goal_trial_room`。
- Batch 2：Stage9 五房。
- Batch 3：Stage10 三房与 Stage11 终点房。
- Batch 4：Stage13 entry / caster / miasma / gate。
- Batch 5：Stage13 crossfire / checkpoint / pressure / branch hub。
- Batch 6：Stage13 resource branch / challenge branch / return / goal。
- Batch 7：Stage14 shrine / backtrack hub / loop return，gate 使用样板结果。
- Batch 8：Stage15 五房，gauntlet 使用样板结果。
- Batch 9：Stage16 五房。

每批只处理 `3-5` 房，完成运行态验收后再进入下一批。

## 房间级验收

- 房间职责、主路、支路和回溯方向一眼可读。
- Luna 脚底、墙体边缘和可踩视觉与真实碰撞一致。
- 入口、出口、门控和失败回落区域均有安全落点。
- 背景、装饰和前景不被误读成道路、平台或空气墙。
- 敌人位置利用地形和高度，不只是平地横向排队。
- 同区域房间共享美术语言，但轮廓、地标和玩法节拍可区分。
- 正向与反向房间连接、checkpoint、能力门和回溯收益链均可运行。
- 每房保存入口、核心玩法、出口三处运行态截图；批次完成后跑完整流程试玩、相关 GUT、Godot import 和差异检查。

## 非目标

- 不重写玩家、敌人 AI、门控状态机或存档系统。
- 不一次性生成 39 房全部新美术。
- 不在三类样板验证前抽象通用房间生成器。
- 不把宣传图、CG、分镜或未批准候选当作地图运行资产。
