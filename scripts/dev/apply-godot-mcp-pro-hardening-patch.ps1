param(
    [string]$ServerPath,
    [string]$ProjectPath,
    [string]$PatchRoot,
    [string]$BackupRoot,
    [ValidateSet("ServerOnly", "PluginOnly", "ServerAndPlugin", "All")]
    [string]$Scope = "ServerAndPlugin",
    [switch]$IncludeProjectScripts,
    [switch]$DryRun,
    [switch]$Build,
    [switch]$Force
)

# Godot MCP Pro 通用 hardening 补丁重放脚本。
# 适用场景：
# - Godot MCP Pro 插件或用户目录中的 Node MCP Server 升级后，需要重新应用 bridge 生命周期补丁。
# - 同一台机器上多个 Godot 项目（例如 nano-hunter、angel-fallen）需要复用同一套端口规划和 workspace handshake。
# 是否会修改：
# - 默认 Scope=ServerAndPlugin，会修改全局 Node server 与目标项目 addons/godot_mcp。
# - 默认不会覆盖目标项目 scripts/dev；只有显式传入 -IncludeProjectScripts 才会写入项目诊断脚本。
# - -DryRun 只输出计划，不写目标文件、不构建、不创建备份目录。
# 常用命令：
# - 当前项目预览：.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
# - 仅补其它项目插件：.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -ProjectPath C:\Path\To\Project -Scope PluginOnly -DryRun
# - 独立目录脚本：C:\Tools\godot-mcp-pro-hardening\apply-godot-mcp-pro-hardening-patch.ps1 -ProjectPath C:\Path\To\Project -PatchRoot C:\Tools\godot-mcp-pro-hardening\patch-files -DryRun
# 安全边界：
# - 已验证上游版本为 1.12.0；其它版本默认拒绝真实写入，需人工审查后加 -Force。
# - 6510-6514 永远保留给 godot-cli，不会作为 stdio bridge 端口。
# - 应用前会把已有目标文件备份到 tests/artifacts/local/godot-mcp-patch-backups/<timestamp>/，或 -BackupRoot 指定目录。

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-IncludesServerPatch {
    # 判断当前 scope 是否包含全局 Node MCP Server 补丁。
    # 输入：Scope 参数值。
    # 输出：布尔值；不会访问文件系统。
    param([string]$SelectedScope)
    return $SelectedScope -in @("ServerOnly", "ServerAndPlugin", "All")
}

function Test-IncludesPluginPatch {
    # 判断当前 scope 是否包含目标项目 addons/godot_mcp 补丁。
    # 输入：Scope 参数值。
    # 输出：布尔值；不会访问文件系统。
    param([string]$SelectedScope)
    return $SelectedScope -in @("PluginOnly", "ServerAndPlugin", "All")
}

function Resolve-ProjectRoot {
    # 解析目标 Godot 项目根目录。
    # 输入：可选 -ProjectPath。
    # 输出：绝对路径。
    # 失败条件：显式路径不存在，或脚本被搬离项目后未传 -ProjectPath。
    param([string]$Path)

    if ($Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }

    $candidate = Join-Path $PSScriptRoot "..\.."
    $resolved = (Resolve-Path -LiteralPath $candidate).Path
    if (Test-Path -LiteralPath (Join-Path $resolved "project.godot")) {
        return $resolved
    }

    throw "无法从脚本位置推断 Godot 项目根目录。脚本搬离项目后请显式传入 -ProjectPath。"
}

