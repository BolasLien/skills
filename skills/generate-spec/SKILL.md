---
name: generate-spec
description: Use when the user wants to create, draft, revise, or structure a product spec, functional specification, feature spec, PRD, or acceptance criteria.
---

# Skill: Generate Product / Functional Spec

本技能用於引導 AI 協助團隊撰寫正式的功能與產品規格書 (PRD / Functional Spec)。本規範旨在確保規格書結構清晰、符合團隊的敏捷開發節奏，並透過前置查證與分類後標記 `[尚未確認]`，防止 AI 自行腦補不確定的業務或設計細節。

---

## 1. 模板選擇規則 (Template Selection Rules)

在接收到規格書撰寫任務時，應優先評估專案規模與變更範圍，並依據以下條件自動選擇合適的模板：

### 1.1 輕量版模板 (Lite Template)
* **適用條件**（須全部符合）：
  1. **無** 後端 API 變動與新增。
  2. **無** 全局狀態管理（如 Zustand/Redux）資料流變動。
  3. 僅限於單一或少數 UI 元件的視覺修改、操作手勢優化或防禦性 Bug 修復（例如：加個 loading 效果、防誤觸滑動）。
* **結構要求**：包含「背景與修改對象」、「功能需求與狀態變化」、「驗收標準」三大區塊。

### 1.2 標準版模板 (Standard Template)
* **適用條件**（符合任意一項）：
  1. 涉及跨組件的全局邏輯重構。
  2. **有** 資料結構、資料流變動或新增/修改 API。
  3. 涉及數據埋點、發佈 Feature Flag 及風險追蹤。
  4. 全新功能模組開發。
* **結構要求**：包含「背景與目標」、「範圍」、「使用者情境」、「功能需求」、「UI / UX 規格」、「資料與 API」、「驗收標準」、「上線與追蹤」八大板塊。

---

## 2. 規格前置查證與不確定性分類 (Evidence & Uncertainty Triage) - 必讀

撰寫規格前，先從使用者提供的內容、現有程式碼、文件、設定、API schema 與設計來源建立事實基線。若需求涉及搬移、封裝、發布、替換或延伸既有元件／模組，必須先檢查既有實作與公開 contract；既有 props、dependencies、exports、資料格式與行為不得重新當成設計選項。

將缺少的資訊分成以下四類，並依指定方式處理：

| 類型 | 判斷方式 | 處理方式 |
| --- | --- | --- |
| 可查證事實 | 能從現有程式碼、文件、設定、API schema 或設計稿確認 | 先查證並寫入 spec，不標記 `[尚未確認]` |
| 工程實作決策 | 不改變產品範圍、公開 contract、ownership 或使用者行為，可由技術限制與驗證結果決定 | 寫成工程限制、實作原則或驗證條件，不要求使用者逐項決策 |
| 產品／架構／組織決策 | 不同答案會改變 scope、公開 contract、ownership 或使用者行為 | 標記 `[尚未確認：...]`，並以具體選項要求使用者確認 |
| 與本次無關 | 不影響本次目標或完成條件 | 移至 Out-of-Scope 或刪除，不保留為待決問題 |

### `[尚未確認]` 寫入前檢查

每個 `[尚未確認]` 寫入 spec 前，依序完成：

1. 能從現有 repository、文件、設定、API schema 或設計來源查到嗎？能則先查證。
2. 只是 build、CI、bundler、package manager 或其他不改變公開 contract 的工程細節嗎？是則改寫成工程限制或驗證條件。
3. 不同答案會改變 scope、公開 contract、ownership 或使用者行為嗎？會才保留 `[尚未確認]` 並詢問使用者。
4. 影響本次完成條件嗎？不影響則移至 Out-of-Scope 或刪除。

**核心原則：`[尚未確認]` 是查證與分類後的最後結果，不是遇到不確定資訊時的預設標記。**

### 範例

既有 UI package 搬移為私有套件時：

- 現有 Button props 與 dependencies：讀取原始碼與 manifest，列為可查證事實。
- ESM build、tree-shaking 與 CI job 實作：依 consumer 限制寫成工程驗證條件。
- package ownership、公開 API 是否允許 breaking change：若會改變責任或 contract，標記 `[尚未確認]` 並詢問。
- 與首次發布無關的 Feature Flag：列為 Out-of-Scope，不建立待決問題。

### 常見錯誤

- 未讀既有實作就重新詢問已存在的 props、狀態或資料格式。
- 把所有技術選項都列成 A／B／C，將工程責任轉交使用者。
- 為填滿模板而虛構 Loading、Empty、Feature Flag、Analytics 或 rollout 需求；不適用時應明寫「不適用」。
- 將不影響本次完成條件的項目保留成 `[尚未確認]`，造成無限延伸的決策清單。

---

## 3. 核心防腦補規範 (Anti-Hallucination Guardrail) - 必讀

> [!IMPORTANT]
> 為了確保規格書能進行二次討論與完善，**嚴禁直接推論不確定的細節**。凡符合以下特徵之資訊，在規格書中必須統一標記為 **`[尚未確認：例如...]`**：
>
> 1. **具體像素、尺寸與色碼**：例如拖曳閾值（`10px`）、縮圖大小（`80px * 80px`）、高亮顏色（`#E79945`），除非代碼中已有明確寫死之常量，否則皆須標記。
> 2. **效能指標數值**：例如動畫延遲毫秒數（`100ms`）、預期幀率（`60 FPS`）。
> 3. **平台與相容性版本**：例如特定之瀏覽器與 iOS/Android 版本支援清單。
> 4. **資料庫或 API 欄位細節**：若現有代碼未定義該 API 或欄位結構，嚴禁自行虛構。
> 5. **業務與上線指標**：例如客訴降低率、轉換率等無法由前端代碼得出的數據。
> 6. **數據追蹤 (Analytics) 埋點**：預期要追蹤的自定義事件名稱。

