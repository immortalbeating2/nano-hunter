# ImageGen Gallery Render Smoke

Date: 2026-06-20

## Summary

新增一个 Godot 可见渲染烟测入口，用于证明 `scenes/dev/imagegen_asset_gallery.tscn` 不只是可加载资源集合，也能在真实渲染器下打开并渲染出非空画面。本步骤继续服务 image gen 资产包的 Godot 编辑器可用性验证。

## Goals

- 新增 `scripts/dev/capture_imagegen_asset_gallery.gd`。
- 使用非 headless OpenGL 渲染器打开 Gallery。
- 保存本地截图到 `tests/artifacts/local/imagegen_asset_gallery/gallery_viewport.png`。
- 保存采样分析报告到 `tests/artifacts/local/imagegen_asset_gallery/gallery_viewport_report.json`。
- 检查截图非空、非单色，并有足够颜色变化。

## Non-Goals

- 不提交本地截图证据。
- 不判断最终美术质量。
- 不判断运行时引用替换、TileSet collision、NinePatch 最终边界、VFX 锚点或 Spine rig。
- 不替代 `audit_imagegen_asset_gallery.gd` 的资源加载审计。

## Commands

```powershell
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_imagegen_asset_gallery.gd
```

不要用 `--headless` 执行该截图脚本；headless dummy 渲染器没有可读取的 viewport texture，会返回空图。

## Current Evidence

2026-06-20 本地验证结果：

- 截图：`tests/artifacts/local/imagegen_asset_gallery/gallery_viewport.png`
- 报告：`tests/artifacts/local/imagegen_asset_gallery/gallery_viewport_report.json`
- `ok`: `true`
- samples: `3600`
- non_transparent_ratio: `1.0`
- varied_color_buckets: `85`
- 阈值：`min_non_transparent_ratio=0.2`、`min_varied_color_buckets=32`

## Exit Criteria

- 脚本退出码为 `0`。
- 报告 `ok=true`。
- 截图路径存在，且报告显示非透明采样和颜色变化超过阈值。
- 文档明确该验证只证明 Gallery 画面非空，不证明最终美术或运行时集成。

## Risks

- 该脚本依赖可用图形渲染器；纯 CI / headless 环境可能不能运行。
- 本地截图默认被 `.gitignore` 忽略，后续 session 需要重新运行命令获取本机证据。
- 截图只覆盖 Gallery 当前视口顶部，不能替代逐资产人工清稿和运行态复核。
