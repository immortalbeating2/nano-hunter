# C2 主菜单接入计划

## 范围

- 固化 C2 选定稿、无文字正式背景 `main_menu_shell_ai02.png` 与独立透明字标 `main_menu_wordmark_ai01.png`。
- `DemoShell` 改为右侧无框响应式布局，删除可见状态提示与主菜单前置图标。
- 主菜单使用专属透明 / 青线状态样式；其他面板继续复用既有 NinePatch 与按钮皮肤。
- 将按钮各自的静态青线替换为唯一共享 `FocusBand`，由 CanvasItem Shader 持续流动、原生 Tween 追踪键鼠 / 手柄焦点。
- 更新 Stage16 回归、运行 UI 绑定审计、资产包审计和主菜单多分辨率捕获。

## 验证

1. Godot `4.6.3` import。
2. Stage16 专项 GUT 与运行 UI 绑定审计。
3. `640x360`、`1024x576`、`1672x941`、`2048x1152` 与 `2560x1080` 主菜单 normal / hover 捕获。
   - 同一 Start 焦点双帧必须产生可测像素变化；跨行到 Settings 后仍只有一个 `FocusBand`，且中心落在目标按钮底边。
4. 生产主场景 Start、Continue 禁用态、控制说明与返回链 smoke。
5. C2 参考图与生产截图同屏设计 QA；修复 P0-P2 后通过。
6. `git diff --check` 与本次文件范围核对。

## 完成门禁

- 运行背景引用 `main_menu_shell_ai02`，画面中不存在烘焙 UI 文字。
- 主菜单无卡片、无状态提示、无前置图标，六项保持同轴居中。
- 现有按钮行为、手柄焦点与 Continue 门控不回归。
- Shader 必须由 `TIME` 自驱，场景只存在一个共享光带节点；旧 hover / focus StyleBox 不再绘制重复底边。
- 自动证据与运行截图通过；真人审美、真实 21:9 和商业发布授权不冒充完成。

## 执行结果（2026-08-05）

- C2 背景、独立风化字标和右侧无框六项菜单已接入生产 `Main.tscn -> DemoShell`；普通有效存档不再显示额外提示，异常备份 / 损坏状态收敛到 Continue 文案。
- 共享动态符光已接入：一个 `FocusBand` 使用 `TIME` 驱动的 CanvasItem Shader 生成流动亮斑、辉光与符尘，焦点变化通过 `0.18s` 原生 Tween 追踪按钮底边；鼠标、键盘和手柄继续使用真实 Button 焦点。
- Stage16 `20/20` / `520` assertions、Stage26 `6/6` / `80`、Stage31 `5/5` / `78`，递归 GUT `48` scripts / `322/322` / `8895` assertions。
- Godot import、runtime UI binding `2 scenes / 5 panels / 5 textures`、strict asset package、start review 与五档布局 / hover report 均通过。
- 同尺寸、聚焦区域、双帧流动与 Start → Settings 共享节点比较见 ignored 的 `tests/artifacts/local/main-menu-c2-design-qa/`；最终 `design-qa.md` 为 `passed`。真实物理 21:9、真人审美与商业授权仍留 Gate26H。
