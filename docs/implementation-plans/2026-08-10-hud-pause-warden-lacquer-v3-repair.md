# HUD / Pause 镇妖官印 v3 专项修复计划

> Status: **superseded / visual rejected on 2026-08-10**. 本文只保留历史执行证据；v3 已退出运行绑定，当前机器契约与实现以 `2026-08-10-hud-pause-warden-official-v4-correction.md` 为准。

## 目标

本轮不是正式 Stage，只处理用户已批准的 `02 镇妖官印` UI 方向及其运行态还原：

- 用 Image Gen 独立生成 Battle、Tutorial、Element 与 Pause 四类无文字外框。
- 标准 16:9 视口下，左右 HUD 控制在约 `22%~24%` 屏宽，教程提示控制在约 `34%~38%` 屏宽；常态高度约 `15%~16%`。
- 暂停面板控制在约 `28%~32%` 屏宽和 `48%~54%` 屏高，所有操作项完整落在外框内。
- 暂停与失败操作共用一个 `Shader TIME` 驱动的青色符光横线；脚本只移动同一个节点追踪真实焦点。
- 动态文字、资源条和状态值继续由 Godot 绘制，不烘入位图。

## 资产与来源边界

- 原始候选保存在 `assets/source/ai_generated/batch_08/`，由 `assets/source/.gdignore` 隔离 Godot 导入。
- 运行时透明 PNG 保存在 `assets/art/ui/hud_warden_lacquer_v3/`。
- 每个运行时 PNG 旁放置独立 `.source.json`，记录候选与导出关系；该记录不等同于最终美术批准。
- 被用户否决的 `hud_formal_v2` 保留为历史技术占位，不覆盖、不继续扩张。

## 实现步骤

1. 生成四张独立高分辨率外框，去色键、去溢色、裁透明边并逐张像素检查。
2. 创建四个 `StyleBoxTexture`，分别锁定 NinePatch 切片与内容安全边距。
3. 调整 TutorialHUD 的面板尺寸、行高与物理缩放上限，使占屏约束在支持矩阵内稳定。
4. 将 Pause / Failure 接入新外框；按钮改为固定几何的无底板文字操作，增加唯一共享 `ActionFocusBand`。
5. 补充布局、资源绑定、焦点追踪和标题流程回归。
6. 执行 Godot import、定向 GUT、递归 GUT、严格资产来源审计和 Windows/D3D12 实机截图。

## 完成门禁

- 四张运行时 PNG 均有有效 alpha、独立来源记录和真实场景引用。
- 支持矩阵内 HUD 无出界、无互压、文字完整位于内容安全区。
- Pause / Failure 只有一个共享操作焦点带，切焦点时几何不跳变。
- 新鲜自动验证通过，并提供主游戏 HUD、暂停、失败三个真实窗口截图供人工视觉复核。
- 不自动 commit、push、合并或发布。

## 执行结果（2026-08-10）

- 四类独立 Image Gen 外框、透明处理、来源散列、四个 `StyleBoxTexture` 与真实场景绑定均已落地；Battle / Tutorial / Element 选用去除大徽章后的 candidate 02，Pause 使用 candidate 01。
- 标准 `2048x1152` 实机中，左右 HUD 约占 `24%` 屏宽，教程约占 `39%`；Pause 约占 `30% x 50%`，Failure 使用低矮同系提示框，全部动态文字位于内容安全区。
- Pause / Failure 共用唯一 `ActionFocusBand`；Shader 内部持续流动，脚本只在真实焦点之间移动光带，按钮 normal / hover / focus / pressed 不再改变几何。
- Windows/D3D12 截图已逐张检查；HUD 七档布局、五种教程状态、暂停、失败与地图返回路径均有运行证据。
- 严格 Image Gen source safety 为 `160 candidates / 0 unsafe`；strict asset package 为 `80 queue / 6 runtime UI panels / 4 runtime UI textures / 0 unsafe`；递归 GUT 为 `51 scripts / 347 tests / 10195 assertions`，全部通过。Godot import 与主场景 smoke 退出码均为 `0`，仍输出项目既有 ObjectDB leak warning。
- 本轮未暂存、commit、push、合并或发布；最终视觉、实体显示器阅读距离、控制器手感与 external-release 条款仍需人工签核。

## 后续纠偏

- v3 将 02 方向中的官印、链条、悬挂官牌与垂饰误当成应删除的干扰元素，并为 Battle 删除了用户未要求删除的左侧官印；该解释已被撤销。
- v3 的高冠 Pause 资源也被压入不同运行比例，继续调 NinePatch 无法解决构图变形，因此不再作为修复基础。
- v4 改为“可拉伸漆木底框 + 不可拉伸独立官印 / 链条 / 官牌 / 垂饰层”，并按四类真实运行比例分别生图。
