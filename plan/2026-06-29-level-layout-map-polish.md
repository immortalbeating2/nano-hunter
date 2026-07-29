# Level Layout and Map Polish 正式计划

## Summary

本计划用于 Stage16 Alpha Demo 候选之后的系统性关卡场景和地图布置处理。目标是按 `LL-00` 到 `LL-06` 推进：先审计现有房间，再修通关阻塞，随后重排地图语义、接入 TileSet 样板、author 碰撞和 hazard，最后做运行态完整复核。

本轮不把所有房间一次性改成最终商业地图；先把关键路径和代表房间做到可看、可玩、可调，再决定是否需要 image_gen 重新生成地图资产或引入外部资产包。

## Stage Boundary / Preflight

- 前置基线：Stage16 Alpha Demo 候选已存在，Stage13-16 GUT 和资产审计已有通过记录。
- 当前问题：大量场景仍有灰盒矩形、visual preview 与碰撞分离不足、TileSet 未正式进入 runtime 地图布置、部分门控和平台语义需要逐房复核。
- 工作模式：固定永久工作树 + 阶段分支；本轮先产出计划，后续按 LL 批次小步实现。
- Preflight：
  - 运行 `godot --headless --path . --import`。
  - 确认 Godot MCP Pro 工具入口可用。
  - 运行最接近的 Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT，记录当前基线。
  - 不清理或覆盖用户已有资产与 ignored 本地截图证据。

## Goals

- 完成完整 Alpha Demo 路线的关卡场景审计。
- 修复所有 P0 可玩阻塞。
- 建立 LL-00 到 LL-06 的执行分计划。
- 明确 Godot MCP Pro、Godot 插件、image_gen、现有资产和外部资产包的分工。
- 至少规划 3-5 个关键样板房，作为后续地图布置质量基线。
- 明确每批验证命令、截图证据和退出条件。

## Non-Goals

- 不新增 Stage17 玩法目标。
- 不新增地图 UI、小地图、传送系统或正式存档。
- 不重写玩家控制、Boss AI、敌人状态机、攻击判定或能力系统。
- 不默认购买资产包或启用额外插件。
- 不一次性替换所有房间碰撞和 TileMap。

## Content Scope

优先覆盖：

- `tutorial_room`
- `stage13_miasma_marsh_entry_room`
- `stage13_miasma_marsh_*` 主线房间
- `stage14_air_dash_shrine_room`
- `stage14_air_dash_gate_room`
- `stage15_seal_guardian_boss_room`
- `stage16_seal_release_threshold_room`
- `stage16_talisman_relay_room`
- `stage16_corruption_purge_room`
- `stage16_alpha_demo_end_room`

次级覆盖：Stage9-12 旧灰盒房间，只做不破坏性检查，不在本轮优先重铺。

## Asset Scope

优先使用现有资产：

- `miasma_marsh_tileset_ai01`
- `shrine_trial_tileset_ai01`
- Stage13 / Stage14 / Stage15 / Stage16 环境图和 room art
- `shrine_gate_prop_atlas_ai01`
- `reusable_seal_props_ai01`
- `material_texture_atlas_ai01`
- `vfx_seal_magic_atlas_ai01`
- `vfx_combat_atlas_ai01`

image_gen 只在以下情况触发：

- TileSet 缺少必须的边缘、角块、平台块或 hazard 视觉。
- 背景误导碰撞或与南北朝东方奇幻方向冲突。
- 机关 / 门 / props 缺少状态图，导致门控读值不清。
- 外部资产包无法满足授权、风格或切片要求。

## Key Changes

- 新增设计方向文档：`spec-design/2026-06-29-level-layout-map-polish-direction.md`。
- 新增执行分计划：`docs/implementation-plans/2026-06-29-level-layout-map-polish-ll00-ll06.md`。
- 后续实现将按 LL 批次推进：
  - `LL-00` 关卡审计
  - `LL-01` P0 通关阻塞修复
  - `LL-02` 地图语义重排
  - `LL-03` TileSet / visual replacement 样板
  - `LL-04` collision / hazard / camera author
  - `LL-05` image_gen / asset pack polish
  - `LL-06` 全流程 QA 与收口

