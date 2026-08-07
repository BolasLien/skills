---
name: handoff-audit
description: Create, update, intake, and audit human-readable coding-work handoffs under docs/handoffs/<task-slug>.md. Use when transferring one or more concurrent tasks between engineers or coding agents, resuming a specific task, or keeping task handoffs current after meaningful work.
---

# Handoff Audit Skill

## Purpose

Maintain one handoff file per independently transferable coding task.

Default layout:

```text
docs/handoffs/
├── README.md
├── autolayout-runtime-attributes.md
├── editorbox-refactor.md
└── typescript-migration.md
```

Each task handoff is written as if a senior engineer is explaining that specific work to another engineer who joins the project today.

The handoff is not:

- a chronological log
- a Git history duplicate
- a commit inventory
- a requirement database
- a verification database
- an audit report
- a repository-wide status document containing unrelated tasks

The reader should quickly understand:

1. what this task is about
2. where this task stands now
3. how the relevant system currently works
4. which task-specific decisions must not be reinterpreted
5. what should happen next for this task
6. where to look in the code

Repository state is the source of truth for implementation.
Git history is the source of truth for historical code changes.
A task handoff is the source of truth for the current shared understanding of that task.
`docs/handoffs/README.md` is only the navigation index for available task handoffs.

## Task identity and file selection

### One independently transferable task, one handoff

Use separate handoffs when work can be paused, resumed, assigned, verified, or completed independently.

Create separate files for work that has a different:

- goal or acceptance boundary
- implementation area
- decision set
- next action
- completion state
- likely assignee

Do not split a task merely because it has several implementation steps. Keep one handoff when the steps contribute to one coherent delivery goal and must be understood together.

### Canonical path

Use:

```text
docs/handoffs/<task-slug>.md
```

The slug must be:

- lowercase
- kebab-case
- specific enough to distinguish parallel work
- based on the task goal, not the agent name, date, branch alone, or generic words such as `current`, `work`, `task`, or `handoff`

Good:

```text
docs/handoffs/autolayout-runtime-attributes.md
docs/handoffs/save-button-event-decoupling.md
docs/handoffs/javascript-to-typescript-migration.md
```

Bad:

```text
docs/handoff.md
docs/handoffs/current.md
docs/handoffs/feature.md
docs/handoffs/2026-08-06.md
```

### Resolve the target before reading or writing

Before `create`, `update`, `intake`, or `audit`:

1. Determine the task identity from the user's request, current conversation, branch context, existing handoff titles, and repository evidence.
2. Inspect `docs/handoffs/README.md` and existing `docs/handoffs/*.md` when available.
3. Select the single handoff whose goal matches the current task.
4. Do not update a handoff merely because it is the newest file.
5. Do not merge unrelated tasks into one file because they share a branch or session.

When exactly one task is clearly implied, proceed without asking.
When several handoffs plausibly match and repository evidence cannot resolve the target, stop and report the candidate paths instead of editing the wrong file.

### Legacy migration

If only `docs/handoff.md` exists:

1. Read it and determine whether it describes one coherent task or several unrelated tasks.
2. For one task, move or rewrite it into `docs/handoffs/<task-slug>.md`.
3. For several tasks, split only when each task has a distinct current goal, state, and next action.
4. Do not leave two active canonical copies of the same handoff.

## Handoff index

Maintain `docs/handoffs/README.md` as a concise navigation index.

It should contain one row or bullet per active or intentionally retained handoff:

- task name
- relative link
- one-sentence purpose
- status: `active`, `blocked`, `ready-for-handoff`, `ready-for-delivery`, or `completed`
- last updated date

Example:

```md
# Work Handoffs

| Task | Purpose | Status | Updated |
|---|---|---|---|
| [AutoLayout runtime attributes](./autolayout-runtime-attributes.md) | Stabilize session-only AutoLayout state and runtime behavior. | ready-for-delivery | 2026-07-14 |
| [EditorBox refactor](./editorbox-refactor.md) | Preserve button behavior while separating EditorBox responsibilities. | active | 2026-08-06 |
```

Index rules:

- Keep descriptions short; do not duplicate the handoff body.
- Update the matching row after create or update.
- Do not rewrite unrelated rows unless their link is broken or clearly stale.
- `completed` handoffs may remain for discoverability, but must not be presented as active.
- The index is not a project dashboard or work log.

## Core principles

### Build a mental model before listing details

The task handoff must be readable from top to bottom.

Explain the work before implementation details. Explain the current system before next steps. Give the reader one coherent current model.

