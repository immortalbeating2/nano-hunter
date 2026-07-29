# Full Flow MCP QA - 2026-06-29

## Scope

本轮目标是用人工式 Godot MCP 运行态检查、GUT 回归、现有审计脚本、subagents 静态交叉检查和 RoleMux / Agy 美术评审，复核当前 Alpha Demo 关卡、资产配置、关卡合理性、数值和 UI 运行观感。

本轮结论只覆盖当前仓库状态和本次运行态证据，不等于商业版最终美术验收。

## Evidence

- Godot import：`godot --headless --path . --import` 通过。
- LL-00 审计：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/audit_level_layout_map_ll00.gd` 通过，结果 `P0=0 / P1=0 / P2=0`。
- GUT 全阶段回归：`141/141` tests 通过，`1623` asserts 通过；退出时仍有 `ObjectDB instances leaked at exit` 警告。
- Godot MCP Pro CLI：
  - `project info` 连接到当前 worktree，主场景为 `res://scenes/main/main.tscn`，窗口 `1280x720`，viewport `640x360`。
  - 运行态开始游戏后进入 `res://scenes/rooms/tutorial_room.tscn`。
  - 运行态全房间结构巡检覆盖 `39` 个 `scenes/rooms/*.tscn`。
- 运行态证据文件：
  - `tests/artifacts/local/full-flow-qa-2026-06-29/full_room_runtime_review.json`
  - `tests/artifacts/local/full-flow-qa-2026-06-29/all_room_screenshots/`，包含 `39` 张逐房运行态截图。
  - `tests/artifacts/local/full-flow-qa-2026-06-29/01_after_start_cli.png`
  - `tests/artifacts/local/full-flow-qa-2026-06-29/02_stage13_entry.png`
  - `tests/artifacts/local/full-flow-qa-2026-06-29/03_stage14_air_dash_gate.png`
  - `tests/artifacts/local/full-flow-qa-2026-06-29/04_stage15_boss.png`
  - `tests/artifacts/local/full-flow-qa-2026-06-29/05_stage16_end.png`
- RoleMux / Agy：
  - 命令：`rolemux review --provider agy --role reviewer --task .\.rolemux\tasks\full-flow-art-review-2026-06-29.md --workdir .`
  - 结果：`status=success`
  - 输出：`.rolemux/tasks/20260629T152311-382424/output.md`

## Verdict

当前游戏主流程已经不是“点击开始只有背景”的状态，主菜单、教程入口、Stage13-16 代表房间和 GUT 主流程均能运行。关键失败重置缺陷已在本轮修复。

但当前美术和关卡表现仍未达到“所有关卡正式美术完整替换”的水平。自动审计的 `P0/P1/P2=0` 只代表 LL-00 规则下的路径、绑定和资产节点检查通过；从运行态截图和全房间节点统计看，灰盒碰撞、预览图集、正式美术和 UI 文本仍混合存在。

## Fixed In This QA

- 修复同房间失败重置不会重载房间的问题：失败、跌落或 checkpoint 回滚需要清空敌人、门、教程步进等房间状态时，现在会强制重载房间。
- 补充 Stage6 回归测试，覆盖“战斗房清场后玩家失败，房间必须恢复敌人和出口锁定”的契约。
- 修复 Stage9 测试 helper 在 Main 自动重置玩家后继续调用已释放 player 的问题。

## All-Room Runtime Findings

运行态全房间结构巡检覆盖 `39` 个房间：

- `39/39` 房间仍存在 `Polygon2D` 灰盒视觉或几何节点。
- `19/39` 房间存在 `TileMapLayer`。
- `19/39` 房间存在 `visual_preview_only` 类资产绑定说明。
- `26/39` 房间存在 `preview` / `dummy` / `placeholder` 语义节点。
- `2/39` 房间存在明显 atlas preview 节点。

