# 阶段 12：资产管线与第一轮 Demo 表现升级开发计划

## Summary

以已完成并收口的 `stage11` 为稳定 demo 基线，`stage12` 固定采用“资产管线 + 轻量表现升级”的方案。本轮目标不是扩新区域或新玩法，而是建立后续资产生产与接入的稳定管线，并对现有 demo 做第一轮可读性提升。

资产接入强度固定为“规范 + 轻替换”：优先完成资产目录、资产清单、接入检查清单，并实际接入少量关键可读性资产作为样例。正式美术可以继续混用占位、临时、AI 或免费资产，但必须记录来源、授权状态和当前接入状态。

本轮关键选择固定为：

- 资产强度：`规范 + 轻替换`
- 阶段目标：`资产管线定型 + 第一轮 Demo 表现升级`
- polish 重点：HUD、门控、checkpoint、终点反馈、玩家 / 敌人轮廓可读性
- 开发模式：`分支 + worktree`
- 不做项：不新增新区域、不新增新核心玩法、不重做 UI 系统、不做大规模正式美术替换

## Preflight

- 本轮固定按 `分支 + worktree` 启动
- 分支名固定为 `codex/stage-12-asset-pipeline-and-demo-polish`
- worktree 固定放在 `.worktrees/stage-12-asset-pipeline-and-demo-polish`
- 实现前必须先补齐并同步：
  - `spec-design/2026-04-25-stage-12-asset-pipeline-and-demo-polish-design.md`
  - `docs/implementation-plans/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
  - `plan/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
  - `docs/progress/status.md`
  - `docs/progress/timeline.md`
  - 当日日志
- preflight 必须先做 fresh 基线确认：
  - `godot --headless --path . --import`
  - Stage 1-11 全量 GUT
  - `git diff --check`
- 新 worktree / Godot MCP 进场前，优先按 `docs/dev/godot-mcp-pro-connectivity-guide.md` 做检查或 dry-run
- preflight 中必须显式写明本轮不做项：
  - 不新增第二小区域
  - 不新增玩家新能力或新战斗动作
  - 不新增敌人类型
  - 不做正式存档 / 经济 / 装备 / 技能树
  - 不做大规模正式美术替换
  - 不重做 HUD 为正式 UI 系统

## Key Changes

### 资产管线

- 新增 `docs/assets/asset-manifest.md`
- 新增 `docs/assets/asset-ingestion-checklist.md`
- 建立资产目录结构：
  - `assets/art/characters/player/`
  - `assets/art/characters/enemies/`
  - `assets/art/environment/biome_01_lab/`
  - `assets/art/vfx/`
  - `assets/art/ui/`
  - `assets/audio/sfx/`
  - `assets/audio/music/`
  - `assets/source/references/`
  - `assets/source/ai_generated/`
  - `assets/source/editable/`
- `asset-manifest` 记录字段固定为：
  - 资产 ID
  - 用途
  - 目标路径
  - 尺寸 / 规格
  - 来源
  - 授权状态
  - 当前状态
  - 接入阶段
  - 替换优先级
  - 备注
- 本阶段不把资产清单扩成正式资源数据库，只作为可读、可维护的 Markdown 管线入口

### 第一轮轻替换

- 玩家仍保留当前 `Polygon2D` 和碰撞结构，但轮廓表现需要更清晰
- 现有 3 类敌人保留 AI、碰撞、受击契约，仅做轻量视觉区分增强：
  - `BasicMeleeEnemy`
  - `GroundChargerEnemy`
  - `AerialSentinelEnemy`
- 接入少量最小 VFX：
  - 基础攻击 slash
  - 命中 spark
  - checkpoint / 门控 / 终点提示图形
- 所有轻替换都必须保留几何占位 fallback，不允许因为资产缺失破坏 demo 可运行性

### Demo 表现升级

- HUD 做第一轮可读性 polish：
  - 生命
  - 冲刺状态
  - 成长 / 收集反馈
  - 当前目标
  - demo 完成反馈
- 门控、checkpoint、终点方向提示必须更清楚
- 终点房完成反馈与重开入口需要能被人工试玩者理解
- 不改变 `Main`、房间切换、checkpoint、敌人契约的核心逻辑

### 文档与资产接入规则

- 用户后续寻找、购买或生成资产时，默认追加到 `asset-manifest`
- 后续 Stage 13+ 如果出现新区域、新敌人、新能力、新 Boss 或新 UI，不重新做整套规划，而是沿用 Stage 12 建立的清单和目录规范追加条目
- 只有美术方向、渲染方式、动画规格或资源类型发生结构性变化时，才修订资产规划

## Public APIs / Interfaces

- 不新增新的玩家动作接口
- 不新增新的敌人基础契约
- 不新增正式存档、经济或背包接口
- HUD 可以新增最小图标 / 文案读值，但继续通过现有稳定快照消费数据
- 房间侧继续沿用：
  - `get_hud_context() -> Dictionary`
  - `room_transition_requested`
  - `checkpoint_requested`
- 敌人侧继续沿用：
  - `receive_attack(...)`
  - `defeated`

## Test Plan

- 基线验证：
  - `godot --headless --path . --import`
  - Stage 1-11 全量 GUT
  - `git diff --check`
- 新增 Stage 12 GUT，至少覆盖：
  - 资产目录已创建
  - `asset-manifest.md` 存在且包含必要字段
  - `asset-ingestion-checklist.md` 存在且覆盖导入、路径、显示、碰撞、HUD、授权记录
  - 玩家和 3 类敌人的可视节点仍存在
  - HUD 关键文案和 demo 完成反馈不回归
  - Stage 11 灰盒主线仍能跑到 demo 完成
- 资产接入后必须确认：
  - Godot 可正常导入资源路径
  - 替换不影响碰撞、攻击判定、敌人受击、房间推进
  - 自动化测试不依赖用户本地未提交资产

## Manual Review / 人工复核

阶段收口前必须完成人工复核，不允许只用自动化替代。

人工复核至少包括：

- 从 `Main.tscn` 完整跑到 `stage11_demo_end_room`
- 至少进入一次 Stage 10 支路
- 至少进入一次挑战房
- 至少触发一次失败 / 重来
- 至少触发一次 demo 完成反馈
- 至少验证一次重开入口
- 观察并记录：
  - 玩家轮廓是否更清楚
  - 三类敌人是否更容易区分
  - 攻击 / 命中反馈是否更可读
  - checkpoint / 门控 / 终点提示是否更容易理解
  - HUD 是否遮挡或误导
  - 视觉资产是否造成碰撞误判
  - 是否存在明显卡点或节奏问题

人工复核结果必须写入当日日志，并给出是否达到 Stage 12 收口标准的判断。

## Assumptions

- Stage 12 的资产强度固定为 `规范 + 轻替换`
- 当前没有正式外部资产包作为硬依赖；允许使用占位、临时、AI 或免费资产，但必须记录来源和授权状态
- Stage 12 不扩内容长度，只改善现有 demo 表达和资产管线
- 若资产接入风险高于预期，优先保留资产清单、目录规范、HUD polish 和人工复核，不为了替换更多视觉牺牲稳定性
- Stage 12 完成后，Stage 13+ 的新资产需求默认追加进同一套 manifest，而不是重新规划资产体系
