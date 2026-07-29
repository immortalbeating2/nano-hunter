# Stage23 镇妖驿站与悬赏榜执行清单

## 设计与失败契约

- [x] 冻结三项固定悬赏、事件来源、回交奖励和重开边界。
- [x] 新增 Stage23 GUT，先覆盖悬赏榜 UI、完整任务链、暂停 / 地图和重开语义。

## 实现

- [x] Stage11 增加悬赏榜触发区并复用现有房间信号边界。
- [x] Main 保存并输出 accepted / completed / turned-in 状态，观察三条既有生产事件。
- [x] DemoShell 复用 DetailPanel 呈现三个固定悬赏按钮。
- [x] HUD / 世界图快照只读显示悬赏计数与驿站情报。

## 验证

- [x] Stage23 专项通过。
- [x] Stage11 / 13 / 16 / 19 / 20 / 22 邻近回归通过。
- [x] 全量 GUT、Godot import、主场景 smoke 和运行态复核通过。
- [x] 更新状态、时间线、日志与路线清单。
