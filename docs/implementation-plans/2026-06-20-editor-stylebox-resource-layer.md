# Editor StyleBoxTexture Resource Layer

Date: 2026-06-20

## Summary

把 `menu_ninepatch_ui_ai01` 九宫格 sheet 从 PNG + regions JSON 推进为 Godot 可加载的 `StyleBoxTexture` 候选资源。该步骤服务于后续 Theme、PanelContainer、Button 或 NinePatch UI polish，不替换运行时 UI 引用。

## Goals

- 为 `menu_ninepatch_ui_ai01` 的 `8` 个 region 生成 `StyleBoxTexture` `.tres`。
- 为每个 StyleBox 绑定原始 atlas texture、region rect 和保守九切 margin。
- 提供 Godot headless 审计脚本，验证资源类型、texture、region 和 margin。

## Non-Goals

- 不声明当前九切边界已经最终可用。
- 不替换 DemoShell、pause panel、completion panel、HUD 或 Boss HUD 的运行时样式。
- 不配置 Theme、不修改场景节点、不调整字体或布局。
- 不处理伪文字、线宽、UI 小尺寸读值或 mask 清稿。

## Key Changes

- 新增 `scripts/dev/build_editor_styleboxes.gd`。
- 新增 `scripts/dev/audit_editor_styleboxes.gd`。
- 新增输出目录 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/`。
- 生成 `8` 个 `*.stylebox_texture.tres`。
- 生成索引 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json`。

## Commands

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
godot --headless --path . --import
```

Recommended full validation after this step:

```powershell
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\audit_asset_target_coverage.py --strict
python scripts\assets\audit_editor_atlas_textures.py --strict
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `8` 个 `StyleBoxTexture` `.tres` 存在于 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/`。
- Godot headless 审计输出 `Editor StyleBoxTexture resources OK: 8`。
- 现有 atlas target-count、AtlasTexture、TileSet 审计仍通过。
- Godot import 仍通过。
- 文档明确记录当前边界：这是九宫格候选资源，不是最终 UI polish 或 runtime integration。

## Risks

- 当前 margin 使用保守 `24px`，后续正式 UI 接入时仍需按每个面板边框重新微调。
- 自动生成的 source art 仍可能含伪文字、边缘污染或风格不统一，需要清稿。
- 正式接入前必须做 UI 小尺寸读值、拉伸失真、文字安全区和运行态截图复核。
