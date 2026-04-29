param(
    [string]$WorkspacePath,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# Godot MCP 安全修复脚本。
# 适用场景：
# - enter-worktree-godot-mcp.ps1 判断需要重开当前 worktree Godot。
# - 用户确认没有其它 Godot MCP 会话依赖 stale stdio bridge 后，执行受限清理。
# 是否会修改：
# - 默认会关闭命令行指向当前 workspace 的 Godot editor，不关闭其它 workspace 的 Godot。
# - 只有 -ForceKillBridge 才会停止 stale stdio bridge 进程。
# - 不清理 6510-6514 godot-cli reserved 端口进程。
# 常用命令：
# - 预览：.\scripts\dev\safe-repair-godot-mcp.ps1 -DryRun
# - 受限清理 stale bridge：.\scripts\dev\safe-repair-godot-mcp.ps1 -ForceKillBridge
# 安全边界：
# - stale 判断必须同时结合 lock/heartbeat、PID、当前 workspace editor 连接和 workspace 归属。
# - 不能只因为端口年龄旧就杀进程；旧但仍被其它 workspace 使用的 bridge 应保留。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-GodotMcpWorkspacePath -WorkspacePath $WorkspacePath
$workspaceComparable = ConvertTo-GodotMcpComparablePath $workspace
$workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace })
$otherEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { -not $_.MatchesWorkspace })
$snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace

Write-Host "Workspace: $workspace"
Write-Host "Safe mode: CLI ports are never cleaned; bridge cleanup requires -ForceKillBridge."

foreach ($editor in $workspaceEditors) {
    # 只处理命令行指向当前 workspace 的编辑器，固定工作树收口时不误关其他 Godot。
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop current workspace Godot editor PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
    } else {
        Stop-Process -Id $editor.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

foreach ($editor in $otherEditors) {
    Write-Host ("Leaving non-workspace Godot editor running PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
}

if ($ForceKillBridge) {
    $staleBridgePids = @()
    foreach ($bridge in $snapshot.BridgeListeners) {
        $lockWorkspaceComparable = ConvertTo-GodotMcpComparablePath $bridge.LockWorkspace
        $belongsToWorkspace = ($lockWorkspaceComparable -eq "" -or $lockWorkspaceComparable -eq $workspaceComparable)
        if ($bridge.LikelyStaleBridge -and $belongsToWorkspace -and -not $bridge.ConnectedToWorkspaceEditor) {
            $staleBridgePids += $bridge.OwningProcess
        }
    }

    foreach ($processId in @($staleBridgePids | Sort-Object -Unique)) {
        if ($DryRun) {
            Write-Host ("[DryRun] Would stop stale stdio bridge PID={0}" -f $processId)
        } else {
            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        }
    }
} else {
    foreach ($bridge in $snapshot.BridgeProcesses) {
        Write-Host ("Bridge reported only PID={0} Ports={1} Stale={2} Reason={3}" -f $bridge.ProcessId, $bridge.ListeningPorts, $bridge.LikelyStaleBridge, $bridge.StaleReason)
    }
}

if (-not $DryRun) {
    Start-Sleep -Seconds 2
}

$after = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace
Write-GodotMcpSection -Title "Bridge Listeners (stdio 6505-6509,6515-6534)" -Rows @($after.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "CLI Listeners (reserved 6510-6514)" -Rows @($after.CliListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Current Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
Write-GodotMcpSection -Title "Other Godot Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { -not $_.MatchesWorkspace } | Sort-Object StartTime)
