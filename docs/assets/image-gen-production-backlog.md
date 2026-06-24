# Nano Hunter Image Gen Production Backlog

Last Updated: 2026-06-24

## 用途

本文件是可执行生产 backlog，负责把 `asset-completion-matrix.md` 的类别矩阵落到具体 image gen 任务。它不替代 `asset-manifest.md`；manifest 记录资产追踪状态，本文件记录生产顺序、生成策略、候选数量和整理目标。

## 当前门槛

- 内置 `image_gen` 已能生成会话预览，`C:\Users\peng8\.codex\generated_images` 可列出历史 PNG；当前 prompt queue 已扩展到 `55` 条，其中 `55/55` 条已有本地候选 PNG。Batch00 / Batch01 / Batch06-Batch13 首轮来自 session JSONL 恢复，Batch02 / Batch03 / Batch03 supplemental / Batch06 supplemental / Batch08 supplemental 来自默认保存目录复制；2026-06-20 又从当前默认生成图目录恢复 `30` 张新 PNG 到 raw candidate 池。
- 当前恢复记录见 `docs/assets/image-gen-session-recovery-log.md`；原始候选位于 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png`，默认不进入普通 Git。
- 当前 raw candidate 池由 `scripts/assets/audit_imagegen_candidate_pool.py` 审计；报告为 `docs/assets/imagegen-candidate-pool-report.json`。当前记录 `133` 张 raw candidates、`548` 个 selected source 切片 / 条目、`102` 个尚未进入 selected sources 的候选和 `55` 个需要人工分拣的 asset；这些未选候选已同步生成 Godot 评审入口 `scenes/dev/imagegen_candidate_review_gallery.tscn` 与 `docs/assets/imagegen-candidate-review-gallery-manifest.json`。
- 当前跨项目来源安全由 `scripts/assets/audit_imagegen_source_safety.py` 审计；报告为 `docs/assets/imagegen-source-safety-report.json`。当前 `133` 张 raw candidates 中 `35` 张为 `project_session_confirmed`，`30` 张为 `explicit_mapping_review_required`，`68` 张为 `workspace_provenance_recorded_review_required`，`0` 张为 `unknown_or_unsafe`。后续不能从全局 `generated_images` 按“最新 PNG”直接导入并接入游戏。
- 当前 shell 环境未提供可用 `OPENAI_API_KEY`，因此不能直接执行 CLI/API fallback。
- 当前已生成 target-count `assets/art/` 可导入候选、atlas、TileSet sheet、Spine 拆件、UI atlas、VFX atlas 和 NinePatch sheet；并已完成 duplicate clearance，使 `26/26` 个 atlas-linked outputs 达到 `duplicates=0`。这些仍是 provisional target-count pass，不声称最终清稿或游戏内正式接入。
- 当前已为非 SpriteFrames atlas-linked outputs 生成 `302` 个 Godot `AtlasTexture` editor resources，并为 Batch07 两套 TileSet sheet 生成 `2` 个 Godot `TileSet` `.tileset.tres` 和 `2` 个 `.tileset_rules.json` 规则 sidecar，为 Batch08 `menu_ninepatch_ui_ai01` 生成 `8` 个 Godot `StyleBoxTexture` 资源骨架、`1` 个 Godot `Theme` 候选、`9` 个 Theme stylebox mappings 和 `4` 个 standalone UI skin panel rules，为 Batch10 / standalone VFX 生成 `6` 个 VFX rule sidecars / `78` 条 anchor-blend rules，为 Batch06 角色 / 敌人 Sprite Sheet 生成 `8` 个 animation rule sidecars / `172` 条 frame rules，为 Batch11 Luna / Seal Guardian 生成 `2` 个 Spine-style cutout exports、`48` 个 part descriptors；同时新增 `scenes/dev/imagegen_asset_gallery.tscn` 作为 Godot 编辑器内资产预览入口，新增 `scenes/dev/imagegen_asset_integration_showcase.tscn` 作为 Godot 节点级消费验证入口，并新增 `docs/assets/art-readiness-audit-report.json` 记录 `55/55` structural-ready、`55/55` final-ready 的当前边界。当前还为 `26` 个 atlas-linked outputs 生成 `538` 个 semantic entries；`docs/assets/asset-provenance-records.json` 已记录 `55` 条 provenance、`133` 个 candidate hashes、`55` 个 output hashes 和 `55` 个 prompt hashes；`docs/assets/asset-runtime-integration-map.json` 已记录 `55` 条 runtime / release binding map entries 和 `9` 个 tracks；`scenes/dev/imagegen_runtime_asset_catalog.tscn` 已用 `ResourcePreloader` 集中加载 `55` 个 runtime catalog resources。2026-06-24 当前 formal runtime / scene / catalog replacement gate 已推进到 `55` 个 passed；其中 `stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01`、`stage15_seal_guardian_ai01`、`stage16_luna_player_readability_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_title_background_ai01`、`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`stage16_talisman_relay_ai01`、`stage16_corruption_purge_ai01`、`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`、`stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01`、`menu_ninepatch_ui_ai01`、`stage16_demo_menu_icons_ai01`、`icon_sheet_core_ai01`、`hud_core_ui_atlas_ai01`、`vfx_seal_magic_atlas_ai01`、`vfx_combat_atlas_ai01`、`luna_idle_sheet_ai01`、`luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01`、`luna_jump_fall_sheet_ai01`、`luna_hit_death_sheet_ai01`、`enemies_core_sheet_ai01`、`seal_guardian_boss_sheet_ai01`、`luna_spine_parts_ai01`、`seal_guardian_spine_parts_ai01`、`biome01_air_dash_shrine_room_ai01`、`biome01_shrine_trial_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome02_miasma_hazard_room_ai01`、`biome02_miasma_marsh_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`、`stage15_seal_guardian_boss_room_ai01`、`equipment_pickup_atlas_ai01`、`material_texture_atlas_ai01`、`reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01`、`capsule_art_alpha_demo_ai01`、`cg_seal_guardian_reveal_ai01`、`nano_hunter_logo_direction_ai01`、`promo_key_art_sheet_ai01`、`storyboard_intro_bounty_ai01`、`storyboard_miasma_marsh_ai01`、`storyboard_narrative_sheet_ai01` 与 `style_board_global_ai01` 已进入 final-ready mini pack。其余资源方便编辑器使用、节点接入试跑和后续动画 / 环境管线交接，但不等于 autotile、正式危险区、完整最终 UI 设计系统、Spine rig、商业发布级公开营销图、最终 logo 字体、平台裁切、过场成片和剧情脚本锁定完成。
- 2026-06-21 最新校正：新增 `luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01`、`luna_idle_sheet_ai01` 四个隐藏玩家 `AnimatedSprite2D` 预览绑定后，formal runtime replacement gate 已推进到 `34 passed / 21 blocked`；P0 runtime replacement plan 当前为 `3 planned replacements, 25 already referenced`，P0 scene replacement batches 当前为 `23 planned scene-asset replacements, 32 already referenced`。`luna_jump_fall_sheet_ai01` 因缺少 `project_session_confirmed` candidate 仍不接入。
- 2026-06-21 继续校正：`vfx_seal_magic_atlas_ai01` 已作为隐藏 `SealMagicVfxPreview` 接入玩家场景和 Seal Guardian Boss 场景。该资产至少包含 1 个 `project_session_confirmed` candidate，但仍有 review-required 候选，因此只作为预览绑定。formal runtime replacement gate 已推进到 `35 passed / 20 blocked`；P0 runtime replacement plan 当前为 `2 planned replacements, 26 already referenced`，P0 scene replacement batches 当前为 `21 planned scene-asset replacements, 34 already referenced`。
- 2026-06-21 多项目来源复核后继续校正：新增 `runtime-source-safety-report`，确认当前 `28` 个 P0 runtime assets 中 `15` 个仍需来源 / 派生复核、`0` 个 unsafe；重新从 `project_session_confirmed` 候选生成 `luna_jump_fall_sheet_ai01`（candidate 04）和 `stage16_seal_release_threshold_ai01`（candidate 02），并接入玩家场景 / Stage16 封印阈值房 preview。formal runtime replacement gate 已推进到 `36 passed / 19 blocked`；P0 runtime replacement plan 当前为 `0 planned replacements, 28 already referenced`，P0 scene replacement batches 当前为 `18 planned scene-asset replacements, 36 already referenced`。同日追加 `stage16_demo_menu_icons_ai01_candidate_02` 与 `stage14_air_dash_icon_ai01_candidate_02` 两个评审候选，并重新从 `stage14_air_dash_icon_ai01_candidate_01` 导出 runtime PNG 与 `.source.json`，使 Air Dash 图标不再出现在 runtime source review-required 列表中。随后补强 standalone `.source.json` 项目键门禁，9 个 standalone 派生记录均包含 `project_key = nano-hunter`，候选池与评审 Gallery 已刷新为 `67` 个 unselected candidates / `67` 张候选卡；`hud_core_ui_atlas_ai01` 已从 `candidate_01` 重建 `16/16` 个 selected items 与 UI atlas，并从 runtime source review-required 列表移除。
- 2026-06-21 继续新增 `runtime-source-review-queue`，把剩余 `15` 个 runtime review-required 资产拆成 `8` 个 `manual_compare_selected_mix` 和 `7` 个 `manual_source_review_or_regenerate`。综合资产包审计已纳入该队列并记录 `15 runtime source review queue entries`。后续恢复 image gen 工具后，优先处理 7 个只来自 review-required 候选的 runtime UI / VFX 资产；混用候选的 8 个资产则先人工审图，避免 confirmed-only 重建造成 duplicate 补位。
- 2026-06-21 继续新增 `runtime-source-regeneration-packet`，为这 7 个 runtime UI / VFX 资产生成下一轮 image gen prompt 与候选路径：`stage16_demo_menu_icons_ai01_candidate_03`、`stage16_talisman_relay_ai01_candidate_02`、`stage16_alpha_demo_completion_ai01_candidate_02`、`stage16_pause_panel_ui_ai01_candidate_02`、`stage16_completion_panel_ui_ai01_candidate_02`、`stage15_boss_hud_frame_ai01_candidate_02`、`stage14_ability_status_hud_ai01_candidate_02`。综合资产包审计已记录 `7 runtime source regeneration prompts`。这些 prompt 是下一轮生成入口，不代表 PNG 已落盘。
- 2026-06-21 继续新增并执行 `runtime-source-regeneration-landing-report`：为上述 7 个重生图候选新增落盘审计，随后已用内置 image_gen 生成并导入这些候选，当前 landing report 为 `7/7 landed, 0 invalid`。同轮还为 8 个 `manual_compare_selected_mix` 资产追加统一风格重生候选。导入时发现全局 `generated_images` 同时存在其它会话 PNG，已修正为显式读取当前 Nano Hunter 会话目录并重导入 `stage16_demo_menu_icons_ai01_candidate_03`。综合资产包审计已记录 `7/7 runtime source regeneration landed`；这些 PNG 仍只是 raw candidates，不自动覆盖 `assets/art/`。
- 2026-06-21 继续新增 Godot `runtime_source_review_workbench.tscn`，把剩余 `15` 个 runtime review-required 资产的当前输出和 `34` 张候选 PNG 放到编辑器可视化审图工作台中。综合资产包审计已记录 `34 runtime source workbench candidates`。后续人工审图时优先打开该场景，再决定确认、局部重建或按 regeneration packet 重生图。
- 2026-06-24 继续刷新 `asset-family-coverage-report`：当前用户目标中的 `10/10` 个美术资产族和 `7/7` 种 Godot 可用格式已经达到 structural coverage，`55` 个资产 structural-ready，`55` 个 final-ready。后续 backlog 重心不再是扩更多类别，而是把已有 structural pass 推进到来源确认、授权记录、人工清稿、运行时接入质量和 final-ready。
- 2026-06-21 继续新增 `project-asset-isolation-report`：针对多项目并行开发风险，扫描 `assets/`、`docs/assets/` 与 `scripts/assets/` 下 `1936` 个资产相关文件，结果为 `0` 个已知外项目标识、`0` 个外项目绝对路径、`0` 个 `project_key` 错误。综合资产包审计已纳入该门槛。该结果不等于 `15` 个 runtime review-required 来源已确认，也不等于最终美术完成。
- image gen 文件落盘后，按 `docs/assets/asset-atlas-build-manifest.json` 与 `scripts/assets/build_asset_atlases.py` 生成 Godot 候选 sheet / atlas。
- raw candidates 进入图集构建前，先用 `scripts/assets/prepare_selected_sources.py` 自动拆分到 `selected_frames/`、`selected_items/`、`selected_tiles/`、`selected_parts/` 或 `selected_panels/`。
- 若一个 asset 需要补帧或补小图，不覆盖旧候选；追加 `<asset_id>_candidate_02.png`、`candidate_03.png` 等，再用 `prepare_selected_sources.py --target target --only <asset_id> --overwrite` 合并抽取并重建该输出。
- 不走 atlas manifest 的单体方向稿、图标、道具、VFX、风格板和 logo direction，用 `scripts/assets/export_standalone_candidates.py` 从 `candidate_01` 导出到 `assets/art/` 目标路径；导出的 `<asset>.source.json` 必须带 `project_key = nano-hunter` 与 `project_name = Nano Hunter`。
- 具体可复制 prompt 队列保存在 `docs/assets/image-gen-prompt-queue.json`，用 `scripts/assets/validate_asset_production_queue.py` 校验 queue、source_dir、output_path 与 atlas manifest 的一致性；批次执行单由 `scripts/assets/export_imagegen_batch_plan.py` 从 queue 导出。
- 如果 Codex Desktop 会话预览只能由用户从界面手动保存，统一先保存到 `assets/source/imagegen_inbox/`；该目录只保留 `.gitkeep`，实际图片默认不进入普通 Git。

