# Nano Hunter 正式 Demo 房间结构蓝图生成器。
# 该工具只生成设计审阅用 SVG 与机器可读 JSON，不修改 Godot 生产场景，也不生成正式美术。

[CmdletBinding()]
param(
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "spec-design\formal-demo-room-blueprints"
}
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Pt([double]$x, [double]$y) { return @($x, $y) }
function Route([string]$id, [string]$label, [string]$kind, [object[]]$points) {
    return [ordered]@{ id = $id; label = $label; kind = $kind; points = $points }
}
function Zone([double]$x, [double]$y, [string]$kind, [string]$label) {
    return [ordered]@{ x = $x; y = $y; kind = $kind; label = $label }
}
function Segment([string]$id, [string]$name, [string]$purpose, [string]$geometry, [string]$pressure, [string]$safety) {
    return [ordered]@{
        id = $id; name = $name; purpose = $purpose; geometry = $geometry
        pressure = $pressure; safety = $safety
    }
}

function Connection(
    [string]$id, [string]$type, [string]$targetRoom, [string]$sourceAnchor,
    [double]$sourceX, [double]$sourceY, [string]$targetSpawn,
    [double]$targetX, [double]$targetY, [string]$targetFacing,
    [string]$directionality, [string]$verb, [object[]]$requirements,
    [string]$blockedFeedback, [string]$mapRepresentation
) {
    return [ordered]@{
        connection_id = $id
        type = $type
        target_room = $targetRoom
        source_anchor_id = $sourceAnchor
        source_anchor_position = [ordered]@{ coordinate_space = "segment_normalized"; x = $sourceX; y = $sourceY }
        target_spawn_id = $targetSpawn
        target_spawn_position = [ordered]@{ coordinate_space = "segment_normalized"; x = $targetX; y = $targetY }
        target_facing = $targetFacing
        directionality = $directionality
        interaction_verb = $verb
        requirements = @($requirements)
        blocked_feedback = $blockedFeedback
        transition_feedback = "fade_room_title_destination_landmark"
        safe_arrival_contract = [ordered]@{
            ground_support = "continuous_floor_or_dedicated_landing"
            safe_runway = 160
            hazard_overlap = "forbidden"
        }
        anti_retrigger_contract = [ordered]@{
            arrival_outside_source_trigger = $true
            reentry_cooldown = "until_player_leaves_arrival_zone"
        }
        map_representation = $mapRepresentation
    }
}

function Interaction(
    [string]$id, [string]$worldObject, [string]$purpose, [string]$verb,
    [object[]]$requirements, [string]$stateOwner, [string]$persistence
) {
    return [ordered]@{
        interaction_id = $id
        world_object = $worldObject
        purpose = $purpose
        interaction_verb = $verb
        interaction_range = 48
        facing_required = $false
        requirements = @($requirements)
        lifecycle = @("locked", "available", "activated", "completed")
        feedback = [ordered]@{
            locked = "world_object_dimmed_plus_requirement_hint"
            available = "outline_pulse_plus_action_prompt"
            success = "state_vfx_sfx_and_map_update"
            repeat = "completed_state_without_duplicate_reward"
        }
        state_owner = $stateOwner
        persistence = $persistence
    }
}

function Encounter(
    [string]$id, [object[]]$enemyTypes, [string]$countAndPlacement,
    [string]$preRead, [string]$trigger, [string]$waves, [string]$lockRule,
    [string]$terrainTest, [string]$exitRule, [string]$failureReset,
    [string]$revisitRule, [string]$clearChange
) {
    return [ordered]@{
        encounter_id = $id
        enemy_types = @($enemyTypes)
        count_and_placement = $countAndPlacement
        pre_read = $preRead
        trigger = $trigger
        waves = $waves
        lock_rule = $lockRule
        terrain_and_ability_test = $terrainTest
        exit_rule = $exitRule
        failure_reset = $failureReset
        revisit_rule = $revisitRule
        clear_change = $clearChange
    }
}

function Reward(
    [string]$id, [string]$type, [string]$value, [string]$condition,
    [string]$visibility, [string]$branchCost, [string]$repeatRule,
    [string]$worldFeedback, [string]$mapFeedback
) {
    return [ordered]@{
        reward_id = $id
        type = $type
        value = $value
        condition = $condition
        visibility = $visibility
        branch_cost = $branchCost
        repeat_rule = $repeatRule
        world_feedback = $worldFeedback
        map_feedback = $mapFeedback
    }
}

