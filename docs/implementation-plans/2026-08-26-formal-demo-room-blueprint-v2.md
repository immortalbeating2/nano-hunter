# 正式 Demo 房间蓝图 V2 补全执行清单

执行状态：`BPV2-01–09 complete`（2026-08-26）。结果为 `18/18` 房、`48/48` 屏段、`38` 条连接、`14` 项奖励、`36` 张逐房 SVG、`2` 张总览；真人逐房确认在目标完成后执行。

## 范围与事实源

- 设计真源：`spec-design/2026-08-26-formal-demo-room-blueprint-v2-design.md`
- 正式阶段计划：`plan/2026-08-26-formal-demo-room-blueprint-v2.md`
- 现有机器真源：`spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json`
- 生产房间与当前代码只用于只读核对，不在本阶段修改。
- 当前工作树很脏；不得清理、回退、批量暂存或覆盖其他改动。

## 执行原则

- 一份 JSON 真源，两类 SVG 视图，不建立平行手工蓝图。
- 先全局合同、后逐房填充；先完整性门禁、后图面美化。
- 每批只处理一个房间簇，完成后运行相同验证器。
- 蓝图只记录已有玩法与已批准设计；不借补字段偷偷新增系统。
- 运行时临时修正必须回写设计语义，但不把实现细节误当设计合同。

## BPV2-01：V2 schema 与完成状态

**Files:**

- Modify: `spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json`
- Modify: `tools/level_design/generate_formal_demo_room_blueprints.ps1`
- Modify: `tools/level_design/validate_formal_demo_room_blueprints.ps1`
- Test: closest existing Blueprint PowerShell validation

**Steps:**

1. 先让验证器在 `schema_version=1` 或缺少任一 V2 顶层合同字段时失败。
2. 把 schema 升级为 `2`，增加 `blueprint_contract`、`connection_vocabulary`、`progression_state_matrix`、`encounter_curve`、`presentation_contract`、`acceptance_contract`。
3. 为每房增加 V2 字段容器，但不填虚假默认值；未完成房间标记为 `gameplay_blueprint_pending`。
4. 验证器报告缺失字段的房间 ID 和字段路径。

**Checkpoint:** V2 完整度可以被机器判断，旧结构数据仍可读取和生成。

## BPV2-02：连接、交互与 Spawn 矩阵

**Files:**

- Modify: machine JSON
- Modify: generator and validator
- Read-only verify: `assets/configs/world_map/formal_demo_room_program.json`
- Read-only verify: F01–F18 scenes and shared room scripts

**Steps:**

1. 登记所有正式主线、支路、回环、回访和 Hub 返回连接。
2. 每条连接补 `connection_id/type/target_room/target_spawn/facing/directionality/verb/requirements/feedback/safety/anti_retrigger/map`。
3. 固定普通相邻边界、建筑门、能力门、清场门、远程法坛、单向地形和 Boss 门七类词汇。
4. 专项保护 F09→F10→F08、F12↔F09、F07↔F14、F14→F15、F18→F03。
5. 校验连接目标存在、双端 Spawn 唯一、出生安全要求完整，且远程法坛不使用自动边界语义。

**Checkpoint:** 不再存在只有“目标房间”而没有玩家动作和落点合同的连接。

## BPV2-03：全局状态、遭遇、地图与 QA 矩阵

**Files:**

- Modify: machine JSON
- Modify: generator and validator
- Read-only verify: movement metrics, world map, current persistence keys and room tests

**Steps:**

1. 冻结五个 progression states 及其跨房影响。
2. 冻结 F01–F18 压力波形、安全房、教学房、战斗房和 Boss 房。
3. 登记正式地图揭示、门控、祭坛、checkpoint、奖励和秘密语义。
4. 把自动结构验证、设计审阅、生产采用、真人灰盒和发布签核分层。
5. 校验每个持久状态都有 owner、写入事件、读取房间和重复行为。

**Checkpoint:** 逐房填充可以引用统一状态和验收语言，不再各自发明规则。

## BPV2-04：F01–F03 开场与 Hub

**Steps:**

1. F01 冻结四段教学、无死亡坑、提示区、回落、回访快线和连续出口。
2. F02 冻结单敌观察、战区、清场、悬令确认、回访开放和不重复发奖。
3. F03 冻结多入口 Spawn、恢复、赏榜、F04 相邻路和 F18 法坛回程。
4. 补齐三房的知识、时间、相机、地标、地图、表现和 QA。
5. 生成三房两类 SVG 并运行验证器。

