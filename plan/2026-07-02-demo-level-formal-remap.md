# Alpha Demo Formal Level Remap Plan

## Summary

本计划把 Alpha Demo 关卡从“线性可通的原型房间链”修正为“正式 Demo 级横版类银河恶魔城区域”。核心修复对象是红绿封印门 / 绿色台阶读值、普通房间双向返回、房间连接处落坑、房间尺度过短和背景延展不足。

## Stage Boundary / Preflight

- 当前基线：Stage16 Alpha Demo 候选已可从主菜单通关，DAC strict gate 和输入式 replay 均通过。
- 本阶段性质：Alpha Demo 试玩反馈修正与正式关卡 remap，不是 Stage17 新玩法。
- 必须先在阶段分支执行，不直接改 `main`。
- 开始前重跑 `git status --short --branch`，确认 dirty tree 范围；不得回滚用户或前序会话改动。

## Goals

- 普通相邻房间默认双向通行。
- 房间出入口具备安全落点，不用无提示落坑做连接。
- 强视觉元素语义清楚：门是门，台阶是台阶，目标提示不是碰撞平台。
- 关键房间长度和背景覆盖符合正式 Demo 节奏。
- 阶段六使用 Godot MCP Pro 做运行态人工复核。
- 图形资产缺口允许使用 image_gen 生成正式门、台阶、出口和 parallax 层。

## Non-Goals

- 不新增完整商业版地图系统。
- 不重写玩家控制、攻击、Boss AI 或存档系统。
- 不启用额外插件。
- 不把所有房间一次性推进到商业级手工清稿。

## Content Scope

- Tutorial、Combat Trial、Goal Trial。
- Stage9 到 Stage16 的 Alpha Demo 主路线普通连接。
- Stage13 / Stage14 / Stage15 / Stage16 的关键支路和回溯房。
- Boss 房和终局房只做锁门语义与出入口安全，不强制双向开放。

## Asset Scope

- 复用现有 shrine / miasma / seal / dac formal terrain 资源。
- 新增资产仅限读值缺口：正式封印门、目标石台、出口标识、可延展背景层。
- image_gen 输出必须落到 `assets/source/ai_generated/demo_level_formal_remap/`，接入图落到对应 `assets/art/` 子目录，并更新 `docs/assets/asset-manifest.md`。

## Key Changes

- 在共享房间基类中加入反向出口契约。
- 为非基类房间补反向出口逻辑。
- 为场景补 `LeftExitZone`、反向 spawn、连续安全落点和门洞视觉。
- 替换误导性的红绿封印门和纯色绿色台阶。
- 以房间玩法节奏扩展关键房间宽度和背景层。
- 新增正式 Demo remap 自动化测试和 MCP 运行态复核脚本 / 清单。

## Public Interfaces

- 延续 `room_transition_requested(target_room_path, spawn_id)`。
- 新增场景导出字段：`previous_room_path`、`previous_spawn_id`。
- 新增可选节点：`LeftExitZone`、`LeftExitMarker`、`RightExitMarker`。
- 保留 `get_spawn_position(spawn_id)`、`get_camera_limits()`、`get_hud_context()`。

## Implementation Plan

1. 写正式拓扑和失败测试。
2. 实现共享房间反向出口契约。
3. 补齐早期独立房间和特殊房间的反向出口。
4. 重排关键房间的安全落点、地形连续性和尺度。
5. 替换误导性资产并按需使用 image_gen。
6. 使用 Godot MCP Pro 运行态验证主线和反向返回。
7. 更新进度文档、交付清单和提交记录。

## Test Plan

- Godot import。
- 新增正式 remap GUT。
- Stage5、Stage9、Stage13、Stage14、Stage15、Stage16 GUT。
- DAC strict art kit gate。
- full-flow production evidence。
- input-only replay。
- Godot MCP Pro 阶段六人工式左右通行复核。

## Manual Review / Runtime Review

阶段六必须覆盖：

- 主菜单进入 Demo。
- Tutorial -> Combat -> Goal 的正向与反向返回。
- Stage13 主线与至少一条支路返回。
- Stage14 能力门和回溯 hub。
- Stage15 Boss 锁门解释。
- Stage16 threshold / relay / purge / end。
- 关键房间入口、中心、出口、反向返回截图。

## Documentation Updates

- `spec-design/2026-07-02-demo-level-formal-remap.md`
- `docs/implementation-plans/2026-07-02-demo-level-formal-remap-plan.md`
- `docs/progress/status.md`
- `docs/progress/timeline.md`
- `docs/progress/logs/2026-07-02.md`
- 如使用 image_gen，更新 `docs/assets/asset-manifest.md` 和 provenance / source safety 报告。

## Exit Criteria

- 所有普通相邻房间通过双向连接测试。
- 出入口安全测试通过，无无提示连接落坑。
- 红绿封印门和绿色纯色平台误读消除。
- 关键样板房截图达到正式 Demo 读值。
- 阶段六 Godot MCP Pro 复核记录完成。
- 文档和验证结果完成留痕。

## Risks

- 大量 `.tscn` 修改容易引入导入噪音，必须分批提交。
- 双向返回可能暴露旧 checkpoint / spawn fallback 问题。
- image_gen 背景若不可拼接，会制造新的接缝和平台误读。
- Boss / 终局锁门需要保留单向例外，不能机械套用双向规则。

## Assumptions

- 当前玩家移动能力、跳跃高度、dash 能力和攻击时序不在本阶段修改。
- 当前 `FormalTerrainTilemapDecor` 仍可作为视觉层；真实碰撞先沿用 StaticBody2D / CollisionShape2D。
- Godot MCP Pro 可通过直连工具或 CLI 通路完成阶段六复核；若直连失败，按现有 connectivity guide 使用 CLI 通路。
