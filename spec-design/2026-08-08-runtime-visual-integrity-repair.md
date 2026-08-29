# 运行态视觉一致性完整修复设计

## 文档定位

本设计处理用户实机截图已经确认的三类阻断：生产房间可见地表与真实碰撞错位、HUD 过小且文字与装饰重叠、Luna 跨动作模型身份和锚点不连续。它是一次项目级视觉完整性修复，不把旧结构测试、资源存在或单房截图当作视觉验收完成。

## 已确认根因

### 地形

- 既有 `test_walkable_surface_visual_collision_alignment.gd` 主要核对 alpha 顶沿与碰撞顶沿的 Y 值，没有核对左右边缘、二维占用段或完整运行态变换。
- `formal_terrain_kit_ai01.tileset.tres` 的碰撞 polygon 使用 `x=0..384`；TileMap cell 原点位于格心，缩放到 64px 后使碰撞整体向右偏移约半格。
- 第一关运行态截图器只覆盖三个硬编码观察点，不能证明 44 房或所有动作状态。

### HUD

- `TutorialHUD` 使用大量固定 offset 和 `8/9px` 逻辑字体；当前 1280x720 基准缩放在 2K 下仍只有约 `12.8-14.4px` 的物理字高。
- 面板装饰和正文共享同一区域，现有测试不检查底边、换行后的字形边界或装饰排除区。
- 教程步骤切换只有文案更新，没有统一的进入、等待提醒和完成反馈层。

### Luna 动作

- 普通跳跃在 `abs(velocity.y) < 80` 时会从 `luna_jump_state_runtime_sheet_ai04` 切到独立生成的 `luna_formal_combat_body_runtime_sheet_ai01/apex`。
- Stage27 正式战斗补片仍为 `final_ready=false`，却可由脚本直接 preload 进入 live runtime。
- 固定 Sprite2D transform 只能避免节点缩放跳变，不能证明不同 sheet 内的人物身份、比例和锚点一致。

## 设计目标

1. 建立覆盖世界图 44 个生产房间、能对当前错位报红的二维地形审计。
2. 从共享 TileSet 与权威碰撞源修正，不再以逐房无记录 offset 掩盖根因。
3. 把 HUD 改为响应式内容布局，并以共享符光反馈突出教程当前步骤。
4. 普通移动和跳跃只使用同一 Luna Model Lock 家族；未完成最终验收的补片不得进入 live runtime。
5. 自动门禁、运行态截图与真人视觉签核各自保留明确边界。

## 二维地形契约

### 扫描范围

- 世界图配置中的全部 44 个生产房间。
- `TileMapLayer`、`StaticBody2D`、one-way platform、门禁、移动平台和带碰撞的遗留节点。
- 正式 TileMap 房使用 `TerrainCollisionVisual` / `PlatformCollisionVisual` 为权威；Stage25 静态 Floor 房按 Polygon2D 与 CollisionShape2D 核对。

### 双向规则

- 每个声明为可踩的碰撞水平段必须存在对应可见承托。
- 每个声明为可踩的可见地表必须存在对应碰撞；纯装饰必须显式标记 `visual_only` 或 `non_walkable`。
- 比较运行态全局坐标中的 top、left、right 与连续占用段，不只比较单格 top Y。
- 普通边缘容差为 2 个逻辑像素；有斜角或透明收边的 cap 使用资源级明确 allowance，不允许用全局宽松阈值吞掉错位。
- 每个房间输出结构化记录：房间、节点、格段、视觉 bounds、碰撞 bounds、差值、例外和 verdict。

### 修正原则

- 384px TileSet collision polygon 的 X 坐标以格心为原点，标准满格范围为 `-192..192`。
- 共享 polygon、切片透明边距和 texture origin 在资源层修正；生成器和模板必须同步同一契约。
- 遗留权威只能显式退役或明确保留，不能与 TileMap 碰撞叠加。
- 门禁和逻辑 Area 不冒充地形，也不因地形审计被误删。

## HUD 正式重排

- 使用 Container、Theme 与内容最小尺寸组织左上状态、顶部教程和右上元素/姿态区；固定 offset 只保留外层安全区锚点。
- 1280x720 下正文不低于 16px、标题不低于 20px；2K 下正文目标 20-22px、标题 24-28px。
- NinePatch 装饰必须定义 content margins；文字与高对比纹样使用独立区域。
- 最长中文、键鼠、手柄、Boss、恢复和空正文状态都必须完整落在四边安全区内。

### 教程共享符光提醒

- 唯一 `TutorialAttention` 视觉层追踪当前教程提示，不为每个 Label 常驻独立动画。
- 新步骤：约 0.2 秒青色符光扫入和轻微 scale emphasis。
- 未操作 3-5 秒：低频呼吸提醒；检测到相关输入后停止。
- 步骤完成：一次金色扫光并归于静止。
- 设置中的降低动态效果模式禁用位移/缩放，只保留短透明度与颜色变化。

