# Stage19 房间蓝图与探索地图

## Summary

基于现有 38 房正式场景、房间内容目录和 Stage18 世界图，补齐运行时发现式地图，并把 Stage11 从旧 Demo 终点修正为连接 Stage10 / Stage13 的镇妖驿厅。保持全部房间几何、敌人数量和五条远端连接不变。

## Design Authority

- `spec-design/2026-07-25-stage19-room-blueprint-exploration-map-design.md`
- `spec-design/2026-07-28-alpha-demo-room-blueprint-matrix.md`
- `spec-design/2026-07-11-alpha-demo-room-content-catalog.md`
- `spec-design/2026-07-25-alpha-demo-world-map-blueprint.md`

## Scope

- Main：记录本轮已发现房间并提供地图快照；Stage11 不再提前完成完整 Demo。
- DemoShell：暂停菜单增加地图入口和地图面板。
- 地图配置：`alpha_demo_world_map.json` 独立维护 38 房归一化坐标、编号和展示连接。
- WorldMapView：读取地图配置，以弧线、符印节点和相邻墨雾绘制发现状态。
- 地图美术：Image Generation 只产出无拓扑底板与非运行时视觉母版，后续改路线不重生成底图。
- 房间蓝图：逐房核对平台节拍、出入口、敌人、陷阱、门控、奖励和叙事。
- Stage11：左返 Stage10、右进 Stage13，HUD 回收为镇妖驿厅语义。
- Stage19 测试、运行态地图截图和进度文档。

## Non-Goals

- 不新增房间、能力、敌人、陷阱、正式存档或快速旅行。
- 不调整其余 37 房平台、碰撞、敌人位置和门控。
- 不把地图 UI 变成切房权威。
- 不把房间、路线、文字或门控烘焙进地图图片。

## Implementation

详细执行清单：`docs/implementation-plans/2026-07-25-stage19-room-blueprint-exploration-map.md`。

## Validation

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage19/test_stage_19_room_blueprint_and_exploration_map.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage11/test_stage_11_playable_demo_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage13/test_stage_13_second_content_zone_production.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
godot --headless --path . --import
git diff --check
```

全量 GUT、主场景 smoke 和 Windows/OpenGL 地图截图在专项绿灯后执行。

## Closure

- 38 房矩阵与运行时地图一一对应；Stage11 镇妖驿厅、发现状态和暂停地图均已落地。
- 旧五行蛇形矩形图已替换为数据驱动的五区域星座布局；底板与动态拓扑分离，房间调整只修改 JSON。
- 本次地图美术重构后 Stage19 为 `6/6` tests、`207` asserts；递归全量 GUT 为 `35` scripts、`263/263` tests、`8128` asserts。
- Godot import、主场景 smoke、Windows/OpenGL 地图复核与 `git diff --check` 通过。