## 可执行 Prompt Queue

当前 queue 覆盖 `Batch 00`、`Batch 01`、`Batch 02`、`Batch 03`、`Batch 06` 到 `Batch 13` 的第一轮核心资产生产入口：

- 风格板：全局视觉锚点。
- P0 玩法读值：Luna、Air Dash、Seal Guardian、Boss warning、Recovery Charge。
- 角色与动画：Luna run / air dash / attack / idle、Seal Guardian boss sheet。
- 地图与贴图：shrine trial TileSet、miasma marsh TileSet、material texture atlas。
- UI / 图标：HUD atlas、icon sheet、menu ninepatch。
- 道具与装备：shrine / gate / relay / checkpoint prop atlas、equipment pickup atlas。
- 特效：seal magic VFX atlas、combat VFX atlas。
- Spine 拆件：Luna cutout parts、Seal Guardian cutout parts。
- 宣传与叙事：key art、capsule art、logo direction、Seal Guardian CG、storyboard sheets。

校验命令：

```powershell
python scripts/assets/validate_asset_production_queue.py
```

导出某个 Batch 的执行单：

```powershell
python scripts/assets/export_imagegen_batch_plan.py --batch 01 --date 2026-06-19
```

当前已导出的首轮执行单：

- `docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- `docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`

生产时从 queue 复制 `prompt` 到内置 `image_gen`，生成后运行 `scripts/assets/import_imagegen_outputs.py` 导入候选。只有真实 PNG 进入 `assets/source/ai_generated/` 或外部资产库后，才进入筛选、清稿、atlas build 和 manifest 状态更新。

如果内置 `image_gen` 只生成会话预览、没有暴露可读取文件路径，优先检查 Codex session JSONL 中是否存在 `image_generation_call.result`。若可恢复，按 `docs/assets/image-gen-session-recovery-log.md` 的方式写入对应候选目录；若不可恢复，则只把视觉评审和扫描结果记录到 `docs/assets/image-gen-preview-log.md`，不要把该预览记为已落盘资产。

### Candidate pool audit / 候选池审计

2026-06-20 已新增候选池审计入口：

```powershell
python scripts\assets\audit_imagegen_candidate_pool.py --strict --write-report
```

报告：

```text
docs/assets/imagegen-candidate-pool-report.json
```

当前结果：

- raw candidates: `133`
- selected sources: `548`
- unselected candidates: `102`
- review-required assets: `55`

使用规则：

- 新图先进入 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`，并由候选池审计记录。
- 未进入 `selected_frames/`、`selected_items/`、`selected_tiles/`、`selected_parts/` 或 `selected_panels/` 的候选只算“可审图素材”，不算 atlas 源图。
- 只有人工确认某个候选更适合当前资产后，才运行 `prepare_selected_sources.py --target target --only <asset_id> --overwrite` 与 `build_asset_atlases.py --only <asset_id>`。
- 候选池增加不自动改变 `assets/art/`、`SpriteFrames`、`TileSet`、`StyleBox`、`Theme`、VFX rules、animation rules 或运行时引用。

