param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$DryRun
)

# 打开指定工作树的 Godot 编辑器。
# 本脚本只负责启动当前 workspace 的 Godot，不清理 bridge；它会确认至少存在一个 stdio bridge
# 监听端口。6510-6514 是 godot-cli reserved，不可作为“当前 Codex MCP bridge 已就绪”的证据。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$godotExecutable = Resolve-GodotExecutablePath -GodotExe $GodotExe
$bridgeListeners = @(Get-GodotMcpBridgeListeners)

Write-Host "Workspace: $workspace"
Write-Host "Godot: $godotExecutable"

if (-not $bridgeListeners) {
    throw "No stdio godot-mcp bridge listeners were detected on 6505-6509 or 6515-6534. Reopen the current Codex session first."
}

if ($DryRun) {
    Write-Host ('[DryRun] Would start: "{0}" -e --path "{1}"' -f $godotExecutable, $workspace)
} else {
    Start-Process -FilePath $godotExecutable -ArgumentList "-e", "--path", $workspace | Out-Null
    Start-Sleep -Seconds 6
}

Write-GodotMcpSection -Title "Bridge Listeners (stdio 6505-6509,6515-6534)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "CLI Listeners (reserved 6510-6514)" -Rows @(Get-GodotMcpCliListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @(Get-GodotEstablishedBridgeConnections -WorkspacePath $workspace | Sort-Object OwningProcess,RemotePort)
