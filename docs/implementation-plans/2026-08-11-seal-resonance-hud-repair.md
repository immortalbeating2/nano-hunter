# 符印共鸣盘 HUD 专项修复 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把右侧 `ElementPanel` 从常驻按键 / 调试文字框重构为与 Luna、封妖世界和 `02 镇妖官印` 一致的“符印共鸣盘”，并把姿态、元素按键教学迁回正确的教程与控制说明入口。

**Architecture:** 保留生产节点名 `ElementPanel`，但给它挂载独立 `SealResonanceHud` 组件；组件只消费 Player 的公开 HUD 快照，将其翻译为 `idle / primed / resolved` 三态、两张完整等比 FrameArt、六枚 Image Gen 符印和一条 Shader 灵力链。`TutorialHUD` 继续负责房间提示与输入设备路由，教程房负责 `E` 姿态步骤，风印由 HUD 观察既有 `wind_seal_unlocked` 转换后显示一次性 `Q / LB` 上下文提示；不改元素、姿态、攻击或序列玩法规则。

**Tech Stack:** Godot `4.6.3`、GDScript、GUT、CanvasItem Shader、OpenAI 内置 Image Gen、Python `3` / Pillow、PNG Alpha、AtlasTexture、StyleBoxEmpty、Windows PowerShell。

**Status:** 用户已批准设计；本清单是非 Stage 专项修复计划，已形成 runtime technical candidate，待真人视觉、物理阅读距离、动效强度、来源/授权与 Gate26H 签核；未 commit/push/release。

## 2026-08-11 v2 纠偏补充（当前事实源）

- 用户在查看 v1 实机后明确否决其缩图可读性，并选择重新生成的 `02 镇妖官印`第 2 版设计。下方 Tasks 1–7 保留 v1 首轮实施与审计历史；其中所有 `hud_seal_resonance_v1`、`ai01`、旧逻辑尺寸和旧截图数量均不再代表当前生产目标，当前绑定以本节、设计文档和资产清单的 v2 记录为准。
- 设计锚点冻结为 `assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/selected_option_02_command_seal_sha256_941695354052e8fd.png`，同状态 gameplay 锚点为 `assets/source/ai_generated/batch_10/hud_seal_resonance_v2/references/gameplay_resolved_wind_thunder_sha256_66ec712ad638641f.png`。两者都由 strict 审计锁定 path、SHA256、尺寸与字节数。
- 当前正式输出为 `assets/art/ui/hud_seal_resonance_v2/` 下的 `928x464` idle 整框、`1296x624` active 整框与 `768x512` 六符印图集；六份 `256x256` AtlasTexture 位于 `assets/art/editor_resources/seal_resonance_symbols_warden_ai02/`。运行逻辑尺寸为 `232x116 / 324x156`，不再沿用 v1 的横向矮条比例。
- active 第一稿因上下盘体视觉断裂被设计 QA 拒收；最终稿通过贯穿上下层的连续铜铰 / 青铜脊梁形成单一器物。Python 仍只负责官方色键去除、Alpha 清理、等比缩小和固定 atlas 排版，没有程序化绘制正式美术。
- 同状态实机证据为 `tests/artifacts/local/seal-resonance-hud/design-qa/selected_option_02_resolved_1672x941.png`，设计稿—实机并排证据为 `tests/artifacts/local/seal-resonance-hud-v2/design-qa/option02_vs_runtime_resolved_1672x941.png`。机器层已通过 builder hash 稳定性、strict 资产 / package / runtime binding、定向与递归 GUT；用户视觉、真实物理阅读距离、动效、来源 / 授权和 Gate26H 仍保持开放。

## Global Constraints

- 视觉方向固定为用户批准的 `02 镇妖官印`：外层黑漆木 / 旧铜官印表达镇妖卫身份，内部佛门印轮 / 灵力链表达修行来源；常态不得加入妖性裂纹、失控异色或普通法师技能栏语言。
- 常驻 HUD 不得出现 `Q 元素 / E 姿态`、`序列：—`、固定秒数、教程句子、技能槽、法力或第三元素。
- `idle` 逻辑尺寸为 `232x116`，`primed / resolved` 为 `324x156`；运行 PNG 分别为 `928x464` 与 `1296x624`。两张 FrameArt 必须整张等比显示，禁止 NinePatch 拉伸或独立 `OrnamentLayer` 叠件。
- 六枚符号固定为 `wind / thunder / swift / ward / wind_thunder_pierce / thunder_wind_scatter`；必须依靠轮廓、方向、颜色和动效共同区分，不能只换色或只换汉字。
- 灵力链只读取现有 `window_remaining / window_duration`；不得新增玩法计时器。反应名短暂显示使用 UI 展示计时，不回写 Player。
- `E` 姿态步骤位于基础攻击之后、离开教程房之前；风印解锁前不得提示元素切换，首次解锁后才显示一次实际 `InputMap` 绑定提示。
- reduced-motion 开启后停止位移、旋转和持续 Shader 流动，只保留瞬时换图、颜色与透明度反馈。本轮不新增数字倒计时设置。
- 正式运行 PNG 必须由 Image Gen 产生并记录来源；Python 只允许去色键、Alpha 清理、裁切、一次等比缩小、透明居中和固定 atlas 排版，不得程序化绘制正式 HUD 美术。
- 自动测试、截图和审计只形成技术候选；最终审美、物理阅读距离、动画强度、来源条款、授权和 Gate26H 继续由真人签核。
- 工作树已有大量用户改动。本轮只碰计划列出的文件，不清理、暂存、commit、push、合并或发布；若用户后续明确授权提交，再对任务自有文件做一次选择性双语提交。