### Candidate review gallery / 候选评审 Gallery

2026-06-20 已把候选池中尚未进入 selected source 的 raw candidates 生成 Godot 编辑器评审场景；2026-06-24 已刷新到当前 `102` 个 unselected candidates：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_candidate_review_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd
```

输出：

- `scenes/dev/imagegen_candidate_review_gallery.tscn`
- `docs/assets/imagegen-candidate-review-gallery-manifest.json`

当前审计结果：

- candidate review cards: `102`
- review-required assets: `55`

使用规则：

- 该场景用于人工逐张扫图、比较新增候选是否值得替换 selected source。
- 它不表示候选已通过质量检查，也不表示候选已接入图集或运行时。
- 综合资产包审计会校验候选池中的 unselected candidate 数量与 Gallery 卡片数一致。

### Asset provenance records / 来源与 hash 记录

2026-06-20 已新增 provenance 记录：

```powershell
python scripts\assets\build_asset_provenance.py
python scripts\assets\audit_asset_provenance.py --strict
```

报告：

```text
docs/assets/asset-provenance-records.json
```

当前结果：

- provenance records: `55`
- candidate hashes: `103`
- output hashes: `55`
- prompt hashes: `55`

使用规则：

- 每次新增、替换、重导出候选或 `assets/art` 输出后都要重跑 provenance build / audit。
- provenance 可以证明 prompt、raw candidate 和输出 hash 可追踪。
- provenance 不能证明商业发布条款、最终美术质量或运行时替换；`art-readiness` 中对应 blocker 现在是 `license_terms_manual_review`。

### Asset runtime integration map / 运行时接入 map

2026-06-20 已新增运行时 / 发布接入 map：

```powershell
python scripts\assets\build_asset_runtime_map.py
python scripts\assets\audit_asset_runtime_map.py --strict
```

报告：

```text
docs/assets/asset-runtime-integration-map.json
```

当前结果：

- runtime map entries: `55`
- tracks: `9`
- missing outputs: `0`
- missing target scene candidates: `0`

使用规则：

- map 只说明每个资产应该接到哪个系统、资源类型和候选场景。
- map 不表示场景引用已经替换，也不表示运行时读值通过。
- `art-readiness` 中对应 blocker 现在是 `runtime_binding_map_ready_manual_replacement`，后续必须按 Stage polish 逐项替换和复核。

### Runtime asset catalog / 运行时资源目录

2026-06-20 已新增 Godot runtime asset catalog：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_runtime_asset_catalog.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_runtime_asset_catalog.gd
```

