param(
    [string]$ServerPath,
    [string]$ProjectPath,
    [switch]$DryRun,
    [switch]$Build,
    [switch]$Force
)

# Godot MCP Pro hardening patch replayer.
# Purpose:
# - The Node MCP server lives outside this repository, so manual edits there are
#   easy to lose after plugin upgrades.
# - This script replays the repository-owned hardened copies into both the
#   external Node server and the project-side Godot plugin/scripts.
# - It always prints the stdio/CLI/plugin port plan so port expansion remains
#   traceable during future upgrades.
# Safety:
# - Version 1.12.0 is the verified source version.
# - Unknown versions require -Force and should be reviewed manually first.
# - Every changed file is backed up under tests/artifacts/local before writing.
# - 6510-6514 are reserved for godot-cli and must not become stdio bridge ports.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ProjectRoot {
    param([string]$Path)
    if ($Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
}

function Resolve-ServerRoot {
    param([string]$Path)
    if ($Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return (Resolve-Path -LiteralPath (Join-Path $env:USERPROFILE ".mcp\godot-mcp-pro\server")).Path
}

function Get-PackageVersion {
    param([string]$Root)
    $packagePath = Join-Path $Root "package.json"
    if (-not (Test-Path -LiteralPath $packagePath)) {
        throw "Cannot find package.json at $packagePath"
    }
    $package = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
    return [string]$package.version
}

function New-PatchBackupRoot {
    param([string]$ProjectRoot)
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupRoot = Join-Path $ProjectRoot "tests\artifacts\local\godot-mcp-patch-backups\$stamp"
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    return $backupRoot
}

function Copy-WithBackup {
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
$serverRoot = Resolve-ServerRoot -Path $ServerPath
$patchRoot = Join-Path $projectRoot "tools\godot-mcp-pro-hardening\patch-files"
$version = Get-PackageVersion -Root $serverRoot

Write-Host "Godot MCP Pro hardening patch"
Write-Host "Project: $projectRoot"
Write-Host "Server:  $serverRoot"
Write-Host "Version: $version"
Write-Host "Stdio bridge ports: 6505-6509,6515-6534"
Write-Host "CLI reserved ports: 6510-6514"
Write-Host "Plugin scan ports:  6505-6534"

if ($version -ne "1.12.0" -and -not $Force) {
    Write-Host "Version is not verified for automatic apply. Re-run with -DryRun for inspection or -Force after review."
    if (-not $DryRun) {
        throw "Refusing to patch unverified Godot MCP Pro version $version without -Force."
    }
}

$backupRoot = New-PatchBackupRoot -ProjectRoot $projectRoot
Write-Host "Backup root: $backupRoot"

$copies = @(
    @{ Source = "server\src\godot-connection.ts"; Target = Join-Path $serverRoot "src\godot-connection.ts" },
    @{ Source = "server\src\utils\bridge-lock.ts"; Target = Join-Path $serverRoot "src\utils\bridge-lock.ts" },
    @{ Source = "server\src\tools\diagnostic-tools.ts"; Target = Join-Path $serverRoot "src\tools\diagnostic-tools.ts" },
    @{ Source = "server\src\index.ts"; Target = Join-Path $serverRoot "src\index.ts" },
    @{ Source = "server\tests\godot-connection.test.ts"; Target = Join-Path $serverRoot "tests\godot-connection.test.ts" },
    @{ Source = "server\tests\bridge-lock.test.ts"; Target = Join-Path $serverRoot "tests\bridge-lock.test.ts" },
    @{ Source = "project\addons\godot_mcp\websocket_server.gd"; Target = Join-Path $projectRoot "addons\godot_mcp\websocket_server.gd" },
    @{ Source = "project\addons\godot_mcp\ui\status_panel.gd"; Target = Join-Path $projectRoot "addons\godot_mcp\ui\status_panel.gd" },
    @{ Source = "project\addons\godot_mcp\plugin.gd"; Target = Join-Path $projectRoot "addons\godot_mcp\plugin.gd" },
    @{ Source = "project\scripts\dev\godot-mcp-common.ps1"; Target = Join-Path $projectRoot "scripts\dev\godot-mcp-common.ps1" },
    @{ Source = "project\scripts\dev\check-godot-mcp.ps1"; Target = Join-Path $projectRoot "scripts\dev\check-godot-mcp.ps1" },
    @{ Source = "project\scripts\dev\enter-worktree-godot-mcp.ps1"; Target = Join-Path $projectRoot "scripts\dev\enter-worktree-godot-mcp.ps1" },
    @{ Source = "project\scripts\dev\safe-repair-godot-mcp.ps1"; Target = Join-Path $projectRoot "scripts\dev\safe-repair-godot-mcp.ps1" },
    @{ Source = "project\scripts\dev\open-worktree-godot.ps1"; Target = Join-Path $projectRoot "scripts\dev\open-worktree-godot.ps1" }
)

foreach ($copy in $copies) {
    $source = Join-Path $patchRoot $copy.Source
    Copy-WithBackup -Source $source -Target $copy.Target -BackupRoot $backupRoot -DryRun:$DryRun
}

if ($Build) {
    if ($DryRun) {
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
