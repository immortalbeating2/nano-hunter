# Validate Phase 2 F04-F09 construction drawings against production scenes.
# This file stays ASCII-only so Windows PowerShell encoding cannot alter behavior.

[CmdletBinding()]
param(
    [string]$ConstructionDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if ([string]::IsNullOrWhiteSpace($ConstructionDir)) {
    $ConstructionDir = Join-Path $repoRoot "spec-design\formal-demo-room-construction"
}
$ConstructionDir = [System.IO.Path]::GetFullPath($ConstructionDir)
$manifestPath = Join-Path $ConstructionDir "phase2-room-construction-audit.json"
$summaryPath = Join-Path $ConstructionDir "phase2-room-construction-calibration.md"
$errors = [System.Collections.Generic.List[string]]::new()

function Require([bool]$condition, [string]$message) {
    if (-not $condition) {
        $errors.Add($message)
    }
}

Require (Test-Path -LiteralPath $manifestPath) "Missing construction audit JSON: $manifestPath"
Require (Test-Path -LiteralPath $summaryPath) "Missing construction calibration summary: $summaryPath"
if ($errors.Count -gt 0) {
    Write-Error ("CONSTRUCTION_DRAWING_VALIDATION_FAILED issues={0}`n{1}" -f $errors.Count, ($errors -join [Environment]::NewLine))
    exit 1
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$expectedIds = 4..9 | ForEach-Object { "F{0:D2}" -f $_ }
$actualIds = @($manifest.rooms | ForEach-Object { [string]$_.id })

Require ($manifest.schema_version -eq 1) "schema_version must equal 1"
Require ($manifest.source_of_truth -eq "production_tscn") "source_of_truth must be production_tscn"
Require ($manifest.calibration_status -eq "aligned_after_tuning") "calibration_status must be aligned_after_tuning"
Require (($actualIds -join ',') -eq ($expectedIds -join ',')) "Rooms must be ordered F04-F09"
Require ($manifest.rooms.Count -eq 6) "Expected exactly 6 rooms, got $($manifest.rooms.Count)"

foreach ($room in $manifest.rooms) {
    $id = [string]$room.id
    $sceneName = [System.IO.Path]::GetFileNameWithoutExtension(([string]$room.scene).Replace('res://', ''))
    $actualPath = Join-Path $ConstructionDir ("$id-$sceneName-actual.svg")
    $overlayPath = Join-Path $ConstructionDir ("$id-$sceneName-overlay.svg")
    Require (Test-Path -LiteralPath $actualPath) "$id missing actual drawing"
    Require (Test-Path -LiteralPath $overlayPath) "$id missing blueprint overlay"
    Require ([int]$room.segment_count -ge 2) "$id has invalid segment count"
    Require ([int]$room.runtime_platform_count -ge [int]$room.segment_count) "$id has too few runtime platforms"
    Require ([bool]$room.all_spawns_supported) "$id has an unsupported spawn"
    Require ([bool]$room.segment_coverage_ok) "$id has an uncovered camera segment"
    Require ([double]$room.max_anchor_dx -le 96.0) "$id max anchor dx exceeds 96u"
    Require ([double]$room.max_anchor_dy -le 72.0) "$id max anchor dy exceeds 72u"
    Require ([int]$room.blocking_issue_count -eq 0) "$id still has blocking deviations"

    if (Test-Path -LiteralPath $actualPath) {
        $actualSvg = Get-Content -Raw -LiteralPath $actualPath
        Require ($actualSvg.Contains("production .tscn")) "$id actual drawing lacks source label"
        Require ($actualSvg.Contains("96.44u")) "$id actual drawing lacks jump metric"
        Require ($actualSvg.Contains("110.00u")) "$id actual drawing lacks air-dash metric"
    }
    if (Test-Path -LiteralPath $overlayPath) {
        $overlaySvg = Get-Content -Raw -LiteralPath $overlayPath
        Require ($overlaySvg.Contains("BLUEPRINT OVERLAY")) "$id overlay lacks blueprint layer"
        Require ($overlaySvg.Contains("ACTUAL GEOMETRY")) "$id overlay lacks actual layer"
    }
}

Require ((Get-ChildItem -LiteralPath $ConstructionDir -Filter '*-actual.svg').Count -eq 6) "Expected exactly 6 actual SVG files"
Require ((Get-ChildItem -LiteralPath $ConstructionDir -Filter '*-overlay.svg').Count -eq 6) "Expected exactly 6 overlay SVG files"

if ($errors.Count -gt 0) {
    Write-Error ("CONSTRUCTION_DRAWING_VALIDATION_FAILED issues={0}`n{1}" -f $errors.Count, ($errors -join [Environment]::NewLine))
    exit 1
}

Write-Output ("CONSTRUCTION_DRAWING_VALIDATION_OK rooms={0} actual_svgs=6 overlay_svgs=6 max_dx={1:N2} max_dy={2:N2}" -f $manifest.rooms.Count, [double]$manifest.max_anchor_dx, [double]$manifest.max_anchor_dy)
