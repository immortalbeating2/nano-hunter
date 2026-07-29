# 北极星后续 Stage 开发路线计划

详细设计入口：`spec-design/2026-07-30-north-star-stage-roadmap.md`

执行清单入口：`docs/implementation-plans/2026-07-30-north-star-stage-roadmap.md`

## Summary

当前 Stage20 让 Alpha Demo 的银河城骨架成型，但北极星独特核心仍不足。后续开发不继续优先堆房间，而按 `Stage21 -> Stage26` 推进：先做元素序列和符印姿态，再让敌人 / Boss 响应该系统，随后补驿站悬赏、Build 深度、第二区域原型，最后收口北极星 Alpha Candidate。

## Stage Boundary / Preflight

- 当前基线：`codex/upgrade-godot-mcp-1-15-hardening` 已合入 d7ef Stage17-20 分支候选。
- 进入 Stage21 前先确认当前分支是否要合入 `main` 或另开阶段分支。
- 当前无关未跟踪内容不纳入本计划。
- 每个 Stage 开始前都需要独立设计确认和 implementation plan；本文件只定义后续路线，不替代每个 Stage 的执行清单。

## Key Changes

- Stage21：`2 元素 + 2 姿态 + 2 步序列` 最小战斗闭环。
- Stage22：元素序列驱动 Caster、Charger、Seal Guardian 和封印脉冲的反应。
- Stage23：Stage11 镇妖驿站与 2-3 个固定悬赏闭环。
- Stage24：2 槽圣物 / 组件 Build 小系统。
- Stage25：雷泽荒原小型第二区域原型。
- Stage26：北极星 Alpha Candidate 集成、真人试玩、手柄、QA 和 release 收口。

## Public Interfaces

- 元素 / 姿态 / 序列状态进入 Main / Player 快照。
- 敌人反应继续走 `receive_attack(...)` 或局部公开查询接口。
- 世界图继续以 `assets/configs/world_map/alpha_demo_world_map.json` 为连接和条件真源。
- HUD / 暂停菜单继续承载当前状态展示，不提前拆大型 UI 系统。

## Test Plan

- 每个 Stage 必须有专项 GUT。
- 修改战斗核心时跑 Stage3 / 6 / 10 / 13 / 15 / 20 邻近回归。
- 修改世界图或门控时跑 Stage18 / 19 / 20。
- 修改 UI 时跑 Stage16 / 19。
- 每个 Stage 收口跑全量 GUT、`godot --headless --path . --import`、主场景 smoke、`git diff --check`。
- 涉及运行态体验时用 Godot MCP 或等效脚本留截图 / 报告证据，并清理临时 autoload。

## Manual Review / Runtime Review

- Stage21 必须验证 30 秒战斗循环是否真的更有辨识度。
- Stage22 必须验证敌人反应能被玩家看懂。
- Stage23 必须验证玩家是否知道接榜、完成、回交。
- Stage24 必须验证 Build 选择有差异但不膨胀。
- Stage25 必须验证第二区域不只是换皮房间。
- Stage26 必须执行真人首次通关和能力回访试玩。

## Assumptions

- Stage20 的 Alpha Demo 关卡闭环作为输入，不在 Stage21 重做地图。
- 风印可升级为风元素入口，但不直接等同完整元素系统。
- Air Dash 仍是移动能力，不强行改造成符印姿态。
- 后续每个 Stage 默认只追求最小可玩闭环；商业完整版元素池、完整剧情、多区域和经济系统分阶段推进。

## Risks

- 如果 Stage21 继续推迟，项目会继续偏向普通东方奇幻银河城，而不是 Nano Hunter。
- 如果 Stage23 / 24 早于 Stage21 / 22 实施，悬赏和 Build 会缺少战斗核心支撑。
- 如果 Stage25 过早扩大房间数量，会稀释现有自动化和资产质量门禁。

## Exit Criteria

- 本路线图被接受后，下一实际开发 Stage 默认为 Stage21。
- Stage21 开始前补专属设计文档和执行清单。
- 若用户优先要求真人试玩或主线合并，则先完成集成 / 签核，再进入 Stage21。
