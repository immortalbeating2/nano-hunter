# 角色 / 怪物通用模型锁治理修复设计

## 性质与范围

本轮是非 Stage 的专项修复，不增加房间、敌人、招式、伤害、AI、掉落或剧情。目标是把 Luna 已验证的 Model Lock 做法推广为所有生产角色 / 怪物 body 的统一资产契约，并修复 Seal Guardian 在旧 idle 与 Stage27 正式动作之间约 `29%` 的体量跳变。

本轮只复用和归一化现有透明动作资产，不生成新图片。若接触表发现无法通过现有源资产修复的身份漂移，保持 `identity_review_status = pending` 并登记后续重生成需求，不用节点 scale 或逐动作 offset 掩盖。

## 当前事实

- Luna 的 7 个 live body 已声明 `luna_model_v1`、canonical reference、`192x192` 画布、中心轴与脚底约束，并有全帧自动报告和运行态接触表。
- 四类旧普通敌人、Seal Guardian、雷蚀獠和夔影雷骸已有固定画布、底部归一化或 Animation State Contract，但没有跨动作共享 `model_id` / canonical reference。
- Seal Guardian 生产 idle 仍使用旧 `seal_guardian_idle_runtime_sheet_ai01`，alpha 高度中位数约 `128px`；其它正式状态使用 `seal_guardian_formal_motion_runtime_sheet_ai01`，非倒地帧高度最高 `168px`。这不是合法姿态变化，而是 live body 家族混用。
- 雷蚀獠的 3 张 body sheet 为 `224x192 / foot_y=184`；夔影雷骸的 5 张 body sheet 为 `288x256 / foot_y=246`，几何归一化稳定，但尚无身份母版、接触表和跨 sheet 门禁。
- `final_ready` 同时包含授权、清稿、人工审美和发布批准，不能等同于“模型身份一致”。Stage27 / Stage30 明确允许本地技术候选进入生产 Demo，但 Gate26H 和 external release 仍阻断。

## 状态分层

每个模型族同时维护四个互不替代的模型锁状态：

| 状态 | 含义 | 自动门禁 |
| --- | --- | --- |
| `geometry_lock_ready` | 画布、共享根锚、透明边界、canonical 尺寸与动作采样没有越界漂移 | Python 严格审计 |
| `identity_lock_ready` | 头顶 / 身体核心或髋部 / 脚底 / 根节点 / 前后关键轮廓的栅格语义锚点齐全，拓扑、比例与跨 sheet canonical 偏差通过 | Python 语义锚点严格审计 |
| `runtime_binding_allowed` | 允许进入当前本地 Alpha Demo 的生产脚本 / 场景 | GUT 反向扫描 live binding |
| `identity_review_status` | 脸型 / 头部、服装 / 甲胄、肢体数、轮廓特征和阶段变体由人工签核 | 接触表；`pending` 不伪装为人工通过 |

`identity_lock_ready` 是可重复计算的 2D 栅格技术门禁，不是代理或真人的审美批准。`final_ready` 继续由 `docs/assets/final-art-acceptance-gates.json` 管理授权与发布边界。外部发布仍要求 `identity_lock_ready = true`、`identity_review_status = approved` 且 `final_ready = true`。

## 通用 Model Lock Contract v1

权威清单位于 `docs/assets/character-creature-model-locks.json`。每个 live `.frames.json` 与 `.source.json` 必须复制同一模型族的机器字段：

- `contract_kind = character_creature_model_lock_v1`
- `contract_version = 1`
- `model_id`
- `canonical_reference` 与 `canonical_frame_index`
- `cell`
- `root_anchor_kind`
- `center_x / center_tolerance_px`
- `root_y / root_tolerance_px`
- `identity_height_ratio_min / max`
- `geometry_lock_ready`
- `identity_lock_ready`
- `runtime_binding_allowed`
- `identity_review_status`
- `semantic_anchor_contract`

