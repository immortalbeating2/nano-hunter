# Alpha Demo 44 房间蓝图核对矩阵

## 文档定位

本表把当前 `44` 个正式地图房间逐一落到同一套核对口径：职责与平台节拍、出入口、敌人、陷阱 / 危险、门控 / 机关、奖励、叙事 / 地标。它回答“当前每个房间实际承担什么”，不把所有空栏都误判为待加内容。

- 精确坐标、碰撞、出生点和节点位置仍以对应 `.tscn` 为真源。
- 实际切房以场景导出字段与房间脚本为真源；地图编号、展示坐标和远端连接条件以 `assets/configs/world_map/alpha_demo_world_map.json` 为真源。
- `—` 表示刻意留白，不表示漏做。恢复房、连接房、能力房和战后降压房允许没有敌人或伤害陷阱。
- `test_room` 是 Stage1–4 机制沙盒，不属于正式世界图，因此不进入本表。

## 序章与镇妖试炼

| 编号 / 房间 | 职责与平台节拍 | 出入口 | 敌人 | 陷阱 / 危险 | 门控 / 机关 | 奖励 | 叙事 / 地标 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `01 tutorial_room` | 移动、跳跃、Dash、攻击四段教学；主路、单向跳台和低顶 Dash 缺口 | 起点；右进 `02` | 1 Dummy | Dash 失败回落区 | Dash gate、训练目标、出口封印门 | 教学进度 | `NarrativeStele`、试炼碑 |
| `02 combat_trial_room` | 单层主战面加短上层；首次单敌清场 | 左返 `01`；右进 `03` | 1 Melee | — | 清敌后解除 `ExitBarrier` | — | 首次清场试炼 |
| `03 goal_trial_room` | 下层战斗后登上右侧目标台 | 左返 `02`；目标完成后进 `04` | 1 Melee | — | 清敌门、上层 `GoalZone` | Goal token / 推进标记 | 序章目标台 |
| `04 stage9_zone_entry_room` | 安全揭示房；低压主路和观察台 | 左返 `03`；右进 `05` | — | — | `RegionCheckpoint` | 检查点 | 镇妖区域入口地标 |
| `05 stage9_zone_combat_room` | 双层基础战，建立上下层追击 | 左返 `04`；右进 `06` | 1 Melee | — | 清敌门 | — | — |
| `06 stage9_zone_charger_room` | 长直冲锋带，减少可躲纵深 | 左返 `05`；右进 `07` | 1 Charger | 冲锋通道压力 | 清敌门、房内 checkpoint | 检查点 | 冲锋回廊 |
| `07 stage9_zone_switch_room` | 两级机关路线；首次流程即可选择上层支路 | 左返 `06`；右进 `08`；SC-01 通往 `A` | — | — | `GateSwitch`、`GateBarrier`；SC-01 无额外能力要求 | — | 早期第二路线入口 |
| `08 stage9_zone_final_room` | 上下层混合终点战 | 左返 `07`；右进 `09` | 1 Melee + 1 Charger | — | 全清门 | — | 镇妖前庭收束 |
| `09 stage10_zone_aerial_room` | 三层空中价值主房 | 左返 `08`；右进 `10`；普通支路进 `A`；SC-02 往返 `12` | 1 Charger + 1 Aerial | 高低层接敌压力 | 清敌门；SC-02 需 Air Dash | — | 上层捷径预告 |
| `A stage10_zone_branch_room` | 两级上行的恢复 / 收集支路 | 从 `09` 或 SC-01 进入；左出 `07`；右返 `09` | 1 Aerial | 秘密墙是探索阻挡，非伤害陷阱 | 清敌门、`SecretWall` | `RecoveryPoint`、风印 | `NarrativeStele`、隐藏支路地标 |
| `10 stage10_zone_challenge_room` | 三层三敌挑战 arena | 左返 `09`；右进 `11` | 1 Melee + 1 Charger + 1 Aerial | 多高度混合接敌压力、循环 `SealPulseHazard` | 全清门 | `ChallengeCollectible` | 镇妖试炼高潮 |
| `11 stage11_demo_end_room` | 无战斗安全驿厅；中央确认、左右旧路、悬赏榜与雷泽路印分流 | 确认后左返 `10`；右进 `12`；SC-07 通往 `35` | — | — | 中央 `GoalZone`、悬赏榜、进入即 checkpoint；SC-07 需三条悬赏全部回交 | 检查点、雷泽荒原路引 | 首次确认触发一次正式封印回响剧情；不是完整 Demo 终点 |

