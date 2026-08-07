---
name: reject-and-redo
description: Use when an agent claims a task, PR, or implementation is complete or verified without sufficient evidence against the stated acceptance criteria. Reject the delivery without performing the agent's debugging or exploratory testing, and require full self-verification, correction, and re-delivery.
---

# Reject And Redo

## Purpose

Prevent the requester from becoming the agent's primary QA or debugger.

The agent owns:

- implementation
- verification
- defect discovery
- diagnosis
- correction
- regression testing

The requester owns:

- acceptance criteria
- product decisions
- approval of subjective tradeoffs

## Execution semantics

This skill is an action workflow, not merely a text-generation template.

When invoked by an orchestrating agent that can resume or message the delivering agent:

1. Evaluate the delivery against the acceptance criteria and evidence requirements.
2. Send the rejection directly to the delivering agent.
3. Keep the task open.
4. Require verification, correction, and re-delivery.
5. Do not surface the incomplete delivery as a completed result.

When the delivering agent cannot be resumed or contacted, output the rejection
message for the requester or orchestrator to send manually. Do not claim to
have rejected or resumed anything that did not actually happen.

## Preconditions

This skill assumes that usable acceptance criteria exist.

If the task has no sufficiently concrete acceptance criteria, do not repeatedly
reject the agent for missing per-criterion evidence. First require the agent to
reconstruct a proposed acceptance checklist from the task, specification, and
available references.

Escalate only criteria that require a genuine product decision.

## When to use

Use this skill when an agent claims completion but one or more of the following is true:

- Acceptance criteria are not mapped to concrete evidence.
- Reported checks do not cover the actual runtime behavior.
- A UI change is verified only through DOM, selectors, code inspection, or computed-style checks.
- Required screenshots, visual comparisons, test output, or runtime evidence are missing.
- The agent reports intended verification instead of completed verification.
- Review findings were reported but not resolved before delivery.
- Known limitations are hidden behind a general completion claim.

## Evidence expectations

Require evidence proportional to the task risk.

### General changes

Evidence may include:

- tests executed and their results
- runtime flows exercised
- relevant logs or command output
- per-criterion verification results
- unresolved limitations
- regression checks

### UI changes

Evidence should additionally include, where relevant:

- screenshots of affected states
- comparison against an available baseline, design reference, explicit visual
  contract, or clearly stated expected runtime behavior
- viewport and test-data conditions
- loading, empty, error, disabled, hover, and focus states
- overflow, scrolling, alignment, spacing, sizing, layering, and responsive behavior

DOM, selector, and computed-style checks are supporting evidence. They are not sufficient visual evidence by themselves.

### Higher-risk changes

For cross-module, architectural, regression-prone, or visually complex changes,
require an independent or adversarial verification pass. The reviewer should
actively attempt to disprove completion instead of merely confirming the
implementation.

Not every task needs this. Typo fixes, small doc edits, config value changes,
and isolated pure-function changes with complete tests can be sufficient with
per-criterion evidence alone.

## Rejection rules

Reject based on delivery incompleteness.

Do not perform the agent's:

- exploratory testing
- debugging
- root-cause analysis
- implementation diagnosis
- patch design

You may identify:

- which acceptance criterion lacks evidence
- which required verification category is missing
- which observable acceptance criterion is violated

Do not provide:

- likely code location
- root-cause theory
- implementation hints
- proposed patch

Do not proactively perform additional exploratory testing to build a defect
list for the agent.

Observable acceptance failures already encountered during normal use may be
reported, but only as failed behavior or failed criteria. Do not diagnose
their cause or propose fixes.

## Rejection template

Adapt only the missing evidence categories:

> 這不是完成交付。你尚未提供足以覆蓋驗收標準的證據。
> 請回到驗收階段，自行重現、找出問題、修正，並重新執行完整驗收後再交付。
> 不要要求我替你做 exploratory testing 或 defect diagnosis。

For UI evidence failures, add:

> UI 驗收不能只依賴 DOM、selector 或 computed style。
> 請提供執行畫面，並根據可用的 baseline、設計稿、明確視覺規格，
> 或預期 runtime behavior 說明比較結果。

For an observable acceptance failure, state only the failed criterion:

> 目前交付不符合「<acceptance criterion>」。
> 請自行重現、診斷、修正，並重跑完整驗收。

## After rejection

A rejection invalidates the previous completion claim.

The agent must:

1. Return to the full acceptance checklist.
2. Reproduce or identify the missing verification.
3. Fix all valid issues it discovers.
4. Rerun all relevant checks, not only the last failed item.
5. Perform regression verification.
6. Submit a new evidence-backed delivery.

Describing the next verification or correction step is not sufficient.

When the required action is clear and the necessary tools are available, execute
it immediately. Do not wait for the requester to say "continue", "proceed", or
"do it".

Adding only the missing sentence, screenshot, or test output without rerunning the
relevant verification workflow is not sufficient.

## Escalation

If the agent repeatedly returns with the same evidence gap, require an evidence audit:

> 列出每一條驗收標準、使用的驗證方法、實際證據、結論，以及無法驗證的項目與原因。
> 不要宣稱未驗證項目已完成。

Then determine whether the blocker is:

- missing acceptance criteria
- missing baseline or reference artifact
- inaccessible runtime environment
- unstable test setup
- insufficient tool capability
- subjective product judgment
- contradictory requirements

Do not continue rejecting indefinitely when the agent lacks a required artifact
or capability.

## Stop conditions

Stop autonomous rejection and escalate to the requester when:

- the agent lacks access to the required environment
- a required baseline or design reference is unavailable, and the expected
  result cannot be derived from an explicit visual contract or stated runtime behavior
- acceptance criteria are contradictory
- the decision is inherently subjective
- available tooling cannot perform the required comparison
- verification cost is materially disproportionate to task risk

Report the exact unverifiable item and why. Never describe an unverifiable
item as completed.
