# Batch 08 Supplemental UI Panels

## Summary

本计划补齐 Batch 08 中缺少的具体 UI 面板与 HUD 状态源图，服务 Alpha Demo 的暂停、完成反馈、Boss 状态和能力状态表现。它延续现有 UI / Icon Atlas 管线，但本轮只生成 standalone PNG 候选，不替换运行时 HUD 或菜单引用。

## Scope

- `stage16_pause_panel_ui_ai01`
- `stage16_completion_panel_ui_ai01`
- `stage15_boss_hud_frame_ai01`
- `stage14_ability_status_hud_ai01`

## Output Targets

- `assets/art/ui/stage16_pause_panel_ui_ai01.png`
- `assets/art/ui/stage16_completion_panel_ui_ai01.png`
- `assets/art/ui/stage15_boss_hud_frame_ai01.png`
- `assets/art/ui/stage14_ability_status_hud_ai01.png`

## Generation Method

- 使用 Codex 内置 `image_gen`，每个 UI 源图单独生成一张候选。
- 使用平整 `#00ff00` chroma-key 背景，导出时由 `scripts/assets/export_standalone_candidates.py` 转透明。
- 默认从 `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613` 复制生成结果。
- 原始候选放入 `assets/source/ai_generated/batch_08/<asset_id>/candidates/<asset_id>_candidate_01.png`。

## Verification

- `python scripts\assets\validate_asset_production_queue.py`
- `python scripts\assets\export_standalone_candidates.py --only <asset_id> --overwrite`
- `godot --headless --path . --import`
- `git diff --check`

## Exit Criteria

- 四个 asset 均有 source candidate。
- 四个 asset 均有 `assets/art` PNG 和 Godot `.import`。
- Godot import 退出码为 `0`。
- 文档记录保持 `placeholder_ready`，不标记为 `integrated`。

## Result

- 已生成并落盘 `4/4` 个 source candidate。
- 已导出 `4/4` 个 `assets/art/ui/*.png`，并由 Godot import 生成对应 `.import`。
- `validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs。
- `godot --headless --path . --import` 退出码为 `0`。
- 透明度检查确认四张 UI PNG 角落 alpha 为 `0`，opaque green pixels 为 `0`。
- 当前状态保持 `placeholder_ready`，未替换运行时 UI 引用。

## Non-Goals

- 不替换 `DemoShell`、HUD、暂停菜单或完成反馈场景引用。
- 不承诺最终 UI 排版、字体、NinePatch 切边或小尺寸读值。
- 不引入新的 UI 系统或 Godot 插件。
