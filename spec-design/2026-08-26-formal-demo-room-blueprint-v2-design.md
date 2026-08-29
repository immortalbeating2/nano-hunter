# 正式 Demo 房间蓝图 V2 补全设计

## 文档定位

本设计延续已批准的方案 B，不推翻 F01–F18 正式切片、现有房间场景或房间切换架构。它修正 2026-08-13 结构蓝图的完成边界：原蓝图已经冻结房间职责、拓扑、屏幕分段、主要路线、移动标尺和基础安全合同，但不足以直接作为完整类银河恶魔城房间施工模板。

本设计成为“完整房间玩法蓝图”的新增权威；以下文档继续保留各自职责：

- 总体房间重构：`spec-design/2026-08-13-formal-demo-room-design-recovery.md`
- 结构蓝图历史基线：`spec-design/2026-08-13-formal-demo-room-spatial-blueprints.md`
- 现有机器清单：`spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json`
- 本阶段正式计划：`plan/2026-08-26-formal-demo-room-blueprint-v2.md`
- 逐项执行清单：`docs/implementation-plans/2026-08-26-formal-demo-room-blueprint-v2.md`

冲突时，本设计只在“蓝图完整度、字段合同和后续施工顺序”上取代旧结构蓝图；F01–F18 的既定房间身份、正式路线和北极星仍以旧设计与当前代码为准。

实现状态（2026-08-26）：本规格已由 BPV2-01–09 落入唯一机器蓝图，`18/18` 房为 `gameplay_blueprint_complete`，`48/48` 屏段和两类逐房视图完整；当前成熟度是完整玩法蓝图候选，尚未提升生产场景采用状态。

## 决策

采用用户批准的推荐方向：

> B-Full 完整玩法蓝图 V2 + 强引导主线 + 开放可选支路 + F14/F16 局部精密动作挑战。

设计目标不是把每个房间塞满机制，而是确保每个房间都能回答：

1. 玩家为什么进入这里？
2. 玩家在这里观察、学习、战斗、选择或恢复什么？
3. 玩家如何理解每个出口、门控、捷径和失败结果？
4. 新能力或世界状态如何改变这个房间？
5. 该房间在首次路线、回访和熟练路线中分别有什么价值？
6. 关卡、美术、镜头、地图和音画反馈如何共同表达同一玩法事实？

## 根因与边界

现有 `schema_version: 1` 的核心房间字段为：

- `id/title/role/scene`
- `segment_count/landmark/persistent_state`
- `routes/zones/segments`
- 每屏 `purpose/geometry/pressure/safety`

这些字段足以生成结构拓扑图，但不能完整冻结：

- 玩家交互动作与失败反馈；
- 连接两端 Spawn、朝向与防反弹；
- 敌人数量、波次、锁区、绕行与重置；
- 能力授予、能力门状态和回访变化；
- 奖励价值、条件和持久生命周期；
- 相机边界、锁镜、预读与反向构图；
- 地图揭示、门图标和回访提示；
- 环境地标、视差、遮挡、安全轮廓与音画意图；
- 逐房自动和真人验收。

F12/F09 与 F14/F07/F15 的局部修正证明，单有拓扑节点不足以保护真实玩家路线。本阶段从数据真源补齐这些缺口，不继续依赖运行中发现问题后逐房追加例外。

## 管线合同

- `map_mode`: `side_scroll_mode`
- `engine_target`: Godot `4.6.3` project-native
- `visual_model`: 本阶段为机器蓝图和审阅图，不生成正式运行美术
- 运行目标：`parallax_layers + platform_objects + interactive_scene_objects + foreground_occluders + scene_hooks + precise_shapes`
- 逻辑镜头：沿用 `640×360u`
- 基础网格：沿用 `32u`
- 移动标尺：沿用生产 Player 的 `24×40u` 碰撞体、普通跳、Dash 与约 `110u` Air Dash 实测
- 结构几何以数据和引擎节点为真源，不从背景像素推断碰撞
- 本阶段不修改生产 `.tscn`、Main、Player、敌人、存档或 InputMap

## Blueprint V2 顶层合同

现有 JSON 原位升级到 `schema_version: 2`，不创建第二份房间真源。顶层至少增加：

### `blueprint_contract`

记录 V2 必填字段、允许的房间例外和完成状态。任何房间缺少必填组时，不得标记为 `gameplay_blueprint_complete`。

### `connection_vocabulary`

统一连接类别、玩家动作和表现语义：

| 类别 | 玩家动作 | 典型表现 | 允许自动切房 |
| --- | --- | --- | --- |
| `adjacent_boundary` | 穿越连续边界 | 山口、坡道、洞口、栈道、雾幕 | 是 |
| `architectural_door` | 明确确认或穿过已开门洞 | 与建筑连续的门扇/门洞 | 仅已开放时 |
| `ability_gate` | 使用指定能力 | 符印、瘴幕、断层、高台 | 否；能力动作成功后才进入 |
| `encounter_gate` | 清场 | 妖气结界消散 | 清场后允许 |
| `remote_waystation` | 接近并确认 | 驿路法坛、祭坛、传送机关 | 否 |
| `one_way_terrain` | 下落、滑行或塌陷 | 井道、滑道、塌桥 | 是，需预读不可逆性 |
| `boss_gate` | 条件满足后确认进入 | 唯一重型封印建筑 | 否 |

