---
name: setup-skill-sync
description: Set up symlink-based sync from this skills repo into Claude Code, Codex, and Gemini CLI/Antigravity's global skill directories, so editing a skill here updates every agent immediately with no copy or update step. Use when the user wants to install this repo's skills onto their coding agents, set up a new machine, or re-sync after adding a skill to this repo.
---

# Setup Skill Sync

Makes this repo the single source of truth for skills shared across Claude Code, Codex, and Gemini CLI/Antigravity. For every skill under `skills/<name>/`, creates a symlink named `<name>` in each agent's global skills directory, pointing back to this repo. Editing `SKILL.md` here is then live everywhere immediately — verified on Codex and Antigravity CLI (both follow symlinked skill directories fine).

## Targets

Only touched if the directory already exists on this machine:

- `~/.claude/skills/<name>`
- `~/.codex/skills/<name>`
- `~/.gemini/skills/<name>` (also read by Antigravity CLI, not just Gemini CLI)

## Workflow

1. Preview first:

```bash
skills/setup-skill-sync/scripts/sync.sh --dry-run
```

2. Run it for real from the repo root:

```bash
skills/setup-skill-sync/scripts/sync.sh
```

3. Read the per-skill, per-target output:

- `linked` — symlink created
- `ok` — symlink already correct, nothing to do
- `conflict` — target exists as a real file/dir, or a symlink pointing somewhere else; left untouched

4. Resolve any `conflict` lines manually. The script never overwrites existing content — a conflict usually means that agent already has its own independent copy of a same-named skill. Decide per-skill whether to remove the old copy and re-run, or rename one side.

## Adding a new skill later

Re-run the same script. It only creates missing links, so it's safe to run repeatedly and after every new skill is added.

## Verification

```bash
ls -la ~/.claude/skills/<name> ~/.codex/skills/<name> ~/.gemini/skills/<name>
```

Each should show `<name> -> /absolute/path/to/this/repo/skills/<name>`.
