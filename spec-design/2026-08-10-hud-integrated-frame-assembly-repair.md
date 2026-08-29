# HUD 一体化框体装配专项修复设计

Date: 2026-08-10

Type: 非 Stage 专项修复

Status: 已形成运行态自动技术候选，待用户真人视觉复核

## 问题定义

当前 Battle、Tutorial、Element 三块游戏内 HUD 使用一张已经完成转角、金属包边和链纹的 NinePatch 底框，同时又把官印、链钩、悬挂官牌 / 流苏和朱砂印作为同一个前景 `OrnamentLayer` 覆盖。该结构没有装配插槽、前后遮挡或共同轮廓，实际运行时必然形成“套件粘贴”、连接处互相遮挡和边缘不一致。

独立装饰还经历色键抠图、Lanczos 归一化和 Godot 运行时强烈缩小。链条从 `768px` 缩到约 `108~128px`，朱砂印从 `384px` 缩到约 `24~28px`；现有像素审计中两者半透明像素占比分别约为 `40.9%` 与 `80.4%`，线性过滤与节点透明度进一步放大毛边。

## 已批准方向

采用“一种 HUD 状态对应一张完成装配的一体化 Image Gen 框体”，不继续调整现有独立贴片的位置或层级。Battle 因内容区存在 `112/136/160px` 三种高度，使用默认与增高两张同构框体，整张切换而不拉伸官印。

- Battle、Tutorial、Element 分别生成独立完整框体，官印、链条、悬挂官牌 / 流苏和朱砂印直接成为框体结构的一部分。
- 连接语法必须明确：官印嵌入金属座，链条穿入或绕过上沿固定件，官牌从可见挂钩自然垂下，朱砂印落在漆木或纸符表面，不能漂浮在边框上。
- 复杂装饰不得越过框体外轮廓成为需要单独抠图的细碎悬空像素；外轮廓保持连续、可稳定去色键。
- 三块框体保留 `02 镇妖官印` 的黑漆木、旧铜、冷青符光和少量朱砂红，不删除用户已经批准的官印、链条、垂饰或官牌。
- 不生成文字、图标、资源条或按钮；这些动态内容继续由 Godot 绘制。

## 运行结构

三块游戏 HUD 的最终绘制关系为：

```text
Godot 动态文字、图标与资源条
一体化 Image Gen FrameArt TextureRect（等比居中）
无纹理 StyleBox（只保存内容安全区）
游戏世界
```

生产场景不得再包含：

- `PromptPanel/OrnamentLayer`
- `BattlePanel/OrnamentLayer`
- `ElementPanel/OrnamentLayer`
- 三块 HUD 对 `warden_seal_medallion_ai01`、`warden_chain_hook_ai01`、`warden_chain_talisman_tassel_ai01`、`warden_cinnabar_stamp_ai01` 的运行引用

Pause 与 Failure 不属于本轮范围，继续使用现有 v4 外框、独立装饰和共享 A 焦点光带。

## 资产规格

| Surface | Runtime source | Ratio | Target pixels | Runtime role |
| --- | --- | ---: | ---: | --- |
| Battle | `battle_frame_integrated_warden_ai01.png` | `2.70:1` | `1080x400` | 左侧官印座、顶部链路、右侧官牌与朱砂印完整装配 |
| Battle Expanded | `battle_frame_integrated_warden_expanded_ai01.png` | `1.90:1` | `760x400` | 恢复 / Boss 增高状态使用，同构但扩展漆木内容区 |
| Tutorial | `tutorial_frame_integrated_warden_ai01.png` | `3.90:1` | `1404x360` | 横向教程框，装饰集中在四周，中央保留两行文字安全区 |
| Element | `element_frame_integrated_warden_ai01.png` | `2.53:1` | `1012x400` | 紧凑状态框，装饰不可侵入三行状态文字安全区 |

- 原始候选保存到 `assets/source/ai_generated/batch_08/hud_warden_integrated_v5/`。
- 运行资产保存到 `assets/art/ui/hud_warden_integrated_v5/`。
- 只承载内容边距的无纹理 StyleBox 保存到 `assets/art/ui/styleboxes/hud_warden_integrated_v5/`。
- 不覆盖 v4 文件；v4 继续服务 Pause / Failure，并作为被替换的 HUD 历史证据。
- 运行 PNG 必须具备 Alpha、透明四角、无可见色键残留，外缘半透明像素比例不得超过 `28%`。
- 只允许去色键、despill、裁切、缩放和极小范围 alpha 收边，不允许程序化重绘替代 Image Gen 美术。

## 等比缩放与安全区

- 保持现有三块 HUD 的逻辑占屏比例和响应式布局，不借本轮扩大或缩小 HUD。
- 完整框体由 `TextureRect.STRETCH_KEEP_ASPECT_CENTERED` 等比缩放，不通过 NinePatch 切割官印、官牌、链路或挂钩。
- Battle 默认高度显示 `2.70:1` FrameArt；恢复或 Boss 增高状态切换到 `1.90:1` FrameArt。两张只能二选一显示。
- 内容安全区至少维持 v4 水平内边距：Battle `52/30px`、Tutorial `74/34px`、Element `72/30px`；如新图装饰侵入，则只能扩大安全区，不能压缩文字。
- 动态文字与资源条继续位于 StyleBox content margin 内，并额外保留既有 `10px` 呼吸距离。

## 验收门禁

1. 新回归测试先因 v5 路径缺失和三个 `OrnamentLayer` 仍存在而失败。
2. 四张运行 PNG 比例偏差不超过 `1%`，透明角有效，半透明外缘比例不超过 `28%`。
3. 三块 HUD 绑定 v5 一体化 FrameArt 和无纹理安全区 StyleBox；生产场景不再实例化独立覆盖装饰。
4. Pause / Failure 的 v4 绑定和共享 A 光带保持不变。
5. 七档 HUD 布局、最长教程文本、安全区与顶部面板互不重叠回归通过。
6. Stage12、HUD 定向 GUT、运行 UI binding、strict asset package、Godot import、主场景 smoke 与递归 GUT取得本轮新鲜结果。
7. Windows 真窗口重新捕获 `2048x1152` gameplay，原尺寸检查三个 HUD 的四角、官印座、链路、官牌挂点和朱砂印边缘。
8. 自动结果只形成运行态技术候选；最终审美、物理显示阅读距离、授权和 Gate26H 仍需真人签核。