$rooms = @(
    [ordered]@{
        id = "F01"; title = "初印试炼"; role = "四段基础教学"; scene = "res://scenes/rooms/tutorial_room.tscn"; segment_count = 4
        landmark = "封妖石阶与初印照壁"; persistent_state = @("tutorial_completed")
        routes = @(
            (Route "first" "首次路线" "first" @((Pt 0.05 0.56),(Pt 0.55 0.56),(Pt 1.15 0.38),(Pt 1.72 0.38),(Pt 2.18 0.56),(Pt 2.72 0.56),(Pt 3.18 0.48),(Pt 3.92 0.48))),
            (Route "speed" "熟练快线" "speed" @((Pt 0.05 0.56),(Pt 0.86 0.56),(Pt 1.42 0.38),(Pt 2.16 0.56),(Pt 3.92 0.48)))
        )
        zones = @((Zone 0.08 0.56 "entry" "新游戏出生"),(Zone 1.26 0.38 "platform" "安全跳跃台"),(Zone 2.34 0.56 "gate" "Dash 门楣"),(Zone 3.30 0.48 "enemy" "木偶靶"),(Zone 3.92 0.48 "exit" "通往 F02"))
        segments = @(
            (Segment "S1" "行步庭" "建立移动与镜头" "连续宽地面，轻微上坡；出口方向始终可见" "0/5" "入口后 160u 安全观察区"),
            (Segment "S2" "跃阶" "教学普通跳跃" "两级 48–80u 高差；落点宽度不小于 48u" "1/5" "失误落回下层，不触发跌落恢复"),
            (Segment "S3" "疾行廊" "教学地面 Dash" "低顶门楣与 80–96u 通道；不使用深坑" "1/5" "Dash 失败仍停在连续地板"),
            (Segment "S4" "初印照壁" "教学攻击并确认离场" "单靶、短台、开阔出口坡道" "1/5" "攻击区与 ExitZone 相隔至少 160u")
        )
    },
    [ordered]@{
        id = "F02"; title = "首次镇妖"; role = "首次实战与任务确认"; scene = "res://scenes/rooms/combat_trial_room.tscn"; segment_count = 3
        landmark = "镇妖悬令台"; persistent_state = @("forward_room_completed","first_bounty_claimed")
        routes = @((Route "first" "首次路线" "first" @((Pt 0.05 0.56),(Pt 0.68 0.56),(Pt 1.18 0.48),(Pt 1.78 0.48),(Pt 2.28 0.40),(Pt 2.92 0.40))),(Route "revisit" "回访直通" "revisit" @((Pt 0.05 0.56),(Pt 1.10 0.56),(Pt 2.92 0.40))))
        zones = @((Zone 0.08 0.56 "entry" "来自 F01"),(Zone 0.62 0.56 "observe" "敌情观察"),(Zone 1.46 0.48 "enemy" "首次单敌"),(Zone 2.25 0.40 "landmark" "悬令台"),(Zone 2.92 0.40 "exit" "通往 F03"))
        segments = @(
            (Segment "S1" "望敌台" "无伤观察敌人" "入口平台高于战区 32u，玩家先看见再下场" "1/5" "出生点不在敌人索敌与攻击范围"),
            (Segment "S2" "镇妖坪" "单敌应用与清场" "240u 宽主战坪，一处 48u 高侧台" "2/5" "清场结界只封前方，不封回程"),
            (Segment "S3" "悬令台" "任务结算并离场" "目标台在上层短阶，出口为连续驿道" "0/5" "回访时目标已完成且出口永久可用")
        )
    },
    [ordered]@{
        id = "F03"; title = "镇妖驿站"; role = "正式循环 Hub"; scene = "res://scenes/rooms/stage11_demo_end_room.tscn"; segment_count = 3
        landmark = "悬钟、赏榜与驿路界碑"; persistent_state = @("waystation_unlocked","bounty_cycle_completed")
        routes = @((Route "first" "首次进入瘴泽" "first" @((Pt 0.05 0.58),(Pt 0.75 0.58),(Pt 1.48 0.48),(Pt 2.92 0.48))),(Route "return" "战后归驿" "revisit" @((Pt 1.42 0.18),(Pt 1.42 0.48),(Pt 0.72 0.58))),(Route "speed" "熟练整备线" "speed" @((Pt 1.42 0.18),(Pt 1.70 0.48),(Pt 2.92 0.48))))
        zones = @((Zone 0.08 0.58 "entry" "来自 F02"),(Zone 0.72 0.58 "checkpoint" "恢复与存档"),(Zone 1.42 0.48 "landmark" "赏榜/悬钟"),(Zone 1.42 0.18 "waystation" "F18 返回"),(Zone 2.92 0.48 "exit" "通往 F04"))
        segments = @(
            (Segment "S1" "归队庭" "承接教程与提供恢复" "宽地面、低压、左回程口与恢复点" "0/5" "所有入口出生都远离其他 ExitZone"),
            (Segment "S2" "镇妖驿厅" "整备、赏榜、完成反馈" "双层大厅；上层驿路节点、下层交互区" "0/5" "交互区无敌、无环境危险"),
            (Segment "S3" "瘴泽界门" "明确下一目标" "向右缓坡抬升，远景可见瘴泽地标" "0/5" "普通户外出口不用实体门扇")
        )
    },
    [ordered]@{
        id = "F04"; title = "瘴泽入口"; role = "区域揭示与地标"; scene = "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"; segment_count = 3
        landmark = "倒悬镇妖塔与瘴泽水线"; persistent_state = @()
        routes = @((Route "first" "首次下泽" "first" @((Pt 0.05 0.34),(Pt 0.72 0.34),(Pt 1.18 0.52),(Pt 1.72 0.66),(Pt 2.35 0.56),(Pt 2.92 0.56))),(Route "speed" "返程快线" "speed" @((Pt 2.92 0.56),(Pt 2.18 0.38),(Pt 1.32 0.34),(Pt 0.05 0.34))))
        zones = @((Zone 0.08 0.34 "entry" "来自 F03"),(Zone 0.70 0.28 "landmark" "区域全景"),(Zone 1.52 0.70 "hazard" "浅瘴预告"),(Zone 2.30 0.42 "observe" "F07 门远景"),(Zone 2.92 0.56 "exit" "通往 F05"))
        segments = @(
            (Segment "S1" "界碑高岸" "三秒内建立区域方向" "高岸宽台，视线越过后两段" "0/5" "出生处完整地面 192u"),
            (Segment "S2" "下泽栈道" "由高到低进入生态区" "折线下降；浅瘴仅作视觉预告" "1/5" "任何落差都有可见下层承接"),
            (Segment "S3" "倒塔滩" "预告交叉能力门" "主路贴地，远景高处出现符印断层" "1/5" "出口前 128u 连续安全地面")
        )
    },
    [ordered]@{
        id = "F05"; title = "断瘴授印"; role = "风印与弹体反制教学"; scene = "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"; segment_count = 3
        landmark = "断瘴风印龛"; persistent_state = @("wind_seal_unlocked","forward_room_completed")
        routes = @((Route "first" "展示-授予-应用" "first" @((Pt 0.05 0.58),(Pt 0.72 0.58),(Pt 1.10 0.44),(Pt 1.52 0.44),(Pt 2.18 0.60),(Pt 2.92 0.48))),(Route "revisit" "回访快线" "revisit" @((Pt 0.05 0.58),(Pt 1.52 0.44),(Pt 2.92 0.48))))
        zones = @((Zone 0.08 0.58 "entry" "来自 F04"),(Zone 0.66 0.58 "projectile" "隔栏看弹体"),(Zone 1.40 0.44 "shrine" "风印安全授予"),(Zone 2.32 0.60 "enemy" "移动中斩弹"),(Zone 2.92 0.48 "exit" "通往 F06"))
        segments = @(
            (Segment "S1" "观瘴廊" "先理解弹体威胁" "隔栏与高差让弹体可见但不可伤及出生点" "1/5" "观察区与战区物理分隔"),
            (Segment "S2" "风印龛" "安全授予风印" "中心抬台、左右对称回旋空间" "0/5" "授予期间无敌且无敌人"),
            (Segment "S3" "断瘴坡" "移动中斩散弹体" "两级坡台，一名远程敌人，无混战" "2/5" "失败重试从本段左缘开始")
        )
    },
    [ordered]@{
        id = "F06"; title = "瘴气洼地"; role = "静态危险与能力回访"; scene = "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"; segment_count = 3
        landmark = "沉没佛首与瘴水盆地"; persistent_state = @("f06_air_dash_reward_claimed")
        routes = @((Route "first" "首次安全上层" "first" @((Pt 0.05 0.52),(Pt 0.62 0.52),(Pt 1.15 0.32),(Pt 1.82 0.32),(Pt 2.30 0.50),(Pt 2.92 0.50))),(Route "revisit" "Air Dash 下层奖励线" "revisit" @((Pt 0.05 0.52),(Pt 0.88 0.70),(Pt 1.42 0.76),(Pt 2.12 0.70),(Pt 2.92 0.50))),(Route "speed" "熟练上层直切" "speed" @((Pt 0.05 0.52),(Pt 1.20 0.32),(Pt 2.18 0.32),(Pt 2.92 0.50))))
        zones = @((Zone 0.08 0.52 "entry" "来自 F05"),(Zone 1.42 0.76 "reward" "Air Dash 回访奖励"),(Zone 1.42 0.86 "hazard" "瘴气洼地"),(Zone 2.92 0.50 "exit" "通往 F07"))
        segments = @(
            (Segment "S1" "洼地边缘" "展示上下两条线" "入口分成上层主路与可见下层诱饵" "1/5" "首次下落有返回踏台，不软锁"),
            (Segment "S2" "沉首盆地" "环境危险核心" "上层 80–105u 普通跳；下层瘴水跨距需 Air Dash" "2/5" "危险两侧均设 96u 安全台"),
            (Segment "S3" "升岸" "汇流并离场" "上下线在出口前汇流，地形向上收束" "1/5" "ExitZone 不覆盖回访落点")
        )
    },
    [ordered]@{
        id = "F07"; title = "交叉封印门"; role = "首次能力门预告与永久捷径"; scene = "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"; segment_count = 3
        landmark = "风雷双印断桥"; persistent_state = @("f07_cross_gate_completed")
        routes = @((Route "first" "首次绕行至 F08" "first" @((Pt 0.05 0.58),(Pt 0.72 0.58),(Pt 1.15 0.30),(Pt 1.86 0.30),(Pt 2.30 0.52),(Pt 2.92 0.52))),(Route "revisit" "风印+Air Dash 永久捷径" "revisit" @((Pt 0.05 0.58),(Pt 0.86 0.58),(Pt 1.46 0.58),(Pt 1.92 0.58))),(Route "speed" "已开门直通" "speed" @((Pt 1.92 0.58),(Pt 1.12 0.58),(Pt 0.05 0.58))))
        zones = @((Zone 0.08 0.58 "entry" "来自 F06"),(Zone 1.46 0.58 "ability_gate" "双能力封印"),(Zone 1.92 0.58 "shortcut" "通往 F14"),(Zone 2.92 0.52 "exit" "首次通往 F08"))
        segments = @(
            (Segment "S1" "断桥前庭" "让玩家先看见封印线" "连续地面直指中央门，绕行阶梯在上方" "0/5" "门前不设坑、不设伤害区"),
            (Segment "S2" "双印断桥" "表达风印与 Air Dash 双条件" "下层封印短跨，上层首次绕行桥" "1/5" "未满足条件时碰门只反馈、不位移"),
            (Segment "S3" "绕行出口" "保证首次流程继续" "上层下降回主路，右侧自然坡口进 F08" "1/5" "正反向出生均有 160u 地板")
        )
    },
    [ordered]@{
        id = "F08"; title = "瘴泽镇界点"; role = "恢复与方向重置"; scene = "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"; segment_count = 2
        landmark = "镇界石柱与净水池"; persistent_state = @("checkpoint_f08_unlocked")
        routes = @((Route "first" "恢复主路" "first" @((Pt 0.05 0.55),(Pt 0.72 0.55),(Pt 1.22 0.48),(Pt 1.92 0.48))),(Route "return" "F10 回环落点" "revisit" @((Pt 1.15 0.18),(Pt 1.15 0.48),(Pt 0.70 0.55))))
        zones = @((Zone 0.08 0.55 "entry" "来自 F07"),(Zone 0.78 0.52 "checkpoint" "镇界恢复点"),(Zone 1.15 0.18 "loop_entry" "F10 回环落点"),(Zone 1.92 0.48 "exit" "通往 F09"))
        segments = @(
            (Segment "S1" "净水池" "恢复、保存、降压" "宽阔单层地面，恢复柱居中" "0/5" "全房无敌、无伤害区"),
            (Segment "S2" "镇界坡" "重新指向分岔" "缓坡向右，F10 回环从上层落入" "0/5" "单向落点与主出口错开 192u")
        )
    },
    [ordered]@{
        id = "F09"; title = "瘴泽三路枢纽"; role = "三路分岔与多阶段复用"; scene = "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"; segment_count = 3
        landmark = "三面镇妖幡与枯树桥"; persistent_state = @("f09_air_dash_route_completed")
        routes = @((Route "first" "中层主路至 F12" "first" @((Pt 0.05 0.56),(Pt 0.72 0.56),(Pt 1.42 0.52),(Pt 2.92 0.52))),(Route "resource" "下层低风险至 F10" "branch" @((Pt 1.42 0.52),(Pt 1.60 0.78),(Pt 2.20 0.78))),(Route "challenge" "上层高风险至 F11" "branch" @((Pt 1.42 0.52),(Pt 1.72 0.24),(Pt 2.36 0.24))),(Route "revisit" "Air Dash 上层高速线" "revisit" @((Pt 0.05 0.56),(Pt 0.70 0.24),(Pt 1.72 0.24),(Pt 2.92 0.24))))
        zones = @((Zone 0.08 0.56 "entry" "来自 F08"),(Zone 1.42 0.52 "landmark" "三路判读点"),(Zone 2.20 0.78 "branch_exit" "F10 低风险"),(Zone 2.36 0.24 "branch_exit" "F11 高风险"),(Zone 2.92 0.52 "exit" "F12 主路"),(Zone 0.70 0.24 "ability_gate" "Air Dash 上层入口"),(Zone 2.92 0.24 "shortcut" "接 F12 快线"))
        segments = @(
            (Segment "S1" "枯桥引入" "远距离看见三条高度线" "中层入口，上下路线轮廓同时进入镜头" "0/5" "入口安全区不触发任一支路"),
            (Segment "S2" "三幡分岔" "完成风险/回报选择" "上层挑战、中层主路、下层资源；三条线形态不同" "1/5" "返回主判读点只需一次普通跳"),
            (Segment "S3" "三路出口" "将出口语义分开" "F11 用祭台阶、F12 用泽岸、F10 用下沉洞" "1/5" "三个 ExitZone 互不重叠且各有 96u 前庭")
        )
    },
    [ordered]@{
        id = "F10"; title = "瘴泽遗物藏所"; role = "低风险探索支路"; scene = "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"; segment_count = 2
        landmark = "半沉经函与破损佛龛"; persistent_state = @("marsh_relic_collected")
        routes = @((Route "first" "探索并回环" "branch" @((Pt 0.05 0.34),(Pt 0.62 0.34),(Pt 1.05 0.55),(Pt 1.48 0.72),(Pt 1.92 0.72))),(Route "speed" "已取遗物快退" "speed" @((Pt 0.05 0.34),(Pt 0.88 0.55),(Pt 1.92 0.72))))
        zones = @((Zone 0.08 0.34 "entry" "来自 F09"),(Zone 0.92 0.55 "secret" "可读破墙"),(Zone 1.34 0.66 "reward" "瘴泽遗物"),(Zone 1.92 0.72 "one_way_exit" "单向回 F08"))
        segments = @(
            (Segment "S1" "经函侧穴" "低风险探索与秘密墙" "短阶下行，破墙轮廓可从入口看见" "1/5" "无敌人；破墙前后均有宽地面"),
            (Segment "S2" "沉龛藏所" "领取遗物并形成永久回环" "奖励台后接不可逆缓坡/滑道回 F08" "0/5" "单向连接明确预告，不能误落入死亡区")
        )
    },
    [ordered]@{
        id = "F11"; title = "镇妖挑战祭台"; role = "高风险前送支路"; scene = "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"; segment_count = 3
        landmark = "三层镇妖祭台"; persistent_state = @("warden_sigil_collected","forward_room_completed")
        routes = @((Route "first" "挑战前送" "branch" @((Pt 0.05 0.62),(Pt 0.62 0.62),(Pt 1.05 0.48),(Pt 1.52 0.28),(Pt 2.12 0.42),(Pt 2.92 0.42))),(Route "revisit" "清场后直通" "revisit" @((Pt 0.05 0.62),(Pt 1.12 0.48),(Pt 2.92 0.42))))
        zones = @((Zone 0.08 0.62 "entry" "来自 F09"),(Zone 0.92 0.62 "enemy" "近地压力"),(Zone 1.52 0.28 "enemy" "高台法师"),(Zone 2.18 0.42 "reward" "镇妖挑战符"),(Zone 2.72 0.42 "clear_gate" "清场结界"),(Zone 2.92 0.42 "exit" "前送 F12"))
        segments = @(
            (Segment "S1" "祭台前坪" "承诺高风险支路" "窄入口后展开主战坪；可随时退回 F09" "2/5" "入口 160u 不锁门"),
            (Segment "S2" "三层祭坛" "远近敌组合挑战" "三高度但任一层均有两条脱离线" "4/5" "落差不伤害，底层不是瘴池"),
            (Segment "S3" "授符门" "发奖并前送" "奖励在结界前，清场后自然坡道进 F12" "0/5" "回访不重复锁门或发奖")
        )
    },
    [ordered]@{
        id = "F12"; title = "瘴泽封印目标"; role = "区域目标与能力前置"; scene = "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"; segment_count = 2
        landmark = "泽心封印轮"; persistent_state = @("miasma_goal_completed","forward_room_completed")
        routes = @((Route "first" "目标主路" "first" @((Pt 0.05 0.58),(Pt 0.62 0.58),(Pt 1.05 0.44),(Pt 1.52 0.44),(Pt 1.92 0.36))),(Route "branch_arrival" "F11 前送入口" "branch" @((Pt 0.08 0.24),(Pt 0.62 0.44),(Pt 1.05 0.44))))
        zones = @((Zone 0.08 0.58 "entry" "来自 F09"),(Zone 0.08 0.24 "entry" "来自 F11"),(Zone 1.05 0.44 "landmark" "封印轮"),(Zone 1.50 0.44 "goal" "区域目标"),(Zone 1.92 0.36 "exit" "通往 F13"))
        segments = @(
            (Segment "S1" "汇流岸" "合并主路与挑战支路" "上下两个入口在目标前安全汇流" "0/5" "两个出生点均不与目标触发器重叠"),
            (Segment "S2" "泽心封印" "完成区域目标并指向神龛" "中央大轮、右侧上行石阶形成明确下一目标" "1/5" "完成后永久开放；无强制伤害")
        )
    },
    [ordered]@{
        id = "F13"; title = "空行神龛"; role = "Air Dash 安全授予"; scene = "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"; segment_count = 1
        landmark = "悬空莲台与月轮神龛"; persistent_state = @("air_dash_unlocked")
        routes = @((Route "first" "授予路线" "first" @((Pt 0.05 0.56),(Pt 0.48 0.48),(Pt 0.95 0.56))),(Route "revisit" "回访直通" "revisit" @((Pt 0.05 0.56),(Pt 0.95 0.56))))
        zones = @((Zone 0.08 0.56 "entry" "来自 F12"),(Zone 0.50 0.45 "shrine" "Air Dash 神龛"),(Zone 0.95 0.56 "exit" "通往 F14"))
        segments = @((Segment "S1" "月轮神龛" "单一焦点授予能力" "一屏对称空间；中心抬台，左右落脚地连续" "0/5" "全房无敌；授予后右出口明确亮起"))
    },
    [ordered]@{
        id = "F14"; title = "空冲证明"; role = "Air Dash 展示、练习与强制应用"; scene = "res://scenes/rooms/stage14_air_dash_gate_room.tscn"; segment_count = 3
        landmark = "断空石梁与回风印桥"; persistent_state = @("air_dash_proof_completed","f07_cross_gate_completed")
        routes = @((Route "first" "展示-练习-证明" "first" @((Pt 0.05 0.58),(Pt 0.58 0.58),(Pt 1.05 0.42),(Pt 1.50 0.42),(Pt 2.10 0.36),(Pt 2.72 0.36),(Pt 2.92 0.48))),(Route "fallback" "失败安全回落" "fallback" @((Pt 2.10 0.36),(Pt 2.36 0.78),(Pt 1.82 0.78),(Pt 1.50 0.42))),(Route "revisit" "F07 双能力捷径" "revisit" @((Pt 1.82 0.78),(Pt 1.20 0.78))))
        zones = @((Zone 0.08 0.58 "entry" "来自 F13"),(Zone 0.70 0.40 "observe" "NPC/残影展示"),(Zone 1.45 0.42 "practice" "安全短跨"),(Zone 2.22 0.36 "ability_gate" "真实空冲证明"),(Zone 2.36 0.78 "safe_floor" "失败回落"),(Zone 1.20 0.78 "shortcut" "双向连接 F07"),(Zone 2.92 0.48 "exit" "通往 F15"))
        segments = @(
            (Segment "S1" "观空台" "无压力展示空冲" "入口与演示跨口同屏，跨距小于能力距离 60%" "0/5" "出生点连续地面 192u"),
            (Segment "S2" "回风练习" "自由练习并发现捷径回落层" "上层短跨、下层安全回落；回落层通向 F07" "1/5" "任何失败都落在本房地板"),
            (Segment "S3" "断空证明" "要求真实 airborne Air Dash" "105–110u 跨距、宽落点、通过后开门" "2/5" "危险区不覆盖起跳、落点或回落层")
        )
    },
    [ordered]@{
        id = "F15"; title = "回访集结"; role = "回访任务与 Boss 前集结"; scene = "res://scenes/rooms/stage14_backtrack_hub_room.tscn"; segment_count = 2
        landmark = "三印回照壁"; persistent_state = @("f06_air_dash_reward_claimed","f07_cross_gate_completed","f09_air_dash_route_completed")
        routes = @((Route "first" "集结至 Boss 路线" "first" @((Pt 0.05 0.56),(Pt 0.68 0.56),(Pt 1.15 0.46),(Pt 1.92 0.46))),(Route "return" "F16 返回整备" "revisit" @((Pt 1.92 0.46),(Pt 1.15 0.46),(Pt 0.68 0.56))))
        zones = @((Zone 0.08 0.56 "entry" "来自 F14"),(Zone 0.78 0.46 "landmark" "三点回访状态"),(Zone 1.45 0.46 "boss_gate" "Boss 路线封印"),(Zone 1.92 0.46 "exit" "通往 F16 / 来自 F16"))
        segments = @(
            (Segment "S1" "三印回照" "显示 F06/F07/F09 回访结果" "上下入口汇流到三枚状态印；不在本房发回访奖励" "0/5" "F07 必需状态缺失时只给方向反馈"),
            (Segment "S2" "集结坡" "进入高潮前整备" "上升缓坡与重型封印远景，节奏收紧" "0/5" "门前恢复余量，不设伏击")
        )
    },
    [ordered]@{
        id = "F16"; title = "封妖综合试炼"; role = "能力参与的综合战斗"; scene = "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"; segment_count = 4
        landmark = "四象缚妖阵"; persistent_state = @("forward_room_completed")
        routes = @((Route "first" "综合战斗主线" "first" @((Pt 0.05 0.60),(Pt 0.68 0.60),(Pt 1.20 0.60),(Pt 1.72 0.48),(Pt 2.18 0.30),(Pt 2.72 0.30),(Pt 3.18 0.48),(Pt 3.92 0.48))),(Route "ability" "Dash/Air Dash 战斗重写线" "revisit" @((Pt 0.05 0.60),(Pt 1.08 0.60),(Pt 1.82 0.30),(Pt 2.68 0.30),(Pt 3.92 0.48))))
        zones = @((Zone 0.08 0.60 "entry" "来自 F15"),(Zone 0.75 0.60 "enemy" "地面近战"),(Zone 1.42 0.60 "enemy" "冲锋通道"),(Zone 2.36 0.30 "enemy" "空中层"),(Zone 3.30 0.48 "clear_gate" "清场妖气结界"),(Zone 3.92 0.48 "exit" "通往 F17"))
        segments = @(
            (Segment "S1" "阵前缓冲" "读场与首个近战" "宽地面、一名近战、可退回入口" "2/5" "战斗锁区在出生点右侧 160u 后"),
            (Segment "S2" "冲锋廊" "用 Dash 改写地面交锋" "长直通道带一处侧台，冲锋敌可被跨越" "3/5" "通道两端各有脱战凹槽"),
            (Segment "S3" "悬阵层" "用 Air Dash 争夺高度" "两层平台与空中敌；上层是快线而非唯一线" "4/5" "跌落回 S2/S3 下层，不判死亡"),
            (Segment "S4" "缚妖门" "完成清场并进入 Boss" "汇流宽台、妖气结界、Boss 门远景" "1/5" "结界消散后出口前 192u 无敌区")
        )
    },
    [ordered]@{
        id = "F17"; title = "封印守卫"; role = "Boss 高潮"; scene = "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"; segment_count = 2
        landmark = "镇妖大印与守卫石座"; persistent_state = @("seal_guardian_defeated","forward_room_completed")
        routes = @((Route "first" "入口至锁镜 arena" "first" @((Pt 0.05 0.56),(Pt 0.62 0.56),(Pt 1.08 0.52),(Pt 1.62 0.52),(Pt 1.92 0.52))),(Route "retry" "本地失败重试" "retry" @((Pt 0.62 0.56),(Pt 1.08 0.52))))
        zones = @((Zone 0.08 0.56 "entry" "来自 F16"),(Zone 0.58 0.56 "checkpoint" "Boss 本地重试"),(Zone 0.92 0.52 "boss_gate" "重型封印门"),(Zone 1.46 0.52 "boss" "封印守卫"),(Zone 1.92 0.52 "exit" "胜利后通往 F18"))
        segments = @(
            (Segment "S1" "封门前室" "读招缓冲与本地重试" "安全前室、恢复锚点、单一重型 Boss 门" "0/5" "死亡后 10–25 秒内回到门前可操作状态"),
            (Segment "S2" "镇印大殿" "Boss 战" "单屏锁镜 arena；左右规避台不遮挡中心读招" "5/5" "场地边缘有实体墙，不靠全局跌落边界封场")
        )
    },
    [ordered]@{
        id = "F18"; title = "战后归驿"; role = "战后降压与返回 Hub"; scene = "res://scenes/rooms/stage15_completion_room.tscn"; segment_count = 2
        landmark = "解印天井与驿路法坛"; persistent_state = @("bounty_cycle_completed")
        routes = @((Route "first" "战后结算" "first" @((Pt 0.05 0.52),(Pt 0.70 0.52),(Pt 1.18 0.42),(Pt 1.62 0.42),(Pt 1.92 0.42))),(Route "return" "法坛返回 F03" "revisit" @((Pt 1.18 0.42),(Pt 1.62 0.42))))
        zones = @((Zone 0.08 0.52 "entry" "来自 F17"),(Zone 0.62 0.52 "landmark" "封印结果反馈"),(Zone 1.36 0.42 "waystation" "驿路法坛"),(Zone 1.92 0.42 "exit" "返回 F03"))
        segments = @(
            (Segment "S1" "解印天井" "战后呼吸与结果反馈" "开阔平地、向上打开天空轮廓，无敌无陷阱" "0/5" "Boss 门后出生点与回程触发器相隔一整屏"),
            (Segment "S2" "归驿法坛" "明确闭合悬赏循环" "短上行至法坛；远端连接拥有独立驿路语义" "0/5" "交互确认后切房，不通过跑出地板触发")
        )
    }
)

