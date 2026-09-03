# Godot MCP Pro Hardening Patch

This directory stores the movable, replayable hardening patch for Godot MCP Pro. The current patch baseline is `1.16.0-nh.1`: upstream `1.16.0` plus the local bridge lifecycle hardening.

`nano-hunter` currently hosts and verifies this tool, but the patch tool is not tied to this project. It can be used for another Godot project, such as `angel-fallen`, as long as `-ProjectPath` points to that project and the script can find `patch-files`.

## Why This Exists

- The Node MCP server lives outside this repository at `C:/Users/peng8/.mcp/godot-mcp-pro/server`.
- Plugin or server upgrades can overwrite local hardening changes.
- Each Godot project owns its own `addons/godot_mcp` copy.
- The project needs a traceable way to reapply bridge lifecycle fixes without manually editing external files.

## Port Plan

- `17605-17619`: stdio MCP primary bridge ports.
- `17620-17624`: primary `godot-cli` ports.
- `6505-6509`: legacy stdio fallback ports.
- `6510-6514`: legacy `godot-cli` fallback ports.
- Godot plugin first reads `<ProjectPath>/.godot/godot-mcp-pro/current-bridge.json`, then falls back to the port groups above.
- Node stdio server skips all CLI ports and writes both global lock files and project-local rendezvous.

The old `6505-6534` range overlaps this machine's observed TCP dynamic port pool (`1024-15000`), so common network software such as proxy clients or mail clients can bind those ports. The new primary range avoids that pool while keeping legacy compatibility.

## Patch Layout

- `patch-files/server`: global Node MCP Server patch and Vitest regression tests.
- `patch-files/plugin/addons/godot_mcp`: per-project Godot plugin template, including upstream `1.16.0` command files plus local rendezvous/handshake connection layer, idle/stale status panel, input-dispatch fixes, token handshake, and plugin metadata.
- `patch-files/optional-project-scripts/scripts/dev`: optional diagnostic scripts for projects that adopt the Nano Hunter workflow.

`optional-project-scripts` are not applied by default. They are useful for projects that want the same `check / enter / safe-repair / open-worktree` workflow, but they should not be forced into unrelated projects.

## Common Commands

Preview the default patch for the current project:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
```

Apply the default patch and rebuild the Node server:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -Build
```

Patch only another project's plugin, for example `angel-fallen`:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope PluginOnly `
  -DryRun
```

Apply global server plus another project's plugin:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope ServerAndPlugin `
  -Build
```

Apply optional project scripts only when the target project accepts this workflow:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope PluginOnly `
  -IncludeProjectScripts `
  -DryRun
```

## Movable Tool Usage

The script first honors explicit `-PatchRoot`. If omitted, it searches likely nearby locations, including a sibling `patch-files` directory and the target project's `tools/godot-mcp-pro-hardening/patch-files`.

Recommended standalone layout:

```text
C:\Tools\godot-mcp-pro-hardening\
  apply-godot-mcp-pro-hardening-patch.ps1
  patch-files\
    server\
    plugin\
    optional-project-scripts\
```

Run from that standalone layout:

```powershell
C:\Tools\godot-mcp-pro-hardening\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -Scope ServerAndPlugin `
  -DryRun
```

If the script and `patch-files` are separated, pass `-PatchRoot`:

```powershell
C:\Tools\apply-godot-mcp-pro-hardening-patch.ps1 `
  -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen `
  -PatchRoot C:\Users\peng8\.codex\worktrees\fef5\nano-hunter\tools\godot-mcp-pro-hardening\patch-files `
  -Scope PluginOnly `
  -DryRun
```

## Scope Reference

- `ServerOnly`: update only `C:/Users/peng8/.mcp/godot-mcp-pro/server`.
- `PluginOnly`: update only `<ProjectPath>/addons/godot_mcp`.
- `ServerAndPlugin`: default; update global server and target project plugin.
- `All`: update server and plugin; optional project scripts still require `-IncludeProjectScripts`.

## Safety And Rollback

- The script checks `package.json` and expects a reviewed Godot MCP Pro version, currently `1.16.0` or `1.16.0-nh.1`, when the scope includes the server.
- Unknown versions require `-Force` after manual review.
- `-DryRun` does not write target files, does not build, and does not create backup directories.
- Real apply backs up existing targets to `tests/artifacts/local/godot-mcp-patch-backups/<timestamp>/`, or to `-BackupRoot`.
- To roll back, copy the relevant backup files back to their original paths.

## Maintenance Rule

Whenever Node server, Godot plugin, or optional project scripts change for bridge lifecycle behavior, refresh the matching files under `patch-files/` in the same commit and run the dry-run matrix documented in `docs/dev/godot-mcp-pro-connectivity-guide.md`.
