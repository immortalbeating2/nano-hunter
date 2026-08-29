# HUD 内容安全区与地形资产语义专项修复设计

## 文档定位

本轮是 2026-08-08 运行态视觉一致性修复的纠偏轮次，不创建新 Stage，也不新增玩法。用户实机截图证明原有自动门禁仍可在两类明显错误下假绿：HUD 文字虽然位于 Panel 外框内，却压到装饰纹样；同一薄平台图片同时表达单向跳台和实体门楣，并让实体碰撞顶面落在图片底边。

## 已确认问题

1. `PromptPanelArt`、`BattlePanelArt`、`ElementPanelArt` 把 `192x96` 装饰图作为普通 `TextureRect` 非等比拉伸，绕过已有 `StyleBoxTexture` 的 NinePatch 和 `24px` content margins。
2. HUD 测试只检查 Label 相对 Panel 外框的固定边距，没有检查实际装饰资源的内容安全区，因此截图中的碰撞仍会通过。
3. `tutorial_thin_platform_visual_ai01` 同时绑定 `one_way_platform` 与 `thin_solid`。前者以图片顶缘为接触面，后者却以图片底缘为碰撞顶面，已知教程房两格相差约 `22px`。
4. 同一外形承载两种互斥物理用途会破坏玩法预示；教程场景尤其不能依赖玩家试撞后猜规则。

## 修复方向

### HUD

- 三个常驻面板直接使用 `StyleBoxTexture` / NinePatch，不再叠一张全尺寸拉伸 `TextureRect`。自动切片中含大段透明像素的竖卡区域不得作为横向 HUD 框。
- Label、图标、资源条和进度文案的布局只从 StyleBox content margins 派生；测试和截图报告也读取同一运行时安全矩形。当前横框把顶部莲纹占用区纳入安全边距，四边为 `24 / 64 / 24 / 24px`，不以缩小字号规避纹样。
- 保留当前三面板信息层级、字号目标和唯一 `TutorialAttention`，不借机重做 HUD 功能。

### 地形资产

- `tutorial_jump_platform_visual_ai02`：只表达可从下方穿越的水平跳台；顶面连续、薄、端头不形成斜坡暗示。
- `tutorial_dash_gate_lintel_visual_ai01`：只表达实体封印门楣；厚度、下沿、支撑和封印结构必须明显，碰撞顶面与可见顶缘一致。
- 真正坡道 / 台阶未来使用独立 `stair_ramp_*` 资产与对应多边形；不得复用上述两类水平件。
- 同一 `asset_id` 默认只能声明一个 `physics_affordance`。需要多用途时必须在机器契约中显式列举并经过人工批准，本轮不建立例外。

## 自动化缝隙

1. HUD：实际 Control 矩形必须完全位于 StyleBox content safe rect；原始全尺寸装饰 TextureRect 禁止回归。
2. 地形几何：所有可踩表面均比较 `visual_alpha_top` 与 `collision_top`，不得以“视觉任一边缘接近碰撞任一边缘”替代。
3. 地形语义：世界图全部生产房间反向收集 `asset_id -> physics role`，同一资产出现互斥角色立即失败。

## 全地图范围

- 扫描 `alpha_demo_world_map.json` 的全部 `44` 个生产房间。
- 现有 `ThinPlatformSurfaceVisual` 统一收敛为单向跳台语义；教程房额外使用独立 `DashGateLintelVisual`。
- 其它房间若发现同图异角色、顶缘错位或缺少角色声明，同轮修复；若没有，则在报告中明确记录零新增问题，而不是扩大问题数量。

## 非目标与签核边界

- 不改房间拓扑、玩家碰撞盒、跳跃参数、Air Dash 门控或关卡坐标。
- 不把水平跳台改成真实斜坡，也不新增坡面移动规则。
- 自动测试、alpha 扫描和实机截图只证明绑定、几何与排版候选；最终资产审美、用途直觉和 HUD 阅读距离仍由真人签核。
