param(
    [string]$WorkspacePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace
$recommendation = Get-GodotMcpRecommendedAction -WorkspacePath $workspace

Write-Host "Workspace: $workspace"
Write-Host ("RecommendedAction: {0}" -f $recommendation.RecommendedAction)
Write-Host ("Reason: {0}" -f $recommendation.Reason)
Write-GodotMcpSection -Title "Bridge Processes" -Rows @($snapshot.BridgeProcesses | Sort-Object StartTime)
Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Godot Editors" -Rows (Get-GodotEditorProcessInfos -WorkspacePath $workspace | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @($snapshot.EditorConnections | Sort-Object OwningProcess,RemotePort)