输出：

- `scenes/dev/imagegen_runtime_asset_catalog.tscn`
- `docs/assets/imagegen-runtime-asset-catalog-manifest.json`

当前结果：

- runtime catalog resources: `55`
- runtime catalog entries: `55`

使用规则：

- catalog 用 `ResourcePreloader` 证明资源能被 Godot 集中加载。
- catalog 不表示正式场景引用已经替换。
- `art-readiness` 中对应 blocker 现在是 `runtime_catalog_ready_manual_replacement`，后续仍需人工替换 scene / HUD / Boss / VFX / TileSet 引用。

### 手动保存后的导入接力

如果用户从 Codex Desktop 界面下载或另存了会话预览图，先放入本地 inbox：

```text
assets/source/imagegen_inbox/
```

然后扫描 inbox：

```powershell
python scripts/assets/import_imagegen_outputs.py --include-inbox --since-minutes 1440 --limit 50
```

如果需要排查无扩展名缓存或错误扩展名文件，使用文件头扫描：

```powershell
python scripts/assets/import_imagegen_outputs.py --include-codex-home --include-temp --include-inbox --magic-scan --since-minutes 1440 --limit 50
```

确认列表中的图片属于目标 asset 后，用显式路径导入：

```powershell
python scripts/assets/import_imagegen_outputs.py --source assets/source/imagegen_inbox/<downloaded-file>.png --batch 12 --asset-id capsule_art_alpha_demo_ai01
```

导入后文件进入：

```text
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png
```

只有当候选被人工选中并复制到 `selected_frames/` 或 `selected_items/` 后，才运行 atlas build。宣传图、CG 和分镜图如不需要切帧，可以先保持在 `candidates/` 并按后续清稿流程输出到 `assets/art/promo/` 或 `assets/art/storyboards/`。

### 会话恢复后的自动拆分与第一版构建

2026-06-19 已从当前 Codex session JSONL 恢复 `33/33` 个原始候选 PNG，并执行：

```powershell
python scripts\assets\prepare_selected_sources.py --overwrite
python scripts\assets\export_standalone_candidates.py --overwrite
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\build_asset_atlases.py
godot --headless --path . --import
```

结果：

- `selected_frames`: `88`
- `selected_items`: `52`
- `selected_tiles`: `32`
- `selected_parts`: `24`
- `selected_panels`: `18`
- 第一版 Godot 候选输出：`33` 张 `assets/art/**/*.png`、`23` 个 JSON、`7` 个 `.spriteframes.tres`
- 其中 standalone 输出 `10` 张，覆盖 `style_board_global_ai01`、Batch01 的 Luna / Air Dash / Seal Guardian / Recovery Charge 方向稿，以及 `nano_hunter_logo_direction_ai01`。
- Batch02 继续新增 standalone 输出 `6` 张，覆盖 Stage16 title background、menu icons、seal release threshold、talisman relay、corruption purge 和 Alpha Demo completion UI。
- Batch03 继续新增 standalone 输出 `5` 张，覆盖 shrine trial / miasma marsh 的 tile、background 和 reusable seal props。
- Batch03 supplemental 继续新增 standalone room/background 输出 `4` 张，覆盖 shrine trial room、Air Dash shrine room、miasma hazard room 和 Seal Guardian boss room。
- Batch06 supplemental 继续新增 Sprite Sheet 输出 `3` 张，覆盖 Luna jump/fall、Luna hit/death 和 core enemies。
- Batch08 supplemental 继续新增 standalone UI panel 输出 `4` 张，覆盖 Stage16 pause / completion panel、Stage15 Boss HUD frame 和 Stage14 ability status HUD；当前 `assets/art/**/*.png` 总数为 `55`，`.spriteframes.tres` 总数为 `10`。

边界：

- 当前历史块记录的是 first pass，只满足 `expected_min`，后续已推进到 target-count rebuild。
- 自动拆分结果用于管线验证和编辑器预览，不等于最终清稿。
- Luna run 存在自动补帧；TileSet、Promo、CG 和 Storyboard 输出存在网格裁切痕迹，后续必须人工重切 / 清稿 / 补图。

### Target-count atlas rebuild

2026-06-19 已对全部 `26` 个 atlas-linked outputs 执行 target-count rebuild：

```powershell
python scripts\assets\prepare_selected_sources.py --target target --overwrite
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\build_asset_atlases.py
python scripts\assets\audit_asset_target_coverage.py --strict
```

