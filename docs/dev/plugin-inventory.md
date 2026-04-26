# Plugin Inventory

Last Updated: 2026-04-27

## 当前结论

当前阶段只默认启用：

- `godot_mcp`
- `gut`

其余插件目录可以保留，但不应默认写入 `project.godot` 的 `[editor_plugins]` 或 `[autoload]`。当前代码没有引用 `DialogueManager`、`ControllerIcons` 或 `BetterTerrain`，因此 2026-04-27 已从 `project.godot` 移除 `DialogueManager` 与 `ControllerIcons` autoload，以降低进入 Godot 项目时的默认加载面。

## 插件状态表

| 插件 | 当前目录 | project.godot 状态 | 当前用途 | 建议 |
| --- | --- | --- | --- | --- |
| Godot MCP Pro | `addons/godot_mcp/` | editor plugin enabled | Codex / Godot MCP 运行态复核 | 保留并启用 |
| GUT | `addons/gut/` | editor plugin enabled | 阶段自动化测试 | 保留并启用 |
| better-terrain | `addons/better-terrain/` | disabled | 后续 tile / terrain 候选 | 保留源码但不启用；重新启用前必须单独验证 |
| Dialogue Manager | `addons/dialogue_manager/` | disabled, no autoload | 后续 NPC / 剧情文本候选 | 当前不使用；剧情阶段再评估 |
| Controller Icons | `addons/controller_icons/` | disabled, no autoload | 后续输入提示 UI 候选 | 当前不使用；输入提示 UI 成型后再评估 |
| Aseprite Wizard | `addons/AsepriteWizard/` | disabled | 后续 Aseprite 素材导入候选 | 当前不使用；正式像素 / sprite 管线前再评估 |
| Godot Saves Addon | `addons/GodotSavesAddon/` | disabled | 后续正式存档候选 | 当前不使用；checkpoint 仍是运行期恢复点 |
| Godot State Charts | `addons/godot_state_charts/` | disabled | 后续复杂敌人 / Boss 状态机候选 | 当前不使用；Boss 原型复杂化后再评估 |

## 报错判断

进入 Godot 项目时如果出现多条插件报错，优先按以下顺序排查：

1. `project.godot` 是否残留非当前默认插件的 `[autoload]`。
2. `project.godot` 的 `[editor_plugins]` 是否启用了当前阶段不需要的插件。
3. `.godot` 导入缓存是否来自旧插件状态。
4. Godot MCP 是否在 headless import 中正常启动又退出。这种日志不等于错误。
5. `6505-6509` 是否有旧 `godot-mcp-pro` bridge 占用，导致当前会话错连。

## 启用新插件前检查

启用或重新启用插件前必须记录：

- 启用日期
- 启用目的
- 影响范围
- 修改了 `project.godot` 的哪些项
- `godot --headless --path . --import` 结果
- 是否需要新增 GUT 或人工复核

## 当前不建议删除的原因

- 多数插件目前只是已安装候选，不会在默认启动中加载。
- 删除第三方插件目录会产生较大 diff，且可能丢失后续评估素材。
- 真正影响启动面的不是“目录存在”，而是 `project.godot` 中的启用项与 autoload。

如果后续连续多个阶段都确认不需要某个候选插件，再单独开清理任务删除目录，并记录来源、授权和替代方案。
