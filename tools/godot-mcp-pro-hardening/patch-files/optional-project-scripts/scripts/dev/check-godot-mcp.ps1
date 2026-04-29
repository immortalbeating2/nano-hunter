param(
    [string]$WorkspacePath
)

# Godot MCP 只读诊断脚本。
# 适用场景：
# - 日常想确认当前 worktree 是否存在可用 bridge、Godot editor 是否连上 bridge。
# - 排查 6505-6509 / 6515-6534 stdio bridge 与 6510-6514 godot-cli reserved 端口是否混用。
# - 查看 lock/heartbeat、PID、TCP 连接、workspace 归属和 stale reason。
# 是否会修改：
# - 本脚本只读，不杀进程、不启动 Godot、不清理 bridge、不修改 project.godot。
# 常用命令：
# - .\scripts\dev\check-godot-mcp.ps1
# - .\scripts\dev\check-godot-mcp.ps1 -WorkspacePath C:\Path\To\Project
# 安全边界：
# - 输出的 stale reason 是诊断证据，不是自动清理命令。
# - 真正清理应通过 enter-worktree-godot-mcp.ps1 或 safe-repair-godot-mcp.ps1，并显式确认当前没有其它 MCP 会话需要这些 bridge。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-GodotMcpWorkspacePath -WorkspacePath $WorkspacePath
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