## File Map

### 新建运行组件与资源

- `scripts/ui/seal_resonance_hud.gd`：右侧 HUD 三态、快照翻译、符号绑定、UI 动效与 reduced-motion。
- `scripts/ui/input_binding_formatter.gd`：从真实 `InputMap` 生成键盘 / 手柄短标签，供 TutorialHUD 与 DemoShell 共用。
- `assets/shaders/ui/seal_resonance_link.gdshader`：第一步衰减链、贯穿线势与散射线势；脚本只写参数。
- `assets/art/ui/hud_seal_resonance_v2/`：两张完整框体、一个六符号 atlas 及三份 `.source.json`。
- `assets/art/editor_resources/seal_resonance_symbols_warden_ai02/`：六份固定 `256x256` AtlasTexture。
- `assets/art/ui/styleboxes/hud_seal_resonance_v2/`：idle / active 两份无纹理内容安全区 StyleBoxEmpty。
- `scripts/assets/build_seal_resonance_hud_assets.py`：把经官方工具去色键的三张候选裁切、等比缩小并输出固定尺寸运行图。
- `scripts/assets/audit_seal_resonance_hud_assets.py`：检查尺寸、比例、Alpha 四角、六格可见像素、来源散列和禁止的旧绑定。
- `tests/demo/test_seal_resonance_hud.gd`：独立组件三态、衰减、反应、切换反馈与 reduced-motion。
- `tests/demo/test_input_binding_formatter.gd`：真实 InputMap 键鼠 / 手柄标签与临时重绑定回归。
- `scripts/dev/capture_seal_resonance_hud_review.gd`：七档视口、三态、两种反应、切换双帧、reduced-motion 与风印提示证据。

### 修改既有运行入口

- `scenes/ui/tutorial_hud.tscn`：用完整双框、动态符号节点和 Shader 链替换 `ElementStatusLabel`。
- `scripts/ui/tutorial_hud.gd`：委托 SealResonanceHud、维护风印一次性提示、使用真实 InputMap 文案。
- `scripts/rooms/tutorial_room.gd`：增加攻击后的姿态切换步骤，姿态完成后才打开出口。
- `assets/configs/rooms/tutorial_room_flow.tres`：把教程标题 / 文案从 `4` 步调整为 `5` 步并加入 `stance`。
- `scripts/ui/demo_shell.gd`：Controls / Settings 动态展示真实元素与姿态绑定。
- `scripts/dev/mcp_player_input_replay_probe.gd`：自然路线遇到 `stance` 步骤时发送 `stance_switch`。
- `tests/stage11/support/stage11_graybox_mainline_driver.gd`：灰盒流程在攻击后完成一次姿态切换。
- `scripts/dev/capture_full_content_flow_evidence.gd`：教程准备过程完成姿态步骤后再保存状态。

### 修改回归、资产治理与事实来源

- `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`
- `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`
- `tests/stage21/test_stage_21_element_stance_sequence.gd`
- `tests/stage26/test_stage_26_north_star_alpha_candidate.gd`
- `tests/demo/test_tutorial_hud_formal_layout.gd`
- `scripts/dev/audit_runtime_ui_skin_binding.gd`
- `docs/assets/asset-manifest.md`
- `docs/assets/asset-package-audit-report.json`：严格资产包审计的派生报告；不扩写角色 / 地形 prompt queue 或 final-art 清单。
- `spec-design/2026-08-10-seal-resonance-hud-redesign.md`
- `docs/progress/status.md`
- `docs/progress/logs/2026-08-11.md`

---

### Task 1: 冻结右侧 HUD、输入绑定和教程顺序的失败契约

