# Stage26 北极星 Alpha Candidate QA Checklist

## 证据口径

- 自动化：GUT、import、smoke、input-only replay 与 synthetic Joypad。
- 代理运行态：Windows/OpenGL 截图、UI / 状态探针和错误面板。
- 实体手柄技术复核：真实 Joypad 事件、InputMap、漂移 / 死区和游戏内响应；synthetic Joypad 不能替代本类。
- 外部人工：真人路线理解、操作手感与人体工学；前三类证据不能替代本类。

## 自动化门禁

- [x] Stage26 专项 GUT：`5/5` tests、`62` assertions。
- [x] Stage16 / 19 / 21 / 22 / 23 / 24 / 25 / 26 邻近回归：`8` scripts、`56/56` tests、`1004` assertions。
- [x] 递归全量 GUT：`42` scripts、`299/299` tests、`8524` assertions。
- [x] `godot --headless --path . --import`。
- [x] `godot --headless --path . --quit-after 3`。
- [x] `git diff --check`。
- [x] input-only 首次通关从主菜单自然到 Stage16 终点：`34` 房、`429.38s`、`P0/P1/P2=0`。
- [x] 键盘与 synthetic Joypad 经生产 InputMap 触发候选动作：`14/14` 输入行。

## 运行态复核

- [x] 主菜单开始、控制说明和 Stage25 六房调试选关可读。
- [x] 暂停、发现式地图、HUD 元素 / 姿态 / 序列和 Build 面板可读。
- [x] 三条悬赏可接取、完成、回交，雷泽路引可进入 Stage25。
- [x] Stage25 风→雷接地后雷暴隐藏、出口解锁。
- [x] 失败恢复回最近 checkpoint，并保留本轮悬赏 / Build 状态。
- [x] 重开回教程并清空本轮状态；release notes / QA 静态就绪状态保持。
- [x] Stage16 终点显示 Alpha Demo 完成和候选文档已准备。
- [x] 临时 MCP autoload 已清理，编辑器错误面板为 `0`，只结束本轮自有编辑器。

## 控制映射

- [x] 键盘：移动 `A/D` 或方向键、跳跃 `Space/W/↑`、攻击 `J`、冲刺 `K`、恢复 `L`、元素 `Q`、姿态 `E`、暂停 `Esc`。
- [x] 手柄映射：移动左摇杆 / 十字键、跳跃 A、冲刺 B、攻击 X、恢复 Y、元素 LB、姿态 RB、暂停 Menu。
- [x] Dash 不再绑定 RB，不会与姿态切换同时触发。

## 存档与音效边界

- [x] checkpoint 只负责当前进程内失败恢复。
- [x] 重开 Demo 清空悬赏、Build、地图发现、能力与 Boss / 完成状态。
- [x] 当前无正式存档；主菜单 Continue 明确说明不能跨进程继续。
- [x] 音频目录当前只有占位；P0 / P1 缺口记录在完成度审计，不临时接入未授权音频。

## 实体手柄技术复核

- [x] Windows / Godot `4.6.3` 识别 Xbox Series X Controller，记录 GUID、vendor / product 与 XInput index。
- [x] 真实手柄覆盖移动、跳跃、攻击、冲刺、恢复、元素、姿态和暂停 `9/9` 个生产动作；A/B/X/Y/LB/RB/Menu 均有原始事件。
- [x] 左摇杆 X 达到 `-1.0 / 1.0`；十字键按钮 `13 / 14` 分别触发左右移动。
- [x] 静置 `17.522s` / `1050` 帧期间 6 个轴 `max_abs=0.0`，当前 `0.5` InputMap 死区无漂移触发。
- [x] 游戏内 HUD 切换到手柄模式，玩家移动 / 跳跃 / 攻击 / 冲刺、姿态切换及暂停恢复均产生运行态响应。

## 外部人工签核

- [ ] 真人首次通关和至少一次能力回访。
- [ ] 真人完成悬赏回交与 Build 调整，确认提示和节奏可理解。
- [ ] 真人确认实体手柄按键舒适度、误按情况及暂停菜单 UI 导航手感。

当前状态：自动化、代理运行态和实体手柄技术复核已收口；真人路线 / Build 理解度与主观手感仍保持外部人工门禁，未取得反馈前不得勾选。
