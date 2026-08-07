# GitLab MR Workflow Guide

> For abbreviations, see `abbreviations.md`. For MR config data, see `mr-config.yaml`.

## Core Principles

### 1. Analyze Before Acting

**Always run branch diff analysis before creating/updating an MR.**

```bash
# List commits between target and HEAD
git log {target}..HEAD --oneline

# List changed files
git diff {target}..HEAD --name-only
```

### 2. Describe Actual Changes

Base MR descriptions on **actual changes only**. Never speculate. Re-verify after every commit.

### 3. Write in Traditional Chinese

All MR titles and descriptions must be in Traditional Chinese.

---

## Standard Workflow

```
1. Analyze branch diff
   → git log {target}..HEAD --oneline
   → git diff {target}..HEAD --name-only

2. Create MR via glab CLI (automatically pushes branch)
   → glab mr create --push --title "..." --description "..." --target-branch {target}
   → --push flag ensures branch is pushed before MR creation
   → title (Conventional Commit format)
   → description (use template)

4. Draft MR description
   → Summary / 相關連結 / 如何測試 / 注意事項
   → Based on actual changes only
   → Written in Traditional Chinese

5. Update existing MR
   → Re-run git log/diff after new commits
   → Sync Summary/測試/注意事項 with latest state
   → Use glab mr update
   → Reply to all review comments
```

---

## Branch Management

### Naming Convention

Refer to `mr-config.yaml` → `branch_patterns` for prefix rules.

**Examples:**

```bash
feature/alert-component
fix/badge-style-issue
refactor/button-logic
docs/update-readme
```

**Rules:**

- ✅ Lowercase only
- ✅ Hyphen-separated words
- ✅ Concise but descriptive
- ❌ Avoid: test, temp, my-branch

### Commands

```bash
# Create branch
git checkout -b feature/xxx {target}

# First push (set upstream)
git push -u origin feature/xxx

# Subsequent pushes
git push

# Check current branch
git branch --show-current
```

---

## MR Title Format

### Conventional Commit Structure

```
<type>(<scope>): <subject>
```

**Refer to `../commit-types.md`** for type definitions and usage.

**Refer to `mr-config.yaml`** for `scopes` definitions.

**Rules:**

- ✅ Keep under 50 characters
- ✅ Traditional Chinese subject
- ✅ Describe **what** changed, not **how**
- ✅ Include quantitative hints (e.g., "新增 10 個元件")
- ❌ No Jira IDs in title (use Related Links)
- ❌ Avoid vague subjects (e.g., "更新程式碼")

---

## MR Description Template

```markdown
## Summary

<!-- Bullet the major changes -->

## 相關連結

- Jira 連結:

## 如何測試

<!-- Verification steps, flows, and expected outcomes -->

## 注意事項

<!-- Special configurations or impacts -->
```

### Summary Section

**Goal:** Help reviewers quickly understand changes.

**Guidelines:**

- ✅ Use bullets, one change per line
- ✅ Explain "what" and "why"
- ✅ Distinguish additions/changes/removals
- ✅ Mention key technical decisions
- ✅ Quantify when possible (e.g., "新增 8 個子元件")
- ✅ Use **bold** for key facts
- ✅ Add bullets for new commits when updating
- ❌ No vague statements (e.g., "更新了一些程式碼")

### Related Links (相關連結)

**Include:**

- Jira issue
- Design files (Figma/Sketch)
- Related docs
- Dependent MRs
- API references
- Update with new links when MR changes

### Test Plan (如何測試)

**Goal:** Guide reviewers/QA on verification.

**Structure:**

```markdown
### 前置條件

- Dependency setup
- Service requirements
- Permissions needed

### 測試步驟

#### 情境 1: [Scenario Name]

1. Step 1
2. Step 2
3. Step 3

**預期結果**: Expected outcome

#### 情境 2: [Error Handling]

1. Step 1
2. Step 2

**預期結果**: Error message shown
```

**Guidelines:**

- ✅ Explicit steps (use ordered lists)
- ✅ State expected results
- ✅ Cover success/failure/edge cases
- ✅ List prerequisites
- ✅ Re-test after every commit
- ❌ No vague instructions (e.g., "試試看")

### Notes Section (注意事項)

**Goal:** Alert about critical considerations.

**Include:**

- Environment variable changes
- Database migrations
- Breaking changes
- Performance impact
- Security considerations
- Deployment order requirements
- Dependency upgrades
- Technical debt notes

**Guidelines:**

- ✅ Use subheadings (e.g., "### Environment", "### Breaking Changes")
- ✅ Highlight severity (use **Important**, ⚠️)
- ✅ Explain exact impact
- ✅ Re-evaluate after updates, remove stale notes

---

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

**With additional options:**

