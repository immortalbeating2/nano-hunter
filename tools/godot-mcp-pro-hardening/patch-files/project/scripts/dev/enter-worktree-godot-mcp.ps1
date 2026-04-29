param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$ResetBeforeReopen,
    [switch]$ConfirmNoOtherGodotMcpSessions,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

# 当前固定工作树进入 Godot MCP 人工复核的统一入口。
# 它会读取 stdio bridge、CLI reserved 端口、lock/heartbeat 和 Godot 编辑器归属后选择动作：
# - 已连通：不动现场
# - 有 bridge 没编辑器：打开当前工作树 Godot
# - 有编辑器没连 bridge：只重开当前工作树 Godot
# - 只有 stale bridge：默认提示重开 Codex；只有用户显式确认后才清理 stale bridge
# 默认不会清理 6510-6514 godot-cli 进程，也不会误关其它 workspace 的 Godot 编辑器。
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
Write-GodotMcpSection -Title "Bridge Listeners (stdio 6505-6509,6515-6534)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "CLI Listeners (reserved 6510-6514)" -Rows @($snapshot.CliListeners | Sort-Object LocalPort)
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