设计字段使用语义动作 `cross/confirm/attack/ground_dash/air_dash/clear/fall_or_slide`。当前 F07/F14 可继续由实现映射到 `ui_down`，本阶段不增加新的全局交互键。

### `progression_state_matrix`

冻结至少五个设计状态：

1. `first_visit`
2. `wind_seal_unlocked`
3. `air_dash_unlocked`
4. `marsh_goal_completed`
5. `seal_guardian_defeated`

矩阵必须说明每个状态对连接、敌人、危险、奖励、地图、地标和提示的影响。

### `encounter_curve`

冻结 18 房压力波形：

```text
教学与首次胜利 -> Hub -> 区域揭示 -> 单机制教学
-> 环境危险 -> 能力门预告 -> 恢复 -> 分支选择
-> 低风险奖励 / 高风险战斗 -> 区域目标 -> 能力授予
-> 能力证明 -> 回访集结 -> 综合战斗 -> Boss -> 降压返回
```

### `presentation_contract`

记录地标、视差层、结构资产、互动资产、前景遮挡、安全轮廓、色彩和音画提示。它只定义生产需求和可读性，不批准任何正式资产。

### `acceptance_contract`

区分：

- JSON/SVG 结构验证；
- 设计审阅；
- 生产场景采用；
- 自动路线验证；
- 真人灰盒；
- 正式美术与发布签核。

前一层通过不能自动提升后一层状态。

## Blueprint V2 单房合同

每个 F01–F18 房间除现有字段外，必须补齐以下字段组。

### 1. `player_knowledge`

- `knows_on_entry`
- `learns_here`
- `remembers_for_revisit`
- `knows_on_exit`

### 2. `timing_and_rhythm`

- 首访预计停留时间；
- 回访预计停留时间；
- 压力等级和节拍；
- 房间前后的节奏对比；
- 捷径目标节省时间。

### 3. `connections`

每条连接记录：

- `connection_id/type/target_room`
- `target_spawn_id/position/facing`
- `directionality`
- `interaction_verb`
- `requirements`
- `blocked_feedback`
- `transition_feedback`
- `safe_arrival_contract`
- `anti_retrigger_contract`
- `map_representation`

### 4. `interactions`

每个门、神龛、祭坛、机关、目标和 checkpoint 记录：

- 世界物件和用途；
- 交互动作、范围和面向要求；
- `locked/available/activated/completed` 状态；
- 条件不足、成功、重复操作反馈；
- 状态写入方与持久性。

### 5. `encounters`

每场遭遇记录：

- 敌人类型、数量、位置和预读；
- 触发条件、波次和锁区；
- 地形与能力考点；
- 可退出、可绕过或必须清场；
- 失败与回访重置；
- 清场后的永久变化。

安全房允许 `encounters: []`，但必须显式说明为什么安全。

### 6. `hazards_and_recovery`

- 危险预读；
- 伤害、击退、跌落和恢复规则；
- 安全回落层与最近重试点；
- 失败后重置对象；
- 不依赖 Main 越界恢复的证明。

### 7. `rewards`

- 奖励 ID、类型、价值和获取条件；
- 可见性和支路成本；
- 重复领取规则；
- 领取后的世界与地图反馈。

### 8. `state_variants`

逐一记录本房在顶层 progression states 下的：

- 路线；
- 门控；
- 敌人；
- 危险；
- 奖励；
- 地标/提示；
- 地图状态。

### 9. `camera`

- 正向和反向入口构图；
- 每段相机边界与垂直范围；
- look-ahead、锁镜和解除；
- 出口、危险、奖励与门控预读；
- Boss arena 特殊规则。

### 10. `presentation`

- 主地标和空间叙事；
- 地表、平台、建筑和互动资产职责；
- `sky/far/mid/near/foreground` 视差意图；
- 前景遮挡分类、角色安全区和淡出策略；
- 能力、门控、奖励、checkpoint 的 VFX/SFX 意图；
- 资产复用或新增需求。

背景只承担非碰撞远景。平台、门、危险、checkpoint 和出口必须是可独立控制的结构对象。

### 11. `map_semantics`

- 房间揭示时机；
- 主出口、未开门、能力门、祭坛、checkpoint、奖励和秘密图标；
- 世界状态变化后的地图更新；
- 主线提示和秘密提示强度。

### 12. `qa`

- 正反向自然输入路线；
- Spawn 支撑与防反弹；
- 无软锁、假跌落、不可见出口；
- 移动标尺与视觉净空；
- 3–5 秒读路；
- 捷径发现和节省时间；
- 失败恢复；
- 真人验收指标。

