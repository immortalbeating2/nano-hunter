# Gate26M Godot MCP Pro 自动技术门禁执行清单

## 入口

- [x] 正式计划：`plan/2026-08-01-gate26m-automated-technical-baseline.md`。
- [x] Preflight26A 已形成可复现起点：`eb98e47` / `5b176d9`。
- [x] 阅读并按 Godot MCP Pro 项目内连接指南执行，记录本轮 bridge `17605`、editor PID `35264`、console PID `23908`。

## 工具与输入

- [x] bridge workspace 精确匹配仓库根目录；Godot `4.6.3`、project info、运行态 InputMap 与临时 autoload 可读。
- [x] 生产主场景可启动，输出与 editor errors 无产品阻断错误；仅有 ignored 证据 duplicate UID 和一次不支持 `await` 的 MCP 临时脚本警告。
- [x] 主菜单开始、暂停、继续、地图、Build、详情与返回链由模拟输入 / 生产按钮走通。
- [x] 焦点可见，`SceneTree.paused` 与面板状态在进入 / 返回后正确；地图动态计数为 `1 / 44`。

## 战斗与证据

- [x] 元素、姿态、两步序列与攻击模拟触发公开快照变化：两条反应分别为 `wind_thunder_pierce`、`thunder_wind_scatter`。
- [x] Stage21 / 23 / 24 / 25 代表场景取得关键截图、`6` 帧连续捕获和状态断言。
- [x] 未发现可稳定复现的产品缺口，因此不新增测试框架；沿用同一新鲜基线 `301/301` GUT。
- [x] 证据写入 ignored `tests/artifacts/local/gate26m/`，文档只记录结论与命令。
- [x] 停止本轮场景和当前 workspace PID；三个临时 autoload 已移除，`project.godot` diff 清零。
- [x] 明确 Gate26M 不等于 Gate26H 真人手感 / 理解度 / 审美签核。

## 工具兼容记录

- `get_input_actions` 在当前编辑器端只列出编辑器内置动作，项目生产映射改由运行态 `InputMap` 读取并确认。
- Server 已暴露但插件端未实现 `record_frames`；本门禁使用已验证可工作的 `capture_frames`。不为此改造游戏或另建自动化框架。
