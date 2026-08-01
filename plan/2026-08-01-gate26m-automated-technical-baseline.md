# Gate26M Godot MCP Pro 自动技术门禁计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
执行清单：`docs/implementation-plans/2026-08-01-gate26m-automated-technical-baseline.md`

## 目标

用 Godot MCP Pro、GUT 与生产主场景证明输入、焦点、状态和画面链路可工作，为 Stage27-31 提供可重复技术门禁；不把自动复核冒充真人手感验收。

## 实施顺序

1. 校验 bridge workspace 精确等于仓库根目录，读取 Godot 版本、project info、输入动作、autoload 与编辑器错误。
2. 启动 `res://scenes/main/main.tscn`，用生产 UI 模拟键盘 / 手柄等价输入：主菜单开始、暂停、继续、地图、Build、详情与返回。
3. 在调试选关中进入 Stage21、Stage23、Stage24、Stage25 代表场景，模拟攻击、元素切换、姿态切换和序列输入。
4. 通过 Main / Player 公开快照断言焦点、`SceneTree.paused`、元素、姿态、序列、Build 与房间状态；捕获关键截图和连续帧。
5. 读取运行输出与编辑器错误；仅对可稳定复现的缺口补最小 GUT，不创建平行自动化框架。
6. 停止本轮启动的场景与精确 PID，清理本轮临时 autoload，复查工程配置 diff。

## 证据包

- workspace / 版本 / 输入动作快照。
- 主菜单、暂停、地图、Build、元素 / 姿态 / 序列的截图或连续帧。
- 关键状态断言、输出日志、编辑器错误数量、GUT 结果。
- `tests/artifacts/local/gate26m/` 本地证据，不提交一次性截图。

## 退出标准

- 输入到达、焦点可见、返回链正确、暂停状态可恢复。
- 元素 / 姿态 / 序列触发真实状态与画面变化，无运行错误。
- 记录“自动可证明”与“Gate26H 才能判断”的边界。

## 非目标

不评价按键舒适度、误触、迷路、规则理解和审美完成度；不代替实体手柄真人试玩。