**Files:**
- Create: `tests/demo/test_seal_resonance_hud.gd`
- Create: `tests/demo/test_input_binding_formatter.gd`
- Modify: `tests/stage21/test_stage_21_element_stance_sequence.gd`
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`
- Modify: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- Modify: `tests/stage26/test_stage_26_north_star_alpha_candidate.gd`
- Modify: `docs/assets/asset-manifest.md`

**Interfaces:**
- Consumes: `Player.get_hud_status_snapshot() -> Dictionary`，其中使用 `wind_seal_unlocked`、`current_element_id/label`、`current_stance_id/label`、`element_sequence.element_ids/window_remaining/window_duration/reaction_id/reaction_label`。
- Produces: `SealResonanceHud.apply_snapshot(snapshot: Dictionary) -> void`、`get_visual_snapshot() -> Dictionary`、`InputBindingFormatter.action_label(action: StringName, device: String) -> String` 的红测契约。

- [x] **Step 1: 为独立组件写三态与禁文案红测**

在 `test_seal_resonance_hud.gd` 实例化 `tutorial_hud.tscn` 中的 `ElementPanel`，并冻结以下断言：

```gdscript
var panel := hud.get_node("ElementPanel")
panel.call("apply_snapshot", {
    "current_element_id": &"thunder",
    "current_element_label": "雷",
    "current_stance_id": &"swift",
    "current_stance_label": "疾印",
    "element_sequence": {
        "element_ids": [],
        "window_remaining": 0.0,
        "window_duration": 2.0,
        "reaction_id": StringName(),
        "reaction_label": "",
    },
})
var snapshot: Dictionary = panel.call("get_visual_snapshot")
assert_eq(snapshot.get("state"), &"idle")
assert_eq(snapshot.get("size"), Vector2(248.0, 92.0))
assert_eq(snapshot.get("element_id"), &"thunder")
assert_eq(snapshot.get("stance_id"), &"swift")
assert_false(str(snapshot.get("visible_text", "")).contains("Q"))
assert_false(str(snapshot.get("visible_text", "")).contains("E"))
assert_false(str(snapshot.get("visible_text", "")).contains("序列："))
```

再分别输入一枚 `wind` 与两枚 `wind, thunder`，要求状态为 `primed / resolved`、面板尺寸为 `320x126.5`、窗口比值被 clamp 到 `0..1`、反应 ID 为 `wind_thunder_pierce`。输入 `thunder, wind` 时必须得到 `thunder_wind_scatter`，不能只换反应文字。

- [x] **Step 2: 为 reduced-motion 与两种切换反馈写红测**

```gdscript
panel.call("set_reduced_motion_enabled", true)
panel.call("apply_snapshot", _snapshot(&"wind", &"ward", [&"wind"], 1.0, 2.0))
var reduced: Dictionary = panel.call("get_visual_snapshot")
assert_true(reduced.get("reduced_motion", false))
assert_eq(float(reduced.get("link_motion_amount", -1.0)), 0.0)
assert_eq(reduced.get("last_switch_feedback"), &"element")
```

随后只改变姿态，要求 `last_switch_feedback == &"stance"`。测试不依赖 Tween 中间像素，只锁定两条反馈路径不能共用同一个语义 ID。

- [x] **Step 3: 为 InputMap 格式器写真实映射和临时重绑定红测**

```gdscript
assert_eq(InputBindingFormatter.action_label(&"element_switch", "keyboard"), "Q")
assert_eq(InputBindingFormatter.action_label(&"stance_switch", "keyboard"), "E")
assert_eq(InputBindingFormatter.action_label(&"element_switch", "controller"), "LB / L1")
assert_eq(InputBindingFormatter.action_label(&"stance_switch", "controller"), "RB / R1")
```

保存 `stance_switch` 的事件数组，临时替换为 `KEY_R`，断言返回 `R`，并在 `after_each()` 无条件恢复原数组。未知 action 固定返回 `未绑定`，不得偷偷回落到 `Q/E`。

- [x] **Step 4: 把现有 HUD 与教程断言改成新职责**

- Stage21 删除 `ElementStatusLabel`、`%.1fs`、`Q/E` 断言，改查 `ElementPanel.get_visual_snapshot()`、两种反应 glyph 资源路径和 Shader `window_ratio`。
- HUD layout 删除“三行文字”断言，改为 idle / active 两套尺寸、两张完整 FrameArt、六个 AtlasTexture、所有动态内容位于当前 StyleBox 安全区。
- Stage5 把顺序冻结为 `move_jump -> dash -> attack -> stance -> exit -> complete`；攻击后必须 `exit_unlocked=false`，收到一次 `stance_changed` 后才为 `true`。
- Stage26 Controls / Settings 断言继续包含默认 `Q/E/LB/RB`，并增加临时重绑定后文案随 InputMap 改变的断言。

- [x] **Step 5: 先登记三项 planned 资产**

在 `asset-manifest.md` 新增 `NH-HUD-Seal-Resonance-v1`，列出两张框体、一个符号 atlas、六个 AtlasTexture、`runtime_binding_allowed=false`、`final_ready=false` 和 Gate26H / 授权边界；在资产真正通过 Task 2 审计前不得改成可绑定。

- [x] **Step 6: 运行红测并保存预期失败原因**

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_seal_resonance_hud.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_input_binding_formatter.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage21/test_stage_21_element_stance_sequence.gd -gexit
```

Expected: FAIL 只来自缺少 `SealResonanceHud` / `InputBindingFormatter`、旧教程直接开门和旧 `ElementStatusLabel` 结构；若出现解析错误、资源 UID 错误或无关测试失败，先修正测试本身。

---

### Task 2: 用官方 Image Gen 生成并治理三张正式 HUD 美术源

**Files:**
- Create: `assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_idle_frame_warden_ai01_source.png`
- Create: `assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_active_frame_warden_ai01_source.png`
- Create: `assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_symbols_warden_ai01_source.png`
- Create: `scripts/assets/build_seal_resonance_hud_assets.py`
- Create: `scripts/assets/audit_seal_resonance_hud_assets.py`
- Create: `assets/art/ui/hud_seal_resonance_v1/seal_resonance_idle_frame_warden_ai01.png`
- Create: `assets/art/ui/hud_seal_resonance_v1/seal_resonance_active_frame_warden_ai01.png`
- Create: `assets/art/ui/hud_seal_resonance_v1/seal_resonance_symbols_warden_ai01.png`
- Create: adjacent `.source.json` for all three runtime PNGs
- Create: six `.atlas_texture.tres` files under `assets/art/editor_resources/seal_resonance_symbols_warden_ai01/`

**Interfaces:**
- Consumes: `assets/art/ui/hud_warden_integrated_v5/element_frame_integrated_warden_ai01.png`、其 batch_08 source、`assets/source/ai_generated/batch_09/hud_seal_resonance_v1/references/gameplay_hud_formal_2048x1152_sha256_57557ef621d8e0a1.png` 和批准设计稿。
- Produces: idle `1080x400`、active `1012x400`、symbols `576x384` RGBA 运行图；symbols 固定 `3x2`、每格 `192x192`。

- [x] **Step 1: 执行前读取生图路由并确认官方渠道**