**Checkpoint:** 前 7–10 分钟具备可施工的完整设计合同。

## BPV2-05：F04–F09 瘴泽核心区

**Steps:**

1. F04 补区域揭示、地标、能力门远景、反向构图和视差意图。
2. F05 补风印交互、授予状态、单施法敌遭遇和回访旁路。
3. F06 补瘴气恢复、下层奖励、Air Dash 状态、相机底边和视觉净空。
4. F07 补 F08 普通出口与 F14 主动祭坛捷径的完整分离合同。
5. F08 补 checkpoint、F10 落点、出口隔离和地图状态。
6. F09 补安全选择区、三高度四路线、下穿操作、Air Dash 快线、地图和视觉净空。
7. 对照现有 F04–F09 actual/overlay 审计，只记录偏差，不在本阶段改 `.tscn`。

**Checkpoint:** 已有生产灰盒的局部修正全部回收到统一设计语言。

## BPV2-06：F10–F12 支路与区域目标

**Steps:**

1. F10 冻结破墙提示、低风险遗物、单向滑道、奖励状态和秘密地图语义。
2. F11 冻结可退入口、敌人组合、锁区、清场、奖励、前送和回访旁路。
3. F12 冻结双入口汇流、主动目标交互、可见路线封口、返回 F09、进入 F13 和地图更新。
4. 核对 F12 当前隐藏安全边界，只把它记录为待生产语义化的现状，不批准隐形墙为终稿。

**Checkpoint:** 主线、低风险支路和高风险前送支路的成本、收益与退出规则完整。

## BPV2-07：F13–F15 能力与回访

**Steps:**

1. F13 冻结神龛确认、Air Dash 授予、输入保护、持久状态和出口预读。
2. F14 冻结展示、练习、失败回落、真实空冲证明、F15 主路与 F07 下层法坛。
3. F15 冻结 F06/F07/F09 回访状态、必需与可选边界、Boss 路线及耗时比较。
4. 校验 Air Dash 至少重写三个旧地点，但可选奖励缺失不会软锁。

**Checkpoint:** “预告 → 获得 → 证明 → 回访 → 捷径”具备完整设计数据。

## BPV2-08：F16–F18 高潮与回 Hub

**Steps:**

1. F16 冻结四段敌人编排、能力替代路线、锁区、失败重置和清场门。
2. F17 冻结前室 checkpoint、Boss 门、锁镜、读招、10–25 秒重试、胜利和 F18 出口。
3. F18 冻结战后反馈、降压、主动法坛返回 F03、奖励和 Hub 状态更新。
4. 明确 F18 当前普通自动出口属于实现漂移，留给下一生产施工阶段修正。

**Checkpoint:** Demo 高潮、失败恢复和返回 Hub 闭环完整。

## BPV2-09：审阅图、验证与冻结

**Files:**

- Modify: generator and validator
- Regenerate: `spec-design/formal-demo-room-blueprints/*.svg`
- Update: design/status/log only with actual results

**Steps:**

1. 从同一 JSON 生成 18 张 topology 与 18 张 side-view gameplay SVG。
2. 生成连接/状态/遭遇/节奏总览，不手工复制第二份数据。
3. 运行 JSON 解析、V2 validator、确定性再生成和 `git diff --check`。
4. 运行逐房字段审计与关键房视觉抽检，覆盖职责、节拍、连接、能力、交互、遭遇、相机、表现、地图和 QA。
5. 机器缺口归属到具体房间和字段；全部清零后设置 `gameplay_blueprint_complete`，真人逐房确认留到目标完成后。

**Checkpoint:** 形成 F01–F18 下一施工阶段唯一允许使用的 Blueprint V2 基线。

## 验证命令

```powershell
pwsh -NoProfile -File tools/level_design/generate_formal_demo_room_blueprints.ps1
pwsh -NoProfile -File tools/level_design/validate_formal_demo_room_blueprints.ps1
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/room_design/test_formal_demo_room_blueprint_v2.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/room_design/test_formal_demo_room_program.gd -gexit
git diff --check
```

只有修改工程配置或生产场景时才运行 Godot import；本阶段正常情况下不触发该门禁。

## 提交边界

- 每个 BPV2 checkpoint 只涉及机器蓝图、生成/校验工具、最近测试和必要文档。
- 不批量暂存当前工作树。
- commit、merge、push、发布和 worktree 清理另行授权。
