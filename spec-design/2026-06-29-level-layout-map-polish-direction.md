# Level Layout and Map Polish Direction

## 文档定位

本文档定义 Stage16 Alpha Demo 之后的系统性关卡场景和地图布置方向。它不是 Stage17 玩法扩张方案，也不是商业版完整地图方案；它是一轮 `LL-00` 到 `LL-06` 的关卡可玩性、地图语义、TileSet 接入和运行态复核计划。

本轮优先修正当前 Alpha Demo 中仍然存在的灰盒房间、无意义台阶、碰撞与美术不一致、路线读值不清和正式场景资产只停留在 visual preview 的问题。

## 北极星

- 世界观继续回到南北朝东方奇幻语境：山门古刹、镇妖试炼场、瘴泽妖域、封妖禁地、佛门符印、镇妖卫遗构。
- 不继续扩大现代实验室、生物废液、现代机械表达。
- 关卡先服务玩法读值，再服务美术覆盖。美术不能掩盖玩家、敌人、危险、门、出口和 HUD。
- 当前可用资产先用起来：`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`、Stage13-16 环境图、prop atlas、VFX atlas、UI skin。
- 只有现有图无法满足清晰读值、TileSet 语义、透明 / 切片、尺寸和风格一致性时，才用 image_gen 重新生成。

## 设计目标

- 建立完整 Alpha Demo 房间布置审计：从教程到 Stage16 终点，每个关键房间都有截图、问题等级和修复建议。
- 修复 P0 可玩阻塞：跳不上、过不去、卡死、攻击无效、出口/门控误读。
- 把灰盒平台整理成可解释的地图语义：下方通行、上方回溯、dash 门、攻击门、能力门、危险区、奖励支路。
- 把至少 3-5 个代表房间推进为高质量样板：教程、Stage13 瘴泽入口、Stage14 Air Dash shrine/gate、Stage15 Boss room、Stage16 终局门槛。
- 分离视觉和碰撞：TileMapLayer / Sprite2D / parallax 负责视觉，StaticBody2D / Area2D 负责碰撞和伤害。
- 建立后续地图扩展可复用的最小规则，不做大型地图编辑器或自动生成器。

## 非目标

- 不新增完整地图系统、地图 UI、传送系统或小地图。
- 不重做玩家控制、攻击时序、Boss AI、敌人状态机或能力系统。
- 不一次性替换所有房间为最终美术。
- 不购买或导入大体量外部资产包作为默认方案。
- 不启用额外 Godot 插件，除非 LL 审计证明当前工具链无法完成必需操作。

## 关卡布置原则

1. 每个房间只保留 1 个主要意图。
2. 玩家第一次遇到机制时给宽容空间，第二次组合，第三次用压力验证。
3. 台阶必须有功能：教学、节奏、遮挡、回溯、敌人高度差或奖励路径；没有功能就删。
4. 红色/绿色/发光/符印等强视觉元素必须对应明确交互或状态。
5. 背景不能像可站立平台；前景不能遮挡 hitbox、hazard 或出口。
6. 危险区必须由 Area2D author，不靠图片暗示。
7. TileSet 碰撞只在 LL-04 后进入正式 author；LL-03 允许 visual-only，保留旧碰撞保护通关。

## Image Gen 规格

所有新图都必须走 image_gen，并按用途选择严格规格。

### TileSet / 地图块

- 2D side-view metroidvania tileset, orthographic, no perspective tilt.
- 统一格子：优先 32x32 或 64x64，输出规则网格 PNG。
- 包含地面、墙、平台边缘、内角、外角、装饰块、危险视觉块。
- 不要角色、UI、文字、logo、相机景深、自由散布物件。
- 不要白底、绿底、棋盘格背景；需要透明背景时明确 `transparent background PNG`。
- 每个 tile 独立在格子内，留出足够边距，不跨格。

### 背景 / Parallax

- 16:9 宽幅，建议 1920x1080 或 1280x720 源图，Godot 内缩放。
- 远景、中景、近景分层优先；如果一次生成整图，必须后续拆层或只当远景。
- 不出现可误读为碰撞的平台边缘。
- 不烘入玩家、敌人、HUD、文字、血条或指引箭头。

### Props / 机关 / 门

- 透明背景 PNG。
- 单物件居中，足够留白，不裁切。
- 至少保留关闭、可触发、已完成三态设计空间。
- 强状态色与玩法一致：锁定、可交互、完成、危险分别区分。

### Hazard / VFX

- 透明背景 PNG 或规则 sprite sheet。
- 视觉不得跨越实际伤害 Area 太多；危险边界必须可读。
- 不把 VFX 烘入角色动作帧或背景。

## Godot MCP Pro 使用边界

Godot MCP Pro 用于场景检查、少量节点调整、TileMap 试铺、碰撞读值、运行态截图和输入验证。它不替代关卡设计判断，也不替代最终美术生产。

优先工具：

- 场景：`open_scene`、`get_scene_tree`、`get_node_properties`、`update_property`、`save_scene`。
- 批量：`batch_set_property`、`find_nodes_by_type`、`get_scene_dependencies`。
- TileMap：`tilemap_get_info`、`tilemap_get_used_cells`、`tilemap_set_cell`、`tilemap_fill_rect`、`tilemap_clear`。
- 碰撞：`get_collision_info`、`get_physics_layers`。
- 运行态：`play_scene`、`simulate_action`、`capture_frames`、`get_game_screenshot`、`execute_game_script`、`run_test_scenario`。
- 视觉辅助：`create_particles`、`get_particle_info`、`assign_shader_material`、`get_shader_params`、`set_shader_param`。

大规模 TileMap 操作优先写小脚本生成，再用 MCP 复核；不一格一格手动调用 MCP。

## 外部资产包策略

外部开源或购买资产包只作为备选，不作为默认路线。

采用条件：

- 现有 image_gen 资产和 TileSet 无法通过 LL-03 / LL-04 的读值和碰撞要求。
- 资产风格能回收到东方奇幻、瘴泽、古刹、符印机关语境。
- 授权允许商业 demo / 修改 / 再分发到仓库或构建包。
- 可以拆成 TileSet、props、背景层，不是只有整张插画。

拒绝条件：

- 欧美城堡 / 科幻实验室 / 现代工业风过强。
- baked UI / baked character / baked text 太多。
- 只提供整张背景，无法拆层、无法和碰撞一致。
- 授权不清、禁止 AI 二次修改或禁止商业发布。

## 完成口径

本轮完成不是“所有地图商业级完成”，而是：

- LL-00 到 LL-06 文档、截图、问题清单和验证闭环完整。
- P0 通关阻塞清零。
- 关键样板房达到可看、可玩、可调。
- TileSet / collision / hazard author 的边界清楚。
- 后续是否需要 image_gen 重生图或购买资产包有证据支撑，而不是凭感觉决定。
