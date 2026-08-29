# 符印共鸣盘图标 Keyline 高门槛修复 Implementation Plan

> **执行方式：** 在当前共享任务分支内 inline execution；保护既有脏工作树，不创建额外 worktree，不执行 Git 暂存、commit、push、合并或 release。

**Goal:** 按用户批准的方案 A，把六枚图标标准化到统一视觉焦点与光学半径，并让相同 `29px` 序列圆框等大、`34px` 反应圆框按 `34/29` 放大，在静态、动画和七档实机视口中通过实际 Alpha 像素门禁。

**Architecture:** 现有 FrameArt 与 `SealResonanceHud` 三态保持不变；`seal_resonance_anchor_contract.json` 升级为 v2，统一保存图标源像素合同、圆内半径、运行尺寸、标签间距和动画约束。构建脚本以 Alpha 权重质心和光学半径归一化六格，最大半径只负责防越界；运行节点共用圆形安全 Shader；strict、GUT 与 glyph-only 真窗口证据共同 fail closed。

**Design source:** `spec-design/2026-08-12-seal-resonance-icon-keyline-design.md`

## Task 1：冻结合同并建立 RED

**Files:**
- Modify: `assets/art/ui/hud_seal_resonance_v2/seal_resonance_anchor_contract.json`
- Modify: `tests/demo/test_seal_resonance_hud.gd`
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`

- [x] 历史首轮先冻结 `alpha>=16`、质心、最大 keyline、圆内余量与标签间距；Task 6 根据用户复核将视觉尺度改为 `60px` 光学半径，最大 `104px` 仅作为防越界安全线。
- [x] 以独立测试常量检查六格真实 Alpha 像素，而非 `TextureRect` 矩形。
- [x] 增加非 reduced-motion 元素反馈全过程不平移、所有 glyph 共用圆形安全 Shader 的红测。
- [x] 在旧实现上确认失败只指向质心、外径、尺寸、遮罩、标签间距和元素平移。

## Task 2：标准化六枚图标并强化 strict

**Files:**
- Modify: `scripts/assets/build_seal_resonance_hud_assets.py`
- Modify: `scripts/assets/audit_seal_resonance_hud_assets.py`
- Modify: `assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png`
- Modify: `assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.source.json`
- Keep: six AtlasTexture resources under `assets/art/editor_resources/seal_resonance_symbols_warden_ai02/`

- [x] 构建器最终按 Alpha 权重质心与 `60px` 光学半径对六格做单次等比缩放和亚像素居中，`104px` 最大核心半径只做越界拒收。
- [x] 来源记录写入机器可读 `icon_keyline_contract` 与六枚构建后指标；不改变冻结参考输入。
- [x] strict 复算质心误差、最大半径、填充率、边界像素，并加入内存篡改负测。
- [x] 标准 builder 重跑后确认两张 FrameArt SHA 不变、Atlas 语义与 region 不变。

## Task 3：接入圆内尺寸、遮罩与无位移动效

**Files:**
- Create: `assets/shaders/ui/seal_resonance_icon_circle_mask.gdshader`
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/seal_resonance_hud.gd`

- [x] 将 idle / active 七个角色实例尺寸改为冻结的内圆直径。
- [x] 五个 TextureRect 共用同一圆形安全 Shader；各自持有独立 ShaderMaterial 与 Atlas `region_uv_rect`，pivot 固定为圆心。
- [x] 删除元素 `+4px` 平移，改为居中缩放 / 透明反馈；保持 reduced-motion 语义。
- [x] active 姿态文字右移，使文字与圆框净距 `>=8px`。
- [x] `get_semantic_anchor_report()` 返回圆半径、预计 Alpha 核心半径、净距、遮罩和动画圆心 gate。

## Task 4：GREEN、实机像素证据与回归

**Files:**
- Modify: `scripts/dev/capture_seal_resonance_hud_review.gd`
- Refresh ignored evidence: `tests/artifacts/local/seal-resonance-hud/`

- [x] Seal 组件与 formal HUD GUT 全绿。
- [x] strict 资产审计、asset package、runtime UI binding 与 Godot import 全绿。
- [x] 真窗口捕获七档布局、五状态、反馈帧，并输出逐槽 glyph-only Alpha 报告。
- [x] 使用 `view_image detail=original` 检查代表性 `1672x941` 全图和共鸣盘 crop；机器门禁不得替代用户签核。
- [x] 运行 Stage12 / Stage21 / Stage26 与递归 GUT，记录既有 warning 与新失败的边界。

## Task 5：事实源收口

**Files:**
- Modify: `spec-design/2026-08-10-seal-resonance-hud-redesign.md`
- Modify: `docs/assets/asset-manifest.md`
- Modify: `design-qa.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/logs/2026-08-12.md`
- Modify: this plan

- [x] 撤销旧的 `72/44/30/30/40 + 矩形中心` 作为足够门禁的表述。
- [x] 记录六图标 keyline 与五语义槽位的最终机器指标、实机证据路径和风险。
- [x] 维持 `final_ready=false`；本轮截图视觉复核已在 Task 7 关闭，物理显示距离、授权 / Gate26H 继续开放。

