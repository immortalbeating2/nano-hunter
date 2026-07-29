# Stage20 六类银河城缺口闭环实施计划

详细执行清单以 `docs/implementation-plans/2026-07-28-stage20-metroidvania-six-gap-closure.md` 为唯一来源。

## 目标

- 把现有 Stage10 Branch 前移为早期替代路线并授予风印。
- 新增循环式封印脉冲危险。
- 为 Caster 接入真实可斩散弹体。
- 建立风印 + Air Dash 的 SC-06 交叉门控。
- 让两件 Stage13 奖励形成可切换 Build。
- 在 Stage11 接入一次正式剧情事件。

## 入口

- 设计：`spec-design/2026-07-28-stage20-metroidvania-six-gap-closure-design.md`
- 执行清单：`docs/implementation-plans/2026-07-28-stage20-metroidvania-six-gap-closure.md`

## 完成门禁

- 六项均有生产运行时入口和 Stage20 自动回归。
- Stage18 / 19 世界图与既有主线回归保持通过。
- 全量 GUT、Godot import、主场景 smoke、运行态复核和 `git diff --check` 通过。
- 状态、时间线和当日日志已同步。
- 不提交、合并或 push，除非用户另行授权。

## 收口结果

- 六项均已接入生产运行时，并由 Stage20 `6/6` tests、`60` assertions 保护。
- 受影响邻近回归为 `104/104` tests、`3332` assertions；递归全量 GUT 为 `36` scripts、`269/269` tests、`8213` assertions。
- Godot `4.6.3` import、主场景 smoke、世界图 JSON、资产包 strict audit、Godot MCP 运行态复核与 `git diff --check` 通过。
- 本阶段没有新增房间或生成新地图位图；地图拓扑继续由 JSON 驱动。当前分支未提交、合并或 push。
