param(
    [string]$SessionsRoot = "$env:USERPROFILE\.codex\sessions",
    [string]$SessionPath = "",
    [string]$OutDir = "assets/source/imagegen_inbox/recovered-nano-hunter-session",
    [string]$ProjectFilter = "",
    [string]$ImportMap = "",
    [switch]$TodayOnly,
    [switch]$AllSessions,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Get-SessionFiles {
    if (-not [string]::IsNullOrWhiteSpace($SessionPath)) {
        $resolvedSession = Resolve-RepoPath $SessionPath
        if (-not (Test-Path -LiteralPath $resolvedSession)) {
            throw "SessionPath not found: $resolvedSession"
        }
        return @(Get-Item -LiteralPath $resolvedSession)
    }

    if (-not (Test-Path -LiteralPath $SessionsRoot)) {
        throw "SessionsRoot not found: $SessionsRoot"
    }

    if ($TodayOnly -and -not $AllSessions) {
        $today = Get-Date -Format "yyyy\\MM\\dd"
        $todayDir = Join-Path $SessionsRoot $today
        if (-not (Test-Path -LiteralPath $todayDir)) {
            return @()
        }
        return @(Get-ChildItem -LiteralPath $todayDir -Filter "*.jsonl" -File)
    }

    return @(Get-ChildItem -LiteralPath $SessionsRoot -Filter "*.jsonl" -File -Recurse)
}

function Find-ImageGenerationItems {
    param([object]$Node)

    if ($null -eq $Node) {
        return
    }

    if ($Node -is [string]) {
        return
    }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [pscustomobject])) {
        foreach ($child in $Node) {
            Find-ImageGenerationItems -Node $child
        }
        return
    }

    $typeProperty = $Node.PSObject.Properties["type"]
    $resultProperty = $Node.PSObject.Properties["result"]
    if ($typeProperty -and $resultProperty -and $Node.type -eq "image_generation_call" -and -not [string]::IsNullOrWhiteSpace([string]$Node.result)) {
        $Node
    }

    foreach ($property in $Node.PSObject.Properties) {
        if ($property.Name -eq "result") {
            continue
        }
        Find-ImageGenerationItems -Node $property.Value
    }
}

function Normalize-Batch {
    param([string]$Batch)
    $value = $Batch.Trim().ToLowerInvariant()
    if ($value.StartsWith("batch_")) {
        return $value
    }
    return "batch_{0:D2}" -f [int]$value
}

function Get-ImportTarget {
    param(
        [object]$MapEntry,
        [string]$ImageId
    )

    if ($null -eq $MapEntry) {
        return $null
    }

    $batch = Normalize-Batch ([string]$MapEntry.batch)
    $assetId = [string]$MapEntry.asset_id
    $slot = if ($MapEntry.slot) { [string]$MapEntry.slot } else { "candidates" }
    $extension = if ($MapEntry.extension) { [string]$MapEntry.extension } else { ".png" }
    if (-not $extension.StartsWith(".")) {
        $extension = ".$extension"
    }

    $targetDir = Join-Path (Get-Location).Path ("assets/source/ai_generated/{0}/{1}/{2}" -f $batch, $assetId, $slot)
    if ($slot -eq "candidates") {
        $index = if ($MapEntry.candidate_index) { [int]$MapEntry.candidate_index } else { 1 }
        return Join-Path $targetDir ("{0}_candidate_{1:D2}{2}" -f $assetId, $index, $extension.ToLowerInvariant())
    }

    $safeId = $ImageId -replace '[^A-Za-z0-9_.-]', '_'
    return Join-Path $targetDir ("{0}_{1}{2}" -f $assetId, $safeId, $extension.ToLowerInvariant())
}