## Luna Model Lock 修复规则（实施代号 v2）

这里的 `v2` 是 2026-08-08 修复轮次代号，不是新的 Model ID；生产 Model ID 始终为 `luna_model_v1`。2026-08-09 起，机器权威统一迁入 `docs/assets/character-creature-model-locks.json`，并与普通敌人和 Boss 共用 `character_creature_model_lock_v1` 契约。

- Canonical model 先沿用 `luna_model_v1` 的 ai03/ai04 移动家族，直到新的统一全动作包通过人工身份签核。
- 普通 jump start、rise、apex、fall、land 全程不得混入独立 Stage27 sheet。
- 所有 live body sheet 固定 `192x192`、`center_x=96 +/-2px`；地面动作 `foot_y=176 +/-2px`，站姿高度允许 `+/-4%`。
- 自动化核对资源家族、画布、alpha bounds 中心与锚点连续性；人物脸型、服装、发型和绘制风格仍由接触表人工签核。
- 资产门禁扫描 `.tscn`、`.tres` 与脚本 `preload/load`；`final_ready=false` 资源只能进入显式 debug/review 路径。

## 验证矩阵

- 地形：44/44 结构化二维报告，无未豁免 P0/P1；全房 debug-collision 截图或接触表。
- HUD：640x360、1024x576、1280x720、1672x941、2048x1152、2560x1080、2560x1440；最长中文与键鼠/手柄组合。
- 动作：idle -> run -> jump rise -> apex -> fall -> land -> attack / dash / hit / death 的接触表与运行态时间序列。
- 工程：Godot 4.6.3 import、相邻 GUT、递归 GUT、主场景 smoke、`git diff --check`。
- 人工边界：自动结果不能替代玩家对碰撞读值、HUD 阅读距离、动态节奏和 Luna 身份一致性的签核。

## 非目标

- 不改变房间拓扑、玩家碰撞盒、移动手感、攻击判定或门控条件。
- 不借 HUD 修复重做暂停、地图、悬赏或 Build 系统。
- 不为了动作一致性引入 AnimationTree 或重写玩家状态机。
- 不在没有资产登记、来源和人工验收时直接生成并接入整套新动作。

## 2026-08-09 实施结论

- 地形根因已在共享 TileSet 修正：正式地形碰撞 polygon 由错误的 `0..384` 改为格心坐标 `-192..192`。结构报告覆盖世界图 `44/44` 房、`1973` 个可踩面条目和 `710` 个碰撞节点，`failed=0`；仅保留教程房左右外边界墙顶 `2` 个明确 `outer_boundary_wall_top` 例外。Windows/OpenGL `--debug-collisions` 捕获 `44/44`，截图 SHA-256 为 `44` 个唯一值。
- HUD 已按物理像素安全区重排。`640x360` 下正文 / 标题为 `16/20px`，七档视口均无面板相交、越界或最长中英混排截断；唯一 `TutorialAttention` 使用青色进入/等待与金色完成 Shader，reduced-motion 关闭位移和缩放。运行报告为 `layouts=7`、`states=5`、`shared_attention=1`、`ok=true`。
- Luna live body 已锁回 ai03/ai04 的 `luna_model_v1`：普通跳跃上升、低速顶点、下落、落地始终使用 ai04；攻击变体由 ai03 body + 独立语义 VFX 表达；Stage27 独立人物表保持 `final_ready=false` 且只作 review resource，不再由玩家脚本 preload。`7` 个 live sheet 共 `111` 帧均为 `192x192`、中心轴 `96 +/-2px`，当前候选严格审计 `7/7`，全动作正式候选审计 `21/21`。
- 生产 Player 真实物理跳跃采样 `54` 帧，四相位均被捕获且跨模型样本为 `0`；接触表和运行态相位图已生成。自动 alpha bounds、锚点与运行绑定通过不等于脸型、发型、服装、轮廓或动作节奏已获真人美术批准。
- 后续通用模型锁专项把同一治理扩展为 `8` 个模型族 / `26` 张 body 证据；本节 Luna 实施结论继续有效，但不再维护另一份独立机器字段定义。
- 自动全路线驱动已更新到当前世界图：主线 `34` 房、正式支路 `4` 房、雷泽 `6` 个唯一房间 / `8` 段回环转换合计覆盖 `44/44` 生产房，Windows/OpenGL 生成 `138` 张 entry/mid/exit 截图，`P0/P1/P2=0`。该驱动会正式确认一次性详情面板，但不是真人输入路线试玩。
- 纯 `Input.action_press/release` 回放在正式碰撞修正后同步校准真实平台起跳边界，不移动玩家、不改房间坐标、不绕过门控；最终从教程自然经过 `34` 个流程房抵达 Stage16 终点，`elapsed=360.2167s`、完成标记为真、`P0/P1/P2=0`。该结果证明自动驾驶输入链可通关，仍不替代实体手柄与真人玩法签核。