## Task 6：光学重量纠偏（2026-08-12 用户复核追加）

- [x] 先增加 `r95 + Alpha 等效墨量` 红测；旧图得到风 / 雷 `1.4405x`、贯穿 / 序列均值 `0.7914x`，准确复现“大框反而最小”。
- [x] 使用官方 ImageGen 重做六符号源，拒收光学重量仍失衡的前两稿；最终贯穿使用粗完整环 + 短枪头，散射使用紧凑三向厚片。
- [x] 构建器改为统一 `60px` 光学半径、`104px` 最大安全半径；六枚结果为 `59.944–59.978px`。
- [x] 真窗口新增正反两枚反应图的最终栅格光学比：序列 A/B `0.9791–1.0214`；反应 / 序列均值 `1.1365–1.1894`（`1x` 及以上），七档与反向反应均通过。

## Task 7：微尺寸清晰度与黑点根治（2026-08-12 用户复核追加）

- [x] 先在旧 atlas 上增加独立暗斑与 `29/34px` 边缘对比红测；六枚源格分别出现 `29–156` 个独立暗斑，证明问题来自图符内部高频纹理，不是有意的最终做旧。
- [x] 用官方 ImageGen 按同一六语义顺序生成无暗描边、无颗粒、无刻蚀噪声的干净微型图符网格；FrameArt、五圆心、运行尺寸和玩法语义不变。
- [x] builder 在写入运行 atlas 前 fail closed；sidecar 冻结 `micro_clarity_contract` 和六枚源级 / `29/34px` 指标；strict 独立复算，不信任记录值。
- [x] 新 atlas 六枚源级、`29px` 与 `34px` 独立暗斑均为 `0`，边缘对比 `0.525896–0.635965`，高于冻结下限 `0.18`。
- [x] 刷新 Windows 真窗口 44 张证据并逐张原尺寸复核代表性正反序列；不将线性采样误判为根因，也不改成会产生锯齿的最近邻。
- [x] 用户在本会话检查最终正反序列实机图后回复“可以”；关闭本轮截图级造型、清晰度与屏幕阅读效果签核，继续保留物理显示距离、来源 / 授权与 Gate26H。

## 执行结果

- 历史六枚源图最大 Alpha 质心误差 `0.030608px`，径向填充范围 `78.6045%–80.1331%`，但用户截图证明最远尖端相近不等于视觉大小相近；随后旧图的高频材质又在源级被测得每枚 `29–156` 个独立暗斑。最终干净图集六枚光学半径为 `59.986814–60.050095px`、最大核心半径 `89.514885px`、边界核心像素与源级 / `29/34px` 独立暗斑均为 `0`。
- 首轮内存负测曾把风印右移 `4px`、放大至旧填充率上限，均被历史门槛拒收；Task 6 又以光学半径红测证明旧 atlas 的风 / 雷为 `1.4405x`、反应 / 序列为 `0.7914x`，从而淘汰“最大尖端相近即等大”的错误门槛。Task 7 进一步淘汰高频“材质感”图符；当前运行 atlas SHA256 为 `0a8ffaf0...6c36d3c`。
- 首轮真实窗口捕获暴露了 AtlasTexture 使用全局 UV、圆形 Shader 却按单格 UV 裁切的真实缺陷；修复为逐节点 `region_uv_rect` 后，Task 6 最终刷新为 44 张捕获与 10 组 glyph-only gate，报告 `ok=true`。
- 最终栅格最大质心偏差 `0.757193` 逻辑像素 / `1.061094` 物理像素，最小圆内核心余量 `2.901063px`，越界核心像素总数 `0`；运行语义报告 89 个可见锚点的最大 Alpha 焦点误差 `0.007527` 逻辑像素。
- Seal GUT `11/11` / `215`、formal HUD `13/13` / `463`、Stage12 `11/11` / `406`、Stage21 `7/7` / `81`、Stage26 `7/7` / `95`、递归 GUT `53` scripts / `375/375` / `10972` assertions 均通过。Stage26 与递归 GUT 保留既有 ObjectDB warning；Stage21 保留既有 orphan 输出。
- 最新 Windows 真窗口报告为 `44` captures、`10` glyph-only pixel gates、`ok=true`；新增逐槽最终光学半径和正反两种反应图门禁。用户已对本次最终实机图回复“可以”，截图级审美、清晰度和屏幕阅读效果签核关闭；当前仍仅为 runtime technical candidate，物理显示距离、来源 / 授权与 Gate26H 保持开放，`final_ready=false`。

## Verification Commands

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_seal_resonance_hud.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
python -m py_compile scripts/assets/build_seal_resonance_hud_assets.py scripts/assets/audit_seal_resonance_hud_assets.py
python scripts/assets/build_seal_resonance_hud_assets.py
python scripts/assets/audit_seal_resonance_hud_assets.py --strict
godot --headless --path . --import
godot --path . --script res://scripts/dev/capture_seal_resonance_hud_review.gd
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
python scripts/assets/audit_asset_package.py --strict --write-report
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage21/test_stage_21_element_stance_sequence.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage26/test_stage_26_north_star_alpha_candidate.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check -- <本轮文件>
```

Git 写操作与发布不在本轮授权范围内。