# V2 连接矩阵是唯一跨房真源；坐标使用“屏段编号 + 屏内比例”的连续归一空间。
$connectionsByRoom = [ordered]@{
    F01 = @(
        (Connection "F01_to_F02" "adjacent_boundary" "F02" "right_exit" 3.92 0.48 "combat_entry" 0.08 0.56 "right" "one_way_progression" "cross" @("tutorial_completed") "教学未完成时出口保持可见但不切房" "main_exit")
    )
    F02 = @(
        (Connection "F02_to_F03" "architectural_door" "F03" "bounty_exit" 2.92 0.40 "stage11_demo_end_start" 0.08 0.58 "right" "one_way_progression" "confirm" @("first_bounty_claimed") "未清场或未确认悬令时门洞显示镇妖符" "main_exit"),
        (Connection "F02_to_F01" "adjacent_boundary" "F01" "left_return" 0.08 0.56 "tutorial_return" 3.82 0.48 "left" "return_pair" "cross" @() "始终可回退" "return_exit")
    )
    F03 = @(
        (Connection "F03_to_F04" "adjacent_boundary" "F04" "marsh_road" 2.92 0.48 "stage13_entry_start" 0.08 0.34 "right" "two_way_pair" "cross" @("waystation_unlocked") "未完成驿站说明时路引高亮但不切房" "main_exit")
    )
    F04 = @(
        (Connection "F04_to_F05" "adjacent_boundary" "F05" "right_marsh_path" 2.92 0.56 "stage13_miasma_start" 0.08 0.58 "right" "two_way_pair" "cross" @() "无阻挡" "main_exit"),
        (Connection "F04_to_F03" "adjacent_boundary" "F03" "left_waystation_path" 0.08 0.34 "stage11_demo_end_return" 2.80 0.48 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F05 = @(
        (Connection "F05_to_F06" "ability_gate" "F06" "wind_seal_exit" 2.92 0.48 "stage13_miasma_start" 0.08 0.52 "right" "two_way_pair" "confirm" @("wind_seal_unlocked") "风印龛未激活时出口瘴幕回卷并提示祭龛" "main_exit"),
        (Connection "F05_to_F04" "adjacent_boundary" "F04" "left_entry" 0.08 0.58 "stage13_entry_return" 2.80 0.56 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F06 = @(
        (Connection "F06_to_F07" "adjacent_boundary" "F07" "right_rise" 2.92 0.50 "stage13_gate_start" 0.08 0.58 "right" "two_way_pair" "cross" @() "无阻挡" "main_exit"),
        (Connection "F06_to_F05" "adjacent_boundary" "F05" "left_rise" 0.08 0.52 "stage13_caster_return" 2.80 0.48 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F07 = @(
        (Connection "F07_to_F08" "adjacent_boundary" "F08" "upper_bypass_exit" 2.92 0.52 "stage13_checkpoint_start" 0.08 0.55 "right" "two_way_pair" "cross" @() "双能力不足不影响上层普通出口" "main_exit"),
        (Connection "F07_to_F06" "adjacent_boundary" "F06" "left_return" 0.08 0.58 "stage13_miasma_return" 2.80 0.50 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit"),
        (Connection "F07_to_F14" "remote_waystation" "F14" "cross_seal_altar" 1.92 0.58 "stage14_gate_from_wind_cross" 1.20 0.78 "right" "two_way_shortcut" "confirm" @("wind_seal_unlocked", "air_dash_unlocked") "风印与空行印分别点亮；条件不足只反馈且不位移" "ability_shortcut")
    )
    F08 = @(
        (Connection "F08_to_F09" "adjacent_boundary" "F09" "right_slope" 1.92 0.48 "stage13_branch_hub_start" 0.08 0.56 "right" "two_way_pair" "cross" @() "无阻挡" "main_exit"),
        (Connection "F08_to_F07" "adjacent_boundary" "F07" "left_slope" 0.08 0.55 "stage13_gate_return" 2.80 0.52 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F09 = @(
        (Connection "F09_to_F12" "adjacent_boundary" "F12" "middle_main_exit" 2.92 0.52 "stage13_goal_start" 0.08 0.58 "right" "two_way_main" "cross" @() "无阻挡" "main_exit"),
        (Connection "F09_to_F08" "adjacent_boundary" "F08" "left_return" 0.08 0.56 "stage13_checkpoint_return" 1.80 0.48 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit"),
        (Connection "F09_to_F10" "one_way_terrain" "F10" "lower_branch_drop" 2.20 0.78 "stage13_resource_branch_start" 0.08 0.34 "right" "one_way_branch" "fall_or_slide" @() "下穿入口先显示单向滑道与回环目的地" "resource_branch"),
        (Connection "F09_to_F11" "architectural_door" "F11" "upper_challenge_steps" 2.36 0.24 "stage13_challenge_branch_start" 0.08 0.62 "right" "two_way_branch" "confirm" @() "祭台阶以高风险符号提示但不锁定" "challenge_branch"),
        (Connection "F09_fast_to_F12" "ability_gate" "F12" "air_dash_upper_exit" 2.92 0.24 "stage13_goal_from_fast_route" 0.08 0.24 "right" "one_way_shortcut" "air_dash" @("air_dash_unlocked") "未获得空冲时上层断口保持不可达并显示空行印" "ability_shortcut")
    )
    F10 = @(
        (Connection "F10_to_F08" "one_way_terrain" "F08" "return_slide" 1.92 0.72 "stage13_checkpoint_from_resource_branch" 1.15 0.18 "right" "one_way_loop" "fall_or_slide" @() "滑道前用地形箭头预告不可逆回环" "permanent_loop")
    )
    F11 = @(
        (Connection "F11_to_F12" "encounter_gate" "F12" "clear_gate_exit" 2.92 0.42 "stage13_goal_from_challenge_branch" 0.08 0.24 "right" "one_way_forward" "clear" @("encounter_cleared") "未清场时妖气结界显示剩余敌人方向" "challenge_forward"),
        (Connection "F11_to_F09" "adjacent_boundary" "F09" "left_retreat" 0.08 0.62 "stage13_challenge_branch_return" 2.36 0.24 "left" "return_pair" "cross" @() "锁区前与清场后始终可退" "return_exit")
    )
    F12 = @(
        (Connection "F12_to_F13" "architectural_door" "F13" "shrine_steps" 1.92 0.36 "stage14_air_dash_shrine_start" 0.08 0.56 "right" "two_way_pair" "confirm" @("miasma_goal_completed") "封印目标未完成时神龛路口保持实体封口并指回封印轮" "main_exit"),
        (Connection "F12_to_F09" "adjacent_boundary" "F09" "left_return" 0.08 0.58 "stage13_branch_hub_return" 2.80 0.52 "left" "two_way_main" "cross" @() "左侧返回边界始终可见且有连续地面" "return_exit")
    )
    F13 = @(
        (Connection "F13_to_F14" "ability_gate" "F14" "air_dash_exit" 0.95 0.56 "stage14_air_dash_gate_start" 0.08 0.58 "right" "two_way_pair" "confirm" @("air_dash_unlocked") "神龛未激活时右门显示空行印并保持关闭" "main_exit"),
        (Connection "F13_to_F12" "architectural_door" "F12" "left_return" 0.08 0.56 "stage13_goal_return" 1.80 0.36 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F14 = @(
        (Connection "F14_to_F15" "ability_gate" "F15" "proof_exit" 2.92 0.48 "stage14_backtrack_hub_start" 0.08 0.56 "right" "two_way_pair" "air_dash" @("air_dash_proof_completed") "证明未完成时断空门反馈真实空冲要求；不与祭坛捷径共用触发器" "main_exit"),
        (Connection "F14_to_F13" "adjacent_boundary" "F13" "left_return" 0.08 0.58 "stage14_shrine_return" 0.86 0.56 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit"),
        (Connection "F14_to_F07" "remote_waystation" "F07" "lower_cross_seal_altar" 1.20 0.78 "stage13_gate_from_wind_cross" 1.92 0.58 "left" "two_way_shortcut" "confirm" @("wind_seal_unlocked", "air_dash_unlocked") "祭坛条件不足时双色符印分别反馈；不会触发 F15 普通出口" "ability_shortcut")
    )
    F15 = @(
        (Connection "F15_to_F16" "boss_gate" "F16" "gauntlet_gate" 1.92 0.46 "stage15_mixed_gauntlet_start" 0.08 0.60 "right" "two_way_pair" "confirm" @("f07_cross_gate_completed") "F07 捷径未完成时回照壁指向 F07；F06/F09 仅显示可选收益" "main_exit"),
        (Connection "F15_to_F14" "adjacent_boundary" "F14" "left_return" 0.08 0.56 "stage14_gate_return" 2.80 0.48 "left" "two_way_pair" "cross" @() "无阻挡" "return_exit")
    )
    F16 = @(
        (Connection "F16_to_F17" "encounter_gate" "F17" "gauntlet_clear_gate" 3.92 0.48 "stage15_boss_start" 0.08 0.56 "right" "two_way_pair" "clear" @("encounter_cleared") "未清场时妖气结界显示当前战段与剩余敌人" "boss_approach"),
        (Connection "F16_to_F15" "adjacent_boundary" "F15" "left_retreat" 0.08 0.60 "stage14_hub_return" 1.80 0.46 "left" "two_way_pair" "cross" @() "首段锁区前与清场后可退" "return_exit")
    )
    F17 = @(
        (Connection "F17_to_F18" "encounter_gate" "F18" "victory_exit" 1.92 0.52 "stage15_completion_start" 0.08 0.52 "right" "one_way_progression" "clear" @("seal_guardian_defeated") "Boss 未败时胜利出口不存在，只保留 arena 边界" "main_exit"),
        (Connection "F17_to_F16" "boss_gate" "F16" "boss_entry_door" 0.08 0.56 "stage15_mixed_gauntlet_return" 3.80 0.48 "left" "return_before_pull" "confirm" @() "Boss 拉起后暂时封门，失败重置后重新开放" "return_exit")
    )
    F18 = @(
        (Connection "F18_to_F03" "remote_waystation" "F03" "return_waystation" 1.36 0.42 "stage11_demo_end_start" 1.42 0.18 "right" "one_way_hub_loop" "confirm" @("seal_guardian_defeated") "必须站在法坛范围内确认；跑出地板不会切房" "hub_return"),
        (Connection "F18_to_F17" "architectural_door" "F17" "left_boss_door" 0.08 0.52 "stage15_boss_return" 1.80 0.52 "left" "return_pair" "cross" @() "胜利后门洞保持开放" "return_exit")
    )
}

function Timing([string]$firstVisit, [string]$revisit, [string]$pressureRhythm, [string]$beforeAfter, [int]$shortcutSavingSeconds) {
    return [ordered]@{
        first_visit = $firstVisit
        revisit = $revisit
        pressure_and_rhythm = $pressureRhythm
        before_after_contrast = $beforeAfter
        shortcut_saving_seconds = $shortcutSavingSeconds
    }
}

$knowledgeByRoom = [ordered]@{
    F01 = @("只知道基础移动目标", "移动、普通跳、地面 Dash、攻击与连续出口", "教学地形可快速直穿且无死亡坑", "能独立进入首次镇妖")
    F02 = @("会基础移动与攻击", "先观察、再入战区、清场后确认悬令", "清场状态与奖励不会重复", "正式悬赏循环从驿站开始")
    F03 = @("首次悬赏已完成", "checkpoint、赏榜、相邻道路与远端法坛是不同交互", "可在此恢复并读取回访状态", "F04 是连续瘴泽道路")
    F04 = @("正离开安全 Hub", "区域地标、瘴气视觉语言与远处能力门", "高岸是返程定向点", "前方将先取得断瘴能力")
    F05 = @("看见弹体但尚无反制", "观察弹体、激活风印、移动中斩散弹体", "神龛已完成时直接走应用快线", "风印可处理后续符印与弹体")
    F06 = @("会使用风印", "上层是首访安全线，下层瘴地是 Air Dash 回访线", "获得 Air Dash 后可取下层奖励并高速横越", "前方有双能力门但首访可绕行")
    F07 = @("只有风印，空行印尚缺", "普通 F08 出口、双能力封印与主动祭坛捷径彼此分离", "风印+Air Dash 后可确认往返 F14", "首次流程继续到 F08")
    F08 = @("刚绕过能力门", "恢复、checkpoint、F10 单向回环落点和 F09 方向", "F10 返回不会误触 F07/F09 出口", "下一房是安全的三路判读点")
    F09 = @("知道主目标在前方", "中层主路、下层资源、上层挑战和 Air Dash 快线", "下穿与空冲分别对应不同路线", "选择会在 F08/F12 汇回主线")
    F10 = @("主动选择低风险资源支路", "破墙、遗物与不可逆滑道回 F08", "遗物只领一次，空房可快退", "回到 F08 后再进入 F09")
    F11 = @("主动选择高风险前送支路", "可退入口、双层战斗、清场授符和前送 F12", "清场后永久旁路且不重复发奖", "将从高位入口抵达 F12")
    F12 = @("主路与挑战支路在此汇流", "主动完成封印目标、可返回 F09、再进入 F13", "目标完成后地图和封口永久更新", "下一房安全授予 Air Dash")
    F13 = @("已完成瘴泽目标", "确认神龛、取得 Air Dash、输入保护与激活反馈", "已激活神龛不重复授予", "右侧出口立即要求应用新能力")
    F14 = @("刚取得 Air Dash", "先展示、再练习、失败回落、真实证明；下层祭坛回 F07", "F15 普通主路和 F07 祭坛捷径绝不共用触发", "证明后进入回访集结")
    F15 = @("拥有风印与 Air Dash", "F07 是必需回访，F06/F09 是可选收益，右侧是 Boss 路线", "回照壁持续显示三处状态", "满足必需状态后进入综合试炼")
    F16 = @("两项能力都可用于战斗", "近战、冲锋、空中压力与清场门的四段组合", "能力提供替代线而非唯一解", "清场后进入 Boss 前室")
    F17 = @("已通过综合试炼", "本地 checkpoint、Boss 门、锁镜读招和胜利出口", "失败可在 10–25 秒内重开", "胜利后进入安全结算房")
    F18 = @("Boss 已败", "结果反馈、完成奖励与主动法坛返回 Hub", "法坛完成后 Hub 显示闭环状态", "回到 F03 而非跑出地板或自动传送")
}

$timingByRoom = [ordered]@{
    F01 = (Timing "180-240s" "25-40s" "0→1/5，四个短教学拍点" "新游戏定向→首次应用" 0)
    F02 = (Timing "120-180s" "20-35s" "1→2→0/5，观察-战斗-结算" "教学低压→首次胜利" 0)
    F03 = (Timing "60-120s" "25-50s" "全程0/5，恢复与决策停顿" "首次胜利→区域出发" 0)
    F04 = (Timing "60-90s" "35-55s" "0→1/5，长镜头揭示" "Hub静止→环境行进" 12)
    F05 = (Timing "120-180s" "30-50s" "1→0→2/5，观察-授予-应用" "环境预告→单机制战斗" 55)
    F06 = (Timing "90-150s" "35-60s" "1→2→1/5，上下路线交错" "单机制战斗→环境危险" 35)
    F07 = (Timing "60-100s" "20-35s" "0→1→1/5，门前停顿后绕行" "危险→门控判读" 210)
    F08 = (Timing "30-60s" "20-35s" "全程0/5，恢复呼吸" "门控→安全重置" 0)
    F09 = (Timing "90-150s" "35-60s" "0→1→1/5，观察-选择-离场" "恢复→路线决策" 45)
    F10 = (Timing "90-150s" "20-35s" "1→0/5，探索后回环" "选择→低压奖励" 55)
    F11 = (Timing "150-240s" "25-45s" "2→4→0/5，承诺-高压-发奖" "选择→高风险前送" 80)
    F12 = (Timing "90-150s" "25-45s" "0→1/5，汇流后目标确认" "支路收束→目标完成" 0)
    F13 = (Timing "45-90s" "15-25s" "全程0/5，单焦点授予" "目标完成→安全赋能" 0)
    F14 = (Timing "120-180s" "30-55s" "0→1→2/5，展示-练习-证明" "安全赋能→动作证明" 210)
    F15 = (Timing "60-120s" "30-55s" "全程0/5，状态复盘与集结" "动作证明→高潮蓄势" 75)
    F16 = (Timing "240-360s" "120-200s" "2→3→4→1/5，四段递进" "集结→综合高压" 70)
    F17 = (Timing "300-480s" "180-360s" "0→5/5，前室停顿后Boss峰值" "综合战斗→高潮" 0)
    F18 = (Timing "60-120s" "25-45s" "全程0/5，战后降压" "Boss峰值→闭环呼吸" 0)
}

$safeRoomReasons = [ordered]@{
    F01 = "只有不造成伤害的教学木偶，职责是输入学习。"
    F03 = "Hub 承担恢复、整备与路线决策。"
    F04 = "区域揭示房不叠加战斗，保证地标与危险预读。"
    F06 = "环境危险是唯一压力源，避免遮蔽上下路线学习。"
    F07 = "门控判读房不使用敌人干扰三种出口语义。"
    F08 = "checkpoint 房必须全房安全。"
    F09 = "选择区保持安全，让三高度四路线可读。"
    F10 = "低风险支路用探索成本而非战斗成本。"
    F12 = "区域目标以主动交互收束，不与战斗混在汇流出生区。"
    F13 = "能力授予房保持单焦点和输入保护。"
    F14 = "能力证明只考移动，不混入敌人变量。"
    F15 = "Boss 前集结房用于状态复盘和恢复节拍。"
    F18 = "战后结算房必须无敌、无陷阱。"
}

$encountersByRoom = [ordered]@{
    F02 = @((Encounter "F02_first_hunt" @("ground_melee_warden") "1 名，位于主战坪中心，入口观察台外" "敌人轮廓与巡逻范围在下场前完整可见" "玩家离开 160u 入口缓冲" "single_wave" "只封前方悬令门，不封左侧退路" "普通攻击、闪避和站位" "可退到观察台脱战" "重置敌人与结界，玩家回到观察台" "清场后不再生成" "悬令台亮起并永久开放 F03 门"))
    F05 = @((Encounter "F05_projectile_lesson" @("miasma_caster") "1 名，位于 S3 远端高差后" "S1 隔栏先看见同型弹体" "风印授予完成且玩家进入 S3" "single_wave" "不锁回风印龛" "移动中用风印斩散弹体" "可退回神龛安全区" "敌人重置，玩家回到 S3 左缘" "风印已取得时仍保留一次可绕过应用战" "出口瘴幕消散"))
    F11 = @((Encounter "F11_altar_challenge" @("ground_melee_warden", "miasma_caster") "底层 1 近战 + 上层 1 法师，错开水平攻击轴" "两敌在锁区前均可见且有退路" "玩家越过祭台前坪锁线" "single_composed_wave" "锁战区两端，但保留两条层间脱离线" "风印反弹体、普通跳换层与近战站位" "锁区前可退出；触发后必须清场" "重置两敌、结界与奖励，玩家回到前坪" "清场后全房旁路且不重复生成" "挑战符出现，F12 前送门开放"))
    F16 = @(
        (Encounter "F16_ground_opening" @("ground_melee_warden") "S1 一名近战，战线位于出生缓冲右侧" "入场即可看见但不在索敌范围" "越过首段锁线" "wave_1" "只锁当前屏段" "基础攻防与退路利用" "清完本段或退回缓冲" "本段敌人重置，玩家回 S1 左缘" "整房清场后不再生成" "S2 结界消散"),
        (Encounter "F16_dash_corridor" @("charging_beast") "S2 一名冲锋敌，长廊中线" "冲锋蓄力线与侧台同屏可见" "进入长廊中心" "wave_2" "锁 S2 两端" "地面 Dash 跨越或侧台规避" "必须清场" "只重置 S2，玩家回长廊左凹槽" "整房清场后不再生成" "S3 上层路径亮起"),
        (Encounter "F16_air_layer" @("miasma_caster", "airborne_wisp") "S3 上层法师 1 + 空中妖灵 1，下层保留普通路线" "进入前可看见上下两条攻击线" "玩家进入 S3" "wave_3" "锁 S3，不封安全下层" "Air Dash 抢高、风印断弹体；下层仍可解" "必须清场" "只重置 S3，玩家回下层安全台" "整房清场后不再生成" "Boss 门妖气结界消散"))
    F17 = @((Encounter "F17_seal_guardian" @("seal_guardian_boss") "1 名 Boss，arena 中心；玩家从左前室进入" "门前壁画与石座先展示体型和招式方向" "玩家确认 Boss 门并进入 arena" "boss_phases" "锁镜并封左右实体门" "读招、地面 Dash、Air Dash 与风印综合应用" "开战后仅通过胜利或失败重置离开" "Boss、arena 与门复位，玩家回本地 checkpoint" "击败后永久为空场" "锁镜解除、胜利出口和 F18 地标亮起"))
}

$hazardsByRoom = [ordered]@{
    F01 = [ordered]@{ hazards=@("教学高差"); pre_read="所有下层落点同屏可见"; damage_and_knockback="无环境伤害"; fall_rule="失误落回连续下层"; safe_floor="每段均有完整承接地面"; nearest_retry="当前教学段起点"; failure_reset="仅重置当前提示，不切房" }
    F02 = [ordered]@{ hazards=@("单敌攻击"); pre_read="观察台先读巡逻与攻击范围"; damage_and_knockback="沿用玩家战斗受击"; fall_rule="全房无死亡落差"; safe_floor="主战坪和观察台"; nearest_retry="观察台"; failure_reset="重置敌人与战区结界" }
    F03 = [ordered]@{ hazards=@(); pre_read="无危险"; damage_and_knockback="禁用"; fall_rule="所有平台下方有 Hub 地板"; safe_floor="全房"; nearest_retry="checkpoint"; failure_reset="无房内失败状态" }
    F04 = [ordered]@{ hazards=@("浅瘴视觉预告"); pre_read="水线与色彩先于接近出现"; damage_and_knockback="首访不造成伤害"; fall_rule="折线下降均有可见承接"; safe_floor="高岸、栈道、出口前庭"; nearest_retry="段首宽台"; failure_reset="回到当前段上一个宽台" }
    F05 = [ordered]@{ hazards=@("施法弹体"); pre_read="隔栏观察同型弹体"; damage_and_knockback="弹体受击但不把玩家击入坑"; fall_rule="全房连续地板"; safe_floor="神龛区与 S3 左缘"; nearest_retry="S3 左缘"; failure_reset="重置单施法敌与弹体" }
    F06 = [ordered]@{ hazards=@("下层瘴气", "跨距失败"); pre_read="入口同时展示上层主路与下层瘴水"; damage_and_knockback="瘴气按周期伤害，不连续锁死"; fall_rule="失败落到安全回落台而非越界"; safe_floor="上层主路与危险两侧 96u 台"; nearest_retry="本段入口安全台"; failure_reset="重置瘴气节拍与奖励接近状态" }
    F07 = [ordered]@{ hazards=@("能力门阻挡"); pre_read="双色符印和上层绕行同时可见"; damage_and_knockback="门控无伤害无击退"; fall_rule="门前与祭坛均是连续地面"; safe_floor="三种出口各自 160u 前庭"; nearest_retry="当前前庭"; failure_reset="条件不足仅反馈，不改变位置或房间" }
    F08 = [ordered]@{ hazards=@(); pre_read="无危险"; damage_and_knockback="禁用"; fall_rule="F10 落点落在独立上层台"; safe_floor="全房"; nearest_retry="checkpoint"; failure_reset="恢复并保持出口隔离" }
    F09 = [ordered]@{ hazards=@("下穿单向承诺", "上层跨距"); pre_read="三高度出口在安全选择区同时出现"; damage_and_knockback="选择区无伤害"; fall_rule="下穿只进入 F10 明示滑道；其余落差有本房承接"; safe_floor="中层判读台与各出口前庭"; nearest_retry="三幡判读点"; failure_reset="回到当前路线入口，不调用全局跌落" }
    F10 = [ordered]@{ hazards=@("不可逆滑道"); pre_read="地面箭头、落差与 F08 图标提前显示"; damage_and_knockback="无伤害"; fall_rule="滑道只在确认跨过承诺线后切至 F08"; safe_floor="破墙前后及奖励台"; nearest_retry="支路入口"; failure_reset="重置破墙表现，保留已领遗物" }
    F11 = [ordered]@{ hazards=@("双层敌人压力"); pre_read="锁区前能看见两敌和层间路线"; damage_and_knockback="敌人伤害不把玩家推出可踩区"; fall_rule="上层跌落到底层战坪"; safe_floor="前坪与两条脱离线"; nearest_retry="祭台前坪"; failure_reset="重置遭遇、结界与未领取奖励" }
    F12 = [ordered]@{ hazards=@("目标未完成封口"); pre_read="封印轮和右侧石阶同屏"; damage_and_knockback="无伤害"; fall_rule="两个入口均在实体地面"; safe_floor="汇流岸与目标台"; nearest_retry="对应入口"; failure_reset="重置目标交互过程，不重置已完成状态" }
    F13 = [ordered]@{ hazards=@(); pre_read="无危险"; damage_and_knockback="授予期间输入保护"; fall_rule="左右连续落脚地"; safe_floor="全房"; nearest_retry="神龛入口"; failure_reset="只取消未完成交互，不回滚能力" }
    F14 = [ordered]@{ hazards=@("空冲跨距", "失败下落"); pre_read="演示残影、落点和下层回落层同时可见"; damage_and_knockback="移动挑战不造成环境伤害"; fall_rule="失败必落本房下层，绝不切 F07/F15"; safe_floor="入口、练习落点、回落层和证明落点"; nearest_retry="对应跨距起跳台"; failure_reset="重置证明门；玩家从回落层返回练习台" }
    F15 = [ordered]@{ hazards=@("状态门阻挡"); pre_read="三枚回照印显示必需与可选状态"; damage_and_knockback="无伤害"; fall_rule="全房连续地面"; safe_floor="全房"; nearest_retry="入口"; failure_reset="只刷新状态展示，不移动玩家" }
    F16 = [ordered]@{ hazards=@("三段敌人组合", "上层跌落"); pre_read="每屏先见敌人与安全脱离位"; damage_and_knockback="敌人伤害沿用战斗规则"; fall_rule="S3 跌回下层而非死亡"; safe_floor="段间缓冲与脱战凹槽"; nearest_retry="当前战段左缘"; failure_reset="仅重置当前战段，保留已清前段" }
    F17 = [ordered]@{ hazards=@("Boss 攻击", "arena 边界"); pre_read="前室壁画、石座与门后轮廓先读招"; damage_and_knockback="Boss 伤害不越过实体 arena 墙"; fall_rule="arena 无死亡坑"; safe_floor="前室与 arena 连续地面"; nearest_retry="Boss 本地 checkpoint"; failure_reset="完整重置 Boss 与 arena，10-25 秒内可重开" }
    F18 = [ordered]@{ hazards=@(); pre_read="战后安全色彩与开阔天井"; damage_and_knockback="禁用"; fall_rule="跑出地板不触发切房，边缘有实体挡墙"; safe_floor="全房"; nearest_retry="完成房入口"; failure_reset="无失败状态；法坛交互可重复取消" }
}

$rewardsByRoom = [ordered]@{
    F01 = @((Reward "tutorial_completed" "progression_state" "解锁正式镇妖流程" "完成四段教学" "出口与照壁同时反馈" "mandatory" "只写入一次" "照壁点亮" "F01 标记完成"))
    F02 = @((Reward "first_bounty_claimed" "progression_state" "首次悬赏结算" "清场并确认悬令" "清场后悬令台出现" "mandatory" "不可重复领取" "悬令盖印并开门" "F02 完成、F03 揭示"))
    F03 = @()
    F04 = @()
    F05 = @((Reward "wind_seal_unlocked" "ability" "风印：斩散弹体与激活符印" "确认风印龛" "首访从隔栏即可看见" "mandatory" "已获得时只播放完成态" "风纹环绕玩家并点亮神龛" "能力图标与 F07 门提示更新"))
    F06 = @((Reward "f06_air_dash_reward_claimed" "revisit_collectible" "Air Dash 回访奖励" "已获得 Air Dash 并抵达下层奖励台" "首访可见不可达" "optional_revisit" "只领取一次" "沉没佛首解封" "F06 奖励图标清除"))
    F07 = @((Reward "f07_cross_gate_completed" "shortcut_state" "永久开启 F07↔F14" "风印+Air Dash 后确认祭坛" "双色祭坛始终可见" "mandatory_backtrack" "已开时直接确认往返" "双印桥连通" "双向捷径线点亮"))
    F08 = @()
    F09 = @((Reward "f09_air_dash_route_completed" "route_mastery_state" "记录 Air Dash 高速线" "完成上层快线" "首访可见断口" "optional_revisit" "只记录一次" "上层幡旗常亮" "快线改为已发现"))
    F10 = @((Reward "marsh_relic_collected" "collectible" "瘴泽遗物" "打破可读墙并抵达沉龛" "入口可读破墙轮廓" "low_risk_branch" "不可重复领取" "经函浮起后龛位留空" "奖励清除、秘密标记完成"))
    F11 = @((Reward "warden_sigil_collected" "collectible" "镇妖挑战符" "清场" "锁区前可看见结界后奖励" "high_risk_branch" "不可重复领取" "祭台授符并解除结界" "挑战支路完成"))
    F12 = @((Reward "miasma_goal_completed" "world_state" "瘴泽目标完成" "确认泽心封印轮" "主路和支路汇流后必见" "mandatory" "完成后保持开放" "封印轮归位、瘴色减弱" "F12 完成、F13 揭示"))
    F13 = @((Reward "air_dash_unlocked" "ability" "Air Dash" "确认月轮神龛" "单屏中心焦点" "mandatory" "不可重复授予" "月轮激活并显示空冲残影" "能力图标与回访点更新"))
    F14 = @((Reward "air_dash_proof_completed" "mastery_state" "开放 F15 主路" "完成真实 airborne Air Dash 证明" "证明门从入口远景可见" "mandatory" "只记录一次" "断空石梁连通" "F14 完成"))
    F15 = @()
    F16 = @((Reward "mixed_gauntlet_completed" "progression_state" "开放 Boss 门" "清完三段遭遇" "Boss 门贯穿后两屏远景" "mandatory" "清场后永久直通" "四象阵熄灭" "F16 完成、F17 开放"))
    F17 = @((Reward "seal_guardian_defeated" "boss_progression" "Demo Boss 胜利状态" "击败封印守卫" "Boss 本体即奖励承诺" "mandatory" "不可重复发奖" "镇妖大印解锁、胜利出口出现" "F17 完成、F18 揭示"))
    F18 = @((Reward "bounty_cycle_completed" "completion_state" "闭合一次悬赏循环" "查看结果并确认归驿法坛" "结果墙与法坛同屏" "mandatory" "完成后只保留复盘反馈" "法坛建立驿路" "F03 Hub 更新为闭环完成态"))
}

$progressionStates = @("first_visit", "wind_seal_unlocked", "air_dash_unlocked", "marsh_goal_completed", "seal_guardian_defeated")
$variantHighlights = @{
    "F03|seal_guardian_defeated" = "Hub 赏榜、悬钟与地图显示本轮悬赏闭环，F18 法坛来路登记。"
    "F05|wind_seal_unlocked" = "神龛切换完成态，授予段变成直通段，弹体教学仍可回看。"
    "F06|air_dash_unlocked" = "开放下层奖励线和上层熟练快线，首访上层仍保持可走。"
    "F07|wind_seal_unlocked" = "风印半边点亮，但祭坛仍因缺少 Air Dash 保持锁定。"
    "F07|air_dash_unlocked" = "双印齐备，主动祭坛可确认往返 F14；F08 普通出口保持独立。"
    "F09|air_dash_unlocked" = "上层断口变为可达高速线，主路与两支路不关闭。"
    "F10|air_dash_unlocked" = "不改变必经路线，只允许更快取得已揭示遗物。"
    "F12|marsh_goal_completed" = "封印轮完成，F13 石阶门永久开放，F09 返回边界不变。"
    "F13|marsh_goal_completed" = "月轮神龛从远景提示转为可交互状态。"
    "F13|air_dash_unlocked" = "神龛完成态与输入保护结束，F14 出口立即点亮。"
    "F14|air_dash_unlocked" = "展示、练习、回落与证明全部启用；祭坛仍需风印条件。"
    "F15|air_dash_unlocked" = "显示 F06/F09 可选回访图标；F07 必需状态单独显示。"
    "F17|seal_guardian_defeated" = "arena 永久清空、锁镜解除、F18 胜利出口出现。"
    "F18|seal_guardian_defeated" = "结果墙、完成奖励与归驿法坛进入可交互状态。"
}

function New-Interactions([System.Collections.IDictionary]$room) {
    $interactiveKinds = @("checkpoint", "shrine", "waystation", "ability_gate", "clear_gate", "boss_gate", "goal", "reward", "secret", "shortcut", "gate")
    $verbByKind = @{
        checkpoint="confirm"; shrine="confirm"; waystation="confirm"; ability_gate="confirm";
        clear_gate="clear"; boss_gate="confirm"; goal="confirm"; reward="confirm";
        secret="attack"; shortcut="confirm"; gate="ground_dash"
    }
    $stateOwnerByKey = @{
        "F01|gate"="tutorial_completed"; "F05|shrine"="wind_seal_unlocked";
        "F07|ability_gate"="f07_cross_gate_completed"; "F07|shortcut"="f07_cross_gate_completed";
        "F08|checkpoint"="Main.checkpoint_snapshot"; "F10|secret"="F10.secret_wall_opened";
        "F10|reward"="marsh_relic_collected"; "F11|reward"="warden_sigil_collected";
        "F11|clear_gate"="F11.encounter_cleared"; "F12|goal"="miasma_goal_completed";
        "F13|shrine"="air_dash_unlocked"; "F14|ability_gate"="air_dash_proof_completed";
        "F14|shortcut"="f07_cross_gate_completed"; "F15|boss_gate"="f07_cross_gate_completed";
        "F16|clear_gate"="mixed_gauntlet_completed"; "F17|checkpoint"="Main.checkpoint_snapshot";
        "F17|boss_gate"="F17.boss_encounter_started"; "F18|waystation"="bounty_cycle_completed"
    }
    $records = @()
    $index = 0
    foreach ($zone in $room.zones) {
        if ($interactiveKinds -notcontains [string]$zone.kind) { continue }
        $index += 1
        $key = "$($room.id)|$($zone.kind)"
        $requirements = @()
        if ($room.id -eq "F07" -and $zone.kind -in @("ability_gate", "shortcut")) { $requirements = @("wind_seal_unlocked", "air_dash_unlocked") }
        elseif ($room.id -eq "F14" -and $zone.kind -eq "ability_gate") { $requirements = @("air_dash_unlocked") }
        elseif ($room.id -eq "F14" -and $zone.kind -eq "shortcut") { $requirements = @("wind_seal_unlocked", "air_dash_unlocked") }
        elseif ($room.id -eq "F15" -and $zone.kind -eq "boss_gate") { $requirements = @("f07_cross_gate_completed") }
        elseif ($zone.kind -eq "clear_gate") { $requirements = @("encounter_cleared") }
        elseif ($room.id -eq "F18" -and $zone.kind -eq "waystation") { $requirements = @("seal_guardian_defeated") }
        $owner = if ($stateOwnerByKey.ContainsKey($key)) { $stateOwnerByKey[$key] } else { "$($room.id).room_flow" }
        $persistence = if ($owner -match "^F\d+\.") { "room_session_or_scene_state" } else { "save_progress" }
        $records += ,(Interaction "$($room.id)_interaction_$index" $zone.label $zone.kind $verbByKind[$zone.kind] $requirements $owner $persistence)
    }
    if ($room.id -eq "F01") { $records += ,(Interaction "F01_training_target" "初印木偶靶" "无伤攻击教学" "attack" @() "tutorial_completed" "save_progress") }
    if ($room.id -eq "F02") { $records += ,(Interaction "F02_bounty_board" "镇妖悬令台" "清场结算与首次悬赏确认" "confirm" @("encounter_cleared") "first_bounty_claimed" "save_progress") }
    if ($room.id -eq "F03") { $records += ,(Interaction "F03_bounty_board" "赏榜与悬钟" "读取目标、回访与闭环状态" "confirm" @() "bounty_cycle_completed" "save_progress") }
    if ($room.id -eq "F15") { $records += ,(Interaction "F15_revisit_wall" "三印回照壁" "读取 F06/F07/F09 回访状态" "confirm" @() "Main.progress_snapshot" "save_progress") }
    return $records
}

function New-StateVariants([System.Collections.IDictionary]$room, [object[]]$encounters, [object[]]$rewards) {
    $records = @()
    foreach ($state in $progressionStates) {
        $key = "$($room.id)|$state"
        $summary = if ($variantHighlights.ContainsKey($key)) { $variantHighlights[$key] } elseif ($state -eq "first_visit") { "使用 $($room.routes[0].label)，展示未完成门控、奖励和提示。" } else { "该状态对 $($room.id) 无新增变化；沿用上一稳定布局。" }
        $route = if ($state -ne "first_visit" -and ($room.routes | Where-Object kind -in @("revisit", "speed"))) { "满足房间条件时启用已声明的回访/快线路线；首次主路仍保留。" } else { "沿用当前已开放路线，不移除安全主路。" }
        $records += ,[ordered]@{
            state = $state
            summary = $summary
            route = $route
            gating = $summary
            enemies = if ($encounters.Count -eq 0) { "none" } else { "按 encounter.revisit_rule 处理；已永久清场时不重复生成。" }
            hazards = "沿用 hazards_and_recovery；状态变化不得移除安全回落层。"
            rewards = if ($rewards.Count -eq 0) { "none" } else { "按 reward.repeat_rule 处理，状态变化不重复发奖。" }
            landmark_and_prompt = $summary
            map_state = "进入或写入该状态后刷新本房图标、连接和提示强度。"
        }
    }
    return $records
}

function New-Camera([System.Collections.IDictionary]$room, [object[]]$encounters) {
    $segments = @()
    for ($i = 0; $i -lt $room.segments.Count; $i++) {
        $segment = $room.segments[$i]
        $segments += ,[ordered]@{
            segment_id = $segment.id
            horizontal_bounds = @(($i * 640), (($i + 1) * 640))
            vertical_range = "0..360u_gameplay_band"
            look_ahead = "toward_route_direction_without_hiding_player_landing"
            preview = $segment.purpose
        }
    }
    $lockRule = if ($room.id -eq "F17") { "Boss 确认后锁定 arena；失败或胜利解除。" } elseif ($encounters.Count -gt 0) { "只在遭遇触发后锁当前战段；清场或允许退场时解除。" } else { "no_camera_lock" }
    return [ordered]@{
        forward_entry_composition = "入口安全地面、主地标与前方第一决策同屏，保留右向 look-ahead。"
        reverse_entry_composition = "反向出生点、返回地板与最近出口隔离同屏，保留左向 look-ahead。"
        segments = $segments
        look_ahead_rule = "输入方向偏移不超过 20% 视宽；危险落点优先于速度感。"
        lock_rule = $lockRule
        unlock_rule = "清场、取消交互、失败重置或离开锁区后恢复房间边界相机。"
        preview_targets = @($room.zones | Where-Object kind -in @("exit", "hazard", "reward", "ability_gate", "boss_gate", "shortcut", "landmark") | ForEach-Object { $_.label })
    }
}

function New-Presentation([System.Collections.IDictionary]$room) {
    return [ordered]@{
        main_landmark = $room.landmark
        spatial_story = "$($room.role)：地形从入口安全轮廓引向 $($room.landmark)。"
        structural_assets = @(
            "ground: 独立地表封边与连续碰撞皮肤",
            "platform: 仅用于可跳平台，不复用作厚地基填充",
            "architecture: 连接、门控和地标各自独立对象",
            "interaction: 神龛/祭坛/checkpoint/奖励拥有独立状态表现"
        )
        parallax_layers = [ordered]@{
            sky = "低对比天空与瘴雾色域"
            far = "区域轮廓和跨房地标"
            mid = "建筑群、树桥与水线"
            near = "不碰撞的近景结构"
            foreground = "仅框景；进入角色安全区时淡出"
        }
        foreground_occlusion = [ordered]@{
            forbidden_regions = @("玩家落点", "出口前庭", "门控提示", "敌人读招区")
            fade_rule = "遮挡角色轮廓超过 15% 或进入 64u 安全圈时淡出"
        }
        feedback_intent = @("门控：状态色+符印脉冲", "能力：专属 VFX/SFX", "奖励：世界物件完成态+地图更新", "checkpoint：稳定青色锚点")
        asset_policy = "优先复用已登记东方奇幻地表、平台与交互资产；缺口登记后再生产，背景不承载碰撞。"
    }
}

function New-MapSemantics([System.Collections.IDictionary]$room, [object[]]$connections, [object[]]$interactions, [object[]]$rewards) {
    return [ordered]@{
        reveal_timing = "玩家在入口安全地面稳定 0.5s 后揭示房间；秘密仅在发现后显示。"
        connection_icons = @($connections | ForEach-Object { "$($_.connection_id):$($_.map_representation):$($_.type)" })
        interaction_icons = @($interactions | ForEach-Object { "$($_.interaction_id):$($_.purpose)" })
        reward_icons = @($rewards | ForEach-Object { "$($_.reward_id):$($_.type)" })
        state_updates = @($room.persistent_state | ForEach-Object { "$_ -> refresh_room_and_connection_state" })
        main_hint_strength = "主线出口高；返回口中；可选支路中；秘密低。"
        secret_hint_strength = if ($room.id -eq "F10") { "轮廓可读但地图只在破墙后显示。" } else { "无未声明秘密提示。" }
    }
}

function New-Qa([System.Collections.IDictionary]$room, [object[]]$connections) {
    $naturalRoutes = @()
    foreach ($route in $room.routes) {
        $naturalRoutes += ,[ordered]@{
            route_id = $route.id
            kind = $route.kind
            natural_input = if ($route.kind -eq "fallback") { "移动+下落回安全层" } elseif ($route.kind -in @("revisit", "speed")) { "移动+已获能力；主动连接另需确认" } else { "移动+普通跳；门控处按语义动作" }
            expected_result = "不越界、不误切房并抵达声明目标"
        }
    }
    return [ordered]@{
        natural_input_routes = $naturalRoutes
        spawn_support = @($connections | ForEach-Object { "$($_.connection_id):160u_support:no_trigger_overlap" })
        regression_checks = @("正向自然输入", "反向自然输入", "Spawn 防反弹", "无软锁/假跌落/不可见出口", "移动标尺与角色头顶净空")
        route_readability = "进入后 3-5 秒可识别主方向、主要地标和当前门控。"
        shortcut_check = "主动捷径必须明确确认、显示去向，并达到 timing_and_rhythm 的节省目标。"
        failure_recovery = "验证本房最近重试点；禁止把普通连接失败交给 Main 越界恢复。"
        later_playtest_metrics = @("首访迷路点", "误触连接次数", "失败后复跑时间", "捷径发现率")
    }
}

foreach ($room in $rooms) {
    $roomId = [string]$room.id
    $connections = @($connectionsByRoom[$roomId])
    $interactions = @(New-Interactions $room)
    $encounters = @()
    if ($encountersByRoom.Contains($roomId)) { $encounters = @($encountersByRoom[$roomId]) }
    $rewards = @()
    if ($null -ne $rewardsByRoom[$roomId]) { $rewards = @($rewardsByRoom[$roomId]) }
    $camera = New-Camera $room $encounters
    $presentation = New-Presentation $room

    $room.blueprint_status = "gameplay_blueprint_complete"
    $room.player_knowledge = [ordered]@{
        knows_on_entry = $knowledgeByRoom[$roomId][0]
        learns_here = $knowledgeByRoom[$roomId][1]
        remembers_for_revisit = $knowledgeByRoom[$roomId][2]
        knows_on_exit = $knowledgeByRoom[$roomId][3]
    }
    $room.timing_and_rhythm = $timingByRoom[$roomId]
    $room.connections = $connections
    $room.interactions = $interactions
    $room.encounters = $encounters
    $room.encounter_policy = if ($encounters.Count -eq 0) { "safe_no_encounter" } else { "authored_combat_encounters" }
    $room.safe_room_reason = if ($encounters.Count -eq 0) { $safeRoomReasons[$roomId] } else { "not_a_safe_room" }
    $room.hazards_and_recovery = $hazardsByRoom[$roomId]
    $room.hazards_and_recovery.global_fall_dependency = "forbidden_and_not_required"
    $room.rewards = $rewards
    $room.reward_policy = if ($rewards.Count -eq 0) { "no_room_reward" } else { "authored_reward_records" }
    $room.state_variants = @(New-StateVariants $room $encounters $rewards)
    $room.camera = $camera
    $room.presentation = $presentation
    $room.map_semantics = New-MapSemantics $room $connections $interactions $rewards
    $room.qa = New-Qa $room $connections
    $sceneName = $room.scene.Replace("res://scenes/rooms/", "").Replace(".tscn", "")
    $room.views = [ordered]@{
        topology = "res://spec-design/formal-demo-room-blueprints/$($room.id)-$sceneName.svg"
        side_view_gameplay = "res://spec-design/formal-demo-room-blueprints/$($room.id)-$sceneName-side-view-gameplay.svg"
    }

    for ($i = 0; $i -lt $room.segments.Count; $i++) {
        $room.segments[$i].camera = [ordered]@{
            bounds = $camera.segments[$i].horizontal_bounds
            vertical_range = $camera.segments[$i].vertical_range
            preview = $camera.segments[$i].preview
        }
        $room.segments[$i].presentation = [ordered]@{
            landmark_role = $room.landmark
            structural_read = $room.segments[$i].geometry
            foreground_rule = "角色、落点、敌人和出口前庭不得被遮挡"
        }
    }
}

$progressionStateMatrix = @(
    [ordered]@{ state="first_visit"; connections="仅开放首次主路和明确可退口"; enemies="使用首访编排"; hazards="显示预读与完整安全回落"; rewards="未领取且可预告"; map="按入口稳定后揭示"; landmarks="未完成态"; hints="主线高强度" },
    [ordered]@{ state="wind_seal_unlocked"; connections="F05 出口开放；F07 仅点亮风印半态"; enemies="弹体可被风印反制"; hazards="不移除安全主路"; rewards="风印不重复授予"; map="标记 F05 完成并更新 F07"; landmarks="风印龛完成态"; hints="指向空行能力" },
    [ordered]@{ state="air_dash_unlocked"; connections="开放 F06/F09 回访线与 F07↔F14 祭坛条件"; enemies="F16 可用空冲替代线"; hazards="跨距仍保留下层回落"; rewards="F06 回访奖励可达"; map="显示三处回访图标"; landmarks="空行印点亮"; hints="回访提示中等" },
    [ordered]@{ state="marsh_goal_completed"; connections="F12→F13 永久开放"; enemies="F11 清场状态不回滚"; hazards="目标封口移除但返回口保留"; rewards="目标不重复结算"; map="F12 完成、F13 揭示"; landmarks="泽心封印轮完成态"; hints="指向月轮神龛" },
    [ordered]@{ state="seal_guardian_defeated"; connections="F17→F18 与 F18→F03 法坛可用"; enemies="Boss 永久清除"; hazards="arena 解锁且完成房无危险"; rewards="完成奖励只结算一次"; map="闭合 F18→F03 Hub 回环"; landmarks="镇妖大印与 Hub 赏榜更新"; hints="归驿法坛高强度" }
)

$encounterPhaseByRoom = [ordered]@{
    F01="教学"; F02="首次胜利"; F03="Hub"; F04="区域揭示"; F05="单机制教学"; F06="环境危险";
    F07="能力门预告"; F08="恢复"; F09="分支选择"; F10="低风险奖励"; F11="高风险战斗"; F12="区域目标";
    F13="能力授予"; F14="能力证明"; F15="回访集结"; F16="综合战斗"; F17="Boss"; F18="降压返回"
}
$encounterCurve = @($rooms | ForEach-Object {
    [ordered]@{
        room_id = $_.id
        phase = $encounterPhaseByRoom[$_.id]
        pressure_wave = @($_.segments | ForEach-Object { $_.pressure })
        encounter_policy = $_.encounter_policy
        encounter_count = $_.encounters.Count
        reset_summary = $_.hazards_and_recovery.failure_reset
    }
})

$connectionMatrix = @($rooms | ForEach-Object { $source = $_.id; $_.connections | ForEach-Object { [ordered]@{ source_room=$source; connection_id=$_.connection_id; target_room=$_.target_room; type=$_.type; source_spawn=$_.source_anchor_id; target_spawn=$_.target_spawn_id } } })
$rewardMatrix = @($rooms | ForEach-Object { $source = $_.id; $_.rewards | ForEach-Object { [ordered]@{ room_id=$source; reward_id=$_.reward_id; type=$_.type; condition=$_.condition; repeat_rule=$_.repeat_rule } } })
$cameraMatrix = @($rooms | ForEach-Object { [ordered]@{ room_id=$_.id; segment_count=$_.camera.segments.Count; lock_rule=$_.camera.lock_rule; preview_targets=$_.camera.preview_targets } })
$mapSemanticsMatrix = @($rooms | ForEach-Object { [ordered]@{ room_id=$_.id; reveal_timing=$_.map_semantics.reveal_timing; connections=$_.map_semantics.connection_icons; updates=$_.map_semantics.state_updates } })
$qaMatrix = @($rooms | ForEach-Object { [ordered]@{ room_id=$_.id; natural_route_count=$_.qa.natural_input_routes.Count; checks=$_.qa.regression_checks; failure_recovery=$_.qa.failure_recovery } })

$stageSegmentTotal = ($rooms | ForEach-Object { [int]$_.segment_count } | Measure-Object -Sum).Sum
$manifest = [ordered]@{
    schema_version = 2
    program_id = "formal_demo_room_recovery_b_phase2_blueprints"
    design_status = "gameplay_blueprint_complete_runtime_scene_pending"
    projection = "dual_topology_and_side_view_gameplay_blueprint"
    map_mode = "side_scroll_mode"
    engine_target = "Godot_4_6_3_project_native"
    camera_world_size = @(640, 360)
    grid_unit = 32
    segment_width = 640
    segment_height = 360
    stage_segment_total = $stageSegmentTotal
    movement_contract = [ordered]@{
        source = "tests/artifacts/local/room-design-recovery/movement-metrics/metrics.json"
        safe_teaching_horizontal_gap = @(58.53, 87.80)
        normal_mainline_horizontal_gap = @(80.48, 109.75)
        regular_challenge_horizontal_gap = @(102.43, 124.39)
        optional_high_horizontal_gap = @(124.39, 139.02)
        safe_landing_width = 48
        normal_landing_width = 36
        air_dash_sample_distance = 110.0
    }
    safety_contract = @(
        "每个入口至少 160u 安全观察地面，且不得与任一出口触发器重叠",
        "普通切房口必须建立在连续地板、坡道、洞口或明确驿路上，不与跌落恢复边界共用",
        "首次主线失败回落必须留在当前房间可踩地形，不依赖 Main 全局跌落恢复",
        "能力门未满足条件时只阻挡并反馈，不移动玩家、不触发跨房",
        "普通主线跳跃不超过移动标尺 75%，高难可选不超过 95%"
    )
    blueprint_contract = [ordered]@{
        schema = "formal_demo_room_blueprint_v2"
        completion_status = "gameplay_blueprint_complete"
        required_top_level_fields = @("connection_vocabulary", "progression_state_matrix", "encounter_curve", "presentation_contract", "acceptance_contract", "connection_matrix", "reward_matrix", "camera_matrix", "map_semantics_matrix", "qa_matrix")
        required_room_fields = @("player_knowledge", "timing_and_rhythm", "connections", "interactions", "encounters", "hazards_and_recovery", "rewards", "state_variants", "camera", "presentation", "map_semantics", "qa", "views")
        required_segment_fields = @("id", "name", "purpose", "geometry", "pressure", "safety", "camera", "presentation")
        required_connection_fields = @("connection_id", "type", "target_room", "source_anchor_id", "source_anchor_position", "target_spawn_id", "target_spawn_position", "target_facing", "directionality", "interaction_verb", "requirements", "blocked_feedback", "transition_feedback", "safe_arrival_contract", "anti_retrigger_contract", "map_representation")
        allowed_exceptions = @("安全房 encounters 可为空，但 encounter_policy 与 safe_room_reason 必填", "无房内奖励时 rewards 可为空，但 reward_policy 必填")
        coordinate_space = "segment_normalized: x=连续屏段坐标, y=单屏高度比例"
    }
    connection_vocabulary = @(
        [ordered]@{ type="adjacent_boundary"; player_action="cross"; presentation="山口/坡道/洞口/栈道/雾幕"; auto_transition="yes_after_crossing_supported_boundary" },
        [ordered]@{ type="architectural_door"; player_action="confirm_or_cross_open_door"; presentation="与建筑连续的门扇或门洞"; auto_transition="only_when_open" },
        [ordered]@{ type="ability_gate"; player_action="ground_dash_or_air_dash_or_confirm"; presentation="符印/瘴幕/断层/高台"; auto_transition="after_required_action_succeeds" },
        [ordered]@{ type="encounter_gate"; player_action="clear"; presentation="妖气结界消散"; auto_transition="after_clear" },
        [ordered]@{ type="remote_waystation"; player_action="confirm"; presentation="驿路法坛/祭坛/传送机关"; auto_transition="no" },
        [ordered]@{ type="one_way_terrain"; player_action="fall_or_slide"; presentation="井道/滑道/塌桥"; auto_transition="yes_after_irreversible_commitment_preview" },
        [ordered]@{ type="boss_gate"; player_action="confirm"; presentation="唯一重型封印建筑"; auto_transition="no" }
    )
    progression_state_matrix = $progressionStateMatrix
    encounter_curve = $encounterCurve
    presentation_contract = [ordered]@{
        required_layers = @("sky", "far", "mid", "near", "foreground")
        object_roles = @("ground", "platform", "architecture", "interaction", "hazard", "enemy", "spawn", "camera", "landmark")
        collision_rule = "背景只承担非碰撞远景；地表、平台、门、危险、checkpoint 与出口是独立结构对象。"
        occlusion_rule = "玩家、落点、敌人读招、门控提示和出口前庭属于前景禁遮挡区。"
        asset_status = "production_requirements_only_not_runtime_asset_approval"
    }
    acceptance_contract = [ordered]@{
        json_svg_structure = "validator_pass"
        design_candidate = "18/18 rooms and 48/48 segments complete"
        runtime_adoption = "separate_later_stage"
        automated_natural_routes = "separate_later_stage_after_tscn_adoption"
        greybox_playtest = "after_goal_completion"
        final_art_and_release = "outside_this_stage"
        promotion_rule = "one_layer_never_implies_the_next"
    }
    formal_main_route = @("F01","F02","F03","F04","F05","F06","F07","F08","F09","F12","F13","F14","F15","F16","F17","F18","F03")
    branch_connections = @(
        [ordered]@{ from = "F09"; to = "F10"; kind = "resource_loop" },
        [ordered]@{ from = "F10"; to = "F08"; kind = "permanent_loop" },
        [ordered]@{ from = "F09"; to = "F11"; kind = "challenge_forward" },
        [ordered]@{ from = "F11"; to = "F12"; kind = "challenge_forward" },
        [ordered]@{ from = "F07"; to = "F14"; kind = "ability_shortcut"; requirements = @("wind_seal_unlocked","air_dash_unlocked") }
    )
    connection_matrix = $connectionMatrix
    reward_matrix = $rewardMatrix
    camera_matrix = $cameraMatrix
    map_semantics_matrix = $mapSemanticsMatrix
    qa_matrix = $qaMatrix
    rooms = $rooms
}

$manifestPath = Join-Path $OutputDir "formal-demo-room-blueprints.json"
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

function EscapeXml([string]$value) {
    return [System.Security.SecurityElement]::Escape($value)
}

$routeStyles = @{
    first = @{ color = "#55d6e8"; dash = "" }
    branch = @{ color = "#c984f7"; dash = "10 7" }
    revisit = @{ color = "#e9b95d"; dash = "12 7" }
    speed = @{ color = "#71d69b"; dash = "7 6" }
    fallback = @{ color = "#aab7c4"; dash = "5 7" }
    retry = @{ color = "#e98989"; dash = "5 5" }
}
$zoneColors = @{
    entry="#6fd3ff"; exit="#77e39f"; enemy="#ef7d7d"; boss="#ff5964"; hazard="#d9845f";
    checkpoint="#6ee7c7"; reward="#f0c75e"; landmark="#f1e4b3"; shrine="#f1e4b3"; gate="#c58cff";
    ability_gate="#c58cff"; clear_gate="#e68b8b"; boss_gate="#b97777"; waystation="#5fd7cf";
    shortcut="#dfb967"; branch_exit="#c984f7"; one_way_exit="#c984f7"; loop_entry="#e9b95d";
    projectile="#ef9c6b"; observe="#a8c9d8"; platform="#9db6c5"; practice="#9db6c5";
    safe_floor="#87a8b8"; secret="#d5a66d"; goal="#f0c75e"
}

function RenderTopologySvg([System.Collections.IDictionary]$room) {
    $canvasW = 1500; $canvasH = 800
    $planX = 70; $planY = 150; $planW = 1360; $planH = 300
    $segW = $planW / [double]$room.segment_count
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$canvasW' height='$canvasH' viewBox='0 0 $canvasW $canvasH' data-view='topology'>")
    [void]$sb.AppendLine("<defs><marker id='arrow' markerWidth='9' markerHeight='9' refX='8' refY='3' orient='auto'><path d='M0,0 L0,6 L9,3 z' fill='context-stroke'/></marker><pattern id='grid' width='32' height='32' patternUnits='userSpaceOnUse'><path d='M32 0 L0 0 0 32' fill='none' stroke='#223746' stroke-width='1'/></pattern></defs>")
    [void]$sb.AppendLine("<rect width='1500' height='800' fill='#0d1822'/><rect x='1' y='1' width='1498' height='798' fill='none' stroke='#5e7686' stroke-width='2'/>")
    [void]$sb.AppendLine("<text x='70' y='58' fill='#f4e8c8' font-family='Microsoft YaHei,Segoe UI' font-size='30' font-weight='700'>$($room.id) · $(EscapeXml $room.title)</text>")
    [void]$sb.AppendLine("<text x='70' y='92' fill='#9fc1d2' font-family='Microsoft YaHei,Segoe UI' font-size='18'>$(EscapeXml $room.role) · $($room.segment_count) 屏 · $($room.segment_count * 640)×360u</text>")
    [void]$sb.AppendLine("<text x='1430' y='58' text-anchor='end' fill='#d9bf77' font-family='Microsoft YaHei,Segoe UI' font-size='17'>记忆点：$(EscapeXml $room.landmark)</text>")
    [void]$sb.AppendLine("<rect x='$planX' y='$planY' width='$planW' height='$planH' rx='10' fill='#132532' stroke='#506a79' stroke-width='2'/><rect x='$planX' y='$planY' width='$planW' height='$planH' rx='10' fill='url(#grid)' opacity='0.7'/>")
    for ($i=0; $i -lt $room.segment_count; $i++) {
        $x = $planX + $i * $segW
        if ($i -gt 0) { [void]$sb.AppendLine("<line x1='$x' y1='$planY' x2='$x' y2='$($planY+$planH)' stroke='#668091' stroke-width='2' stroke-dasharray='8 8'/>") }
        $labelX = $x + 12
        [void]$sb.AppendLine("<text x='$labelX' y='$($planY+25)' fill='#8caabb' font-family='Segoe UI' font-size='15'>S$($i+1)</text>")
    }
    foreach ($route in $room.routes) {
        $style = $routeStyles[$route.kind]
        $coords = @()
        foreach ($point in $route.points) {
            $px = $planX + ([double]$point[0] / [double]$room.segment_count) * $planW
            $py = $planY + [double]$point[1] * $planH
            $coords += "$([math]::Round($px,1)),$([math]::Round($py,1))"
        }
        $dash = if ([string]::IsNullOrWhiteSpace($style.dash)) { "" } else { " stroke-dasharray='$($style.dash)'" }
        [void]$sb.AppendLine("<polyline points='$($coords -join ' ')' fill='none' stroke='$($style.color)' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'$dash marker-end='url(#arrow)' opacity='0.95'/>")
    }
    foreach ($zone in $room.zones) {
        $zx = $planX + ([double]$zone.x / [double]$room.segment_count) * $planW
        $zy = $planY + [double]$zone.y * $planH
        $color = $zoneColors[$zone.kind]; if ([string]::IsNullOrWhiteSpace($color)) { $color = "#c0d0d8" }
        [void]$sb.AppendLine("<circle cx='$zx' cy='$zy' r='10' fill='$color' stroke='#071118' stroke-width='3'/>")
        [void]$sb.AppendLine("<text x='$([math]::Round($zx+14,1))' y='$([math]::Round($zy-12,1))' fill='#f2f5f6' font-family='Microsoft YaHei,Segoe UI' font-size='13' paint-order='stroke' stroke='#0d1822' stroke-width='4'>$(EscapeXml $zone.label)</text>")
    }
    $cardY = 485; $cardGap = 10; $cardW = ($planW - (($room.segment_count-1)*$cardGap)) / [double]$room.segment_count
    for ($i=0; $i -lt $room.segments.Count; $i++) {
        $seg = $room.segments[$i]; $cx = $planX + $i * ($cardW + $cardGap)
        [void]$sb.AppendLine("<rect x='$cx' y='$cardY' width='$cardW' height='220' rx='9' fill='#162b38' stroke='#3e5b6b'/>")
        [void]$sb.AppendLine("<text x='$($cx+14)' y='$($cardY+30)' fill='#f1dca5' font-family='Microsoft YaHei,Segoe UI' font-size='18' font-weight='700'>$(EscapeXml $seg.id) · $(EscapeXml $seg.name)</text>")
        $lines = @("职责：$($seg.purpose)","结构：$($seg.geometry)","压力：$($seg.pressure)","安全：$($seg.safety)")
        $ly = $cardY + 62
        foreach ($line in $lines) {
            $escaped = EscapeXml $line
            $maxChars = if ($room.segment_count -ge 4) { 20 } elseif ($room.segment_count -eq 3) { 28 } else { 42 }
            $parts = @()
            while ($escaped.Length -gt $maxChars) { $parts += $escaped.Substring(0,$maxChars); $escaped = $escaped.Substring($maxChars) }
            $parts += $escaped
            foreach ($part in $parts) {
                [void]$sb.AppendLine("<text x='$($cx+14)' y='$ly' fill='#c6d6dd' font-family='Microsoft YaHei,Segoe UI' font-size='13'>${part}</text>")
                $ly += 20
            }
        }
    }
    $legend = @("first=首次路线","branch=支路","revisit=能力回访","speed=熟练快线","fallback/retry=安全回落或重试")
    [void]$sb.AppendLine("<text x='70' y='752' fill='#87a8b8' font-family='Microsoft YaHei,Segoe UI' font-size='14'>俯视结构审阅图；横版玩法不变。1 屏 = 640×360u。$(EscapeXml ($legend -join ' ｜ '))</text>")
    [void]$sb.AppendLine("<text x='1430' y='780' text-anchor='end' fill='#668091' font-family='Segoe UI' font-size='12'>formal_demo_room_recovery_b · blueprint v2 · view=topology</text>")
    [void]$sb.AppendLine("</svg>")
    return $sb.ToString()
}

function ShortText([string]$value, [int]$maxLength = 68) {
    if ($null -eq $value) { return "" }
    if ($value.Length -le $maxLength) { return $value }
    return $value.Substring(0, $maxLength - 1) + "…"
}

function RenderSideViewGameplaySvg([System.Collections.IDictionary]$room) {
    $canvasW = 1600; $canvasH = 1000
    $planX = 70; $planY = 150; $planW = 1460; $planH = 410
    $segW = $planW / [double]$room.segment_count
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$canvasW' height='$canvasH' viewBox='0 0 $canvasW $canvasH' data-view='side_view_gameplay'>")
    [void]$sb.AppendLine("<defs><marker id='side-arrow' markerWidth='9' markerHeight='9' refX='8' refY='3' orient='auto'><path d='M0,0 L0,6 L9,3 z' fill='context-stroke'/></marker><pattern id='side-grid' width='32' height='32' patternUnits='userSpaceOnUse'><path d='M32 0 L0 0 0 32' fill='none' stroke='#263947' stroke-width='1'/></pattern></defs>")
    [void]$sb.AppendLine("<rect width='$canvasW' height='$canvasH' fill='#0b151d'/><rect x='1' y='1' width='1598' height='998' fill='none' stroke='#5e7686' stroke-width='2'/>")
    [void]$sb.AppendLine("<text x='70' y='55' fill='#f4e8c8' font-family='Microsoft YaHei,Segoe UI' font-size='30' font-weight='700'>$($room.id) · $(EscapeXml $room.title) · 横版玩法施工图</text>")
    [void]$sb.AppendLine("<text x='70' y='88' fill='#9fc1d2' font-family='Microsoft YaHei,Segoe UI' font-size='17'>view=side_view_gameplay · $($room.segment_count) 屏 · blueprint_status=$($room.blueprint_status)</text>")
    [void]$sb.AppendLine("<text x='1530' y='55' text-anchor='end' fill='#d9bf77' font-family='Microsoft YaHei,Segoe UI' font-size='16'>主地标：$(EscapeXml $room.landmark)</text>")

    [void]$sb.AppendLine("<rect x='$planX' y='$planY' width='$planW' height='$planH' rx='10' fill='#132532' stroke='#506a79' stroke-width='2'/>")
    [void]$sb.AppendLine("<rect x='$planX' y='$planY' width='$planW' height='82' fill='#102330'/><text x='$($planX+12)' y='$($planY+24)' fill='#5f8193' font-family='Segoe UI' font-size='13'>sky / far</text>")
    [void]$sb.AppendLine("<rect x='$planX' y='$($planY+82)' width='$planW' height='104' fill='#162c37'/><text x='$($planX+12)' y='$($planY+107)' fill='#6f91a0' font-family='Segoe UI' font-size='13'>mid / landmark</text>")
    [void]$sb.AppendLine("<rect x='$planX' y='$($planY+186)' width='$planW' height='224' fill='url(#side-grid)' opacity='0.85'/><text x='$($planX+12)' y='$($planY+211)' fill='#7899a8' font-family='Segoe UI' font-size='13'>near / gameplay / foreground-safe</text>")

    for ($i=0; $i -lt $room.segment_count; $i++) {
        $x = $planX + $i * $segW
        if ($i -gt 0) { [void]$sb.AppendLine("<line x1='$x' y1='$planY' x2='$x' y2='$($planY+$planH)' stroke='#88a1ae' stroke-width='2' stroke-dasharray='8 8'/>") }
        [void]$sb.AppendLine("<rect x='$($x+5)' y='$($planY+5)' width='$($segW-10)' height='$($planH-10)' fill='none' stroke='#4f7182' stroke-width='1' stroke-dasharray='5 6'/>")
        [void]$sb.AppendLine("<text x='$($x+12)' y='$($planY+48)' fill='#c6d6dd' font-family='Segoe UI' font-size='16' font-weight='700'>S$($i+1) camera</text>")
    }

    foreach ($route in $room.routes) {
        $style = $routeStyles[$route.kind]
        $coords = @()
        foreach ($point in $route.points) {
            $px = $planX + ([double]$point[0] / [double]$room.segment_count) * $planW
            $py = $planY + 105 + [double]$point[1] * ($planH - 125)
            $coords += "$([math]::Round($px,1)),$([math]::Round($py,1))"
        }
        [void]$sb.AppendLine("<polyline points='$($coords -join ' ')' fill='none' stroke='#263d49' stroke-width='20' stroke-linecap='square' stroke-linejoin='round'/>")
        $dash = if ([string]::IsNullOrWhiteSpace($style.dash)) { "" } else { " stroke-dasharray='$($style.dash)'" }
        [void]$sb.AppendLine("<polyline points='$($coords -join ' ')' fill='none' stroke='$($style.color)' stroke-width='4' stroke-linecap='round' stroke-linejoin='round'$dash marker-end='url(#side-arrow)'/>")
    }

    foreach ($zone in $room.zones) {
        $zx = $planX + ([double]$zone.x / [double]$room.segment_count) * $planW
        $zy = $planY + 105 + [double]$zone.y * ($planH - 125)
        $color = $zoneColors[$zone.kind]; if ([string]::IsNullOrWhiteSpace($color)) { $color = "#c0d0d8" }
        $shape = if ($zone.kind -in @("enemy", "boss", "hazard", "projectile")) { "triangle" } elseif ($zone.kind -in @("entry", "exit", "branch_exit", "one_way_exit", "loop_entry")) { "spawn" } else { "interaction" }
        if ($shape -eq "triangle") {
            [void]$sb.AppendLine("<path d='M$zx $($zy-12) L$($zx+12) $($zy+10) L$($zx-12) $($zy+10) Z' fill='$color' stroke='#071118' stroke-width='2'/>")
        } elseif ($shape -eq "spawn") {
            [void]$sb.AppendLine("<path d='M$zx $($zy-12) L$($zx+12) $zy L$zx $($zy+12) L$($zx-12) $zy Z' fill='$color' stroke='#071118' stroke-width='2'/>")
        } else {
            [void]$sb.AppendLine("<rect x='$($zx-9)' y='$($zy-9)' width='18' height='18' rx='3' fill='$color' stroke='#071118' stroke-width='2'/>")
        }
        [void]$sb.AppendLine("<text x='$([math]::Round($zx+14,1))' y='$([math]::Round($zy-12,1))' fill='#f2f5f6' font-family='Microsoft YaHei,Segoe UI' font-size='12' paint-order='stroke' stroke='#0b151d' stroke-width='4'>$(EscapeXml (ShortText $zone.label 24))</text>")
    }

    foreach ($connection in $room.connections) {
        $sx = $planX + ([double]$connection.source_anchor_position.x / [double]$room.segment_count) * $planW
        $sy = $planY + 105 + [double]$connection.source_anchor_position.y * ($planH - 125)
        [void]$sb.AppendLine("<circle cx='$sx' cy='$sy' r='15' fill='none' stroke='#f4e8c8' stroke-width='2'/><text x='$sx' y='$($sy+4)' text-anchor='middle' fill='#f4e8c8' font-family='Segoe UI' font-size='10'>SP</text>")
    }

    $cardY = 590; $cardW = 355; $cardH = 320; $gap = 13
    $cards = @(
        [ordered]@{ title="1 空间与移动"; color="#55d6e8"; lines=@("分段：$($room.segment_count) 屏 / $($room.segment_count*640)u", "首次：$($room.timing_and_rhythm.first_visit)", "回访：$($room.timing_and_rhythm.revisit)", "节拍：$($room.timing_and_rhythm.pressure_and_rhythm)", "路线：$(($room.routes | ForEach-Object { $_.label }) -join ' / ')") },
        [ordered]@{ title="2 遭遇与危险"; color="#ef7d7d"; lines=@("策略：$($room.encounter_policy)", "遭遇：$(if($room.encounters.Count -eq 0){$room.safe_room_reason}else{($room.encounters | ForEach-Object {$_.encounter_id}) -join ' / '})", "危险：$(($room.hazards_and_recovery.hazards) -join ' / ')", "回落：$($room.hazards_and_recovery.safe_floor)", "重置：$($room.hazards_and_recovery.failure_reset)") },
        [ordered]@{ title="3 交互、门控与状态"; color="#c984f7"; lines=@("连接：$(($room.connections | ForEach-Object { $_.connection_id }) -join ' / ')", "交互：$(($room.interactions | ForEach-Object { $_.world_object }) -join ' / ')", "奖励：$(if($room.rewards.Count -eq 0){'none'}else{($room.rewards | ForEach-Object {$_.reward_id}) -join ' / '})", "持久状态：$(($room.persistent_state) -join ' / ')", "地图：$($room.map_semantics.main_hint_strength)") },
        [ordered]@{ title="4 相机、地标与表现"; color="#e9b95d"; lines=@("地标：$($room.presentation.main_landmark)", "正向：$($room.camera.forward_entry_composition)", "反向：$($room.camera.reverse_entry_composition)", "锁镜：$($room.camera.lock_rule)", "遮挡：$($room.presentation.foreground_occlusion.fade_rule)") }
    )
    for ($i=0; $i -lt $cards.Count; $i++) {
        $card = $cards[$i]; $cx = $planX + $i * ($cardW + $gap)
        [void]$sb.AppendLine("<rect x='$cx' y='$cardY' width='$cardW' height='$cardH' rx='10' fill='#142733' stroke='$($card.color)' stroke-width='2'/>")
        [void]$sb.AppendLine("<text x='$($cx+16)' y='$($cardY+32)' fill='$($card.color)' font-family='Microsoft YaHei,Segoe UI' font-size='18' font-weight='700'>$($card.title)</text>")
        $ly = $cardY + 65
        foreach ($line in $card.lines) {
            $remaining = EscapeXml (ShortText ([string]$line) 88)
            while ($remaining.Length -gt 38) {
                [void]$sb.AppendLine("<text x='$($cx+16)' y='$ly' fill='#c8d7dd' font-family='Microsoft YaHei,Segoe UI' font-size='12'>$($remaining.Substring(0,38))</text>")
                $remaining = $remaining.Substring(38); $ly += 19
            }
            [void]$sb.AppendLine("<text x='$($cx+16)' y='$ly' fill='#c8d7dd' font-family='Microsoft YaHei,Segoe UI' font-size='12'>$remaining</text>")
            $ly += 23
        }
    }
    [void]$sb.AppendLine("<text x='70' y='958' fill='#87a8b8' font-family='Microsoft YaHei,Segoe UI' font-size='13'>◆ Spawn/出口 ｜ ▲ 遭遇/危险 ｜ ■ 交互/门控 ｜ 粗灰线=可踩结构 ｜ 彩线=玩家路线 ｜ 四层合同均来自同一 JSON</text>")
    [void]$sb.AppendLine("<text x='1530' y='980' text-anchor='end' fill='#668091' font-family='Segoe UI' font-size='12'>formal_demo_room_recovery_b · blueprint v2 · view=side_view_gameplay</text></svg>")
    return $sb.ToString()
}

foreach ($room in $rooms) {
    $baseName = "{0}-{1}" -f $room.id, $room.scene.Replace("res://scenes/rooms/","").Replace(".tscn","")
    (RenderTopologySvg $room) | Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.svg") -Encoding UTF8
    (RenderSideViewGameplaySvg $room) | Set-Content -LiteralPath (Join-Path $OutputDir "$baseName-side-view-gameplay.svg") -Encoding UTF8
}

function RenderOverviewSvg([System.Collections.IDictionary]$blueprint) {
    $roomSpecs = @($blueprint.rooms)
    $positions = [ordered]@{}
    $mainIds = @()
    foreach ($id in $blueprint.formal_main_route) {
        if ($mainIds -notcontains $id) { $mainIds += $id }
    }
    for ($i=0; $i -lt $mainIds.Count; $i++) {
        $row = [math]::Floor($i / 6); $col = $i % 6
        if (($row % 2) -eq 1) { $col = 5 - $col }
        $positions[$mainIds[$i]] = @([double](120 + $col*225), [double](150 + $row*185))
    }
    $positions["F10"] = @(1020.0, 650.0); $positions["F11"] = @(1245.0, 650.0)
    $titleById = @{}; foreach ($r in $roomSpecs) { $titleById[$r.id] = $r.title }
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='1500' height='820' viewBox='0 0 1500 820'><defs><marker id='oa' markerWidth='9' markerHeight='9' refX='8' refY='3' orient='auto'><path d='M0,0 L0,6 L9,3 z' fill='context-stroke'/></marker></defs><rect width='1500' height='820' fill='#0d1822'/><text x='70' y='62' fill='#f4e8c8' font-family='Microsoft YaHei,Segoe UI' font-size='30' font-weight='700'>方案 B · F01–F18 屏幕分段总览</text><text x='70' y='94' fill='#9fc1d2' font-family='Microsoft YaHei,Segoe UI' font-size='17'>18 房 / $stageSegmentTotal 屏 · 主路线、资源回环、挑战前送与双能力捷径</text>")
    $edges = @()
    for ($i=0;$i -lt $blueprint.formal_main_route.Count-1;$i++){ $edges += ,@($blueprint.formal_main_route[$i],$blueprint.formal_main_route[$i+1],"main") }
    foreach ($branch in $blueprint.branch_connections) { $edges += ,@($branch.from, $branch.to, $branch.kind) }
    foreach($edge in $edges){
        $a=$positions[$edge[0]]; $b=$positions[$edge[1]]; $kind=$edge[2]
        $color = if($kind -eq "main"){"#55d6e8"}elseif($kind -eq "ability_shortcut"){"#e9b95d"}elseif($kind -in @("resource_loop","challenge_forward")){"#c984f7"}else{"#71d69b"}
        $dash = if($kind -eq "main"){""}else{" stroke-dasharray='9 7'"}
        [void]$sb.AppendLine("<line x1='$($a[0])' y1='$($a[1])' x2='$($b[0])' y2='$($b[1])' stroke='$color' stroke-width='4'$dash marker-end='url(#oa)' opacity='0.85'/>")
    }
    foreach($id in @($mainIds + @("F10", "F11"))){
        $p=$positions[$id]; $room=$roomSpecs | Where-Object id -eq $id | Select-Object -First 1
        $segments=$room.segment_count
        [void]$sb.AppendLine("<rect x='$($p[0]-78)' y='$($p[1]-42)' width='156' height='84' rx='12' fill='#172c39' stroke='#5b7787' stroke-width='2'/><text x='$($p[0])' y='$($p[1]-8)' text-anchor='middle' fill='#f1dca5' font-family='Segoe UI' font-size='19' font-weight='700'>$id · ${segments}屏</text><text x='$($p[0])' y='$($p[1]+20)' text-anchor='middle' fill='#c8d7dd' font-family='Microsoft YaHei,Segoe UI' font-size='14'>$(EscapeXml $titleById[$id])</text>")
    }
    [void]$sb.AppendLine("<text x='70' y='790' fill='#87a8b8' font-family='Microsoft YaHei,Segoe UI' font-size='14'>青：正式主线 ｜ 紫：可选支路 ｜ 金：风印 + Air Dash 捷径 ｜ 绿：永久回环 / 返回 Hub</text></svg>")
    return $sb.ToString()
}

function RenderGameplayOverviewSvg([System.Collections.IDictionary]$blueprint) {
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='1600' height='1040' viewBox='0 0 1600 1040' data-view='gameplay_overview'><rect width='1600' height='1040' fill='#0d1822'/>")
    [void]$sb.AppendLine("<text x='60' y='58' fill='#f4e8c8' font-family='Microsoft YaHei,Segoe UI' font-size='30' font-weight='700'>F01–F18 Blueprint V2 · 玩法节奏总览</text><text x='60' y='90' fill='#9fc1d2' font-family='Microsoft YaHei,Segoe UI' font-size='16'>玩家认知、压力、连接、遭遇、奖励与失败恢复；总目标 30–45 分钟</text>")
    for ($i=0; $i -lt $blueprint.rooms.Count; $i++) {
        $room = $blueprint.rooms[$i]
        $row = [math]::Floor($i / 6); $col = $i % 6
        $x = 55 + $col * 255; $y = 125 + $row * 292
        $phase = ($blueprint.encounter_curve | Where-Object room_id -eq $room.id | Select-Object -First 1).phase
        $pressure = ($room.segments | ForEach-Object { $_.pressure }) -join "→"
        $rewardText = if($room.rewards.Count -eq 0){"none"}else{($room.rewards | ForEach-Object {$_.reward_id}) -join ", "}
        [void]$sb.AppendLine("<rect x='$x' y='$y' width='235' height='258' rx='11' fill='#172c39' stroke='#5b7787' stroke-width='2'/>")
        [void]$sb.AppendLine("<text x='$($x+14)' y='$($y+31)' fill='#f1dca5' font-family='Segoe UI' font-size='20' font-weight='700'>$($room.id) · $(EscapeXml $room.title)</text>")
        $lines = @("阶段：$phase", "压力：$pressure", "首访：$($room.timing_and_rhythm.first_visit)", "回访：$($room.timing_and_rhythm.revisit)", "连接：$($room.connections.Count)", "遭遇：$($room.encounters.Count)", "奖励：$rewardText", "重置：$($room.hazards_and_recovery.nearest_retry)")
        $ly = $y + 62
        foreach($line in $lines){
            $short = EscapeXml (ShortText ([string]$line) 29)
            [void]$sb.AppendLine("<text x='$($x+14)' y='$ly' fill='#c8d7dd' font-family='Microsoft YaHei,Segoe UI' font-size='13'>$short</text>")
            $ly += 24
        }
    }
    [void]$sb.AppendLine("<text x='60' y='1010' fill='#87a8b8' font-family='Microsoft YaHei,Segoe UI' font-size='14'>教学→首次胜利→Hub→区域揭示→机制教学→环境危险→门控→恢复→分支→目标→赋能→证明→回访→综合战斗→Boss→归驿</text></svg>")
    return $sb.ToString()
}

(RenderOverviewSvg $manifest) | Set-Content -LiteralPath (Join-Path $OutputDir "F01-F18-overview.svg") -Encoding UTF8
(RenderGameplayOverviewSvg $manifest) | Set-Content -LiteralPath (Join-Path $OutputDir "F01-F18-gameplay-overview.svg") -Encoding UTF8

$summary = [ordered]@{
    output_dir = $OutputDir
    manifest = $manifestPath
    room_count = $rooms.Count
    segment_count = $manifest.stage_segment_total
    topology_svg_count = $rooms.Count
    side_view_gameplay_svg_count = $rooms.Count
    overview_svg_count = 2
    expected_svg_count = ($rooms.Count * 2) + 2
}
$summary | ConvertTo-Json -Depth 5
