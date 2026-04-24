Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-NanoHunterWorkspacePath {
    param(
        [string]$WorkspacePath
    )

    if ($WorkspacePath) {
        return (Resolve-Path -LiteralPath $WorkspacePath).Path
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    return (Resolve-Path -LiteralPath (Join-Path $scriptDirectory "..\..")).Path
}

function Get-GodotMcpBridgeProcessInfos {
    $bridgePattern = "*godot-mcp-pro/server/build/index.js*"
    $nodeProcesses = Get-CimInstance Win32_Process -Filter "name = 'node.exe'" |
        Where-Object { $_.CommandLine -like $bridgePattern }

    foreach ($processInfo in $nodeProcesses) {
        $runtimeProcess = Get-Process -Id $processInfo.ProcessId -ErrorAction SilentlyContinue
        [pscustomobject]@{
            ProcessId   = $processInfo.ProcessId
            CommandLine = $processInfo.CommandLine
            StartTime   = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            ProcessName = if ($runtimeProcess) { $runtimeProcess.ProcessName } else { "node" }
        }
    }
}

function Get-GodotMcpBridgeListeners {
    param(
        [int[]]$Ports = @(6505, 6506, 6507, 6508, 6509)
    )

    $listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.LocalPort -in $Ports }

    foreach ($listener in $listeners) {
        $runtimeProcess = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
        [pscustomobject]@{
            LocalPort     = $listener.LocalPort
            OwningProcess = $listener.OwningProcess
            ProcessName   = if ($runtimeProcess) { $runtimeProcess.ProcessName } else { "" }
            StartTime     = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
        }
    }
}

function Get-GodotEditorProcessInfos {
    param(
        [string]$WorkspacePath
    )

    $workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
    $godotProcesses = Get-CimInstance Win32_Process |
        Where-Object { $_.Name -in @("Godot_v4.6.2-stable_win64.exe", "godot.exe") }

    foreach ($processInfo in $godotProcesses) {
        $runtimeProcess = Get-Process -Id $processInfo.ProcessId -ErrorAction SilentlyContinue
        $commandLine = if ($processInfo.CommandLine) { $processInfo.CommandLine } else { "" }
        [pscustomobject]@{
            ProcessId       = $processInfo.ProcessId
            CommandLine     = $commandLine
            MainWindowTitle = if ($runtimeProcess) { $runtimeProcess.MainWindowTitle } else { "" }
            StartTime       = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            MatchesWorkspace = ($commandLine -like "*$workspace*")
        }
    }
}

function Get-GodotEstablishedBridgeConnections {
    param(
        [string]$WorkspacePath,
        [int[]]$Ports = @(6505, 6506, 6507, 6508, 6509, 6510, 6511, 6512, 6513, 6514)
    )

    $workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $WorkspacePath |
        Where-Object { $_.MatchesWorkspace })

    if (-not $workspaceEditors) {
        return @()
    }

    $workspaceProcessIds = $workspaceEditors.ProcessId
    $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
        Where-Object { $_.OwningProcess -in $workspaceProcessIds -and $_.RemotePort -in $Ports }

    foreach ($connection in $connections) {
        [pscustomobject]@{
            OwningProcess = $connection.OwningProcess
            LocalAddress  = $connection.LocalAddress
            LocalPort     = $connection.LocalPort
            RemoteAddress = $connection.RemoteAddress
            RemotePort    = $connection.RemotePort
        }
    }
}

