# 阶段 13：第二小区域内容生产开发计划

## Summary

Stage 13 固定为 `阶段 13：第二小区域内容生产`，以已完成并合并回 `main` 的 Stage 12 稳定基线为前置，新增一个 `生物废液区` 第二小区域。本阶段目标是验证项目在已有 demo 基线、资产 manifest 与灰盒主线自动化基础上，能否继续生产一个更厚、更可读、更可验证的内容区域。

本阶段内容密度固定为 `10 个主线房间 + 2 条小支路`。主线从 Stage 11/12 demo 终点后继续推进，重点是第二小区域的房间组合、区域主题、新敌人、新危险、门控、checkpoint 与资产需求落地，而不是提前做大地图、完整回溯、Boss 或正式成长系统。

本轮关键选择固定为：

- 第二小区域主题：`生物废液区`
- 主线密度：`10` 个连续房间
- 支路密度：`2` 条小支路，分别服务“资源 / 恢复收益”和“风险挑战收益”
- 第 `4` 类敌人：`孢子投射敌`
- 区域危险：`废液池 / 酸液地形`
- 区域门控：`净化门控`
- 区域终点：承接 Stage 14 回溯能力前置，但 Stage 13 不发放新能力

## Preflight

- 本轮实际按 `仅分支` 启动，未额外创建阶段 worktree
- 分支名固定为 `codex/stage-13-second-content-zone-production`
- 实现前必须先确认当前分支已对齐最新 `main`，避免在过期 Stage 9 / Stage 10 基线上落文档或实现
- 流程说明：本轮因实际开发已经在主路径阶段分支中完成，收口时不迁移现场；后续 Stage 14 起按最新 `AGENTS.md` 恢复为固定永久工作树策略
- 实现前必须先补齐并同步：
  - `spec-design/2026-04-26-stage-13-second-content-zone-production-design.md`
  - `docs/implementation-plans/2026-04-26-stage-13-second-content-zone-production.md`
  - `plan/2026-04-26-stage-13-second-content-zone-production.md`
  - `docs/progress/status.md`
  - `docs/progress/timeline.md`
  - `docs/progress/logs/2026-04-26.md`
  - `docs/assets/asset-manifest.md`
- preflight 必须先做 fresh baseline：
  - `godot --headless --path . --import`
  - Stage 1-12 全量 GUT
  - `git diff --check`
  - Godot MCP 进场检查；如果当前会话无法恢复 MCP，则记录 fallback 原因并继续使用 headless 验证
- preflight 中必须显式写明本轮不做项：
  - 不做完整大地图
  - 不做跨多区域的完整世界结构
  - 不做正式存档、经济、装备或技能树
  - 不新增玩家核心能力
  - 不做 Boss / 精英原型
  - 不把 2 条支路扩成半开放大区域
  - 不重做 Stage 12 资产管线

## Key Changes

### 第二小区域

- 新增 `生物废液区`，作为不同于 Stage 9 第一区域的第二个内容型区域
- 区域结构固定为：
  - `10` 个主线房间
  - `2` 条小支路
  - `1` 个区域终点房
  - 区域 checkpoint 与失败重来规则
- 两条支路的职责固定为：
  - 支路 A：资源 / 恢复收益，用于验证玩家愿意离开主线获取恢复或补给
  - 支路 B：风险挑战收益，用于验证废液危险、新敌人和净化门控的组合压力
- 区域终点房用于承接 Stage 14 的回溯能力前置表达，但不在 Stage 13 发放新能力或开启正式回溯系统

### 新敌人与区域压力

- 新增第 `4` 类普通敌人：`孢子投射敌`
- 孢子投射敌定位为偏远程压制，与现有三类敌人形成区别：
  - `BasicMeleeEnemy`：近身接触压力
  - `GroundChargerEnemy`：地面冲锋封位
  - `AerialSentinelEnemy`：空中位置压力
  - `SporeShooterEnemy`：远程投射 / 区域压制
- 新敌人继续复用现有敌人契约和配置资源入口，不引入第二套敌人基类
- 本阶段至少做出 `2-3` 组新的常规遭遇组合，让孢子投射敌与废液危险、净化门控、现有敌人产生可重复验证的区域压力

### 区域危险与门控

- 新增 `废液池 / 酸液地形`
  - 只做可读伤害、区域压力或失败风险
  - 不做复杂液体模拟、流体物理或长期 DOT 系统
  - 不改变玩家基础碰撞和受击契约
