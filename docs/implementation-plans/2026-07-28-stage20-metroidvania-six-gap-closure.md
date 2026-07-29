# Stage20 六类银河城缺口闭环执行清单

## 范围

- 设计真源：`spec-design/2026-07-28-stage20-metroidvania-six-gap-closure-design.md`
- 正式入口：`plan/2026-07-28-stage20-metroidvania-six-gap-closure.md`
- 当前工作树保留既有 Stage17–19 与资产处置改动，不回退无关文件。

## 执行步骤

### S20-01 早期路线与风印

- [x] 将 SC-01 改为首次流程可用的 Stage9 Switch -> Stage10 Branch 入口。
- [x] Stage10 Branch 收集物授予跨房风印。
- [x] Main / Player 快照、重开与换房同步风印状态。
- [x] 更新世界图 JSON 和 Stage18 / 19 契约。

### S20-02 封印脉冲危险

- [x] 新增一个最小 `Area2D` 循环危险脚本。
- [x] 接入 Stage10 Challenge 与 Stage14 Air Dash Gate。
- [x] 验证预警、激活、单周期伤害和视觉 / 碰撞尺寸。

### S20-03 Caster 弹体职责

- [x] 新增最小腐瘴弹体脚本与场景。
- [x] Caster 绑定玩家、范围判断、施法间隔与生成弹体。
- [x] 风印解锁后玩家攻击可查询 Area 并斩散弹体。
- [x] 保持 `receive_attack(...)`、`receive_damage(...)` 和 `defeated` 现有契约。

### S20-04 第二能力交叉门

- [x] Stage13 Gate 与 Stage14 Air Dash Gate 增加 SC-06 双向入口和安全出生点。
- [x] 两端均要求风印与 Air Dash。
- [x] 地图 JSON 用 `requirements` 描述 SC-01 至 SC-06 条件。

### S20-05 奖励 Build

- [x] Main 保存已取得 Build 与当前调谐。
- [x] Player 实现瘴泽遗物恢复倍率和镇妖挑战符攻击距离效果。
- [x] 暂停菜单增加单按钮循环调谐并显示当前 Build。
- [x] 换房保持，重开清空。

### S20-06 剧情事件

- [x] Main 在 Stage11 首次封印确认时触发并去重事件。
- [x] DemoShell 复用详情面板显示剧情，继续后恢复游戏。
- [x] 快照暴露事件完成状态。

### S20-07 验证与留痕

- [x] 新增 Stage20 专项 GUT，逐项保护六类成果。
- [x] 运行 Stage3 / 6 / 13 / 14 / 15 / 18 / 19 邻近回归。
- [x] 运行递归全量 GUT、Godot import 和主场景 smoke。
- [x] 使用 Godot MCP 复核早期分支、脉冲危险、Caster 弹体、Build 按钮、剧情面板与 SC-06。
- [x] 清理 MCP 临时 autoload，运行 `git diff --check`。
- [x] 更新房间蓝图、世界图设计、内容目录、状态、时间线和 `2026-07-28` 日志。