function Get-GodotMcpBridgeDiagnosticSnapshot {
    param(
        [string]$WorkspacePath
    )

    $bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)
    $bridgeListeners = @(Get-GodotMcpBridgeListeners)
    $editorConnections = @(Get-GodotEstablishedBridgeConnections -WorkspacePath $WorkspacePath)
    $connectedPorts = @($editorConnections | Select-Object -ExpandProperty RemotePort -Unique)

    $latestBridgeStart = $null
    $bridgeStarts = @($bridgeProcesses | Where-Object { $_.StartTime } | Select-Object -ExpandProperty StartTime)
    if ($bridgeStarts.Count -gt 0) {
        $latestBridgeStart = ($bridgeStarts | Sort-Object | Select-Object -Last 1)
    }

    $enrichedListeners = foreach ($listener in $bridgeListeners) {
        $isConnectedToWorkspaceEditor = $connectedPorts -contains $listener.LocalPort
        $isLatestBatch = $false
        if ($latestBridgeStart -and $listener.StartTime) {
            $isLatestBatch = $listener.StartTime -ge $latestBridgeStart.AddSeconds(-10)
        }

        [pscustomobject]@{
            LocalPort                  = $listener.LocalPort
            OwningProcess              = $listener.OwningProcess
            ProcessName                = $listener.ProcessName
            StartTime                  = $listener.StartTime
            ConnectedToWorkspaceEditor = $isConnectedToWorkspaceEditor
            LikelyCurrentSession       = $isLatestBatch
            LikelyStaleBridge          = (-not $isLatestBatch)
        }
    }

    $enrichedProcesses = foreach ($processInfo in $bridgeProcesses) {
        $listeningPorts = @($bridgeListeners |
            Where-Object { $_.OwningProcess -eq $processInfo.ProcessId } |
            Select-Object -ExpandProperty LocalPort |
            Sort-Object)
        $isConnectedToWorkspaceEditor = @($listeningPorts | Where-Object { $connectedPorts -contains $_ }).Count -gt 0
        $isLatestBatch = $false
        if ($latestBridgeStart -and $processInfo.StartTime) {
            $isLatestBatch = $processInfo.StartTime -ge $latestBridgeStart.AddSeconds(-10)
        }

        [pscustomobject]@{
            ProcessId                  = $processInfo.ProcessId
            ProcessName                = $processInfo.ProcessName
            StartTime                  = $processInfo.StartTime
            ListeningPorts             = ($listeningPorts -join ",")
            ConnectedToWorkspaceEditor = $isConnectedToWorkspaceEditor
            LikelyCurrentSession       = $isLatestBatch
            LikelyStaleBridge          = (-not $isLatestBatch)
            CommandLine                = $processInfo.CommandLine
        }
    }

    return [pscustomobject]@{
        BridgeProcesses = $enrichedProcesses
        BridgeListeners = $enrichedListeners
        EditorConnections = $editorConnections
    }
}

function Get-GodotMcpRecommendedAction {
    param(
        [string]$WorkspacePath
    )

    $workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $WorkspacePath |
        Where-Object { $_.MatchesWorkspace })
    $snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $WorkspacePath
    $likelyCurrentListeners = @($snapshot.BridgeListeners | Where-Object { $_.LikelyCurrentSession })
    $likelyStaleListeners = @($snapshot.BridgeListeners | Where-Object { $_.LikelyStaleBridge })
    $workspaceConnections = @($snapshot.EditorConnections)

    if ($workspaceEditors.Count -eq 0 -and $likelyCurrentListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "SafeOpenEditor"
            Reason = "Current-session bridge likely exists, but no Godot editor is open for this workspace."
        }
    }

    if ($workspaceEditors.Count -gt 0 -and $workspaceConnections.Count -eq 0 -and $likelyCurrentListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "SafeReopenEditor"
            Reason = "Current-session bridge likely exists, but this workspace editor has no established bridge connections."
        }
    }

    if ($workspaceEditors.Count -gt 0 -and $workspaceConnections.Count -gt 0 -and $likelyStaleListeners.Count -gt 0 -and $likelyCurrentListeners.Count -eq 0) {
        return [pscustomobject]@{
            RecommendedAction = "ReopenSessionThenForceKillBridge"
            Reason = "This workspace editor is connected only to bridges that look stale. Reopen the Codex session, then use -ForceKillBridge."
        }
    }

    if ($workspaceEditors.Count -eq 0 -and $likelyCurrentListeners.Count -eq 0 -and $likelyStaleListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "ReopenSessionThenForceKillBridge"
            Reason = "Only stale bridge listeners were found. Reopen the Codex session and reset bridges."
        }
    }

    if ($workspaceEditors.Count -gt 0 -and $workspaceConnections.Count -gt 0 -and $likelyCurrentListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "AlreadyConnected"
            Reason = "This workspace editor already has established bridge connections and a current-session bridge is present."
        }
    }

    return [pscustomobject]@{
        RecommendedAction = "InspectManually"
        Reason = "State is mixed or ambiguous. Inspect bridge start times, listeners, and editor connections before forcing repairs."
    }
}

function Resolve-GodotExecutablePath {
    param(
        [string]$GodotExe
    )

    $candidates = @()
    if ($GodotExe) {
        $candidates += $GodotExe
    }
    if ($env:GODOT_EXE) {
        $candidates += $env:GODOT_EXE
    }
    $candidates += "C:\AITOOL\Godot\Godot Engine\Godot_v4.6.2-stable_win64.exe"

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "Could not find a Godot executable. Pass -GodotExe or set GODOT_EXE."
}

function Write-GodotMcpSection {
    param(
        [string]$Title,
        [object[]]$Rows
    )

    Write-Host ""
    Write-Host "=== $Title ==="
    if (-not $Rows -or $Rows.Count -eq 0) {
        Write-Host "(empty)"
        return
    }

    $Rows | Format-Table -AutoSize | Out-String | Write-Host
}