---

## 3.5 Figma 驅動或視覺類規格 - 必讀

當規格涉及指定 Figma node、或使用者已驗收的視覺結果時，先讀 `docs/agents/figma-visual-delivery.md`——來源優先序、node property checklist、shared-CSS baseline、視覺／runtime 證據分離、測試授權門檻唯一以該文件為準，本節不重述。依該文件規則撰寫本規格，第 2、3 節的一般查證與 `[尚未確認]` 分類不適用於視覺數值（視覺數值改用該文件的來源優先序判斷，不用查證/分類表）。

此範圍下的規格特有規則：
- 第 7 節的 AC（Given-When-Then）只描述可觀察正確性；是否新增/修改/執行自動化測試依 canonical 文件的測試授權門檻另外取得使用者授權，不因為本規格列了 AC 就預設列入測試新增或修改（此限定僅適用本節所述之 Figma 驅動／視覺類規格，其餘規格仍依第 7 節一般規則撰寫測試場景）。
- 修改共享 CSS／元件時，Scope／Out-of-Scope 章節須聲明本次允許變更的 selector／狀態。

**完成條件**：規格內每一個視覺數值都能對應 canonical checklist 的一列（source／value／未解 gap 三者之一有記錄），且沒有視覺數值落入第 2 節的 `[尚未確認]` 分類表。

---

## 4. 標準版規格書結構規範 (Standard Specification)

標準版規格書必須且僅能包含以下 8 大板塊，並緊扣 **Why**、**What**、**Behavior**、**Done** 四大核心：

### 1. 背景與目標 (Background & Goals)
* **Why**：說明為什麼要做這個需求、解決用戶或系統的什麼痛點。
* **目標**：列出具體預期解決的問題。
* **成功標準**：列出可判斷此需求達成的結果或指標（無法由程式碼證實的數據指標須標記為 `[尚未確認]`）。
* **格式**：章節內必須使用 `### Why`、`### 目標`、`### 成功標準` 作為子標題。

### 2. 範圍 (Scope)
* **What**：明確定義本次迭代要做什麼（In-Scope）與不做什麼（Out-of-Scope），畫清開發邊界。
* **格式**：章節內必須使用 `### In-Scope`、`### Out-of-Scope` 作為子標題。

### 3. 使用者情境 (User Scenarios)
* **Who/When/Flow**：說明誰是主要使用者、在何種情境下使用，以及完整的使用者操作主路徑 (Key Flow)。
* **格式**：章節內必須使用 `### Who / When` 與 `### Key Flow x：流程名稱` 作為子標題。

### 4. 功能需求 (Functional Requirements)
* **Behavior**：條列出所有功能點。每一個功能點必須使用獨立標題呈現，格式為 `### Fx：功能短標題`；標題下必須包含以下子欄位（不得合併）。
  ```text
  ### Fx：功能短標題

  - 操作流程：
  - 欄位規則：
  - 狀態變化：
  - 錯誤處理：
  - 權限限制：
  ```

### 5. UI / UX 規格 (UI/UX Specs)
* **Behavior**：詳細說明介面互動。必須明確定義並區分以下狀態的表現：
  * `### 畫面與互動`（含觸發閾值等說明）
  * `### Loading 狀態`
  * `### Empty 狀態`
  * `### Error 狀態`
  * `### Disabled 狀態`

### 6. 資料與 API (Data & API)
* 說明資料來源、資料格式。
* 列出涉及的 API Request/Response 與錯誤碼（若無變動，則說明延用既有機制；若未定案，則標記 `[尚未確認]`）。
* **格式**：章節內應依需求使用 `### 資料來源`、`### 資料格式`、`### API`、`### 後端依賴` 或同等語意子標題。

### 7. 驗收標準 (Acceptance Criteria)
* **Done**：至少提供 3 個核心測試場景。每個場景必須有獨立標題，格式為 `### ACx：場景名稱`，標題下必須嚴格採用 bullet + 粗體關鍵字的 `Given-When-Then` 語法撰寫。
  ```text
  ### ACx：場景名稱

  - **Given** ...
  - **When** ...
  - **Then** ...
  ```

### 8. 上線與追蹤 (Rollout & Metrics)
* 說明上線部署方式、風險防範（如 Feature flag 控制）以及上線後需要追蹤的業務/技術指標（不確定的指標一律標記 `[尚未確認]`）。
* **格式**：章節內必須使用 `### 上線方式`、`### 風險防範`、`### 上線後追蹤` 作為子標題。

---

## 5. 輕量版規格書結構規範 (Lite Specification)

輕量版規格書僅保留最核心的 Why、Behavior 與 Done，結構縮編為以下 3 大區塊：

### 1. 背景與修改對象 (Context & Target)
* 說明此修改要解決的特定 UI Bug 或手勢體驗優化背景。
* 明確列出此異動會影響的元件 (Component) 名稱或檔案路徑。

### 2. 功能需求與狀態變化 (Behavior)
* **互動流程**：簡單描述用戶如何與此修改元件互動。
* **狀態矩陣**：定義此元件在修改後的 UI 狀態變化（如 Default, Active, Hover, Disabled 等狀態的視覺或防誤觸行為）。

### 3. 驗收標準 (Acceptance Criteria)
* **Done**：提供 1-2 個核心驗收場景，並使用 `Given-When-Then` 格式撰寫。