## 逐房补全目标

| 房间 | 必须冻结的完整玩法重点 |
| --- | --- |
| F01 | 四段教学触发、无死亡坑、回落、提示、快速回访与连续出口 |
| F02 | 观察单敌、战区、清场、悬令确认、回访永久开放和不重复发奖 |
| F03 | 多入口 Hub、checkpoint、赏榜、F04 相邻道路、F18 法坛回程和地图更新 |
| F04 | 区域揭示、跨房地标、瘴气预告、能力门远景、正反构图与视差意图 |
| F05 | 看弹体、风印授予、移动应用、单施法敌遭遇、授予状态和回访旁路 |
| F06 | 上层首访、下层瘴气、可见回访奖励、Air Dash 高速线、恢复和相机底边 |
| F07 | F08 普通出口、双能力封印、F14 主动祭坛捷径、四态反馈和防反弹 |
| F08 | 无敌恢复、checkpoint 状态、F10 单向落点、方向重置和出口隔离 |
| F09 | 安全选择区、三高度四路线、下穿输入、Air Dash 快线、视觉净空和地图语义 |
| F10 | 可读破墙、低风险遗物、单向滑道回 F08、奖励持久状态和秘密提示 |
| F11 | 可退入口、双层敌人组合、锁区、清场、挑战符、前送 F12 和回访旁路 |
| F12 | F09/F11 汇流、主动封印目标、可见路线封口、F09 返回、F13 出口和地图更新 |
| F13 | 安全神龛交互、Air Dash 授予、输入保护、已激活状态和立即可读出口 |
| F14 | 展示、练习、失败回落、真实 Air Dash 证明、F15 主路和 F07 下层祭坛分离 |
| F15 | F06/F07/F09 回访状态、F07 必需而其余可选、Boss 路线和耗时对比 |
| F16 | 四段综合遭遇、三类敌人、能力替代路线、锁区、清场门和失败局部重置 |
| F17 | 前室 checkpoint、Boss 门、锁镜 arena、读招、10–25 秒重试、胜利状态和 F18 出口 |
| F18 | 战后降压、结果反馈、主动法坛返回 F03、完成奖励与 Hub 状态更新 |

## 审阅图交付

每房只维护一份机器数据，避免平行文档漂移；由同一数据生成两类 SVG：

1. `topology`：保留现有俯视路线、连接、回环和状态节点；
2. `side_view_gameplay`：横版地形、平台、危险、交互、敌人、Spawn、相机和安全回落。

`side_view_gameplay` 使用四层图例：

- 空间与移动；
- 遭遇与危险；
- 交互、门控和状态；
- 相机、地标和表现意图。

现有 F04–F09 `actual/overlay` 是生产 `.tscn` 反向审计，不与 V2 设计施工图混为一谈。后续施工阶段才将两者叠加检查。

## 完成门禁

### 机器门禁

- `schema_version=2`；
- `18/18` 房必填字段组完整；
- `48/48` 屏段具备空间、压力、安全、相机和表现职责；
- 所有连接具备来源、目标、双端 Spawn、动作、条件、反馈和地图语义；
- 所有能力门、机关、奖励和 checkpoint 具备状态生命周期；
- 所有战斗房具备敌人编排和重置；安全房显式为空遭遇；
- 每房至少一条自然输入 QA 路线；
- 两类 SVG 和总览可确定性再生成；
- 旧结构蓝图引用无断链。

### 设计审阅门禁

- 每房主要职责唯一；
- 连续三个房间不得使用同一空间和压力节拍；
- 玩家能区分普通出口、能力门、战斗结界、祭坛捷径和 Boss 门；
- F06/F07/F09 在 Air Dash 前后均有明确差异；
- F09 四路线可预读且选择区安全；
- F14 主路与 F07 捷径不共享触发语义；
- F18 只能通过明确法坛返回 Hub；
- F01–F18 预计总时长仍落在 `30–45` 分钟。

本阶段完成只能称为“完整玩法蓝图候选”。它不证明生产场景、真人手感、正式美术或发布候选完成。

## 非目标

- 不重写 `room_transition_requested` 或 Main 切房；
- 不增加第二套交互、地图或存档管理器；
- 不修改生产 `.tscn`；
- 不生成正式背景、平台、门、机关、敌人或音频资产；
- 不新增正式房间、第二生态区、敌人类型或玩家能力；
- 不以 SVG 图面完整代替真人灰盒；
- 不在 Blueprint V2 冻结前继续批量施工 F01–F03、F10–F18。

## 后续阶段

Blueprint V2 冻结后：

1. 先重新叠加审计 F04–F09，确认现有生产灰盒与 V2 的交互、遭遇、相机和状态要求一致；
2. 再按房间簇施工 F01–F03、F10–F12、F13–F15、F16–F18；
3. 完成真实输入和真人灰盒；
4. 结构通过后，才为各屏生成 in-world stage reference，并进入分层场景美术和结构资产生产。
