---
name: implement-review-loop
description: Own an explicitly authorized implementation task end-to-end, implement directly in the primary agent, and use fresh independent reviewers for quality control. Use when the user has already discussed the requirement with the primary agent and wants it to proceed autonomously without delegating implementation to another worker. Do not use for read-only advice, open-ended diagnosis, or tasks that explicitly require multi-worker parallel execution.
---

# Implement Review Loop

Act as the Primary Agent. Own the task from clarified requirement through implementation, verification, independent review, correction, and final report.

The user should not relay messages between agents.

## Preconditions and authority

- Use this workflow only after the user explicitly requests implementation, either directly or by invoking the `implement` skill. Invocation authorizes edits only within the described scope; it does not authorize commit or other external mutations.
- Repository instructions and the user's stated scope override this workflow.
- Before project work, read the repository's `AGENTS.md` and `CLAUDE.md` instruction chain when present.
- Read and follow the `herdr` skill before controlling reviewer panes or agents. If `HERDR_ENV` is not `1`, stop and report that the review workflow is unavailable.
- Read any task-specific skill required by the repository or ticket.
- Do not push, deploy, merge, publish, commit, or perform destructive operations unless separately authorized.
- Preserve any repository-specific human verification or commit gate.

## Primary Agent responsibilities

The Primary Agent:

- retains the requirement context already established with the user;
- establishes observable acceptance criteria;
- creates the smallest dependency-aware implementation plan;
- implements production changes directly;
- runs risk-proportionate verification;
- starts only reviewers relevant to the task;
- evaluates reviewer findings against the task and repository constraints;
- fixes supported P0/P1 findings directly;
- repeats fresh review until the completion gate is satisfied;
- performs final verification and reports the result.

Do not delegate implementation merely to preserve role separation.

Use another implementation agent only when one of these is true:

- independent work can materially benefit from parallel execution;
- a clearly specialized capability is required;
- the current context is too large to safely continue;
- the user explicitly requests multi-worker orchestration.

In those cases, switch to the dedicated multi-agent orchestration workflow instead of partially mixing both models.

## Implementation loop

1. Confirm the current scope from the ticket or established conversation context.
2. Derive observable acceptance criteria.
3. Implement directly.
4. Verify the implementation locally.
5. Start relevant independent Reviewers.
6. Read reviewer findings.
7. Fix all supported P0/P1 findings directly.
8. Terminate the old Reviewers and close only their workflow-created panes.
9. Start fresh Reviewers with clean context.
10. Repeat until P0 = 0 and P1 = 0.
11. Run final verification.
12. Report completion and remaining P2 items.

Do not iterate solely to eliminate P2.

## Reviewer strategy

Reviewers are independent, read-only quality gates.

Choose only reviewers relevant to the task, such as:

- product / UX;
- visual design;
- frontend architecture;
- runtime / browser behavior;
- accessibility;
- security;
- performance;
- Three.js / WebGL;
- domain-specific visual or interaction quality.

Run at least one general engineering Reviewer for every non-trivial implementation. A purely mechanical, low-risk change may skip independent review only when the Primary Agent records why review is not useful and reports the review result as `N/A`.

Read-only Reviewers may run concurrently.

## Fresh-context review

Every review round must use a fresh Reviewer.

Each Reviewer receives only:

- the original ticket or current task context;
- the acceptance criteria;
- the complete current diff or current implementation state;
- applicable repository rules;
- relevant verification evidence.

Do not provide:

- previous reviewer conclusions;
- previous defenses or explanations;
- suspected findings;
- the desired verdict;
- summaries that bias the Reviewer toward checking only earlier defects.

A new Reviewer must inspect the complete current result.

## Reviewer contract

Reviewers must not modify production code.

They report only:

```text
P0
- <release-blocking failure with concrete evidence>

P1
- <business-quality or material technical issue with concrete evidence>

P2
- <optional polish>
```

Definitions:

- P0: cannot reasonably ship; core behavior, correctness, safety, or critical usability is blocked.
- P1: materially below the requested commercial or engineering quality bar and must be fixed before completion.
- P2: non-blocking polish or follow-up improvement.

Every P0/P1 must identify:

- affected behavior or location;
- concrete evidence or reproduction;
- expected result.

P2 never blocks completion.

## Herdr reviewer rules

The Primary Agent controls reviewer agents directly through Herdr.

The user must never be asked to:

- copy a reviewer prompt;
- contact a reviewer;
- relay findings;
- decide which reviewer runs next.

The Primary Agent must:

- create a fresh workflow-owned pane for each Reviewer;
- start the Reviewer;
- send the complete review prompt;
- wait for completion;
- read the result;
- terminate the old Reviewer and close its workflow-created pane after retrieving the result;
- start a fresh Reviewer for re-review.

Herdr `agent stop` is not assumed to exist. End the agent through supported agent controls, then close only the pane created by this workflow. Never close or repurpose a user-owned pane.

Every review prompt must be self-contained and use this shape:

```text
Role: Independent read-only Reviewer
Original task: <ticket identifier or self-contained task context>
Acceptance criteria: <observable criteria>
Review target: Inspect the complete current working-tree and index diff against <fixed-point>, including uncommitted changes.
Repository constraints: Read and follow AGENTS.md and CLAUDE.md. Review only; do not modify files, commit, push, deploy, merge, publish, or operate the issue tracker.
Verification evidence: <relevant commands and runtime evidence>

Inspect the complete result independently. Report only P0, P1, and P2 findings under the severity contract in this skill. Every P0/P1 must include the affected behavior or location, concrete evidence or reproduction, and expected result.
```

Do not invoke another implementation or review orchestration skill from inside the Reviewer. In particular, do not use a review workflow that ignores uncommitted changes or starts nested agents. The Herdr-managed Reviewer itself is the independent review boundary.

Do not repeatedly poll reviewer state with `herdr agent get`, `herdr agent list`, pane reads, or equivalent progress checks.

Prefer Herdr's event-driven waiting primitives.

When assigning review:

```bash
herdr agent prompt <reviewer> "<review prompt>" --wait
```

If the review was already submitted:

```bash
herdr agent wait <reviewer>
```

Use reviewer output retrieval only after Herdr reports completion or blocking.

Waiting is not review work. Do not spend model turns observing progress that Herdr can wait on.

## Correction loop

When supported P0/P1 findings exist:

1. consolidate findings into bounded correction requirements;
2. reject findings that conflict with the source requirement or repository rules, documenting the reason internally;
3. fix supported P0/P1 directly;
4. rerun relevant local verification;
5. terminate the old Reviewer and close its workflow-created pane;
6. start a fresh Reviewer;
7. review the complete current result again.

Do not ask the previous Reviewer to validate its own findings after correction.

## Loop safety

Stop and request a Human Gate instead of continuing automatically when:

- the same material P0/P1 fails to improve across two correction rounds;
- reviewers materially contradict each other and the conflict cannot be resolved from the source requirements;
- a correction would expand product scope;
- a required decision is not derivable from the ticket, conversation, repository rules, or existing product behavior;
- credentials, permissions, or external approval are required;
- progress requires a separately gated irreversible action.

## Verification

Use risk-proportionate verification according to repository capabilities.

Relevant checks may include:

- build;
- typecheck;
- lint;
- automated tests when appropriate to the repository;
- runtime behavior;
- browser console;
- screenshots;
- responsive layouts;
- critical interaction paths;
- accessibility checks;
- performance checks;
- intermediate animation or continuous-state checkpoints.

For continuous or animated behavior, inspect meaningful intermediate states rather than only start and end states.

If the user specifies exact checkpoints, treat them as acceptance evidence.

## Completion gate

The task is complete only when:

- every acceptance criterion has evidence;
- relevant build/runtime/interaction checks have passed;
- requested screenshots or state checks have been inspected;
- P0 = 0;
- P1 = 0.

For an eligible mechanical change where independent review was skipped, the final report must state `Reviewer: N/A` and the reason; the P0/P1 gate applies whenever review runs.

P2 may remain.

Do not continue merely to eliminate P2.

## Autonomy boundary

Allowed by default within the requested repository scope:

- read;
- edit;
- run;
- inspect;
- build;
- verify;
- capture screenshots;
- use temporary local artifacts needed for verification;
- start and stop workflow-owned Reviewers.

Not allowed unless explicitly authorized:

- push;
- deploy;
- merge;
- publish;
- destructive production operations;
- external irreversible actions;
- commit when repository or user rules require a human verification gate first.

## Final report

Report only:

- completed scope;
- principal changes;
- verification results;
- reviewer results;
- remaining P2 items;
- pending Human Gates.

Do not include internal orchestration chatter or reviewer transcripts unless the user asks for them.