结果：

- `selected_frames`: `236`
- `selected_items`: `122`
- `selected_tiles`: `96`
- `selected_parts`: `48`
- `selected_panels`: `36`
- `26/26` atlas-linked outputs reached `expected_target`
- `55` 张 `assets/art/**/*.png`
- `26` 个 `frames / regions` JSON
- `10` 个 `.spriteframes.tres`

边界：

- 这是 editor-ready target-count 重建，不是 final polish。
- duplicate 补位已在 2026-06-20 duplicate clearance 中清零；后续优先用人工清稿、语义切分和运行态复核替代继续补数量。
- TileSet、Promo、CG 和 Storyboard 输出仍需人工重切、语义整理和清稿。
- UI、VFX 和 Spine parts 仍需锚点、mask、NinePatch、线宽和运行态读值复核。

### Duplicate reduction / clearance passes

2026-06-20 已对 duplicate 输出追加补充候选：

```powershell
python scripts\assets\prepare_selected_sources.py --target target --only <asset_id> --overwrite
python scripts\assets\build_asset_atlases.py --only <asset_id>
python scripts\assets\audit_asset_target_coverage.py --strict
```

Pass 01 结果：

| Asset ID | Before | After |
| --- | ---: | ---: |
| `luna_run_sheet_ai01` | 12 | 0 |
| `vfx_combat_atlas_ai01` | 17 | 1 |
| `enemies_core_sheet_ai01` | 16 | 0 |
| `shrine_gate_prop_atlas_ai01` | 16 | 0 |
| `equipment_pickup_atlas_ai01` | 13 | 0 |

Pass 01 后仍有 duplicate 的 Luna air dash、Luna attack、Luna idle、Luna jump/fall、Luna hit/death、Seal Guardian boss、icon sheet、menu ninepatch 和 seal magic VFX 已在 Pass 02 继续处理。

Pass 02 结果：

| Asset ID | Before Pass 02 | After Pass 02 |
| --- | ---: | ---: |
| `seal_guardian_boss_sheet_ai01` | 8 | 0 |
| `luna_jump_fall_sheet_ai01` | 8 | 0 |
| `luna_hit_death_sheet_ai01` | 8 | 0 |
| `icon_sheet_core_ai01` | 8 | 0 |
| `vfx_seal_magic_atlas_ai01` | 6 | 0 |
| `luna_air_dash_sheet_ai01` | 4 | 0 |
| `luna_idle_sheet_ai01` | 4 | 0 |
| `luna_attack_01_sheet_ai01` | 2 | 0 |
| `menu_ninepatch_ui_ai01` | 2 | 0 |
| `vfx_combat_atlas_ai01` | 1 | 0 |

当前 `python scripts\assets\audit_asset_target_coverage.py --strict` 结果为：`26/26` 个 atlas-linked outputs 全部 `duplicates=0`。下一步不再优先补 duplicate，而是进入人工筛选、清稿、语义切分、帧序复核、TileSet / NinePatch / VFX 锚点整理和运行态接入验证。

### Editor AtlasTexture resource layer

2026-06-20 已为非 SpriteFrames 的 atlas-linked outputs 生成 Godot 编辑器资源层：

```powershell
python scripts\assets\build_editor_atlas_textures.py --clean
python scripts\assets\audit_editor_atlas_textures.py --strict
godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd
```

结果：

- `302` 个 `AtlasTexture` `.tres`
- `16` 个 covered assets
- 索引：`assets/art/editor_resources/editor_atlas_textures.index.json`
- Godot 加载验证：`Editor AtlasTexture resources OK: 302`

该层让 UI icon、TileSet sheet region、prop / equipment、Spine parts、textures、promo / CG / storyboard region 可在 Godot 编辑器中按单个 `AtlasTexture` 使用。它不替代正式 TileSet 资源、NinePatch margin 配置或运行时接入。

### Editor StyleBoxTexture resource layer

2026-06-20 已为 Batch08 `menu_ninepatch_ui_ai01` 生成 Godot `StyleBoxTexture` 候选资源：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd
godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd
```

结果：

- `8` 个 `StyleBoxTexture` `.tres`
- 索引：`assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json`
- Godot 加载验证：`Editor StyleBoxTexture resources OK: 8`

该层让 `menu_ninepatch_ui_ai01.png` 的 `8` 个 region 可以作为 Godot UI 样式候选使用。当前使用保守 `24px` 九切边距，不包含 Theme 接入、运行时 UI 引用替换、伪文字清理、线宽统一、文字安全区或拉伸失真复核。

### Editor UI skin / Theme rules layer

2026-06-20 已在 `StyleBoxTexture` 之上继续生成 Godot UI skin 候选：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_ui_skin.gd
godot --headless --path . --script res://scripts/dev/audit_editor_ui_skin.gd
```

结果：

- `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres`
- `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`
- `8` 个 Theme stylebox mappings，覆盖 `PanelContainer`、`Button`、`PopupPanel`、`TooltipPanel` 和 `AcceptDialog`。
- `4` 个 standalone UI skin panel rules，覆盖 Stage16 pause / completion panel、Stage15 Boss HUD frame 和 Stage14 ability status HUD。
- Godot 加载验证：初始 `Editor UI skin OK: 8 style mappings, 4 standalone panels`；runtime UI skin binding 后当前为 `Editor UI skin OK: 9 style mappings, 4 standalone panels`

该层让 Batch08 UI 资源具备 Theme 映射和 text-safe area 规则入口。当前仍不替换 DemoShell、Boss HUD 或 ability HUD；伪文字清理、真实布局、拉伸失真、对比度、小尺寸读值和运行态 UI 复核仍需后续处理。

### Editor TileSet resource layer

2026-06-20 已为 Batch07 两个 `tileset_sheet` 生成 Godot `TileSet` 候选资源：

```powershell
godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd
godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd
```

结果：