`center_x` 和 `root_y` 是归一化后的视觉根锚，不要求攻击姿势的透明包围盒宽高完全不变。每个 sheet 单独声明 `identity_sample_indices` 作为接触表目检姿态，另以 `scale_sample_indices` 指定可与 canonical 比较体量的同类姿态；若后者省略则沿用前者。倒地末帧、夸张蓄力或合法冲刺伸展可以进入身份目检，但不得被错误用于 standing-scale 判定。

自动接触表还显示：

- 青线：共享 `center_x`；
- 金线：共享 `root_y`；
- 紫框：逐帧 alpha silhouette 包围盒；
- 橙点：alpha 脚底 / 接触点；
- 红菱形：每族手工限定头部搜索区内的头顶 / 冠顶落点；
- 绿点：人形髋部估计点，或四足 / 浮空体的 `body_core`；
- 蓝 / 紫点：朝向相关的前后关键轮廓端点；
- 帧下注记：实测 `center / foot / height / head / hip-or-core`。

这些锚点来自每个模型族显式声明的 `semantic_anchor_contract`：朝向、头部搜索区、身体核心比例、前后轮廓方向与容差都进入中央 JSON，并在逐帧 alpha 掩码上求实际不透明落点。它们用于 2D 栅格连续性，不冒充骨骼绑定或解剖真值；真正的脸、角、尾、武器、甲胄、肢体身份和动作重量仍通过人工特征清单签核。不存在髋关节的四足 / 浮空体必须使用 `body_core`，不得伪造 `hip_center`。

## 遗留闭环修订

2026-08-09 的复核确认首轮只形成了自动几何子集，以下内容重新列为本专项的退出门禁：

1. 八个模型族必须声明 `identity_lock_ready` 与 `semantic_anchor_contract`，且 active frames/source sidecar 完整复制。
2. 通用审计必须输出逐帧 `root / foot_contact / head_top / hip_center-or-body_core / front_contour / rear_contour`，并验证不透明落点、拓扑顺序、root 接触距离和 canonical 比例偏差。
3. 接触表必须显示上述语义锚点及图例，不能再只显示 center/root/alpha bbox。
4. 生产反向扫描必须从明确的生产 include / exclude 规则遍历全部 `scripts/` 与 `scenes/`，不能依赖五个硬编码子目录；`scripts/dev`、`scenes/dev` 与 `tests/` 必须显式排除。
5. Seal Guardian 与夔影雷骸必须分别生成本轮新鲜的真实窗口运行态全状态连续性 JSON 和截图；报告逐状态记录 asset、model、animation、frame、cell、transform 与屏幕 root，并证明没有跨 model、禁用 body 或隐式 transform 跳变。
6. `asset-manifest`、Stage17 设计、Stage30 资产矩阵和 `final-art-acceptance-gates.json` 必须双向引用同一机器契约；final-art gate 不得把技术身份锁冒充人工最终批准。

## 模型族

| 模型族 | Canonical | 画布 / 根锚 | 允许变体 |
| --- | --- | --- | --- |
| `luna_model_v1` | `luna_idle_runtime_sheet_ai03#0` | `192x192`、`x=96 +/-2`、既有地面脚底契约 | 姿态与动作轮廓；身份特征不变 |
| `basic_melee_model_v1` | `enemy_basic_melee_runtime_sheet_ai01#0` | `160x160`、`x=80 +/-1`、`root_y=149 +/-2` | 非血腥倒地压缩 |
| `ground_charger_model_v1` | `enemy_ground_charger_runtime_sheet_ai01#0` | `160x160`、`x=80 +/-1`、`root_y=149 +/-2` | telegraph / charge / recover / defeat |
| `aerial_sentinel_model_v1` | `enemy_aerial_sentinel_runtime_sheet_ai01#0` | `160x160`、`x=80 +/-1`、`root_y=149 +/-2` | hover 与倒地；root 是视觉根而非物理脚底 |
| `miasma_caster_model_v1` | `enemy_miasma_caster_runtime_sheet_ai01#0` | `160x160`、`x=80 +/-1`、`root_y=149 +/-2` | pulse 与 defeat |
| `seal_guardian_model_v1` | `seal_guardian_formal_motion_runtime_sheet_ai01#0` | `256x192`、`x=128 +/-1`、`root_y=184 +/-1` | 预警、攻击、恢复、破印、阶段、受击、倒地 |
| `thunder_fang_model_v1` | `stage30_thunder_fang_locomotion_runtime_ai01#0` | `224x192`、`x=112 +/-1`、`root_y=184 +/-2` | 蓄雷、攻击、反应、倒地 |
| `kui_thunder_boss_model_v1` | `stage30_kui_boss_phase1_presence_runtime_ai01#0` | `288x256`、`x=144 +/-2`、`root_y=245 +/-1` | phase2 只允许雷化、能量与规定姿态变化；主体身份不变 |

