param(
    [string]$WorkspacePath,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# 安全修复工具。
# 默认只关闭当前工作树的 Godot 编辑器，并列出 bridge / CLI / lock 状态。
# 只有显式 -ForceKillBridge 时才会清理“当前 workspace 且 heartbeat stale / 无当前连接”的 stdio bridge。
# 6510-6514 是 godot-cli reserved 端口，永远不在本脚本默认清理范围内。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
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
