# Stage16 Alpha Demo 打包候选设计

## 文档定位

本文档定义 `nano-hunter` Stage16 的阶段设计。Stage16 是 Stage12-15 路线的收束阶段，目标不是继续无限扩内容，而是在 Stage15 稳定基线之上形成一个可试玩、可验证、可记录问题的 `Alpha Demo` 候选版本。

本阶段按大功能处理，采用固定永久工作树 + 阶段分支 + subagent / multiagent 规划。主代理负责最终整合、写入和验证，子代理只在明确边界内提供设计、架构、内容与 QA 输入，不直接竞争同一核心文件。

## 设计目标

Stage16 的核心目标是把 Stage12-15 已形成的内容、能力门控、Boss 原型、资产管线和 QA 流程收束为第二版更完整的 Alpha Demo：

- 从 Stage15 `Seal Guardian / 封印守卫` 击败反馈继续推进到终局封印链。
- 新增 `4-6` 个终局封印链房间，默认采用 `5` 个房间，不创建第三个大区域。
- 补齐最小主菜单、暂停、重开和最终完成反馈。
- 接入最小 SFX / BGM 与第二轮关键视觉占位需求。
- 升级灰盒主线自动化，使其覆盖主线、失败重试、Stage14 回溯链、Stage15 Boss 与 Stage16 终点。
- 输出 Demo 级 QA checklist 与 Alpha Demo release notes。

## 核心体验线

Stage16 的体验线从 Stage15 completion room 开始，而不是从一个全新区域重启内容生产：

1. 玩家击败封印守卫，进入 Stage15 completion room。
2. Stage16 入口展示封印裂开和镇妖符印失衡，提示 Boss 战只是最终封印链的前置。
3. 玩家通过符印连锁房确认 Stage14 Air Dash 与既有移动能力仍然有用。
4. 回溯确认房汇总 Stage14 回溯收益、Stage15 Boss 击败和当前 Demo 完成条件。
5. 妖瘴净化房把 Stage13 的废液 / 酸液灰盒语境回收到“封印渗漏、妖瘴净化、符印机关”方向。
6. Alpha Demo 终点房给出完成反馈、可重开入口、当前可试玩范围和已知问题指向。

## 内容范围

默认新增 `5` 个终局封印链房间：

- `stage16_seal_release_threshold_room`：承接 Stage15 completion room，展示封印裂开、镇妖碑或封印柱解除。
- `stage16_talisman_relay_room`：短平台与符印连锁验证房，使用 Air Dash 通过，不新增能力。
- `stage16_backtrack_confirmation_room`：回溯确认房，汇总 Air Dash、回溯收益和 Boss 击败状态。
- `stage16_corruption_purge_room`：妖瘴净化房，把废液 / 酸液语境改写为符印净化与封印渗漏。
- `stage16_alpha_demo_end_room`：Alpha Demo 最终完成房，提供完成反馈、重开提示和 release notes 指向。

这些房间允许复用已有敌人、门控、危险和 HUD 反馈，但不新增敌人类别、核心能力、正式剧情系统或正式地图系统。

## Demo 壳

Stage16 的 Demo 壳只服务 Alpha Demo 候选：

- 主菜单：最小开始入口，能进入 demo 起点。
- 暂停：提供继续与重开，不做设置页、键位页、存档槽或音量系统。
- 重开：调用现有 `restart_demo()` 或其 Stage16 扩展版本，清理当前试玩运行期进度。
- 完成反馈：在 Stage16 终点房和 HUD 中显示 Alpha Demo 已完成、可重开、可查看 release notes。

Demo 壳不承担正式产品外层 UI 架构，不引入正式场景栈或 UI Router。

## 资产与音频方向

Stage16 继续遵循 Stage12 建立的资产清单规则。新增资产需求默认记录到 `docs/assets/asset-manifest.md`，先以 `needed` 或 `placeholder_ready` 状态存在，不要求全部正式接入。

建议追加资产方向：

- `stage16_seal_release_props`：封印裂开、石柱、符印链条、镇妖碑。
- `stage16_talisman_relay_vfx`：符印连锁光路、机关激活反馈。
- `stage16_corruption_purge_vfx`：妖瘴净化、封印渗漏被压制。
- `stage16_alpha_demo_completion_ui`：Alpha Demo 完成反馈图形。
- `stage16_demo_sfx_pack`：封印破裂、符印激活、门开启、完成反馈。
- `stage16_demo_music_loop`：最小 BGM 循环。

