---
name: codex-goal-writer
description: Use this skill when the user wants to write, improve, review, or convert a task into a Codex CLI `/goal` prompt for long-running work with clear scope, validation, checkpoints, and stopping conditions.
---

# Codex Goal Writer

## Purpose

Turn rough task intent into a durable Codex CLI `/goal` prompt. The prompt should make the objective, boundaries, verification loop, pause conditions, and stopping condition explicit enough for long-running autonomous work.

## When to Use

Use this skill when the user asks to:

- write a `/goal` prompt
- turn a feature, migration, refactor, experiment, deployment loop, eval loop, or prototype into a long-running Codex objective
- review whether a proposed `/goal` prompt is good enough
- create a reusable prompt template for goal-driven Codex work

Prefer planning instead when the user only wants analysis, has not decided to implement, or does not have a verifiable stopping condition yet.

## Inputs

Gather these from the user request or surrounding context:

- Objective: the single durable outcome to complete.
- Context: files, docs, issues, plans, logs, or repo instructions Codex must read first.
- Scope: allowed files, folders, modules, systems, and forbidden areas.
- Validation: commands, artifacts, screenshots, checks, evals, or acceptance criteria.
- Stop condition: the externally checkable state that means the goal is done.
- Pause conditions: cases where Codex should stop and ask before proceeding.

If critical details are missing, ask at most three concise questions. Prioritize end state, validation evidence, and allowed or forbidden scope.

## Workflow

1. Decide whether `/goal` is appropriate.
   - Good fit: long-running work, one durable objective, repeatable validation, clear stop condition.
   - Poor fit: loose backlog, unclear requirements, pure brainstorming, or one-off question.

2. Convert the task into a structured goal prompt with these sections:
   - Objective
   - Context
   - Scope
   - Non-goals
   - Execution
   - Validation
   - Pause conditions
   - Stop condition

3. Make the stop condition verifiable.
   - Prefer commands that pass, artifacts that exist, previews that load, eval scores, or migration parity.
   - Avoid vague endings like "improve quality" or "make it better".

4. Keep boundaries explicit.
   - Name what Codex may change.
   - Name what Codex must not change.
   - Include compatibility, UI, API, data, or product behavior that must be preserved.

5. If the task is complex, recommend putting detailed requirements in `PLAN.md` and make `/goal` reference it.

## Output

Return a paste-ready prompt in this shape:

```text
/goal [complete one objective], without stopping until [verifiable end state].

Objective:
- [One durable objective.]

Context:
- Read first: [AGENTS.md / CLAUDE.md / PLAN.md / issue / docs / key files].
- Background: [short project or task context].

Scope:
- Allowed changes: [files, folders, modules].
- Do not change: [forbidden areas].
- Preserve: [behavior, UI, API, data format, compatibility].

Non-goals:
- [Explicit things Codex should not expand into.]

Execution:
- Work in checkpoints and keep a short progress log.
- Before each checkpoint, state the immediate intent.
- After each checkpoint, run the relevant validation.
- Prefer minimal changes aligned with existing project patterns.

Validation:
- Run: [command or artifact check].
- Run: [command or artifact check].
- If validation fails, inspect the failure, make the smallest targeted fix, and rerun.

Pause conditions:
- Pause only if [specific blocking or risky conditions].

Stop condition:
- Stop when [specific commands pass / artifact works / score is reached].
- Final report must include changed files, validation evidence, and remaining risks.
```

## Constraints

- The objective must be singular.
- The stop condition must be externally checkable.
- Scope and non-goals must be explicit.
- Validation commands or artifacts must be named whenever possible.
- Pause conditions must be concrete.
- Do not turn an open-ended backlog into one `/goal`.
- Keep the generated prompt direct and actionable.
