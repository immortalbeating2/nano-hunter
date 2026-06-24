# Runtime Source Regeneration Landing Audit / 运行时重生图落盘审计

## Summary

为 `runtime-source-regeneration-packet` 对应的 7 个 Nano Hunter 专属重生图候选新增落盘审计。该层只检查 PNG 是否真实落到指定候选路径、是否保持为项目内候选文件、以及是否避免覆盖 `assets/art/` 正式输出。

## Scope

- 新增 `scripts/assets/audit_runtime_source_regeneration_landing.py`。
- 生成 `docs/assets/runtime-source-regeneration-landing-report.json`。
- 生成 `docs/assets/runtime-source-regeneration-landing-report.md`。
- 扩展 `scripts/assets/audit_asset_package.py` 纳入 landing gate。

## Non-Goals

- 不生成或编辑 PNG。
- 不替换 selected source。
- 不判定 final-ready。
- 不做美术质量或授权判断。

## Rules

- 重生图必须落在 `docs/assets/runtime-source-regeneration-packet.json` 指定的 `assets/source/ai_generated/.../candidates/` 目标。
- 允许暂时 `pending`，但不能误落入 `assets/art/`。
- 只接受 PNG。
- 扫到 `invalid` 时必须先修正路径或导入流程，再继续来源复核。

## Verification

```powershell
python scripts\assets\audit_runtime_source_regeneration_landing.py --write-report --strict
python scripts\assets\audit_asset_package.py --write-report --strict
git diff --check
```

## Exit Criteria

- 7 个重生图候选全部在落盘报告中变为 `landed`，或明确保持 `pending` 且无 `invalid`。
- 综合资产包审计将 landing gate 纳入 strict 校验。
- 不再把全局默认目录里的 PNG 误当作项目正式落盘结果。
