---
name: autonomous-agent-orchestration
description: Coordinate an explicitly authorized implementation task through Herdr using isolated Workers and fresh-context Reviewers. Use when the user asks the main agent to own multi-agent execution or autonomous orchestration. Do not use for ordinary implementation, open-ended diagnosis, or read-only advice.
---

# Autonomous Agent Orchestration

Act as the Task Owner. Coordinate implementation and independent review without making the user relay messages between agents.

## Preconditions and authority

- Use this workflow only after the user explicitly requests implementation and multi-agent orchestration.
- This skill grants no additional authority. Repository instructions and the user's stated scope override this workflow.
- Before project work, read the repository's `AGENTS.md` and `CLAUDE.md` instruction chain.
- Read and follow the `herdr` skill before controlling panes or agents. If `HERDR_ENV` is not `1`, stop and report that Herdr orchestration is unavailable.
- Read any task-specific skill required by the repository or ticket before deciding the plan.
- Do not push, deploy, merge, publish, commit, or perform destructive operations unless separately authorized. In this repository, stop after editing for human verification before any commit unless the user already granted explicit commit authority.

## Task Owner responsibilities

The Task Owner:

- establishes the acceptance criteria from the ticket or supplied context;
- creates the smallest dependency-aware task plan;
- assigns implementation to Workers and does not implement production code itself;
- receives evidence, checks acceptance criteria, and requests missing verification;
- starts only reviewers relevant to the task;
- converts supported P0/P1 findings into bounded correction requests;
- performs final verification after review gates pass.

Do not ask the user to copy prompts, contact another agent, or make orchestration decisions. Ask the user only when work requires an irreducible product decision, credentials or permission, a separately gated external action, or a major irreversible choice.

## Worker isolation

- Use one implementation Worker at a time when agents share the same working tree.
- Use separate Git worktrees when implementation Workers must edit concurrently. Do not create worktrees unless concurrency materially shortens independent work.
- Read-only Reviewers may run concurrently.
- Track every pane and agent created by this workflow. Stop or close only resources created by the Task Owner; preserve user-owned panes and sessions.

## Waiting and observation

Waiting is not work. Do not spend model turns observing progress that Herdr can wait on.

- Never poll an agent with repeated `herdr agent get`, `herdr agent list`, `herdr pane read`, `herdr pane list`, or equivalent status checks.
- Submit work and enter Herdr's server-owned, event-driven wait in one command. This avoids the race between a separate prompt and wait:

  ```bash
  herdr agent prompt <agent> "<task>" --wait
  ```

  With the installed Herdr CLI, omitting `--until` waits for the first settled `idle`, `done`, or `blocked` state observed after submission. If states must be explicit, include all settled outcomes:

  ```bash
  herdr agent prompt <agent> "<task>" --wait \
    --until idle --until done --until blocked
  ```

- If work was already submitted, wait without polling:

  ```bash
  herdr agent wait <agent>
  ```

- Prefer an indefinite event-driven wait. Add `--timeout` only when the task has a real operational deadline, not to create periodic progress checks.
- After the wait returns:
  - `idle` or `done`: use `herdr agent read` once to retrieve the delivery;
  - `blocked`: use `herdr agent read` once to inspect the exact approval or question, resolve it, then resume with `herdr agent prompt ... --wait` or `herdr agent wait`;
  - timeout or command error: inspect state/output once, choose a recovery action, then return to event-driven waiting.
- Use `agent read` for delivery or blocker retrieval, never as a progress monitor. Do not request percentage-complete or intermediate status reports from Workers or Reviewers.

The Worker does not need to send a separate message to the Task Owner. Herdr detects the lifecycle transition through its server/socket event stream and wakes the waiting command.

## Worker prompt contract

Every implementation prompt sent to a Worker must invoke `/implement` and identify exactly one source of scope:

### Ticket-backed task

```text
/implement <ticket-identifier-or-URL>

Role: Worker
Task: <bounded assignment within the ticket>
Acceptance criteria: <criteria this Worker owns>
Repository constraints: Read and follow AGENTS.md and CLAUDE.md. Repository-specific rules override generic /implement defaults. Do not commit unless the Task Owner explicitly authorizes it.
Return the Worker Delivery Contract below with concrete evidence.
```