- `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`
- `assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres`
- `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset_rules.json`
- `assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset_rules.json`
- Godot 加载验证：`Editor TileSet resources OK: 2`
- 综合审计验证：`2` 个 rule files、`96` 个 tile rules、`64` 个 collision-ready tiles、`8` 个 hazard visual-only tiles。

该层让 `miasma_marsh_tileset_ai01.png` 与 `shrine_trial_tileset_ai01.png` 可以作为 Godot `TileSet` 起点加载。当前已配置 `1` 个 physics layer、`1` 个 terrain set、solid / one-way platform 的保守碰撞候选，以及 hazard / decor 的 visual-only 规则。`miasma_marsh_tileset_ai01` 已在 Stage13 / Stage14 房间作为 `TileMapLayer` visual preview 引用，但它仍不包含 autotile、navigation、occlusion、正式伤害 Area、正式碰撞替换或 gameplay readability 复核。

### Spine-style cutout export layer

2026-06-20 已为 Batch11 Luna 与 Seal Guardian 拆件图集生成 Spine-style cutout exports：

```powershell
python scripts\assets\build_spine_cutout_manifests.py
python scripts\assets\audit_spine_cutout_manifests.py --strict
```

结果：

- `2` 个 asset exports：`luna_spine_parts_ai01`、`seal_guardian_spine_parts_ai01`
- `48` 个 part descriptors
- 总索引：`assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json`
- 每个 asset 输出 `.atlas`、`.spine_style.json` 与 `.cutout_manifest.json`
- 审计验证：`Audited 2 Spine-style cutout exports with 48 parts.`

该层让拆件图集具备后续手工 rigging 的描述入口。当前不启用 Spine 插件，不生成正式 Spine 工程，不包含 bone hierarchy、IK、mesh、weights、动画曲线或精修 pivot；正式绑定前仍需语义命名、层级顺序、遮挡边缘和透明边缘清稿。

### VFX anchor / blend rules layer

2026-06-20 已为 Batch10 和 standalone VFX 生成 first-pass VFX rules：

```powershell
python scripts\assets\build_vfx_rules.py
python scripts\assets\audit_vfx_rules.py --strict
```

结果：

- `assets/art/vfx/vfx_rules/vfx_rules.index.json`
- `6` 个 VFX rule sidecars
- `78` 条 frame / texture rules
- 覆盖 `vfx_seal_magic_atlas_ai01`、`vfx_combat_atlas_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01`、`stage16_talisman_relay_ai01`、`stage16_corruption_purge_ai01`
- 所有规则均记录 `gameplay_collision=false` 和 `damage_source=false`
- 审计验证：`VFX rules OK: 6 assets, 78 frame rules, 78 collision-disabled rules.`

该层让 VFX 具备 first-pass anchor、spawn offset、blend 和用途记录。当前不替换运行时 VFX，不生成 hitbox / hurtbox / damage Area；mask、透明边缘、播放速度、缩放、遮挡层级和 gameplay readability 仍需人工复核。

### Character animation rules layer

2026-06-20 已为 Batch06 角色 / 敌人 Sprite Sheet 生成 first-pass animation rules：

```powershell
python scripts\assets\build_animation_rules.py
python scripts\assets\audit_animation_rules.py --strict
```

结果：

- `assets/art/characters/animation_rules/animation_rules.index.json`
- `8` 个 animation rule sidecars
- `172` 条 frame rules
- 覆盖 Luna run / air dash / attack / idle / jump-fall / hit-death、Seal Guardian boss attack 和 core enemies cycle
- 审计验证：`Animation rules OK: 8 assets, 172 frame rules.`

该层让角色 / 敌人 Sprite Sheet 具备 first-pass clip、fps、loop、pivot、脚底基线和 frame duration 规则。当前不替换运行时动画，也不确认最终帧序、角色一致性、碰撞盒读值或试玩手感。

### Godot ImageGen Asset Gallery

2026-06-20 已新增 Godot 编辑器内资产预览入口：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_gallery.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd
```

结果：

- `scenes/dev/imagegen_asset_gallery.tscn`
- `docs/assets/imagegen-asset-gallery-manifest.json`
- Gallery manifest 覆盖 `55` 个 queue output PNG、`302` 个 `AtlasTexture` region、`2` 个 TileSet sheet、`8` 个 `StyleBoxTexture` 和 `48` 个 Spine part descriptors。
- `audit_imagegen_asset_gallery.gd` 会实际检查 `361` 个普通纹理预览资源和 `8` 个 `StyleBoxTexture` 预览资源，不只统计场景节点数量。

该入口用于后续人工扫图、清稿优先级判断和编辑器验收；它不是正式游戏场景，也不代表 runtime references 已替换。

### Godot ImageGen Asset Gallery render smoke

2026-06-20 已新增 Gallery 渲染烟测：

```powershell
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_imagegen_asset_gallery.gd
```

结果：

- 本地截图：`tests/artifacts/local/imagegen_asset_gallery/gallery_viewport.png`
- 采样报告：`tests/artifacts/local/imagegen_asset_gallery/gallery_viewport_report.json`
- 报告 `ok=true`
- `samples=3600`
- `non_transparent_ratio=1.0`
- `varied_color_buckets=85`

该命令需要真实渲染器，不使用 `--headless`。截图和报告是本地验证证据，默认不进入普通提交；该烟测只证明 Gallery 非空渲染，不证明最终美术质量或运行时接入。

### Godot ImageGen Asset Integration Showcase

2026-06-20 已新增节点级接入演示：

```powershell
godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd
godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd
```

结果：

- `scenes/dev/imagegen_asset_integration_showcase.tscn`
- `docs/assets/imagegen-asset-integration-showcase-manifest.json`
- `10` 个 `AnimatedSprite2D` 绑定 `.spriteframes.tres`
- `2` 个 `TileMapLayer` 绑定 `.tileset.tres`
- `4` 个 `PanelContainer` 绑定 `StyleBoxTexture`
- `8` 个 `Sprite2D` 绑定代表性 `AtlasTexture`
- Godot 加载验证：`Imagegen asset integration showcase OK: res://scenes/dev/imagegen_asset_integration_showcase.tscn`

