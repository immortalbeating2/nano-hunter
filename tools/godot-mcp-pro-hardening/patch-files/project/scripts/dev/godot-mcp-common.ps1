Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Godot MCP shared diagnostics.
# This file owns the local port plan and process classification used by all
# check/enter/repair scripts. Keep it in sync with the Node server, the Godot
# plugin, the hardening patch script, and docs/dev/godot-mcp-pro-connectivity-guide.md.
# Port plan:
# - 6505-6509 and 6515-6534: stdio MCP bridge candidates.
# - 6510-6514: godot-cli reserved temporary WebSocket servers.
# A bridge lock is only supporting evidence. Cleanup decisions must also check
# PID, TCP connections, Godot editor ownership, and workspace identity.

$script:GodotMcpStdioBridgePorts = @((6505..6509) + (6515..6534))
$script:GodotMcpCliPorts = @(6510..6514)
$script:GodotMcpPluginScanPorts = @(6505..6534)
$script:GodotMcpHeartbeatStaleSeconds = 30

function Get-GodotMcpPortPlan {
    [pscustomobject]@{
        StdioBridgePorts = ($script:GodotMcpStdioBridgePorts -join ",")
        CliPorts         = ($script:GodotMcpCliPorts -join ",")
        PluginScanPorts  = ($script:GodotMcpPluginScanPorts -join ",")
    }
}

function Resolve-NanoHunterWorkspacePath {
    param([string]$WorkspacePath)

    if ($WorkspacePath) {
        return (Resolve-Path -LiteralPath $WorkspacePath).Path
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    return (Resolve-Path -LiteralPath (Join-Path $scriptDirectory "..\..")).Path
}

function ConvertTo-GodotMcpComparablePath {
    param([string]$Path)

    if (-not $Path) {
        return ""
    }
    return (($Path -replace "\\", "/").TrimEnd("/") ).ToLowerInvariant()
}

function Get-GodotMcpBridgeLockRoot {
    $base = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [System.IO.Path]::GetTempPath() }
    return Join-Path $base "godot-mcp-pro\bridges"
}

function Get-GodotMcpBridgeLocks {
    $root = Get-GodotMcpBridgeLockRoot
    if (-not (Test-Path -LiteralPath $root)) {
        return @()
    }

    foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.json" -File -ErrorAction SilentlyContinue) {
        try {
            $json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
            $lastHeartbeat = if ($json.lastHeartbeat) { [datetime]$json.lastHeartbeat } else { $null }
            $age = if ($lastHeartbeat) { [math]::Round(((Get-Date) - $lastHeartbeat).TotalSeconds, 1) } else { $null }
            [pscustomobject]@{
                Path                = $file.FullName
                Port                = [int]$json.port
                Pid                 = [int]$json.pid
                Workspace           = [string]$json.workspace
                SessionId           = [string]$json.sessionId
                StartedAt           = [string]$json.startedAt
                LastHeartbeat       = [string]$json.lastHeartbeat
                HeartbeatAgeSeconds = $age
                Version             = [string]$json.version
                Kind                = [string]$json.kind
                IsHeartbeatStale    = ($null -eq $lastHeartbeat -or $age -gt $script:GodotMcpHeartbeatStaleSeconds)
                IsValid             = $true
            }
        } catch {
            [pscustomobject]@{
                Path                = $file.FullName
                Port                = $null
                Pid                 = $null
                Workspace           = ""
                SessionId           = ""
                StartedAt           = ""
                LastHeartbeat       = ""
                HeartbeatAgeSeconds = $null
                Version             = ""
                Kind                = "Invalid"
                IsHeartbeatStale    = $true
                IsValid             = $false
            }
        }
    }
}

function Test-GodotMcpProcessAlive {
    param([int]$ProcessId)

    if (-not $ProcessId) {
        return $false
    }
    return $null -ne (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue)
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
            Kind        = "stdio"
        }
    }
}

function Get-GodotMcpCliProcessInfos {
    $cliPattern = "*godot-mcp-pro/server/build/cli.js*"
    $nodeProcesses = Get-CimInstance Win32_Process -Filter "name = 'node.exe'" |
        Where-Object { $_.CommandLine -like $cliPattern }

    foreach ($processInfo in $nodeProcesses) {
        $runtimeProcess = Get-Process -Id $processInfo.ProcessId -ErrorAction SilentlyContinue
        [pscustomobject]@{
            ProcessId   = $processInfo.ProcessId
            CommandLine = $processInfo.CommandLine
            StartTime   = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            ProcessName = if ($runtimeProcess) { $runtimeProcess.ProcessName } else { "node" }
            Kind        = "cli"
        }
    }
}

