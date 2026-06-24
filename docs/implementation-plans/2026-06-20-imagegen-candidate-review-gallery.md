# ImageGen Candidate Review Gallery Implementation Plan

Date: 2026-06-20

## Summary

为本轮从 Codex Desktop 默认生成图目录恢复出的 raw image gen candidates 增加 Godot 编辑器内评审入口。该计划只处理候选复核展示，不把候选自动提升为 selected source，不重建 `assets/art/`，不替换运行时引用。

## Goals

- 读取 `docs/assets/imagegen-candidate-pool-report.json` 中的 unselected candidates。
- 生成 Godot 可打开的候选评审场景。
- 为每张未选候选图保留 asset id、batch、候选编号和 texture 绑定。
- 将候选评审场景纳入综合资产包审计，避免后续 session 只看文件存在而误判状态。

## Non-Goals

- 不进行人工选图结论。
- 不执行 `prepare_selected_sources.py` 或 `build_asset_atlases.py`。
- 不改变 `assets/art/` 当前输出。
- 不改变任何 `final_ready`、`integrated` 或 runtime 引用状态。

## Key Changes

- 新增 `scripts/dev/build_imagegen_candidate_review_gallery.gd`。
- 新增 `scripts/dev/audit_imagegen_candidate_review_gallery.gd`。
- 生成 `scenes/dev/imagegen_candidate_review_gallery.tscn`。
- 生成 `docs/assets/imagegen-candidate-review-gallery-manifest.json`。
- 扩展 `scripts/assets/audit_asset_package.py`，交叉校验候选池报告和候选评审 Gallery manifest。

## Validation

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_candidate_review_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd
python scripts\assets\audit_asset_package.py --strict --write-report
```

当前结果：

- `Imagegen candidate review gallery OK: 72 candidates, 53 assets`
- `Asset package audit OK`，并记录 `72 unselected candidates, 72 candidate review cards`

## Exit Criteria

- 候选评审 Gallery manifest 存在。
- Gallery 场景存在并能由 Godot headless 加载。
- Gallery 卡片数与候选池报告中的 `unselected_candidate_count` 一致。
- Gallery 资产数与候选池报告中的 `review_required_item_count` 一致。
- 综合资产包审计通过。

## Risks / Follow-Up

- 这只是审图入口，不代表候选质量通过。
- 后续如果人工选中候选，需要按 asset id 单独运行 selected source 准备、atlas rebuild、art readiness、asset package audit 和对应 Godot 接入复核。
