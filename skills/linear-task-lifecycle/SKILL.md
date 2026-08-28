---
name: linear-task-lifecycle
description: Manage a Linear issue through implementation, verification, interruption, and completion. Use when a coding task references a Linear issue identifier or URL, or when the user asks an agent to implement, resume, review, or update tracked Linear work. Do not mutate Linear for read-only questions unless explicitly requested.
---

# Linear Task Lifecycle

Treat Linear as the source of truth for task scope, status, dependencies, and delivery discussion. This skill complements implementation, review, commit, and merge-request skills; it does not replace them.

## Resolve the task

When the request identifies a Linear issue, fetch the issue before acting. Read its description, project, status, relations, and relevant comments. Use the issue's team and its actual workflow statuses rather than assuming status names.

If the request is only consultation, planning, or a read-only review, do not change the issue unless the user explicitly asks. If no issue identifier or URL is supplied, do not guess, search for a likely issue, or create one merely to track the work.

## Start or resume implementation

An explicit request to implement or resume a Linear issue authorizes normal lifecycle updates to that issue:

1. Confirm that the issue is not completed, canceled, or blocked by an unresolved dependency.
2. If a blocking relation is unresolved, do not begin implementation. Report the blocker and leave an explanatory comment only when it adds information not already present.
3. Move an unstarted issue to the team's started status immediately before implementation begins. Preserve an existing started status when resuming.
4. Add one concise start or resume comment containing the branch or worktree when known and the intended validation. Do not post routine progress narration.

The issue defines scope. If repository evidence conflicts with it or required information is missing, pause and ask a targeted question instead of silently changing scope. Record the resulting decision in Linear when it affects future work.

## Keep the project state consistent

When the issue belongs to a Linear Project, treat Project status as an aggregate lifecycle rather than mirroring the current issue:

- When implementation of the first active issue actually begins, move an unstarted Project to its started status when the workspace exposes an appropriate transition.
- Do not complete, cancel, or pause a Project merely because one issue changes state.
- Before completing a Project, fetch all Project issues and confirm that every required, non-canceled issue is completed and that any Project-level acceptance criteria are satisfied.
- When the Project is genuinely complete, publish one concise Project update with delivery and verification evidence, then move it to the completed status.
- If Project status cannot be changed through the available Linear tools, report that limitation; do not claim it was synchronized.

Use the workspace's actual Project statuses. Do not invent a status or substitute an Issue status for a Project status.

## Record meaningful state

Use comments for durable handoff information, not a transcript. Record only material events such as:

- a user-approved scope or acceptance-criteria change;
- a newly discovered external blocker;
- validation evidence needed to judge completion;
- a delivery reference such as commit, branch, or merge request;
- recovery context before an intentional stop or context reset.

A recovery comment should state what is complete, what remains, the current branch or worktree when known, validation already run, and the next concrete action.

Do not mark an issue blocked merely because the work is difficult, incomplete, or awaiting the agent's own next step. Use the team's blocked state only for a genuine external dependency or missing user decision, and explain the condition in a comment.

## Complete the issue

Do not move the issue to a completed status until all of the following are true:

- the issue's requested scope and acceptance criteria are satisfied;
- required source verification has passed;
- required runtime or human verification has actually been performed when the issue requires it;
- the requested commit or delivery operation is complete;
- no known required work remains.

On completion, add one delivery comment summarizing the implementation, commit or merge-request reference when available, and exact verification results. Then move the issue to the team's completed status.

If implementation is delivered but required verification is still outstanding, keep the issue in a started state and state the remaining gate. Never report a Linear transition that the MCP did not confirm.

## Typical invocation

- Claude Code and Antigravity CLI (`agy`): `/implement BOL-5`
- Codex: `$implement BOL-5`

The implementation skill handles the code workflow; this skill fetches `BOL-5`, maintains its lifecycle state, and records durable evidence.
