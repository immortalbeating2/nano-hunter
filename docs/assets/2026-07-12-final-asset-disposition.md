# Nano Hunter 最终资产处置清单

日期：2026-07-12  
状态：完成

## 处置结论

本轮不把“文件存在”“历史 Preview 绑定”或“开发画廊可见”当成正式运行接入。资产按运行职责分为四类：

| 分类 | 处置 | 当前范围 |
| --- | --- | --- |
| `runtime_keep` | 保留并纳入运行接入门禁 | runtime map 中 `26` 项；其中当前 P0 运行计划 `11` 项、`11/11` 已有正式引用 |
| `source_dev_keep` | 保留但不得计为正式运行接入 | runtime map 中 `20` 项；包括方向稿、editor 资源、source sheet 与 `scenes/dev/` 工具场景 |
| `archive_keep` | 保留作为审计和历史依据 | runtime map 中 `9` 项；包括被正式运行资源取代的旧动画 / VFX 候选 |
| `delete_after_validation` | 零引用且 import/GUT 通过后删除 | `14` 个 Stage 12/13 SVG 及 `14` 个 `.import`，本轮已删除 |

## 正式场景 Preview 处置

- 删除正式场景中隐藏的 `*Preview*` 节点；这些节点只曾用于证明“资源被场景引用”，不承担当前运行表现。
- `scenes/dev/` 下资产画廊的 Preview 节点保留，因为其职责就是开发期资产浏览。
- `stage14_air_dash_shrine_room.tscn` 中实际可见的 `GatePreviewArt` 与 `AirDashTrailPreviewArt` 不删除，分别改名为 `GateEchoArt` 与 `AirDashTrailArt`，继续承担能力门和冲刺轨迹提示。
- 清理完成后，正式场景节点名中不得再出现 `Preview`。

## 已验证并删除的旧资产

### 玩家与敌人占位轮廓

- `assets/art/characters/player/stage12_player_silhouette.svg`
- `assets/art/characters/enemies/stage12_basic_melee_silhouette.svg`
- `assets/art/characters/enemies/stage12_ground_charger_silhouette.svg`
- `assets/art/characters/enemies/stage12_aerial_sentinel_silhouette.svg`
- `assets/art/characters/enemies/stage13_miasma_caster_silhouette.svg`

### 旧 VFX 与 UI 占位

- `assets/art/vfx/stage12_slash_vfx.svg`
- `assets/art/vfx/stage12_hit_spark_vfx.svg`
- `assets/art/vfx/stage13_miasma_hazard_warning_01.svg`
- `assets/art/ui/stage12_checkpoint_gate_goal_icons.svg`

### Stage 13 旧灰盒环境与道具

- `assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_background_01.svg`
- `assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_tiles_01.svg`
- `assets/art/props/stage13_miasma_marsh_goal_device_01.svg`
- `assets/art/props/stage13_seal_gate_01.svg`
- `assets/art/props/stage13_seal_node_01.svg`

## 删除门禁与执行结果

14 个旧 SVG 仅在以下条件同轮满足后删除；本轮均已满足：

1. `scenes/`（排除 `scenes/dev/`）、`scripts/`、`tests/` 与运行资源中均无路径引用。
2. 正式场景节点名中 `Preview` 数量为 `0`。
3. Godot `--import --quit` 成功。
4. 受影响 Stage 12-17、Demo GUT 成功。
5. asset runtime map、source safety 和 final acceptance gates 已从当前文件状态重新生成并相互一致。

## 最终结果

- Preview：正式场景初始 `52` 个名称含 `Preview` 的节点中，`50` 个隐藏历史节点已删除；`GatePreviewArt`、`AirDashTrailPreviewArt` 两个可见节点分别改名为 `GateEchoArt`、`AirDashTrailArt`。正式场景当前 `Preview=0`，`scenes/dev/` 的开发画廊命名不受影响。
- Source-only 绑定：`LunaReadabilityArt`、`SealGuardianArt`、`AttackWarningArt`、`SealGuardianRoomArt`、`BossWarningRoomArt`、`AbilityStatusFrameArt`、`BossHudFrameArt` 共 `7` 个隐藏方向稿节点已退出正式场景。
- 删除：上列 `14` 个 SVG 与各自 `.import` 已物理删除；`assets/` 当前 SVG 文件数为 `0`。历史文档和 manifest 保留原路径，仅用于说明退役来源，不构成运行引用。
- 运行接入：runtime map 为 `55` 项 / `10` tracks，处置分布为 `runtime_keep=26`、`source_dev_keep=20`、`archive_keep=9`；P0 运行计划为 `11` 项，`0` 项待替换、`11` 项已有引用。
- P0 下游：rehearsal 为 `11` 节点；target matrix 为 `12` 个正式场景、`11` 个资产、`23` 个场景-资产引用；replacement batches 为 `6` 批，数量均从当前计划动态推导，不再硬编码历史 `30` 项。
- 来源安全：runtime source safety 为 `11` 个运行资产、`0` review-required、`0` unsafe；ImageGen 候选层为 `133` 个 provenance review-required、`0` unsafe，该层不冒充运行资产确认。
- 最终门禁：art readiness `55/55` structural、`55/55` final；final review queue `0` manual-review；final acceptance gates `55/55` final-ready、`0` blocked；asset package strict audit 通过。
- 动画与隔离：animation runtime replacement `21/21 active ready`、`10` archived references、`0` archive errors；project asset isolation `839` files、`0` forbidden markers、`0` outside paths、`0` project-key errors。
- Godot：删除前门禁和删除后 `godot --headless --path . --import --quit` 均通过；Stage 12-17 与 Demo 定向回归通过；最终递归全量 GUT 为 `33` scripts、`240/240` tests、`6147` asserts。
- 边界：Image Gen 原始候选、selected frames、source sheet、editor atlas / TileSet、provenance 与开发工作台均按 `source_dev_keep` / `archive_keep` 保留；本轮没有按文件名、日期或目录做扩大删除。