这说明当前地图处于“玩法可运行 + 局部正式资产展示 + 灰盒结构承载”的状态，而不是最终地图美术 author 完成状态。

## Major Remaining Issues

### P1 - 资产配置和视觉一致性

- 全房间仍有灰盒 `Polygon2D`，正式 TileMap 多数只是视觉预览层，还没有成为完整地形 author 和碰撞来源。
- 训练木桩仍是多边形占位资产，作为玩家第一个攻击目标，观感落差明显。
- Stage13-16 代表截图可见：背景图、地面贴片、灰盒地板和 UI 大字同时存在，正式资产没有形成统一场景语言。
- 部分房间仍保留 atlas / preview 节点作为运行态展示，容易被玩家看成未切分的大图或临时贴纸。

### P1 - UI 和分辨率适配

- MCP UI 枚举显示失败面板和完成面板的 `Label` 宽度出现 `1px`，暂停菜单按钮矩形也有重叠迹象。
- 右上角 HUD 文案仍然偏长，在 `640x360` 基准视口中遮挡画面，且更像调试文本而不是正式 HUD。
- 当前 UI 已比之前收缩，但还需要一轮“低分辨率布局契约”专项：面板宽度、字号、锚点、换行和隐藏面板布局都要一起复核。

### P1 - 关卡合理性和数值

- GUT 和运行态代表房间证明主流程可运行，但目前仍缺少“按真人输入从起点逐房走到终点”的逐房录像或完整输入 replay 证据。
- Stage13+ 多个房间存在 spawn fallback 风险，部分 `checkpoint_spawn_id` 没有对应完整 flow 配置，后续容易出现进房位置不符合设计的问题。
- 关卡视觉地形和碰撞地形脱节时，玩家会以为能跳、能站或能穿过的地方，实际由灰盒碰撞决定，容易再次出现“看起来能走但过不去”的问题。

### P2 - 表现层

- 背景图仍多为单张低透明度 Sprite，缺少 ParallaxBackground 和分层空间感。
- VFX 层级还没有统一规范，Boss / player / slash / hit spark / warning 的 z-index 需要一个全局表。
- 部分正式 UI 资产和图标资产没有充分替代纯文字状态。

## Agy Art Review - Simplified

Agy 独立评审给出的最简判断：

- 技术集成度约 `80%`：资源路径、场景引用和测试基础较扎实。
- 视觉完成度约 `35%`：正式资产与灰盒、预览图、纯文字 UI 混合明显。
- 最值得先做：UI 美术解封与重排、TileMap 取代灰盒地形、训练木桩替换、背景视差化。
- 暂不建议做：重生成 Luna 全套动作、给所有房间做最终 autotile 清稿、提前扩大完整音频系统。

## Recommended Minimal Execution Order

1. UI 低分辨率专项：修失败 / 完成 / 暂停面板布局，缩短 HUD 文案，接入已有 UI 图标和面板资产。
2. 训练木桩和首屏交互资产替换：优先保证教程第一分钟没有明显占位物。
3. 样板房 TileMap author：先选 Tutorial、Stage13 entry、Stage14 gate、Stage15 boss、Stage16 end，把灰盒地形和正式地形关系跑通。
4. 全房间 spawn / checkpoint 配置审计：把 fallback spawn 变成显式房间 flow 配置。
5. VFX 层级表和代表特效复核：统一 player / enemy / boss / warning / hit spark 的 z-index。
6. 最后才做全房间视觉清稿和视差背景铺开。

## Exit Criteria For Next QA

- 真人式或脚本输入式从主菜单到 Alpha Demo end 至少完成一条全流程证据链。
- 全房间没有运行态可见的 `dummy` / `placeholder` 首屏关键交互物。
- 样板房中至少一组 TileMap 同时承担视觉和碰撞，不再依赖同位置灰盒 `FloorVisual`。
- UI 在 `640x360`、`960x540`、`1280x720` 三档下无文字越界、面板错位或隐藏面板布局污染。
