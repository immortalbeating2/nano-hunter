# Gate26M Godot MCP Pro 自动技术门禁执行清单

## 入口

- [x] 正式计划：`plan/2026-08-01-gate26m-automated-technical-baseline.md`。
- [ ] Preflight26A 已形成可复现起点。
- [ ] 阅读并按 Godot MCP Pro 项目内连接指南执行，记录本轮桥接 / 编辑器 PID。

## 工具与输入

- [ ] bridge workspace 精确匹配仓库根目录；Godot 版本、project info、输入动作、autoload 可读。
- [ ] 生产主场景可启动，输出与 editor errors 无阻断错误。
- [ ] 主菜单开始、暂停、继续、地图、Build、详情与返回链可由模拟输入走通。
- [ ] 焦点可见，`SceneTree.paused` 与面板状态在进入 / 返回后正确。

## 战斗与证据

- [ ] 元素、姿态、两步序列与攻击模拟触发公开快照变化。
- [ ] Stage21 / 23 / 24 / 25 代表场景取得关键截图、连续帧和状态断言。
- [ ] 稳定复现问题已补最小 GUT；无稳定缺口时不新增测试框架。
- [ ] 证据写入 ignored `tests/artifacts/local/gate26m/`，文档只记录结论与命令。
- [ ] 停止本轮场景 / 精确 PID，临时 autoload 与工程配置 diff 清零。
- [ ] 明确 Gate26M 不等于 Gate26H 真人手感 / 理解度 / 审美签核。