## Public Interfaces

本计划原则上不新增 public runtime interface。

允许继续沿用：

- `room_transition_requested(target_room_path: String, spawn_id: StringName)`
- `checkpoint_requested(room_path: String, spawn_id: StringName)`
- `bind_player(player)`
- `bind_main(main)`
- `get_spawn_position(spawn_id: StringName) -> Vector2`
- `get_camera_limits() -> Rect2i`
- `get_hud_context() -> Dictionary`
- `Main.get_demo_progress_snapshot() -> Dictionary`

如后续 LL 批次必须新增调试接口，只能作为测试或 dev 脚本使用，不进入正式玩法 API。

## Implementation Plan

1. `LL-00`：用 Godot MCP Pro 和脚本生成房间截图、节点/碰撞/TileMap 清单、P0/P1/P2 问题表。
2. `LL-01`：只修 P0 阻塞，保持 diff 小；每个修复补最小 GUT 或 MCP 复核。
3. `LL-02`：给关键房间明确主要意图，删除或调整没有意义的平台、门和障碍。
4. `LL-03`：在 3-5 个样板房接入现有 TileSet / background / prop visual，先不大规模迁移碰撞。
5. `LL-04`：为样板房 author collision、one-way、hazard Area、camera limits、spawn/checkpoint。
6. `LL-05`：根据 LL-03 / LL-04 的缺口使用 image_gen 生成缺失 tiles / props / parallax；外部资产包只作为备选。
7. `LL-06`：完整路线 MCP 试玩、截图、GUT、import、文档收口。

## Test Plan

基础命令：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage13/test_stage_13_second_content_zone_production.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
git diff --check
```

运行态验证：

- Godot MCP Pro 从主菜单点击开始。
- 逐段推进教程、Stage13、Stage14、Stage15、Stage16。
- 保存关键房间截图到 `tests/artifacts/local/level-layout-map-polish/`。
- 对可疑点使用 `capture_frames` 验证跳跃、dash、hazard、Boss room 动态读值。

## Manual Review / Runtime Review

MCP 复核必须覆盖：

- 是否能从开始推进到 Alpha Demo 终点。
- 每个关键房间的主目标是否一眼可读。
- 玩家是否能理解哪里可站、哪里危险、哪里可交互。
- TileSet / props / background 是否误导碰撞。
- HUD / 摄像机是否遮挡平台、门、敌人或危险区。
- 失败、重开、checkpoint、room transition 是否仍稳定。

## Documentation Updates

- 更新 `docs/progress/status.md`。
- 更新 `docs/progress/timeline.md`。
- 更新 `docs/progress/logs/YYYY-MM-DD.md`。
- LL 执行后更新 `docs/assets/asset-manifest.md` 或 `docs/assets/asset-production-roadmap.md`，只记录真实新增或状态变化。

## Exit Criteria

- LL-00 到 LL-06 的计划和执行证据完整。
- P0 通关阻塞清零。
- 至少 3-5 个关键样板房完成 visual / collision / hazard / camera 基线。
- Godot import、相关 GUT 和 `git diff --check` 通过。
- Godot MCP Pro 运行态截图和问题清单完成。
- 若需要 image_gen 或外部资产包，有明确缺口、prompt、路径、授权边界和验收规格。

## Assumptions

- 当前玩家控制和关卡主流程继续作为稳定基线，不在本轮重写。
- 现有 TileSet / environment assets 足够支撑第一批样板房。
- Godot MCP Pro 适合复核和小批编辑；大规模 TileMap 批量写入优先用脚本。
- 外部资产包不是必需项，只有当前资产无法满足读值或风格时才进入评估。

## Risks

- 大规模替换 TileMap 可能破坏通关路径，因此 LL-03 先 visual-only，LL-04 再 author collision。
- 购买资产包可能带来风格偏移和授权风险。
- image_gen 生成的 TileSet 可能边缘不连续，需要人工清稿或只做样板。
- 过早追求美术完整度会拖慢 P0 可玩问题修复。