function Get-GodotMcpBridgeListeners {
    param([int[]]$Ports = $script:GodotMcpStdioBridgePorts)

    $listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.LocalPort -in $Ports }

    foreach ($listener in $listeners) {
        $runtimeProcess = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
        [pscustomobject]@{
            LocalPort     = $listener.LocalPort
            OwningProcess = $listener.OwningProcess
            ProcessName   = if ($runtimeProcess) { $runtimeProcess.ProcessName } else { "" }
            StartTime     = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            Kind          = "stdio"
        }
    }
}

function Get-GodotMcpCliListeners {
    $listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.LocalPort -in $script:GodotMcpCliPorts }

    foreach ($listener in $listeners) {
        $runtimeProcess = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
        [pscustomobject]@{
            LocalPort     = $listener.LocalPort
            OwningProcess = $listener.OwningProcess
            ProcessName   = if ($runtimeProcess) { $runtimeProcess.ProcessName } else { "" }
            StartTime     = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            Kind          = "cli"
        }
    }
}

function Get-GodotEditorProcessInfos {
    param([string]$WorkspacePath)

    $workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
    $workspaceForwardSlash = $workspace -replace "\\", "/"
    $godotProcesses = Get-CimInstance Win32_Process |
        Where-Object { $_.Name -in @("Godot_v4.6.2-stable_win64.exe", "godot.exe") }

    foreach ($processInfo in $godotProcesses) {
        $runtimeProcess = Get-Process -Id $processInfo.ProcessId -ErrorAction SilentlyContinue
        $commandLine = if ($processInfo.CommandLine) { $processInfo.CommandLine } else { "" }
        [pscustomobject]@{
            ProcessId        = $processInfo.ProcessId
            CommandLine      = $commandLine
            MainWindowTitle  = if ($runtimeProcess) { $runtimeProcess.MainWindowTitle } else { "" }
            StartTime        = if ($runtimeProcess) { $runtimeProcess.StartTime } else { $null }
            MatchesWorkspace = ($commandLine -like "*$workspace*" -or $commandLine -like "*$workspaceForwardSlash*")
        }
    }
}

function Get-GodotEstablishedBridgeConnections {
    param(
        [string]$WorkspacePath,
        [int[]]$Ports = $script:GodotMcpPluginScanPorts
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
            PortKind      = if ($connection.RemotePort -in $script:GodotMcpCliPorts) { "cli" } else { "stdio" }
        }
    }
}

