---
name: codebase-inventory
description: Reverse-engineer, maintain, and query a codebase architecture inventory. Use when the user invokes /codebase-inventory create, update, or query, or explicitly asks to use the codebase inventory workflow. Builds evidence-backed architecture knowledge with Repomix, Madge, ast-grep, Git, and ripgrep without modifying production code.
---

# Codebase Inventory

Maintain an evidence-backed description of the codebase as it exists now.

The inventory describes the current codebase. Git describes history.

## Commands

Interpret the first argument as one of:

- `create`
- `update`
- `query <request>`

If the command is missing or unsupported, explain the valid command syntax and stop.

## Non-negotiable boundaries

- Never modify production source code.
- Only create or update files under `docs/codebase-inventory/`, unless the user explicitly requests another output.
- Do not refactor, fix, format, rename, or rewrite production code.
- Do not treat filenames, comments, naming, or folder structure alone as proof of runtime behavior.
- Distinguish `Fact`, `Inference`, and `Unknown` in reasoning and output whenever certainty matters.
- Important architecture conclusions must cite concrete file paths and symbols. Add line numbers when useful, but do not rely on line numbers as stable identifiers.
- Tool-derived mechanical facts should be obtained from tools rather than reconstructed manually by the agent.
- Repomix and Madge are required for `create` and `update`.
- ast-grep is required for `create`, `update`, and `query`.
- Git and ripgrep are required when available in the repository environment.
- If a required tool cannot run after reasonable adaptation, stop the affected workflow and report the exact limitation. Do not silently replace dependency or AST analysis with guesses.

## Tool authority

Use tools for mechanically derivable facts:

| Tool | Authority |
|---|---|
| Git | repository state, current commit, changed files, diff range |
| Repomix | repository inventory, compact signature/context material |
| Madge | static module dependency graph, circular dependencies, orphan candidates, dependency hubs |
| ast-grep | syntax-aware structural discovery, definitions, calls, imports, mutations, registrations, repeated code patterns |
| ripgrep | strings, XML, templates, config, dynamic names, comments, unsupported syntax, cross-checking |

Use agent reasoning for semantic interpretation:

- module responsibility
- runtime flow
- data flow
- business boundaries
- architectural risks
- likely extension points

Never ask the agent to manually reconstruct facts that Git, Repomix, Madge, ast-grep, or ripgrep can determine more reliably.

## Tool installation policy

Tools may be executed through ephemeral package runners such as `npx --yes` when this does not add project dependencies.

Requirements:

- Do not modify `package.json`.
- Do not modify lockfiles.
- Do not add production or development dependencies to the project.
- Prefer ephemeral execution.
- Tool cache outside the repository is acceptable.
- Temporary analysis output should go to a temporary directory unless it is a defined inventory artifact.
- Inspect project configuration and adapt commands for source roots, extensions, aliases, module systems, and parsers.

## Repomix

Use Repomix during `create` and `update`.

Purpose:

- produce a compact repository inventory
- preserve broad codebase structure for agent reading
- produce `docs/codebase-inventory/repomix-signatures.xml`

Preferred starting point:

```bash
npx --yes repomix \
  --compress \
  --remove-comments \
  --output docs/codebase-inventory/repomix-signatures.xml \
  --style xml \
  --no-file-summary
```

Adapt include/exclude rules to the actual project.

Exclude generated or external content such as:

- `node_modules`
- `dist`
- `build`
- `coverage`
- vendored code
- generated code
- large binary assets

Requirements:

- Treat Repomix output as inventory and search material, not authoritative architecture evidence.
- Verify important conclusions against source files.
- Record meaningful coverage limitations in the inventory.

## Madge

Use Madge during `create` and `update`.

Purpose:

- static module dependency graph
- circular dependency analysis
- orphan candidates
- dependency hubs
- direct and reverse dependency scope

Preferred starting points:

```bash
npx --yes madge <source-root> --json
npx --yes madge <source-root> --circular
npx --yes madge <source-root> --orphans
```

Write machine output to a temporary directory for analysis.

Adapt configuration for:

- `.js`, `.jsx`, `.ts`, `.tsx`, and project-specific extensions
- path aliases
- webpack/Babel/TypeScript resolution
- CommonJS
- mixed module systems

Requirements:

- Record limitations around dynamic `require`, dynamic imports, computed paths, loaders, aliases, runtime registration, and unsupported syntax.
- Missing Madge edges are not proof that no dependency exists.
- Verify critical dependency claims with source-level tracing.
- For `update`, rerun the full Madge graph. Do not infer graph changes only from Git diff.

## ast-grep

