# Final Art Review Workbench Implementation Plan

## Summary

把 `docs/assets/final-art-review-queue.json` 中的 `55` 个最终美术复核任务转换为 Godot 编辑器可打开的审图 Workbench，方便按 priority / family 扫图、查看 blockers 和下一步动作。

本计划只补复核入口，不批准最终美术，不改变运行时引用，不替换玩法场景资源。

## Scope

- 新增 Godot 生成脚本：`scripts/dev/build_final_art_review_workbench.gd`
- 新增 Godot 审计脚本：`scripts/dev/audit_final_art_review_workbench.gd`
- 生成审图场景：`scenes/dev/final_art_review_workbench.tscn`
- 生成 manifest：`docs/assets/final-art-review-workbench-manifest.json`
- 扩展综合资产包审计：`scripts/assets/audit_asset_package.py`
- 更新资产矩阵、status、timeline 和当日日志

## Workbench Rules

- Workbench 必须包含全部 `55` 个 final-art review entries。
- 卡片默认按 `P0`、`P1`、`P2` 排序，并在每个 priority 下按 family 分组。
- 每张卡必须展示 asset id、target kind、review status、blocker count、预览图、主要 blockers、主要 next actions 和资源路径。
- 每张卡必须带 Godot metadata，供审计脚本统计和验证。
- Manifest 必须显式记录 `55 manual-review assets` 与 `0 final-ready assets`。

## Verification

```powershell
godot --headless --path . --script res://scripts/dev/build_final_art_review_workbench.gd
godot --headless --path . --script res://scripts/dev/audit_final_art_review_workbench.gd
python -m py_compile scripts\assets\audit_asset_package.py
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Godot build 写出 Workbench scene 和 manifest。
- Godot audit 输出 `55 cards, 55 manual-review assets, 0 final-ready assets`。
- 综合资产包审计纳入 `55 final-art workbench cards`。
- 文档明确 Workbench 是复核入口，不代表最终美术、授权、运行时替换或玩法读值完成。

## Risks

- Workbench 只能证明 Godot 能加载当前输出 PNG，不能证明图片质量、版权条款、动画帧序、NinePatch 边界或运行时表现。
- 多项目并行时不得用全局 `.codex/generated_images` 的最新 PNG 自动补 Workbench 来源。
