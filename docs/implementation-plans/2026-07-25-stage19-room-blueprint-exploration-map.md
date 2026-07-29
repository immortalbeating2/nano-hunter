# Stage19 房间蓝图与探索地图实施计划

## 目标

让当前三环路 / 五远端连接在游戏内可发现，并清除 Stage11 旧 Demo 终点造成的错误完成与重开语义。只使用当前房间和 UI 资产，不新增玩法内容。

## 清单

- [x] 新增 Stage19 红灯测试，保护 38 房布局、连接一致性、发现状态和 Stage11 新语义。
- [x] Main 记录本轮 `visited_room_paths`，提供地图快照，并让完整 `demo_completed` 只属于 Stage16。
- [x] 新增最小 `WorldMapView`，绘制已发现房、相邻轮廓、当前房和门控连接。
- [x] 用 Image Generation 生成无文字 / 无拓扑地图底板和组件视觉母版，并完成项目来源审计。
- [x] 把 38 房位置与展示连接移入独立 JSON；矩形蛇形图改为曲线路径、符印节点和五区域星座布局。
- [x] 地图面板按底板宽高比响应式扩展，2K 运行态上限由 `900x620` 调整为约 `1597x1100`。
- [x] DemoShell 暂停菜单新增地图按钮、地图面板和返回行为。
- [x] Stage11 HUD 改为镇妖驿厅，左侧返回 Stage10 Challenge，右侧继续 Stage13 Entry。
- [x] 更新 Stage11 / 13 / 16 既有测试和灰盒 driver 的完成语义。
- [x] 新增 38 房八项蓝图矩阵，并与房间目录、世界图和运行时地图交叉核对。
- [x] 更新房间内容目录、世界蓝图、status 和当日日志。
- [x] 运行 Stage19、Stage11、Stage13、Stage16 GUT，之后运行全量 GUT。
- [x] 运行 Godot import、主场景 smoke 和 Windows/OpenGL 地图截图复核。
- [x] 检查目标文件注释、乱码、无关 diff 和 `git diff --check`。

## 文件边界

新增：

- `assets/configs/world_map/alpha_demo_world_map.json`
- `assets/art/ui/stage19_discovery_map_base_ai01.png`
- `scripts/ui/world_map_view.gd`
- `spec-design/images/2026-07-28-stage19-discovery-map-visual-reference.png`
- `tests/stage19/test_stage_19_room_blueprint_and_exploration_map.gd`

修改：

- `scripts/main/main.gd`
- `scripts/ui/demo_shell.gd`
- `scenes/ui/demo_shell.tscn`
- `scripts/rooms/stage11_demo_end_room.gd`
- Stage11 / 13 / 16 受影响测试和对应设计 / 进度文档

不修改：

- 其余 37 房 `.tscn`
- 玩家移动、普通敌人、Boss、战斗、TileSet 与碰撞
- 正式存档、快速旅行和输入系统

## 风险控制

- 地图连接必须由测试与场景导出字段核对；地图配置不能驱动切房。
- 地图图片不得包含房间、路线、文字或门控；视觉母版不得被运行时场景引用。
- 普通地图调整只修改归一化 JSON，不重新生成底板或复制一套脚本常量。
- Stage11 保留历史文件路径、节点名和 `goal_completed` 信号，降低旧测试和资产引用风险。
- 地图入口复用 DemoShell 已有暂停状态，不创建第二套暂停控制。
- 当前工作树保留 Stage17 / 18 和用户已有改动，不清理、不提交、不推送。

## 收口证据

- 房间矩阵与运行时地图 `38/38` 一一对应，无缺项或重复；`test_room` 保持排除。
- 专项：本次地图美术重构后 Stage19 `6/6` / `207` asserts，Stage16 `20/20` / `484`；原 Stage11 `5/5` / `25`、Stage13 `15/15` / `392`、Stage18 `12/12` / `1711` 证据保持。
- 全量：`35` scripts、`263/263` tests、`8128` asserts。
- Godot `4.6.3` import、主场景 `--quit-after 60` smoke、`git diff --check` 通过；`project.godot` 无临时 MCP autoload diff。
- Windows/OpenGL 运行态已复核完整地图和首次发现态；本地证据位于 ignored 的 `tests/artifacts/local/stage19/`。
