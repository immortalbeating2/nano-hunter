# 阶段 9：首个小区域内容生产开发计划

## Summary

以当前已完成的 `stage8` 为稳定基线，`stage9` 固定采用“线性主线小区域”方案，把现有模板和配置化结果真正用于内容生产，而不再只是验证系统本身。
本轮目标是做出一个 `4-6` 个连续房间的小区域，接入第 `2` 类敌人、首个正式 checkpoint、以及第一种正式门控，验证阶段 8 的配置资源、HUD 接口和敌人模板是否足以支撑更高效率的内容制作。

本轮关键选择固定为：

- 第 2 类敌人：`地面冲锋敌`
- checkpoint 形式：`房间入口存档点`
- 正式门控类型：`开关门`
- 区域结构：`线性主线区`

## Preflight

- 本轮固定采用 `分支 + worktree`
- 分支名固定为 `codex/stage-9-first-content-zone-production`
- worktree 固定放在 `.worktrees/stage-9-first-content-zone-production`
- 开始实现前必须先补齐：
  - `spec-design/2026-04-24-stage-9-first-content-zone-production-design.md`
  - `docs/implementation-plans/2026-04-24-stage-9-first-content-zone-production.md`
  - `docs/progress/status.md`
  - `docs/progress/timeline.md`
  - `docs/progress/2026-04-24.md`

## Key Changes

### 小区域结构与主流程

- `stage9` 固定做一个 `4-6` 房间的线性主线区，不做支路，不做半开放回环
- 推荐房间构成为：
  - 入口房
  - 基础战斗房
  - 冲锋敌首次教学房
  - 开关门门控房
  - 混合战斗/门控房
  - 区域终点房
- 当前 `Main` 继续沿用现有房间过渡能力，但要支持“checkpoint 后从指定房间入口恢复”

### 第二类敌人：地面冲锋敌

- 新增第 `2` 类敌人，固定为“地面冲锋敌”
- 它应继续继承当前基础敌人模板入口，不另起一套敌人契约
- 行为边界固定为：
  - 常态短距离巡逻或待机
  - 进入触发范围后做一次明显的水平冲锋
  - 保持接触伤害
  - 继续沿用当前 `receive_attack(...)` 与 `defeated` 契约

### Checkpoint 与失败循环

- 新增首个正式 checkpoint，形式固定为“房间入口存档点”
- checkpoint 更新规则固定为：
  - 通过一组关键房间后，主恢复点更新到下一个关键房间入口
  - 玩家失败后，从最近一次已激活 checkpoint 对应房间入口恢复
- 本轮不做正式存档系统；checkpoint 只服务当前运行内的区域推进与失败恢复

### 门控与房间配置

- 本轮的第一个正式门控固定为“开关门”
- 开关门必须与区域推进绑定，而不是独立摆设
- 继续沿用 `RoomFlowConfig` 路线，但把配置从“原型三段链路”扩展到真正的小区域房间内容

### HUD 与内容生产支撑

- HUD 本轮继续沿用当前第二轮接口，不重做第三轮
- 只补足与 `stage9` 小区域直接相关的信息：
  - 当前房间/目标提示
  - checkpoint 更新提示
  - 开关门状态的最小可读性提示

### 配置化与模板复用要求

- `stage9` 必须实际复用当前阶段 8 已完成的：
  - 玩家配置资源
  - 房间流程配置资源
  - 基础敌人模板入口
- 不允许为求快回退到脚本里临时硬编码一批新参数

## Public APIs / Interfaces

- 敌人侧继续统一走基础敌人模板契约：
  - `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
  - `defeated` 信号
- 新增 checkpoint 最小接口，建议固定为：
  - `Main` 持有当前激活 checkpoint 的房间标识与出生点标识
  - 房间继续通过统一过渡请求进入下一个房间
- 房间侧继续提供稳定 HUD 上下文：
  - `get_hud_context() -> Dictionary`

## Test Plan

- 基线验证继续保留：
  - `godot --headless --path . --import`
  - Stage 1-8 GUT
  - `git diff --check`
- 新增 Stage 9 GUT，至少覆盖：
  - 小区域线性主线可从入口推进到终点
  - 第 2 类敌人已接入且行为与基础敌人明显不同
  - checkpoint 激活后，失败会从最近 checkpoint 房间入口恢复
  - 开关门默认关闭，满足条件后解锁
  - 小区域房间配置资源已被实际读取
  - 既有 Stage 1-8 测试不回归

## Assumptions

- `stage9` 固定为线性主线区，不做支路；支路留到 `stage10`
- `stage9` 不新增玩家动作；战斗扩展动作留到 `stage10`
- `stage9` 的 checkpoint 只服务当前运行内推进，不扩成正式存档
- 第 2 类敌人固定选 `地面冲锋敌`
- 门控固定选 `开关门`
