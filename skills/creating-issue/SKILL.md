---
name: creating-issue
description: Issue 文件撰寫流程協作。使用者想回報問題、開票、提改善建議、做成 issue 文件時觸發。協助走完五階段：研究驗證問題真的存在 → 討論問題本質與業界佐證 → 等明確授權才產出檔案 → 用使用者面語言撰寫且不寫實作細節 → 寫完不 commit、surgical iteration。觸發詞例：「開一張票」「回報 issue」「做成 issue」「寫成 issue 文件」「提一個優化」「建議改 X」「我想記下這個問題」「優化票」「issue 文件」。即使使用者只描述了一個問題、暗示想寫起來，也應該觸發——不要等使用者明說「issue」這個字。
---

# Creating an Issue Document

寫一份 issue 文件不只是「寫出 markdown」——是一個多階段的協作流程。Issue 是「提案人 → 其他 stakeholder」的溝通橋樑：提案人的責任是把問題講清楚並提供佐證，**不是替別人規劃怎麼解**。

這個 skill 把流程明確化，避免常見失敗模式：
- 跳過驗證直接寫（issue 被「真的有這個問題嗎」反駁）
- 越界做別人的工作（issue 變 spec）
- 用工程語言寫給混合讀者（PM / UIUX 看不懂）
- 沒得到授權就直接 Write 檔案

---

## Phase 1: 驗證問題真的存在

使用者通常以**觀察**或**猜測**起頭，例如「這個功能會跳 alert 對吧？」「我們是不是還在用 X？」。

**不要憑印象同意或反對**——先用工具實際確認：

- `rg` / `fd` / `ast-grep` 搜尋程式碼確認問題存在
- 計算規模：多少處、多少檔案、佔比、與「正確解」的比例
- 看 repo 有沒有既有的「正確解」可以對照（**這發現很關鍵**——可能設施已存在、只是沒被用）
- 找典型的觸發場景（哪些使用者流程會踩到）

**目的**：讓後面的討論建立在事實上。沒有數據的「應該要改」很容易被反駁；有數據才能說服 PM / UIUX。

如果工具確認問題不存在或規模很小，**告訴使用者**而不是硬寫——這比寫一份沒事實基礎的 issue 更有價值。

---

## Phase 2: 討論問題本質

確認問題存在後，跟使用者討論：

- 這是 **problem**（客觀傷害）還是 **preference**（個人偏好）？前者值得寫 issue，後者不值得。
- 業界 / UX research / 標準怎麼說？引用 MDN、Nielsen Norman Group、Material Design、W3C ARIA、Web Almanac 等可信來源。
- 影響範圍是什麼？哪些使用者流程會踩到？影響使用者體驗、品牌、無障礙還是什麼？

**不要跳過這一步直接寫**。讓使用者也理解為什麼這是問題，他們才有信心拿這份 issue 去說服別人。

---

## Phase 3: 等明確授權才寫檔案

寫 issue 是有副作用的動作（產出檔案）。**等使用者明確說「開一張票」「做成 issue」「寫成 issue 文件」這類授權詞才進 Phase 4**。

- ❌ 不主動建議「要不要我幫你寫一份 issue？」
- ✅ 等使用者開口

**為什麼**：使用者可能還在想要不要 escalate、可能想等其他人 input、可能只是口頭討論。自己主動建議是越界。

---

## Phase 4: 產出 issue 檔案

### Standard structure

以 `assets/ISSUE_native_alert.md` 為 worked example。標準段落如下，依當下需求增減：

```markdown
# Issue：[一句話 summary]

## 問題
[問題的本質是什麼；最重要的數據放這裡：規模、比例失衡]

## 為什麼是問題
[多個論點：技術影響、使用者體驗、品牌、無障礙、業界共識]

## 典型錯用案例
[表格列具體場景，全用使用者面語言]

## 範圍
[影響哪些產品 / 哪些使用者流程]

## 佐證
[數據統計 + 最常發生問題的使用者流程]

## 參考
[業界文章 / 標準 / 文件連結]
```

不需要每份都湊滿所有段落，依議題增減。

### Audience-first language