完整读取 `imagegen` 技能；只读取 `~/.codex/config.toml` 的模型提供者 / base URL 字段，不输出密钥。当前预期 `model_provider="openai"`，因此使用内置 `image_gen`；若执行时已变成第三方渠道，严格按仓库 AGENTS 路由切换到 `image-api-edits`，不得把第三方密钥发送给 OpenAI 主机。

- [x] **Step 2: 分别生成恰好三张唯一候选**

Idle frame 提示词冻结为：单一正交正视 HUD、完整外轮廓、`02 镇妖官印` 黑漆木与旧铜、左侧官印座和右侧朱砂印属于框体结构、中央有两个清晰方形印槽、内部佛门同心细纹；允许与边框有明确金属挂点的一体化短链、官牌或垂饰，但它们必须留在整体轮廓内，禁止漂浮独立贴片；无文字 / 图标 / 第二框体、纯绿色键背景、可见结构约 `2.70:1`。

Active frame 提示词冻结为：与 idle 同一套材质和身份、完整单框、横向展开为两枚序列印槽与一条内嵌灵力轨道、贯穿 / 散射反馈区留白；允许与结构相连的一体化短链、官牌或垂饰，禁止无挂点的独立悬浮装饰；无文字 / 图标 / 第二框体、纯绿色键背景、可见结构约 `2.53:1`。

Symbols 提示词冻结为：同一画师 / 同一线宽的 `3x2` 接触表，顺序严格为第一行 `风、雷、疾印`，第二行 `御印、追击贯穿、散射破势`；每格只有一个无文字符印、相同视觉重量、无框、无阴影底板、纯绿色键背景。风为羽状外旋，雷为分叉震纹，疾印为前冲开式，御印为同心闭式，贯穿为水平穿刺，散射为外张放射。

三次调用都引用现有 v5 Element 框和 `2048x1152` gameplay 截图；保存到上述三个唯一 source 路径。

- [x] **Step 3: 使用 `view_image detail=original` 逐张拒收不合格候选**

拒绝条件：伪文字、两个框体、裁边、比例明显错误、官印 / 朱砂印悬浮、NinePatch 式重复边、符号格位错序、六符号人物化、颜色只换色不换轮廓、绿色侵入主体。若一张失败，只重试该唯一文件，不接受四版候选混放生产目录。

- [x] **Step 4: 官方去色键后运行一次性构建脚本**

```powershell
python "$env:USERPROFILE\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py" --input assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_idle_frame_warden_ai01_source.png --out tests/artifacts/local/seal-resonance-hud/alpha/idle.png --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
python "$env:USERPROFILE\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py" --input assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_active_frame_warden_ai01_source.png --out tests/artifacts/local/seal-resonance-hud/alpha/active.png --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
python "$env:USERPROFILE\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py" --input assets/source/ai_generated/batch_09/hud_seal_resonance_v1/seal_resonance_symbols_warden_ai01_source.png --out tests/artifacts/local/seal-resonance-hud/alpha/symbols.png --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
python scripts/assets/build_seal_resonance_hud_assets.py
```

构建脚本只允许：按 Alpha bbox 裁两张框、等比缩小后透明居中；符号源按 `3x2` 等格裁切、每格 Alpha bbox 等比居中到 `192x192`，最后合成 `576x384`。六份 AtlasTexture region 固定为 `(0,0)`、`(192,0)`、`(384,0)`、`(0,192)`、`(192,192)`、`(384,192)`。

- [x] **Step 5: 写三份来源记录并运行资产审计**

每份 `.source.json` 必须包含 `provider`、完整 prompt、candidate/output path、candidate/output SHA256、source/output size、允许的 process、`visual_assembly_contract="seal_resonance_v1_complete_frame"`、`runtime_binding_allowed=true`、`final_ready=false` 与人工边界。

```powershell
python -m py_compile scripts/assets/build_seal_resonance_hud_assets.py scripts/assets/audit_seal_resonance_hud_assets.py
python scripts/assets/audit_seal_resonance_hud_assets.py --strict
```

Expected: 三图尺寸和比例准确；四角 Alpha 为 `0`；六格均有非零可见像素且不能跨格；候选 / 输出 SHA256 匹配；旧 `element_frame_integrated_warden_ai01` 暂时仍可存在但后续不得被 `ElementPanel` 消费。

---

### Task 3: 实现独立 SealResonanceHud 三态组件并接入场景

**Files:**
- Create: `scripts/ui/seal_resonance_hud.gd`
- Create: `assets/shaders/ui/seal_resonance_link.gdshader`
- Create: `assets/art/ui/styleboxes/hud_seal_resonance_v1/seal_resonance_idle_content_safe.stylebox_empty.tres`
- Create: `assets/art/ui/styleboxes/hud_seal_resonance_v1/seal_resonance_active_content_safe.stylebox_empty.tres`
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/tutorial_hud.gd`
- Modify: `tests/demo/test_seal_resonance_hud.gd`
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`
- Modify: `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`
- Modify: `tests/stage21/test_stage_21_element_stance_sequence.gd`

**Interfaces:**
- Consumes: Task 2 runtime PNG / AtlasTexture 与 Player HUD snapshot。
- Produces: `apply_snapshot(snapshot: Dictionary) -> void`、`set_reduced_motion_enabled(enabled: bool) -> void`、`get_display_state() -> StringName`、`get_visual_snapshot() -> Dictionary`、`layout_changed` signal。

- [x] **Step 1: 建立组件公开契约和状态解析**