## 瘴泽分流

| 编号 / 房间 | 职责与平台节拍 | 出入口 | 敌人 | 陷阱 / 危险 | 门控 / 机关 | 奖励 | 叙事 / 地标 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `12 stage13_miasma_marsh_entry_room` | 安全落点与区域揭示平台 | 左返 `11`；右进 `13`；SC-02 往返 `09` | — | — | `RegionCheckpoint`；SC-02 需 Air Dash | 检查点 | `NarrativeStele`、瘴泽入口 |
| `13 stage13_miasma_marsh_caster_room` | 三层定向弹体教学 | 左返 `12`；右进 `14` | 1 Caster | 可被风印攻击斩散的腐瘴弹体 | 清敌门 | — | 妖术伏击 |
| `14 stage13_miasma_marsh_miasma_room` | 下层危险带、两段上层绕行 | 左返 `13`；右进 `15` | — | `MiasmaHazard` | 上层 bypass | — | 首次瘴气危险教学 |
| `15 stage13_miasma_marsh_gate_room` | 两级上行触符印，再回下层过门 | 左返 `14`；右进 `16`；SC-06 往返 `23` | — | — | `SealNode`、`GateBarrier`；SC-06 需风印 + Air Dash | — | 封印门机关与交叉能力回访口 |
| `16 stage13_miasma_marsh_crossfire_room` | 三层交叉弹体火力 | 左返 `15`；右进 `17` | 2 Caster | 双向定向腐瘴弹体 | 主路推进 | — | — |
| `17 stage13_miasma_marsh_checkpoint_room` | 恢复大厅与单观察台 | 左返 `16`；右进 `18`；接收 `B` 的 SC-03 | — | — | `RecoveryPoint` | 检查点 / 恢复 | 瘴泽缓冲点 |
| `18 stage13_miasma_marsh_pressure_room` | 下层瘴气、上层绕行、右侧弹体压制 | 左返 `17`；右进 `19` | 1 Caster | `MiasmaHazard`、定向腐瘴弹体 | 上层 bypass | — | 压力升级 |
| `19 stage13_miasma_marsh_branch_hub_room` | 主路、资源、挑战三高度分叉 | 左返 `18`；主路进 `20`；支路进 `B` / `C` | — | — | `ResourceBranchZone`、`ChallengeBranchZone`、主路出口 | — | 三路选择地标 |
| `B stage13_miasma_marsh_resource_branch_room` | 低风险两级奖励路线 | 从 `19` 进入；SC-03 单向回到 `17` | — | 秘密墙是探索阻挡，非伤害陷阱 | `SecretWall` | `marsh_relic` Build：恢复充能获取量 ×1.5 | 瘴泽遗物藏所 |
| `C stage13_miasma_marsh_challenge_branch_room` | 三层法师挑战与门后回报 | 从 `19` 进入；清场后 SC-04 单向前送 `21` | 1 Caster | `MiasmaHazard`、定向腐瘴弹体 | 全清门 | `warden_sigil` Build：攻击横向判定 +16px | 镇妖挑战祭台 |
| `20 stage13_miasma_marsh_return_room` | 支路 / 主线汇流后的降压连接 | 左返 `19`；右进 `21` | — | — | — | — | 汇流节拍 |
| `21 stage13_miasma_marsh_goal_room` | 区域目标大厅与上层祭器 | 从 `20` 或 `C` 进入；完成后进 `22` | — | — | `GoalDevice`、`GoalZone` | 区域推进标记 | 瘴泽封印目标 |

## 神龛回访与封妖禁地

