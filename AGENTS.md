# AGENTS.md - Nano Hunter 仓库执行契约

## 作用与边界

- 项目是 Godot `4.6.x` 的 2D 类银河恶魔城，主要使用 GDScript，主场景为 `res://scenes/main/main.tscn`。
- 本文件只保存跨阶段稳定的仓库硬规则、阅读入口和完成门禁。
- 当前阶段、分支、测试数量、资产批次和临时风险统一读取 `docs/progress/status.md`，不在本文件复制。
- 优先做小而准、可验证、可追溯的改动，不为未来需求提前铺设框架。

## 规则优先级与北极星

1. 用户直接要求
2. 本项目 `AGENTS.md`
3. `spec-design/2026-03-23-nano-hunter-design.md`
4. 已批准的阶段设计与实现计划
5. 通用习惯和辅助技能建议

- 总设计锚点是南北朝东方奇幻、Luna 镇妖卫赏金猎人、元素序列连锁、佛门符印姿态，以及 Ori 式流动感与山海经 / 水墨工笔气质。
- 现代实验室、生物废液等旧灰盒表达不得继续扩张；应回收为封妖禁地、瘴泽、妖域、腐化祭坛、符印机关或官府 / 佛门遗构。
- 若阶段设计必须偏离北极星，先写明原因、范围、临时性和回归路径。
- 面向用户的说明、代理任务和项目文档默认使用中文；提交信息使用“中文 + English”；项目自有代码注释使用中文。

## 必读顺序与事实来源

新 session 开始修改前，依次读取：

1. `AGENTS.md`
2. `docs/progress/status.md`
3. 最近一篇 `docs/progress/logs/YYYY-MM-DD.md`
4. 当前任务相关的 `spec-design/`、`plan/` 和 `docs/implementation-plans/`

事实冲突时，以当前代码和可运行结果为先，其次是最新状态文档、最新设计文档，最后才是旧聊天或历史计划。

专题入口：

- Codex 客户端：`docs/dev/codex-client-workflow-reference.md`
- Codex 多代理设置：`docs/dev/codex-multi-agent-settings-reference.md`
- Godot MCP：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- 插件状态：`docs/dev/plugin-inventory.md`
- 资产需求：`docs/assets/asset-manifest.md`
- 资产生产：`docs/assets/asset-production-roadmap.md`
- 资产存储：`docs/assets/asset-storage-policy.md`

## 任务分级与最短流程

大功能包括核心玩法、玩家控制、战斗循环、状态机、敌人 AI、关卡推进、能力门控、主流程 UI 和项目级规范变更。

大功能按以下顺序推进：

1. `brainstorming` 或等效设计确认
2. 在 `spec-design/` 确认或补写设计
3. 在 `docs/implementation-plans/` 写执行清单；正式 Stage 同步维护根目录 `plan/` 的唯一最终版
4. 选择分支 / worktree 策略
5. 实现
6. 自动验证和必要的运行态复核
7. 更新状态、时间线和当日日志

小改动包括单点配置、插件启停、目录修正、文档修订和单脚本 bugfix。先写明目标与影响范围，再实施、做最小验证、更新当日日志，默认一个提交。

需求边界不清、影响多个子系统、改变后续方向或与现有设计冲突时，自动升级为大功能。不要把第二个目标偷偷混入当前改动。

## 项目实现约束

- 复用现有契约：房间沿用 `room_transition_requested`、`checkpoint_requested`、`get_hud_context()`；敌人沿用 `receive_attack(...)`、`defeated`；HUD 继续读取状态快照。
- 配置优先放入已有 Resource、场景导出字段或现有配置脚本，不把调参散落成不可追踪的硬编码。
- 玩家、战斗、敌人、房间、checkpoint、HUD、能力门控和 MCP 工具链属于高风险区域；修改范围保持小，并补最接近的测试。
- 薄包装房间脚本可以保留，但必须说明差异来自基类、场景节点、导出字段还是 override。
- 不提前实现完整地图、正式存档、复杂 Boss 框架、技能树或多资源经济，除非已批准的阶段设计明确要求。
- 非平凡运行时脚本、测试和 PowerShell 工具必须有中文文件头；重要 signal、export、状态和非平凡函数说明职责、调用方与副作用。
- 注释解释“为什么”，不逐行复述代码。触达超过三个核心脚本时，收口检查注释可读性和常见乱码。

资产规则：

- 不让正式资产生产阻塞灰盒玩法验证；玩法成立后再替换正式资产。
- 新需求先登记 `docs/assets/asset-manifest.md`，按生产路线和存储策略处理来源、候选、接入与授权。
- 原始候选、source sheet 和预览图不等于运行时已接入；完成宣称必须验证真实场景引用和运行表现。
- 当前默认启用插件仅为 `godot_mcp` 与 `gut`；其他已安装插件的判断以插件盘点为准。

## 文档留痕

- 所有开发活动都要记录做了什么、为什么、影响、验证、风险和下一步；没有验证记录不能声称完成。
- `spec-design/` 保存玩法和系统设计；实现改变设计时同步回写。
- `docs/implementation-plans/` 保存执行清单；`plan/` 只保存每个正式 Stage 的唯一最终计划。
- `docs/progress/status.md` 保存当前真实摘要；`timeline.md` 只记里程碑；`logs/YYYY-MM-DD.md` 保存当天细节。
- `docs/deliverables/<id>/` 只用于可试玩、可打包或可发布候选，不为普通 bugfix、工具修正或内部实验创建。
- 截图和一次性测试证据默认放在 ignored 的 `tests/artifacts/local/<topic>/`，不塞入进度文档。
- 只更新本次实际变化的事实来源，不在多个文件复制同一段状态或命令输出。

## 验证与完成门禁

- 工程配置或导入状态变化后运行 `godot --headless --path . --import`。
- 脚本或场景变化运行最接近的 GUT；bugfix 优先补最小回归测试。
- 需要人工复核时使用 Godot MCP，并遵循连接指南；结束后清理临时 autoload diff。
- 纯文档改动只需做引用路径、陈旧术语、乱码、格式和 `git diff --check` 验证，不运行无关的游戏回归。
- 完成前确认：目标范围已实现、相关验证通过、进度文档已更新、没有混入无关文件。
- 未取得当次新鲜验证证据，不使用“已完成”“已修复”“测试通过”等结论。

## Git、协作与维护

- `main` 只承载稳定、已验证、可试玩的结果；除极小低风险整理外，从最新稳定基线创建任务分支。
- 阶段型开发在需要保留 Godot 编辑器、导入缓存或稳定试玩现场时复用固定永久工作树；短任务默认只开分支，临时 worktree 仅用于真正隔离的并行或实验。
- 多代理仅在写入范围可分离时启用；多个代理不得同时修改同一核心脚本，主代理负责整合和最终验证，子代理不得继续派生子代理。
- 每次提交只表达一个进展点，使用“中文 + English”；提交前确认验证、留痕和无关噪音。
- 阶段型开发按可验证检查点提交；小改动默认一个提交。合并、push、PR、分支或 worktree 清理必须符合用户授权范围。
- 删除 worktree 或清理 MCP / Godot 现场前，先确认进程归属和 ignored 本地证据，不影响其他活跃项目。
- 客户端前缀、任务 UI、临时 worktree 和工具入口等实现细节只维护在客户端专题文档。
- 阶段开始、完成、分支切换和工具版本变化不再触发本文件更新。
- 修改本文件时优先替换或删除旧规则，不做追加式堆叠；动态信息必须进入状态、计划、日志或对应专题文档。
