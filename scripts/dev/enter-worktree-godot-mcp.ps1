param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$ResetBeforeReopen,
    [switch]$ConfirmNoOtherGodotMcpSessions,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

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
        Write-Host ""
        Write-Host "Godot MCP is already connected for this workspace. Continue with MCP review."
        break
    }

    "SafeOpenEditor" {
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
        Write-Host ""
        Write-Host "State is ambiguous. No automatic repair was performed."
        Write-Host "Use check-godot-mcp.ps1 for full diagnostics, or close unrelated Godot/Codex sessions before retrying."
        break
    }
}