```gdscript
extends Panel
class_name SealResonanceHud

signal layout_changed

const STATE_IDLE := &"idle"
const STATE_PRIMED := &"primed"
const STATE_RESOLVED := &"resolved"
const IDLE_SIZE := Vector2(248.0, 92.0)
const ACTIVE_SIZE := Vector2(320.0, 126.5)
const REACTION_LABEL_DURATION := 0.85

func apply_snapshot(snapshot: Dictionary) -> void:
    var sequence: Dictionary = snapshot.get("element_sequence", {})
    var element_ids: Array = sequence.get("element_ids", [])
    var next_state := STATE_IDLE
    if element_ids.size() == 1:
        next_state = STATE_PRIMED
    elif element_ids.size() >= 2:
        next_state = STATE_RESOLVED
    _apply_state(next_state)
    _apply_identity(snapshot)
    _apply_sequence(sequence)
```

所有未知元素回落 `thunder`、未知姿态回落 `swift`；多于两枚只读最后两枚；`window_ratio = clamp(window_remaining / max(window_duration, 0.001), 0, 1)`。

- [x] **Step 2: 把 ElementPanel 改为完整双框与固定动态节点**

场景节点结构固定为：

```text
ElementPanel (Panel + SealResonanceHud)
├─ FrameArt
├─ FrameArtActive
└─ ContentRoot
   ├─ ElementGlyph
   ├─ ElementLabel
   ├─ StanceGlyph
   ├─ StanceLabel
   └─ SequenceRoot
      ├─ SequenceSlotA
      ├─ SequenceLink
      ├─ SequenceSlotB
      ├─ ReactionGlyph
      └─ ReactionLabel
```

删除 `ElementStatusLabel`。`FrameArt` / `FrameArtActive` 都用 `STRETCH_KEEP_ASPECT_CENTERED`，只二选一显示；`ContentRoot` 永远在 FrameArt 之上且严格位于当前 StyleBox 安全区。ElementPanel metadata 写入：

```text
metadata/hud_role = "seal_resonance"
metadata/asset_id_idle = "seal_resonance_idle_frame_warden_ai01"
metadata/asset_id_active = "seal_resonance_active_frame_warden_ai01"
metadata/visual_assembly_contract = "seal_resonance_v1_complete_frame"
```

两份 StyleBoxEmpty 的 content margins 冻结为 idle `48/18/22/16px`、active `64/18/28/16px`；元素 / 姿态辅助标签使用 `18px`，反应名使用 `16px`。idle 安全区按左右两组 `36px glyph + 42px label` 排布；active 上行使用 `28px` 元素 / 姿态 glyph，下行使用 `34px` 双序列槽、`62px` 灵力链、`30px` 反应 glyph 与剩余反应文字区。任何节点超出安全区都由测试直接失败，不靠缩小字体兜底。

- [x] **Step 3: 实现 Shader 灵力链与两种反应线势**

Shader uniforms 固定为：

```glsl
uniform float window_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float motion_amount : hint_range(0.0, 1.0) = 1.0;
uniform float reaction_mode : hint_range(0.0, 2.0) = 0.0;
uniform vec4 wind_tint : source_color = vec4(0.24, 0.88, 0.78, 1.0);
uniform vec4 thunder_tint : source_color = vec4(0.48, 0.58, 1.0, 1.0);
```

`reaction_mode=0` 为单链衰减，`1` 为水平贯穿扫光，`2` 为从中心向外的散射；Alpha 必须乘 `step(UV.x, window_ratio)` 或等价平滑边缘，使窗口衰减真实可见。reduced-motion 时 `motion_amount=0`，Shader 不再依赖 `TIME` 产生像素变化。

- [x] **Step 4: 实现两条不同的 switch_feedback**

- 元素变化：`ElementGlyph` 做 `0.22s` 横向流光 / 透明度换轨，不旋转整个面板。
- 姿态变化：`StanceGlyph` 做 `0.24s` 开式 / 闭式缩放与轻微旋转，不复用元素 Tween。
- reduced-motion：两者只瞬时换纹理并闪一次颜色；`get_visual_snapshot().last_switch_feedback` 仍分别返回 `element / stance`。
- 反应名只在新 reaction ID 出现后显示 `0.85s`；符号与线势继续跟随玩法窗口，不用 UI 计时器清空 Player 序列。
- idle 不播放常驻呼吸、旋转或流动；只有实际元素 / 姿态变化时才启动一次性反馈。

- [x] **Step 5: 让 TutorialHUD 只委托组件并响应布局变化**

把 `_update_element_status()` 改为：

```gdscript
func _update_element_status() -> void:
    if element_panel == null or not element_panel.has_method("apply_snapshot"):
        return
    element_panel.call("apply_snapshot", _get_player_hud_status())
```

删除旧三行文本拼接。`layout_changed` 只触发 `_layout_runtime_hud_for_viewport(_layout_viewport_size)`；不要在每帧无变化时重排。`set_reduced_motion_enabled()` 同步调用 ElementPanel，同一个项目设置同时约束教程强调层和符印共鸣盘。

