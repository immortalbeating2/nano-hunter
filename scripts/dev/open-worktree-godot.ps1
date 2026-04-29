param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$DryRun
)

# 打开当前 worktree 的 Godot 编辑器辅助脚本。
# 适用场景：
# - 已确认当前 Codex 会话存在 stdio bridge listener，需要启动目标 worktree 的 Godot editor 去连接 bridge。
# - 通常由 enter-worktree-godot-mcp.ps1 调用，日常不需要直接运行。
# 是否会修改：
# - 会启动 Godot editor；不杀进程、不清理 bridge、不修改项目文件。
# 常用命令：
# - 预览：.\scripts\dev\open-worktree-godot.ps1 -DryRun
# - 指定 Godot：.\scripts\dev\open-worktree-godot.ps1 -GodotExe C:\Path\To\Godot.exe
# 安全边界：
# - 只有 6505-6509 / 6515-6534 stdio listener 才算 Codex MCP bridge 证据。
# - 6510-6514 是 godot-cli reserved，不代表当前 Codex MCP bridge 已可用。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-GodotMcpWorkspacePath -WorkspacePath $WorkspacePath
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
