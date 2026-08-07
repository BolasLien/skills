# handoff-audit

A coding-agent skill for maintaining one human-readable handoff per independently transferable coding task.

```text
repository = current implementation truth
git history = code change history
docs/handoffs/<task-slug>.md = current shared understanding of one task
docs/handoffs/README.md = task handoff index
```

## Why one file per task

Parallel work should not compete for a single `docs/handoff.md`. Separate handoffs prevent one task's updates, risks, decisions, and next steps from overwriting or bloating another task's context.

Example:

```text
docs/handoffs/
├── README.md
├── autolayout-runtime-attributes.md
├── editorbox-refactor.md
└── typescript-migration.md
```

## Modes

- `create` — create a task-specific handoff and index entry
- `update` — rewrite the matching task handoff for today's state
- `intake` — resolve and reconcile one task handoff before implementation
- `audit` — check accuracy, readability, task boundaries, duplicates, and index consistency

## Trigger examples

```text
Use handoff-audit create mode for the AutoLayout runtime attributes work.
```

```text
Use handoff-audit update mode for docs/handoffs/editorbox-refactor.md.
Rewrite it for the current state; do not append a log or include unrelated branch changes.
```

```text
Resume the TypeScript migration from its task handoff using intake mode.
Do not modify code until intake is complete.
```

```text
Audit the AutoLayout handoff and its index entry for stale, duplicated, or cross-task information.
```

## Recommended project rule

```text
Maintain one handoff per independently transferable coding task under docs/handoffs/.
Resolve the exact task handoff before create, update, intake, or audit.
Do not use the newest file by default and do not combine unrelated concurrent tasks.
```
