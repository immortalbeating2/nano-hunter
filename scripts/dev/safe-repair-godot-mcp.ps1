param(
    [string]$WorkspacePath,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

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
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop current workspace Godot editor PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
    } else {
        Stop-Process -Id $editor.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

if ($otherEditors.Count -gt 0) {
    foreach ($editor in $otherEditors) {
        if ($DryRun) {
            Write-Host ("[DryRun] Would leave non-workspace Godot editor running PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
        } else {
            Write-Host ("Leaving non-workspace Godot editor running PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
        }
    }
}

if ($ForceKillBridge) {
    foreach ($bridge in $bridgeProcesses) {
        if ($DryRun) {
            Write-Host ("[DryRun] Would stop bridge PID={0}" -f $bridge.ProcessId)
        } else {
            Stop-Process -Id $bridge.ProcessId -Force -ErrorAction SilentlyContinue
        }
    }
} else {
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