- 新增 `净化门控`
  - 默认阻挡区域推进
  - 可通过清敌、触发净化节点或小机关解除
  - 不扩展成正式钥匙系统或复杂解谜系统
- checkpoint 继续保持运行期恢复点定位，不扩成正式存档

### 资产安排

- 继续沿用 Stage 12 建立的 `docs/assets/asset-manifest.md` 和 `docs/assets/asset-ingestion-checklist.md`
- 新增 `biome_02_bio_waste` 相关资产需求，不重新规划资产体系
- 第一轮优先资产：
  - 废液地面 / 平台
  - 生物废液背景层
  - 净化门
  - 净化节点
  - 孢子投射敌轮廓
  - 废液危险提示
  - 区域终点装置
- 第一轮接入仍可使用占位、临时、AI 或免费资产，但必须记录来源、授权状态、当前状态和替换优先级

## Public APIs / Interfaces

- 房间继续沿用现有信号与接口：
  - `room_transition_requested`
  - `checkpoint_requested`
  - `goal_completed`
  - `get_hud_context() -> Dictionary`
- 敌人继续沿用基础契约：
  - `receive_attack(...)`
  - `defeated`
- 新敌人只新增参数资源与行为脚本，不引入第二套敌人基类
- `Main` 只做第二小区域接入所需的最小扩展：
  - 注册 Stage 13 主线入口、支路入口与终点房路径
  - 保持 checkpoint 为运行期恢复点
  - 不扩成正式存档系统
- HUD 可补 Stage 13 区域状态、净化门控、废液危险和支路反馈文案，但继续走现有快照 / 绑定方式，不回退到分散字段探测

## Test Plan

- Preflight 验证：
  - `godot --headless --path . --import`
  - Stage 1-12 全量 GUT
  - `git diff --check`
  - Godot MCP 进场检查或记录 fallback
- 新增 Stage 13 GUT，至少覆盖：
  - 第二小区域主路径可从 Stage 11/12 终点后进入
  - `10` 个房间的主线推进顺序稳定
  - `2` 条小支路可进入、完成、返回主线或给出明确结束反馈
  - 第 `4` 类敌人已接入，行为节奏与近战、冲锋、空中敌明显不同
  - 废液 / 酸液危险不会破坏玩家失败和 checkpoint 恢复
  - 净化门控默认阻挡，满足条件后可解除
  - Stage 13 资产条目已追加到 manifest
  - Stage 11 灰盒主线自动化扩展到至少跑通 Stage 13 主路径
- 收口验证：
  - Stage 13 专项 GUT 通过
  - Stage 1-13 全量 GUT 通过
  - `godot --headless --path . --import` 通过
  - `git diff --check` 通过

## Manual Review / 人工复核

阶段收口前必须完成人工复核，不允许只用自动化替代。

人工复核至少包括：

- 从 `Main.tscn` 跑到 Stage 13 第二小区域入口
- 完整跑通 Stage 13 主路径到区域终点房
- 至少进入并完成 `2` 条小支路
- 至少触发一次废液 / 酸液危险导致的失败或压力反馈
- 至少触发一次 checkpoint 恢复
- 至少验证一次净化门控从关闭到开启
- 观察并记录：
  - 区域主题是否清楚
  - 孢子投射敌是否可读
  - 废液危险是否误导碰撞
  - 支路奖励是否有意义
  - HUD 是否能解释当前目标
  - 区域终点是否清楚表达“下一阶段将进入回溯能力前置”

人工复核结果必须写入当日日志，并给出是否达到 Stage 13 收口标准的判断。

## Assumptions

- Stage 13 采用 `生物废液区 + 10 房 + 2 支路`，这是本轮正式文档和后续实现的固定方案
- 第二小区域要“厚”，但厚度主要来自房间组合、支路、敌人 / 危险 / 门控协作，不靠引入多个新系统
- 新资产需求全部追加进 Stage 12 建立的 manifest，不重新规划资产体系
- Stage 13 不做完整大地图、正式存档、经济、装备、技能树、新玩家核心能力、Boss / 精英原型，也不重做 Stage 12 资产管线
- 若实现中范围失控，裁剪优先级为：先保主线 10 房、新敌人、废液危险、净化门控和 checkpoint；再裁剪第二支路复杂度；不裁剪 preflight、测试或人工复核
