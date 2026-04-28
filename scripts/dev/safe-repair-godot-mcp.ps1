param(
    [string]$WorkspacePath,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# 安全修复工具默认只关闭当前工作树的 Godot 编辑器，并保留 bridge。
# 只有显式 -ForceKillBridge 时才会清 bridge，这是为了保护其他活跃项目会话。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace })
$otherEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { -not $_.MatchesWorkspace })
$bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)

Write-Host "Workspace: $workspace"
Write-Host "Safe mode: bridge processes are reported only unless -ForceKillBridge is provided."

foreach ($editor in $workspaceEditors) {
    # 只处理命令行指向当前 workspace 的编辑器，固定工作树收口时不误关其他 Godot。
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop current workspace Godot editor PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
    } else {
        Stop-Process -Id $editor.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

if ($otherEditors.Count -gt 0) {
    # 其他 Godot 实例只列出不关闭，供人工判断是否属于其他项目或主工作区。
    foreach ($editor in $otherEditors) {
        if ($DryRun) {
            Write-Host ("[DryRun] Would leave non-workspace Godot editor running PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
        } else {
            Write-Host ("Leaving non-workspace Godot editor running PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
        }
    }
}

if ($ForceKillBridge) {
    # bridge 是全局资源，只有调用者明确承担影响范围时才清理。
    foreach ($bridge in $bridgeProcesses) {
        if ($DryRun) {
            Write-Host ("[DryRun] Would stop bridge PID={0}" -f $bridge.ProcessId)
        } else {
            Stop-Process -Id $bridge.ProcessId -Force -ErrorAction SilentlyContinue
        }
    }
} else {
    # 默认把 bridge 留在原地，避免把“重开当前工作树编辑器”变成“断开当前 Codex 工具”。
    foreach ($bridge in $bridgeProcesses) {
        Write-Host ("Bridge still running PID={0} Start={1}" -f $bridge.ProcessId, $bridge.StartTime)
    }
}

if (-not $DryRun) {
    Start-Sleep -Seconds 2
}

Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Current Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
Write-GodotMcpSection -Title "Other Godot Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { -not $_.MatchesWorkspace } | Sort-Object StartTime)
