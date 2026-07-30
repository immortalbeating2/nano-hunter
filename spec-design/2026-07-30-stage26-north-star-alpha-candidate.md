# Stage26 北极星 Alpha Candidate 收口设计

## 目标

停止新增大系统，把 Stage21-25 与既有 34 房首次通关链整合为可复查的北极星 Alpha 候选；修复候选入口、手柄映射和交付状态的真实缺口，并把自动证据与真人 / 实体手柄外部签核明确分开。

## 候选边界

- 正式入口仍为 `res://scenes/main/main.tscn`。
- 首次通关仍沿安全主线到 Stage16 终点；Stage11 悬赏与 Stage25 雷泽荒原是可回访循环，不强行插入首次通关。
- Stage21-25 的状态继续由 Main 单次会话快照持有，不新增存档系统、存档槽或“继续游戏”假实现。
- Stage26 只修候选集成缺口、补跨阶段回归和交付文档，不新增元素、敌人、房间、装备或剧情分支。

## 候选集成改动

### 手柄映射

候选默认映射固定为：

| 动作 | 手柄 |
| --- | --- |
| 移动 | 左摇杆 / 十字键 |
| 跳跃 | A |
| 冲刺 | B |
| 攻击 | X |
| 恢复 | Y |
| 元素切换 | LB |
| 姿态切换 | RB |
| 暂停 | Menu / Start |

- 移除 Dash 的 RB 备用绑定，避免一次输入同时触发冲刺与姿态切换。
- 键盘 `WASD / Space / J / K / L / Q / E / Esc` 保持不变。
- synthetic Joypad 只证明 InputMap 与生产 Player 通路；实体手柄型号、漂移、平台驱动和人体工学仍需外部签核。

### 调试与交付入口

- Demo shell 的调试选关增加 Stage25 六房；机关房预置风印和风元素，保证可直接复核接地序列。
- Stage16 终点保留历史快照字段名，但候选文档落盘并通过门禁后，HUD 应显示 release notes / QA checklist 已准备，不再显示陈旧“待补充”。
- 新建 `docs/deliverables/stage26-north-star-alpha-candidate/`，保存 QA checklist、release notes 与北极星完成度审计。

## 验证分层

### 自动化

- Stage26 GUT 覆盖非冲突手柄映射、Stage25 调试入口、跨 Stage 悬赏 / Build / 雷泽 / Boss / 终点状态、失败恢复、重开边界和交付文档。
- 复跑 Stage16、Stage19、Stage21-25 邻近组合及递归全量 GUT。
- 运行 Godot import、主场景 smoke、`git diff --check`。

### 运行态

- 复用现有 input-only replay：只发送生产 Input action，从主菜单自然完成 34 房首次通关，不调用切房或改玩家坐标。
- 复核暂停、地图、HUD、Build 面板、Stage25 接地和最终完成反馈；截图 / JSON 只保存在 ignored 的 `tests/artifacts/local/`。
- 查询 `Input.get_connected_joypads()` 记录本机是否存在实体设备；无设备时不得把 synthetic 输入写成硬件认证。

### 外部人工

- 真人首次通关、至少一次能力回访、悬赏回交理解度、Build 调整手感与实体手柄舒适度必须由人执行。
- 自动化与代理运行态可以让候选达到“开发收口完成”，不能把外部人工门禁改写为“已签核”。

## 存档边界

| 操作 | 候选语义 |
| --- | --- |
| 同一会话切房 / checkpoint 恢复 | 保留 Main 的元素、姿态、悬赏、Build、Boss 与地图发现状态 |
| 失败恢复 | 回最近 checkpoint；不清空本轮跨房状态 |
| 重开 Demo | 回教程起点并清空全部本轮状态 |
| 关闭程序后继续 | 不支持；主菜单 Continue 不宣称持久化 |

## 音效缺口

当前 `assets/audio/` 只有目录占位，Stage16 音频包也仅有需求文档。Alpha Candidate 允许无音频进入人工试玩，但 release notes 与完成度审计必须明确：

- P0：攻击 / 命中、玩家受伤、Boss 预警、checkpoint、关键机关与完成反馈。
- P1：UI 确认 / 返回、区域氛围、脚步 / 跳跃 / Dash、悬赏与 Build 反馈。
- 本阶段不临时生成或接入未经授权、未混音的占位音频。

## 退出标准

- 所有可自动取得的 Stage26 证据通过，候选文档、映射和调试入口与当前代码一致。
- 首次通关 replay、暂停 / 地图 / HUD、失败恢复、存档边界和音效缺口均有新鲜记录。
- 真人与实体手柄未执行时，Stage26 开发可收口，但 Alpha Candidate 最终签核必须保持“待外部人工验收”。
