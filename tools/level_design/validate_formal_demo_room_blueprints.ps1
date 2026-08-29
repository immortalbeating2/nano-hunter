# Nano Hunter 正式 Demo Blueprint V2 一致性验证器。
# 校验 18 房、48 屏、玩法合同、双视图与正式 room program，不触达生产场景。

[CmdletBinding()]
param(
    [string]$BlueprintDir = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if ([string]::IsNullOrWhiteSpace($BlueprintDir)) {
    $BlueprintDir = Join-Path $repoRoot "spec-design\formal-demo-room-blueprints"
}
$BlueprintDir = [System.IO.Path]::GetFullPath($BlueprintDir)

$manifestPath = Join-Path $BlueprintDir "formal-demo-room-blueprints.json"
$overviewPaths = @(
    (Join-Path $BlueprintDir "F01-F18-overview.svg"),
    (Join-Path $BlueprintDir "F01-F18-gameplay-overview.svg")
)
$programPath = Join-Path $repoRoot "assets\configs\world_map\formal_demo_room_program.json"

$errors = [System.Collections.Generic.List[string]]::new()
function Require([bool]$condition, [string]$message) {
    if (-not $condition) { $errors.Add($message) }
}
function HasText($value) {
    return -not [string]::IsNullOrWhiteSpace([string]$value)
}
function Resolve-ResourcePath([string]$path) {
    if ($path.StartsWith("res://")) {
        return Join-Path $repoRoot $path.Substring(6).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
    }
    return $path
}

Require (Test-Path -LiteralPath $manifestPath) "缺少蓝图 JSON：$manifestPath"
foreach ($overviewPath in $overviewPaths) { Require (Test-Path -LiteralPath $overviewPath) "缺少总览 SVG：$overviewPath" }
Require (Test-Path -LiteralPath $programPath) "缺少正式 room program：$programPath"
if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$program = Get-Content -Raw -LiteralPath $programPath | ConvertFrom-Json
$expectedIds = @(1..18 | ForEach-Object { "F{0:D2}" -f $_ })
$manifestIds = @($manifest.rooms | ForEach-Object { [string]$_.id })
$programIds = @($program.formal_rooms | ForEach-Object { [string]$_.id })
$knownIds = @{}; foreach ($id in $expectedIds) { $knownIds[$id] = $true }

Require ($manifest.schema_version -eq 2) "schema_version 必须为 2"
Require ($manifest.design_status -eq "gameplay_blueprint_complete_runtime_scene_pending") "设计状态必须为 gameplay_blueprint_complete_runtime_scene_pending"
Require ($manifest.rooms.Count -eq 18) "必须精确包含 18 个正式房，实际 $($manifest.rooms.Count)"
Require (($manifestIds -join ',') -eq ($expectedIds -join ',')) "蓝图 ID 必须按 F01–F18 顺序完整排列"
Require (($programIds -join ',') -eq ($expectedIds -join ',')) "正式 room program 不再是 F01–F18"
Require (($manifest.camera_world_size -join 'x') -eq '640x360') "镜头世界尺寸必须为 640×360"
Require ($manifest.grid_unit -eq 32) "基础网格必须为 32u"

$requiredTopLevel = @("blueprint_contract", "connection_vocabulary", "progression_state_matrix", "encounter_curve", "presentation_contract", "acceptance_contract", "connection_matrix", "reward_matrix", "camera_matrix", "map_semantics_matrix", "qa_matrix")
foreach ($field in $requiredTopLevel) { Require ($null -ne $manifest.$field) "顶层缺少 $field" }
$requiredRoomFields = @("player_knowledge", "timing_and_rhythm", "connections", "interactions", "encounters", "hazards_and_recovery", "rewards", "state_variants", "camera", "presentation", "map_semantics", "qa", "views")
$requiredConnectionFields = @("connection_id", "type", "target_room", "source_anchor_id", "source_anchor_position", "target_spawn_id", "target_spawn_position", "target_facing", "directionality", "interaction_verb", "requirements", "blocked_feedback", "transition_feedback", "safe_arrival_contract", "anti_retrigger_contract", "map_representation")
$allowedConnectionTypes = @($manifest.connection_vocabulary | ForEach-Object { [string]$_.type })
$expectedConnectionTypes = @("adjacent_boundary", "architectural_door", "ability_gate", "encounter_gate", "remote_waystation", "one_way_terrain", "boss_gate")
Require (($allowedConnectionTypes -join ',') -eq ($expectedConnectionTypes -join ',')) "connection_vocabulary 必须完整冻结七种连接语义"
$expectedStates = @("first_visit", "wind_seal_unlocked", "air_dash_unlocked", "marsh_goal_completed", "seal_guardian_defeated")
$actualStates = @($manifest.progression_state_matrix | ForEach-Object { [string]$_.state })
Require (($actualStates -join ',') -eq ($expectedStates -join ',')) "progression_state_matrix 必须完整冻结五个状态"
Require ($manifest.encounter_curve.Count -eq 18) "encounter_curve 必须覆盖 18 房"
Require ($manifest.camera_matrix.Count -eq 18) "camera_matrix 必须覆盖 18 房"
Require ($manifest.map_semantics_matrix.Count -eq 18) "map_semantics_matrix 必须覆盖 18 房"
Require ($manifest.qa_matrix.Count -eq 18) "qa_matrix 必须覆盖 18 房"

$segmentSum = 0
$connectionCount = 0
$rewardCount = 0
$sceneSet = @{}
$topologyViews = @{}
$gameplayViews = @{}
foreach ($programRoom in $program.formal_rooms) { $sceneSet[[string]$programRoom.id] = [string]$programRoom.path }
foreach ($room in $manifest.rooms) {
    $id = [string]$room.id
    $segmentSum += [int]$room.segment_count
    Require ($room.blueprint_status -eq "gameplay_blueprint_complete") "$id 尚未达到 gameplay_blueprint_complete"
    foreach ($field in $requiredRoomFields) { Require ($null -ne $room.$field) "$id 缺少 $field" }
    Require ($sceneSet.ContainsKey($id)) "$id 不在正式 room program 中"
    Require ([string]$room.scene -eq $sceneSet[$id]) "$id 场景路径与正式 room program 不一致"
    Require ($room.segments.Count -eq [int]$room.segment_count) "$id segments 数与 segment_count 不一致"
    Require ($room.routes.Count -gt 0) "$id 缺少路线"
    Require ($room.zones.Count -gt 1) "$id 必须至少有入口和出口/交互节点"
    Require (HasText $room.landmark) "$id 缺少空间记忆点"
    Require (HasText $room.player_knowledge.knows_on_entry) "$id 缺少入场认知"
    Require (HasText $room.player_knowledge.learns_here) "$id 缺少本房学习目标"
    Require (HasText $room.player_knowledge.remembers_for_revisit) "$id 缺少回访记忆"
    Require (HasText $room.player_knowledge.knows_on_exit) "$id 缺少离场认知"
    Require (HasText $room.timing_and_rhythm.first_visit) "$id 缺少首访时长"
    Require (HasText $room.timing_and_rhythm.revisit) "$id 缺少回访时长"

    $zoneKinds = @($room.zones | ForEach-Object { [string]$_.kind })
    Require ($zoneKinds -contains 'entry') "$id 缺少 entry 安全出生节点"
    Require (($zoneKinds -contains 'exit') -or ($zoneKinds -contains 'one_way_exit') -or ($zoneKinds -contains 'waystation')) "$id 缺少明确离场节点"
    foreach ($segment in $room.segments) {
        Require (HasText $segment.purpose) "$id/$($segment.id) 缺少职责"
        Require (HasText $segment.geometry) "$id/$($segment.id) 缺少几何合同"
        Require (HasText $segment.pressure) "$id/$($segment.id) 缺少压力合同"
        Require (HasText $segment.safety) "$id/$($segment.id) 缺少安全合同"
        Require ($null -ne $segment.camera) "$id/$($segment.id) 缺少相机合同"
        Require ($null -ne $segment.presentation) "$id/$($segment.id) 缺少表现合同"
    }

    Require ($room.connections.Count -gt 0) "$id 至少需要一条连接"
    $connectionCount += $room.connections.Count
    foreach ($connection in $room.connections) {
        foreach ($field in $requiredConnectionFields) { Require ($null -ne $connection.$field) "$id/$($connection.connection_id) 缺少 $field" }
        Require ($knownIds.ContainsKey([string]$connection.target_room)) "$id/$($connection.connection_id) 指向未知房间 $($connection.target_room)"
        Require ($allowedConnectionTypes -contains [string]$connection.type) "$id/$($connection.connection_id) 使用未知连接类型 $($connection.type)"
        Require (HasText $connection.source_anchor_id) "$id/$($connection.connection_id) 缺少来源 Spawn"
        Require (HasText $connection.target_spawn_id) "$id/$($connection.connection_id) 缺少目标 Spawn"
        Require ($connection.source_anchor_position.coordinate_space -eq "segment_normalized") "$id/$($connection.connection_id) 来源坐标空间错误"
        Require ($connection.target_spawn_position.coordinate_space -eq "segment_normalized") "$id/$($connection.connection_id) 目标坐标空间错误"
        Require ($connection.safe_arrival_contract.safe_runway -ge 160) "$id/$($connection.connection_id) 安全落地不足 160u"
        Require ($connection.anti_retrigger_contract.arrival_outside_source_trigger -eq $true) "$id/$($connection.connection_id) 未声明防反弹"
    }

    if ($room.encounters.Count -eq 0) {
        Require ($room.encounter_policy -eq "safe_no_encounter") "$id 无遭遇时必须声明 safe_no_encounter"
        Require (HasText $room.safe_room_reason) "$id 无遭遇时必须说明安全原因"
    } else {
        Require ($room.encounter_policy -eq "authored_combat_encounters") "$id 有遭遇时策略错误"
        foreach ($encounter in $room.encounters) {
            Require ($encounter.enemy_types.Count -gt 0) "$id/$($encounter.encounter_id) 缺少敌人类型"
            Require (HasText $encounter.failure_reset) "$id/$($encounter.encounter_id) 缺少失败重置"
            Require (HasText $encounter.revisit_rule) "$id/$($encounter.encounter_id) 缺少回访规则"
        }
    }
    Require (HasText $room.hazards_and_recovery.failure_reset) "$id 缺少危险失败重置"
    Require ($room.hazards_and_recovery.global_fall_dependency -eq "forbidden_and_not_required") "$id 仍依赖 Main 全局跌落恢复"
    $rewardCount += $room.rewards.Count
    foreach ($reward in $room.rewards) {
        Require (HasText $reward.reward_id) "$id 奖励缺少 ID"
        Require (HasText $reward.repeat_rule) "$id/$($reward.reward_id) 缺少重复领取规则"
        Require (HasText $reward.map_feedback) "$id/$($reward.reward_id) 缺少地图反馈"
    }
    Require ($room.state_variants.Count -eq 5) "$id state_variants 必须覆盖五个状态"
    Require ((@($room.state_variants | ForEach-Object { $_.state }) -join ',') -eq ($expectedStates -join ',')) "$id state_variants 顺序或状态不完整"
    Require ($room.camera.segments.Count -eq $room.segment_count) "$id 相机分段数错误"
    Require ($room.qa.natural_input_routes.Count -gt 0) "$id 缺少自然输入 QA 路线"
    Require ($room.map_semantics.connection_icons.Count -eq $room.connections.Count) "$id 地图连接语义与连接数不一致"

    $topologyPath = Resolve-ResourcePath ([string]$room.views.topology)
    $gameplayPath = Resolve-ResourcePath ([string]$room.views.side_view_gameplay)
    $topologyViews[$topologyPath] = $true
    $gameplayViews[$gameplayPath] = $true
    Require (Test-Path -LiteralPath $topologyPath) "$id 缺少 topology SVG：$topologyPath"
    Require (Test-Path -LiteralPath $gameplayPath) "$id 缺少 side_view_gameplay SVG：$gameplayPath"
    if (Test-Path -LiteralPath $topologyPath) {
        $svg = Get-Content -Raw -LiteralPath $topologyPath
        Require ($svg.Contains("data-view='topology'")) "$id topology SVG 类型错误"
        Require ($svg.Contains("$id ·")) "$id topology SVG 缺少房间标题"
        for ($i = 1; $i -le [int]$room.segment_count; $i++) { Require ($svg.Contains("S$i")) "$id topology SVG 缺少 S$i" }
    }
    if (Test-Path -LiteralPath $gameplayPath) {
        $svg = Get-Content -Raw -LiteralPath $gameplayPath
        Require ($svg.Contains("data-view='side_view_gameplay'")) "$id side_view_gameplay SVG 类型错误"
        Require ($svg.Contains("1 空间与移动")) "$id gameplay SVG 缺少空间层"
        Require ($svg.Contains("2 遭遇与危险")) "$id gameplay SVG 缺少遭遇层"
        Require ($svg.Contains("3 交互、门控与状态")) "$id gameplay SVG 缺少交互层"
        Require ($svg.Contains("4 相机、地标与表现")) "$id gameplay SVG 缺少表现层"
        for ($i = 1; $i -le [int]$room.segment_count; $i++) { Require ($svg.Contains("S$i")) "$id gameplay SVG 缺少 S$i" }
    }
}

Require ($segmentSum -eq 48) "总屏数必须为 48，实际 $segmentSum"
Require ([int]$manifest.stage_segment_total -eq $segmentSum) "manifest 总屏数与逐房求和不一致"
Require ($manifest.safety_contract.Count -ge 5) "全局安全合同不足 5 条"
Require ($topologyViews.Count -eq 18) "topology SVG 必须精确为 18 张"
Require ($gameplayViews.Count -eq 18) "side_view_gameplay SVG 必须精确为 18 张"
Require ($manifest.connection_matrix.Count -eq $connectionCount) "connection_matrix 与逐房连接数不一致"
Require ($manifest.reward_matrix.Count -eq $rewardCount) "reward_matrix 与逐房奖励数不一致"
Require ((Get-ChildItem -LiteralPath $BlueprintDir -Filter '*.svg').Count -eq 38) "蓝图目录必须精确包含 36 张逐房图与 2 张总览"

foreach ($id in $program.formal_main_route) { Require ($knownIds.ContainsKey([string]$id)) "正式主路线引用未知房间：$id" }
foreach ($edge in $program.formal_branch_connections) {
    Require ($knownIds.ContainsKey([string]$edge.from)) "支路 from 引用未知房间：$($edge.from)"
    Require ($knownIds.ContainsKey([string]$edge.to)) "支路 to 引用未知房间：$($edge.to)"
}

$f07ToF14 = $manifest.rooms[6].connections | Where-Object connection_id -eq "F07_to_F14" | Select-Object -First 1
$f14ToF07 = $manifest.rooms[13].connections | Where-Object connection_id -eq "F14_to_F07" | Select-Object -First 1
$f14ToF15 = $manifest.rooms[13].connections | Where-Object connection_id -eq "F14_to_F15" | Select-Object -First 1
$f18ToF03 = $manifest.rooms[17].connections | Where-Object connection_id -eq "F18_to_F03" | Select-Object -First 1
Require ($f07ToF14.type -eq "remote_waystation" -and $f07ToF14.interaction_verb -eq "confirm") "F07→F14 必须是主动祭坛捷径"
Require ($f14ToF07.type -eq "remote_waystation" -and $f14ToF07.interaction_verb -eq "confirm") "F14→F07 必须是主动祭坛捷径"
Require ($f14ToF15.type -eq "ability_gate" -and $f14ToF15.source_anchor_id -ne $f14ToF07.source_anchor_id) "F14→F15 必须与 F14→F07 使用不同通道"
Require ($manifest.rooms[14].connections.target_room -notcontains "F07") "F15 不得继续保留错误的 F07 捷径入口"
Require ($f18ToF03.type -eq "remote_waystation" -and $f18ToF03.interaction_verb -eq "confirm") "F18→F03 必须主动确认法坛"

if ($errors.Count -gt 0) {
    Write-Error ("BLUEPRINT_V2_VALIDATION_FAILED issues={0}`n{1}" -f $errors.Count, ($errors -join [Environment]::NewLine))
    exit 1
}

Write-Output ("BLUEPRINT_V2_VALIDATION_OK rooms={0} segments={1} connections={2} rewards={3} topology=18 side_view_gameplay=18 overviews=2" -f $manifest.rooms.Count, $segmentSum, $connectionCount, $rewardCount)
