# 正式 Demo Blueprint V2 运行时落地阶段计划

状态：`RTA-01–06 complete`（2026-08-27）

## 权威入口

- 设计：`spec-design/2026-08-27-formal-demo-blueprint-v2-runtime-adoption-design.md`
- Blueprint V2：`spec-design/2026-08-26-formal-demo-room-blueprint-v2-design.md`
- 机器蓝图：`spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json`
- 执行清单：`docs/implementation-plans/2026-08-27-formal-demo-blueprint-v2-runtime-adoption.md`

## 目标

把 F01–F18 从 `runtime_scene_pending` 推进为生产灰盒候选：结构、交互状态、Spawn/相机、关键连接和自然输入路线全部有新鲜机器与运行态证据。正式美术和真人手感确认不包含在本阶段。

## 顺序

1. `RTA-01`：冻结运行时合同与 RED 门禁。
2. `RTA-02`：高偏差 F02/F09/F10/F14/F18。
3. `RTA-03`：部分匹配 F01/F03–F08/F11–F12/F15–F16。
4. `RTA-04`：接近 F13/F17 与全局状态矩阵。
5. `RTA-05`：18 房自然输入、完整回归、运行截图和内部视觉复核。
6. `RTA-06`：更新事实文档并冻结灰盒候选。

## 完成记录

- F01–F18 `18/18` 生产结构、Spawn、相机和主动交互合同通过。
- 主链与五个专项真实输入 replay 覆盖全部正式房、支路、返程、双能力捷径和回访快线，均为 `P0/P1/P2=0`。
- `room_design 64/64 / 2289`、最终 `19/19` 专项套件、Godot import、MCP workspace/截图/editor errors 与独立视觉复核通过。
- 冻结为生产灰盒候选；正式环境资产、真人手感和发布签核仍按计划边界后续处理。

## 硬门禁

- 不以 Blueprint JSON/SVG 完整代替生产 `.tscn` 采用。
- 不以直接切房、改玩家坐标或自动定位截图代替自然输入路线。
- 主动祭坛、建筑门和法坛没有 `ui_down` 确认与防重复时不得通过。
- 任一 Spawn 无地面支撑、落入源触发区或可能立即反弹时不得通过。
- 任一关键连接只在单一状态通过、锁定/回访/失败状态未覆盖时不得通过。
- 不用正式美术缺失阻塞灰盒，但可见旧资产不能表达错误交互语义。

## 完成定义

- `18/18` 房生产结构采纳门禁通过。
- `18/18` 房主自然路线通过，关键支路和回环另有状态覆盖。
- F07↔F14、F09→F10→F08、F09↔F12、F14→F15、F18→F03 运行闭环通过。
- 锁定、开放、完成、回访、失败恢复和一次性奖励无重复/软锁/假跌落。
- Godot import、相关 GUT、生产输入 replay、MCP 运行态检查和视觉复核均有新鲜结果。
- 状态和日志只记录实际通过项；未通过项保留为明确阻断，不提升成熟度。

## 边界

当前工作树包含大量用户既有改动。只编辑本阶段明确触达的房间、共享脚本、最近测试、运行探针和文档；不清理、不批量暂存、不 commit/merge/push。