## 生产绑定规则

- live body 只能来自 `runtime_binding_allowed = true` 的清单资产。
- live 文件声明的 `model_id` 必须与当前脚本状态映射一致；一个状态切换不能隐式换到另一个模型族。
- Seal Guardian idle、warning、strike、recovery、stagger、phase、hit、defeat 全部统一使用 Stage27 formal motion body；旧 idle sheet退出 live binding，但保留为历史 / canonical 比较证据。
- Body 与 VFX 继续分层；VFX 不进入模型锁清单，也不能改变 body 的 transform、hitbox 或 damage authority。
- `identity_review_status = pending` 可用于本地技术候选，但必须保持 Gate26H / external release 阻断，不得写成 final art approved。

## 验证与退出门禁

1. 清单覆盖全部生产 live body；没有未知或遗漏绑定。
2. 每个 active asset 的 frames/source metadata 与清单一致，未来重建脚本不会擦掉模型锁。
3. 通用严格审计验证画布、中心根锚、root、采样体量、canonical reference 和状态分层。
4. 生成 8 个模型族接触表与一个总报告；自动几何失败为 `0`。
5. Seal Guardian 运行态所有状态只报告 `seal_guardian_formal_motion_runtime_sheet_ai01 / seal_guardian_model_v1`。
6. GUT 反向扫描 player / enemy / boss 生产脚本和场景，阻止未登记或 `runtime_binding_allowed=false` 的 body。
7. Godot 4.6.3 import、邻近 GUT、递归 GUT、主场景 smoke、Python lint / strict audit、`git diff --check` 通过。
8. 接触表不能替代真人身份与动作节奏签核；所有 `pending` 必须在状态和日志中可见。

## 2026-08-09 实施结论

- 已建立 `character_creature_model_lock_v1` 中央契约，覆盖 `8` 个模型族、`26` 张 body 证据；`25` 张 active / runtime allowed，旧 `seal_guardian_idle_runtime_sheet_ai01` 为唯一 `reference_rejected`。
- 全部 `52` 份 frames/source sidecar 已写入同一机器字段；Luna、Stage17 split、Stage17 派生、Stage27 与 Stage30 构建器均从中央 helper 回填。复跑契约写入为 `metadata_changed=0`。
- 严格像素审计为 `8 families / 26 assets / 0 failures`，并生成、逐张检查 `8` 张 contact sheet。审查图写入 `.gdignore` 的本地证据目录，不进入 Godot import 链。
- Seal Guardian 场景初始态、idle、异常 fallback 与捕获清单已统一到 `seal_guardian_formal_motion_runtime_sheet_ai01`；旧 idle 的 `122-132px` 高度不会再切入 formal body 的 `168px` 生产状态。
- 旧动作审计已兼容通用 schema，当前为 `20/20 active ready / 11 archived / 0 errors`；综合资产包 strict 继续通过。
- Godot `4.6.3` import、主场景 smoke、模型锁 / Stage15 / Stage17 / Stage27 / Stage30 邻近 GUT及递归 GUT `51 scripts / 337/337 tests / 9742 assertions` 通过。`identity_review_status=pending_gate26h` 与 external-release 授权仍未由本轮批准。
