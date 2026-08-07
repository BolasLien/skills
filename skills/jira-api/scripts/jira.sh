#!/usr/bin/env bash
# Jira CLI wrapper — 透過 REST API v3 操作 Jira Cloud
# 用法: jira <command> [args...]

set -euo pipefail

# 從 ~/.zshrc 提取 JIRA 環境變數（避免 source 整個 zshrc 造成 bash 相容問題）
if [[ -z "${JIRA_EMAIL:-}" ]] || [[ -z "${JIRA_TOKEN:-}" ]] || [[ -z "${JIRA_BASE:-}" ]]; then
  eval "$(grep '^export JIRA_' ~/.zshrc 2>/dev/null)"
fi

: "${JIRA_EMAIL:?Missing JIRA_EMAIL}" "${JIRA_TOKEN:?Missing JIRA_TOKEN}" "${JIRA_BASE:?Missing JIRA_BASE}"

AUTH="-u $JIRA_EMAIL:$JIRA_TOKEN"
API="$JIRA_BASE/rest/api/3"
HEADERS=(-H "Content-Type: application/json")

# ---------------------------------------------------------------------------
# build_adf <text>
# 將 Markdown 轉成 Jira ADF doc，支援：
#   Block：
#     - # / ## / ### ... 標題
#     - - / * 無序列表
#     - 1. 2. ... 有序列表
#     - ``` fenced code block（支援語言）
#     - 空行分段
#   Inline：
#     - `code` inline code
#     - **bold** 粗體
#     - URL 自動轉 link mark
#     - @user 轉 Jira mention（需查 accountId）
# 輸出：ADF document JSON（含 type/version/content）
# ---------------------------------------------------------------------------
build_adf() {
  local text="$1"

  # 預查 @mention 的 accountId
  local mentions_json="{}"
  local username acc
  while read -r username; do
    [[ -z "$username" ]] && continue
    acc=$(curl -s $AUTH "$API/user/search?query=$username" | jq -r '.[0].accountId // empty')
    if [[ -n "$acc" ]]; then
      mentions_json=$(echo "$mentions_json" | jq --arg k "$username" --arg v "$acc" '.[$k] = $v')
    fi
  done < <(echo "$text" | grep -oE '@[a-zA-Z0-9._-]+' | sed 's/^@//' | sort -u)

  MESSAGE="$text" MENTIONS="$mentions_json" python3 <<'PYEOF'
import json, re, os

msg = os.environ['MESSAGE']
mentions = json.loads(os.environ['MENTIONS'])

inline_pattern = re.compile(r'(`[^`]+`|\*\*[^*]+\*\*|https?://\S+|@[a-zA-Z0-9._-]+)')
trim_chars = '.,;:!?)'

def tokenize_inline(line):
    nodes = []
    pos = 0
    for m in inline_pattern.finditer(line):
        start = m.start()
        end = m.end()
        token = m.group(0)

        # URL 末尾標點不算 URL
        if token.startswith("http"):
            while token and token[-1] in trim_chars:
                token = token[:-1]
                end -= 1
            if not token:
                continue

        if start > pos:
            nodes.append({"type": "text", "text": line[pos:start]})

        if token.startswith("`"):
            nodes.append({
                "type": "text",
                "text": token[1:-1],
                "marks": [{"type": "code"}]
            })
        elif token.startswith("**"):
            nodes.append({
                "type": "text",
                "text": token[2:-2],
                "marks": [{"type": "strong"}]
            })
        elif token.startswith("http"):
            nodes.append({
                "type": "text",
                "text": token,
                "marks": [{"type": "link", "attrs": {"href": token}}]
            })
        elif token.startswith("@"):
            username = token[1:]
            if username in mentions:
                nodes.append({
                    "type": "mention",
                    "attrs": {"id": mentions[username], "text": token}
                })
            else:
                nodes.append({"type": "text", "text": token})
        pos = end

    if pos < len(line):
        nodes.append({"type": "text", "text": line[pos:]})
    return nodes if nodes else [{"type": "text", "text": line}]


lines = msg.split("\n")
blocks = []
list_buffer = []
list_type = None
in_code = False
code_lines = []
code_lang = ""

def flush_list():
    global list_buffer, list_type
    if not list_buffer:
        return
    node_type = "bulletList" if list_type == "bullet" else "orderedList"
    items = [
        {
            "type": "listItem",
            "content": [{"type": "paragraph", "content": tokenize_inline(item)}]
        }
        for item in list_buffer
    ]
    blocks.append({"type": node_type, "content": items})
    list_buffer = []
    list_type = None

def emit_code():
    global in_code, code_lines, code_lang
    node = {
        "type": "codeBlock",
        "content": [{"type": "text", "text": "\n".join(code_lines)}] if code_lines else []
    }
    if code_lang:
        node["attrs"] = {"language": code_lang}
    blocks.append(node)
    in_code = False
    code_lines = []
    code_lang = ""

for line in lines:
    # Fenced code block (```lang ... ```)
    if line.startswith("```"):
        if in_code:
            flush_list()
            emit_code()
        else:
            flush_list()
            in_code = True
            code_lang = line[3:].strip()
        continue
    if in_code:
        code_lines.append(line)
        continue

    # Empty line
    if line.strip() == "":
        flush_list()
        continue

    # Heading (# to ######)
    m = re.match(r'^(#{1,6})\s+(.*)', line)
    if m:
        flush_list()
        blocks.append({
            "type": "heading",
            "attrs": {"level": len(m.group(1))},
            "content": tokenize_inline(m.group(2))
        })
        continue

    # Bullet list (- or *)
    m = re.match(r'^[-*]\s+(.*)', line)
    if m:
        if list_type == "ordered":
            flush_list()
        list_type = "bullet"
        list_buffer.append(m.group(1))
        continue

    # Ordered list (1. 2. ...)
    m = re.match(r'^\d+\.\s+(.*)', line)
    if m:
        if list_type == "bullet":
            flush_list()
        list_type = "ordered"
        list_buffer.append(m.group(1))
        continue

    # Paragraph
    flush_list()
    blocks.append({"type": "paragraph", "content": tokenize_inline(line)})

flush_list()
if in_code:
    emit_code()

print(json.dumps({"type": "doc", "version": 1, "content": blocks}))
PYEOF
}

