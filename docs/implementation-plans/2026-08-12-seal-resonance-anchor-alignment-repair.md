# 符印共鸣盘五语义锚点对齐专项修复 Implementation Plan

> **执行方式：** 本轮在现有共享任务分支内 inline execution；保护工作树中的既有改动，不创建额外 worktree，不执行暂存、commit、push、合并或 release。

**Goal:** 把右侧“符印共鸣盘”的五个动态符号精确放入对应美术圆框，并把圆心、包围盒、文字区、连接带和同状态视觉对照升级为会阻止错位回归的正式门槛。

**Architecture:** 保留 v2 idle / active 完整 FrameArt 与现有 `SealResonanceHud` 三态；新增一份美术原生坐标到逻辑坐标的机器可读锚点合同。运行脚本只通过语义锚点居中布局，不再以手写左上角坐标猜位置；GUT 以独立常量复核实际节点几何，真实窗口报告把五锚点误差纳入 `ok`，设计 QA 使用同视口、同状态的参考—实机组合图。

**Tech Stack:** Godot `4.6.3`、GDScript、GUT、CanvasItem Shader、PNG、JSON、Windows PowerShell。

**Status:** 本计划记录第一轮 Control 几何纠偏，已由 `2026-08-12-seal-resonance-icon-keyline-repair.md` 的方案 A 像素合同取代；下列 `72/44/30/30/40` 与 `<=2px` 仅为历史结果，不再是当前正式门槛。用户视觉复核与 Gate26H 保持开放。

## 冻结视觉真值

- 用户当前参考：`assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/user_selected_semantic_anchor_target_sha256_3d25aee0f20cd7a7.png`
- SHA256：`3d25aee0f20cd7a7302962b1444f88ec2620cce19ac4b1b72183e29fc0f6268f`
- 尺寸：`1672x941`
- 本轮只校准 v2 运行框内的五个语义槽位，不重新生成 Battle / Tutorial / Pause，也不改变元素、姿态或序列玩法。

## 五个语义锚点

| 角色 | 语义 | active 美术原生圆心 | active 逻辑圆心 | 运行符号尺寸 |
| --- | --- | ---: | ---: | ---: |
| `element` | 当前元素主印 | `(234, 216)` | `(58.50, 54.00)` | `72x72` |
| `stance` | 当前姿态卫星印 | `(561, 223)` | `(140.25, 55.75)` | `44x44` |
| `sequence_a` | 第一步蓄印 | `(632, 498)` | `(158.00, 124.50)` | `30x30` |
| `sequence_b` | 第二步蓄印 | `(865, 498)` | `(216.25, 124.50)` | `30x30` |
| `reaction` | 两步反应终点 | `(1148, 504)` | `(287.00, 126.00)` | `40x40` |

idle 只启用前两个角色：`element=(64.75, 51.25)`、`stance=(144.75, 53.25)`。所有坐标均相对 FrameArt 左上角；原图到运行尺寸严格按 `0.25` 等比换算。

## 视觉门槛

- 静态圆心误差：每个可见符号 `<= 2.0` 逻辑像素；不得用整体面板安全区替代逐槽验证。
- 包围盒：每个符号 Control 必须完全落入对应金属内圈 `slot_safe_rect`，至少保留 `2px` 视觉余量；首轮 `80/52/36/36/48` 虽已居中但目检仍贴圈，已明确拒收。
- 动效包络：元素换轨最大 `4px`，姿态缩放 / 旋转不得越出本槽；reduced-motion 回到静态圆心。
- 文字安全区：`雷/风`、`疾印/御印`与短暂反应名各有独立矩形，不得与圆框、其他文字或面板透明区相交。
- 灵力链：只能位于序列 A 与 B 的圆框间走廊，不得覆盖任一圆心或侵入第三个反应圆。
- 证据：静态截图至少等待反馈 Tween 结束；报告逐项写出 target / actual / delta / tolerance / inside_slot，并让任一 P1/P2 几何错误使总 `ok=false`。
- 分级：错槽、缺失、裁切为 P0/P1；圆心超差、文字越区、连接带盖住槽位为 P2；几何通过后的颜色、颗粒密度与材质差异才允许记为 P3。

## Task 1：建立会失败的锚点合同回归

