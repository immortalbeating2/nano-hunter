param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$godotExecutable = Resolve-GodotExecutablePath -GodotExe $GodotExe
$bridgeListeners = @(Get-GodotMcpBridgeListeners)

Write-Host "Workspace: $workspace"
Write-Host "Godot: $godotExecutable"

if (-not $bridgeListeners) {
    throw "No godot-mcp bridge listeners were detected on 6505-6509. Reopen the current Codex session first."
}

if ($DryRun) {
    Write-Host ('[DryRun] Would start: "{0}" -e --path "{1}"' -f $godotExecutable, $workspace)
} else {
    Start-Process -FilePath $godotExecutable -ArgumentList "-e", "--path", $workspace | Out-Null
    Start-Sleep -Seconds 6
}

Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @(Get-GodotEstablishedBridgeConnections -WorkspacePath $workspace | Sort-Object OwningProcess,RemotePort)
