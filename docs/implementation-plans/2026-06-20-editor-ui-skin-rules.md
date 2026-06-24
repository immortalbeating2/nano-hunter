# Editor UI Skin Rules Plan

## Summary

把 Batch08 `menu_ninepatch_ui_ai01` 的 `StyleBoxTexture` 候选继续推进为 Godot `Theme` 候选，并为 Stage16 pause / completion panel、Stage15 Boss HUD frame、Stage14 ability status HUD 生成第一版 UI 接入规则。目标是让 UI 类资产从“可加载九宫格资源”前进到“有 Theme 映射和 text-safe area 规则”，但不直接替换 DemoShell 或 HUD 运行时引用。

## Scope

- 新增 Godot editor script：
  - `scripts/dev/build_editor_ui_skin.gd`
  - `scripts/dev/audit_editor_ui_skin.gd`
- 输出：
  - `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres`
  - `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`
- 审计覆盖：
  - `scripts/assets/audit_asset_package.py`
  - `scripts/assets/audit_art_readiness.py`

## Key Changes

- 将 `menu_ninepatch_ui_ai01` 的 `8` 个 `StyleBoxTexture` 映射到 Godot `Theme` 候选：
  - `PanelContainer/panel`
  - `Button/normal`
  - `Button/hover`
  - `Button/pressed`
  - `Button/disabled`
  - `PopupPanel/panel`
  - `TooltipPanel/panel`
  - `AcceptDialog/panel`
- 为 `4` 张 standalone UI / HUD PNG 记录保守 text-safe area、推荐 Control 类型、最小运行时尺寸和人工复核 note。
- 综合资产包审计新增 UI skin 检查：Theme、rules、`8` 个 stylebox mappings、`4` 个 standalone panel rules。
- Art readiness 把 UI 类 blocker 从“未建立 Theme / text-safe 规则”推进为 manual review：
  - `theme_mapping_manual_review`
  - `text_safe_area_manual_review`
  - `final_ninepatch_margin_manual_review`
  - `stretch_distortion_manual_review`
  - `runtime_layout_manual_review`

## Non-Goals

- 不替换 `DemoShell`、Stage15 Boss HUD 或 Stage14 ability HUD 的运行时引用。
- 不声称 UI 最终清稿完成。
- 不处理伪文字、线宽统一、真实按钮布局、键鼠 / 手柄提示或动态本地化文本。
- 不启用新的 Godot UI 插件。

## Validation

```powershell
python -m py_compile scripts\assets\audit_art_readiness.py scripts\assets\audit_asset_package.py scripts\assets\validate_asset_production_queue.py scripts\assets\audit_asset_target_coverage.py
godot --headless --path . --script res://scripts/dev/build_editor_ui_skin.gd
godot --headless --path . --script res://scripts/dev/audit_editor_ui_skin.gd
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
git diff --check
```

## Exit Criteria

- Godot 能生成并加载 `nano_hunter_imagegen_ui.theme.tres`。
- UI skin rules 包含 `8` 个 Theme stylebox mappings 和 `4` 个 standalone panel rules。
- `asset-package-audit-report.json` 记录 UI skin `present=true`、`missing=[]`。
- `art-readiness-audit-report.json` 对相关 UI 条目记录 `ui_skin_rules`，但 `final_ready_count` 仍保持 `0`。

## Boundary

当前 UI skin 是 `placeholder_ready` editor candidate。它证明 UI 资源已经具备 Theme 映射入口和 text-safe area 规则入口，不证明最终 UI 美术、拉伸表现、运行时布局、文本可读性或正式 HUD / 菜单替换已经完成。
