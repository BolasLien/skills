# Output Contract

Use this contract for `docs/codebase-inventory/`.

The inventory is a current-state architecture reference for both humans and future agents. Match the repository's actual architecture; do not force generic frontend sections onto a non-frontend repository.

Use Traditional Chinese for prose when the user's language is Traditional Chinese. Preserve source identifiers, filenames, symbols, package names, and commands verbatim.

## README.md

Purpose: 60-second orientation and navigation.

Include:

- project identity and inventory purpose
- concise mental model that corrects likely wrong assumptions
- document navigation table
- machine-readable artifact description
- project snapshot with measured scale and stack
- development/build entry commands when discoverable
- high-impact warnings for future agents

Do not keep dated notes describing stale architecture. Update the current-state text instead.

## ARCHITECTURE.md

Purpose: global system architecture.

Include when applicable:

- what the system is
- application/entry-point boundaries
- bootstrap lifecycle
- state model
- runtime layers
- build system
- major dependencies
- dependency graph summary
- high-centrality dependency hubs
- circular dependency summary
- architectural characteristics and constraints

Use Mermaid only for edges supported by source evidence.

## MODULE_MAP.md

Purpose: map responsibilities and feature boundaries.

Include:

- directory responsibility map
- module responsibility table
- domain/data-model hierarchy
- managers/services/controllers
- UI/component boundaries
- API or persistence boundaries
- feature boundaries
- important cross-module relationships

Avoid a folder-tree dump without semantic responsibility.

## DATA_FLOW.md

Purpose: trace runtime behavior.

Include representative flows such as:

- app lifecycle
- rendering
- user event handling
- state mutation
- API requests
- persistence/save
- undo/redo
- upload/import/export
- other project-specific critical flows

For each important flow, cite actual files and symbols.

Distinguish static proof from runtime assumptions.

## IMPORTANT_FILES.md

Purpose: accelerate onboarding and focused investigation.

Include:

- the most important files or modules, ranked by architectural importance
- why each is important
- what to read before changing it
- quick lookup: "I want to change/debug X → start here"
- orphan/dead-code candidates when supported by Madge and source cross-checking

Do not call an orphan "dead code" solely because Madge reports it as orphaned.

## TECH_DEBT.md

Purpose: evidence-backed technical debt inventory.

Include:

- risk classification
- measured counts where reproducible
- concrete examples
- impact
- evidence and tool limitations
- architectural bottlenecks
- hidden global state
- side-effect risks
- dependency cycles
- duplication or parallel implementations
- large/god modules
- unsafe or legacy patterns
- likely memory/resource leaks when supported by lifecycle evidence
- security-relevant code patterns when discovered

Rules:

- Do not label code as debt merely because it is old.
- Do not copy counts forward during `update`; remeasure.
- Separate confirmed defects from suspected risks.
- A tool match is a candidate until source context supports the claim.

## repomix-signatures.xml

Generate with Repomix.

Prefer compressed/signature-oriented output suitable for agent orientation.

Document actual coverage and exclusions in README.md.

## .inventory.json

Exact minimum schema:

```json
{
  "schemaVersion": 1,
  "lastScannedCommit": "<git commit sha>"
}
```

Write or update this file only after successful validation.

## Citation style

Use concrete references such as:

```text
`src/core/data/ProjectData.js` — `ProjectData.set xml`
```

or, when a line number is useful:

```text
`src/global/AppConfig.js:30-45`
```

Prefer symbols over line numbers for durable references.

Every major architecture claim should be traceable to at least one source file, configuration file, or deterministic tool result.

## Current-state rule

The documents describe the codebase now.

When architecture changes:

- rewrite the affected current-state description
- remove stale statements
- update diagrams
- remeasure metrics
- update important-file rankings if centrality changes

Do not append chronological update sections. Git owns history.
