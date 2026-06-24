# ImageGen Source Safety Audit

## Summary

多项目并行开发时，Codex Desktop 的全局 `generated_images` 目录可能同时包含多个项目输出。本轮新增 Nano Hunter 专用 source safety audit，把 `101` 个 image_gen raw candidates 按项目 session、recovery ledger、provenance 和项目路径边界分类，防止后续补齐美术资产时把其它项目图像误接入当前资产生产线。

## Scope

- 新增 `scripts/assets/audit_imagegen_source_safety.py`。
- 新增 `docs/assets/imagegen-source-safety-report.json`。
- 扩展 `scripts/assets/audit_asset_package.py`，把 source safety 纳入综合资产包审计。
- 更新资产矩阵、生产 backlog、进度日志和 timeline。
- 不生成新图、不移动候选、不重建 atlas、不替换场景引用。

## Key Changes

- 将候选图分为：
  - `project_session_confirmed`
  - `explicit_mapping_confirmed`
  - `explicit_mapping_review_required`
  - `workspace_provenance_recorded_review_required`
  - `unknown_or_unsafe`
- 严格失败条件只针对真正不安全的候选：
  - 缺 provenance 记录。
  - 候选路径不在 `assets/source/ai_generated/`。
  - 输出路径不在 `assets/art/`。
  - prompt 缺 Nano Hunter 风格 / 项目锚点。
  - 候选文件缺失或未被 provenance candidate hashes 覆盖。
- `review_required` 候选保留在候选池中，但不能直接视为最终选中、清稿、运行时接入或授权完成。

## Validation

```powershell
python -m py_compile scripts\assets\audit_imagegen_source_safety.py scripts\assets\audit_asset_package.py
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Result

- Source safety audit：`101` candidates。
- `33` 个 `project_session_confirmed`。
- `30` 个 `explicit_mapping_review_required`。
- `38` 个 `workspace_provenance_recorded_review_required`。
- `0` 个 `unknown_or_unsafe`。
- 综合资产包审计通过，并纳入 `0 unsafe source candidates`。

## Exit Criteria

- 后续继续 image_gen 批次生产或候选导入前，必须保持 `unknown_or_unsafe = 0`。
- 如果出现 unsafe candidate，先处理来源边界，再进入 selected source、atlas rebuild 或 runtime replacement。
- 该审计只证明跨项目来源风险受控，不证明最终美术质量、商业授权、清稿或 Godot 运行时替换完成。
