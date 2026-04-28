param(
    [string]$WorkspacePath,
    [switch]$DryRun
)

# 强制修复工具会关闭所有 godot-mcp-pro bridge，并关闭当前工作树的 Godot 编辑器。
# 这会影响同机其他 Codex / Godot MCP 会话，只应在当前会话已不可用且人工确认安全时使用。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "godot-mcp-common.ps1")

$workspace = Resolve-NanoHunterWorkspacePath -WorkspacePath $WorkspacePath
$bridgeProcesses = @(Get-GodotMcpBridgeProcessInfos)
$workspaceEditors = @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace })

Write-Host "Workspace: $workspace"
Write-Host "Force mode: this script stops all godot-mcp bridge processes. Prefer safe-repair-godot-mcp.ps1 unless the current session is already bad."

if ($DryRun) {
    Write-Host "[DryRun] Would stop all godot-mcp bridge processes and all Godot editors bound to this workspace."
}

foreach ($editor in $workspaceEditors) {
    # 编辑器只关闭当前 workspace 命中的实例，避免顺手杀掉主工作区或其他项目的 Godot。
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop Godot editor PID={0} Title={1}" -f $editor.ProcessId, $editor.MainWindowTitle)
    } else {
        Stop-Process -Id $editor.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

foreach ($bridge in $bridgeProcesses) {
    # bridge 本身无法可靠按项目归属区分，因此 force 模式必须被视作全局破坏性操作。
    if ($DryRun) {
        Write-Host ("[DryRun] Would stop bridge PID={0}" -f $bridge.ProcessId)
    } else {
        Stop-Process -Id $bridge.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

if (-not $DryRun) {
    Start-Sleep -Seconds 2
}

Write-GodotMcpSection -Title "Remaining Bridge Listeners (6505-6509)" -Rows @(Get-GodotMcpBridgeListeners | Sort-Object LocalPort)
Write-GodotMcpSection -Title "Remaining Workspace Editors" -Rows @(Get-GodotEditorProcessInfos -WorkspacePath $workspace | Where-Object { $_.MatchesWorkspace } | Sort-Object StartTime)
