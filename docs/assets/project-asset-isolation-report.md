# Project Asset Isolation Report / 项目资产隔离报告

本报告用于防止多项目并行时把其它项目的 image_gen 输出误归属到 Nano Hunter。它只证明项目隔离，不证明最终美术质量、授权或 final-ready。

## Summary

- Status: `isolated`
- Project key: `nano-hunter`
- Scanned files: `1936`
- Forbidden project markers: `0`
- Outside absolute paths: `0`
- Project key errors: `0`

## Boundary

- 允许记录 `Documents/Codex/tools/imagegen-export` 这类导出脚本路径。
- 允许包含 `nano-hunter` 的历史或当前本地路径。
- 不允许资产记录、资产文档或资产脚本里出现其它项目标识作为来源。
- 该报告不替代 `imagegen-source-safety-report`、`runtime-source-safety-report` 或人工审图。

## Result

未发现已扫描资产记录中混入已知其它项目标识、外项目绝对路径或非 Nano Hunter `project_key`。