Use ast-grep during `create`, `update`, and `query`.

Purpose:

- locate entry-point patterns
- identify component, class, hook, service, manager, data model, and utility definitions
- find API calls and side effects
- find state mutations
- find event registration
- find dynamic imports and module registration
- detect repeated structural patterns
- support call-chain and data-flow investigation

Preferred starting points:

```bash
npx --yes @ast-grep/cli run --lang javascript --pattern '<pattern>' <path>
npx --yes @ast-grep/cli scan
```

Adapt language and patterns to the project.

Examples of useful structural searches:

```bash
npx --yes @ast-grep/cli run \
  --lang javascript \
  --pattern 'import $X from $SOURCE' \
  src

npx --yes @ast-grep/cli run \
  --lang javascript \
  --pattern 'require($SOURCE)' \
  src

npx --yes @ast-grep/cli run \
  --lang javascript \
  --pattern '$TARGET.addEventListener($EVENT, $HANDLER)' \
  src

npx --yes @ast-grep/cli run \
  --lang javascript \
  --pattern 'useEffect($CALLBACK, $DEPS)' \
  src
```

Requirements:

- Prefer AST search over textual search when syntax can answer the question.
- Use `rg` when AST search is unsuitable: config, strings, XML, templates, comments, generated metadata, or non-standard syntax.
- Never use ast-grep rewrite or fix mode.
- Treat matches as candidates. Verify important conclusions in source context.
- Reusable project-specific `sgconfig.yml` rules may be used if already present. Do not add project configuration unless the user explicitly requests it.

## Inventory location and contract

The canonical inventory lives at:

```text
docs/codebase-inventory/
├── README.md
├── ARCHITECTURE.md
├── MODULE_MAP.md
├── DATA_FLOW.md
├── IMPORTANT_FILES.md
├── TECH_DEBT.md
├── repomix-signatures.xml
└── .inventory.json
```

Use the output contract in `references/output-contract.md`.

Metadata format:

```json
{
  "schemaVersion": 1,
  "lastScannedCommit": "<git commit sha>"
}
```

`lastScannedCommit` is the Git commit whose code state the inventory has successfully analyzed and validated.

Only update `lastScannedCommit` after the inventory validation succeeds.

## `create`

Use when no trustworthy inventory exists or the user explicitly requests a fresh inventory.

Workflow:

1. Inspect repository state, source roots, package manager, build configuration, aliases, entry configuration, and language/module conventions.
2. Check whether `docs/codebase-inventory/` already exists.
   - If it contains an inventory, do not silently overwrite it.
   - If the user explicitly requested `create`, rebuild the inventory from the current codebase, preserving only information revalidated against current code.
3. Run Repomix.
4. Run the full Madge dependency analysis.
5. Use ast-grep to discover structural patterns and candidate architecture nodes.
6. Use ripgrep for unsupported syntax, strings, XML, config, dynamic registration, and cross-checking.
7. Identify and verify:
   - entry points
   - bootstrap and app lifecycle
   - build system
   - routing or navigation
   - state model
   - API/request layer
   - persistence
   - domain/data model
   - component or UI boundaries
   - event systems and side effects
   - dependency hubs
   - circular dependencies
   - orphan/dead-code candidates
   - feature boundaries
   - major technical debt
8. Trace representative runtime flows from observable entry to side effect/persistence/rendering feedback.
9. Write the canonical inventory documents.
10. Validate the complete inventory.
11. Only after validation succeeds, write `.inventory.json` with the current `HEAD`.

Do not read every file linearly before forming a map.

Start with mechanically derived structure, identify high-centrality and runtime-critical nodes, then expand by evidence.

## `update`

Use to synchronize an existing inventory to the current codebase.

The result must describe the current codebase, not the history of changes.

Workflow:

1. Read `.inventory.json`.
2. Read all current inventory documents.
3. Resolve the current `HEAD`.
4. Validate `lastScannedCommit`.
   - If missing, invalid, or not reachable from the current repository history, do not guess an incremental range.
   - Fall back to a full inventory rebuild using the `create` analysis workflow, while updating the existing canonical documents in place.
5. If `lastScannedCommit == HEAD`, still perform a lightweight consistency check against working-tree changes.
   - If relevant tracked or untracked source/config changes exist, include them in the investigation but do not write `HEAD` as proof of uncommitted content.
   - Report that metadata cannot represent uncommitted state exactly.
6. Otherwise obtain the change range:

```bash
git diff --name-status <lastScannedCommit>..HEAD
```

