# 宏观银河城世界图重构设计

## 文档定位

本设计回应当前 Alpha Demo“微观房间已整理、宏观仍是 34 房阶段长链”的问题。用户直接要求将现有内容重组为至少 3 个区域环路、4–6 条远端捷径，并让 Air Dash、Stage13 支路和锚点房承担真实回访价值。

这次工作会偏离既有“先做最小元素与姿态切片”的推荐顺序，原因是用户明确把宏观关卡结构列为当前目标。偏离范围只限现有房间图、轻量探索状态和锚点交互；不新增敌人类别、战斗核心、正式存档、地图 UI 或传送系统。完成后仍回到 `2 元素 + 2 姿态 + 2 步序列` 的北极星战斗切片。

## 设计结论

- 不新增大批房间，复用当前 34 个主线房和 4 个支线房。
- 保留首次通关的安全主路线，新增路线只形成可选环路、回访捷径或风险更高的替代路径。
- 统一复用现有 `room_transition_requested`、`spawn_positions`、`get_hud_context()` 与 Main 跨房状态，不建立第二套地图管理器。
- Air Dash 至少重新打开 Stage9 和 Stage10 各一条此前可见但不可达的路径。
- Stage13 两条支路不再汇入同一房：资源支路回到旧 checkpoint，挑战支路前送到区域目标。
- 支路奖励必须产生跨房效果，不再只做本房计数。

## 三个区域环路

### 环路 A：镇妖试炼上层回路

```text
Stage9 Switch -> Stage9 Final -> Stage10 Aerial
       |                              |
       +-- Air Dash + 瘴泽遗物 --> Stage10 Branch --+
                                      ^              |
                                      +--------------+
```

- `Stage9 Switch <-> Stage10 Branch` 成为双向远端捷径。
- Stage9 入口第一次经过时只看见上层封印通路；取得 Air Dash 且拿到 Stage13 资源支路的“瘴泽遗物”后才能进入。
- `Stage10 Aerial <-> Stage13 Entry` 形成第二条 Air Dash 双向远端连接，减少完整回访时重复穿过 Stage10 Challenge 与 Stage11 终点大厅。

### 环路 B：瘴泽分流回路

```text
Stage13 Checkpoint -> Pressure -> Branch Hub -> Return -> Goal
        ^                            |                 ^
        |                            +-> Resource -----+
        |                                  |
        +----------------------------------+
                                     +-> Challenge ----+
```

- 主路仍为 `Hub -> Return -> Goal`。
- 资源支路：无敌或低压探索、秘密墙、瘴泽遗物；出口改到 `Checkpoint`，形成安全回环。
- 挑战支路：瘴气、敌群和清场门；获得镇妖挑战符后出口改到 `Goal`，形成高风险前送路线。
- 两条支路在路线、风险和长期收益上都不同。

### 环路 C：神龛至封妖禁地回路

```text
Stage14 Hub -> Loop Return -> Stage15 Pressure -> Gauntlet
     |                                                |
     +-- 镇妖挑战符捷径 --> Stage15 Challenge <-------+
```

- `Stage14 Hub <-> Stage15 Challenge` 成为双向高风险捷径。
- 捷径要求 Stage13 挑战支路取得的“镇妖挑战符”；进入后仍需完成挑战房并汇入 Gauntlet，不跳过 Boss。
- 普通路线保留恢复和压力递进；捷径路线更短但直接进入危险房。

## 5 条远端连接

| ID | 连接 | 类型 | 条件 | 作用 |
| --- | --- | --- | --- | --- |
| SC-01 | Stage9 Switch <-> Stage10 Branch | 双向捷径 | Air Dash + 瘴泽遗物 | 重新打开早期上层封印路 |
| SC-02 | Stage10 Aerial <-> Stage13 Entry | 双向捷径 | Air Dash | 缩短跨区域回访 |
| SC-03 | Stage13 Resource -> Stage13 Checkpoint | 单向回环出口 | 无 | 安全资源支路回到旧节点 |
| SC-04 | Stage13 Challenge -> Stage13 Goal | 单向前送出口 | 清场 | 高风险支路前送到区域目标 |
| SC-05 | Stage14 Hub <-> Stage15 Challenge | 双向捷径 | 镇妖挑战符 | 形成高风险替代路线 |

单向连接必须以落差、封印滑道或单向门表现；其余捷径默认双向，并配置独立 spawn 和安全落点。

## 持久探索收益

Main 只新增一个按 ID 去重的探索收益字典，不引入物品栏或经济系统。

