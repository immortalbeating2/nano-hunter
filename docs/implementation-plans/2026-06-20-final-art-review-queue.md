# Final Art Review Queue

## Summary

将 `art-readiness-audit-report.json` 中分散的 `polish_blockers` 转换为可逐项勾选的最终美术复核队列。该队列覆盖 `55` 个 image gen 资产，按 family / priority / blocker / next action 组织后续清稿、授权、运行时替换和 Godot 复核任务。

## Scope

- 新增最终美术复核队列 JSON 与 Markdown。
- 新增构建 / 审计脚本。
- 接入综合资产包审计。
- 不生成新图，不重建 atlas，不替换运行时引用。

## Key Changes

- 新增 `scripts/assets/build_final_art_review_queue.py`。
- 新增 `scripts/assets/audit_final_art_review_queue.py`。
- 新增 `docs/assets/final-art-review-queue.json`。
- 新增 `docs/assets/final-art-review-queue.md`。
- `scripts/assets/audit_asset_package.py` 纳入 `55` 条 final-art review entries。

## Validation

```powershell
python -m py_compile scripts\assets\build_final_art_review_queue.py scripts\assets\audit_final_art_review_queue.py scripts\assets\audit_asset_package.py
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\audit_final_art_review_queue.py --strict
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Exit Criteria

- 复核队列包含 `55` 个资产。
- `55` 个资产都有 blockers 与 next actions。
- `final_ready_count=0` 被明确保留，不误标完成。
- 综合资产包审计输出 `55 final-art review entries`。

## Boundary

本步骤只是把最终美术审批与接入工作拆成可追踪任务；它不代表任何资产已经最终清稿、授权审批通过或完成运行时替换。