cmd="${1:-help}"
shift || true

case "$cmd" in

  # jira search "JQL query" [maxResults]
  search)
    jql="${1:?Usage: jira search \"JQL\"}"
    max="${2:-20}"
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$jql'''))")
    curl -s $AUTH "$API/search/jql?jql=$encoded&maxResults=$max&fields=key,summary,status,priority,assignee,updated" \
      | jq '.issues[] | {key: .key, summary: .fields.summary, status: .fields.status.name, priority: .fields.priority.name, updated: (.fields.updated | split("T")[0])}'
    ;;

  # jira my [maxResults] — 查我的未完成票
  my)
    max="${1:-20}"
    curl -s $AUTH "$API/search/jql?jql=assignee%3DcurrentUser()%20AND%20status%20NOT%20IN%20(%E5%AE%8C%E6%88%90%2C%20Done)%20ORDER%20BY%20updated%20DESC&maxResults=$max&fields=key,summary,status,priority,updated" \
      | jq '.issues[] | {key: .key, summary: .fields.summary, status: .fields.status.name, priority: .fields.priority.name, updated: (.fields.updated | split("T")[0])}'
    ;;

  # jira get <ISSUE_KEY>
  get)
    key="${1:?Usage: jira get ISSUE_KEY}"
    curl -s $AUTH "$API/issue/$key" | jq '{key: .key, summary: .fields.summary, status: .fields.status.name, priority: .fields.priority.name, assignee: .fields.assignee.displayName, description: .fields.description}'
    ;;

  # jira assign <ISSUE_KEY> [ISSUE_KEY...] — 指派給自己
  assign)
    [[ $# -eq 0 ]] && echo "Usage: jira assign ISSUE_KEY [ISSUE_KEY...]" && exit 1
    account_id=$(curl -s $AUTH "$API/myself" | jq -r '.accountId')
    for key in "$@"; do
      code=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "${HEADERS[@]}" $AUTH "$API/issue/$key" \
        -d "{\"fields\":{\"assignee\":{\"accountId\":\"$account_id\"}}}")
      echo "$key: $code"
    done
    ;;

  # jira transitions <ISSUE_KEY> — 查可用狀態轉換
  transitions)
    key="${1:?Usage: jira transitions ISSUE_KEY}"
    curl -s $AUTH "$API/issue/$key/transitions" | jq '.transitions[] | {id: .id, name: .name}'
    ;;

  # jira transition <ISSUE_KEY> <TRANSITION_ID_OR_NAME>
  transition)
    key="${1:?Usage: jira transition ISSUE_KEY TRANSITION_ID_OR_NAME}"
    target="${2:?Usage: jira transition ISSUE_KEY TRANSITION_ID_OR_NAME}"
    # 如果傳的是名稱，先查 ID
    if [[ ! "$target" =~ ^[0-9]+$ ]]; then
      tid=$(curl -s $AUTH "$API/issue/$key/transitions" \
        | jq -r --arg name "$target" '.transitions[] | select(.name == $name) | .id')
      [[ -z "$tid" ]] && echo "Error: transition '$target' not found for $key" && exit 1
      target="$tid"
    fi
    code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${HEADERS[@]}" $AUTH "$API/issue/$key/transitions" \
      -d "{\"transition\":{\"id\":\"$target\"}}")
    echo "$key -> transition $target: $code"
    ;;

  # jira comment <ISSUE_KEY> "留言內容"
  comment)
    key="${1:?Usage: jira comment ISSUE_KEY \"message\"}"
    msg="${2:?Usage: jira comment ISSUE_KEY \"message\"}"
    adf=$(build_adf "$msg")
    payload=$(jq -n --argjson body "$adf" '{body: $body}')
    response=$(curl -s -w "\n%{http_code}" -X POST "${HEADERS[@]}" $AUTH "$API/issue/$key/comment" -d "$payload")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
      echo "$key comment: $http_code"
    else
      echo "Error ($http_code): $key comment failed" >&2
      echo "$body" | jq . 2>/dev/null || echo "$body" >&2
      exit 1
    fi
    ;;

  # jira create <PROJECT_KEY> <ISSUE_TYPE> "summary" [--parent PARENT_KEY] [--desc "description"]
  create)
    project="${1:?Usage: jira create PROJECT_KEY ISSUE_TYPE \"summary\"}"
    issuetype="${2:?Usage: jira create PROJECT_KEY ISSUE_TYPE \"summary\"}"
    summary="${3:?Usage: jira create PROJECT_KEY ISSUE_TYPE \"summary\"}"
    shift 3
    parent="" desc=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --parent) parent="$2"; shift 2 ;;
        --desc)   desc="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    # 描述用 build_adf 處理（URL → link，@user → mention）
    if [[ -n "$desc" ]]; then
      desc_adf=$(build_adf "$desc")
    else
      desc_adf=""
    fi
    payload=$(jq -n \
      --arg project "$project" \
      --arg issuetype "$issuetype" \
      --arg summary "$summary" \
      --arg parent "$parent" \
      --argjson desc "${desc_adf:-null}" \
      '{ fields: { project: {key: $project}, issuetype: {name: $issuetype}, summary: $summary } }
       | if $parent != "" then .fields.parent = {key: $parent} else . end
       | if $desc != null then .fields.description = $desc else . end')
    response=$(curl -s -w "\n%{http_code}" -X POST "${HEADERS[@]}" $AUTH "$API/issue" -d "$payload")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
      echo "$body" | jq '{key: .key, self: .self}'
    else
      echo "Error ($http_code):" >&2
      echo "$body" | jq . 2>/dev/null || echo "$body" >&2
      exit 1
    fi
    ;;

  # jira edit <ISSUE_KEY> --summary "new title" [--desc "new desc"]
  edit)
    key="${1:?Usage: jira edit ISSUE_KEY --summary \"title\"}"
    shift
    summary="" desc=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --summary) summary="$2"; shift 2 ;;
        --desc)    desc="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    # 描述用 build_adf 處理（URL → link，@user → mention）
    if [[ -n "$desc" ]]; then
      desc_adf=$(build_adf "$desc")
    else
      desc_adf=""
    fi
    payload=$(jq -n \
      --arg summary "$summary" \
      --argjson desc "${desc_adf:-null}" \
      '{ fields: {} }
       | if $summary != "" then .fields.summary = $summary else . end
       | if $desc != null then .fields.description = $desc else . end')
    response=$(curl -s -w "\n%{http_code}" -X PUT "${HEADERS[@]}" $AUTH "$API/issue/$key" -d "$payload")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
      echo "$key edit: $http_code"
    else
      echo "Error ($http_code): $key edit failed" >&2
      echo "$body" | jq . 2>/dev/null || echo "$body" >&2
      exit 1
    fi
    ;;

  help|*)
    cat <<'USAGE'
Jira CLI — usage:
  jira my                          查我的未完成票
  jira search "JQL" [max]          JQL 搜尋
  jira get KEY                     取得單一 issue
  jira assign KEY [KEY...]         指派給自己
  jira transitions KEY             查可用狀態轉換
  jira transition KEY ID|Name      改狀態
  jira comment KEY "msg"           加留言
  jira create PROJ TYPE "title" [--parent KEY] [--desc "desc"]  開票
  jira edit KEY --summary "t" [--desc "d"]  編輯
USAGE
    ;;
esac
