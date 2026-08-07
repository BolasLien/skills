---
name: subagent-go
description: Use when the user provides a clear, bounded task specification (e.g. dependency cleanup, config changes, migrations, refactors) and asks the main session to direct subagents, stay out of the implementation process, and only return the final, independently verified result. Not for open-ended debugging, exploration, or design work — see Applicability.
---

# Subagent Go

## Purpose

The main session governs and audits. Subagents execute.

Core principles:

- Implementation completion is not task completion.
- A task is complete only after the main session independently verifies the evidence.
- Subagents must not reinterpret requirements, expand scope, or weaken verification standards.
- When evidence is insufficient, an undefined situation appears, or an acceptance criterion fails, the correct result is `BLOCKED`, not an improvised fix.

## Applicability

Use this skill only when all of the following are true:

1. The user has provided a clear task specification, or the request can be safely reduced to one before execution.
2. The modification scope can be defined in advance.
3. The execution sequence can be described in advance.
4. Completion can be verified through commands, diffs, tests, builds, runtime evidence, or other concrete artifacts.
5. The user wants the main session to direct the work while they remain outside the intermediate process.

Do not use this skill for:

- Runtime bugs whose root cause is unknown.
- Exploratory debugging that requires repeated hypothesis and experiment cycles.
- Architecture work before a solution has been selected.
- Product, UX, or design tasks whose requirements may change during execution.
- Tasks without objective completion evidence.

For these cases, complete an investigation first, then convert the findings into a bounded execution task.

# Role Boundaries

## Main Session: Director and Auditor

The main session is responsible for:

- Verifying the task assumptions.
- Reducing the request into a bounded specification.
- Defining scope, constraints, blocked conditions, and acceptance criteria.
- Creating the task brief.
- Dispatching the implementation subagent.
- Independently verifying the implementation evidence.
- Deciding whether commit, push, or merge request creation is allowed.
- Reporting only the audited final result to the user.

The main session must not:

- Edit project files.
- Perform the implementation itself.
- Directly fix issues left by a subagent to save time.
- Accept a subagent's `DONE` result without independent verification.

The main session may run read-only inspection and audit commands, including:

- `rg`
- `find`
- `cat`
- `git status`
- `git diff`
- `git log`
- `git show`
- `git branch`
- `git rev-parse`

The main session must not run commands that mutate project files, Git state, dependencies, or build outputs.

## Implementation Subagent

The implementation subagent is responsible for:

- Creating the task branch when authorized.
- Modifying only the files permitted by the brief.
- Running installation, tests, builds, and verification.
- Capturing complete evidence.
- Stopping when an undefined, suspicious, or out-of-scope condition appears.

The implementation subagent must not:

- Redefine the task.
- Expand the file scope.
- Fix unrelated issues to make verification pass.
- Lower an acceptance standard.
- Commit, push, or create a merge request unless the brief explicitly authorizes it.

## Git Finalization Subagent

The Git finalization subagent is responsible only for:

- Staging approved files.
- Creating the commit.
- Pushing only when explicitly authorized.
- Creating a merge request only when explicitly authorized.

The Git finalization subagent must not:

- Modify project files.
- Run formatters.
- Fix tests or builds.
- Add, restore, stash, checkout, or delete files outside the approved scope.
- Use `git add .`.
- Switch branches.
- Split or add commits unless explicitly instructed.

# Workflow

## Phase 0: Preflight

### 0.1 Verify the Task Specification

Verify every material claim before execution. Do not rely on memory.

Depending on the task, inspect:

- Static imports and `require` calls.
- Dynamic imports.
- Package scripts.
- Build, test, and lint configuration.
- CI configuration.
- Dockerfiles.
- Shell scripts.
- Code generation.
- Runtime commands.
- Relevant Git history.
- Known active related branches.

Commented code is not current usage evidence, but it may be recorded as a risk signal.

### 0.2 Inspect the Working Tree

Record:

```bash
git branch --show-current
git status --short
git rev-parse HEAD
```

Rules:

- If staged or tracked changes exist outside the approved scope, return `BLOCKED`.
- If only out-of-scope untracked files exist, do not touch them and continue.
- Never automatically stash, restore, checkout, or clean the working tree.
- Record the base commit.

### 0.3 Resolve Decisions

Resolve all of the following before implementation:

- Final goal.
- Allowed files and directories.
- Explicitly prohibited actions.
- Acceptance criteria.
- `BLOCKED` conditions.
- Whether branch creation is authorized.
- Whether commit is authorized.
- Whether push or merge request creation is authorized.

When the user has explicitly said they will not participate in the process:

- Proceed with decisions that are safely determined by existing rules.
- Stop instead of guessing when a decision cannot be made safely and could produce destructive or irreversible effects.

