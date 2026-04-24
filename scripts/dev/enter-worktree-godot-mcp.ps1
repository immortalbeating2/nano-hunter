param(
    [string]$WorkspacePath,
    [string]$GodotExe,
    [switch]$ForceKillBridge,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = $PSScriptRoot
$workspaceArgument = @()
$godotArgument = @()

if ($WorkspacePath) {
    $workspaceArgument = @("-WorkspacePath", $WorkspacePath)
}

if ($GodotExe) {
    $godotArgument = @("-GodotExe", $GodotExe)
}

Write-Host "== Step 1/3: Check current godot-mcp state =="
& (Join-Path $scriptRoot "check-godot-mcp.ps1") @workspaceArgument

Write-Host ""
Write-Host "== Step 2/3: Safe repair stale editor state =="
if ($DryRun) {
    & (Join-Path $scriptRoot "safe-repair-godot-mcp.ps1") @workspaceArgument -ForceKillBridge:$ForceKillBridge -DryRun
} else {
    & (Join-Path $scriptRoot "safe-repair-godot-mcp.ps1") @workspaceArgument -ForceKillBridge:$ForceKillBridge
}

if ($ForceKillBridge) {
    Write-Host ""
    Write-Host "Force bridge reset requested. You can also run force-repair-godot-mcp.ps1 directly in fully broken sessions."
}

Write-Host ""
Write-Host "== Step 3/3: Open current worktree editor and re-check =="
if ($DryRun) {
    & (Join-Path $scriptRoot "open-worktree-godot.ps1") @workspaceArgument @godotArgument -DryRun
} else {
    & (Join-Path $scriptRoot "open-worktree-godot.ps1") @workspaceArgument @godotArgument
}
