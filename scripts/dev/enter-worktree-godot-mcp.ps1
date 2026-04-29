param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$ResetBeforeReopen,
    [switch]$ConfirmNoOtherGodotMcpSessions,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# 当前固定工作树进入 Godot MCP 人工复核的统一入口。
# 它根据诊断状态选择“直接继续 / 打开编辑器 / 安全重开编辑器 / 提醒实测 MCP / 提醒重开 Codex”。
# 默认不全局清 bridge，避免误伤其他活跃 Godot MCP 项目会话。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = $PSScriptRoot

if ($WorkspacePath) {
    $workspace = (Resolve-Path -LiteralPath $WorkspacePath).Path
} else {
    $workspace = (Resolve-Path -LiteralPath (Join-Path $scriptRoot "..\..")).Path
}

$bridgeListeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in @(6505, 6506, 6507, 6508, 6509) }

$bridgeConnections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
    Where-Object { $_.RemotePort -in @(6505, 6506, 6507, 6508, 6509, 6510, 6511, 6512, 6513, 6514) }

# 先打印关键状态，让用户能在执行修复前看到本次判断依据。
Write-Host "Workspace: $workspace"
Write-Host ("Bridge listeners (6505-6509): {0}" -f @($bridgeListeners).Count)
Write-Host ("Editor-to-bridge established connections: {0}" -f @($bridgeConnections).Count)

if ($ForceKillBridge) {
    Write-Host ""
    Write-Host "Note: -ForceKillBridge is kept for compatibility. Prefer -ResetBeforeReopen for stale-only bridge cleanup before restarting Codex."
}

Write-Host ""
Write-Host "Preflight completed. No automatic editor or bridge action was performed by this lightweight entry script."
Write-Host "Next step: verify MCP tools from the current Codex session. If tools fail, use check-godot-mcp.ps1 for detailed diagnostics."
