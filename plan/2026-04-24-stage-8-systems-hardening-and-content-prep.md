# 阶段 8：系统稳固与内容生产前准备开发计划

## Summary

以当前已完成并合并的 `stage7` 为稳定基线，`stage8` 固定采用“参数数据化优先 + HUD 第二轮最小收口 + 敌人模板先行”的方案，为后续继续扩内容建立更稳的工程接口，但不引入新的主玩法能力、不新增敌人种类、不扩主流程长度。

本轮优先级固定为：

1. 参数数据化
2. HUD 第二轮
3. 敌人模板化

## Key Changes

### 参数数据化

- 本轮把当前最关键的可调参数从“散落在脚本导出字段”收口到只读配置资产
- 优先覆盖 3 类对象：
  - 玩家
  - 基础近战敌人
  - 当前主流程房间的最小门控/HUD 文案配置
- 推荐采用 Godot `Resource` 资产，不引入外部表格、JSON 解析或自定义编辑器工具

### HUD 第二轮

- 保留当前 `TutorialHUD` 作为唯一前台入口，不新建第二套 HUD
- 第二轮目标固定为“收口接口和表现层次”，不是扩功能
- HUD 调整范围固定为：
  - 明确分离“房间上下文提示”和“战斗状态显示”
  - 把当前 `step/prompt/health/dash` 的读取路径整理为稳定绑定接口
  - 为后续进入更多房间或更多敌人时保留一致的文案更新入口

### 敌人模板化

- 本轮模板化对象只选 `BasicMeleeEnemy`
- 目标不是立刻做第二类敌人，而是把当前“单敌人原型”整理成可复用基础模板
- 推荐拆成：
  - 基础敌人配置资源
  - 基础敌人脚本骨架
  - 当前近战敌人实现继续作为第一种具体模板实例

### 房间与主流程约束

- `Main` 本轮只允许做“接口收口”，不重做成正式房间图系统
- `TutorialRoom`、`CombatTrialRoom`、`GoalTrialRoom` 继续保留现有三段链路

## Public APIs / Interfaces

- 玩家侧新增稳定读取接口，推荐最少包括：
  - `get_current_health() -> int`
  - `get_max_health() -> int`
  - `is_dash_ready() -> bool`
  - `get_hud_status_snapshot()`
- 房间侧统一 HUD 上下文接口，推荐固定为：
  - `get_current_step_title() -> String`
  - `get_current_prompt_text() -> String`
  - `is_dash_available_in_hud() -> bool`
- 敌人模板侧统一基础契约：
  - `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
  - `defeated` 信号

## Test Plan

- 基线验证继续保留：
  - `godot --headless --path . --import`
  - Stage 1-7 GUT
  - `git diff --check`
- 新增 Stage 8 GUT，至少覆盖：
  - 玩家关键参数已从配置资源读取并成功应用
  - `BasicMeleeEnemy` 关键参数已从配置资源读取并成功应用
  - 房间/HUD 文案上下文能通过统一接口稳定读取
  - HUD 不再依赖分散探测式读取来拼接核心状态
  - 基础敌人模板契约不回归

## Assumptions

- `stage8` 固定优先做参数数据化，不先做大范围 UI 美术重做
- 参数数据化本轮只做到只读配置资源，不做热更新或编辑器工具
- 模板化本轮只先落在敌人侧，不先重做房间模板体系