function Load-ImportMap {
    if ([string]::IsNullOrWhiteSpace($ImportMap)) {
        return @{}
    }

    $resolvedMap = Resolve-RepoPath $ImportMap
    if (-not (Test-Path -LiteralPath $resolvedMap)) {
        throw "ImportMap not found: $resolvedMap"
    }

    $json = Get-Content -LiteralPath $resolvedMap -Raw | ConvertFrom-Json
    $entries = if ($json.items) { $json.items } elseif ($json.written) { $json.written } else { $json }
    $map = @{}
    foreach ($entry in $entries) {
        $id = if ($entry.image_id) { [string]$entry.image_id } elseif ($entry.id) { [string]$entry.id } else { "" }
        if (-not [string]::IsNullOrWhiteSpace($id) -and $entry.batch -and $entry.asset_id) {
            $map[$id] = $entry
        }
    }
    return $map
}

$resolvedOutDir = Resolve-RepoPath $OutDir
$resolvedProjectFilter = if ([string]::IsNullOrWhiteSpace($ProjectFilter)) { (Get-Location).Path } else { $ProjectFilter }
$importMapById = Load-ImportMap

if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $resolvedOutDir | Out-Null
}

$written = New-Object System.Collections.Generic.List[object]
$files = Get-SessionFiles

foreach ($file in $files) {
    if (-not [string]::IsNullOrWhiteSpace($resolvedProjectFilter) -and [string]::IsNullOrWhiteSpace($SessionPath)) {
        $matchesProject = Select-String -LiteralPath $file.FullName -Pattern $resolvedProjectFilter -SimpleMatch -Quiet
        if (-not $matchesProject) {
            continue
        }
    }

    $lineNumber = 0
    $stream = [System.IO.File]::Open($file.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $reader = New-Object System.IO.StreamReader($stream)
    try {
        while (($line = $reader.ReadLine()) -ne $null) {
            $lineNumber++
            if ($line -notmatch '"image_generation_call"' -or $line -notmatch '"result"') {
                continue
            }

            try {
                $entry = $line | ConvertFrom-Json
            } catch {
                continue
            }

            foreach ($item in (Find-ImageGenerationItems -Node $entry)) {
                $id = if ($item.id) { [string]$item.id } else { "imagegen_line_$lineNumber" }
                $safeId = $id -replace '[^A-Za-z0-9_.-]', '_'
                $sessionSlug = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $name = "{0}-{1}.png" -f $sessionSlug, $safeId
                if ($name.Length -gt 180) {
                    $name = "{0}.png" -f $safeId
                }

                $inboxPath = Join-Path $resolvedOutDir $name
                $mapEntry = if ($importMapById.ContainsKey($id)) { $importMapById[$id] } else { $null }
                $importTarget = Get-ImportTarget -MapEntry $mapEntry -ImageId $id

                $status = "planned"
                $bytes = 0
                if (-not $DryRun) {
                    $data = [Convert]::FromBase64String([string]$item.result)
                    $bytes = $data.Length
                    if (-not (Test-Path -LiteralPath $inboxPath)) {
                        [System.IO.File]::WriteAllBytes($inboxPath, $data)
                        $status = "wrote_inbox"
                    } else {
                        $status = "inbox_exists"
                    }

                    if ($importTarget) {
                        $targetDir = Split-Path -Parent $importTarget
                        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
                        if (-not (Test-Path -LiteralPath $importTarget)) {
                            [System.IO.File]::WriteAllBytes($importTarget, $data)
                            $status = "$status+imported"
                        } else {
                            $status = "$status+target_exists"
                        }
                    }
                }

                $written.Add([pscustomobject]@{
                    Id = $id
                    Source = $file.FullName
                    Line = $lineNumber
                    InboxPath = $inboxPath
                    ImportTarget = $importTarget
                    Bytes = $bytes
                    Status = $status
                }) | Out-Null
            }
        }
    } finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

$ledgerPath = Join-Path $resolvedOutDir "recovery-ledger.json"
if (-not $DryRun) {
    $written | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ledgerPath -Encoding UTF8
}

$written | Format-Table -AutoSize
"Recovered {0} image(s) to {1}" -f $written.Count, $resolvedOutDir
if (-not $DryRun) {
    "Ledger: {0}" -f $ledgerPath
}
