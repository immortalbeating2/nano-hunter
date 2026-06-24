# ImageGen Art Readiness Audit

Date: 2026-06-20

## Summary

本计划新增美术接入就绪审计层，用来区分“已经生成并能进入管线的结构性资产”和“真正可替换运行时引用的最终资产”。当前 image gen 资产已经完成落盘、图集化、editor resource 和 Godot 节点级 smoke，但还不能直接宣称最终美术完成。

## Scope

- 新增 `scripts/assets/audit_art_readiness.py`。
- 新增 `docs/assets/art-readiness-audit-report.json`。
- 扩展 `scripts/assets/audit_asset_package.py`，把 art readiness report 纳入综合资产包审计。
- 扩展 `scripts/assets/export_standalone_candidates.py`，支持 `green` 与 `magenta` 两种 chroma key 背景移除。
- 重导出 `stage15_seal_guardian_ai01`，修复洋红 chroma key 未移除导致的非透明背景问题。

## Checks

- 每个 queue 输出 PNG 是否存在。
- PNG 是否能被 Pillow 打开。
- 图片尺寸是否有效。
- 是否存在不透明 chroma key 残留。
- 期望透明背景的资产是否检测到 alpha。
- atlas-linked 输出的 metadata region count 是否匹配 `expected_target`。
- 每个资产仍需哪些人工 polish blocker，包含授权记录、运行时替换、清稿、锚点、帧序、TileSet collision、NinePatch margin、Theme、Spine rig 和玩法读值复核。

## Boundary

- `structural_ready` 只代表资产文件和元数据能进入当前管线。
- `final_ready` 只有在授权记录、人工清稿、语义命名、运行时替换和玩法读值复核都完成后才可为 true。
- 当前报告不会把任何资产自动升级为 `integrated`。

## Commands

```powershell
python scripts/assets/audit_art_readiness.py --strict --write-report
python scripts/assets/audit_asset_package.py --strict --write-report
```

## Current Result

2026-06-20 当前结果：

- `55/55` queue outputs are `structural_ready`。
- `0/55` queue outputs are `final_ready`。
- `errors=[]`。
- `alpha_expected_but_not_detected` 已通过重导出 `stage15_seal_guardian_ai01` 清零。
- 剩余 warnings 为 `background_asset_contains_alpha`，主要集中在 tile、texture、promo、CG 和 storyboard 类输出，作为后续清稿提示，不阻断结构性使用。

## Next Steps

- 按 blocker 类型拆下一轮清稿：Luna / Boss 帧序与锚点、UI 小尺寸读值、NinePatch margin、TileSet collision / terrain、VFX mask / anchor、Spine part pivot / layer order。
- 每完成一个运行时替换包，再把对应资产从 `placeholder_ready` 推进到 `integrated`，并记录验证证据。