Issue 的讀者通常是混合的：PM、UIUX、Eng 都會看。**寫完掃一遍**，把所有檔名、code path、commit hash、git 指令、shell 指令、function 名稱替換成產品語言：

| ❌ 工程語言 | ✅ 使用者面 / 產品面語言 |
|---|---|
| `SaveButton.tsx` | 表單的儲存按鈕 |
| `src/features/import/`、`src/features/editor/` | 匯入流程與內容編輯流程 |
| `commit abc1234` | 撰寫 issue 時的版本 |
| `rg --pcre2 'alert\('` | （拿掉，移到 SPEC.md）|
| `FinishControl.js`（12 處）| 完稿流程（12 處）|

對每個程式術語問自己：「PM 看了懂嗎？」不懂就翻譯。

如果想保留工程驗證資訊（grep 指令、檔案分佈、code path），放到另一份 `SPEC_*.md` 工程文件，不要污染 issue。

### Content blacklist（不寫進 issue）

提案人的工作是「指出問題」，不是「規劃別人怎麼解」。以下都越界，不寫進 issue：

| 不寫 | 為什麼 |
|---|---|
| PR 切分計畫（P0/P1/P2…）| 工程實作細節，越界 |
| 工作天 / 人月估算 | PM 的工作，不要替他算 |
| Helper / utility / refactor 提案 | 工程實作細節 |
| ESLint rule / 開發工具建議 | 工程實作細節 |
| Open Questions 列一堆給別人決定 | 別替 stakeholder 列待辦 |
| UIUX 需要設計的新東西規格 | 越界做設計師的事 |
| 實作步驟、code snippet、API 簽章 | 工程實作細節 |

需要記錄這些細節，另開 `SPEC_*.md`，issue 連結過去即可。

### Before writing the file

**寫檔案前先口頭預覽**：列出打算寫的段落和主要 bullet points，讓使用者口頭確認。等使用者明確說「改吧 / 寫吧 / 動手 / OK 開始 / go」才用 Write 寫檔案。

- 「我有足夠資訊了」**不是**授權
- 「使用者好像不耐煩了」**不是**授權
- 「這是我自己創的 draft、覆寫低風險」**不是**授權

Write / Edit 的授權必須來自使用者明確的授權詞。

---

## Phase 5: 迭代修正

寫完 issue 後：

- **不 commit**——等使用者手動 review。
- 使用者指出某段問題時，**只修那一段，不重寫整份**。Surgical changes。
- 同類問題可以順便**點出**（例如「這個檔名問題在另外兩段也有」），但是不是要一起改要**先問**。
- 改完不主動加新段落、不主動「順手優化」相鄰文字。

---

## Anti-patterns 速查

| 反模式 | 為什麼不好 |
|---|---|
| 跳過 Phase 1、根據使用者猜測就寫 | 數據沒驗證，issue 容易被反駁 |
| 主動建議「我幫你寫一份 issue 吧？」 | 越界主動性，使用者還沒決定要不要 escalate |
| 寫進 PR 切分 / 工作天估算 / helper 提案 | 越界做別人的工作，issue 失焦變 spec |
| 用 `SaveControl.js`、`src/app/...` 等程式語言 | 非工程讀者看不懂，失去說服力 |
| 沒明確授權就 Write 檔案 | 違反「等明確授權」原則 |
| 使用者改一段時順手改其他相關段落 | 越界修改未授權內容 |
| 結尾列十幾個 Open Questions 給別人決定 | 替 stakeholder 列待辦，越界 |

---

## Output location

預設寫到 `docs/ISSUE_<topic>.md`，topic 用 kebab-case 描述問題（例：`docs/ISSUE_native_alert.md`）。

如果 repo 有既有的 issue 模板路徑（如 `.github/ISSUE_TEMPLATE/`、Jira 模板），優先對齊那個位置。

---

## Reference

`assets/ISSUE_native_alert.md` 是這個 skill 的虛構 worked example——「以產品內通知取代非必要的 native `alert()`」這個案例的完成版 issue 文件。專案名稱、元件名稱與數字僅供示範，可作為新 issue 撰寫時的結構、語氣、用詞範例，不可當成真實盤點結果。