Stage13 既有 `bio_waste` / 废液命名短期可作为灰盒路径保留，但 Stage16 文案、HUD、资产备注和 release notes 应使用“妖瘴、封印渗漏、符印节点、镇妖印、封妖禁地”等语境。

## Goals

- 新增终局封印链房间并接入 Stage15 completion room 后续。
- 形成 Alpha Demo 最小外壳：主菜单、暂停、重开、完成反馈。
- 让 `Main.get_demo_progress_snapshot()` 能表达 Stage16 Alpha Demo 完成态、QA checklist 状态和 release notes 状态。
- 升级 HUD，使完成态优先显示 Alpha Demo 结果，不继续显示旧 Boss 目标或旧收集行。
- 升级灰盒主线自动化，覆盖从 `Main.tscn` 到 Stage16 终点的主链路。
- 建立 Demo 级 QA checklist 与 Alpha Demo release notes。
- 记录第二轮关键视觉、音频和灰盒语境回收需求。

## Non-Goals

- 不做完整商业版内容量。
- 不新增第三个大区域。
- 不新增核心能力、敌人类别或第二个 Boss。
- 不做正式存档、成就、设置页、键位配置或多槽位菜单。
- 不做完整剧情系统、过场动画或对白系统。
- 不把 `SealGuardianBoss` 扩成正式 Boss 框架。
- 不把灰盒 driver 扩成通用关卡求解器。

## Public Interfaces

`Main.get_demo_progress_snapshot()` 计划新增：

- `stage16_alpha_demo_completed`
- `stage16_release_notes_ready`
- `stage16_qa_checklist_ready`

Stage16 房间继续沿用：

- `room_transition_requested(target_room_path: String, spawn_id: StringName)`
- `checkpoint_requested(room_path: String, spawn_id: StringName)`
- `goal_completed`
- `bind_player(player)`
- `bind_main(main)`
- `get_spawn_position(spawn_id: StringName) -> Vector2`
- `get_camera_limits() -> Rect2i`
- `get_hud_context() -> Dictionary`
- `should_reset_on_player_defeat() -> bool`

Demo 壳只调用：

- `restart_demo() -> void`
- `get_demo_progress_snapshot() -> Dictionary`

暂停状态由 Demo 壳自身持有；正式进度仍归 `Main`。

## Subagent / Multiagent 模型

Stage16 默认启用 `4` 个核心 subagent，由主代理统筹整合：

- `design`：阶段边界、终局封印链体验、Goals / Non-Goals、正式阶段计划结构。
- `architecture`：Main / HUD / 房间契约、Demo 壳接口、暂停与重开边界、灰盒 driver 扩展点。
- `content`：`4-6` 个终局封印链房间职责、房间顺序、回溯验证点、资产接入范围。
- `qa`：Stage16 GUT、灰盒主线自动化升级、QA checklist、Godot MCP 运行态复核清单。

按需追加：

- `asset_direction`：第二轮关键视觉、音频命名、资产清单与授权状态。
- `godot_runtime`：MCP preflight 与运行态人工复核。
- `production`：进度文档、分支 / worktree 留痕、release notes 与阶段收口。

约束：

- 子代理不得继续派生子代理。
- 多个代理不得同时修改同一核心脚本。
- 主代理负责最终整合、验证和对用户交付。

## 验收标准

- Alpha Demo 可以从开始稳定推进到 Stage16 终点。
- Stage16 终局封印链房间可进入、可退出、可理解，并能承接 Stage15 Boss 击败状态。
- 失败、重开、回溯、Boss 战和完成反馈都成立。
- 主菜单、暂停、重开和完成反馈有最小可用实现。
- 全量 GUT、Stage16 专项 GUT、Godot import 与 `git diff --check` 通过。
- Godot MCP 运行态人工复核完成并记录结果。
- Demo 级 QA checklist 和 Alpha Demo release notes 完成。
- 资产清单能区分“已接入、临时占位、待替换、可延后”。

