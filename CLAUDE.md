# CLAUDE.md

## Repository Purpose

This repository contains Claude Code plugin skills.

## Structure Rules

- Plugin metadata lives in `.claude-plugin/plugin.json`.
- Codex plugin metadata lives in `.codex-plugin/plugin.json`.
- `.claude-plugin/` should only contain `plugin.json`.
- `.codex-plugin/` should only contain `plugin.json`.
- Skills live in `skills/<skill-name>/SKILL.md`.
- Optional human-facing skill usage docs may live in `skills/<skill-name>/README.md`.
- English is the default skill README language. Localized skill docs may use `README.<locale>.md`, for example `README.zh-TW.md`.
- Skill UI metadata may live in `skills/<skill-name>/agents/openai.yaml`.
- Skill names use kebab-case.
- Shared references live in `references/`.
- Skill-specific references live in `skills/<skill-name>/references/`.
- Shared scripts live in `scripts/`.
- Skill-specific scripts live in `skills/<skill-name>/scripts/`.
- Templates live in `skills/<skill-name>/templates/` when they are skill-specific.

## Skill Authoring Rules

- Every skill must have a `SKILL.md`.
- Every `SKILL.md` must start with YAML frontmatter.
- Frontmatter must include `name` and `description`.
- `description` must describe when to use the skill.
- Keep `SKILL.md` concise.
- Move long examples, templates, and detailed references into separate files.
- Keep skill-level `README.md` human-facing; do not rely on it for agent trigger behavior.
- Keep localized README files separate from the default English README.
- Use relative links from `SKILL.md`.

## Review Checklist

Before finishing, verify:

- Directory structure is valid.
- Every skill has a `SKILL.md`.
- Every `SKILL.md` has valid frontmatter.
- Skill names match their folder names.
- References are placed at the correct level.
- Scripts are documented.
- README lists all skills.
- Plugin metadata directories contain only `plugin.json`.