- [x] **Step 6: 运行组件、HUD、Stage12 与 Stage21 定向测试**

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_seal_resonance_hud.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage21/test_stage_21_element_stance_sequence.gd -gexit
```

Expected: 0 failed；idle / active 尺寸、FrameArt、符号、Shader ratio、reaction glyph、禁用旧文案和内容安全区全部绿灯。

---

### Task 4: 把 E 姿态切换加入初始教程，并使用真实 InputMap 文案

**Files:**
- Create: `scripts/ui/input_binding_formatter.gd`
- Modify: `scripts/rooms/tutorial_room.gd`
- Modify: `assets/configs/rooms/tutorial_room_flow.tres`
- Modify: `scripts/ui/tutorial_hud.gd`
- Modify: `scripts/dev/mcp_player_input_replay_probe.gd`
- Modify: `tests/stage11/support/stage11_graybox_mainline_driver.gd`
- Modify: `scripts/dev/capture_full_content_flow_evidence.gd`
- Modify: `tests/demo/test_input_binding_formatter.gd`
- Modify: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- Modify: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

**Interfaces:**
- Consumes: `Player.stance_changed(stance_id: StringName)`、`InputMap.action_get_events()`、既有 `tutorial_step_changed` / `get_hud_context()`。
- Produces: `STEP_STANCE=&"stance"`、五步教程、实际绑定提示；出口仍只由教程房控制。

- [x] **Step 1: 实现共享 InputBindingFormatter**

```gdscript
extends RefCounted
class_name InputBindingFormatter

const DEVICE_KEYBOARD := "keyboard"
const DEVICE_CONTROLLER := "controller"

static func action_label(action: StringName, device: String) -> String:
    for event: InputEvent in InputMap.action_get_events(action):
        if device == DEVICE_KEYBOARD and event is InputEventKey:
            var key := (event as InputEventKey).physical_keycode
            if key == 0:
                key = (event as InputEventKey).keycode
            return OS.get_keycode_string(key)
        if device == DEVICE_CONTROLLER and event is InputEventJoypadButton:
            return _joy_button_label((event as InputEventJoypadButton).button_index)
    return "未绑定"
```

手柄映射至少覆盖 `A / Cross`、`B / Circle`、`X / Square`、`Y / Triangle`、`LB / L1`、`RB / R1`、`Menu`；未知按钮返回 `按钮 <index>`，不伪造默认键。

- [x] **Step 2: 把教程房扩为五步并安全连接姿态信号**

新增 `STEP_STANCE`，标题顺序固定为：

```text
教程 1/5 · 移动与跳跃
教程 2/5 · 冲刺穿门
教程 3/5 · 基础攻击
教程 4/5 · 疾御换印
教程 5/5 · 离开教程区
```

攻击训练目标或出口柱后调用 `_set_current_step(STEP_STANCE)`，保持出口锁定。`bind_player()` 必须先断开旧玩家 `stance_changed`，再连接新玩家；只有 `_current_step == STEP_STANCE` 时，收到实际变化才调用 `_unlock_exit_after_stance_switch()`、打开出口并进入 `STEP_EXIT`。Main 注入初始姿态不得跳过步骤，因为绑定发生在攻击步骤之前。

- [x] **Step 3: 用真实绑定生成 stance PromptPanel 文案**

`TutorialHUD._format_prompt_text()` 对 `&"stance"` 返回：

```gdscript
var key := InputBindingFormatter.action_label(&"stance_switch", _input_mode)
return "姿态：%s。切换一次疾印 / 御印，观察攻守差异。" % key
```

把 `stance` 加入 `TUTORIAL_STEP_IDS`，继续复用唯一 `TutorialAttention`，不得生成第二条强调框。

- [x] **Step 4: 更新所有自动路线的 stance 动作**

- `stage11_graybox_mainline_driver` 在攻击后调用生产 `player.cycle_current_stance()`，确认步骤进入 `exit` 再移动。
- `mcp_player_input_replay_probe` 的 `_tap_active` 和 `_release_all()` 加入 `stance_switch`；`stance` 分支只发送该 action，释放 attack / dash。
- `capture_full_content_flow_evidence` 在攻击后调用一次 `cycle_current_stance()`，使截图与后续步骤不滞留在姿态教学。

- [x] **Step 5: 运行输入格式器、Stage5、Stage8 与 Stage11 回归**

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_input_binding_formatter.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/stage11 -ginclude_subdirs -gexit
godot --headless --path . --script res://scripts/dev/run_stage17_input_smoke.gd
```

Expected: 攻击后出口仍锁；键盘 `E` 与 synthetic Joypad `RB` 都能完成姿态步骤；既有教程阈值、dash 门与切房契约不变。

---

### Task 5: 在风印首次解锁时显示一次 Q / LB 上下文教学，并同步 Controls / Settings

**Files:**
- Modify: `scripts/ui/tutorial_hud.gd`
- Modify: `scripts/ui/demo_shell.gd`
- Modify: `tests/stage21/test_stage_21_element_stance_sequence.gd`
- Modify: `tests/stage26/test_stage_26_north_star_alpha_candidate.gd`
- Modify: `tests/demo/test_tutorial_hud_formal_layout.gd`

**Interfaces:**
- Consumes: 玩家 HUD snapshot 的 `wind_seal_unlocked/current_element_id`、Task 4 的 `InputBindingFormatter`、既有 PromptPanel / TutorialAttention。
- Produces: `get_contextual_tutorial_snapshot() -> Dictionary`；风印提示只在 `false -> true` 转换后激活，玩家完成一次真实元素变化后结束。

- [x] **Step 1: 增加仅属于 HUD 展示期的风印提示状态**