| 编号 / 房间 | 职责与平台节拍 | 出入口 | 敌人 | 陷阱 / 危险 | 门控 / 机关 | 奖励 | 叙事 / 地标 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `22 stage14_air_dash_shrine_room` | 单一能力授予焦点 | 左返 `21`；右进 `23` | — | — | `AirDashShrine` | Air Dash | `NarrativeStele`、空冲神龛 |
| `23 stage14_air_dash_gate_room` | 起跳台、Air Dash 缺口、失败安全回落和门前落点 | 左返 `22`；右进 `24`；SC-06 往返 `15` | — | Air Dash 失败回落区、循环 `SealPulseHazard` | `AirDashGateSensor`、`GateBarrier`；SC-06 需风印 + Air Dash | — | 能力证明房与交叉能力回访口 |
| `24 stage14_backtrack_hub_room` | 三层递进回溯收益 | 左返 `23`；右进 `25`；SC-05 通往 `D` | — | 平台落差，非伤害陷阱 | SC-05 需 `warden_sigil` | `BacktrackReward` ×3 | 回溯枢纽 |
| `25 stage14_loop_return_room` | 两段上行后的回环确认 | 左返 `24`；上层目标进 `26` | — | — | 上层 `GoalZone` | 区域推进标记 | 回环出口 |
| `26 stage15_seal_pressure_room` | 三高度双敌前置战 | 左返 `25`；右进 `27` | 1 Charger + 1 Caster | 冲锋与定向弹体组合压力 | 全清门 | — | 封妖禁地压力焦点 |
| `27 stage15_mixed_gauntlet_room` | 近战区、冲锋通道、空中层混合战 | 左返 `26`；右进 `28`；普通支路进 `D` | 1 Melee + 1 Charger + 1 Aerial | 多高度混合接敌压力 | 全清 Boss 门、`ChallengeBranchZone` | — | Boss 前综合试炼 |
| `D stage15_challenge_branch_room` | 瘴气绕行双敌奖励支路 | 从 `27` 或 SC-05 进入；左出 `24`；右返 `27` | 1 Caster + 1 Aerial | `MiasmaHazard`、定向腐瘴弹体 | 全清门 | 挑战奖励标记；非跨房门控 | 封妖禁地高风险支路 |
| `28 stage15_seal_guardian_boss_room` | 宽 Boss arena 与左右规避平台 | 左返 `27`；胜利后进 `29` | 1 Seal Guardian | Boss 攻击；无环境伤害区 | Boss 锁门 / 胜利出口 | Boss 推进标记 | 封印守卫与 SealDais |
| `29 stage15_completion_room` | 战后降压与封印完成大厅 | 左返 `28`；右进 `30` | — | — | `CompletionSeal` | 区域完成标记 | 战后封印地标 |

## 终局封印链

| 编号 / 房间 | 职责与平台节拍 | 出入口 | 敌人 | 陷阱 / 危险 | 门控 / 机关 | 奖励 | 叙事 / 地标 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `30 stage16_seal_release_threshold_room` | 上层释放、下层过门 | 左返 `29`；右进 `31` | — | — | `SealReleaseNode`、`GateBarrier` | — | 封印链起点 |
| `31 stage16_talisman_relay_room` | 三层递进中继 | 左返 `30`；右进 `32` | — | — | `TalismanRelay A / B / C`、完成门 | — | 符印中继仪式 |
| `32 stage16_backtrack_confirmation_room` | 验证 Stage14 三个回溯收益 | 左返 `31`；右进 `33` | — | — | `BacktrackConfirmationNode`、`GateBarrier` | 无新奖励；读取既有回溯收益 | 回溯成果确认 |
| `33 stage16_corruption_purge_room` | 下层腐化危险、上层净化机关 | 左返 `32`；右进 `34` | — | `CorruptionMiasmaHazardArea` | `CorruptionPurgeNode`、`GateBarrier` | — | 妖瘴净化仪式 |
| `34 stage16_alpha_demo_end_room` | 最终封印大厅 | 左返 `33`；无后续地图房间 | — | — | `AlphaDemoSeal`、最终完成标记 | Alpha Demo 完成 | 正式终点封印 |

## 雷泽荒原

