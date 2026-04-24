param(
    [string]$WorkspacePath,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)
$workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace })

Write-Host "Workspace: $workspace"
Write-Host "Force mode: this script stops all godot-mcp bridge processes. Prefer safe-repair-godot-mcp.ps1 unless the current session is already bad."

if ($DryRun) {
    Write-Host "[DryRun] Would stop all godot-mcp bridge processes and all Godot editors bound to this workspace."
}

foreach ($editor in $workspaceEditors) {
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop Godot editor PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
    } else {
        Stop-Process -Id $editor.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

foreach ($bridge in $bridgeProcesses) {
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop bridge PID={0}" -f $bridge.ProcessId)
    } else {
        Stop-Process -Id $bridge.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

if (-not $DryRun) {
    Start-Sleep -Seconds 2
}

Write-GodotMcpSection -Title "Remaining Bridge Listeners (6505-6509)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Remaining Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
