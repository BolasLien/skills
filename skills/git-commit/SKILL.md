---
name: git-commit
description: Assist with Git commit tasks such as analyzing local changes, formatting, splitting commits, and writing commit messages. Useful for Claude Code commands like create-commit.
---

# Git Commit Workflow

This skill standardizes the Git commit workflow.

## References

**Loading strategy:**

1. Consult `references/commit-types.md` when validating commit types
2. Consult `references/commit-config.yaml` when validating scopes or splitting decisions
3. Refer to `references/context.md` for detailed workflow steps and examples

## Scope

Focus on commit-specific tasks:

- Analyze the changes in the working tree
- Format modified files if the project has a configured formatter
- Split commits by logical grouping
- Write commit messages that follow the Conventional Commit format

## Core Principles

### Analyze Before You Act

**Always finish the change analysis before running any commit command**:

```bash
# 1. Inspect the working tree status
git status

# 2. List files that changed
git diff --name-only
```

**Commit messages must reflect the actual changes; never guess.**

### Prohibited Items

❌ **Never** add:

- `Co-Authored-By` tags
- `Generated with Claude Code` notices
- Any extra author metadata
- AI-generated copyright statements

## Standard Workflow

```
1. Analyze the diff
   └─> git status
   └─> git diff --name-only

2. Format modified files if the project has one configured
   └─> Check `commit-config.yaml` → `formatting` for the project's formatter command
   └─> Skip this step when `formatting.command` is `none`
   └─> Do NOT invent custom formatting commands

3. Group changes by logical scope
   └─> Split by feature/component/concern
   └─> Keep related changes together
   └─> Separate refactors from feature work

4. Create commits per logical unit
   └─> Use the Conventional Commit format
   └─> Write messages in English
   └─> Each commit should stand on its own
```

## Commit Splitting Guidelines

### Split When

✅ Different features
✅ Different components
✅ Refactors vs. feature work
✅ Visual tweaks vs. logic changes
✅ Config files vs. application code

### Avoid Splitting When

❌ Files support the same feature
❌ Component + corresponding tests
❌ Changes that only make sense together

## Commit Message Format

Use **Conventional Commits**:

```
<type>(<scope>): <subject>

<body>
```

See `references/commit-types.md` for the full type list and selection rules.

**Example**:

```
feat(alert): 新增 Alert 元件

- 實作三種變體: success, info, danger
- 支援響應式布局 (mobile/desktop)
- 使用 CSS custom properties 傳遞顏色
- 建立完整的 Storybook stories
```

## Quick Checklist

Confirm before committing:

- [ ] Ran `git status` and `git diff` to analyze changes
- [ ] Ran the project's configured formatter on modified files, or confirmed none is configured
- [ ] Commits are logically grouped
- [ ] Commit message follows Conventional Commits
- [ ] Message is written in English
- [ ] All `Co-Authored-By` tags removed

## Detailed Reference

For the full Git commit standards and workflow, read `references/context.md`.
