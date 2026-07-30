# Stage26 北极星 Alpha Candidate 正式计划

## 目标

复用现有主线 replay、Main 快照、Demo shell 与分阶段 GUT，将 Stage21-25 收成一份可自动复查、可交给真人签核的 Alpha Candidate。

## 实现顺序

1. 新增 Stage26 GUT，先锁定手柄映射、Stage25 选关、跨阶段循环、失败 / 重开和交付文档。
2. 用 Godot ProjectSettings 输入动作工具写入非冲突标准手柄映射；Main fallback 同步兜底。
3. Demo shell 增加 Stage25 六房调试入口，终点 HUD 对齐当前候选文档就绪状态。
4. 新增 QA checklist、release notes、北极星完成度审计与音效 / 存档边界说明。
5. 运行 Stage26 专项、Stage16/19/21-25 邻近组合、全量 GUT、import、smoke。
6. 运行 input-only 首次通关、synthetic Joypad 与 Windows/OpenGL 候选复核，记录实体设备探测结果。
7. 更新路线清单、状态、时间线和当日日志后提交 Stage26 检查点。

## 最小改动

- 不重写 Stage16 主线 driver，不建立第二套候选状态机。
- 不新增存档系统；只冻结单次会话、checkpoint 和重开语义。
- 不接入临时音频；只形成有优先级的真实缺口清单。
- 不把 synthetic Joypad 或代理操作描述为真人 / 实体手柄验收。

## 验证

- Stage26 专项先红后绿。
- 邻近组合至少包含 Stage16 / 19 / 21 / 22 / 23 / 24 / 25 / 26。
- 全量 GUT、Godot import、主场景 smoke、input-only replay、InputMap smoke 与 `git diff --check` 均需新鲜通过。
- 外部人工项未取得证据时在 QA checklist 保持未勾选。

## 收口状态

- 自动化、input-only replay、synthetic Joypad 与 Windows/OpenGL 代理运行态已闭环。
- Xbox Series X Controller 的真实事件、`9/9` 生产动作、摇杆 / 十字键、静置漂移和教程内响应已完成技术复核。
- 真人首次通关、能力回访、悬赏 / Build 理解度和实体手柄主观舒适度仍待外部人工签核。
