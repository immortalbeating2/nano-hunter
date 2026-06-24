# Background Alpha Policy

## Summary

为背景类、宣传类、CG 和分镜类 image gen 输出补充 alpha 通道处理策略。目标不是覆盖原图或批准最终美术，而是把 `background_asset_contains_alpha` 从未解释 warning 推进为可审计的人工复核项。

## Scope

- 读取 `docs/assets/art-readiness-audit-report.json` 中带 `background_asset_contains_alpha` warning 的资产。
- 对 tile / atlas 类透明边界记录为可保留 alpha 的编辑器 padding。
- 对 promo / CG / storyboard 类生成 opaque preview，供发布和叙事复核。
- 接入 `audit_art_readiness.py` 与 `audit_asset_package.py`。

## Key Changes

- 新增 `scripts/assets/build_background_alpha_policy.py`。
- 新增 `scripts/assets/audit_background_alpha_policy.py`。
- 新增 `docs/assets/background-alpha-policy-report.json`。
- 新增 `6` 张 opaque preview：
  - `assets/art/promo/opaque_previews/`
  - `assets/art/storyboards/opaque_previews/`
- `audit_art_readiness.py` 将已记录 policy 的背景 alpha 从 warning 转为：
  - `alpha_padding_policy_manual_review`
  - `opaque_preview_manual_review`
- `audit_asset_package.py` 纳入 `11` 条 background alpha policy。

## Validation

```powershell
python -m py_compile scripts\assets\build_background_alpha_policy.py scripts\assets\audit_background_alpha_policy.py scripts\assets\audit_art_readiness.py scripts\assets\audit_asset_package.py
python scripts\assets\build_background_alpha_policy.py
python scripts\assets\audit_background_alpha_policy.py --strict
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `background_asset_contains_alpha` warning 清零。
- `alpha_padding_policy_manual_review=5`。
- `opaque_preview_manual_review=6`。
- 综合资产包审计输出 `11 background alpha policies`。
- 原始 PNG 不被覆盖。

## Boundary

本步骤只证明 alpha 通道有策略记录和 opaque preview，不证明背景 / 宣传 / CG / 分镜已经完成最终构图、清稿、叙事审批或运行时接入。
