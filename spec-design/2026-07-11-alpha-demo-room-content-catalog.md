# Alpha Demo Room Content Catalog

## 目的

本目录固定 39 房的关卡职责、敌人、机关、物品和门控意图。精确坐标与碰撞仍以对应 `.tscn` 为真源；本表不复制坐标，避免场景调整后双重维护。

当前统计：`39` 房，`16` 个战斗房，普通敌人实例 `24` 个（Melee 6 / Charger 6 / Aerial 5 / Caster 7），Boss `1` 个，训练 Dummy `3` 个。

## 教程与早期链

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `test_room` | Stage1-4 非整格机制沙盒 | 2 Dummy | 基础移动、跳跃、Dash gap、低顶和攻击测试；不属于正式主线遭遇 |
| `tutorial_room` | 移动、跳跃、Dash、攻击四段教学 | 1 Dummy | one-way 跳台、Dash gate、训练目标、出口封印门 |
| `combat_trial_room` | 首次单敌清场 | 1 Melee | 清敌后开 `ExitBarrier`，左侧可返回 tutorial |
| `goal_trial_room` | 下层战斗后登上右侧目标台 | 1 Melee | 清敌门、上层 Goal token、左侧返回 combat |

## Stage9 第一小区域

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage9_zone_entry_room` | 安全区域揭示 | - | Region checkpoint、双向出口 |
| `stage9_zone_combat_room` | 双层基础战 | 1 Melee | 清敌门 |
| `stage9_zone_charger_room` | 长直冲锋教学带 | 1 Charger | 清敌后开门并激活 checkpoint |
| `stage9_zone_switch_room` | 两级机关路线 | - | GateSwitch、封印门、checkpoint marker |
| `stage9_zone_final_room` | 上下层混合终点战 | 1 Melee + 1 Charger | 全清门、进入 Stage10 |

## Stage10 战斗变化与奖励支路

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage10_zone_aerial_room` | 三层空中价值主房 | 1 Charger + 1 Aerial | 可选 BranchZone、清敌门、主线出口 |
| `stage10_zone_branch_room` | 两级上行奖励房 | 1 Aerial | RecoveryPoint、BranchCollectible、返回主线门 |
| `stage10_zone_challenge_room` | 三层三敌挑战 arena | 1 Melee + 1 Charger + 1 Aerial | ChallengeCollectible、全清门、进入 Stage11 |
| `stage11_demo_end_room` | 旧 Demo 节点与 Stage13 接口 | - | Replay / Goal / Continue 三选择、运行期 checkpoint |

## Stage13 瘴泽区域

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage13_miasma_marsh_entry_room` | 区域揭示与安全落点 | - | RegionCheckpoint |
| `stage13_miasma_marsh_caster_room` | 三层远程压制教学 | 1 Caster | 清敌门 |
| `stage13_miasma_marsh_miasma_room` | 下层危险、上层绕行 | - | MiasmaHazard、危险提示 VFX |
| `stage13_miasma_marsh_gate_room` | 两级上行触符印后回到下层过门 | - | SealNode、GateBarrier |
| `stage13_miasma_marsh_crossfire_room` | 三层交叉火力 | 2 Caster | 双向出口，无额外奖励 |
| `stage13_miasma_marsh_checkpoint_room` | 降压恢复大厅 | - | RecoveryPoint / CheckpointArt |
| `stage13_miasma_marsh_pressure_room` | 危险绕行加右侧远程压制 | 1 Caster | MiasmaHazard、上层 bypass |
| `stage13_miasma_marsh_branch_hub_room` | 资源、挑战、主线三路分叉 | - | ResourceBranchZone、ChallengeBranchZone、主线 ExitZone |
| `stage13_miasma_marsh_resource_branch_room` | 低风险两级奖励路线 | - | Stage13Reward，返回 Hub |
| `stage13_miasma_marsh_challenge_branch_room` | 三层法师挑战 | 1 Caster | 全清门、门后 Stage13Reward，返回 Hub |
| `stage13_miasma_marsh_return_room` | 支路 / 主线汇流降压 | - | 双向出口 |
| `stage13_miasma_marsh_goal_room` | 区域终点与 Stage14 入口 | - | GoalDevice、GoalZone |

## Stage14 Air Dash 与回溯

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage14_air_dash_shrine_room` | 单一能力授予焦点 | - | AirDashShrine、能力解锁 |
| `stage14_air_dash_gate_room` | 起跳、Air Dash 缺口、安全回落 | - | AirDashGateSensor、GateBarrier、门前后安全落点 |
| `stage14_backtrack_hub_room` | 三层回溯收益 | - | BacktrackReward 1 / 2 / 3 |
| `stage14_loop_return_room` | 两段上行后的回环确认 | - | 上层 GoalZone，进入 Stage15 |

## Stage15 战斗高潮

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage15_seal_pressure_room` | 三高度双敌前置战 | 1 Charger + 1 Caster | 压力焦点、全清门 |
| `stage15_mixed_gauntlet_room` | 近战区、冲锋通道、空中层混合战 | 1 Melee + 1 Charger + 1 Aerial | ChallengeBranchZone、全清 Boss 门 |
| `stage15_challenge_branch_room` | 危险绕行双敌奖励支路 | 1 Caster + 1 Aerial | MiasmaHazard、全清门、Stage13Reward |
| `stage15_seal_guardian_boss_room` | 宽 Boss arena 与左右规避平台 | 1 Seal Guardian | Boss 门、胜利出口 |
| `stage15_completion_room` | 战后降压和封印完成 | - | CompletionSeal、进入 Stage16 |

## Stage16 终局封印链

| 房间 | 职责 / 空间节拍 | 敌人 | 机关、物品与门控 |
| --- | --- | --- | --- |
| `stage16_seal_release_threshold_room` | 上层释放、下层过门 | - | SealReleaseNode、GateBarrier |
| `stage16_talisman_relay_room` | 三层递进中继 | - | TalismanRelay A / B / C、完成后开门 |
| `stage16_backtrack_confirmation_room` | 验证 Stage14 三个回溯收益 | - | BacktrackConfirmationNode、GateBarrier |
| `stage16_corruption_purge_room` | 下层腐化危险与上层净化 | - | CorruptionMiasma、CorruptionPurgeNode、GateBarrier |
| `stage16_alpha_demo_end_room` | Alpha Demo 终局大厅 | - | AlphaDemoSeal、完成反馈与双向出口 |

## 当前内容风险

- 房间空间分布已经明确，但普通敌人仍是一击清除和触碰伤害原型，当前数量不能代表成熟遭遇深度。
- Stage13 的 Caster 占普通敌人实例 `7/24`，但尚无真实弹体，多个“远程压制房”目前主要靠位置和 VFX 区分。
- Stage14 与 Stage16 刻意偏能力 / 机关链，整段无普通敌人；是否需要追加战斗必须由节奏试玩决定，不能仅因房间空而加怪。
- Stage10 / Stage13 / Stage14 的奖励目前主要是计数与 HUD 标记，没有进入北极星中的圣物、组件、装备或 Build 系统。

## 维护规则

- 改变敌人类型、数量、机关、奖励、支路或门控时同步更新本表。
- 只调整像素坐标、背景取景或装饰时不更新本表，场景文件保持坐标真源。
- 新增房间前先写职责和节拍，再放敌人；不从“有多少空位”反推敌人数量。
