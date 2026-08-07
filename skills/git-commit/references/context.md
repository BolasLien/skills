# Git Commit Workflow Guide

> For commit config data, see `commit-config.yaml`.

## Core Principles

1. **Analyze Before Acting**: Always run `git status` and `git diff --name-only` before committing
2. **Base on Real Changes**: Describe actual diff only, never guess
3. **Traditional Chinese**: All commit messages in Traditional Chinese

---

## Conventional Commits Format

```
<type>(<scope>): <subject>
<body>
<footer>
```

**Refer to `../commit-types.md` for:**

- Type definitions and selection rules (feat, fix, refactor, style, docs, test, chore, perf, ci, build, revert)

**Refer to `commit-config.yaml` for:**

- `scopes`: Scope definitions (project-specific — see the file's placeholder)
- `subject`: Guidelines (max 50 chars, quantitative hints)
- `body`: When required and formatting rules

**Example:**

```
feat(ui): 實作 Alert 元件

- 實作三種變體: success, info, danger
- 支援響應式布局 (mobile/desktop)
- 使用 CSS custom properties 傳遞顏色
- 建立完整的 Storybook stories
```

**Footer uses:**

- Link issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: ...`
- Dependencies: `Depends on #abc123`

---

## Workflow

**Change Analysis:**

```bash
git status              # Inspect working tree
git diff --name-only    # List changed files
git diff <file>         # Detailed diffs (if needed)
```

**Formatting:**
Refer to `commit-config.yaml` → `formatting` for the project's formatter command. Skip this step when it is `none`.

```bash
<formatting.command>  # Run from repo root, before committing, if configured
```

**Submission:**

```bash
git status && git diff --name-only  # 1. Analyze
<formatting.command>                 # 2. Format (if configured)
git add <files>                      # 3. Stage
git commit -m "<type>(<scope>): <subject>

<body>"                              # 4. Commit
```

---

## Commit Splitting Strategy

**Core rules:**

- Focus on one logical change
- Understandable on its own
- Include all related files
- Pass tests, keep app functional

**Refer to `commit-config.yaml` → `splitting` for:**

- `split_when`: Independent components, different modules, refactor vs feature, massive formatting
- `keep_together`: Component + stories/styles/tests, coupled types + implementation
- `decision_questions`: 3 questions to ask
- `decision_rule`: All yes → keep together; any no → split

---

## Common Mistakes & Fixes

| Mistake               | Wrong                                       | Correct                                                                  |
| --------------------- | ------------------------------------------- | ------------------------------------------------------------------------ |
| **No analysis**       | `git add . && git commit -m "更新程式碼"`   | Run `git status` and `git diff` first, then commit with specific message |
| **Unrelated changes** | `git add alert.tsx badge.tsx && git commit` | Split: commit alert.tsx, then badge.tsx separately                       |
| **Vague subject**     | `feat: 更新程式碼`                          | `feat(icons): 新增 2000+ Bootstrap Icons React 元件`                     |
| **Missing body**      | `feat(ui): 新增 Alert` (for complex change) | Add body with bullet points explaining variants, layout, properties      |
| **Extra tags**        | Adding `Co-Authored-By: Claude`             | Remove all Co-Authored-By tags                                           |

---

## Troubleshooting

| Issue                              | Solution                                                                    |
| ---------------------------------- | --------------------------------------------------------------------------- |
| **Forgot analysis**                | `git commit --amend` or `git reset HEAD~1` then re-commit                   |
| **Multiple changes in one commit** | `git reset HEAD~1`, then stage and commit separately                        |
| **Large formatting diffs**         | Commit formatting first (`style: ...`), then commit functional changes      |

---

## BREAKING CHANGE

**When to add:** API changes, prop changes, removed functionality, default value changes

**Example:**

```
feat(badge): 改用新的 color token 系統

BREAKING CHANGE: Badge color prop 值已變更

舊值 -> 新值:
- blue -> primary
- red -> danger
- yellow -> warning

移轉: <Badge color="blue" /> -> <Badge color="primary" />
```

---

## Pre-Commit Checklist

- [ ] Analyzed: `git status` and `git diff`
- [ ] Formatted with the project's configured formatter, or confirmed none is configured
- [ ] Logically grouped commits
- [ ] Conventional Commits format
- [ ] Traditional Chinese message
- [ ] No Co-Authored-By tags
- [ ] Each commit stands alone

---

## Prohibited Content

❌ **Never add:**

- Co-Authored-By tags
- "Generated with Claude Code" notices
- Extra author metadata
- AI-generated copyright statements