该入口证明当前资源包可以被真实 Godot 节点消费。它不是正式游戏场景，也不代表 runtime references 已替换；正式接入仍需另走对应 Stage polish / asset integration plan、`asset-ingestion-checklist.md`、Godot import、GUT 或人工试玩复核。

### Art readiness audit layer

2026-06-20 已新增美术接入就绪审计：

```powershell
python scripts\assets\audit_art_readiness.py --strict --write-report
```

结果：

- 报告：`docs/assets/art-readiness-audit-report.json`
- `ok`: `true`
- `structural_ready_count`: `55/55`
- `final_ready_count`: `55/55`
- `alpha_expected_but_not_detected`: `0`
- 剩余 warnings：`background_asset_contains_alpha=11`

同轮修复 `scripts/assets/export_standalone_candidates.py`，standalone 导出现在同时支持绿色和洋红 chroma key；`stage15_seal_guardian_ai01` 已重导出为带 alpha 的 `RGBA` PNG。

该报告明确当前下一步不是继续盲目补数量，而是按 blocker 类型做人工清稿和运行时替换：Luna / Boss 帧序与锚点、TileSet collision / terrain、UI 小尺寸读值、NinePatch margin、VFX mask / anchor、Spine part pivot / layer order、授权记录和 gameplay readability。

### Asset semantic label layer

2026-06-20 已新增语义标签层：

```powershell
python scripts\assets\build_asset_semantics.py
python scripts\assets\audit_asset_semantics.py --strict
```

结果：

- `docs/assets/asset-semantics-index.json`
- `26` 个 atlas-linked semantic files
- `538/538` atlas / frame / region semantic entries
- `assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json`
- `assets/art/ui/stage16_demo_menu_icons_ai01.regions.json`
- `6` 个 standalone menu icon confirmed semantics
- 综合资产包审计记录 `544 semantic labels`

该层把自动编号切片推进到可读语义名，例如 Luna 动作帧、Boss phase、敌人类型、TileSet category、HUD / icon region、prop state、equipment item、VFX phase、Spine part、promo variant 和 storyboard panel。当前仍是 first-pass machine semantic labels，人工确认前不视为最终命名。

### Asset package audit layer

2026-06-20 已新增综合资产包审计入口：

```powershell
python scripts\assets\audit_asset_package.py --strict --write-report
```

结果：

- 报告：`docs/assets/asset-package-audit-report.json`
- `ok`: `true`
- queue items: `55`
- candidate PNGs: `133`
- unselected raw candidates: `102`
- atlas-linked outputs: `26`
- AtlasTexture resources: `302`
- TileSet resources: `2`
- TileSet rule sidecars: `2`
- TileSet collision-ready tiles: `64`
- StyleBoxTexture resources: `8`
- UI Theme mappings: `9`
- Runtime UI skin panels: `5`
- Runtime UI skin textures: `4`
- UI skin standalone panel rules: `4`
- VFX rules: `78`
- Animation rules: `172`
- Spine-style cutout exports: `2` assets / `48` parts
- Godot Asset Gallery scene / manifest: present
- Godot Asset Integration Showcase scene / manifest: present
- Art readiness: `55` structural-ready outputs / `55` final-ready outputs
- Asset semantics: `544` first-pass labels
- Candidate pool report: `133` raw candidates / `102` unselected candidates
- Candidate review gallery: `102` candidate review cards / `55` assets
- Source safety: `0` unsafe source candidates

该报告是结构性 gate，只证明文件、数量和 editor resource descriptors 存在；不证明最终美术质量、授权、运行时接入、TileSet collision、NinePatch 拉伸、VFX 锚点、Spine pivot 或玩法读值。

## 生产顺序

| 顺序 | Batch | 目标 | 为什么先做 |
| --- | --- | --- | --- |
| 1 | Batch 00 | 全局风格板与 Luna / Seal Guardian 方向 | 锁定风格，避免后续图集混风格 |
| 2 | Batch 01 | P0 玩法可读资产 | 直接影响 Alpha Demo 玩家读值 |
| 3 | Batch 06 | Luna 高帧动作 sheet | 主角是长期注视对象，必须优先高帧数 |
| 4 | Batch 08 | HUD / Icon / 九宫格 | UI 决定 demo 完成度和信息理解 |
| 5 | Batch 10 | VFX Atlas | 能力、攻击、Boss 预警读值 |
| 6 | Batch 07 | TileSet / Textures | 场景替换范围大，需在读值资产后做 |
| 7 | Batch 09 | Prop / Equipment Atlas | 丰富内容但不应阻塞核心读值 |
| 8 | Batch 11 | Spine 拆件图集 | 后续动画管线候选，当前不启用插件 |
| 9 | Batch 12 | LOGO / CG / Promo | 宣传展示，不阻塞 playable demo |
| 10 | Batch 13 | Storyboard / Narrative | 叙事扩展，等视觉基调稳定后推进 |

## Batch 06 - Luna 高帧动作优先队列

| Asset ID | 候选帧数 | 正式目标帧数 | 单帧建议 | 目标路径 | Prompt 模板 |
| --- | --- | --- | --- | --- | --- |
| `luna_run_sheet_ai01` | 12 | 16-24 | 160x160 | `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png` | `Batch 06 - Luna High Frame Sprite Sheet Prompt` |
| `luna_air_dash_sheet_ai01` | 12 | 12-16 | 192x160 | `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png` | `Batch 06 - Luna High Frame Sprite Sheet Prompt` |
| `luna_attack_01_sheet_ai01` | 10-12 | 12-16 | 192x160 | `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png` | `Batch 06 - Luna High Frame Sprite Sheet Prompt` |
| `luna_idle_sheet_ai01` | 8-12 | 12-16 | 160x160 | `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png` | `Batch 06 - Luna High Frame Sprite Sheet Prompt` |
| `luna_jump_fall_sheet_ai01` | 8-12 | 6-8 per group | 160x160 | `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png` | `Batch 06 - Character Sprite Sheet Prompt` |
| `luna_hit_death_sheet_ai01` | 12 | hit 6-8, death 16-24 | 192x160 | `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png` | `Batch 06 - Luna High Frame Sprite Sheet Prompt` |

