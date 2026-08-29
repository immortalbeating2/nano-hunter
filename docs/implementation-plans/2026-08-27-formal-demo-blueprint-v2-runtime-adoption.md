# 正式 Demo Blueprint V2 运行时落地执行清单

执行状态：`RTA-01–06 complete`（2026-08-27）

## RTA-01：合同与 RED 门禁

1. 新增生产采纳 GUT：逐房检查段数、相机、Spawn、几何源、必需交互节点和关键连接语义。
2. 在现有房间基类测试中先写主动确认、锁定、单次切房和防重复失败用例。
3. 扩展现有真实输入 replay 的正式 F 编号覆盖；路线期间禁止切房 API 和坐标写入。
4. 基线运行并保存预期失败清单，失败必须指向房间和合同字段。

## RTA-02：高偏差五房

- F02：三段灰盒、单敌清场、悬令板代理、`ui_down` 确认、一次性首赏。
- F09：保留现有共享 Layout；分离 F10 下落、F11 确认、F12 主路和 Air Dash 快线。
- F10：两段共享 Layout、可破墙、遗物确认、单向滑道回 F08。
- F14：三段共享 Layout、失败回落、真 Air Dash 证明、F15 上层主路与 F07 下层祭坛。
- F18：两段共享 Layout、战后结果、独立归驿法坛确认回 F03，移除自动跑出出口。

每房先运行最近 RED，再运行该房 production scene smoke。

## RTA-03：部分匹配十一房

- F01/F03：保留专用教学与 Hub 交互，补结构合同、Spawn/相机和路线审计。
- F04–F08：在现有 `FormalRoomGrayboxLayout` 上校准 V2 段落、净空、危险、checkpoint 和 F07 祭坛。
- F11–F12：共享 Layout、战斗锁区/汇流目标、主动交互与双向连接。
- F15–F16：回访状态两段、四段综合战斗、清场门和局部重试。

## RTA-04：接近二房与状态矩阵

- F13：安全单屏、Air Dash 确认授予、重复进入保护。
- F17：前室/Boss arena、checkpoint、Boss 门、锁镜、胜利后 F18。
- 对五个 progression states 运行连接、奖励、门控和地图快照审计。

## RTA-05：全量验证

1. `godot --headless --path . --import`。
2. 运行 Blueprint V2、生产采纳、移动标尺、最近房间行为 GUT。
3. 运行生产 Main 的 F01–F18 真实输入 replay，输出每房/连接状态矩阵和遥测。
4. 捕获 18 房入口/核心/出口及关键状态差异图。
5. 使用 Godot MCP 确认正确 workspace、无新脚本错误、关键房运行表现；结束后清理本任务启动的现场。
6. 对 18 房进行内部视觉复核；视觉通过不替代真人手感。

## RTA-06：收口

1. 更新 `docs/progress/status.md` 与 `docs/progress/logs/2026-08-27.md`。
2. 记录通过数量、失败数量、测试命令、截图路径和剩余边界。
3. 运行 `git diff --check`，确认无无关文件混入本阶段说明。

## 通过判定

只有 RTA-01–05 全部通过，才把本计划状态改为 `RTA-01–06 complete`。任何自动路线失败、Spawn 反弹、主动交互自动触发或房间职责不可读，都保持 `in progress`。

## 完成证据

- 生产采纳：F01–F18 `18/18`；`room_design 64/64 / 2289`。
- 路线：主链 24 次进房；F09→F10→F08、F09→F11→F12、F12→F09、F06 回访、F09 快线五个专项；六组报告均 `done=true / P0/P1/P2=0`。
- 回归：Batch1–8、可踩面视觉、Stage5/7/13/14/15/18/19/20/31 共 `19/19` 套件通过；Godot import 退出码 `0`。
- 运行态：Godot MCP Pro 指向当前仓库，F01–F18 截图编号一致；F11 相机修正后脚底地表可见，editor errors=`0`；运行现场已清理。
- 证据目录：`tests/artifacts/local/formal-blueprint-v2/`（ignored）。
