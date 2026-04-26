# Plugin Inventory

Last Updated: 2026-04-27

## 当前结论

当前阶段只默认启用：

- `godot_mcp`
- `gut`

其余插件目录可以保留，但不应默认写入 `project.godot` 的 `[editor_plugins]` 或 `[autoload]`。当前代码没有引用 `DialogueManager`、`ControllerIcons` 或 `BetterTerrain`，因此 2026-04-27 已从 `project.godot` 移除 `DialogueManager` 与 `ControllerIcons` autoload，以降低进入 Godot 项目时的默认加载面。

之前“一进入 Godot 项目就有多个报错”的高置信度原因不是“插件目录存在就会报错”，而是多种历史状态叠加：

- `project.godot` 早期曾残留 `BetterTerrain` autoload / UID 引用，而 `better-terrain` 在当前 Godot 4.6 环境下有解析和兼容性风险。
- `DialogueManager` 与 `ControllerIcons` 虽然没有在 `[editor_plugins]` 启用，但曾作为 `[autoload]` 默认加载；任何 autoload 都会在项目启动时参与加载。
- 清理 `.godot` 缓存后，历史 UID 引用容易重新暴露为 `Unrecognized UID`。
- `godot_mcp` 在 headless import 中会启动并停止 MCP bridge，这类日志不是错误；真正需要警惕的是旧 bridge 占用 `6505-6509` 导致当前会话错连。

## 插件状态表

| 插件 | 当前目录 | project.godot 状态 | 当前用途 | 建议 |
| --- | --- | --- | --- | --- |
| Godot MCP Pro | `addons/godot_mcp/` | editor plugin enabled | Codex / Godot MCP 运行态复核 | 保留并启用 |
| GUT | `addons/gut/` | editor plugin enabled | 阶段自动化测试 | 保留并启用 |
| better-terrain | `addons/better-terrain/` | disabled | 后续 tile / terrain 候选 | 暂不推荐启用；过去已验证有兼容性风险 |
| Dialogue Manager | `addons/dialogue_manager/` | disabled, no autoload | 后续 NPC / 佛门石碑 / 悬赏榜文本候选 | 有可用价值，但等叙事系统进入阶段计划再启用 |
| Controller Icons | `addons/controller_icons/` | disabled, no autoload | 后续键鼠 / 手柄提示 UI 候选 | 有可用价值，但等输入提示 UI 成型后再启用 |
| Aseprite Wizard | `addons/AsepriteWizard/` | disabled | 后续 sprite / Aseprite 素材导入候选 | 如果确定使用 Aseprite 做角色 / 敌人动画，值得启用 |
| Godot Saves Addon | `addons/GodotSavesAddon/` | disabled | 后续正式存档候选 | 当前不推荐；checkpoint 仍是运行期恢复点，正式存档前再评估 |
| Godot State Charts | `addons/godot_state_charts/` | disabled | 后续复杂敌人 / Boss 状态机候选 | Stage 15 Boss 若行为复杂，值得优先评估 |

## 当前已安装插件是否有用

短期必须使用：

- `godot_mcp`：用于 Godot 编辑器运行态复核、截图、场景树检查和 MCP 工具链。
- `gut`：当前测试体系依赖它，必须保留。

中期可能有用，但不应现在默认启用：

- `Dialogue Manager`：适合悬赏榜、佛门石碑、NPC 对话、剧情分支。建议等叙事 UI 或文本系统进入阶段计划时启用。
- `Controller Icons`：适合 Stage 16 的主菜单 / 暂停 / 输入提示 polish。建议等输入重绑定或手柄支持明确后启用。
- `Aseprite Wizard`：如果正式采用 Aseprite 生产 Luna、妖物和 Boss sprite，则有价值；如果继续使用 SVG / 手绘分层资产，则暂不需要。
- `Godot State Charts`：适合 Stage 15 之后的精英 / Boss 状态机；普通敌人当前无需引入。

当前不建议使用：

- `better-terrain`：过去已经造成解析 / UID / 兼容性问题，且当前关卡仍是灰盒平台与手工场景，不值得重新启用。
- `Godot Saves Addon`：当前没有正式存档系统，过早引入会扩大范围；等 Stage 16 之后再评估。

## 其他可能有用的 Godot 插件方向

不建议现在安装，但可以作为后续候选：

- 相机插件：若后续需要更细的镜头引导、区域边界、Boss 房镜头震动和过渡，可评估 Godot 4 生态中的相机辅助插件；当前项目相机需求仍可自研。
- 音频管理插件：Stage 16 如果进入 SFX / BGM 包装，可评估轻量音频管理插件；当前音频资产尚未进入接入阶段。
- 行为树 / AI 插件：如果 Boss 或多阶段敌人复杂度明显超过 `godot_state_charts` 的适用范围，再评估；当前不需要。
- 对话 / 任务插件：已有 `Dialogue Manager` 候选，暂不再并行引入另一个同类插件，避免脚本和资源格式分裂。
- 地图 / TileMap 工具：只有当 Stage 14-16 明确要从灰盒房间转向 tile-based 量产时才评估；不要为了“以后可能会用”提前启用。

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