Prefer the canonical ticket identifier or URL, such as a Linear issue identifier, when the ticket is the source of truth. Do not paraphrase away requirements that the Worker can fetch from the ticket.

### Context-backed task

```text
/implement

Role: Worker
Task context: <self-contained problem, expected behavior, relevant paths, and constraints>
Acceptance criteria: <observable completion conditions>
Out of scope: <explicit exclusions>
Repository constraints: Read and follow AGENTS.md and CLAUDE.md. Repository-specific rules override generic /implement defaults. Do not commit unless the Task Owner explicitly authorizes it.
Return the Worker Delivery Contract below with concrete evidence.
```

Use context-backed prompts only when no authoritative ticket exists. If neither a ticket nor enough context defines observable acceptance criteria, request the missing scope from the user before starting a Worker.

## Worker Delivery Contract

```text
TASK:
STATUS: complete | blocked

CHANGED:
- ...

VERIFICATION:
- build:
- runtime:
- console:
- screenshots:
- tests:

DECISIONS:
- ...

OPEN_ISSUES:
- ...
```

Workers must stay within their assignment, run risk-proportionate verification, and report observable evidence. They must not declare the overall task complete or send questions directly to the user. A blocked Worker reports the exact missing decision or permission to the Task Owner.

For this repository, `/implement`'s generic test and commit defaults do not override `CLAUDE.md`: do not create automated tests merely for feature verification, do not treat `npm test` as a completion signal, and do not commit before the repository's human verification gate.

## Review loop

After the Task Owner verifies the Worker delivery against the full acceptance criteria, start only relevant Reviewers, such as product/UX, visual design, frontend architecture, runtime/browser, accessibility, security, or performance.

Every prompt that starts a Reviewer, including every fresh re-review round, must invoke `/code-review` rather than `/implement`:

```text
/code-review <base-branch-or-fixed-point>

Role: Reviewer
Review scope: <ticket identifier or self-contained acceptance criteria>
Review target: <complete current diff or fixed revision>
Repository constraints: Read and follow AGENTS.md and CLAUDE.md. Review only; do not modify files, commit, push, deploy, merge, publish, or operate the ticket tracker.
Report only P0, P1, and P2 findings using the severity contract below.
```

Choose the `/code-review` fixed point that represents the implementation task's actual base, such as its target branch or merge-base. Do not use `/implement`, even when the Reviewer is inspecting an implementation ticket. Worker correction prompts remain `/implement` prompts under the Worker prompt contract.

Each review round must use a fresh Reviewer with only:

- the original ticket or context and acceptance criteria;
- the complete current diff or fixed revision under review;
- applicable repository rules;
- relevant verification evidence.

Do not provide earlier reviewer conclusions, Worker defenses, suspected findings, or the desired verdict. Reviewers are read-only and report only:

```text
P0
- <blocking failure with concrete evidence>

P1
- <business-quality or material technical issue with concrete evidence>

P2
- <optional polish>
```

P0 and P1 findings must identify the affected behavior or location, reproduction or reasoning, and expected result. P2 does not block completion.

When supported P0/P1 findings exist:

1. consolidate them into bounded correction requirements;
2. send the correction to the responsible Worker using `/implement` with the same ticket or updated self-contained context;
3. stop the old Reviewer created by this workflow;
4. verify the corrected delivery;
5. start a fresh Reviewer to inspect the complete current result, not only the previous findings.

Stop and request a Human Gate instead of looping when the same material finding fails to improve across two correction rounds, reviewers materially contradict each other, a correction expands product scope, or progress requires new authority.

## Completion gate

The task is complete only when:

- every acceptance criterion has evidence;
- relevant final build/runtime/interaction checks have passed according to repository capabilities;
- continuous or animated behavior has been checked at meaningful intermediate states when applicable;
- P0 equals zero;
- P1 equals zero.

P2 may remain. Do not iterate solely to remove P2.

Report only:

- completed tasks;
- principal changes;
- verification results;
- reviewer results;
- remaining P2 items;
- pending Human Gates.
