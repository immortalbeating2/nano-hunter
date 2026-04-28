param(
    [string]$WorkspacePath
)

# 输出当前工作树的 Godot MCP 诊断快照，只读不修复。
# 日常用它确认 bridge、Godot 编辑器和当前固定工作树之间是否已经正确连通。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace
$recommendation = Get-GodotMcpRecommendedAction -WorkspacePath $workspace

# 推荐动作来自公共判断函数；本脚本只把依据展开给开发者和代理阅读。
Write-Host "Workspace: $workspace"
Write-Host ("RecommendedAction: {0}" -f $recommendation.RecommendedAction)
Write-Host ("Reason: {0}" -f $recommendation.Reason)
Write-GodotMcpSection -Title "Bridge Processes" -Rows @($snapshot.BridgeProcesses | Sort-Object StartTime)
Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Godot Editors" -Rows (Get-GodotEditorProcessInfos -WorkspacePath $workspace | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @($snapshot.EditorConnections | Sort-Object OwningProcess,RemotePort)