```bash
glab mr create \
  --push \
  --title "feat: 新增 XX 功能" \
  --description "..." \
  --target-branch develop \
  --assignee username \
  --reviewer reviewer1,reviewer2 \
  --label ui,enhancement \
  --remove-source-branch
```

**Common options:**

- `--push`: **[REQUIRED]** Push branch before creating MR
- `--title, -t`: MR title (Conventional Commit format)
- `--description, -d`: MR description (use template, or "-" for editor)
- `--target-branch, -b`: Target branch (e.g., develop, main)
- `--assignee, -a`: Assign to user by username
- `--reviewer`: Request review from users (comma-separated)
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

**Update specific MR:**

```bash
glab mr update 123 \
  --title "..." \
  --description "..." \
  --label +bug,-enhancement \
  --reviewer +reviewer3
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
glab mr view 123              # By MR ID
glab mr view feature/xxx      # By branch name
glab mr view --comments       # Include comments
glab mr view --web            # Open in browser
```

### List MRs

**List open MRs:**

```bash
glab mr list
glab mr list --assignee @me
glab mr list --author @me
glab mr list --label ui
```

---

## Common Issues & Fixes

### Issue 1: MR Created But Branch Not Pushed

**Problem:** `glab mr create` executed without `--push` flag, remote doesn't have the branch.

**Fix:**

- **Always use `--push` flag**: `glab mr create --push ...`
- The `--push` flag automatically pushes the branch before creating the MR
- This prevents "branch not found" errors on GitLab

### Issue 2: MR Created Without Analysis

**Problem:** Opening MR before running branch diff.

**Fix:** Always run `git log` and `git diff` first.

### Issue 3: Vague MR Description

**Problem:** Summary doesn't explain what changed.

**Fix:** Use bullets, explain decisions, provide quantitative info.

### Issue 4: Missing Test Steps

**Problem:** No verification guidance.

**Fix:** List prerequisites, explicit steps, expected results, multiple scenarios.

### Issue 5: Push Rejected (non-fast-forward)

**Error:**

```
! [rejected] feature/xxx -> feature/xxx (non-fast-forward)
```

**Fix:**

```bash
# Option 1: Pull and merge
git pull origin feature/xxx

# Option 2: Pull and rebase (recommended)
git pull --rebase origin feature/xxx

# Then push
git push
```

### Issue 6: Missing Upstream

**Error:**

```
fatal: The current branch has no upstream branch
```

**Fix:**

```bash
git push -u origin feature/xxx
```

### Issue 7: glab Authentication Error

**Error:**

```
Error: failed to get auth token
```

**Fix:**

1. Authenticate with GitLab:
   ```bash
   glab auth login
   ```
2. Follow prompts to authenticate via browser or token
3. Verify authentication: `glab auth status`

### Issue 8: Stale MR Description After Update

**Problem:** New commits pushed but description still describes old state.

**Fix:**

- Re-run `git log` and `git diff`
- Update MR description via `glab mr update`
- Note what changed since last review

### Issue 9: Ignoring Review Comments

**Problem:** Fixes pushed without replying to reviewers.

**Fix:**

- Reply to each comment explaining the fix
- Use `Resolve` only after addressing concern
- Document significant changes in Summary

---

## Best Practices

### 1. Rebase Frequently

```bash
git fetch origin
git rebase origin/develop
```

### 2. Keep MR Scope Reasonable

Refer to `mr-config.yaml` → `mr_size` for guidelines:

- ✅ Focus on single feature/fix
- ✅ Recommended: 10-30 files, 200-500 lines
- ❌ Avoid: > 1000 lines changed

### 3. Respond to Reviews Quickly

- Reply within 24 hours
- Push follow-up commits
- Explain how each comment was addressed

### 4. Keep Descriptions Current

- Re-run checklist after every push
- Update description when major changes occur
- Add new test steps
- Highlight breaking changes
- Remove outdated notes

### 5. Use Meaningful Branch Names

```bash
✅ feature/alert-component
✅ fix/badge-style-issue
✅ refactor/button-logic

❌ test
❌ my-branch
❌ branch-1
```

---

## Pre-Submit Checklist

Before creating **or updating** an MR:

- [ ] Branch diff analyzed after latest commits
- [ ] Using `--push` flag with `glab mr create` (ensures branch is pushed)
- [ ] Title uses Conventional Commit format
- [ ] Title in Traditional Chinese
- [ ] Description includes Summary
- [ ] Summary/測試/注意事項 reflect latest changes
- [ ] Detailed test steps provided
- [ ] Related links included (Jira, Figma, etc.)
- [ ] Special notes documented when needed
- [ ] Correct source/target branches set
- [ ] glab CLI authenticated and configured

---

## Prohibited Content

❌ **Never include:**

- "Generated with Claude Code" tags
- AI-generated copyright notices
- Vague descriptions (e.g., "更新程式碼")
- Statements not backed by actual changes
