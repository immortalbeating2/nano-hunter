# Spine Cutout Export Layer

Date: 2026-06-20

## Summary

把 Batch11 的 Luna 与 Seal Guardian 拆件图集，从 PNG atlas + regions JSON 推进为可交接的 Spine-style cutout 描述文件。该步骤服务于后续骨骼绑定、外部动画工具整理或 Godot cutout rig 规划，不启用 Spine 插件，不替换运行时动画。

## Goals

- 为 `luna_spine_parts_ai01` 输出 TexturePacker / Spine-style `.atlas`。
- 为 `seal_guardian_spine_parts_ai01` 输出 TexturePacker / Spine-style `.atlas`。
- 为两组拆件输出 project cutout manifest，记录 source texture、region、pivot 候选和部件数量。
- 为两组拆件输出 Spine-style skeleton JSON，作为后续手工 rigging 的描述起点。
- 提供审计脚本，验证 `.atlas`、`.spine_style.json` 和 `.cutout_manifest.json` 数量一致。

## Non-Goals

- 不生成正式 Spine 工程。
- 不声明 Spine Runtime 可直接播放。
- 不配置 bone hierarchy、IK、mesh、weights、slots 层级、pivot 精修或动画曲线。
- 不替换 Godot 运行时玩家 / Boss 动画。

## Key Changes

- 新增 `scripts/assets/build_spine_cutout_manifests.py`。
- 新增 `scripts/assets/audit_spine_cutout_manifests.py`。
- 新增输出目录 `assets/art/spine_parts/spine_exports/`。
- 输出 `2` 个拆件资产、`48` 个部件描述。

## Outputs

- `assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.atlas`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.spine_style.json`
- `assets/art/spine_parts/spine_exports/luna_spine_parts_ai01/luna_spine_parts_ai01.cutout_manifest.json`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.atlas`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.spine_style.json`
- `assets/art/spine_parts/spine_exports/seal_guardian_spine_parts_ai01/seal_guardian_spine_parts_ai01.cutout_manifest.json`

## Commands

```powershell
python scripts\assets\build_spine_cutout_manifests.py --dry-run
python scripts\assets\build_spine_cutout_manifests.py
python scripts\assets\audit_spine_cutout_manifests.py --strict
```

Recommended full validation after this step:

```powershell
python -m py_compile scripts\assets\build_spine_cutout_manifests.py scripts\assets\audit_spine_cutout_manifests.py
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\audit_asset_target_coverage.py --strict
python scripts\assets\audit_editor_atlas_textures.py --strict
python scripts\assets\audit_spine_cutout_manifests.py --strict
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `2` 个 Spine-style cutout exports 存在。
- `48` 个 part descriptors 被索引。
- 审计输出 `Audited 2 Spine-style cutout exports with 48 parts.`
- 文档明确记录当前边界：这是拆件描述与交接层，不是正式 rig 或 runtime integration。

## Risks

- 当前部件名仍来自自动拆分，缺少头、躯干、手臂、腿、链条等语义分类。
- 当前 pivot 只用 region 中心点，正式绑定前必须人工调整。
- 仍需清稿、透明边缘、遮挡重叠、左右肢体拆分和层级顺序复核。
