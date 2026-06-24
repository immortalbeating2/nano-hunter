# Imagegen Import Safety Guard

## Summary

多项目并行开发时，`C:\Users\peng8\.codex\generated_images` 会混合多个 Codex session 的输出。Nano Hunter 资产导入不能再依赖“全局最新 PNG”推断项目归属。本次补一个轻量安全护栏，防止跨项目 image gen 图像误入 `assets/source/ai_generated/`。

## Scope

- 加固 `scripts/assets/import_imagegen_outputs.py`。
- 补充 image gen 恢复日志和资产矩阵中的安全边界。
- 不生成新资产，不重建 atlas，不替换 `assets/art/`，不修改运行时场景引用。

## Key Changes

- `--copy-latest` 仍可用于扫描后的便捷导入，但当最新文件来自全局 `CODEX_HOME/generated_images` 时默认拒绝。
- 新增 `--allow-global-latest`，只允许在人工确认图片确实属于 Nano Hunter 后使用。
- 推荐默认路径改为：
  - 明确 `--source <inspected png>`。
  - 或使用 `Export-NanoHunterImageGenResults.ps1` 从明确 session JSONL 恢复。
  - 或使用带 `image_id -> batch / asset_id` 的 import map。

## Validation

```powershell
python -m py_compile scripts\assets\import_imagegen_outputs.py
python scripts\assets\import_imagegen_outputs.py --copy-latest --batch 06 --asset-id luna_run_sheet_ai01
python scripts\assets\import_imagegen_outputs.py --source <known-png> --batch 06 --asset-id luna_run_sheet_ai01 --dry-run
```

## Exit Criteria

- 全局最新图导入在未显式确认时被阻止。
- 显式 `--source` dry-run 仍能给出目标路径。
- 文档明确多项目并行的归属校验规则。
