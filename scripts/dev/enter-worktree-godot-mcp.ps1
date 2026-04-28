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
. (Join-Path $scriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$godotArgument = @()
$workspaceArgument = @()

if ($WorkspacePath) {
    $workspaceArgument = @("-WorkspacePath", $WorkspacePath)
}

if ($GodotExe) {
    $godotArgument = @("-GodotExe", $GodotExe)
}

$recommendation = Get-GodotMcpRecommendedAction -WorkspacePath $workspace
$snapshot = Get-GodotMcpBridgeDiagnosticSnapshot -WorkspacePath $workspace

# 先打印关键状态，让用户能在执行修复前看到本次判断依据。
Write-Host "Workspace: $workspace"
Write-Host ("RecommendedAction: {0}" -f $recommendation.RecommendedAction)
Write-Host ("Reason: {0}" -f $recommendation.Reason)
Write-GodotMcpSection -Title "Bridge Listeners (6505-6509)" -Rows @($snapshot.BridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Workspace Editor -> Bridge Connections" -Rows @($snapshot.EditorConnections | Sort-Object OwningProcess, RemotePort)

$action = $recommendation.RecommendedAction
$shouldResetBeforeReopen = $ResetBeforeReopen -or $ForceKillBridge

if ($ForceKillBridge) {
    Write-Host ""
    Write-Host "Note: -ForceKillBridge is kept for compatibility. Prefer -ResetBeforeReopen for stale-only bridge cleanup before restarting Codex."
}

switch ($action) {
    "AlreadyConnected" {
        # 已连通时不做任何清理或重启，这是固定工作树日常复核的理想状态。
        Write-Host ""
        Write-Host "Godot MCP is already connected for this workspace. Continue with MCP review."
        break
    }

    "ConnectedBridgeAgeUnknown" {
        # 当前工作树编辑器已经连到 bridge，但 bridge 年龄不像当前会话。
        # 这种状态可能是“旧但仍可通信”，不能直接清理；下一步应调用 MCP 工具实测。
        if ($shouldResetBeforeReopen) {
            Write-Host ""
            Write-Host "Workspace editor is already connected to a bridge. Ignoring bridge reset request until MCP tool calls fail."
        }

        Write-Host ""
        Write-Host "Workspace editor is connected to an existing Godot MCP bridge, but the bridge age is unknown."
        Write-Host "Do not clean bridges yet. First verify MCP tools in the current Codex session."
        Write-Host "If MCP tools can call get_scene_tree or another read-only tool, continue review."
        Write-Host "If MCP tools return Transport closed or are missing, reopen Codex from this fixed workspace."
        break
    }

    "SafeOpenEditor" {
        # 当前会话 bridge 已可用，只缺指向本工作树的 Godot 编辑器连接。
        if ($shouldResetBeforeReopen) {
            Write-Host ""
            Write-Host "Current-session bridge exists. Ignoring bridge reset request to avoid breaking this Codex session."
        }

        Write-Host ""
        Write-Host "Opening the current workspace Godot editor..."
        & (Join-Path $scriptRoot "open-worktree-godot.ps1") @workspaceArgument @godotArgument -DryRun:$DryRun
        break
    }

    "SafeReopenEditor" {
        # 工作树编辑器可能是旧进程或断连进程，先关当前工作树编辑器，再打开同一工作树。
        if ($shouldResetBeforeReopen) {
            Write-Host ""
            Write-Host "Current-session bridge exists. Ignoring bridge reset request to avoid breaking this Codex session."
        }

        Write-Host ""
        Write-Host "Reopening the current workspace Godot editor without touching bridge processes..."
        & (Join-Path $scriptRoot "safe-repair-godot-mcp.ps1") @workspaceArgument -DryRun:$DryRun
        & (Join-Path $scriptRoot "open-worktree-godot.ps1") @workspaceArgument @godotArgument -DryRun:$DryRun
        break
    }

    "ReopenSessionThenForceKillBridge" {
        # stale-only 状态通常表示当前 Codex 会话没有自己的 bridge；清理前必须确认没有其他项目会话。
        Write-Host ""
        if ($shouldResetBeforeReopen) {
            if (-not $ConfirmNoOtherGodotMcpSessions) {
                Write-Host "Stale-only bridge state detected, but bridge reset is global for godot-mcp-pro."
                Write-Host "It can interrupt other active Godot MCP project sessions on this machine."
                Write-Host "If you have confirmed there are no other active Godot MCP sessions, run:"
                Write-Host "  .\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions"
                Write-Host "Then reopen Codex from this same fixed workspace and run this script once more."
                break
            }

            Write-Host "Stale-only bridge state detected. Cleaning stale bridge listeners before Codex restart..."
            & (Join-Path $scriptRoot "safe-repair-godot-mcp.ps1") @workspaceArgument -ForceKillBridge -DryRun:$DryRun
            Write-Host ""
            Write-Host "Next step: reopen Codex from this same fixed workspace, then run enter-worktree-godot-mcp.ps1 again."
        } else {
            Write-Host "Stale-only bridge state detected. If you are about to reopen Codex, run:"
            Write-Host "  .\scripts\dev\enter-worktree-godot-mcp.ps1 -ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions"
            Write-Host "Then reopen Codex from this fixed workspace and run this script once more."
        }
        break
    }

    default {
        # 模糊状态不自动修复，避免脚本在归属不明时关闭他人的 Godot / bridge。
        Write-Host ""
        Write-Host "State is ambiguous. No automatic repair was performed."
        Write-Host "Use check-godot-mcp.ps1 for full diagnostics, or close unrelated Godot/Codex sessions before retrying."
        break
    }
}
