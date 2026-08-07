---
name: glab-mr-review
description: 當使用者要求審查 GitLab Merge Request、判斷 MR 是否可合併、或要對 GitLab MR 留下 review comment 時使用。
---

# MR Review

使用 `glab` 對 GitLab Merge Request 進行可驗證的程式碼審查，並生成 `mr-review-<MR_ID>.md` 報告。

這份 skill 產出的是一份：

- 以 MR branch 完整內容為依據
- 以 correctness 與 regression risk 為優先
- 能被作者直接採取行動的 findings-first review

## Hard Rules

### 1. 一律以 MR branch / head SHA 為準

- 先取得 MR 的 `source_branch` 與 `head SHA`
- 一律以該 branch 或該 SHA 的完整檔案內容作為審查上下文
- 可以參考 diff，但不能只看 diff 下結論
- 禁止拿本地工作樹、目前 branch、或 `main` 的檔案內容當作 MR 內容

### 2. Finding 必須可驗證

- 每個 finding 都必須能回到 MR branch 的完整內容驗證
- 如果你缺上下文，先補讀檔案，不要猜
- 如果你懷疑有風險但證據不足，寫成 open question，不要寫成 bug

### 3. 不要把偏好偽裝成缺陷

以下情況通常不應直接列為 issue：

- 單純寫法偏好
- 你個人的抽象層喜好
- 沒有行為風險的結構差異
- 無法證明會造成成本或 bug 的「感覺不好」

### 4. Repo-specific 規範必須先讀

如果 review 發生在某個實際 repo 內：

1. 先讀根目錄的 `AGENTS.md` / `CLAUDE.md`
2. 依任務關鍵字補讀相關文件（如 Documentation Index 所列）
3. 只有在確認規範後，才能把某項問題列為 project rule violation

不要假設模型本來就知道該 repo 的 icon、token、命名、型別、目錄或架構規範。

## Context Gathering

開始 review 前，至少完成以下步驟：

### 1. 取得 MR 基本資料

```bash
glab mr view <MR_ID> --output json
glab mr diff <MR_ID>
```

至少確認：MR 標題、作者、source branch、target branch、head SHA。

### 2. 補讀完整檔案內容

對每個你要下判斷的檔案，直接讀 MR branch 的完整內容：

```bash
git fetch origin <source_branch>
git show origin/<source_branch>:path/to/file.tsx
```

預設用 source_branch 讀檔。如果 branch 已被推新 commit、需要精準對齊 MR 當下版本、或 branch 名稱不可靠時，改用 head SHA：

```bash
git fetch origin <head_sha>
git show <head_sha>:path/to/file.tsx
```

### 3. 讀必要的周邊上下文

如果某段變更依賴其他檔案才看得懂，就補讀（呼叫端、型別定義、測試檔、共用 utility、專案規範文件）。補到足夠做判斷為止，不要只憑局部 diff 補腦。

## Review Workflow

### Step 1. 分類 MR 類型

判斷 MR 主要屬於哪一類（UI / component、React state / effect / hook、API / data、form / validation、test-only、config / CI / script、refactor、mixed），決定後面要加強哪組領域鏡頭。

### Step 2. 依審查維度檢查

以下維度依優先序排列。用經典術語當思考框架，觸發對每個維度的深入辨識，但不要逐條機械式核對：

1. **Correctness** — contract violations, precondition failures, off-by-one, type mismatches, impossible states
2. **Behavioral regression** — broken callers, changed defaults, altered timing, shifted fallback paths
3. **Error handling** — swallowed errors, unrecoverable UI states, missing fallbacks, fail-unsafe defaults
4. **Test coverage** — behavior verification vs mock verification, regression safety net gaps
5. **Security / data exposure** — trust boundary violations, data leaks to client/log/URL, injection surfaces
6. **Performance** — unnecessary renders/effects/re-fetches, N+1 patterns, bundle/network/DOM cost at wrong layer
7. **Maintainability** — duplicated knowledge, shotgun surgery, divergent change, large responsibility surface, primitive obsession
8. **Project rules** — 只檢查你已從 repo 文件確認過的規則，不要把「大概是團隊習慣」寫成違規

### Step 3. 套用領域鏡頭

根據 MR 類型，加做對應檢查。用經典術語輔助辨識，但如果觀察沒有造成具體風險，不要硬寫成 issue。

**React / Next.js** — 用 Dan Abramov 心智模型辨識：unnecessary state (props mirrored in state)、unnecessary effect (derived values computed in effect instead of render)、component boundary violations (one component managing too many concerns)、prop drilling solvable by composition (Kent C. Dodds IoC)、client/server boundary misplacement

