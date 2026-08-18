# Devin CLI × Multica Bridge Skill

Portable Devin Skill for setting up and troubleshooting an experimental Devin CLI integration with Multica Desktop on Windows. It adapts Devin's standard ACP server to Multica's Kiro/ACP custom-runtime protocol.

This is an unofficial compatibility bridge. Multica does not currently provide a native Devin runtime.

## Prerequisites

- Windows
- Devin CLI installed and authenticated
- `devin models list` succeeds
- Multica Desktop installed and connected
- Multica workspace owner/admin permission
- At least one Multica-native runtime, such as Codex or Qoder, already detected

## Use as a temporary global Skill

```powershell
git clone https://github.com/ZhaoYangGG/devin-multica-bridge-skill.git "$env:APPDATA\devin\skills\devin-multica-bridge"
```

Start a new Devin session, then invoke:

```text
/devin-multica-bridge
```

Install or refresh the ACP wrapper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:APPDATA\devin\skills\devin-multica-bridge\install.ps1"
```

The installer prints the exact command to paste into Multica.

## Use for one project only

Run from the project root:

```powershell
New-Item -ItemType Directory -Path ".devin\skills" -Force | Out-Null
git clone https://github.com/ZhaoYangGG/devin-multica-bridge-skill.git ".devin\skills\devin-multica-bridge"
```

Start a new Devin session in that project and invoke `/devin-multica-bridge`.

## Multica runtime summary

Create a custom runtime with:

- Protocol family: `Kiro`
- Display name: `Devin CLI (ACP)`
- Command printed by `install.ps1`, normally:

```text
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File C:/Users/<user>/AppData/Local/devin/cli/devin-multica-acp.ps1
```

Use forward slashes in the path. Multica treats backslashes as escape characters.

## Update

```powershell
git -C "$env:APPDATA\devin\skills\devin-multica-bridge" pull
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:APPDATA\devin\skills\devin-multica-bridge\install.ps1"
```

## Remove the temporary Skill

After confirming the path, remove the cloned Skill directory:

```powershell
Remove-Item -Recurse -Force "$env:APPDATA\devin\skills\devin-multica-bridge"
```

This does not remove `%LOCALAPPDATA%\devin\cli\devin-multica-acp.ps1`, because an existing Multica runtime may still depend on it.

See `SKILL.md` for the complete workflow, model selection, validation, and troubleshooting guide.
