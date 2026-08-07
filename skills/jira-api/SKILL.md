---
name: jira-api
description: |
  Jira 票務操作：查票、開票、改狀態、編輯、留言。透過 CLI 腳本操作 Jira Cloud（curl + REST API 為 fallback）。
  當使用者提到 Jira、票、issue、transition、comment，或提到任何 Jira 票號格式（如 `WEB-1234`，依專案而定、不限特定 key）時使用此 skill。
---

# Jira 操作 Skill

透過 CLI 腳本或 `curl` + Jira Cloud REST API v3 操作 Jira。不需要 MCP server。

## 優先使用 CLI 腳本

腳本路徑：這個 skill 目錄下的 `scripts/jira.sh`。

**優先用腳本操作，腳本失敗才 fallback 到 curl。**

```bash
JIRA=<this-skill-dir>/scripts/jira.sh

$JIRA my                                    # 查我的未完成票
$JIRA search "project = WEB" 10             # JQL 搜尋（可指定 maxResults）
$JIRA get WEB-1169                           # 取得單一 issue
$JIRA assign WEB-1553 WEB-1554 WEB-1555      # 批量指派給自己
$JIRA transitions WEB-1169                   # 查可用狀態轉換
$JIRA transition WEB-1169 Done               # 改狀態（支援名稱或 ID）
$JIRA comment WEB-1169 "留言內容"             # 加留言
$JIRA create WEB 任務 "標題" --parent WEB-1272 --desc "描述"  # 開票
$JIRA edit WEB-1169 --summary "新標題" --desc "新描述"        # 編輯
```

## 環境設定

Credentials 存在 `~/.zshrc` 的環境變數中，腳本會自動讀取：

| 變數 | 用途 |
|------|------|
| `JIRA_EMAIL` | 登入帳號 |
| `JIRA_TOKEN` | API Token |
| `JIRA_BASE` | Jira Cloud URL（如 `https://tintint.atlassian.net`）|

## 預設值

> 以下是範例專案的設定，套用到別的 Jira 站台或專案時，換成該專案實際的專案 key，不要假設 `WEB` 通用。

- 預設專案 key：`WEB`（使用者可指定其他專案）
- 預設 maxResults：`20`

## 描述支援 Markdown

`--desc` 的內容會透過 `build_adf` 轉成 Jira ADF。**直接寫 Markdown 就會正確 render**，不需要手組 ADF JSON。

**Block 語法**：

- `#` ~ `######` → heading（1~6 級）
- `-` / `*` 開頭 → 無序列表
- `1.` `2.` 開頭 → 有序列表
- ` ``` lang ... ``` ` → fenced code block（可帶語言）
- 空行分段

**Inline 語法**：

- `` `code` `` → inline code mark
- `**bold**` → 粗體
- URL → 自動 link mark
- `@username` → Jira mention（會自動查 accountId）

**範例**：

```bash
$JIRA create WEB 漏洞 "標題" --parent WEB-757 --desc "## 現象
頁面 \`/xxx\` 冒出 error。

## 根因

- \`format.ts:37\` 的 \`new Date()\` 不一致
- SSR 與 hydrate 時 now 差距造成 text mismatch

## 修正方向

1. 改成接受 \`now\` 參數
2. 用 \`useEffect\` 延後注入"
```

**限制**：

- Bold 不能跨行
- Inline code 不能包含反引號
- 不支援表格、引言、圖片、task list
- 需要更複雜的結構時，fallback 到 curl 手組 ADF

## Fallback：curl 直接呼叫

如果腳本異常，改用 curl + REST API v3 直接呼叫。載入環境變數、API 端點、Issue Types、Transition ID 對照表都在 `references/curl-fallback.md`——只有腳本失敗才需要讀那份文件，正常操作不會用到。

## 操作原則

1. **查詢前確認範圍**：如果使用者沒指定專案，預設用 `WEB`（這是範例站台的預設值，換專案時要換成該站台實際的專案 key）
2. **建立前確認內容**：開票前先跟使用者確認 summary、type、parent（如果是子任務）
3. **改狀態前先查 transitions**：不同狀態下可用的 transition 不同，一律先查再改
4. **結果用表格呈現**：查票結果用 Markdown 表格，方便閱讀
5. **錯誤處理**：如果 curl 回傳非 2xx，把錯誤訊息顯示給使用者
6. **搜尋要廣不要窄**：`text ~` 只搜 summary + description 的文字，很容易漏掉子任務。搜尋某個功能領域的票時，應該用多條件聯集（OR），例如同時搜關鍵字、parent issue、場景代號（C2/C4/C6 等），而不是只靠單一 `text ~`
7. **子任務要分開查**：`$JIRA search` 預設不包含子任務（`issueType in (子任務, "Bug Sub-task")`）。查某個功能或 epic 的完整待辦時，要額外執行一次子任務查詢：
   ```bash
   # 查故事/任務層
   $JIRA search 'assignee=currentUser() AND text ~ "關鍵字" AND status NOT IN (完成,Done)'
   # 查子任務層（用 parent in (...)）
   $JIRA search 'assignee=currentUser() AND issueType in (子任務,"Bug Sub-task") AND project=WEB AND status NOT IN (完成,Done)'
   ```
