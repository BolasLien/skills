# Skills

Reusable Claude Code agent skills for AI-assisted development workflows.

## Structure

```txt
.codex-plugin/
└── plugin.json
.claude-plugin/
└── plugin.json
CLAUDE.md
README.md
skills/
└── <skill-name>/
    ├── SKILL.md
    ├── README.md
    ├── README.zh-TW.md
    ├── agents/
    │   └── openai.yaml
    ├── references/
    ├── scripts/
    └── templates/
references/
└── *.md
scripts/
└── *.sh / *.py / *.js
```

Only directories with actual content need to exist. `.claude-plugin/` and `.codex-plugin/` are reserved for plugin metadata and should only contain `plugin.json`.

## Reference

Every skill is generic — none are tied to a specific repo. Grouped by what they're for; each line names when to reach for it.

### Git & Merge Requests

- **[git-commit](./skills/git-commit/SKILL.md)** — Standardize the Git commit workflow: change analysis, optional formatting, commit-message conventions, and commit-splitting strategy.
- **[glab-mr](./skills/glab-mr/SKILL.md)** — Standardize the GitLab Merge Request workflow via `glab`: branch diff analysis, branch pushing, MR title/description conventions, create/update operations.
- **[glab-mr-review](./skills/glab-mr-review/SKILL.md)** — Review a GitLab Merge Request via `glab`, grounded in the full MR-branch content, producing a findings-first report optionally posted as an MR comment.

### Planning, Delivery & Handoff

- **[generate-spec](./skills/generate-spec/SKILL.md)** — Draft a product/functional spec (PRD), choosing lite vs. standard templates and flagging unverified details instead of guessing.
- **[codex-goal-writer](./skills/codex-goal-writer/SKILL.md)** — Turn rough task intent into a structured Codex CLI `/goal` prompt with explicit scope, validation, pause conditions, and stopping criteria.
- **[subagent-go](./skills/subagent-go/SKILL.md)** — Direct a bounded task to implementation/git subagents, stay out of the implementation itself, and independently audit evidence before accepting the result.
- **[reject-and-redo](./skills/reject-and-redo/SKILL.md)** — Reject a task/PR delivery that claims completion without sufficient evidence against acceptance criteria, and require self-verification and re-delivery.
- **[handoff-audit](./skills/handoff-audit/SKILL.md)** — Create, update, intake, and audit one human-readable handoff per transferable task under `docs/handoffs/<task-slug>.md`.
- **[linear-task-lifecycle](./skills/linear-task-lifecycle/SKILL.md)** — Keep a referenced Linear issue synchronized with implementation, verification, interruption, and completion state.

### Codebase & Integrations

- **[codebase-inventory](./skills/codebase-inventory/SKILL.md)** — Build and maintain an evidence-backed codebase architecture inventory using Repomix, Madge, ast-grep, Git, and ripgrep, with `create`/`update`/`query` commands.
- **[jira-api](./skills/jira-api/SKILL.md)** — Query, create, transition, edit, and comment on Jira Cloud issues via a `scripts/jira.sh` CLI wrapper (curl + REST API v3 fallback).

### Setup & Tooling

- **[setup-serena](./skills/setup-serena/SKILL.md)** — Install `serena-agent`, configure Serena MCP for Codex, enable hooks, and verify cross-repo activation.
- **[setup-skill-sync](./skills/setup-skill-sync/SKILL.md)** — Symlink this repo's skills into Claude Code, Codex, and Gemini CLI/Antigravity's global skill directories so editing a skill here updates every agent immediately.

## Installation / Usage

Use this repository as a Claude Code plugin source. After installing or linking the plugin, skills live under `skills/<skill-name>/SKILL.md` and can be invoked when their frontmatter `description` matches the user request.

For local development, clone the repo and edit skills in place:

```bash
git clone git@github.com:BolasLien/skills.git
cd skills
```

## Conventions

- Plugin metadata lives in `.claude-plugin/plugin.json`.
- Codex plugin metadata lives in `.codex-plugin/plugin.json`.
- Skills live in `skills/<skill-name>/SKILL.md`.
- Optional human-facing skill usage docs may live in `skills/<skill-name>/README.md`.
- English is the default README language. Localized skill docs may use `README.<locale>.md`, for example `README.zh-TW.md`.
- Skill UI metadata may live in `skills/<skill-name>/agents/openai.yaml`.
- Skill folder names use kebab-case.
- Every `SKILL.md` starts with YAML frontmatter containing `name` and `description`.
- `description` explains when to use the skill, not just what the skill is.
- Keep `SKILL.md` concise and use progressive disclosure.
- Shared references live in root `references/`.
- Skill-specific references live in `skills/<skill-name>/references/`.
- Shared scripts live in root `scripts/`.
- Skill-specific scripts live in `skills/<skill-name>/scripts/`.
- Scripts must be documented in the relevant `SKILL.md` or this README.

## Unresolved / Uncategorized

No uncategorized content yet.

## License

MIT License. See [LICENSE](./LICENSE).
