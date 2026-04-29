param(
    [string]$WorkspacePath
)

# 输出当前工作树的 Godot MCP 诊断快照，只读不修复。
# 本脚本会区分 stdio bridge、godot-cli 临时端口、bridge lock/heartbeat 和 Godot 编辑器连接。
# 它不会杀进程；当输出 stale reason 时，也只是为 safe-repair 或人工判断提供证据。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace
$recommendation = Get-GodotMcpRecommendedAction -WorkspacePath $workspace

Write-Host "Workspace: $workspace"
Write-Host ("RecommendedAction: {0}" -f $recommendation.RecommendedAction)
Write-Host ("Reason: {0}" -f $recommendation.Reason)
Write-GodotMcpSection -Title "Port Plan" -Rows @(Get-GodotMcpPortPlan)
Write-GodotMcpSection -Title "Bridge Processes" -Rows @($snapshot.BridgeProcesses | Sort-Object StartTime)
Write-GodotMcpSection -Title "CLI Processes" -Rows @($snapshot.CliProcesses | Sort-Object StartTime)
Write-GodotMcpSection -Title "Bridge Listeners (stdio 6505-6509,6515-6534)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "CLI Listeners (reserved 6510-6514)" -Rows @($snapshot.CliListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Bridge Locks" -Rows @($snapshot.BridgeLocks | Sort-Object Port)
Write-GodotMcpSection -Title "Godot Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @($snapshot.EditorConnections | Sort-Object OwningProcess,RemotePort)