```gdscript
var _wind_unlock_seen := false
var _wind_switch_prompt_active := false
var _wind_switch_start_element := &""
var _room_context_cache: Dictionary = {}

func _sync_wind_switch_tutorial(player_status: Dictionary) -> void:
    var unlocked := bool(player_status.get("wind_seal_unlocked", false))
    var element_id := StringName(str(player_status.get("current_element_id", "thunder")))
    if not unlocked:
        _wind_unlock_seen = false
        _wind_switch_prompt_active = false
        return
    if not _wind_unlock_seen:
        _wind_unlock_seen = true
        _wind_switch_prompt_active = true
        _wind_switch_start_element = element_id
        _apply_wind_switch_prompt()
    elif _wind_switch_prompt_active and element_id != _wind_switch_start_element:
        _wind_switch_prompt_active = false
        _apply_room_context(_room_context_cache)
```

首次绑定已经解锁的存档只设置 `_wind_unlock_seen=true`，不弹补课提示；只有同一绑定生命周期观察到 `false -> true` 才激活。新游戏重新绑定锁定状态时允许状态归零。

- [x] **Step 2: 让 PromptPanel 覆盖和恢复都走单一入口**

`_apply_room_context()` 先缓存房间上下文；风印提示激活时不让房间 signal 覆盖。标题固定为 `风印已解 · 元素切换`，正文为：

```gdscript
var binding := InputBindingFormatter.action_label(&"element_switch", _input_mode)
prompt_label.text = "元素：%s。在风印与雷印之间切换一次。" % binding
```

输入设备变化时只重算同一条提示。attention step 使用新增 `&"wind_switch"`；提示结束后恢复当前房间标题 / 正文与 attention，不保留空框。

- [x] **Step 3: Controls 和 Settings 都从 InputMap 构造元素 / 姿态行**

把 Settings 按钮从静态 `.bind(...)` 改连 `_on_settings_pressed()`。Controls 保留全控制表，但各 action 都调用 formatter；Settings 至少显示：

```text
元素切换：Q · LB / L1
姿态切换：E · RB / R1
降低动态效果：读取 accessibility/reduced_motion
```

临时把 `element_switch` 改成 `R` 后再次打开两个页面，都必须出现 `R` 且不再出现硬编码 `Q`。

- [x] **Step 4: 写清风印前、解锁时、完成后的回归**

Stage21 断言：

1. 风印未解锁：`get_contextual_tutorial_snapshot().active == false`，常驻共鸣盘也没有 Q。
2. 调用生产 `main.unlock_wind_seal()`：PromptPanel 显示实际键盘 / 手柄绑定，snapshot step 为 `wind_switch`。
3. 调用生产 `player.cycle_current_element()`：提示关闭并恢复房间上下文。
4. 换房后绑定已解锁玩家：提示不重复。

- [x] **Step 5: 运行 HUD、Stage21、Stage26 回归**

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_tutorial_hud_formal_layout.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage21/test_stage_21_element_stance_sequence.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage26/test_stage_26_north_star_alpha_candidate.gd -gexit
```

Expected: 0 failed；常驻 HUD 没有按键，两个按键只在正确入口出现，且真实重绑定可见。

---

### Task 6: 更新运行绑定审计、轻量资产治理和真实窗口证据

**Files:**
- Modify: `scripts/dev/audit_runtime_ui_skin_binding.gd`
- Create: `scripts/dev/capture_seal_resonance_hud_review.gd`
- Modify: `scripts/dev/capture_tutorial_hud_formal_review.gd`
- Modify: `docs/assets/asset-manifest.md`
- Modify/generated: `docs/assets/asset-package-audit-report.json`
- Create/refresh ignored evidence: `tests/artifacts/local/seal-resonance-hud/`

**Interfaces:**
- Consumes: Tasks 2–5 production bindings。
- Produces: 可重复的 Alpha / runtime binding / 七档布局 / 状态双帧报告，并保持 `final_ready=false`；不无故扩大现有 `80` 项 prompt queue 或角色 / 地形 final-art 清单。

- [x] **Step 1: 更新 runtime UI binding 反向审计**

审计必须确认：

- `ElementPanel` 有 `hud_role=seal_resonance`。
- idle / active 两张纹理路径正确且均为 `STRETCH_KEEP_ASPECT_CENTERED`。
- 六个 AtlasTexture region 与符号 atlas 一致。
- `ElementStatusLabel`、`OrnamentLayer`、旧 v5 Element texture 的生产引用为 `0`。
- Battle / Tutorial 继续使用既有 v5，一律不被本轮误改；Pause / Failure 继续保持既有合同。

- [x] **Step 2: 按既有 v5 HUD 路径运行轻量治理并保持人工门禁**

Task 2 的三份相邻 `.source.json` 是来源与散列真源；`asset-manifest.md` 把状态从 planned 更新为 `runtime technical candidate / human visual review pending`。本轮不把这三张 HUD 图伪装成角色 / 地形生产队列，也不为它们改写 `image-gen-prompt-queue.json`、`asset-provenance-records.json` 或 final-art gates。

```powershell
python scripts/assets/audit_seal_resonance_hud_assets.py --strict
python scripts/assets/audit_asset_package.py --strict --write-report
```

Expected: source/output SHA256、运行绑定、Alpha 与 strict package 全部通过；三份 source record 仍为 `final_ready=false`。

- [x] **Step 3: 捕获七档布局与所有语义状态**

`capture_seal_resonance_hud_review.gd` 固定捕获：

- 视口：`640x360`、`1024x576`、`1280x720`、`1672x941`、`2048x1152`、`2560x1080`、`2560x1440`。
- 状态：idle 雷 / 疾、idle 风 / 御、primed 风、resolved 风→雷、resolved 雷→风。
- 反馈：元素切换双帧、姿态切换双帧、普通灵力链双帧、reduced-motion 双帧。
- 教学：五步姿态提示键盘 / 手柄、风印首次解锁键盘 / 手柄、完成切换后的房间提示恢复。

报告 `seal_resonance_hud_review.json` 对每张图记录 SHA256、物理矩形、内容安全区、FrameArt 可见性、glyph ID、Shader 参数、是否与 Battle / Prompt 相交。普通流动双帧 crop 应不同；reduced-motion 双帧 crop 应相同。

- [x] **Step 4: 运行真实窗口捕获并逐张原尺寸查看**

```powershell
godot --path . --script res://scripts/dev/capture_seal_resonance_hud_review.gd
godot --path . --script res://scripts/dev/capture_tutorial_hud_formal_review.gd
```

用 `view_image detail=original` 检查所有正式截图，重点拒收：框体占屏过大、闲置态仍像文本框、图标碰边、字被官印遮挡、FrameArt 拉伸、符号毛边、风 / 雷或疾 / 御只靠换色、贯穿 / 散射线势相同、reduced-motion 仍持续流动。

- [x] **Step 5: 运行 UI binding 与资产专项门禁**

```powershell
python scripts/assets/audit_seal_resonance_hud_assets.py --strict
godot --headless --path . --script res://scripts/dev/audit_runtime_ui_skin_binding.gd
```

Expected: 新 HUD 三项资产均在运行清单中、旧 Element 运行消费者为 `0`、unsafe source 为 `0`；人工审美 / 授权仍 pending。

---

### Task 7: 全量回归、事实来源收口与人工交付

**Files:**
- Modify: `spec-design/2026-08-10-seal-resonance-hud-redesign.md`
- Modify: `docs/implementation-plans/2026-08-11-seal-resonance-hud-repair.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/logs/2026-08-11.md`
- Modify only when the actual change requires it: `docs/progress/timeline.md`

**Interfaces:**
- Consumes: Tasks 1–6 的新鲜结果和截图。
- Produces: 技术候选状态、明确未通过的人审边界和可供用户查看的实机证据；不自动发布。

- [x] **Step 1: 运行最邻近和输入回归**

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage21/test_stage_21_element_stance_sequence.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage26/test_stage_26_north_star_alpha_candidate.gd -gexit
godot --headless --path . --script res://scripts/dev/run_stage17_input_smoke.gd
```