7. Identify directly changed architecture-relevant files.
8. Rerun Repomix.
9. Rerun the complete Madge graph, circular analysis, and orphan analysis.
10. Use ast-grep to re-check structural patterns affected by the changes.
11. Trace direct and indirect impact through importers, dependencies, runtime call paths, state, side effects, persistence, and rendering.
12. Update the canonical documents in place:
    - preserve still-valid content
    - correct changed facts
    - remove invalid descriptions
    - add newly important architecture
    - update metrics and technical debt only when remeasured
13. Validate the complete inventory, not only edited paragraphs.
14. Only after validation succeeds, update `lastScannedCommit` to the analyzed `HEAD`.

Do not create dated update logs.

Use Git history for historical questions.

### Update verification

At minimum verify:

- cited file paths exist
- cited symbols exist or the text clearly marks historical/removed content only when the user explicitly asked for history
- entry points match current build/runtime configuration
- module responsibilities are supported by implementation evidence
- important runtime flows can be traced through source
- dependency claims match current Madge output and source-level cross-checks
- removed modules are removed from current-state documentation
- newly central modules are considered for the inventory
- Mermaid diagrams do not assert unverified edges
- technical-debt counts are not copied forward without remeasurement
- `Unknown` is not rewritten as `Fact`

If validation fails:

- do not update `.inventory.json`
- report the failed checks and affected documents
- leave enough evidence for the user or next agent to continue

## `query`

Use for focused investigation.

`query` returns investigation results and does not update the codebase inventory.

Do not modify production code.

### Query modes

Infer the mode from the request.

#### Goal-driven investigation

The user describes a feature, behavior change, bug, or desired outcome.

Example:

```text
/codebase-inventory query "我要新增選取相片框後自動套用版型"
```

Do not require the user to know which subsystem should be investigated.

Infer the investigation scope from the desired outcome.

Start from observable behavior and trace inward:

```text
UI or external entry
→ event handling
→ state/selection
→ domain logic
→ side effects
→ persistence
→ rendering feedback
```

Expand scope only through actual dependency, call, registration, or data-flow evidence.

The purpose is to identify:

- the existing mechanism relevant to the goal
- likely extension points
- reusable abstractions
- affected behavior
- hidden constraints
- verification evidence needed before implementation

Do not produce a full implementation plan unless the user asks for one.

#### Target-driven investigation

The user names a module, symbol, flow, API, or technical mechanism.

Example:

```text
/codebase-inventory query "追蹤 AutoLayoutFlow 的完整呼叫鏈"
```

Trace the target through:

- definitions
- callers/importers
- callees/dependencies
- state reads and writes
- side effects
- persistence
- rendering or externally observable consequences

### Query procedure

1. Read the inventory documents first.
2. Use the inventory as orientation, not proof.
3. Use ast-grep for syntax-aware discovery.
4. Use Madge data or rerun targeted dependency analysis when dependency direction matters.
5. Use ripgrep for strings, XML, config, dynamic names, or unsupported syntax.
6. Open and trace actual source files and symbols.
7. Return an evidence-backed investigation.

Recommended result shape:

```markdown
# Investigation

## Conclusion

## Relevant existing mechanism

## Runtime / call / data flow

## Extension points

## Affected scope

## Existing behavior that must not be broken

## Verification evidence

## Fact / Inference / Unknown
```

Adapt headings to the request. Do not force irrelevant sections.

If the investigation proves that the current inventory materially disagrees with the codebase, state:

```text
Codebase inventory 與目前程式碼不一致。請執行 `/codebase-inventory update`。
```

Continue the query using current source evidence when possible, but do not silently repair inventory files.

## Evidence discipline

Use these certainty labels internally and surface them where ambiguity affects decisions:

- `Fact`: directly supported by code, configuration, Git, or deterministic tool output.
- `Inference`: best explanation from multiple facts, but not directly proven at runtime.
- `Unknown`: evidence is missing, dynamic behavior blocks static proof, or runtime observation is required.

Examples:

- Madge edge + matching import statement: `Fact`.
- A manager appears to own a workflow because all known callers delegate to it: `Inference` until runtime or complete registration evidence confirms exclusivity.
- Dynamic `require(variable)` target cannot be resolved statically: `Unknown`.

Never convert `Inference` into `Fact` for cleaner documentation.

## Stop conditions

Stop and report instead of guessing when:

- repository source cannot be located
- required tool execution cannot be made to work without modifying project dependencies or production code
- build aliases or generated resolution prevent reliable dependency analysis and cannot be reconstructed from existing config
- dynamic runtime behavior is essential and static evidence cannot answer the question
- the requested conclusion requires runtime evidence not available in the current environment

State exactly what is known, what is blocked, and what evidence would resolve the block.
