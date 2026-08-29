# HUD / Pause 02 镇妖官印 v4 纠偏修复计划

Date: 2026-08-10

Type: 非 Stage 专项修复

Status: runtime technical candidate integrated; human visual approval pending

## 修复目标

- 废弃 `hud_warden_lacquer_v3` 的运行绑定，不再围绕错误的 NinePatch 比例继续补丁。
- 按真实运行比例重新生产四张只承载可拉伸漆木底框的 Image Gen 资产：Battle `2.70:1`、Tutorial `3.90:1`、Element `2.53:1`、Pause `1.05:1`。
- 明确恢复并保留 02 的视觉锚点：镇妖官印、链条、悬挂官牌、垂饰 / 流苏和朱砂印记；Battle 左侧官印不得因排版便利而被删除。
- 官印、链条、官牌、垂饰和朱砂印记必须作为独立 `TextureRect` 装饰层，保持原始宽高比，不进入 StyleBox / NinePatch 拉伸区。
- 生命、冲刺、目标、恢复图标与量槽统一为同一批 02 美术；动态文字继续由 Godot 绘制并使用同一字体栈。

## 运行契约

| Surface | Source pixels | Ratio | Standard logical size | Approx. width occupancy |
| --- | ---: | ---: | ---: | ---: |
| Battle | `1080x400` | `2.70` | `304x112` | `23.75%` at 1280 |
| Tutorial | `1404x360` | `3.90` | `512x128` | `40%` at 1280 |
| Element | `1012x400` | `2.53` | `320x126.5` | `25%` at 1280 |
| Pause | `840x800` | `1.05` | viewport-derived | about `26%` width, `44%` height |

- 底框允许由 `StyleBoxTexture` 拉伸；独立装饰层必须声明 `non_stretch_visual_layer=true` 与 `visual_anchor_contract=02_warden_seal_chains_tassel`。
- 装饰 `TextureRect` 必须使用 `STRETCH_KEEP_ASPECT_CENTERED`。
- Pause / Failure 沿用交互 A：按钮几何固定，唯一共享 Shader 光带追踪焦点。
- MainMenu 必须隐藏完整 gameplay HUD，不能泄漏教程强调外框。

## 资产与来源

- 原始生成图：`assets/source/ai_generated/batch_08/hud_warden_official_v4/`。
- 运行图：`assets/art/ui/hud_warden_official_v4/`。
- StyleBox：`assets/art/ui/styleboxes/hud_warden_official_v4/`。
- 每个运行 PNG 均有相邻 `.source.json`，记录官方 OpenAI 内置 `image_gen` 来源、候选 / 输出 SHA256、处理边界与人工批准边界。
- 后处理只允许去色键、去溢色、alpha 裁切、裁块和缩放，不允许程序化重绘替代 Image Gen 美术。

## 完成门禁

1. 四张底框源比例与目标比例偏差不超过 `1%`。
2. 生产场景、脚本、测试与审计不再引用 v3。
3. HUD 三面板与 Pause 均存在 02 独立装饰层，装饰不随底框变形。
4. 文字、图标、量槽全部位于内容安全区，支持矩阵无溢出或重叠。
5. Stage12、HUD、Stage16、运行时 UI binding、strict asset package 与递归 GUT 通过。
6. Windows 真窗口提供 gameplay、Pause、Failure 截图；自动截图只形成候选，真人视觉签核保持 pending。
7. 不自动暂存、commit、push、合并或发布。

## 当前执行结果

- 四类 v4 底框、四类独立装饰、四类统一图标和一条统一量槽均已生成、逐图检查并接入运行场景。
- v3 已从生产场景、脚本、测试和运行 UI 审计契约退出；旧文件保留为被否决历史，不作为 live binding。
- Stage12 `10/10` / `364` assertions、HUD `9/9` / `283` assertions、Stage16 `22/22` / `605` assertions、运行 UI binding `2 scenes / 6 panels / 4 non-stretch ornament layers` 已通过。
- Godot `4.6.3` import、主场景 smoke、strict asset package 与递归 GUT `51 scripts / 349 tests / 10428 assertions` 已通过；全量仍报告既有 ObjectDB orphan / leak warning。
- Windows/OpenGL（AMD Radeon RX 7900 XTX）已重新捕获 gameplay、Pause、Failure 并原尺寸检查；真人视觉、物理显示阅读距离、控制器手感与发布条款仍保持 pending。
