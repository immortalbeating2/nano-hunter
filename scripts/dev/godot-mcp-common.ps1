Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Godot MCP 诊断公共库。
# 适用场景：
# - 被 check / enter / safe-repair / open-worktree 脚本点源引用，统一端口规划、进程识别、lock 读取和 stale 判断。
# - 不直接手动运行；如果需要人工诊断，请运行 check-godot-mcp.ps1 或 enter-worktree-godot-mcp.ps1。
# 是否会修改：
# - 本文件只定义函数和常量；单独 dot-source 不会杀进程、不启动 Godot、不写文件。
# 端口规划：
# - 6505-6509 与 6515-6534 是 stdio MCP bridge 候选端口。
# - 6510-6514 永远保留给 godot-cli 临时 WebSocket server。
# 安全边界：
# - bridge lock/heartbeat 只是辅助证据，不是唯一真相。
# - stale 清理必须同时结合 PID、TCP 连接、Godot editor 归属、workspace 身份和 heartbeat 年龄。
# - 本文件的端口规划必须与 Node server、Godot 插件、补丁脚本和 docs/dev/godot-mcp-pro-connectivity-guide.md 同步。

$script:GodotMcpStdioBridgePorts = @((6505..6509) + (6515..6534))
$script:GodotMcpCliPorts = @(6510..6514)
$script:GodotMcpPluginScanPorts = @(6505..6534)
$script:GodotMcpHeartbeatStaleSeconds = 30

function Get-GodotMcpPortPlan {
    # 返回统一端口规划，供诊断输出和 dry-run 使用。
    # 输出：stdio bridge 端口、CLI reserved 端口、插件扫描端口的逗号分隔字符串。
    [pscustomobject]@{
        StdioBridgePorts = ($script:GodotMcpStdioBridgePorts -join ",")
        CliPorts         = ($script:GodotMcpCliPorts -join ",")
        PluginScanPorts  = ($script:GodotMcpPluginScanPorts -join ",")
    }
}

function Resolve-GodotMcpWorkspacePath {
    # 解析目标 Godot 项目根目录。
    # 输入：可选 -WorkspacePath；未传时从脚本所在 scripts/dev 向上两级推断。
    # 输出：绝对路径；如果路径不存在会抛错。
    param([string]$WorkspacePath)

    if ($WorkspacePath) {
        return (Resolve-Path -LiteralPath $WorkspacePath).Path
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    return (Resolve-Path -LiteralPath (Join-Path $scriptDirectory "..\..")).Path
}

function ConvertTo-GodotMcpComparablePath {
    # 将路径规范化为可比较形式，避免 Windows 反斜杠、大小写和末尾斜杠导致 workspace 误判。
    # 输入：任意路径字符串。
    # 输出：小写、正斜杠、无末尾斜杠的路径字符串。
    param([string]$Path)

    if (-not $Path) {
        return ""
    }
    return (($Path -replace "\\", "/").TrimEnd("/") ).ToLowerInvariant()
}

function Get-GodotMcpBridgeLockRoot {
    # 返回 bridge lock 根目录。
    # 优先使用 LOCALAPPDATA；缺失时退到系统 temp，与 Node server 的 lock 策略保持一致。
    $base = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [System.IO.Path]::GetTempPath() }
    return Join-Path $base "godot-mcp-pro\bridges"
}

function Get-GodotMcpBridgeLocks {
    # 读取所有 bridge lock，并计算 heartbeat age 和 stale 状态。
    # 输出：lock 对象数组；损坏 JSON 会以 IsValid=false 返回，便于人工诊断。
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
    # 检查 PID 是否仍存在。
    # 输出：布尔值；PID 不存在或为空时返回 false。
    param([int]$ProcessId)

    if (-not $ProcessId) {
        return $false
    }
    return $null -ne (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue)
}

function Get-GodotMcpBridgeProcessInfos {
    # 找出 stdio bridge Node 进程。
    # 只匹配 server/build/index.js，避免把 godot-cli 的 cli.js 临时进程误判为 bridge。
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
    # 找出 godot-cli 临时 Node 进程。
    # CLI 进程仅用于诊断展示，永远不作为 stale bridge 自动清理目标。
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
    # 读取 stdio bridge 监听端口。
    # 默认只看 6505-6509 与 6515-6534，显式跳过 6510-6514 CLI reserved。
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
    # 读取 6510-6514 godot-cli reserved 监听端口。
    # 这些监听只用于确认 CLI 是否占用，不参与 bridge stale 清理。
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
    # 找出本机 Godot editor 进程，并判断命令行是否指向目标 workspace。
    # 输出中 MatchesWorkspace=true 的进程才允许被 safe-repair 关闭。
    param([string]$WorkspacePath)

    $workspace = Resolve-GodotMcpWorkspacePath -WorkspacePath $WorkspacePath
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
    # 查询目标 workspace Godot editor 到 bridge/CLI 端口的 Established TCP 连接。
    # 输出 PortKind=stdio/cli，避免把 CLI 连接当作 MCP bridge 可用证据。
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
    # 汇总进程、监听端口、lock、Godot editor 连接，并计算 stale reason。
    # 输出：诊断快照对象；本函数只读，不执行修复动作。
    param([string]$WorkspacePath)

    $bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)
    $cliProcesses = @(Get-GodotMcpCliProcessInfos)
    $bridgeListeners = @(Get-GodotMcpBridgeListeners)
    $cliListeners = @(Get-GodotMcpCliListeners)
    $locks = @(Get-GodotMcpBridgeLocks)
    $editorConnections = @(Get-GodotEstablishedBridgeConnections -WorkspacePath $WorkspacePath)
    $connectedPorts = @($editorConnections | Where-Object { $_.PortKind -eq "stdio" } | Select-Object -ExpandProperty RemotePort -Unique)
    $workspaceComparable = ConvertTo-GodotMcpComparablePath (Resolve-GodotMcpWorkspacePath -WorkspacePath $WorkspacePath)

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
    # 根据诊断快照给出保守推荐动作。
    # 输出 RecommendedAction 与 Reason；调用方决定是否真正执行修复。
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
    # 解析 Godot 可执行文件路径。
    # 优先级：显式 -GodotExe、GODOT_EXE 环境变量、项目当前默认安装路径。
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
    # 以统一格式输出诊断表格。
    # 输入：标题与行对象数组；空数组输出 (empty)，便于 dry-run 和日志阅读。
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