function Resolve-ServerRoot {
    # 解析用户目录中的 Godot MCP Pro Node server。
    # 输入：可选 -ServerPath。
    # 输出：绝对路径。
    # 失败条件：目标目录不存在；PluginOnly scope 不会调用本函数。
    param([string]$Path)

    if ($Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return (Resolve-Path -LiteralPath (Join-Path $env:USERPROFILE ".mcp\godot-mcp-pro\server")).Path
}

function Resolve-PatchRoot {
    # 解析补丁源目录，优先使用显式 -PatchRoot；否则按可搬移优先策略自动查找。
    # 输入：可选 -PatchRoot 与已解析的 ProjectRoot。
    # 输出：包含 server/plugin/optional-project-scripts 的 patch-files 绝对路径。
    # 失败条件：所有候选目录都不存在，此时提示用户显式传入 -PatchRoot。
    param(
        [string]$ExplicitPatchRoot,
        [string]$ProjectRoot
    )

    if ($ExplicitPatchRoot) {
        return (Resolve-Path -LiteralPath $ExplicitPatchRoot).Path
    }

    $candidates = @(
        (Join-Path $PSScriptRoot "..\tools\godot-mcp-pro-hardening\patch-files"),
        (Join-Path $PSScriptRoot "..\..\tools\godot-mcp-pro-hardening\patch-files"),
        (Join-Path $PSScriptRoot "tools\godot-mcp-pro-hardening\patch-files"),
        (Join-Path $PSScriptRoot "patch-files"),
        (Join-Path $ProjectRoot "tools\godot-mcp-pro-hardening\patch-files"),
        (Join-Path (Get-Location).Path "tools\godot-mcp-pro-hardening\patch-files")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "找不到 patch-files。请传入 -PatchRoot，例如：-PatchRoot C:\Tools\godot-mcp-pro-hardening\patch-files。"
}

function Get-PackageVersion {
    # 读取 Node server package.json 版本，用来防止在未审查的新上游版本上静默覆盖。
    # 输入：Node server 根目录。
    # 输出：package.json 中的 version 字符串。
    # 失败条件：package.json 缺失或 JSON 无法解析。
    param([string]$Root)

    $packagePath = Join-Path $Root "package.json"
    if (-not (Test-Path -LiteralPath $packagePath)) {
        throw "Cannot find package.json at $packagePath"
    }
    $package = Get-Content -Encoding UTF8 -LiteralPath $packagePath -Raw | ConvertFrom-Json
    return [string]$package.version
}

function New-PatchBackupRoot {
    # 计算本次备份目录。真实应用时创建目录；dry-run 只返回将使用的路径。
    # 输入：项目根目录、可选 -BackupRoot、DryRun。
    # 输出：备份目录绝对路径。
    # 副作用：非 dry-run 时创建目录。
    param(
        [string]$ProjectRoot,
        [string]$ExplicitBackupRoot,
        [switch]$DryRun
    )

    if ($ExplicitBackupRoot) {
        $root = $ExplicitBackupRoot
    } else {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $root = Join-Path $ProjectRoot "tests\artifacts\local\godot-mcp-patch-backups\$stamp"
    }

    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $root | Out-Null
    }
    return $root
}

function New-PatchCopyItem {
    # 创建一个补丁复制条目，统一保存分组、源相对路径和目标绝对路径。
    # 输入：Group、Source、Target。
    # 输出：pscustomobject；不会访问文件系统。
    param(
        [string]$Group,
        [string]$Source,
        [string]$Target
    )

    [pscustomobject]@{
        Group  = $Group
        Source = $Source
        Target = $Target
    }
}

function Get-PatchCopyPlan {
    # 根据 scope 生成本次要应用的补丁文件列表。
    # 输入：scope、是否包含项目脚本、server/project 根目录。
    # 输出：复制条目数组。
    # 关键规则：All 不自动覆盖 scripts/dev；项目脚本必须由 -IncludeProjectScripts 显式开启。
    param(
        [string]$SelectedScope,
        [bool]$WithProjectScripts,
        [string]$ServerRoot,
        [string]$ProjectRoot
    )

    $items = @()

    if (Test-IncludesServerPatch -SelectedScope $SelectedScope) {
        $items += New-PatchCopyItem -Group "server" -Source "server\src\godot-connection.ts" -Target (Join-Path $ServerRoot "src\godot-connection.ts")
        $items += New-PatchCopyItem -Group "server" -Source "server\src\utils\bridge-lock.ts" -Target (Join-Path $ServerRoot "src\utils\bridge-lock.ts")
        $items += New-PatchCopyItem -Group "server" -Source "server\src\tools\diagnostic-tools.ts" -Target (Join-Path $ServerRoot "src\tools\diagnostic-tools.ts")
        $items += New-PatchCopyItem -Group "server" -Source "server\src\index.ts" -Target (Join-Path $ServerRoot "src\index.ts")
        $items += New-PatchCopyItem -Group "server" -Source "server\tests\godot-connection.test.ts" -Target (Join-Path $ServerRoot "tests\godot-connection.test.ts")
        $items += New-PatchCopyItem -Group "server" -Source "server\tests\bridge-lock.test.ts" -Target (Join-Path $ServerRoot "tests\bridge-lock.test.ts")
    }

    if (Test-IncludesPluginPatch -SelectedScope $SelectedScope) {
        $items += New-PatchCopyItem -Group "plugin" -Source "plugin\addons\godot_mcp\websocket_server.gd" -Target (Join-Path $ProjectRoot "addons\godot_mcp\websocket_server.gd")
        $items += New-PatchCopyItem -Group "plugin" -Source "plugin\addons\godot_mcp\ui\status_panel.gd" -Target (Join-Path $ProjectRoot "addons\godot_mcp\ui\status_panel.gd")
        $items += New-PatchCopyItem -Group "plugin" -Source "plugin\addons\godot_mcp\plugin.gd" -Target (Join-Path $ProjectRoot "addons\godot_mcp\plugin.gd")
    }

    if ($WithProjectScripts) {
        $items += New-PatchCopyItem -Group "optional-project-scripts" -Source "optional-project-scripts\scripts\dev\godot-mcp-common.ps1" -Target (Join-Path $ProjectRoot "scripts\dev\godot-mcp-common.ps1")
        $items += New-PatchCopyItem -Group "optional-project-scripts" -Source "optional-project-scripts\scripts\dev\check-godot-mcp.ps1" -Target (Join-Path $ProjectRoot "scripts\dev\check-godot-mcp.ps1")
        $items += New-PatchCopyItem -Group "optional-project-scripts" -Source "optional-project-scripts\scripts\dev\enter-worktree-godot-mcp.ps1" -Target (Join-Path $ProjectRoot "scripts\dev\enter-worktree-godot-mcp.ps1")
        $items += New-PatchCopyItem -Group "optional-project-scripts" -Source "optional-project-scripts\scripts\dev\safe-repair-godot-mcp.ps1" -Target (Join-Path $ProjectRoot "scripts\dev\safe-repair-godot-mcp.ps1")
        $items += New-PatchCopyItem -Group "optional-project-scripts" -Source "optional-project-scripts\scripts\dev\open-worktree-godot.ps1" -Target (Join-Path $ProjectRoot "scripts\dev\open-worktree-godot.ps1")
    }

    return @($items)
}

function Copy-WithBackup {
    # 将单个补丁源复制到目标，并在真实写入前备份已有目标文件。
    # 输入：源文件、目标文件、备份根目录、DryRun。
    # 输出：无。
    # 副作用：非 dry-run 时可能创建目标目录、复制备份、覆盖目标文件。
    param(
        [string]$Source,
        [string]$Target,
        [string]$BackupRoot,
        [switch]$DryRun
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Patch source missing: $Source"
    }

    $backupPath = Join-Path $BackupRoot ($Target -replace "[:\\\/]", "_")
    if ($DryRun) {
        Write-Host ("[DryRun] Would backup: {0} -> {1}" -f $Target, $backupPath)
        Write-Host ("[DryRun] Would copy:   {0} -> {1}" -f $Source, $Target)
        return
    }

    if (Test-Path -LiteralPath $Target) {
        Copy-Item -LiteralPath $Target -Destination $backupPath -Force
    }
    $targetDir = Split-Path -Parent $Target
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Target -Force
}

$projectRoot = Resolve-ProjectRoot -Path $ProjectPath
$includesServer = Test-IncludesServerPatch -SelectedScope $Scope
$serverRoot = if ($includesServer) { Resolve-ServerRoot -Path $ServerPath } else { "" }
$resolvedPatchRoot = Resolve-PatchRoot -ExplicitPatchRoot $PatchRoot -ProjectRoot $projectRoot
$version = if ($includesServer) { Get-PackageVersion -Root $serverRoot } else { "(server skipped)" }
$backupRootPath = New-PatchBackupRoot -ProjectRoot $projectRoot -ExplicitBackupRoot $BackupRoot -DryRun:$DryRun
$copyPlan = Get-PatchCopyPlan -SelectedScope $Scope -WithProjectScripts:$IncludeProjectScripts -ServerRoot $serverRoot -ProjectRoot $projectRoot

Write-Host "Godot MCP Pro hardening patch"
Write-Host "Scope:   $Scope"
Write-Host "Project: $projectRoot"
Write-Host "Server:  $serverRoot"
Write-Host "Patch:   $resolvedPatchRoot"
Write-Host "Version: $version"
Write-Host "Stdio bridge ports: 6505-6509,6515-6534"
Write-Host "CLI reserved ports: 6510-6514"
Write-Host "Plugin scan ports:  6505-6534"
Write-Host "Backup root: $backupRootPath"
Write-Host ("Included groups: {0}" -f ((@($copyPlan | Select-Object -ExpandProperty Group -Unique)) -join ", "))

$skippedGroups = @()
if (-not $includesServer) { $skippedGroups += "server" }
if (-not (Test-IncludesPluginPatch -SelectedScope $Scope)) { $skippedGroups += "plugin" }
if (-not $IncludeProjectScripts) { $skippedGroups += "optional-project-scripts" }
Write-Host ("Skipped groups: {0}" -f ($(if ($skippedGroups.Count -gt 0) { $skippedGroups -join ", " } else { "(none)" })))

if ($includesServer -and $version -ne "1.12.0" -and -not $Force) {
    Write-Host "Version is not verified for automatic apply. Re-run with -DryRun for inspection or -Force after review."
    if (-not $DryRun) {
        throw "Refusing to patch unverified Godot MCP Pro version $version without -Force."
    }
}

foreach ($copy in $copyPlan) {
    $source = Join-Path $resolvedPatchRoot $copy.Source
    Copy-WithBackup -Source $source -Target $copy.Target -BackupRoot $backupRootPath -DryRun:$DryRun
}

if ($Build) {
    if (-not $includesServer) {
        Write-Host "[Skip] -Build requested, but Scope=$Scope does not include the Node server."
    } elseif ($DryRun) {
        Write-Host "[DryRun] Would run npm run build in $serverRoot"
    } else {
        Push-Location $serverRoot
        try {
            npm run build
        } finally {
            Pop-Location
        }
    }
}
