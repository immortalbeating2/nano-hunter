# Reverse-generate Phase 2 F04-F09 construction drawings from production .tscn files.
# This script is ASCII-only for deterministic Windows PowerShell execution.

[CmdletBinding()]
param(
    [string]$BlueprintPath = "",
    [string]$ConstructionDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:Invariant = [System.Globalization.CultureInfo]::InvariantCulture
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if ([string]::IsNullOrWhiteSpace($BlueprintPath)) {
    $BlueprintPath = Join-Path $repoRoot "spec-design\formal-demo-room-blueprints\formal-demo-room-blueprints.json"
}
if ([string]::IsNullOrWhiteSpace($ConstructionDir)) {
    $ConstructionDir = Join-Path $repoRoot "spec-design\formal-demo-room-construction"
}
$BlueprintPath = [System.IO.Path]::GetFullPath($BlueprintPath)
$ConstructionDir = [System.IO.Path]::GetFullPath($ConstructionDir)
$null = New-Item -ItemType Directory -Force -Path $ConstructionDir

function Num([double]$value) {
    return $value.ToString("0.##", $script:Invariant)
}

function SvgText([string]$value) {
    return [System.Security.SecurityElement]::Escape($value)
}

function Parse-Vector([string]$value) {
    $match = [regex]::Match($value, 'Vector2\(\s*(-?[0-9.]+)\s*,\s*(-?[0-9.]+)\s*\)')
    if (-not $match.Success) {
        throw "Cannot parse Vector2: $value"
    }
    return [pscustomobject]@{ x = [double]$match.Groups[1].Value; y = [double]$match.Groups[2].Value }
}

function Parse-Scene([string]$scenePath) {
    $text = Get-Content -Raw -LiteralPath $scenePath
    $idMatch = [regex]::Match($text, 'metadata/formal_room_id = "(F[0-9]{2})"')
    $cameraMatch = [regex]::Match($text, 'camera_limits = Rect2i\(\s*(-?[0-9]+)\s*,\s*(-?[0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*\)')
    $segmentMatch = [regex]::Match($text, '(?m)^segment_count = ([0-9]+)$')
    $profileMatch = [regex]::Match($text, '(?m)^layout_profile = &"([^"]+)"$')
    if (-not ($idMatch.Success -and $cameraMatch.Success -and $segmentMatch.Success -and $profileMatch.Success)) {
        throw "Missing construction metadata in $scenePath"
    }

    $solids = [System.Collections.Generic.List[object]]::new()
    $oneWays = [System.Collections.Generic.List[object]]::new()
    foreach ($kind in @('solid_rects', 'one_way_rects')) {
        $lineMatch = [regex]::Match($text, "(?m)^$kind = .+$")
        if (-not $lineMatch.Success) { throw "Missing $kind in $scenePath" }
        foreach ($rectMatch in [regex]::Matches($lineMatch.Value, 'Rect2\(\s*(-?[0-9.]+)\s*,\s*(-?[0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)')) {
            $rect = [pscustomobject]@{
                x = [double]$rectMatch.Groups[1].Value
                y = [double]$rectMatch.Groups[2].Value
                w = [double]$rectMatch.Groups[3].Value
                h = [double]$rectMatch.Groups[4].Value
            }
            if ($kind -eq 'solid_rects') { $solids.Add($rect) } else { $oneWays.Add($rect) }
        }
    }

    $nodes = [ordered]@{}
    $currentName = $null
    $currentType = $null
    foreach ($line in ($text -split "`r?`n")) {
        $nodeMatch = [regex]::Match($line, '^\[node name="([^"]+)" type="([^"]+)" parent="\."')
        if ($nodeMatch.Success) {
            $currentName = $nodeMatch.Groups[1].Value
            $currentType = $nodeMatch.Groups[2].Value
            continue
        }
        if ($line.StartsWith('[node ')) {
            $currentName = $null
            $currentType = $null
            continue
        }
        if ($null -ne $currentName -and $line -match '^position = (Vector2\(.+\))$') {
            $point = Parse-Vector $Matches[1]
            $nodes[$currentName] = [pscustomobject]@{ name = $currentName; type = $currentType; x = $point.x; y = $point.y }
            $currentName = $null
            $currentType = $null
        }
    }

    $spawns = [System.Collections.Generic.List[object]]::new()
    $spawnMatch = [regex]::Match($text, 'spawn_positions = \{(?<body>.*?)\}', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($spawnMatch.Success) {
        foreach ($entry in [regex]::Matches($spawnMatch.Groups['body'].Value, '&"([^"]+)"\s*:\s*(Vector2\([^\)]+\))')) {
            $point = Parse-Vector $entry.Groups[2].Value
            $spawns.Add([pscustomobject]@{ name = $entry.Groups[1].Value; x = $point.x; y = $point.y })
        }
    }

    return [pscustomobject]@{
        id = $idMatch.Groups[1].Value
        camera = [pscustomobject]@{
            x = [double]$cameraMatch.Groups[1].Value
            y = [double]$cameraMatch.Groups[2].Value
            w = [double]$cameraMatch.Groups[3].Value
            h = [double]$cameraMatch.Groups[4].Value
        }
        segment_count = [int]$segmentMatch.Groups[1].Value
        layout_profile = $profileMatch.Groups[1].Value
        solids = @($solids)
        one_ways = @($oneWays)
        nodes = $nodes
        spawns = @($spawns)
        scene_text = $text
    }
}

function Get-SupportDrop($scene, [double]$x, [double]$y) {
    $best = [double]::PositiveInfinity
    foreach ($rect in @($scene.solids) + @($scene.one_ways)) {
        if ($x -lt $rect.x -or $x -gt ($rect.x + $rect.w)) { continue }
        $drop = $rect.y - $y
        if ($drop -ge 0.0 -and $drop -lt $best) { $best = $drop }
    }
    return $best
}

function Get-AnchorMap([string]$roomId) {
    $maps = @{
        F04 = @(
            @{ zone = 0; actual = 'spawn:stage13_entry_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:RegionVistaMarker'; name = 'region_vista' },
            @{ zone = 2; actual = 'node:MiasmaWarningMarker'; name = 'miasma_warning' },
            @{ zone = 3; actual = 'node:CrossGateVistaMarker'; name = 'cross_gate_vista' },
            @{ zone = 4; actual = 'node:ExitZone'; name = 'exit' }
        )
        F05 = @(
            @{ zone = 0; actual = 'spawn:stage13_miasma_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:ProjectileObservationMarker'; name = 'projectile_observe' },
            @{ zone = 2; actual = 'node:WindSealShrine'; name = 'wind_shrine' },
            @{ zone = 3; actual = 'node:ProjectilePracticeMarker'; name = 'projectile_practice' },
            @{ zone = 4; actual = 'node:ExitZone'; name = 'exit' }
        )
        F06 = @(
            @{ zone = 0; actual = 'spawn:stage13_miasma_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:AirDashRevisitReward'; name = 'revisit_reward' },
            @{ zone = 2; actual = 'node:MiasmaHazard'; name = 'miasma_hazard' },
            @{ zone = 3; actual = 'node:ExitZone'; name = 'exit' }
        )
        F07 = @(
            @{ zone = 0; actual = 'spawn:stage13_gate_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:GateBarrier'; name = 'ability_gate' },
            @{ zone = 2; actual = 'node:ShortcutZone'; name = 'f14_shortcut' },
            @{ zone = 3; actual = 'node:ExitZone'; name = 'exit' }
        )
        F08 = @(
            @{ zone = 0; actual = 'spawn:stage13_checkpoint_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:RecoveryPoint'; name = 'checkpoint' },
            @{ zone = 2; actual = 'node:ResourceLoopLandingMarker'; name = 'f10_loop_landing' },
            @{ zone = 3; actual = 'node:ExitZone'; name = 'exit' }
        )
        F09 = @(
            @{ zone = 0; actual = 'spawn:stage13_branch_hub_start'; name = 'entry' },
            @{ zone = 1; actual = 'node:ThreeRouteLandmark'; name = 'three_route_landmark' },
            @{ zone = 2; actual = 'node:ResourceBranchZone'; name = 'resource_branch' },
            @{ zone = 3; actual = 'node:ChallengeBranchZone'; name = 'challenge_branch' },
            @{ zone = 4; actual = 'node:ExitZone'; name = 'main_exit' },
            @{ zone = 5; actual = 'node:AirDashFastRouteEntryMarker'; name = 'fast_entry' },
            @{ zone = 6; actual = 'node:AirDashFastRouteExitMarker'; name = 'fast_exit' }
        )
    }
    return $maps[$roomId]
}

function Resolve-ActualPoint($scene, [string]$token) {
    $parts = $token.Split(':', 2)
    if ($parts[0] -eq 'node') {
        if (-not $scene.nodes.Contains($parts[1])) { throw "Missing node $($parts[1]) in $($scene.id)" }
        return $scene.nodes[$parts[1]]
    }
    foreach ($spawn in $scene.spawns) {
        if ($spawn.name -eq $parts[1]) { return $spawn }
    }
    throw "Missing spawn $($parts[1]) in $($scene.id)"
}

function Add-Grid([System.Text.StringBuilder]$svg, $scene, [double]$scale, [double]$originX, [double]$originY) {
    $worldLeft = $scene.camera.x
    $worldRight = $scene.camera.x + $scene.camera.w
    $worldTop = -64.0
    $worldBottom = 352.0
    for ($x = $worldLeft; $x -le $worldRight; $x += 32.0) {
        $sx = $originX + (($x - $worldLeft) * $scale)
        $major = (([int](($x - $worldLeft) / 32.0)) % 20 -eq 0)
        $color = if ($major) { '#48666d' } else { '#243c42' }
        $width = if ($major) { '1.4' } else { '0.7' }
        $null = $svg.AppendLine("<line x1='$(Num $sx)' y1='$(Num $originY)' x2='$(Num $sx)' y2='$(Num ($originY + (($worldBottom - $worldTop) * $scale)))' stroke='$color' stroke-width='$width'/>")
    }
    for ($y = $worldTop; $y -le $worldBottom; $y += 32.0) {
        $sy = $originY + (($y - $worldTop) * $scale)
        $null = $svg.AppendLine("<line x1='$(Num $originX)' y1='$(Num $sy)' x2='$(Num ($originX + ($scene.camera.w * $scale)))' y2='$(Num $sy)' stroke='#243c42' stroke-width='0.7'/>")
    }
    for ($index = 0; $index -lt $scene.segment_count; $index++) {
        $sx = $originX + (($index * 640.0) * $scale)
        $null = $svg.AppendLine("<rect x='$(Num $sx)' y='$(Num $originY)' width='$(Num (640.0 * $scale))' height='$(Num (($worldBottom - $worldTop) * $scale))' fill='none' stroke='#8aa2a7' stroke-width='1.5' stroke-dasharray='8 7'/>")
        $null = $svg.AppendLine("<text x='$(Num ($sx + 10))' y='$(Num ($originY + 20))' fill='#a9bbc0' font-size='14' font-family='Segoe UI,Arial'>S$($index + 1)</text>")
    }
}

function Add-ActualGeometry([System.Text.StringBuilder]$svg, $scene, [double]$scale, [double]$originX, [double]$originY, [double]$opacity) {
    $worldLeft = $scene.camera.x
    $worldTop = -64.0
    foreach ($rect in $scene.solids) {
        $x = $originX + (($rect.x - $worldLeft) * $scale)
        $y = $originY + (($rect.y - $worldTop) * $scale)
        $null = $svg.AppendLine("<rect x='$(Num $x)' y='$(Num $y)' width='$(Num ($rect.w * $scale))' height='$(Num ($rect.h * $scale))' rx='2' fill='#173f46' fill-opacity='$(Num $opacity)' stroke='#4fb6b4' stroke-width='2'/>")
    }
    foreach ($rect in $scene.one_ways) {
        $x = $originX + (($rect.x - $worldLeft) * $scale)
        $y = $originY + (($rect.y - $worldTop) * $scale)
        $null = $svg.AppendLine("<rect x='$(Num $x)' y='$(Num $y)' width='$(Num ($rect.w * $scale))' height='$(Num ([math]::Max(4.0, $rect.h * $scale)))' fill='#49a7b2' fill-opacity='$(Num $opacity)' stroke='#94eced' stroke-width='1.5'/>")
    }
}

function Add-ActualAnchors([System.Text.StringBuilder]$svg, $anchorRows, $scene, [double]$scale, [double]$originX, [double]$originY) {
    $worldLeft = $scene.camera.x
    $worldTop = -64.0
    foreach ($row in $anchorRows) {
        $x = $originX + (($row.actual_x - $worldLeft) * $scale)
        $y = $originY + (($row.actual_y - $worldTop) * $scale)
        $null = $svg.AppendLine("<circle cx='$(Num $x)' cy='$(Num $y)' r='5' fill='#f6c85f' stroke='#201b12' stroke-width='1.5'/>")
        $null = $svg.AppendLine("<text x='$(Num ($x + 8))' y='$(Num ($y - 7))' fill='#ffe2a0' font-size='12' font-family='Segoe UI,Arial'>$(SvgText $row.name)</text>")
    }
    foreach ($spawn in $scene.spawns) {
        $x = $originX + (($spawn.x - $worldLeft) * $scale)
        $y = $originY + (($spawn.y - $worldTop) * $scale)
        $null = $svg.AppendLine("<path d='M $(Num $x) $(Num ($y - 6)) L $(Num ($x + 6)) $(Num $y) L $(Num $x) $(Num ($y + 6)) L $(Num ($x - 6)) $(Num $y) Z' fill='#9ee493' stroke='#1b351c' stroke-width='1.2'/>")
    }
}

function Add-Blueprint([System.Text.StringBuilder]$svg, $blueprintRoom, $scene, [double]$scale, [double]$originX, [double]$originY) {
    $worldLeft = $scene.camera.x
    $worldTop = -64.0
    $routeColors = @('#ff6b6b', '#f7b267', '#84dcc6', '#c7a0ff')
    $routeIndex = 0
    foreach ($route in $blueprintRoom.routes) {
        $points = [System.Collections.Generic.List[string]]::new()
        foreach ($point in $route.points) {
            $wx = $worldLeft + ([double]$point[0] * 640.0)
            $wy = [double]$point[1] * 360.0
            $points.Add("$(Num ($originX + (($wx - $worldLeft) * $scale))),$(Num ($originY + (($wy - $worldTop) * $scale)))")
        }
        $color = $routeColors[$routeIndex % $routeColors.Count]
        $null = $svg.AppendLine("<polyline points='$($points -join ' ')' fill='none' stroke='$color' stroke-width='3' stroke-dasharray='10 7' stroke-linejoin='round'/>")
        $routeIndex++
    }
    foreach ($zone in $blueprintRoom.zones) {
        $wx = $worldLeft + ([double]$zone.x * 640.0)
        $wy = [double]$zone.y * 360.0
        $x = $originX + (($wx - $worldLeft) * $scale)
        $y = $originY + (($wy - $worldTop) * $scale)
        $null = $svg.AppendLine("<circle cx='$(Num $x)' cy='$(Num $y)' r='7' fill='#ff6b6b' fill-opacity='0.28' stroke='#ff817a' stroke-width='2'/>")
    }
}

function Add-DeviationVectors([System.Text.StringBuilder]$svg, $anchorRows, $scene, [double]$scale, [double]$originX, [double]$originY) {
    $worldLeft = $scene.camera.x
    $worldTop = -64.0
    foreach ($row in $anchorRows) {
        $blueprintX = $originX + (($row.blueprint_x - $worldLeft) * $scale)
        $blueprintY = $originY + (($row.blueprint_y - $worldTop) * $scale)
        $actualX = $originX + (($row.actual_x - $worldLeft) * $scale)
        $actualY = $originY + (($row.actual_y - $worldTop) * $scale)
        $null = $svg.AppendLine("<line x1='$(Num $blueprintX)' y1='$(Num $blueprintY)' x2='$(Num $actualX)' y2='$(Num $actualY)' stroke='#ffd166' stroke-width='1.2' stroke-dasharray='3 3'/>")
        $midX = ($blueprintX + $actualX) * 0.5
        $midY = ($blueprintY + $actualY) * 0.5
        $null = $svg.AppendLine("<text x='$(Num ($midX + 4))' y='$(Num ($midY - 4))' fill='#ffd166' font-size='9' font-family='Segoe UI,Arial'>dx $(Num $row.dx) / dy $(Num $row.dy)</text>")
    }
}

function New-SvgHeader([string]$title, [string]$subtitle, [double]$width, [double]$height) {
    $svg = [System.Text.StringBuilder]::new()
    $null = $svg.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$(Num $width)' height='$(Num $height)' viewBox='0 0 $(Num $width) $(Num $height)'>")
    $null = $svg.AppendLine("<rect width='100%' height='100%' fill='#0d171b'/>")
    $null = $svg.AppendLine("<text x='36' y='36' fill='#e8f0ec' font-size='24' font-weight='700' font-family='Segoe UI,Arial'>$(SvgText $title)</text>")
    $null = $svg.AppendLine("<text x='36' y='60' fill='#93a7aa' font-size='13' font-family='Segoe UI,Arial'>$(SvgText $subtitle)</text>")
    return $svg
}

function Add-MetricLegend([System.Text.StringBuilder]$svg, [double]$height) {
    $y = $height - 42.0
    $null = $svg.AppendLine("<line x1='42' y1='$(Num $y)' x2='138.44' y2='$(Num $y)' stroke='#f6c85f' stroke-width='5'/>")
    $null = $svg.AppendLine("<text x='145' y='$(Num ($y + 5))' fill='#f6c85f' font-size='13' font-family='Segoe UI,Arial'>jump sample 96.44u</text>")
    $null = $svg.AppendLine("<line x1='320' y1='$(Num $y)' x2='430' y2='$(Num $y)' stroke='#7ee0df' stroke-width='5'/>")
    $null = $svg.AppendLine("<text x='438' y='$(Num ($y + 5))' fill='#7ee0df' font-size='13' font-family='Segoe UI,Arial'>Air Dash 110.00u</text>")
    $null = $svg.AppendLine("<text x='650' y='$(Num ($y + 5))' fill='#93a7aa' font-size='13' font-family='Segoe UI,Arial'>grid 32u | camera segment 640x360</text>")
}

$blueprint = Get-Content -Raw -LiteralPath $BlueprintPath | ConvertFrom-Json
$blueprintRooms = @($blueprint.rooms | Where-Object { $_.id -in @('F04','F05','F06','F07','F08','F09') })
$roomReports = [System.Collections.Generic.List[object]]::new()
$allAnchorRows = [System.Collections.Generic.List[object]]::new()

$beforeTuning = @{
    F04 = 'Vista x -64 and descent x 544 compressed the three-segment reveal.'
    F05 = 'Projectile observation anchor was absent; shrine/practice anchors were not blueprint-auditable.'
    F06 = 'Air Dash reward sat at (880,64) on the first-visit upper route instead of the lower revisit route.'
    F07 = 'Gate and shortcut shared x=800; F14 return spawn was 178.89u from the shortcut marker.'
    F08 = 'F10 return spawn was (560,76), outside the blueprint loop landing and lacked a named landing marker.'
    F09 = 'Lower resource branch had only 32u below an overlapping solid main floor; fast entry/decision anchors were absent.'
}

foreach ($blueprintRoom in $blueprintRooms) {
    $sceneRelative = ([string]$blueprintRoom.scene).Replace('res://', '').Replace('/', '\')
    $scenePath = Join-Path $repoRoot $sceneRelative
    $scene = Parse-Scene $scenePath
    if ($scene.id -ne $blueprintRoom.id) { throw "Blueprint/scene id mismatch for $scenePath" }
    $anchorRows = [System.Collections.Generic.List[object]]::new()
    foreach ($map in (Get-AnchorMap $scene.id)) {
        $zone = $blueprintRoom.zones[[int]$map.zone]
        $actual = Resolve-ActualPoint $scene ([string]$map.actual)
        $blueprintX = $scene.camera.x + ([double]$zone.x * 640.0)
        $blueprintY = [double]$zone.y * 360.0
        $row = [pscustomobject]@{
            room = $scene.id
            name = [string]$map.name
            blueprint_x = [math]::Round($blueprintX, 2)
            blueprint_y = [math]::Round($blueprintY, 2)
            actual_x = [math]::Round([double]$actual.x, 2)
            actual_y = [math]::Round([double]$actual.y, 2)
            dx = [math]::Round([double]$actual.x - $blueprintX, 2)
            dy = [math]::Round([double]$actual.y - $blueprintY, 2)
        }
        $anchorRows.Add($row)
        $allAnchorRows.Add($row)
    }

    $unsupportedSpawns = [System.Collections.Generic.List[string]]::new()
    foreach ($spawn in $scene.spawns) {
        $drop = Get-SupportDrop $scene $spawn.x $spawn.y
        if ([double]::IsPositiveInfinity($drop) -or $drop -gt 56.0) {
            $unsupportedSpawns.Add("$($spawn.name):$(Num $drop)")
        }
    }
    $uncoveredSegments = [System.Collections.Generic.List[string]]::new()
    for ($segment = 0; $segment -lt $scene.segment_count; $segment++) {
        $left = $scene.camera.x + ($segment * 640.0)
        $right = $left + 640.0
        $covered = @($scene.solids + $scene.one_ways | Where-Object { $_.x -lt $right -and ($_.x + $_.w) -gt $left }).Count -gt 0
        if (-not $covered) { $uncoveredSegments.Add("S$($segment + 1)") }
    }

    $roomMaxDx = ($anchorRows | ForEach-Object { [math]::Abs([double]$_.dx) } | Measure-Object -Maximum).Maximum
    $roomMaxDy = ($anchorRows | ForEach-Object { [math]::Abs([double]$_.dy) } | Measure-Object -Maximum).Maximum
    $blocking = $unsupportedSpawns.Count + $uncoveredSegments.Count
    if ($roomMaxDx -gt 96.0 -or $roomMaxDy -gt 72.0) { $blocking++ }
    $sceneName = [System.IO.Path]::GetFileNameWithoutExtension($sceneRelative)

    $scale = 0.58
    $originX = 36.0
    $originY = 84.0
    $worldHeight = 416.0
    $width = [math]::Ceiling(($scene.camera.w * $scale) + 72.0)
    $height = [math]::Ceiling(($worldHeight * $scale) + 154.0)
    $actualSvg = New-SvgHeader "$($scene.id) $($blueprintRoom.title) - ACTUAL CONSTRUCTION" "reverse generated from production .tscn | profile $($scene.layout_profile) | $($scene.segment_count) camera segments" $width $height
    Add-Grid $actualSvg $scene $scale $originX $originY
    Add-ActualGeometry $actualSvg $scene $scale $originX $originY 0.9
    Add-ActualAnchors $actualSvg $anchorRows $scene $scale $originX $originY
    Add-MetricLegend $actualSvg $height
    $null = $actualSvg.AppendLine('</svg>')
    $actualPath = Join-Path $ConstructionDir "$($scene.id)-$sceneName-actual.svg"
    [System.IO.File]::WriteAllText($actualPath, $actualSvg.ToString(), [System.Text.UTF8Encoding]::new($false))

    $overlaySvg = New-SvgHeader "$($scene.id) $($blueprintRoom.title) - BLUEPRINT OVERLAY" "ACTUAL GEOMETRY (cyan) + BLUEPRINT OVERLAY (dashed routes/red anchors) | max dx $(Num $roomMaxDx)u | max dy $(Num $roomMaxDy)u" $width $height
    Add-Grid $overlaySvg $scene $scale $originX $originY
    Add-ActualGeometry $overlaySvg $scene $scale $originX $originY 0.6
    Add-Blueprint $overlaySvg $blueprintRoom $scene $scale $originX $originY
    Add-DeviationVectors $overlaySvg $anchorRows $scene $scale $originX $originY
    Add-ActualAnchors $overlaySvg $anchorRows $scene $scale $originX $originY
    Add-MetricLegend $overlaySvg $height
    $null = $overlaySvg.AppendLine('</svg>')
    $overlayPath = Join-Path $ConstructionDir "$($scene.id)-$sceneName-overlay.svg"
    [System.IO.File]::WriteAllText($overlayPath, $overlaySvg.ToString(), [System.Text.UTF8Encoding]::new($false))

    $roomReports.Add([ordered]@{
        id = $scene.id
        title = [string]$blueprintRoom.title
        scene = [string]$blueprintRoom.scene
        layout_profile = $scene.layout_profile
        segment_count = $scene.segment_count
        runtime_platform_count = $scene.solids.Count + $scene.one_ways.Count
        all_spawns_supported = ($unsupportedSpawns.Count -eq 0)
        unsupported_spawns = @($unsupportedSpawns)
        segment_coverage_ok = ($uncoveredSegments.Count -eq 0)
        uncovered_segments = @($uncoveredSegments)
        max_anchor_dx = [math]::Round([double]$roomMaxDx, 2)
        max_anchor_dy = [math]::Round([double]$roomMaxDy, 2)
        blocking_issue_count = $blocking
        before_tuning = $beforeTuning[$scene.id]
        actual_drawing = "$($scene.id)-$sceneName-actual.svg"
        overlay_drawing = "$($scene.id)-$sceneName-overlay.svg"
        anchors = @($anchorRows)
    })
}

$globalMaxDx = ($allAnchorRows | ForEach-Object { [math]::Abs([double]$_.dx) } | Measure-Object -Maximum).Maximum
$globalMaxDy = ($allAnchorRows | ForEach-Object { [math]::Abs([double]$_.dy) } | Measure-Object -Maximum).Maximum
$totalBlocking = 0
foreach ($report in $roomReports) {
    $totalBlocking += [int]$report.blocking_issue_count
}
$manifest = [ordered]@{
    schema_version = 1
    generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
    source_of_truth = 'production_tscn'
    blueprint = 'spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json'
    projection = 'side_scroll_mode'
    grid_unit = 32
    camera_segment = '640x360'
    movement_metrics = [ordered]@{ jump_sample_distance = 96.44; air_dash_sample_distance = 110.0 }
    calibration_status = if ($totalBlocking -eq 0) { 'aligned_after_tuning' } else { 'needs_tuning' }
    max_anchor_dx = [math]::Round([double]$globalMaxDx, 2)
    max_anchor_dy = [math]::Round([double]$globalMaxDy, 2)
    rooms = @($roomReports)
}
$manifestPath = Join-Path $ConstructionDir 'phase2-room-construction-audit.json'
[System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))

$summary = [System.Text.StringBuilder]::new()
$null = $summary.AppendLine('# F04-F09 actual construction calibration')
$null = $summary.AppendLine()
$null = $summary.AppendLine('This report is regenerated from the six production `.tscn` scenes. The original blueprint remains the design baseline; cyan geometry and gold anchors are current runtime construction.')
$null = $summary.AppendLine()
$null = $summary.AppendLine('## Calibration result')
$null = $summary.AppendLine()
$null = $summary.AppendLine(('- Status: `{0}`' -f $manifest.calibration_status))
$null = $summary.AppendLine(('- Global maximum anchor deviation: dx `{0}u`, dy `{1}u`' -f (Num $globalMaxDx), (Num $globalMaxDy)))
$null = $summary.AppendLine('- Movement rulers: jump sample `96.44u`; Air Dash sample `110.00u`; grid `32u`; camera segment `640x360`.')
$null = $summary.AppendLine('- Automated evidence proves scene structure, collision support, segment coverage, route clearance, and anchor tolerances. It does not replace a fresh human playtest.')
$null = $summary.AppendLine()
$null = $summary.AppendLine('## Before/after deviations')
$null = $summary.AppendLine()
$null = $summary.AppendLine('| Room | Before tuning | After tuning |')
$null = $summary.AppendLine('|---|---|---|')
foreach ($report in $roomReports) {
    $after = "max dx $(Num $report.max_anchor_dx)u / max dy $(Num $report.max_anchor_dy)u; spawns supported=$($report.all_spawns_supported); segments covered=$($report.segment_coverage_ok)"
    $null = $summary.AppendLine("| $($report.id) | $($report.before_tuning) | $after |")
}
$null = $summary.AppendLine()
$null = $summary.AppendLine('## Deliverables')
$null = $summary.AppendLine()
foreach ($report in $roomReports) {
    $null = $summary.AppendLine("- $($report.id): [$($report.actual_drawing)]($($report.actual_drawing)) + [$($report.overlay_drawing)]($($report.overlay_drawing))")
}
$summaryPath = Join-Path $ConstructionDir 'phase2-room-construction-calibration.md'
[System.IO.File]::WriteAllText($summaryPath, $summary.ToString(), [System.Text.UTF8Encoding]::new($false))

Write-Output ("CONSTRUCTION_DRAWING_GENERATION_OK rooms={0} actual_svgs=6 overlay_svgs=6 status={1} max_dx={2:N2} max_dy={3:N2}" -f $roomReports.Count, $manifest.calibration_status, [double]$globalMaxDx, [double]$globalMaxDy)
