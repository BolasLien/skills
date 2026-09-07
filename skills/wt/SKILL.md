---
name: wt
description: >
  管理 git worktree 生命週期。建立：自動分配 port 4000-4007、分析任務產生分支名、
  目錄命名為 wt-{port}-{feature}、安裝依賴並啟動 dev server。清理：檢查未提交異動、
  停止 dev server、移除 worktree 不問合併。列表：顯示所有 worktree 及其分支描述。
  觸發：/wt、「開 worktree」、「新開一個環境」、「清 worktree」、「結束 worktree」、
  「收工」。即使使用者只說「開一個來做 XXX」也應觸發。
---

# Worktree 管理

透過 `/wt` 管理此專案的 git worktree，包含建立、清理、列表三個指令。

## 指令格式

```
/wt [base-branch] <任務描述與補充資訊>   建立 worktree
/wt exit                                 清理 worktree
/wt list                                 列出所有 worktree
```

## 建立 Worktree

觸發：`/wt` 後面接的不是 `exit` 也不是 `list`。

### Step 1：解析參數

參數的第一個詞如果是已存在的 git 分支名，就當作基底分支，剩餘文字為任務描述與補充資訊。
如果第一個詞不是分支名，則整段都是任務描述，基底分支用當前所在分支。

```bash
# 檢查第一個詞是否為已存在的分支
git rev-parse --verify <first-word> >/dev/null 2>&1
```

### Step 2：分析任務，產生分支名稱

根據任務描述判斷分類：

| 任務性質 | 前綴 |
|---------|------|
| 新功能、新增頁面、新增欄位 | `feat/` |
| 修 bug、修正錯誤 | `fix/` |
| 重構、調整結構 | `refactor/` |
| 樣式調整 | `style/` |
| 文件更新 | `docs/` |

分支名稱格式：`{前綴}{簡短描述-kebab-case}`。
例如：`feat/collection-winning-settings`、`fix/login-redirect-loop`。

如果上下文不足以判斷分類或描述，詢問使用者。

### Step 3：分配 Dev Server Port

從 4000~4007 中選一個未被佔用的 port：

```bash
for port in $(seq 4000 4007); do
  lsof -iTCP:$port -sTCP:LISTEN -t >/dev/null 2>&1 || { echo "$port"; break; }
done
```

選最小的可用 port。

### Step 4：建立 Worktree

目錄放在專案根目錄的 `.worktrees/` 下。
目錄名為 `wt-{port}-{feature}`，feature 取分支描述段（去掉 feat/ 等前綴），保持簡短。

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# 確認 .worktrees 在 .gitignore 中
cd "$PROJECT_ROOT"
git check-ignore -q .worktrees 2>/dev/null || echo ".worktrees" >> .gitignore

# 建立
git worktree add ".worktrees/wt-${PORT}-${FEATURE}" -b "${BRANCH_NAME}" "${BASE_BRANCH}"
cd ".worktrees/wt-${PORT}-${FEATURE}"

# 偵測 package manager 並安裝依賴
if [ -f pnpm-lock.yaml ]; then
  pnpm install
elif [ -f yarn.lock ]; then
  yarn install
else
  npm install
fi
```

### Step 5：啟動 Dev Server

必須先 cd 到 worktree 目錄再啟動，避免 Next.js 偵測到多個 lockfile 產生路徑混亂。

```bash
cd "${PROJECT_ROOT}/.worktrees/wt-${PORT}-${FEATURE}"

# 用 PORT 環境變數指定 port（適用於 Next.js / Vite 等主流框架）
if [ -f pnpm-lock.yaml ]; then
  PORT=${PORT} pnpm --filter web dev
elif [ -f yarn.lock ]; then
  PORT=${PORT} yarn dev
else
  PORT=${PORT} npm run dev
fi
```

在背景執行，不阻塞對話。

### Step 6：回報就緒

用以下格式回報：

```
Worktree 就緒
  路徑：.worktrees/wt-4001-collection-winning
  分支：feat/collection-winning-settings（基於 main）
  Port：4001
  補充：活動 slug 使用 2025-baseball
```

「補充」欄位放使用者提供的任務相關資訊，原文保留，作為後續工作的上下文。
如果沒有補充資訊則省略此欄。

---

## 清理 Worktree（/wt exit）

### 判斷要清理哪個 worktree

依照以下優先順序：

1. **cwd 在某個 worktree 內** → 清理當前這個
2. **只有一個 worktree** → 直接清那個
3. **有多個 worktree** → 列出所有 worktree（同 `/wt list` 格式），讓使用者選

### Step 1：檢查未提交異動

```bash
cd "${WORKTREE_PATH}"
git status --porcelain
```

- **有異動** → 列出異動檔案，提醒使用者。停在這裡，等使用者決定怎麼處理。
- **沒異動** → 繼續。

### Step 2：停止 Dev Server

找到該 port 上的 process 並停止：

```bash
lsof -iTCP:${PORT} -sTCP:LISTEN -t | xargs kill 2>/dev/null
```

### Step 3：移除 Worktree

```bash
cd "$PROJECT_ROOT"
git worktree remove ".worktrees/wt-${PORT}-${FEATURE}"
```

不詢問是否合併。分支保留在 git 中，使用者需要時自行處理。

### Step 4：回報完成

```
已清理 wt-4001-collection-winning
  分支 feat/collection-winning-settings 保留在 git 中
```

---

## 列出 Worktree（/wt list）

列出 `.worktrees/` 下所有 worktree，每個顯示目錄名、分支名、port、最新 commit message 作為描述。

```bash
git worktree list --porcelain
```

輸出格式：

```
目前 Worktree：
  wt-4000-collection-winning  (feat/collection-winning-settings) port:4000
    → 得獎名單改用 permalink 並顯示獎項名額
  wt-4001-login-fix           (fix/login-redirect-loop)          port:4001
    → 修正登入後重導向跑回首頁的問題
```

描述從該 worktree 分支的最新 commit message 取得。
如果沒有任何 worktree，回報「目前沒有 worktree」。
