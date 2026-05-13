# Codex Goal Writer

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

---

# Codex Goal Writer（繁體中文）

`codex-goal-writer` 會把粗略任務整理成可以直接貼到 Codex CLI 的 `/goal` prompt。它適合長時間任務，讓 Codex 依照 checkpoint 持續推進，直到達成清楚、可驗證的停止條件。

## 何時使用

適合在這些情境使用：

- 撰寫新的 `/goal` prompt
- 改善或 review 既有 `/goal` prompt
- 把 feature、migration、refactor、prototype、deployment loop、eval loop 轉成 durable Codex objective
- 在開始長時間任務前，先定義 scope、validation、pause conditions、stop condition

如果只是發想、討論方向、或還沒有可驗證停止條件，應該先規劃，不要直接用 `/goal`。

## 如何呼叫

可以直接指定 skill，也可以自然描述需求：

```text
Use $codex-goal-writer to draft a durable /goal prompt for this task:
```

```text
幫我把這個 migration plan 轉成 /goal prompt。
```

```text
幫我 review 這個 /goal prompt，收斂 scope 和 stop condition。
```

## 產出內容

skill 會產出一份結構化 `/goal` prompt，包含：

- `Objective`
- `Context`
- `Scope`
- `Non-goals`
- `Execution`
- `Validation`
- `Pause conditions`
- `Stop condition`

最重要的是 `Validation` 和 `Stop condition`：前者定義如何證明進度，後者定義什麼時候該停止。

## 輸入檢查表

為了得到更穩定的 prompt，最好提供：

- 你要 Codex 完成的單一結果
- Codex 必須先讀的檔案、文件、issue、plan 或 log
- Codex 可以修改的範圍
- Codex 不能修改的範圍
- 可以證明完成的命令或產物
- 什麼情況下 Codex 應該暫停詢問

## 範例

```text
Use $codex-goal-writer to create a /goal prompt for this task:

我想讓 Codex 替 Vue Pomodoro app 補 Playwright smoke coverage。
它應該先讀 AGENTS.md、tests/e2e、playwright.config.js、src/router、
src/views、src/store/pomodoro.js。可以修改 tests/e2e 和必要的測試輔助設定。
不要改產品文案、UI 設計或資料模型。停止條件是 npm run lint 和 npm run test:e2e 都通過。
```

預期輸出形狀：

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

## 寫作技巧

- 把 goal 寫成完成合約，不要寫成模糊任務。
- 用「測試通過才停止」取代「改善品質」。
- 明確列出禁止修改的範圍。
- 一個 `/goal` 只處理一個 durable objective。
- 複雜任務可以先寫 `PLAN.md`，再讓 `/goal` 引用它。