**Files:**
- Modify: `tests/demo/test_seal_resonance_hud.gd`
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`

- [x] 用独立测试常量冻结 idle 两锚点与 active 五锚点。
- [x] 断言实际节点圆心、槽位包围盒、三个文字安全区和连接带走廊。
- [x] 在旧实现上运行两组 GUT，确认只因现有错位失败，不得有解析 / UID / 空引用错误。

## Task 2：建立机器可读合同并修正运行布局

**Files:**
- Create: `assets/art/ui/hud_seal_resonance_v2/seal_resonance_anchor_contract.json`
- Modify: `scripts/ui/seal_resonance_hud.gd`
- Modify: `scenes/ui/tutorial_hud.tscn`

- [x] JSON 记录参考图 SHA、两张 FrameArt 尺寸、原生 / 逻辑圆心、槽位与文字区。
- [x] 以 `_place_centered()` 和语义字典替换散落的左上角坐标；`SequenceRoot` 使用面板本地坐标。
- [x] `get_visual_snapshot()` 返回真实五锚点报告，包含静态与当前动效误差。
- [x] 调整连接带至 A/B 间走廊，保持现有 Shader 语义和 reduced-motion。

## Task 3：把视觉门槛接入真实窗口报告

**Files:**
- Modify: `scripts/dev/capture_seal_resonance_hud_review.gd`

- [x] 静态状态等待 Tween 收束后再拍摄。
- [x] 报告记录逐锚点 target / actual / delta、slot、文字区和 connector gate。
- [x] `layout / semantic_state / design_qa` 任一锚点失败时总报告必须失败；feedback 另按动效包络判断。

## Task 4：RED → GREEN 与同状态视觉复核

- [x] 先取得旧实现 RED 证据。
- [x] 实现后运行 Seal 组件与 formal HUD GUT 至全绿。
- [x] 运行真实窗口 capture，生成修复后的 `1672x941 resolved wind -> thunder -> pierce` 全图与 HUD crop。
- [x] 将当前用户参考与新实机截图合成同尺寸对照，并以 `view_image detail=original` 检查；首个居中版本因符号贴圈被拒收，缩小至 `72/44/30/30/40` 后重新捕获。

## Task 5：回归、事实源与交付边界

- [x] 运行 Godot import、Stage12 / Stage21 / Stage26、strict 资产 / runtime UI binding 和递归 GUT。
- [x] 更新 `design-qa.md`、`docs/progress/status.md` 与 `docs/progress/logs/2026-08-12.md`，撤销旧“无 P1/P2”的错误结论并记录新鲜证据。
- [x] 展示修复前后聚焦 crop 与实机全图；机器几何通过不替代用户审美、物理阅读距离、授权或 Gate26H。

## 执行结果

- 旧实现 RED：Seal 组件 `3/5`、formal HUD `12/13`，失败只指向缺失锚点合同与错位几何，没有解析、UID 或空引用错误。
- 最终 GREEN：Seal 组件 `5/5`、`76` assertions；formal HUD `13/13`、`407` assertions。
- 真窗口：`34` 张 capture，全部接入逐槽 gate；最大静态圆心误差 `0px`，反馈期间最大实际圆心误差 `3.898438px`，在元素 `4.01px` 动效包络内；锚点、文字区和连接带失败数均为 `0`。
- 回归：Stage12 `11/11` / `406`、Stage21 `7/7` / `81`、Stage26 `7/7` / `95`；递归 GUT `53` scripts / `369/369` / `10777` assertions；strict HUD 资产、asset package、runtime UI binding 均为 exit `0`。
- 视觉边界：符号落槽、内圈留白和连接带位置已修；参考图的开放式紫雷器械轮廓与当前 v2 的闭合 L 形青铜 / 青色框体仍有明显差异，因此最终视觉状态保持 `blocked`，等待用户决定是否另开 FrameArt 重生轮次。

## Verification Commands

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_seal_resonance_hud.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
godot --path . --script res://scripts/dev/capture_seal_resonance_hud_review.gd
python scripts/assets/audit_seal_resonance_hud_assets.py --strict
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check -- <本轮文件>
```

Git 提交、push、合并与发布需要用户另行授权，本计划不自动执行。