function Get-GodotMcpBridgeDiagnosticSnapshot {
    param([string]$WorkspacePath)

    $bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)
    $cliProcesses = @(Get-GodotMcpCliProcessInfos)
    $bridgeListeners = @(Get-GodotMcpBridgeListeners)
    $cliListeners = @(Get-GodotMcpCliListeners)
    $locks = @(Get-GodotMcpBridgeLocks)
    $editorConnections = @(Get-GodotEstablishedBridgeConnections -WorkspacePath $WorkspacePath)
    $connectedPorts = @($editorConnections | Where-Object { $_.PortKind -eq "stdio" } | Select-Object -ExpandProperty RemotePort -Unique)
    $workspaceComparable = ConvertTo-GodotMcpComparablePath (Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath)

    $latestBridgeStart = $null
    $bridgeStarts = @($bridgeProcesses | Where-Object { $_.StartTime } | Select-Object -ExpandProperty StartTime)
    if ($bridgeStarts.Count -gt 0) {
        $latestBridgeStart = ($bridgeStarts | Sort-Object | Select-Object -Last 1)
    }

    $enrichedListeners = foreach ($listener in $bridgeListeners) {
        $lock = @($locks | Where-Object { $_.Port -eq $listener.LocalPort } | Select-Object -First 1)
        $lockWorkspaceComparable = if ($lock) { ConvertTo-GodotMcpComparablePath $lock.Workspace } else { "" }
        $isConnectedToWorkspaceEditor = $connectedPorts -contains $listener.LocalPort
        $pidAlive = Test-GodotMcpProcessAlive -ProcessId $listener.OwningProcess
        $isLatestBatch = $false
        if ($latestBridgeStart -and $listener.StartTime) {
            $isLatestBatch = $listener.StartTime -ge $latestBridgeStart.AddSeconds(-10)
        }

        $staleReasons = @()
        if (-not $pidAlive) { $staleReasons += "PID not alive" }
        if ($lock -and $lock.IsHeartbeatStale) { $staleReasons += "Heartbeat stale" }
        if ($lock -and $lock.Workspace -and $lockWorkspaceComparable -ne $workspaceComparable) { $staleReasons += "Different workspace lock" }
        if (-not $isConnectedToWorkspaceEditor) { $staleReasons += "No current workspace editor connection" }
        if (-not $lock -and -not $isLatestBatch) { $staleReasons += "No lock and old listener" }

        [pscustomobject]@{
            LocalPort                  = $listener.LocalPort
            OwningProcess              = $listener.OwningProcess
            ProcessName                = $listener.ProcessName
            StartTime                  = $listener.StartTime
            Kind                       = "stdio"
            ConnectedToWorkspaceEditor = $isConnectedToWorkspaceEditor
            LikelyCurrentSession       = $isLatestBatch
            LikelyStaleBridge          = ($staleReasons.Count -gt 0 -and -not $isConnectedToWorkspaceEditor)
            StaleReason                = ($staleReasons -join "; ")
            LockWorkspace              = if ($lock) { $lock.Workspace } else { "" }
            SessionId                  = if ($lock) { $lock.SessionId } else { "" }
            LastHeartbeat              = if ($lock) { $lock.LastHeartbeat } else { "" }
            HeartbeatAgeSeconds        = if ($lock) { $lock.HeartbeatAgeSeconds } else { $null }
            LockPath                   = if ($lock) { $lock.Path } else { "" }
        }
    }

    $enrichedProcesses = foreach ($processInfo in $bridgeProcesses) {
        $listeningPorts = @($bridgeListeners |
            Where-Object { $_.OwningProcess -eq $processInfo.ProcessId } |
            Select-Object -ExpandProperty LocalPort |
            Sort-Object)
        $isConnectedToWorkspaceEditor = @($listeningPorts | Where-Object { $connectedPorts -contains $_ }).Count -gt 0
        $processLocks = @($locks | Where-Object { $_.Pid -eq $processInfo.ProcessId })
        $hasFreshLock = @($processLocks | Where-Object { -not $_.IsHeartbeatStale }).Count -gt 0
        $isLatestBatch = $false
        if ($latestBridgeStart -and $processInfo.StartTime) {
            $isLatestBatch = $processInfo.StartTime -ge $latestBridgeStart.AddSeconds(-10)
        }

        [pscustomobject]@{
            ProcessId                  = $processInfo.ProcessId
            ProcessName                = $processInfo.ProcessName
            Kind                       = "stdio"
            StartTime                  = $processInfo.StartTime
            ListeningPorts             = ($listeningPorts -join ",")
            ConnectedToWorkspaceEditor = $isConnectedToWorkspaceEditor
            LikelyCurrentSession       = $isLatestBatch
            LikelyStaleBridge          = (-not $isConnectedToWorkspaceEditor -and -not $hasFreshLock -and -not $isLatestBatch)
            StaleReason                = if ($hasFreshLock) { "" } elseif (-not $listeningPorts) { "No listener" } else { "No fresh lock/current connection" }
            CommandLine                = $processInfo.CommandLine
        }
    }

    [pscustomobject]@{
        BridgeProcesses   = $enrichedProcesses
        CliProcesses      = $cliProcesses
        BridgeListeners   = $enrichedListeners
        CliListeners      = $cliListeners
        BridgeLocks       = $locks
        EditorConnections = $editorConnections
    }
}

function Get-GodotMcpRecommendedAction {
    param([string]$WorkspacePath)

    $workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $WorkspacePath |
        Where-Object { $_.MatchesWorkspace })
    $snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $WorkspacePath
    $freshListeners = @($snapshot.BridgeListeners | Where-Object { -not $_.LikelyStaleBridge })
    $staleListeners = @($snapshot.BridgeListeners | Where-Object { $_.LikelyStaleBridge })
    $workspaceConnections = @($snapshot.EditorConnections | Where-Object { $_.PortKind -eq "stdio" })

    if ($workspaceEditors.Count -eq 0 -and $freshListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "SafeOpenEditor"
            Reason = "A stdio bridge is available, but no Godot editor is open for this workspace."
        }
    }

    if ($workspaceEditors.Count -gt 0 -and $workspaceConnections.Count -eq 0 -and $freshListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "SafeReopenEditor"
            Reason = "This workspace editor is open but has no established stdio bridge connection."
        }
    }

    if ($workspaceEditors.Count -gt 0 -and $workspaceConnections.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "AlreadyConnected"
            Reason = "This workspace editor already has an established stdio bridge connection."
        }
    }

    if ($workspaceEditors.Count -eq 0 -and $freshListeners.Count -eq 0 -and $staleListeners.Count -gt 0) {
        return [pscustomobject]@{
            RecommendedAction = "ReopenSessionThenCleanStaleBridge"
            Reason = "Only stale stdio bridge listeners were found. Clean them before reopening Codex if no other sessions need them."
        }
    }

    [pscustomobject]@{
        RecommendedAction = "InspectManually"
        Reason = "State is mixed or ambiguous. Inspect bridge locks, listeners, CLI ports, and editor connections before repairs."
    }
}

function Resolve-GodotExecutablePath {
    param([string]$GodotExe)

    $candidates = @()
    if ($GodotExe) { $candidates += $GodotExe }
    if ($env:GODOT_EXE) { $candidates += $env:GODOT_EXE }
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