| 编号 / 房间 | 职责与平台节拍 | 出入口 | 敌人 | 陷阱 / 危险 | 门控 / 机关 | 奖励 | 叙事 / 地标 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `35 stage25_thunder_waste_entry_room` | 安全入口与低压观察平台 | SC-07 从 `11` 进入；右进 `36` | — | — | `RegionCheckpoint`；SC-07 需雷泽荒原路引 | 检查点 | 荒原界碑 |
| `36 stage25_thunder_waste_stormfield_room` | 低洼地形首次展示雷暴危险 | 左返 `35`；右进 `37` | — | `StormField` 首次触碰造成 1 点伤害 | — | — | 雷雨洼地 |
| `37 stage25_thunder_waste_slope_room` | 两级坡道与主路 / 支路汇流 | 左返 `36`；右进 `38`；接收 `39` 回环 | — | — | — | — | 引雷坡道 |
| `38 stage25_thunder_waste_fork_room` | 主路与上层机关支路分叉 | 左返 `37`；主路进 `40`；上层支路进 `39` | — | — | `BranchZone` | — | 风蚀岔口 |
| `39 stage25_thunder_waste_relay_room` | 雷暴压迫下完成元素序列机关 | 从 `38` 进入；接地后进 `37` | — | `StormField` 首次触碰造成 1 点伤害 | `StormRelay` 只响应风→雷追击贯穿；成功后关闭雷暴并解除 `GateBarrier` | — | 接地祭柱 |
| `40 stage25_thunder_waste_outlook_room` | 战后降压与旧区返回 | 从 `38` 进入；SC-08 返回 `11` | — | — | — | — | 驿路远眺 |

## 当前覆盖与剩余缺口

| 设计面 | 当前覆盖 | 判断 |
| --- | --- | --- |
| 房间职责 / 平台节拍 | `44/44` 已明确 | 原 38 房使用正式几何；雷泽 6 房为复用既有地形材质的可试玩灰盒 |
| 出入口 / 回环 | `34` 房原主线、`4` 个旧支路房、`6` 个雷泽房、`8` 条远端连接 | 雷泽形成 `38 → 39 → 37` 内部回环，并经 Stage11 回访旧区 |
| 敌人配置 | `16` 个战斗房、`24` 个普通敌人、`1` 个 Boss | Caster 已承担定向弹体压力并可被风印反制；仍只有一个远程原型 |
| 环境陷阱 | `9` 个正式房含伤害危险区，覆盖瘴气 / 腐化瘴气、封印脉冲与雷暴 | 雷暴以单房一次伤害建立区域辨识，不扩成天气状态机 |
| 门控 / 机关 | 清场门、符印门、Air Dash 门、交叉能力门、悬赏路引、风→雷接地祭柱和终局封印链已覆盖 | Stage25 已证明元素序列可承担区域机关；仍不建立通用元素锁系统 |
| 奖励 | 有 checkpoint、短链收集、3 个回溯收益、风印、悬赏路引和 4 件两槽 Build | 四件物品分别改变恢复、攻击距离、序列窗口或姿态冷却；尚无强化、词条或技能树 |
| 叙事 | 4 个显式 `NarrativeStele`、1 个一次性正式事件，另有神龛、祭器、封印与 Boss 地标 | 已有首个暂停式剧情事件；尚无多角色对话、选择或任务链 |
| 玩家导航 | 暂停菜单发现式地图显示当前房、已发现房、相邻轮廓和 SC-01 至 SC-08 状态 | 路线位置和条件由 JSON 驱动；仍无快速旅行与正式存档 |

## 变更规则

- 改动平台或碰撞：更新 `.tscn` 与最近的物理回归；只有职责 / 节拍变化时才更新本表。
- 改动入口、出口或捷径：同步更新场景 / 房间脚本、`world_map_view.gd`、Stage18 / Stage19 测试和世界地图蓝图。
- 改动敌人、陷阱、门控、奖励或叙事地标：同步更新本表和房间内容目录。
- 新增内容前先说明它解决哪一项剩余缺口；不因某格为 `—` 就自动加怪、加陷阱或加奖励。
