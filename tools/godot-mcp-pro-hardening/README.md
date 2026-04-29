# Godot MCP Pro Hardening Patch

This directory stores the replayable hardening patch for Godot MCP Pro `1.12.0`.

Why it exists:

- The Node MCP server lives outside this repository at `C:/Users/peng8/.mcp/godot-mcp-pro/server`.
- Plugin upgrades can overwrite local Node server changes.
- The project needs a traceable way to reapply the bridge lifecycle fixes.
- The patch files also include the Node Vitest regression tests used to verify port fallback, CLI reservation, workspace normalization and bridge lock behavior.

Port plan:

- `6505-6509`: stdio MCP primary bridge ports.
- `6510-6514`: reserved for `godot-cli`.
- `6515-6534`: stdio MCP overflow bridge ports.
- Godot plugin scans `6505-6534`; Node stdio server skips `6510-6514`.

Apply flow:

```powershell
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -Build
```

Safety and rollback:

- The script checks `package.json` and expects version `1.12.0`.
- Unknown versions require `-Force` after manual review.
- Backups are written to `tests/artifacts/local/godot-mcp-patch-backups/<timestamp>/`.
- To roll back, copy the relevant backup files back to their original paths.

Maintenance rule:

Whenever Node server, Godot plugin, or PowerShell MCP scripts are changed for bridge lifecycle behavior, refresh the matching files under `patch-files/` in the same commit.