- [x] **Step 2: 运行 import、主场景 smoke 和递归 GUT**

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 120
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

记录真实 test / assertion 数量与 ObjectDB warning；不得复制 2026-08-10 的旧 `351/351` 数量冒充新鲜结果。

- [x] **Step 3: 检查任务自有 diff、引用与陈旧文案**

```powershell
rg -n "Q 元素 / E 姿态|序列：—|ElementStatusLabel|element_frame_integrated_warden_ai01" scenes/ui/tutorial_hud.tscn scripts/ui/tutorial_hud.gd scripts/ui/seal_resonance_hud.gd tests scripts/dev
git diff --check -- scripts/ui/seal_resonance_hud.gd scripts/ui/input_binding_formatter.gd scripts/ui/tutorial_hud.gd scripts/ui/demo_shell.gd scripts/rooms/tutorial_room.gd scenes/ui/tutorial_hud.tscn assets/configs/rooms/tutorial_room_flow.tres tests scripts/dev docs/assets/asset-manifest.md spec-design/2026-08-10-seal-resonance-hud-redesign.md docs/implementation-plans/2026-08-11-seal-resonance-hud-repair.md docs/progress/status.md docs/progress/logs/2026-08-11.md
```

允许旧设计 / 历史日志保留原型文案，但生产场景、生产脚本、当前测试和当前审计不得再依赖它。

- [x] **Step 4: 更新状态与日志，只写新鲜事实**

- 设计状态更新为“已实现技术候选，待真人视觉签核”或如实记录阻塞。
- 实现计划逐项勾选实际完成项，不因接近结束而预先勾选。
- 状态 / 日志记录：新资产来源与 SHA 边界、三态与教程迁移、实际测试数量、截图报告路径、已知 warning、未完成人审 / 授权 / Gate26H。
- 只有形成新的可玩里程碑才更新 timeline；普通技术收口不重复堆一条。

- [ ] **Step 5: 代表图已准备；待主代理展示截图并等待用户真人评审**

至少展示 `idle`、`primed`、两种 `resolved`、键盘姿态教学、风印解锁提示和 `640x360 / 2048x1152 / 2560x1080` 布局；使用 Windows 绝对路径。明确区分：机器验证通过、运行态已采用、真人视觉尚未批准、没有 commit / push / release。

## Plan Self-Review Checklist

- [x] 设计稿每项要求都映射到 Task 1–7：三态、双框、六符号、灵力链、两种反应、双切换反馈、reduced-motion、E 教程、Q 解锁教学、Controls / Settings、七档布局、资产与人审边界。
- [x] 占位表达扫描无命中；每个代码任务均给出接口、关键实现内容、命令和预期结果。
- [x] 跨任务名称一致：`SealResonanceHud`、`apply_snapshot`、`get_visual_snapshot`、`InputBindingFormatter.action_label`、`wind_switch`、`seal_resonance_v1_complete_frame`。
- [x] 所有新增文件都在 File Map 和至少一个 Task 中出现；所有修改范围都能由用户批准的 A 方案解释。
- [x] dirty worktree 保护已写入全局约束；执行期间只处理列入计划的任务文件。
