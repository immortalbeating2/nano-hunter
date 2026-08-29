# 运行态视觉一致性完整修复执行清单

权威设计：`spec-design/2026-08-08-runtime-visual-integrity-repair.md`

## Checkpoint 0：现场与红灯

- [x] 保存用户四张实机截图到 ignored 本地证据目录。
- [x] 新鲜运行旧碰撞、HUD、Stage17 测试，确认它们不能捕获用户症状。
- [x] 使用 `--debug-collisions` 复现第一关薄平台二维错位。
- [x] 为 44 房补二维 bounds/连续段门禁，并在修复前记录稳定失败。
- [x] 为 HUD 补四边、实际最小字号、最长文案和装饰排除区失败用例。
- [x] 为 Luna 补普通跳跃禁止跨模型、live 资产 final-ready 和锚点连续性失败用例。

## Checkpoint 1：共享地形根因

- [x] 输出 44 房逐房 JSON，记录权威层、可见层、运行态 bounds 与差值。
- [x] 修正 `formal_terrain_kit_ai01` 共享碰撞 polygon 的格心坐标。
- [x] 按资源 alpha 收边确认 left/center/right cap allowance，不以全局宽松阈值放过偏移。
- [x] 同步房间生成器、TileSet 审计、模板测试和地形说明文档。
- [x] 清除未登记的第三碰撞层和仍启用的 retired shape；逻辑门禁/Area 保持不变。
- [x] 二维专项 44/44 通过，并生成全房 debug-collision 运行态证据。

## Checkpoint 2：HUD 响应式重构

- [x] 把 TutorialHUD 内部固定 offset 收敛为响应式 Container 与 Theme tokens。
- [x] 提升正文、标题、数值、图标和条形的最小物理读值。
- [x] 为 Prompt/Battle/Element 面板建立真实 content margins 与装饰排除区。
- [x] 实现唯一 TutorialAttention 共享层和青色进入、等待提醒、金色完成反馈。
- [x] 接入降低动态效果设置；键鼠和手柄提示共享同一焦点/提醒状态。
- [x] 多分辨率、最长文案、空正文、Boss、恢复与元素序列用例通过。
- [x] 保存正常、步骤进入、等待提醒、完成四态运行截图/双帧证据。

## Checkpoint 3：Luna 动作统一

- [x] 先让普通跳跃全程使用 ai04 Model Lock 家族，移除 apex 对 Stage27 独立 sheet 的 live 依赖。
- [x] 审计所有玩家 body 的脚本 preload、场景与资源引用，阻断 `final_ready=false` live 绑定。
- [x] 生成动作接触表，量化 center、foot、head/body height 与 alpha bounds 连续性。
- [x] 现有 ai03/ai04 自动身份 / 锚点门禁未触发重生；Stage27 身份漂移表改为 review-only，不生成第二套未签核 live body。
- [x] 通过自动锚点门禁、Stage17/Stage27 回归和运行态转场复核。
- [ ] 人工签核脸型、发型、服装、比例、轮廓和动作节奏后，才更新 final-ready。

## Checkpoint 4：全量收口

- [x] `godot --headless --path . --import`；退出码 `0`，历史 ignored 证据副本产生的 UID duplicate 警告已记录。
- [x] 碰撞、Stage5、Stage12、Stage17、Stage21/26/27 邻近 GUT。
- [x] 递归全量 GUT 与主场景 smoke；`50` scripts / `334/334` / `9220` assertions。
- [x] 44 房二维报告、debug-collision 截图、HUD 多档截图、Luna 接触表齐全。
- [x] 从教程到 Stage16 的纯输入 replay 自然经过 `34` 个流程房，`360.2167s`、完成标记为真、`P0/P1/P2=0`。
- [x] 更新地形契约、Luna 候选 / gates 边界、状态、时间线和当日日志；Stage27 人物表仍保持 `final_ready=false`。
- [x] `git diff --check` 退出码 `0`；逐项核对并保留当前工作树既有 C2、个人配置、VFX 与候选目录改动，未暂存或回退。
- [ ] 真人碰撞读值、HUD 阅读距离、动态节奏、Luna 身份签核保持独立 Gate；未签核不写 release-final。
