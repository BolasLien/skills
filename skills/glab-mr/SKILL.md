---
name: glab-mr
description: Assist with GitLab Merge Request operations including branch diff analysis, branch pushing, MR creation/updates, and description drafting. Uses glab CLI, follows branch conventions, and uses standard MR templates. Ideal for create-mr or update-mr commands.
---

# GitLab Merge Request Workflow

Standardized GitLab MR workflow for creating and updating Merge Requests.

## References

This skill uses the following reference files:

- **`references/commit-types.md`**: Conventional Commit type definitions (shared with `git-commit`)
- **`references/abbreviations.md`**: Standard abbreviations (MR, MCP, etc.)
- **`references/context.md`**: Complete workflow guide and best practices
- **`references/mr-config.yaml`**: Structured MR configuration data (scopes, branch patterns, project settings)

**Loading strategy:**

1. Read `abbreviations.md` first to understand terminology
2. Consult `references/commit-types.md` when validating MR types
3. Consult `mr-config.yaml` when validating scopes or branch names
4. Refer to `context.md` for detailed workflow steps and guidelines

## Scope

Focus on MR-related tasks:

- Analyze changes between current and target branches
- Push current branch to remote
- Create MRs via glab CLI
- Update existing MRs after follow-up commits
- Draft and maintain clear, complete MR descriptions

## Core Principles

### Analyze Before Acting

**Always run branch diff analysis before creating/updating an MR:**

```bash
# 1. List commits between target and HEAD
git log {target-branch}..HEAD --oneline

# 2. List changed files
git diff {target-branch}..HEAD --name-only
```

**Base MR descriptions strictly on actual changes. Never speculate.**

### Prohibited Items

❌ **Never include:**

- "Generated with Claude Code" tags
- AI-generated copyright notices
- Vague or meaningless descriptions

## Standard Workflow

```
1. Run branch diff analysis
   └─> git log {target}..HEAD --oneline
   └─> git diff {target}..HEAD --name-only

2. Create MR with glab (automatically pushes branch)
   └─> glab mr create --push --title "..." --description "..." --target-branch {target}
   └─> --push flag ensures branch is pushed before MR creation
   └─> Fill title and description based on template

4. Draft MR description (actual changes only)
   └─> Use standard template from context.md
   └─> Include: Summary, 相關連結, 如何測試, 注意事項
   └─> Write in Traditional Chinese

5. Update existing MR (when needed)
   └─> Re-run diff analysis after new commits
   └─> Sync Summary/測試/注意事項 with latest state
   └─> Use glab mr update
   └─> Reply to review comments
```

## MR Title Format

Follow Conventional Commit format:

```
<type>(<scope>): <subject>
```

**Consult `references/commit-types.md`** for valid types (feat, fix, refactor, etc.).

**Consult `mr-config.yaml`** for valid `scopes`.

**Rules:**

- ✅ Keep under 50 characters
- ✅ Write subject in Traditional Chinese
- ✅ Describe **what** changed, not **how**
- ❌ No Jira IDs in title

## MR Description Template

```markdown
## Summary

<!-- Bullet major changes -->

## 相關連結

- Jira 連結:

## 如何測試

<!-- Verification steps, flows, expected outcomes -->

## 注意事項

<!-- Special configurations or impacts -->
```

See `context.md` for detailed guidelines on each section.

## Branch Naming

**Consult `mr-config.yaml` → `branch_patterns`** for prefix rules.

**Examples:**

```bash
feature/alert-component
fix/badge-style-issue
refactor/badge-variants
docs/update-readme
```

## glab CLI Integration

### Create MR

**⚠️ IMPORTANT: Always use `--push` flag to ensure branch is pushed before MR creation.**

**Basic usage:**

```bash
glab mr create \
  --push \
  --title "feat: 新增 XX 功能" \
  --description "..." \
  --target-branch develop
```

**Common options:**

- `--push`: **[REQUIRED]** Push branch before creating MR
- `--title, -t`: MR title (Conventional Commit format)
- `--description, -d`: MR description (use template)
- `--target-branch, -b`: Target branch (e.g., develop, main)
- `--assignee, -a`: Assign to user by username
- `--reviewer`: Request review from users
- `--label, -l`: Add labels (comma-separated)
- `--draft`: Mark as draft MR
- `--remove-source-branch`: Auto-remove branch after merge

### Update MR

**Update current branch's MR:**

```bash
glab mr update \
  --title "feat: 調整 XX 功能" \
  --description "..."
```

**Update specific MR by ID or branch:**

```bash
glab mr update 123 \
  --title "..." \
  --description "..."
```

**Common update options:**

- `--title, -t`: Update title
- `--description, -d`: Update description (use "-" to open editor)
- `--assignee, -a`: Update assignees (prefix with +/- to add/remove)
- `--reviewer`: Update reviewers (prefix with +/- to add/remove)
- `--label, -l`: Add labels
- `--unlabel, -u`: Remove labels
- `--draft`: Mark as draft
- `--ready, -r`: Mark as ready for review
- `--target-branch`: Change target branch

### View MR

**View current branch's MR:**

```bash
glab mr view
```

**View specific MR:**

```bash
glab mr view 123
glab mr view feature/xxx
```

**View with details:**

```bash
glab mr view --comments     # Include comments
glab mr view --web          # Open in browser
```

## Update Workflow

When revising after review:

1. Re-run branch diff analysis
2. Push new commits
3. Update MR description (Summary/測試/注意事項)
4. Use `glab mr update` to update title/description/labels/reviewers
5. Reply to each review comment

## Quick Checklist

Before creating **or updating** an MR:

- [ ] Branch diff analyzed after latest commits
- [ ] Using `--push` flag with `glab mr create` (ensures branch is pushed)
- [ ] Title follows Conventional Commit format (validate with mr-config.yaml)
- [ ] Description reflects current changes (Summary/測試/注意事項)
- [ ] Complete test plan included
- [ ] Description written in Traditional Chinese
- [ ] Special considerations documented

## Common Issues

For troubleshooting (push rejected, missing upstream, invalid project ID, etc.), refer to `context.md` → "Common Issues & Fixes".

## Best Practices

1. Rebase frequently: `git rebase origin/develop`
2. Keep MR scope reasonable (see `mr-config.yaml` → `mr_size`)
3. Respond to reviews within 24 hours
4. Keep descriptions current after every push
5. Use meaningful branch names

---

**For complete details, workflows, and examples, see `context.md`.**
