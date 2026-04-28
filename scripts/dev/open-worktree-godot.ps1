param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$DryRun
)

# 打开指定工作树的 Godot 编辑器，并要求当前 Codex 会话已经有 bridge 监听。
# 该脚本只负责启动编辑器，不负责修复 bridge，避免把“打开项目”和“清理全局连接”混在一起。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$godotExecutable = Resolve-GodotExecutablePath -GodotExe $GodotExe
$bridgeListeners = @(Get-GodotMcpBridgeListeners)

Write-Host "Workspace: $workspace"
Write-Host "Godot: $godotExecutable"

if (-not $bridgeListeners) {
    # 没有 bridge 时直接打开 Godot 也无法让当前 Codex 工具连通，所以要求先重开会话建立 bridge。
    throw "No godot-mcp bridge listeners were detected on 6505-6509. Reopen the current Codex session first."
}

if ($DryRun) {
    Write-Host ('[DryRun] Would start: "{0}" -e --path "{1}"' -f $godotExecutable, $workspace)
} else {
    # 使用编辑器模式 -e 保持 MCP 插件和运行态复核所需的 editor-side 服务可用。
    Start-Process -FilePath $godotExecutable -ArgumentList "-e", "--path", $workspace | Out-Null
    Start-Sleep -Seconds 6
}

Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @(Get-GodotEstablishedBridgeConnections -WorkspacePath $workspace | Sort-Object OwningProcess,RemotePort)
