# Stage23 镇妖驿站与悬赏榜计划

## Goal

复用 Stage11、Main 快照和 DemoShell DetailPanel，完成三个固定悬赏的接取、追踪、完成、回交与情报奖励闭环。

## Scope

- Stage11 新增可见悬赏榜触发区。
- DemoShell 动态呈现三个固定悬赏按钮。
- Main 保存每项悬赏的 accepted / completed / turned-in 状态。
- Caster 击败、`marsh_relic` 取得和封印脉冲雷风错峰分别推进一个目标。
- 三项回交解锁雷泽荒原路引情报。
- HUD 与世界图快照只读展示进度。

## Validation

- Stage23 专项先红后绿，覆盖真实对象、UI、暂停 / 地图、Stage11 完成和重开。
- 回归 Stage11 / 13 / 16 / 19 / 20 / 22。
- 运行 Godot import、递归全量 GUT、主场景 smoke、Windows/OpenGL 运行态复核和 `git diff --check`。

## Non-goals

- 不做随机任务、赏银经济、商店、通用任务数据库或对话树。
- 不新增正式资产、NPC、存档或 Stage25 房间。