| ID | 来源 | 长期作用 |
| --- | --- | --- |
| `marsh_relic` | Stage13 Resource Branch | 与 Air Dash 共同开启 SC-01 |
| `warden_sigil` | Stage13 Challenge Branch | 开启 SC-05 |

这两个状态通过 Main 快照暴露给 HUD、房间和测试；重开 Demo 时清空，换房和失败恢复时保留。

## 12 个锚点房

| 房间 | 主要新增职责 |
| --- | --- |
| Tutorial | 第一块佛门训练碑，说明镇妖卫试炼背景 |
| Stage9 Entry | 区域地标与被封上层路线预示 |
| Stage9 Switch | 环路 A 机关与 SC-01 入口 |
| Stage10 Aerial | SC-02 上层 Air Dash 路线 |
| Stage10 Branch | 秘密墙、瘴泽前兆碑、SC-01 返回端 |
| Stage13 Entry | 瘴泽区域碑与 SC-02 返回端 |
| Stage13 Gate | 区域机关地标，强化符印门语义 |
| Stage13 Branch Hub | 三路地标与风险提示 |
| Stage13 Resource Branch | 秘密墙、瘴泽遗物、回环出口 |
| Stage13 Challenge Branch | 危险机关、镇妖挑战符、前送出口 |
| Stage14 Shrine / Hub | 能力叙事碑、回访收益与 SC-05 入口 |
| Stage15 Challenge | 封妖禁地地标与 SC-05 返回端 |

其中 `Stage14 Shrine / Hub` 作为同一能力锚点组计算；实际改动仍落在两个现有房间。

## 最小共享契约

### 房间基类

`Stage9RoomBase` 新增通用可选捷径字段和触发：

- `shortcut_room_path`
- `shortcut_spawn_id`
- `shortcut_requires_air_dash`
- `shortcut_required_reward_id`
- 场景节点固定名 `ShortcutZone`

基类通过已绑定 Player 判断 Air Dash，通过已绑定 Main 查询持久探索收益。没有 `ShortcutZone` 的房间行为不变。

同一基类新增可选叙事碑字段和节点：

- `narrative_stele_title`
- `narrative_stele_text`
- 场景节点固定名 `NarrativeStele`

玩家靠近时只临时替换 HUD 标题与提示，离开后恢复原房间文本；不新增对话框系统。

### 秘密墙

新增一个最小 `BreakableSecretWall` 静态节点脚本：接收现有 `receive_attack(...)`，首次命中后禁用碰撞并隐藏。只在 Stage10 Branch 与 Stage13 Resource Branch 使用，不抽象破坏物系统。

### Main

Main 新增：

- `collect_exploration_reward(reward_id)`
- `has_exploration_reward(reward_id)`
- `get_exploration_reward_count()`

Stage13 奖励房通过现有 `bind_main` 路径写入状态；HUD 快照只显示简短探索收益数量和当前捷径是否可用。

## 首次通关与回访规则

- 新玩家不需要走任何捷径即可从 Tutorial 到 Stage16 终点。
- Air Dash 取得前，SC-01 和 SC-02 只提供视觉预示，不能触发切房。
- 不取得资源支路奖励时，SC-01 保持关闭，但主线不受影响。
- 不完成挑战支路时，SC-05 保持关闭，但 Stage14 到 Stage15 普通路线不受影响。
- 捷径不得跳过 Stage15 Boss 或 Stage16 最终封印链。

## 验收口径

1. 静态世界图测试证明存在至少 3 个独立环路和 5 条远端连接。
2. 34 房首次通关主路线仍可到达 Stage16 终点。
3. Air Dash 前 SC-01 / SC-02 不可用，取得能力后按奖励条件正确开放。
4. Stage13 Resource 和 Challenge 的出口、风险节点与持久奖励均不同。
5. 12 个锚点房能在场景树中找到对应秘密墙、机关、叙事碑或地标职责。
6. 正向、反向 spawn 都有安全落点，不在出口触发区内重生。
7. 相关 GUT、全量 GUT、Godot import、主场景 smoke 和输入式主路线 replay 取得新鲜证据。

## 非目标

- 不新增房间图编辑器、通用任务系统、背包、正式存档、地图 UI、传送点或快速旅行菜单。
- 不新增第三种持久货币或奖励类型。
- 不为锚点房生成新美术包；优先复用现有 TileSet、prop atlas、equipment atlas 和 VFX。
- 不重写玩家移动、敌人 AI、Boss、HUD 框架或现有 39 房地形蓝图。
