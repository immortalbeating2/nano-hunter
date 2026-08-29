# HUD 一体化框体装配专项修复 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用四张按最终比例生成的一体化 Image Gen 框体（三类 HUD，Battle 含普通 / 增高两态）取代 gameplay HUD 的独立装饰覆盖层，消除贴片感、错误遮挡和色键毛边。

**Architecture:** Battle、Tutorial、Element 使用完整 `FrameArt TextureRect` 等比居中，官印、链路、官牌 / 流苏和朱砂印在源图内完成物理装配；无纹理 StyleBox 只保存内容安全区。Battle 默认态与增高态切换两张同构整框，Godot 仅叠加动态文字、图标和资源条。Pause / Failure 保留 v4 和共享 A 光带，不进入本轮改造。

**Tech Stack:** Godot 4.6.3、GDScript、GUT、OpenAI 内置 Image Gen、Python/Pillow、PNG Alpha、StyleBoxEmpty、TextureRect。

**Status:** 自动实现与验证已收口；真人视觉、授权与 Gate26H 保持 pending。

## Global Constraints

- 视觉方向固定为用户批准的 `02 镇妖官印`；不得重新解释为禁止官印、链条、垂饰、官牌或朱砂印。
- 四张框体目标比例固定为 Battle `2.70:1`、Battle Expanded `1.90:1`、Tutorial `3.90:1`、Element `2.53:1`，偏差不超过 `1%`。
- 不覆盖或删除 v4 资产；Pause / Failure 继续使用 v4。
- 不改变 HUD 当前响应式占屏、教程状态、字体、图标、量槽或教程 Shader。
- 工作树已有大量用户改动；不得清理、暂存、commit、push、合并或发布。
- 自动验证只形成技术候选，不替代真人视觉、授权与 Gate26H。

---

### Task 1: 冻结失败回归契约

**Files:**
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`
- Modify: `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`

**Interfaces:**
- Consumes: `TutorialHUD` 的三个 Panel 节点、既有 StyleBoxTexture 与独立装饰层。
- Produces: `hud_warden_integrated_v5` FrameArt 路径、无 `OrnamentLayer`、v5 Alpha 边缘门禁。

- [x] **Step 1: 将独立装饰断言改为一体化框体断言**

```gdscript
assert_null(prompt_panel.get_node_or_null("OrnamentLayer"))
assert_null(battle_panel.get_node_or_null("OrnamentLayer"))
assert_null(element_panel.get_node_or_null("OrnamentLayer"))
```

- [x] **Step 2: 锁定三张新资源路径和既有比例**

```gdscript
var expected_paths := {
    "PromptPanel": "res://assets/art/ui/hud_warden_integrated_v5/tutorial_frame_integrated_warden_ai01.png",
    "BattlePanel": "res://assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_ai01.png",
    "ElementPanel": "res://assets/art/ui/hud_warden_integrated_v5/element_frame_integrated_warden_ai01.png",
}
```

- [x] **Step 3: 运行测试并确认红灯来自旧结构**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
```

Expected: FAIL，明确报告 v5 路径未绑定或 `OrnamentLayer` 仍存在。

### Task 2: 生成四张一体化 Image Gen 框体

**Files:**
- Create: `assets/source/ai_generated/batch_08/hud_warden_integrated_v5/battle_frame_integrated_warden_ai01_source.png`
- Create: `assets/source/ai_generated/batch_08/hud_warden_integrated_v5/tutorial_frame_integrated_warden_ai01_source.png`
- Create: `assets/source/ai_generated/batch_08/hud_warden_integrated_v5/element_frame_integrated_warden_ai01_source.png`
- Create: `assets/source/ai_generated/batch_08/hud_warden_integrated_v5/battle_frame_integrated_warden_expanded_ai01_source.png`

**Interfaces:**
- Consumes: v4 三张框体、当前 gameplay 实机截图、02 视觉锚点。
- Produces: 三块 HUD 的无文字、平面色键背景一体化源候选，其中 Battle 含默认与增高两种同构状态。

- [x] **Step 1: 逐张调用官方内置 Image Gen**

每张提示词必须说明：正交正视、完整单一 HUD、官印与边框有金属插座、链条进入固定件、官牌从可见挂钩垂下、朱砂印落在表面、中央内容区为空、无文字、无图标、无额外面板、纯色键背景。

- [x] **Step 2: 使用 `view_image detail=original` 检查四张源图**

拒绝条件：装饰悬浮、两个以上框体、伪文字、链条断裂、官牌无挂点、外轮廓被裁、内容区被占用或风格偏离 02。

### Task 3: 透明处理、最终尺寸和来源记录

**Files:**
- Create: `assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_ai01.png`
- Create: `assets/art/ui/hud_warden_integrated_v5/tutorial_frame_integrated_warden_ai01.png`
- Create: `assets/art/ui/hud_warden_integrated_v5/element_frame_integrated_warden_ai01.png`
- Create: `assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_expanded_ai01.png`
- Create: adjacent `.source.json` files for the four runtime PNGs
- Create: `scripts/assets/audit_hud_integrated_frame_alpha.py`

