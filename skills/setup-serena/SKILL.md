---
name: setup-serena
description: Install and configure the Serena MCP server for Codex on a new machine or repository. Use when the user asks to set up Serena, install serena-agent, configure Serena MCP, enable Serena hooks, migrate from uvx GitHub-based Serena startup to the official local installation, verify Serena tools, or troubleshoot whether Serena activates across different repos.
---

# Setup Serena

Use this workflow to reproduce a known-good Serena setup for Codex without rediscovering commands.

## Target State

Codex should use the official local Serena installation:

```toml
[mcp_servers.serena]
command = "serena"
args = ["start-mcp-server", "--context=codex", "--project-from-cwd"]

[mcp_servers.serena.tools.write_memory]
approval_mode = "approve"
```

Codex hooks should call:

```bash
serena-hooks activate --client codex
serena-hooks remind --client codex
serena-hooks cleanup --client codex
```

## Workflow

1. Read any repo-local `AGENTS.md` or `CLAUDE.md` before making project-specific changes.
2. Inspect the current Serena state:

```bash
codex mcp get serena
uv tool list
serena --version
```

If `serena` is not installed but `uvx --from git+https://github.com/oraios/serena ...` exists in `~/.codex/config.toml`, migrate it to the official tool install.

3. Install Serena using the official uv tool flow:

```bash
uv tool install -p 3.13 serena-agent
```

Expected executables: `serena`, `serena-agent`, `serena-hooks`.

4. Register Serena for Codex using Serena's setup command:

```bash
serena setup codex
```

Expected effect: it runs a command equivalent to:

```bash
codex mcp add serena -- serena start-mcp-server --context=codex --project-from-cwd
```

5. Preserve memory safety. Ensure `~/.codex/config.toml` contains:

```toml
[mcp_servers.serena.tools.write_memory]
approval_mode = "approve"
```

Add it back if `serena setup codex` rewrites the MCP block and removes it.

6. Enable Codex hooks if necessary. On current Codex builds, the feature flag is:

```toml
[features]
hooks = true
```

Do not add obsolete or unknown feature names unless the local Codex version explicitly requires them.

7. Create or update `~/.codex/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "serena-hooks activate --client codex",
            "async": false
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "serena-hooks remind --client codex",
            "async": false
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "serena-hooks cleanup --client codex",
            "async": false
          }
        ]
      }
    ]
  }
}
```

If a hooks file already exists, merge entries instead of overwriting unrelated hooks.

## Verification

Run:

```bash
codex mcp get serena
jq . ~/.codex/hooks.json
serena --version
serena tools list
```

Expected MCP output:

```text
command: serena
args: start-mcp-server --context=codex --project-from-cwd
```

After restarting Codex, use `tool_search` to expose Serena tools, then test:

1. `activate_project` with the current repo path.
2. `initial_instructions`.
3. `get_current_config`; confirm active context is `codex`.
4. `list_memories`; confirm project memories are visible if the repo is known.
5. `get_symbols_overview` on a real source file.
6. `find_symbol` and, if available, `find_referencing_symbols`.
7. `get_diagnostics_for_file` on a source file.

Do not test `write_memory` by creating throwaway memories unless the user explicitly approves; config-level verification is usually enough.

## Expected Cross-Repo Behavior

Because the MCP args include `--project-from-cwd`, Serena should activate based on the Codex working directory:

- Known repos activate directly.
- New repos may need Serena onboarding or project metadata.
- Non-code directories may only receive hook reminders.
- Memories are project-scoped unless intentionally written under `global/`.

## Common Pitfalls

- `uvx --from git+https://github.com/oraios/serena ...` works but is not the official persistent install target.
- `serena setup codex` may replace the MCP block; re-check `write_memory` approval afterward.
- `uv` commands may need access to the user's uv cache; if sandboxed execution fails on `~/.cache/uv`, rerun with appropriate approval.
- If `serena-hooks activate --client codex` emits JSON containing `additionalContext`, the hook command itself is working.
