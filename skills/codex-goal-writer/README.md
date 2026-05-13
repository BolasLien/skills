# Codex Goal Writer

[Traditional Chinese](./README.zh-TW.md)

`codex-goal-writer` helps turn rough task ideas into paste-ready Codex CLI `/goal` prompts. It is designed for long-running work where Codex should keep moving through checkpoints until a clear, verifiable stopping condition is reached.

## When to Use

Use this skill when you want to:

- write a new `/goal` prompt
- improve or review an existing `/goal` prompt
- convert a feature, migration, refactor, prototype, deployment loop, or eval loop into a durable Codex objective
- define scope, validation, pause conditions, and stop conditions before starting long-running work

Do not use it for loose brainstorming or one-off questions. If the task does not have a verifiable stopping condition yet, start with planning instead.

## How to Invoke

Ask Codex for the skill by name, or describe the goal-writing task naturally:

```text
Use $codex-goal-writer to draft a durable /goal prompt for this task:
```

```text
Help me turn this migration plan into a /goal prompt.
```

```text
Review this /goal prompt and tighten the scope and stop condition.
```

## What the Skill Produces

The skill returns a structured `/goal` prompt with these sections:

- `Objective`
- `Context`
- `Scope`
- `Non-goals`
- `Execution`
- `Validation`
- `Pause conditions`
- `Stop condition`

The most important fields are `Validation` and `Stop condition`. They tell Codex how to prove progress and when to stop.

## Input Checklist

For best results, provide:

- the single outcome you want Codex to complete
- files, docs, issues, plans, or logs Codex should read first
- what Codex may change
- what Codex must not change
- commands or artifacts that prove the work is correct
- cases where Codex should pause and ask before continuing

## Example

```text
Use $codex-goal-writer to create a /goal prompt for this task:

I want Codex to add Playwright smoke coverage to a Vue Pomodoro app.
It should read AGENTS.md, tests/e2e, playwright.config.js, src/router,
src/views, and src/store/pomodoro.js first. It may modify tests/e2e and
necessary test helper config. It should not change product copy, UI design,
or the data model. Stop only when npm run lint and npm run test:e2e pass.
```

Expected output shape:

```text
/goal Complete smoke test coverage for the Pomodoro app, without stopping until npm run lint and npm run test:e2e both pass.

Objective:
- ...

Context:
- ...

Scope:
- ...

Non-goals:
- ...

Execution:
- ...

Validation:
- ...

Pause conditions:
- ...

Stop condition:
- ...
```

## Tips

- Write the goal as a completion contract, not a vague task.
- Prefer "stop when tests pass" over "make it better".
- Name forbidden areas explicitly.
- Keep one `/goal` focused on one durable objective.
- For complex work, put detailed requirements in `PLAN.md` and make `/goal` reference it.
