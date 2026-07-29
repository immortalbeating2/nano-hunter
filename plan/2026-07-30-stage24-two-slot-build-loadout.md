# Stage24 两槽圣物 / 组件 Build 正式计划

## 目标

以现有 Build 公开接口为兼容层，增加两槽装备列表、两件新组件、轻量暂停选择 UI 和可测的 Stage21 / 22 战斗影响。

## 实现顺序

1. 用 Stage24 GUT 冻结四件来源、两槽上限、组合效果、跨房与重开边界。
2. Main 扩展 Build 定义、取得事件、装备列表与快照。
3. Player 把四种效果接入现有恢复、判定、序列窗口和姿态冷却计算入口。
4. DemoShell 复用 DetailPanel 与 Stage23 选择列表完成装备 / 卸下。
5. 运行专项、邻近、全量、import、smoke 和 Godot MCP 运行态复核。
6. 更新路线清单、状态、时间线和日志后提交 Stage24 检查点。

## 兼容边界

- 保留 `cycle_active_build()`、`get_active_build_id()`、`get_active_build_label()` 和 Player `set_active_build_id()`。
- `active_build_id` 只代表调谐焦点；新逻辑以 `equipped_build_ids` 为效果真源。
- 现有两件物品的数值不变。

## 验证

- Stage24 专项覆盖取得、两槽 UI、槽满保护、组合效果、跨房和重开。
- 邻近回归至少覆盖 Stage15 / 16 / 20 / 21 / 22 / 23。
- 全量 GUT、Godot import、主场景 smoke 和运行态截图均需新鲜通过。

## 非目标

- 不建立通用物品数据库、背包、经济、强化或正式存档。