### Preserve consequences, not history

Do not preserve rejected approaches merely because they were discussed.

Keep historical context only when its consequence still constrains future work.

### One canonical place per fact

Do not repeat the same fix across requirements, decisions, verification, current state, risks, and audit sections.

### Current state describes the phase, not the feature catalog

The current-state section answers: **what phase is this task in now?**

Do not mix the state of other concurrent tasks into this section.

### Code map means investigation entry points

Organize it by task or responsibility. Prefer the smallest useful set of entry-point files.

### One next step is one independently verifiable task

Each next step must have one coherent goal and one verification boundary.

### Completed means implemented and behaviorally verified

A work item may be described as completed only when:

1. the intended change exists in the repository
2. the required observable behavior has been verified with evidence

Build, lint, typecheck, or plausible code do not prove behavioral correctness.

## Modes

Select the mode from the user's intent:

- `create`: establish a new task handoff
- `update`: keep one existing task handoff current
- `intake`: take over one specific task from its handoff before implementation
- `audit`: inspect one specific task handoff for accuracy, readability, and sufficiency

If the user explicitly names a mode, use it.

---

# Mode: Create

## Goal

Create a concise, human-readable explanation of one independently transferable task.

## Procedure

1. Resolve the task identity and canonical slug.
2. Check existing handoffs and the index to avoid creating a duplicate task file.
3. Read the current conversation or task context.
4. Inspect relevant plans/specs only when they affect this task.
5. Inspect `git status`, relevant diffs, relevant commits, and current source.
6. Separate task-specific changes from unrelated dirty work in the same repository or branch.
7. Draft `docs/handoffs/<task-slug>.md` using `templates/handoff-template.md` as a guide.
8. Add or update the matching entry in `docs/handoffs/README.md`.
9. Run the readability, task-boundary, and accuracy audit.

## Create rules

- Do not create a second handoff for an existing task under a slightly different name.
- Do not absorb unrelated concurrent work into the new handoff.
- Mention shared infrastructure only when it directly affects this task.
- Start with a plain-language explanation of what this task is.
- Include only current decisions that affect future implementation.
- Include only unresolved risks and unknowns.
- Use Git for detailed history; do not reproduce it.

---

# Mode: Update Existing Handoff

## Goal

Keep one selected task handoff clear, current, and human-readable without modifying other task handoffs.

Updating does not mean appending. Re-understand the selected task and rewrite its handoff where necessary.

## Procedure

### 1. Resolve and lock the target task

Identify the exact handoff path before editing.

Confirm that its title, goal, current state, and code area match the current task. Treat unrelated repository changes as out of scope even when they are on the same branch or in the same session.

### 2. Read the selected handoff completely

Understand its narrative and mental model before editing it.

Do not preload every other handoff. Read another handoff only when a shared dependency or task-boundary conflict requires it.

### 3. Inspect what changed for this task

Review available evidence:

- current conversation or task context
- user corrections and decisions
- task-relevant `git status` entries
- task-relevant `git diff` and staged diff
- relevant commits since the previous update
- verification actually performed
- current repository state

Do not import unrelated dirty files or commits into this handoff.

### 4. Identify meaningful task state changes

Look for:

- new or corrected requirements
- changed architectural decisions
- completed work
- newly discovered behavior
- failed approaches whose consequences still constrain future work
- new verification evidence that changes status
- new or resolved risks
- changed next steps

### 5. Update the mental model first

If the system now works differently, rewrite the explanation of how it works. Do not preserve an outdated explanation and append corrections below it.

### 6. Rewrite the current state

Describe the phase of this task, not the repository as a whole and not a catalog of completed features.

Remove items that are no longer active. Move completed work out of next steps.

### 7. Rewrite active decisions and constraints

Keep only decisions that still affect future implementation of this task.

### 8. Rewrite next steps

Each next step must be one independently verifiable task within this handoff's goal.

If a proposed next step belongs to another independently transferable goal, create or point to a separate handoff instead of expanding this one.

For each next step, explain:

- what remains
- why it matters
- how to verify it
- what means complete
- when to stop instead of guessing

### 9. Clean risks and unknowns

Remove resolved and purely historical risks. Keep only conditions that can still affect this task.

### 10. Refresh the code map

List investigation entry points for this task only.

### 11. Rebuild the document as one explanation

The result must feel like a fresh handoff written for today's task state.

### 12. Update the index entry

Refresh the matching task's purpose, status, and updated date in `docs/handoffs/README.md`.

Do not alter unrelated entries.

