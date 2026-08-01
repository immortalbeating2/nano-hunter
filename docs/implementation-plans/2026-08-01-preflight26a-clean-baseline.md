# Preflight26A 可审计开发基线执行清单

## 入口与归属

- [x] 北极星差距、资产差距与总路线已形成事实基线。
- [x] 正式计划：`plan/2026-08-01-preflight26a-clean-baseline.md`。
- [x] 记录当前 branch / HEAD / tracked / untracked / ignored 证据。
- [x] 将地形对齐、路线文档、个人配置 / 候选资产和未知文件分组；不触碰归属不明文件。
- [x] 地形视觉 / 碰撞批次取得新鲜专项、全量、import、smoke 与 diff 证据并确定检查点归属。

## 资产治理

- [x] 确认 `stage19_discovery_map_base_ai01` 的真实运行引用与唯一资产 ID。
- [x] 补齐 runtime integration map、readiness 与 acceptance 边界。
- [x] strict readiness / package / runtime-map / acceptance 对同一集合全部通过。

## 基线验证与收口

- [x] Stage21-26 相邻组合与递归 GUT 通过。
- [x] Godot import、主场景 smoke 与 `git diff --check` 通过；编辑器连接后的错误复核进入 Gate26M。
- [x] Godot MCP workspace 正确，临时 autoload 为零；保留当前会话 bridge，不误杀其他进程。
- [x] 状态、时间线和当日日志记录 Stage27 起点提交与保留现场。

## 完成证据

- 技术基线提交：`eb98e47`（`固定 Stage27 前技术基线 / Freeze pre-Stage27 technical baseline`）。
- 地形专项：`16/16` tests、`1358` assertions；相邻组合：`97/97` tests、`1864` assertions。
- 递归 GUT：`43` scripts、`301/301` tests、`8542` assertions；Godot `4.6.3` import 与主场景 smoke 通过。
- 资产集合统一为 `56`：runtime map `56/56`、structural-ready `56/56`、final-ready `55/56`；唯一人工阻断仍是 `stage19_discovery_map_base_ai01` 的许可、小尺寸、文字安全区和运行布局签核。
- 发现 `docs/assets/asset-manifest.md` 为全 NUL 损坏文件；原样备份到 ignored 的 `tests/artifacts/local/preflight26a/asset-manifest.corrupt-zero.bin`，再从 HEAD 精确恢复，没有覆盖可恢复的用户文本。
- 明确保留且未提交：`.codex/config.toml`、`AGENTS - reference.md`、`assets/source/imagegen_inbox/`、`backend/`、`docs/progress/logs/2026-06-26.md` 与 `player_placeholder.tscn`。
