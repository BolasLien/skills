# Curl Fallback

只在 `scripts/jira.sh` 異常時才需要讀這份文件。正常操作一律優先用腳本，見 `SKILL.md`。

## 載入環境變數

```bash
export $(grep '^export JIRA_' ~/.zshrc | sed 's/^export //' | xargs)
```

不要用 `eval`，避免執行 `~/.zshrc` 裡其他 shell 指令。

所有 curl 指令用 Basic Auth：`-u "$JIRA_EMAIL:$JIRA_TOKEN"`

## API 端點參考

> **重要**：`/rest/api/3/search` 已被移除（回 410），搜尋必須用 `/rest/api/3/search/jql`。

### 1. 查票（搜尋）

```bash
# GET 方式（簡單查詢）
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/search/jql?jql=<URL_ENCODED_JQL>&maxResults=20&fields=key,summary,status,priority,assignee,updated"

# POST 方式（複雜查詢）
curl -s -X POST -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/search/jql" \
  -d '{"jql":"<JQL>","maxResults":20,"fields":["key","summary","status","priority","assignee","updated"]}'
```

常用 JQL：
- 我的未完成票：`assignee=currentUser() AND status NOT IN (完成, Done) ORDER BY updated DESC`
- 特定專案：`project = WEB ORDER BY updated DESC`
- 特定 issue：`key = WEB-1169`
- 特定狀態：`project = WEB AND status = "進行中"`

回傳結構（新端點）：
```json
{
  "issues": [...],
  "nextPageToken": "...",
  "isLast": true
}
```

顯示結果時，用表格格式呈現，包含：Key、標題、狀態、優先度、更新日期。

### 2. 取得單一 Issue

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/<ISSUE_KEY>"
```

### 3. 建立 Issue

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": {"key": "<PROJECT_KEY>"},
      "summary": "<標題>",
      "issuetype": {"name": "<類型名稱>"},
      "description": <ADF_FORMAT>
    }
  }'
```

**Issue Types（範例站台的自訂中文名稱，不是 Jira 通用預設）：**

這些類型名稱是這個 Jira 站台自己客製的，換一個站台或專案時類型名稱可能完全不同（例如原生 Jira 預設是 Story/Task/Bug/Epic）。改動作前先用 `$JIRA get <ISSUE_KEY>` 或查該站台的專案設定，確認實際可用的類型名稱。

| 名稱（此站台範例） | 是否子任務 |
|------|-----------|
| 大型工作 | 否 |
| 故事 | 否 |
| 任務 | 否 |
| 漏洞 | 否 |
| 子任務 | 是 |
| Bug Sub-task | 是 |

**建立子任務時**，需加 `parent` 欄位：

```json
{
  "fields": {
    "project": {"key": "WEB"},
    "parent": {"key": "WEB-1272"},
    "summary": "子任務標題",
    "issuetype": {"name": "子任務"}
  }
}
```

**Description 格式**：REST API v3 的 description 必須用 ADF（Atlassian Document Format）：

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "描述內容"}
      ]
    }
  ]
}
```

多段落就在 `content` 陣列中加多個 paragraph。需要標題用 `"type": "heading"` + `"attrs": {"level": 2}`。

### 4. 編輯 Issue

```bash
curl -s -X PUT -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/<ISSUE_KEY>" \
  -d '{
    "fields": {
      "summary": "新標題",
      "description": <ADF_FORMAT>
    }
  }'
```

只需傳要改的欄位。

### 5. 改狀態（Transition）

改狀態是兩步驟：先查可用的 transitions，再執行。

**Step 1：查可用 transitions**

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/<ISSUE_KEY>/transitions" | jq '.transitions[] | {id: .id, name: .name}'
```

**Step 2：執行 transition**

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/<ISSUE_KEY>/transitions" \
  -d '{"transition": {"id": "<TRANSITION_ID>"}}'
```

已知的 Transition 參考（範例站台的 workflow ID，不通用）：

Transition ID 是每個 Jira 專案的 workflow 各自設定的，換一個專案或站台幾乎一定不同。這張表只給範例參考，實際操作前一律先執行 Step 1（查可用 transitions）取得當下真正的 ID，不要直接套這張表。

| ID | 名稱 |
|----|------|
| 151 | To Do |
| 131 | In Progress |
| 121 | QA |
| 111 | Ready |
| 91 | Review |
| 101 | Done |
| 71 | Reopened |
| 41 | 內部審查 |
| 31 | Stop task |
| 61 | Complete the task |

### 6. 加留言

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/<ISSUE_KEY>/comment" \
  -d '{
    "body": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "留言內容"}]
        }
      ]
    }
  }'
```