## Update invariants

```text
resolve one task
→ understand its new state
→ rebuild its mental model
→ rewrite its current narrative
→ exclude unrelated work
→ remove stale and duplicate information
→ remove resolved risks and completed next steps
→ update its index row
→ audit readability, task boundary, and accuracy
```

Mandatory rules:

- Do not update the newest handoff by default.
- Do not merge concurrent tasks into one handoff.
- Do not append an update log.
- Do not preserve stale text for historical completeness.
- Do not duplicate Git history.
- Do not repeat the same fact across multiple sections.
- Do not keep resolved risks active.
- Do not keep completed work in next steps.
- Each next step must be independently verifiable.
- The code map must identify task-specific entry points.
- Rewrite sections when necessary. Updating does not mean appending.

---

# Mode: Intake Existing Handoff

## Goal

Build an accurate mental model of one selected task before modifying code.

## Procedure

1. Resolve the intended task and exact handoff path from the request and index.
2. Read that handoff completely.
3. Explain the task goal, current phase, system behavior, active constraints, next step, risks, and code entry points.
4. Inspect the repository without modifying it:
   - task-relevant `git status`
   - relevant `git diff`
   - relevant recent commits when needed
   - files referenced by the handoff
   - available verification evidence
5. Compare the handoff's claims with repository evidence.
6. Read another task handoff only when a shared dependency or boundary conflict materially affects this task.
7. Produce a concise intake report before implementation.

## Intake rules

- Do not modify code during intake.
- Do not silently switch to another handoff because it is newer.
- Do not treat unrelated dirty files as part of the selected task.
- Do not assume the handoff is automatically correct.
- When handoff and repository conflict, report the conflict explicitly.
- Do not begin implementation until intake is complete.

---

# Mode: Audit

## Goal

Check whether one selected task handoff is accurate enough to trust, readable enough to use, and correctly separated from concurrent work.

## Evidence checks

Check for:

- claims that conflict with current source
- completed claims without implementation or behavioral evidence
- missing active constraints or unresolved work
- next steps that are already complete
- risks that have already been resolved
- unrelated task details included because they share a branch or session
- task-relevant changes omitted because they were mistaken for unrelated work

## Information quality checks

Check for:

- duplicate, contradictory, or stale information
- historical information incorrectly presented as active
- Git history duplicated in prose
- an opening that assumes too much prior context
- a current-state section that repeats the feature catalog
- next steps that group independently verifiable procedures
- a code map that is a file inventory instead of entry points
- a task boundary broad enough to contain multiple independently transferable goals

## Index checks

Check that:

- the selected handoff has exactly one correct index entry
- its link, title, purpose, status, and updated date match the file
- no duplicate handoff appears under another slug
- unrelated index entries were not overwritten

## Audit action

When the user asks to audit only, report findings without changing files unless they also ask to update or fix them.

When audit is part of `create` or `update`, repair every discovered problem directly and rerun the audit.

---

# Recommended handoff shape

Use `templates/handoff-template.md` as a writing guide.

The usual reading order is:

1. what this task is about
2. where this task is now
3. how the relevant system currently works
4. decisions and constraints that must not be reinterpreted
5. what should happen next
6. where to look in the code
7. current risks and unknowns

Headings may change to fit the task. Do not force a database-like schema.

## Readability and boundary test

The handoff is not complete until a new engineer can accurately answer:

- Which exact task does this file describe?
- What is explicitly outside this handoff?
- What phase is this task in?
- How does its relevant system work?
- What is settled and must not be reinterpreted?
- What remains and what should happen next?
- Where should I start reading in the code?

Also ask:

- Could this handoff be assigned independently from the repository's other active work?
- Does it contain unrelated changes merely because they share a branch or session?
- Does another handoff describe the same task under a different slug?
- Is each important fact in one canonical place?
- Is each next step independently verifiable?

## Stop conditions

Stop and state the limitation instead of inventing facts when:

- the intended task or handoff path cannot be resolved safely
- repository access is unavailable for a repository-grounded claim
- task context is materially incomplete
- runtime behavior cannot be verified
- required credentials, services, fixtures, or environments are missing
- handoff and repository evidence conflict and the conflict cannot be resolved

## Final response

After `create` or `update`, report only:

1. task handoff path
2. index path
3. meaningful current-state or mental-model changes reflected in the handoff
4. up to three unresolved evidence gaps that still affect this task

After `intake`, provide the intake report and name the handoff path used.

After `audit`, provide the highest-impact findings and name the handoff path audited.
