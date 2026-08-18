---
name: devin-multica-bridge
description: Set up, validate, or troubleshoot an experimental Devin CLI integration with Multica on Windows by adapting Devin's ACP server to Multica's Kiro/ACP custom runtime. Use for Devin–Multica connection, custom runtime creation, missing models, broken Windows paths, wrapper installation, daemon logs, and model selection. 关键词：Devin CLI、Multica、自定义运行时、ACP、Kiro、模型列表、连接失败。
---

# Devin CLI → Multica Bridge

Configure Multica to run Devin CLI through standard ACP on Windows. Multica does not currently list Devin as a native runtime, so use a custom runtime based on Multica's Kiro/ACP protocol family and the packaged argument adapter.

Treat this as an experimental compatibility bridge. Validate it after Multica or Devin upgrades.

## Package contents

```text
devin-multica-bridge/
├── SKILL.md
├── README.md
├── install.ps1
└── assets/
    └── devin-multica-acp.ps1
```

The wrapper translates Multica's Kiro launch shape:

```text
<command> acp --trust-all-tools
```

into Devin's supported launch shape:

```text
devin.exe acp
```

It also maps Multica's version probe to `devin.exe --version` and preserves other ACP-compatible arguments.

## Preconditions

Verify these before changing Multica:

1. Windows on amd64 or arm64.
2. Devin CLI is installed:
   ```powershell
   Get-Command devin
   devin --version
   ```
3. Devin authentication and model access work in the user's terminal:
   ```powershell
   devin auth status
   devin models list
   ```
   A successful `devin models list` is the stronger end-to-end check.
4. Multica Desktop is installed, signed in, and connected to the target workspace.
5. The user is a Multica workspace owner or admin.
6. Multica detects at least one built-in runtime, such as Codex or Qoder. A custom profile cannot be the daemon's only startup runtime.
7. Devin CLI and Multica Desktop run as the same Windows user so Devin credentials are available to the child process.

Never request, print, copy, commit, or persist Devin or Multica tokens. Do not display Multica profile `config.json`; it contains an authentication token.

## Install or refresh the wrapper

Use the actual skill source path reported by the skill loader:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<this-skill-dir>\install.ps1"
```

The installer is idempotent. It installs:

```text
%LOCALAPPDATA%\devin\cli\devin-multica-acp.ps1
```

and prints the exact Multica command.

Manual smoke tests:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\devin\cli\devin-multica-acp.ps1" acp --trust-all-tools --version
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\devin\cli\devin-multica-acp.ps1" acp --trust-all-tools --help
```

The first must print the Devin version and the second must print `devin acp` help.

## Create the Multica custom runtime

In Multica Desktop:

1. Open **Runtimes**.
2. Select the target computer.
3. Click **Add custom runtime**.
4. Select **Kiro** as the protocol family. Both Kiro and Devin speak standard ACP.
5. Set the display name to:
   ```text
   Devin CLI (ACP)
   ```
6. Paste the exact command printed by `install.ps1`. It normally looks like:
   ```text
   powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File C:/Users/<WindowsUser>/AppData/Local/devin/cli/devin-multica-acp.ps1
   ```
7. Save the profile.

Do not append `acp` or `--trust-all-tools`; Multica adds them. Do not append `--model` when users need per-agent model selection.

### Critical Windows path rule

Multica's command parser treats backslash as an escape character. Always use forward slashes in the wrapper path.

Correct:

```text
C:/Users/mt/AppData/Local/devin/cli/devin-multica-acp.ps1
```

Incorrect:

```text
C:\Users\mt\AppData\Local\devin\cli\devin-multica-acp.ps1
```

A broken parsed path looks like:

```text
C:UsersmtAppDataLocaldevinclidevin-multica-acp.ps1
```

Before saving, inspect Multica's parsed-command preview. It must preserve the complete forward-slash path.

## Refresh and verify registration

Saving should trigger daemon re-registration. Wait 10–30 seconds and refresh **Runtimes**. If needed, fully quit Multica Desktop from the tray and reopen it.

Expected result:

```text
Devin CLI (ACP) — Online
```

The bundled Multica CLI is commonly located at:

```text
%LOCALAPPDATA%\Programs\@multicadesktop\resources\app.asar.unpacked\resources\bin\multica.exe
```

Diagnose without reading profile configuration files:

```powershell
$multica = "$env:LOCALAPPDATA\Programs\@multicadesktop\resources\app.asar.unpacked\resources\bin\multica.exe"
& $multica --profile desktop-api.multica.ai daemon status
& $multica daemon probe-runtimes
```

Logs are commonly located at:

```text
%USERPROFILE%\.multica\profiles\desktop-api.multica.ai\daemon.log
%USERPROFILE%\.multica\profiles\desktop-api.multica.ai\daemon.err.log
```

Search only relevant non-secret diagnostics:

```powershell
Select-String -Path "$HOME\.multica\profiles\desktop-api.multica.ai\daemon.log" -Pattern 'custom runtime|model list|kiro|initialize failed|devin-multica|powershell' | Select-Object -Last 50
```

Healthy messages include:

```text
registering custom runtime profile ... protocol_family=kiro
registered runtime ... provider=kiro
model list uses custom runtime profile command
```

## Select Devin models

The custom-runtime editor intentionally has no model field. It only defines process startup.

After the runtime is online:

1. Open **Agents**.
2. Create or edit an agent.
3. Select runtime **Devin CLI (ACP)**.
4. Open or refresh the model selector.
5. Select a model returned by Devin ACP.
6. Leave Multica's separate Kiro reasoning-effort field empty when the Devin model ID already contains an effort level.

List exact account models with:

```powershell
devin models list
```

Use only a family slug, alias, or model UID shown by that command. Examples vary by account:

```text
adaptive
swe-1-7
gpt-5-6-terra-high
claude-opus-4-8-high
gpt-5-3-codex-high
```

### Empty or incorrect model selector

Because this is an unofficial Kiro/ACP adaptation, model catalog discovery may not map perfectly. Configure the model per Multica agent:

1. Leave Multica's model selector empty.
2. Add an agent environment variable:
   ```text
   DEVIN_MODEL=<exact Devin model UID or alias>
   ```
3. Save and start a new task.

Example:

```text
DEVIN_MODEL=gpt-5-6-terra-high
```

Do not set both a Multica model and `DEVIN_MODEL`.

To force one model for every agent on this runtime, append to the custom command:

```text
--model <model-id>
```

Do not do this when users need independent per-agent choices.

## First task validation

Start with one agent, concurrency `1`, no additional MCP configuration, and a low-cost or free model exposed by the account. Use a read-only prompt:

```text
Report the active model and list the current workspace files. Do not modify files.
```

Validate:

1. The task starts instead of remaining queued.
2. ACP initialization succeeds.
3. Devin returns messages through Multica.
4. The active model matches the selected model or `DEVIN_MODEL`.
5. The task exits cleanly.

Only then add MCP servers, skills, higher concurrency, or expensive models.

## Troubleshooting

| Symptom | Cause | Action |
|---|---|---|
| Runtime editor has no model field | Expected behavior | Save runtime, then select the model in the Agent editor |
| Models stay empty and log path is `C:Users...` | Multica stripped backslashes | Replace the wrapper path with forward slashes |
| `Devin CLI was not found` | Devin binary missing from expected path | Reinstall Devin CLI or update `$devin` in the wrapper |
| `Not logged in` or model listing fails | Credentials unavailable to daemon user | Log in under the same Windows account; rerun `devin models list` |
| Profile does not appear | Wrong role/workspace or daemon did not sync | Verify owner/admin access, refresh, restart Desktop |
| Custom profile is the only runtime | Multica requires a built-in runtime first | Keep Codex, Qoder, or another native runtime detected |
| `kiro initialize failed` | Wrapper failed, args are wrong, or ACP incompatibility | Run both smoke tests and inspect model-list/task logs |
| Model selector shows Kiro values | Provider metadata did not map to Devin | Leave selector empty and use per-agent `DEVIN_MODEL` |
| Unexpected model | Multiple overrides conflict | Keep only one of Agent model, `DEVIN_MODEL`, or fixed `--model` |
| HTTP 502 fetching/registering profiles | Multica service/network failure | Retry after service recovery; do not change the wrapper |
| Repository clone errors appear nearby | Separate repository authentication issue | Diagnose repository access separately from ACP |

## Maintenance

- Pull the Skill repository and rerun `install.ps1` to upgrade the wrapper.
- Re-run smoke tests after Devin CLI updates.
- Retest after Multica changes its Kiro launch arguments or ACP backend.
- Preserve forward-slash paths in Multica.
- Keep credentials out of commands, logs shown to users, and source control.
- If Multica adds a native Devin protocol family, migrate to it and retire this bridge.