**Refactoring / Design Smells** — 用 Fowler《Refactoring》辨識：Data Clumps、Feature Envy、Long Parameter List、Large Class、Middle Man、Speculative Generality。用 Pragmatic Programmer 辨識：DRY violations (knowledge duplication, not just code duplication)、Orthogonality violations (changing A shouldn't break B)、Broken Windows

**UI / Design System** — token consistency、component variant responsibility、state completeness (disabled/loading/empty/error)、keyboard/focus/aria

**CI / Script / Config** — implicit environment dependencies、half-applied failure states、pipeline ordering impact、local/CI reproducibility

### Step 4. 收斂 findings

只留下可證明、對作者有幫助、能清楚說明風險與修改方向的 findings。不要把每個小觀察都硬塞進報告。

## Writing Rules

### 1. Findings first

輸出順序：findings → open questions → 簡短總結。不要先寫長篇總評再藏 finding。

### 2. 每個 finding 都要回答

- 現在程式怎麼跑
- 哪一步會出問題
- 為什麼這會造成錯誤或風險
- 受影響的是哪個條件或使用情境
- 要改哪裡（帶檔案路徑和行號）

### 3. 用白話，不用空泛術語

內部用經典術語思考，對外用白話輸出。避免「這樣有 code smell」「建議重構」「abstraction 不夠好」。改成：實際流程是什麼、問題在哪一步、修改後應該如何避免風險。

### 4. 沒問題就直接說

未發現 blocker / major issue 就明說，標明哪些 residual risk、哪些因上下文限制未完全驗證。

## Severity Guide

- **Blocker** — 明確 bug、高機率回歸、安全/資料暴露、功能無法正確運作、專案明文禁止事項
- **Major** — 使用者流程錯誤、維護困難、錯誤處理缺口、明顯測試缺口
- **Minor** — 可讀性、局部一致性、小型結構問題、不影響正確性的改善
- **Suggestion** — 不是缺陷，只是可考慮的改善

## Report Format

```markdown
# MR !<MR_ID> Code Review

**MR 標題**: <MR 標題>
**作者**: <作者>
**分支**: <來源分支> → <目標分支>
**審查日期**: <今天日期>

---

## 審查結果：[✅ 批准 / ⚠️ 需要修改 / ❌ 不建議合併]

## Findings

### 🔴 Blocker

- [ ] `path/to/file.tsx:123` 問題描述
  - **目前流程**：<現在程式怎麼跑>
  - **風險**：<哪一步會錯、影響誰>
  - **怎麼改**：<具體修改方向>

### 🟡 Major

- [ ] `path/to/file.tsx:123` 問題描述
  - **目前流程**：<現在程式怎麼跑>
  - **風險**：<為什麼這裡會造成問題>
  - **怎麼改**：<具體修改方向>

### 🟢 Minor

- [ ] `path/to/file.tsx:123` 問題描述
  - **原因**：<簡短說明>
  - **建議**：<簡短修改方向>

## Open Questions / Assumptions

- <需要作者確認，但目前證據不足以下結論的點>

## Good Parts

- <值得保留的實作>

## Summary

<一句到三句，總結 merge 建議與主要風險>
```

若某個分類沒有內容，就省略。

## Comment Posting Flow

### `/mr-review <MR_ID>`

- 執行 review，生成 `mr-review-<MR_ID>.md`

### `/mr-review <MR_ID> comment`

1. 確認 `mr-review-<MR_ID>.md` 存在
2. 讀取報告內容
3. `glab mr comment <MR_ID> --message "$(cat mr-review-<MR_ID>.md)"`

如果報告太長，優先保留 findings，刪掉冗長總評和重複敘述。不要為了縮短留言把關鍵 issue 砍掉。

## Failure Modes

- **無法取得 MR branch** — 先確認 `glab` auth 與 remote，無法取得時明確回報，不要假裝完成 review
- **Diff 很大** — 先抓高風險檔案、優先看行為核心路徑、標明哪些區塊已深入檢查、哪些只做抽樣。不要把「沒看完」偽裝成「沒問題」
- **Generated files** — 預設不當主要審查對象，回到來源檔案或產生邏輯審查
- **證據不足** — 寫成 open question 或標示為「需補上下文才能確認」

## Review Mindset

你的工作不是證明自己看得多細，而是幫團隊提前攔下真正會造成問題的變更。

不要把 review 變成風格警察，也不要把沒證據的懷疑寫成定論。
