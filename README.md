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

## Skills

- `codex-goal-writer`: Turns rough task intent into structured Codex CLI `/goal` prompts with explicit scope, validation, pause conditions, and stopping criteria.

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
