# 角色 / 怪物通用模型锁专项修复实施计划

**类型：** 非 Stage 专项修复轮次
**设计：** `spec-design/2026-08-09-character-creature-model-lock-repair.md`
**范围：** 资产治理、现有 body 归一化、接触表、生产绑定与回归；不新增玩法或生成新图片。

## 1. 红灯与事实快照

- [x] 盘点 Luna、四类旧敌人、Seal Guardian、雷蚀獠、夔影雷骸全部 live body。
- [x] 证明只有 Luna metadata 声明 `model_lock`。
- [x] 证明 Seal Guardian 旧 idle 与 Stage27 formal motion 存在约 `128px -> 165px` 中位高度跳变。
- [x] 证明 Stage27 / Stage30 body 的 `final_ready=false` 是已记录技术候选边界，不冒充 release-ready。
- [x] 新增回归测试：未登记 / 被禁用 live body、缺少模型锁 metadata、Seal Guardian idle 混用旧资产时失败。

## 2. 通用契约与生成器

- [x] 新增 `docs/assets/character-creature-model-locks.json`，登记 8 个模型族及全部 active / rejected body 证据。
- [x] 新增共享 Python contract helper，把清单模型锁写入 frames/source metadata。
- [x] 修改 Luna、Stage17 split / 派生、Stage27、Stage30 和通用 runtime candidate 生成器，确保重建不擦除 metadata。
- [x] 在不重绘图片的前提下刷新现有 `52` 份 metadata；复跑为 `metadata_changed=0`。
- [x] Python `py_compile`、metadata 一致性和旧动作审计兼容通过；当前环境未安装 `ruff`，未伪称执行。

## 3. 严格审计与接触表

- [x] 新增通用严格审计：canonical、cell、center、root、scale sample、active status、live binding policy。
- [x] 新增接触表生成器，分别输出 Luna、四类旧敌人、Seal Guardian、雷蚀獠、夔影雷骸报告和 PNG。
- [x] 生成总报告，`family_count=8`、`asset_count=26`、自动几何失败 `0`。
- [x] 使用 `view_image` 逐张复核，不把代理目检写成人类最终签核。

## 4. 生产绑定修复

- [x] Seal Guardian idle 退出旧 `seal_guardian_idle_runtime_sheet_ai01`，统一使用 formal motion canonical body。
- [x] 保持现有攻击、VFX、伤害窗口、状态时长、Boss completion 契约不变。
- [x] 新增 GUT：所有生产 body 已登记且允许 runtime binding；未知 body 也会报红。
- [x] 新增 GUT：Seal Guardian 全状态不跨 model_id；全部 sidecar（含夔影雷骸五套 sheet）匹配各自唯一 model_id。

## 5. 文档引用与状态边界

- [x] `docs/assets/asset-manifest.md` 增加通用模型锁入口和各模型族引用。
- [x] Stage17 设计、Stage30 资产矩阵和 2026-08-08 运行态修复设计引用同一通用契约。
- [x] 明确 `geometry_lock_ready / runtime_binding_allowed / identity_review_status / final_ready` 的区别。
- [x] 更新 `docs/progress/status.md`、`timeline.md` 和 `logs/2026-08-09.md`。

## 6. 验证

- [x] Python compile；`ruff` 在当前环境不可用，已记录而非跳过不报。
- [x] 通用模型锁 strict audit；旧动作候选 strict 与综合资产包 strict 同步通过。
- [x] 邻近 GUT：模型锁、Stage15、Stage17、Stage27、Stage30。
- [x] Godot `4.6.3` import 与主场景 smoke。
- [x] 递归全量 GUT：`51` scripts、`338/338` tests、`9990` assertions。
- [x] `git diff --check` 无 whitespace error；保留既有 dirty worktree、CRLF 提示、UID duplicate 与 ObjectDB warning。

## 人工边界

- [ ] Gate26H 真人确认 Luna、Seal Guardian、雷蚀獠、夔影雷骸的脸 / 头部、甲胄、肢体、轮廓、动作重量和阶段变化后，才将 `identity_review_status` 更新为 `approved`。
- [ ] 授权和 external release 仍以 `final_ready` 为准；本轮不擅自批准。

## 7. 复核后重新打开的遗留闭环

> 2026-08-09 收口结论：以下遗留项已全部形成机器契约、反向扫描、真实窗口证据和文档互引；本专项技术 Goal 可以关闭，但 Gate26H 与 external-release 仍保持开放。

- [x] 中央契约与全部 active sidecar 增加可审计 `identity_lock_ready`；它不替代 `identity_review_status` 或 `final_ready`。
- [x] 八族声明头顶、髋部或身体核心、脚底、根节点、前后关键轮廓语义锚点搜索区和容差。
- [x] 通用 strict audit 验证语义落点、拓扑、root 接触与 canonical 偏差；增强八张接触表显示所有锚点。
- [x] GUT 从全量生产 `scripts/` / `scenes/` 反向扫描 body，显式排除 dev / test 证据，不再只扫描五个子目录。
- [x] Seal Guardian 与夔影雷骸分别输出本轮新鲜的真实窗口全状态连续性 JSON、逐状态截图和汇总报告。
- [x] `asset-manifest`、Stage17、Stage30 与 `final-art-acceptance-gates.json` 双向引用中央契约。
- [x] Python lint / compile、strict audits、Godot import / smoke、专项与邻近 GUT、递归 GUT、MCP 运行态复核及 diff 门禁通过。
- [x] 更新 status、timeline、当日日志；继续保留 Gate26H 与 external-release 人工阻断。
