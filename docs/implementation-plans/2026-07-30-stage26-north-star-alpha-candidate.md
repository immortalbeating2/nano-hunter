# Stage26 北极星 Alpha Candidate 执行清单

## 设计与回归

- [x] 冻结候选范围、自动 / 运行态 / 外部人工证据边界。
- [x] 新增 Stage26 GUT，先覆盖集成缺口与交付契约。

## 候选集成

- [x] 写入 A/B/X/Y/LB/RB/Menu 非冲突手柄映射并保留键盘。
- [x] Demo shell 增加 Stage25 六房调试选关。
- [x] 终点 HUD 的 release notes / QA checklist 状态与 Stage26 文档一致。
- [x] 明确 checkpoint、重开与无持久化 Continue 边界。
- [x] 形成 P0 / P1 音效缺口清单。

## 自动与运行态验证

- [x] Stage26 专项通过。
- [x] Stage16 / 19 / 21 / 22 / 23 / 24 / 25 / 26 邻近回归通过。
- [x] 递归全量 GUT、Godot import、主场景 smoke 和 `git diff --check` 通过。
- [x] input-only 首次通关与 synthetic Joypad 候选输入通过。
- [x] Windows/OpenGL 复核暂停 / 地图 / HUD、失败恢复、Build 与终点反馈。
- [x] 清理临时 MCP autoload，并确认只结束本轮自有进程。

## 交付文档

- [x] 更新 Stage26 QA checklist。
- [x] 更新 Stage26 release notes。
- [x] 更新北极星完成度审计。
- [x] 更新路线清单、状态、时间线和当日日志。

## 外部人工签核

- [ ] 真人首次通关与至少一次能力回访。
- [ ] 真人完成悬赏回交与 Build 调整体验复核。
- [x] Xbox Series X Controller 实体信号、InputMap、摇杆 / 十字键、漂移 / 死区与教程内响应复核。
- [ ] 真人确认实体手柄按键舒适度、误按和暂停菜单 UI 导航手感。

开发收口状态：自动化、代理运行态和实体手柄技术门禁已闭环；真人路线、悬赏 / Build 理解度与主观手感仍保持外部人工门禁。
