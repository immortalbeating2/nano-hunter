# Nano Hunter Asset Storage Policy

Last Updated: 2026-06-21

## 使用范围

本文件规定 `Nano Hunter` 资产在 Git、Git LFS、外部资产库和 Godot 项目目录之间的存放边界。它不替代 `asset-manifest.md`，而是回答“哪些文件应该进入仓库，哪些文件只做本地或外部资产库保存”。

资产生产作为长期并行的 `Asset Production Track / 资产生产线` 运行，不单独替代玩法 Stage。每个玩法 Stage 仍先用灰盒或占位资产验证玩法，再按资产 Batch 同步生成、筛选和接入。

## 存储分层

| 层级 | 内容 | 默认位置 | Git 策略 | 备注 |
| --- | --- | --- | --- | --- |
| 可运行资产 | Godot 当前会加载的小体积 PNG、SVG、OGG、TRES、TSCN、`.import` | `assets/art/`、`assets/audio/`、`assets/configs/` | 普通提交 | clone 后应能运行 demo |
| 资产文档 | 清单、生成 brief、接入 checklist、存储策略、批次路线图 | `docs/assets/` | 普通提交 | 所有来源、授权和状态在这里留痕 |
| AI 原始候选 | 批量候选图、失败稿、未清理版本 | `assets/source/ai_generated/` 或外部资产库 | 默认不普通提交 | 只保留 `.gitkeep`，必要时用外部资产库链接 |
| Image gen 手动保存入口 | 从 Codex Desktop 下载 / 另存、尚未归入具体 Batch 的会话预览图 | `assets/source/imagegen_inbox/` | 默认不普通提交 | 只保留 `.gitkeep`；确认 asset id 后用导入脚本复制到 `assets/source/ai_generated/` |
| 可编辑源文件 | PSD、KRA、ASE、ASEPRITE、BLEND、分轨音频工程 | `assets/source/editable/` 或外部资产库 | 默认不普通提交 | 真正需要随项目走时再评估 Git LFS |
| 参考与授权证据 | 参考图、购买资产原包、授权截图、发票、下载记录 | `assets/source/references/` 或外部资产库 | 默认不普通提交 | `asset-manifest.md` 记录来源摘要和授权状态 |
| 大体积交付物 | 高分辨率图、长音频、视频、trailer 草案 | 外部资产库或 Git LFS | 默认不普通提交 | 不让普通 Git 历史膨胀 |

## Git 与 Git LFS 规则

- 普通 Git 只承载“项目运行需要的小体积资产”和“资产治理文档”。
- 单个资产文件小于 `10 MB` 且用于当前 demo 运行时，可以普通提交。
- 单个资产文件 `10-50 MB` 时，优先压缩或降规格；确需随版本走再评估 Git LFS。
- 单个资产文件超过 `50 MB` 时，不普通提交；使用 Git LFS 或外部资产库。
- AI 原始候选、失败稿、源文件、授权截图和购买资产原包默认不进入普通 Git。
- Godot 生成的 `.import` 文件应随可运行资产提交；`.godot/` 缓存不提交。

## 外部资产库规则

外部资产库可以是本地同步盘、NAS、云盘、专用素材库或后续 Git LFS 存储。建议结构：

```text
NanoHunterAssets/
  batch_00_style_lock/
  batch_01_playability_p0/
  batch_02_stage16_ui_feedback/
  batch_03_environment_pass/
  batch_04_audio/
  batch_05_animation_reference/
  licenses/
  references/
```

每个批次应保存原始 prompt、生成工具和账号 / 计划信息、候选文件、入选版本、淘汰原因、授权条款截图或导出记录，以及最终导入 Godot 的文件名和仓库目标路径。

## AI 生成资产留痕

每个进入 `asset-manifest.md` 的 AI 资产必须记录：

- `Project Key`，当前项目固定为 `nano-hunter`
- `Batch ID`
- `Asset ID`
- 目标用途
- 目标路径
- 生成工具
- prompt 摘要或 prompt 文件位置
- 授权状态
- 当前状态：`needed`、`placeholder_ready`、`integrated`、`deferred`
- 接入阶段或关联 Stage
- 替换优先级

如果授权状态尚未确认，写 `License pending - tool terms must be recorded before integration`，不要留空。

## 多项目来源门禁

用户可能同时推进多个 Godot / 工具项目，因此 Nano Hunter 不能从 Codex Desktop 的全局 image_gen 输出目录里按“最新图片”直接取图。所有进入 `assets/art/`、Godot 场景或运行时目录的 image_gen 资产，必须先满足：

- provenance 记录顶层 `project_key` 为 `nano-hunter`。
- 每条资产 provenance 记录的 `project_key` 为 `nano-hunter`。
- 候选 PNG 位于当前仓库 `assets/source/ai_generated/` 下，且记录在 `docs/assets/asset-provenance-records.json`。
- `scripts/assets/audit_asset_provenance.py --strict` 通过。
- `scripts/assets/audit_imagegen_source_safety.py --write-report --strict` 通过，且 `unknown_or_unsafe` 为 `0`。

`project_session_confirmed` 候选可优先进入 Godot preview / runtime binding；`explicit_mapping_review_required` 和 `workspace_provenance_recorded_review_required` 只能作为 review 候选，除非另有人工确认，不应声明为最终资产或直接替换核心运行时表现。

任何没有 `project_key=nano-hunter`、缺少 hash、缺少 prompt、缺少候选路径、或来自其它项目路径的图片，都只能放入隔离 review，不得进入正式资产目录。

## Godot 插件边界

- Godot 插件只负责导入、预览、测试和接入效率，不承担完整资产生产。
- 短期默认只启用 `godot_mcp` 与 `gut`。
- `AsepriteWizard` 只在正式采用 Aseprite / `.aseprite` 动画源时再启用。
- 音频裁剪、降噪、响度统一和 BGM loop 仍在 Audacity / Reaper 等外部工具完成。
- SVG 图标、符印和 UI 图案仍在 Inkscape / Krita 等外部工具清稿，Godot 只做导入和显示验证。

## 提交流程

1. 在 `asset-manifest.md` 登记需求与来源状态。
2. 在外部资产库或 `assets/source/` 生成和筛选候选。
3. 只将清理后的可接入版本放入 `assets/art/` 或 `assets/audio/`。
4. 运行 `godot --headless --path . --import` 生成并验证 `.import`。
5. 如果资产接入场景、HUD 或音频播放，按 `asset-ingestion-checklist.md` 复核。
6. 在当日日志记录资产范围、来源、验证、风险和下一步。