**Interfaces:**
- Consumes: Task 2 source PNGs。
- Produces: `1080x400`、`760x400`、`1404x360`、`1012x400` RGBA PNG 与机器可读 Alpha 报告。

- [x] **Step 1: 使用官方去色键脚本处理每张源图**

Run pattern:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py" --input <source.png> --out <rgba.png> --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
```

- [x] **Step 2: 裁到单一连续框体并缩放一次到最终尺寸**

不得先放大为通用母版再由 Godot 极端缩小；最终运行图直接输出目标像素尺寸。

- [x] **Step 3: 写入来源旁置记录**

每份 `.source.json` 记录 `provider=openai_builtin_image_gen`、最终提示词、源图 SHA256、运行图 SHA256、允许的后处理、`runtime_binding_allowed=true` 与 `final_ready=false`。

- [x] **Step 4: 运行 Alpha 审计**

Run:

```powershell
python scripts/assets/audit_hud_integrated_frame_alpha.py
```

Expected: 四张图片尺寸 / 比例正确、透明角存在、外缘无色键残留、半透明像素比例均不超过 `0.28`。

### Task 4: 用等比 FrameArt 接入并删除 gameplay 覆盖层

**Files:**
- Create: `assets/art/ui/styleboxes/hud_warden_integrated_v5/battle_content_safe.stylebox_empty.tres`
- Create: `assets/art/ui/styleboxes/hud_warden_integrated_v5/tutorial_content_safe.stylebox_empty.tres`
- Create: `assets/art/ui/styleboxes/hud_warden_integrated_v5/element_content_safe.stylebox_empty.tres`
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/dev/audit_runtime_ui_skin_binding.gd`

**Interfaces:**
- Consumes: Task 3 runtime PNGs。
- Produces: 三个只含整张 FrameArt 与动态内容的 gameplay Panel；Pause / Failure v4 不变。

- [x] **Step 1: 新建三份无纹理 StyleBoxEmpty**

复制 v4 的内容安全边距作为下限；StyleBox 不承载纹理，只供 `_panel_content_rect()` 读取安全区。

- [x] **Step 2: 接入四张等比 FrameArt**

三个 Panel 的 `FrameArt` 使用 `STRETCH_KEEP_ASPECT_CENTERED`；Battle 另有默认隐藏的 `FrameArtExpanded`，恢复 / Boss 行出现时与默认 FrameArt 二选一。

- [x] **Step 3: 删除三个 `OrnamentLayer` 及四张独立装饰 ext_resource**

只从 `tutorial_hud.tscn` 删除 gameplay 覆盖层；不得删除 v4 PNG，因为 DemoShell 的 Pause / Failure 仍使用它们。

- [x] **Step 4: 更新运行 UI binding 审计**

TutorialHUD 期望四张 v5 一体化 FrameArt、三张 StyleBoxEmpty 且 `ornament_panels=[]`；DemoShell 继续检查 v4 Pause / Failure 装饰契约。

- [x] **Step 5: 运行定向测试直到绿灯**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
```

Expected: 0 failed tests；binding 审计确认 gameplay HUD 为三张 v5 整体框，Pause / Failure 仍为 v4。

### Task 5: 资产治理与实机验收

**Files:**
- Modify only if generated by existing audit scripts: `docs/assets/asset-package-audit-report.json`
- Modify: `docs/assets/asset-manifest.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/logs/2026-08-10.md`
- Create/refresh ignored evidence under `tests/artifacts/local/runtime-visual-integrity/hud-formal-review/`

**Interfaces:**
- Consumes: Tasks 1–4 的运行绑定。
- Produces: 自动验证、Windows 实机截图与人工边界记录。

- [x] **Step 1: 导入并运行严格资产审计**

```powershell
godot --headless --path . --import
python scripts/assets/audit_asset_package.py --strict --write-report
```

- [x] **Step 2: 捕获七档 HUD、两种 Battle 框体状态和 2048x1152 gameplay**

```powershell
godot --path . --script res://scripts/dev/capture_tutorial_hud_formal_review.gd
godot --path . --script res://scripts/dev/capture_demo_shell_start_review.gd
```

用 `view_image detail=original` 检查三个 HUD 的连接点与外缘。

- [x] **Step 3: 运行主场景 smoke 与递归 GUT**

```powershell
godot --headless --path . --quit-after 120
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

- [x] **Step 4: 检查本轮 diff**

```powershell
git diff --check -- scenes/ui/tutorial_hud.tscn scripts/dev/audit_runtime_ui_skin_binding.gd tests/demo/test_tutorial_hud_formal_layout.gd tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd docs/progress/status.md docs/progress/logs/2026-08-10.md
```

- [x] **Step 5: 更新事实来源**

只记录本轮新鲜命令结果、截图路径、已知 warning 和真人 Gate pending；不得复制旧轮次通过数量充当本轮证据。