## Phase 1: Create the Task Brief

Write the final task brief to the session scratchpad.

The brief is the sole task-specification source for this execution. If it conflicts with repository instructions, system constraints, or observed evidence, return `BLOCKED`. Do not resolve the conflict independently.

The brief must contain the following sections.

### Context

Include:

- Task background.
- Base commit.
- Current branch.
- Verified facts.
- Explicit user decisions.

For Figma-driven or otherwise visual-only work, read `docs/agents/figma-visual-delivery.md` before drafting the brief — it is the single source for precedence, checklist, and baseline rules — and fold its constraints into Scope, Constraints, and Acceptance Criteria below.

### Goal

Describe the required end state.

Do not describe only actions. Define a result that can be verified.

### Scope

Define:

- Files that may be modified.
- Files that may be added or deleted.
- Explicit exclusions.

### Constraints

At minimum:

- Do not modify out-of-scope files.
- Do not run formatters.
- Do not commit.
- Do not push.
- Do not reinterpret the task.
- Do not fix unrelated problems to make verification pass.
- Do not touch existing untracked files.
- For visual work: stay within the brief's declared allowed selectors/states and test authorization, per `docs/agents/figma-visual-delivery.md`.

### Ordered Steps

Define a strict execution order.

Each step must include:

- The required action.
- The expected result.
- The verification method.
- The conditions that require `BLOCKED`.

### Acceptance Criteria

Every acceptance criterion must map to concrete evidence, such as:

- A named test exits with code 0.
- `git diff --stat` contains only approved files.
- A specified search returns no results.
- A production build succeeds.
- Baseline and after-build comparisons meet a defined condition.
- Required runtime evidence is present.

For visual work, list visual-acceptance and runtime-regression criteria as separate items per `docs/agents/figma-visual-delivery.md`. Completion check: the report's evidence section has both, and neither is derived from the other.

### Report Contract

Write the full report to:

```text
$SCRATCHPAD/task-report.md
```

The report must include:

- The steps actually performed.
- Every important command.
- Command results and exit codes.
- The modified file list.
- `git status --short`
- `git diff --stat`
- Verification evidence.
- Unresolved items.
- Concerns.
- Final status.

The subagent response must contain only:

```text
STATUS: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
SUMMARY: <one-line summary>
REPORT: <report path>
```

## Phase 2: Dispatch the Implementation Subagent

Keep the dispatch prompt minimal.

Include only:

- One sentence of task context.
- The brief path.
- An instruction to read the brief completely before acting.
- An instruction to follow it exactly.
- Any relevant timeout guidance.

Do not paste the brief into the dispatch prompt.

Example:

```text
Execute the approved dependency-cleanup task.
Read this brief completely before acting and follow it exactly: <brief-path>
Return BLOCKED for any undefined, suspicious, or out-of-scope condition. Do not improvise.
Use a sufficient timeout for long-running production builds.
```

## Phase 3: Independent Audit

A `DONE` response is not proof of completion.

The main session must obtain evidence independently.

### 3.1 Read the Report

Compare the report against the brief:

- Were all ordered steps executed?
- Does every acceptance criterion have evidence?
- Were any steps skipped?
- Were unauthorized files modified?
- Were concerns minimized or omitted?

### 3.2 Re-obtain Working Tree Evidence

At minimum, run:

```bash
git branch --show-current
git status --short
git diff --stat
git diff
```

Run additional read-only checks when needed:

- Search for references.
- Recount files or entries.
- Verify package or configuration contents.
- Verify the base commit.
- Compare reported file lists against the actual diff.

### 3.3 Compare Claims Against Evidence

Do not approve the result when any of the following is true:

- Reported counts do not match file lists.
- The report does not match the actual diff.
- The subagent claims N files changed, but the diff shows more.
- A test is reported as passing without the command, result, or exit code.
- A no-bundle-impact claim lacks baseline and comparison evidence.
- An unused-dependency claim lacks a complete usage-surface check.

### 3.4 Status Handling

#### DONE

All acceptance criteria passed and no unresolved concern remains.

The task may proceed to Git finalization.

#### DONE_WITH_CONCERNS

The main acceptance criteria passed, but risk or uncertainty remains.

The main session must determine whether the concern violates an acceptance criterion.

- If it does not and existing rules allow acceptance, approve it.
- If it cannot be resolved from existing rules, stop and do not commit.
- If it violates an acceptance criterion, treat it as `BLOCKED`.

#### NEEDS_CONTEXT

Execution requires missing context.

Only provide context within the existing task definition. Do not redesign the task.

Allow at most one redispatch for the same phase.

#### BLOCKED

Return `BLOCKED` when any of the following occurs:

- A task assumption is false.
- The working tree is unsafe.
- The brief does not define the situation.
- Verification fails.
- The approved scope is insufficient.
- Repository instructions conflict with the brief.
- Completion requires expanding the modification scope.
- The subagent improvised, exceeded scope, or fixed unrelated issues.

Do not ignore, minimize, or directly repair a blocked condition.

Allow at most one redispatch for the same phase. If it remains blocked, stop and report the result to the user.

## Phase 4: Git Finalization

Run this phase only after the main session has independently approved the implementation.

### Commit Rules

The Git finalization subagent must follow these rules:

1. Use an English commit message.
2. Use Conventional Commits.
3. Do not run formatters.
4. Use only `git add <approved files>`.
5. Never use `git add .`.
6. Do not add, restore, stash, checkout, or delete out-of-scope files.
7. Do not push.
8. Do not switch branches.
9. Create one commit.
10. Report:
    - Commit hash.
    - Full commit message.
    - Every Git command executed.

The main session must provide:

- What changed.
- Why it changed.
- Approved scope.
- Verification evidence.
- Intentionally retained items and their rationale.

### Post-Commit Audit

The main session must run:

```bash
git log --oneline -2
git show --stat --oneline HEAD
git status --short
```

Verify that:

- The commit contains only approved files.
- Out-of-scope untracked files are unchanged.
- No formatter or unrelated reordering occurred.
- The commit message accurately describes the change.

## Phase 5: Push and Merge Request

Run this phase only when explicitly authorized by the user.

Rules:

- Push only the current task branch.
- Do not modify files.
- Do not create another commit.
- Use an English merge request title and description.
- Base the merge request content on the audited what, why, scope, verification, and risks.
- On authentication or remote errors, return `BLOCKED`. Do not guess or switch hosts or remotes.

After creation, the main session must read the merge request and verify:

- State.
- Source branch.
- Target branch.
- Title.
- Description.
- Commit.
- Change scope.

# Build-Impact Verification

When the task claims zero bundle impact, build success alone is insufficient.

## Baseline

1. Record:
   - Node version.
   - npm version.
   - Lockfile hash.
   - Base commit.
2. Perform a clean install using the baseline lockfile.
3. Remove previous build output.
4. Run the production build.
5. Save the output to the scratchpad.
6. Run the same build again.
7. Compare the two outputs to establish build determinism.

## After

1. Complete the approved change.
2. Perform a clean install using the modified lockfile.
3. Remove previous build output.
4. Run the production build.
5. Compare the result against the baseline.

## Acceptance Standard

Prefer a byte-identical comparison:

```bash
diff -r <baseline-dist> <after-dist>
```

Zero output is required to claim byte identity.

If the baseline build is not deterministic:

- Do not claim byte identity.
- Use webpack stats or an equivalent structured build output.
- Compare at least:
  - Entrypoints.
  - Module set.
  - Chunk composition.
  - Emitted assets.
  - Asset sizes.
- Explicitly state that the evidence is weaker than a byte-identical comparison.

# Dependency-Cleanup Verification

Before declaring a package unused, inspect at least:

- Static imports.
- `require` calls.
- Dynamic imports.
- Package scripts.
- Webpack, Babel, ESLint, and test configuration.
- CI.
- Dockerfiles.
- Shell scripts.
- `npx` and `npm exec` usage.
- Code-generation commands.
- Runtime commands.
- Known active related branches.

Do not compare lockfiles using only `name@version`.

Compare at least:

- Package path.
- Name.
- Version.
- Resolved source.
- Integrity.
- Dependencies.
- Optional dependencies.
- Peer dependencies.
- Development and optional flags.

When claiming that transitive dependencies can also be removed, use a dependency graph to prove they are no longer referenced by another root dependency.

# Red Flags

Stop immediately when any of the following occurs:

- The main session edits project files.
- The main session directly fixes an implementation issue.
- A subagent expands scope.
- A subagent weakens verification.
- A subagent fixes unrelated issues to force verification to pass.
- Reported counts, lists, and diffs do not match.
- A dependency is removed without checking the complete usage surface.
- Byte identity is claimed without establishing build determinism.
- A `DONE` result proceeds directly to commit without audit.
- The Git finalization subagent uses `git add .`.
- A formatter modifies files outside the approved scope.
- Out-of-scope tracked changes are stashed, restored, checked out, or overwritten.
- The same phase is redispatched more than once.

# Final Report

Report only the result independently verified by the main session:

- Completion status.
- Actual modifications.
- Verification results.
- Commit hash.
- Merge request link or number.
- Concerns or blocked reason.
- Explicitly unperformed actions.

Do not merely repeat the subagent report.
