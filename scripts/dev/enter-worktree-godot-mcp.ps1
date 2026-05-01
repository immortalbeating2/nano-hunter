param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$ResetBeforeReopen,
    [switch]$ConfirmNoOtherGodotMcpSessions,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# Godot MCP 日常入口脚本。
# 适用场景：
# - 当前 worktree 要进入 Godot MCP 人工复核前，先判断 bridge / editor / lock 状态。
# - 希望用一个入口完成“只读诊断、打开 Godot、重开当前 worktree Godot、确认后清 stale bridge”的分流。
# 是否会修改：
# - 默认只读或打开当前 worktree 的 Godot。
# - 只有传入 -ResetBeforeReopen 且同时传入 -ConfirmNoOtherGodotMcpSessions 时，才会调用 safe-repair 清理 stale stdio bridge。
# - 永远不把 17620-17624 或 legacy 6510-6514 godot-cli 端口当作 stale bridge 清理对象。
# 常用命令：
# - 预览：.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
# - 确认无其它会话后清理 stale：.\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions
# 安全边界：
# - MCP 工具入口缺失时，本脚本无法让当前 Codex 会话凭空加载工具；仍需从目标 worktree 重开 Codex。
# - runtime autoload 注入失败不是 bridge 生命周期问题，应按 connectivity guide 分层排查。
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
Write-GodotMcpSection -Title "Project Rendezvous" -Rows @($snapshot.ProjectRendezvous)
Write-GodotMcpSection -Title "Bridge Listeners (stdio 17605-17619; legacy 6505-6509)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "CLI Listeners (cli 17620-17624; legacy 6510-6514)" -Rows @($snapshot.CliListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Bridge Locks" -Rows @($snapshot.BridgeLocks | Sort-Object Port)

if ($ForceKillBridge) {
    Write-Host ""
    Write-Host "Note: -ForceKillBridge is kept for compatibility and only targets stale stdio bridge listeners for this workspace."
}

switch ($recommendation.RecommendedAction) {
    "AlreadyConnected" {
        Write-Host "MCP bridge appears connected for this workspace. Verify with a read-only MCP tool before runtime review."
    }
    "SafeOpenEditor" {
        & (Join-Path $PSScriptRoot "open-worktree-godot.ps1") -WorkspacePath $workspace -GodotExe $GodotExe -DryRun:$DryRun
    }
    "SafeReopenEditor" {
        & (Join-Path $PSScriptRoot "safe-repair-godot-mcp.ps1") -WorkspacePath $workspace -DryRun:$DryRun
        & (Join-Path $PSScriptRoot "open-worktree-godot.ps1") -WorkspacePath $workspace -GodotExe $GodotExe -DryRun:$DryRun
    }
    "ReopenSessionThenCleanStaleBridge" {
        if ($ResetBeforeReopen -and $ConfirmNoOtherGodotMcpSessions) {
            & (Join-Path $PSScriptRoot "safe-repair-godot-mcp.ps1") -WorkspacePath $workspace -ForceKillBridge -DryRun:$DryRun
            Write-Host "Stale bridge cleanup requested. Reopen Codex from this same workspace before using MCP tools."
        } else {
            Write-Host "Only stale stdio bridge listeners were found."
            Write-Host "If no other Godot MCP sessions need them, run:"
            Write-Host ".\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions"
            Write-Host "Then reopen Codex from this same workspace."
        }
    }
    default {
        Write-Host "State is ambiguous. Inspect the diagnostic tables above before forcing repairs."
    }
}
