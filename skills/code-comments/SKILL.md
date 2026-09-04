---
name: code-comments
description: Rationale-first code commenting guidelines. Use when writing, modifying, refactoring, or reviewing comments in code — documenting why code exists, explaining non-obvious logic, domain constraints, or workarounds, and stripping transient noise (ticket IDs, Figma links, author history).
---

# Code Comments (Rationale-First)

The sole purpose of a code comment is to **explain to future maintainers why this code must exist and the decision context behind it**.

---

## Core Mental Model: Why-over-What

| Dimension | What to Write (✅ Keep in Code) | What NOT to Write (❌ Move to External Systems) |
|---|---|---|
| **Core Intent** | **Why & Intent**: Business rationale, non-obvious constraints, architectural motivations | **What**: Syntax mechanics or behavior already expressed by the code |
| **External Context** | **Domain/System Constraints**: Compatibility quirks, timing/race conditions, browser-specific behavior | **Transient Identifiers**: Ticket IDs (Linear/Jira), Figma nodes/links, PR numbers |
| **Historical Changes** | **Invariants & Assumptions**: Preconditions and boundary conditions of current state | **Changelog History**: Author names, dates, "Refactored from old class", "Fixed bug in v2" |

---

## Rules and Patterns

### 1. Rationale-First
Explain "why a naive implementation was not chosen" or "what breaks if this is done differently".

```javascript
// ❌ Mechanical What
// Set refreshTime to current timestamp
setRefreshTime(Date.now());

// ✅ Architecture & Non-Obvious Why
// Store only holds navigational state; bumping timestamp forces subscribers to re-read updated live tree nodes
setRefreshTime(Date.now());
```

### 2. Strip Transient Noise
Offload tracking metadata to Git commits, MR/PR descriptions, or issue trackers to keep comments self-contained and durable.

- **Issue Keys / Ticket IDs** (e.g., `BOL-123`): Place in commit messages or MR descriptions, **never in code comments**.
- **Figma Links / Design Node IDs**: Keep in MR descriptions or spec documents, **never in code comments**.
- **Authorship and Timestamps** (e.g., `// Updated by John 2024-05`): Managed by Git blame, **never in code comments**.

```javascript
// ❌ Cluttered with transient noise
// [BOL-892] Fix modal close flicker per Figma node 12:345 (by bolas 2024/06)
if (isExiting) return null;

// ✅ Focused on runtime boundary and rationale
// Unmount DOM node early during exit animation to prevent flicker caused by parent overflow calculations
if (isExiting) return null;
```

### 3. Workarounds & Edge Cases
When non-standard workarounds or compatibility shims are necessary, explicitly document the **trigger condition** and **root cause**.

```javascript
// ✅ Explicit trigger condition and root cause
// Legacy Safari does not reset buffer context upon canvas resize; explicitly reassign width to force repaint
canvas.width = targetWidth;
```

---

## Completion Criteria

When writing or reviewing comments, verify against this checklist:

1. **[Self-Explanatory]** If this comment is deleted, would the rationale be difficult to infer from the code alone? (If the code is obvious, delete the comment).
2. **[Zero Transient Noise]** No ticket IDs, Figma nodes, author names, or dates.
3. **[Why-over-What]** Focus strictly on why, invariants, and constraints, not mechanical paraphrasing of code.