## Batch 07-13 分类队列

| Batch | Asset ID | 输出类型 | 目标路径 | 候选数量 | 备注 |
| --- | --- | --- | --- | --- | --- |
| Batch 07 | `shrine_trial_tileset_ai01` | Tile Set | `assets/art/tilesets/shrine_trial_tileset_ai01.png` | 3-6 | 地形边界优先 |
| Batch 07 | `miasma_marsh_tileset_ai01` | Tile Set | `assets/art/tilesets/miasma_marsh_tileset_ai01.png` | 3-6 | 危险色和安全色分离 |
| Batch 07 | `material_texture_atlas_ai01` | Texture Atlas | `assets/art/textures/material_texture_atlas_ai01.png` | 3-6 | 手绘材质，不做 PBR |
| Batch 08 | `hud_core_ui_atlas_ai01` | UI Atlas | `assets/art/ui/atlases/hud_core_ui_atlas_ai01.png` | 3-6 | 640x360 读值 |
| Batch 08 | `menu_ninepatch_ui_ai01` | NinePatch | `assets/art/ui/menu_ninepatch_ui_ai01.png` | 3-6 | 无文字，面板可拉伸 |
| Batch 08 | `icon_sheet_core_ai01` | Icon Sheet | `assets/art/ui/atlases/icon_sheet_core_ai01.png` | 3-6 | 64x64 源图，32x32 可读 |
| Batch 08 | `stage16_pause_panel_ui_ai01` | UI Panel | `assets/art/ui/stage16_pause_panel_ui_ai01.png` | 1-3 | 暂停 / 重开面板候选，无文字 |
| Batch 08 | `stage16_completion_panel_ui_ai01` | UI Panel | `assets/art/ui/stage16_completion_panel_ui_ai01.png` | 1-3 | Alpha Demo 完成反馈面板候选 |
| Batch 08 | `stage15_boss_hud_frame_ai01` | HUD Frame | `assets/art/ui/stage15_boss_hud_frame_ai01.png` | 1-3 | Boss 血条框与封印链状态候选 |
| Batch 08 | `stage14_ability_status_hud_ai01` | HUD Panel | `assets/art/ui/stage14_ability_status_hud_ai01.png` | 1-3 | Air Dash / Recovery 状态候选 |
| Batch 09 | `shrine_gate_prop_atlas_ai01` | Prop Atlas | `assets/art/atlases/shrine_gate_prop_atlas_ai01.png` | 3-6 | inactive / active / completed 状态空间 |
| Batch 09 | `equipment_pickup_atlas_ai01` | Equipment Atlas | `assets/art/atlases/equipment_pickup_atlas_ai01.png` | 3-6 | 小物件不能现代化 |
| Batch 10 | `vfx_combat_atlas_ai01` | VFX Atlas | `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png` | 3-6 | slash / hit / boss warning |
| Batch 10 | `vfx_seal_magic_atlas_ai01` | VFX Atlas | `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png` | 3-6 | dash / relay / purge |
| Batch 11 | `luna_spine_parts_ai01` | Spine cutout sheet | `assets/art/spine_parts/luna_spine_parts_ai01.png` | 3-6 | 先不启用 Spine 插件 |
| Batch 11 | `seal_guardian_spine_parts_ai01` | Spine cutout sheet | `assets/art/spine_parts/seal_guardian_spine_parts_ai01.png` | 3-6 | Boss 拆件 |
| Batch 12 | `nano_hunter_logo_direction_ai01` | Logo direction | `assets/art/promo/nano_hunter_logo_direction_ai01.png` | 3-6 | 生成文字仅作方向 |
| Batch 12 | `key_art_alpha_demo_ai01` | Key Art | `assets/art/promo/key_art_alpha_demo_ai01.png` | 3-6 | 不烘焙最终标题 |
| Batch 12 | `capsule_art_alpha_demo_ai01` | Promo capsule | `assets/art/promo/capsule_art_alpha_demo_ai01.png` | 3-6 | 预留标题安全区 |
| Batch 13 | `storyboard_intro_bounty_ai01` | Storyboard Sheet | `assets/art/storyboards/storyboard_intro_bounty_ai01.png` | 3-6 | 六格分镜，无对白文字 |
| Batch 13 | `storyboard_miasma_marsh_ai01` | Storyboard Sheet | `assets/art/storyboards/storyboard_miasma_marsh_ai01.png` | 3-6 | 瘴泽异变 |
| Batch 13 | `cg_seal_guardian_reveal_ai01` | CG PNG | `assets/art/promo/cg_seal_guardian_reveal_ai01.png` | 3-6 | Seal Guardian 揭示 |

## 每批执行清单

1. 从本 backlog 选择 `1` 个 Batch。
2. 从 `docs/assets/image-gen-prompt-queue.json` 复制对应 asset 的完整 `prompt`。
3. 为每个 asset 生成 `3-6` 个候选。
4. 使用 `scripts/assets/import_imagegen_outputs.py` 保存原始候选到 `assets/source/ai_generated/batch_XX/` 或外部资产库。
5. 选择 `1-2` 个方向做清稿。
6. 导出可接入版到目标路径。
7. 对需要图集化的资产运行 `python scripts/assets/build_asset_atlases.py --only <asset_id>`。
8. 运行 `python scripts/assets/build_asset_semantics.py` 和 `python scripts/assets/audit_asset_semantics.py --strict`，生成 / 复核语义标签。
9. 回填 `asset-manifest.md` 的来源、授权和状态。
10. 若接入 Godot，运行 `godot --headless --path . --import`。
11. 若影响 HUD、场景、Boss、动画或完成反馈，按 `asset-ingestion-checklist.md` 复核。
