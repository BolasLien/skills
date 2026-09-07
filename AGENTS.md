# Agent 工作規範

## 需求與驗證

- 禁止猜測使用者意圖或自行補齊缺少的需求。
- 資訊不足、需求含糊或存在會影響結果的不同解讀時，先提出具體問題釐清。
- 無法實際查證的內容必須明確標示為「未驗證」，不得以推測冒充結論。

## 範圍控制

- 只修改使用者要求的範圍。
- 不順手新增功能、重構、調整無關格式或改善未被要求的程式碼。
- 必要的額外變更若超出原始需求，必須先說明原因與影響；高風險或不可逆時先取得確認。

## Shell 工具

優先使用以下專用工具：

| 工作 | 使用 | 避免 |
|---|---|---|
| 尋找檔案 | `fd` | `find`、`ls -R` |
| 搜尋文字 | `rg` | `grep`、`ag` |
| 分析程式結構 | `ast-grep` | 以純文字搜尋取代結構分析 |
| 處理 JSON | `jq` | 手動解析、`python -m json.tool` |
| 處理 YAML／XML | `yq` | 手動解析 |
| Terminal／Pane 操作 | `herdr` | `ps aux`、要求使用者手動操作 |

- 跨 Pane、Terminal 或 SSH 工作優先使用 `herdr pane list`、`herdr pane read`、`herdr pane run` 與 `herdr pane process-info`。
- 缺少必要工具時，能安全安裝就安裝；否則明確說明限制後再選擇替代方案。

## 個人 Linear Issue Tracker

- 使用 Linear workspace `Bolas Dev`（`https://linear.app/bolas-dev`）管理個人規格與 tickets。
- 預設 team 為 `Bolas Dev`（key：`BOL`）。
- 每個 feature 或 refactor 建立一個 Linear Project；完整規格放在該 Project 的 Project Document。
- 每張 implementation ticket 建立為 Project 內獨立的 Linear Issue，標題保留 `01`、`02` 等兩位數順序前綴。
- Ticket 依賴使用 Linear 原生 `blocked by` relation；討論、驗證證據與交付記錄寫入對應 Issue comments。
- Linear 是範圍、狀態、依賴與討論的唯一來源；repo 的 `.scratch/` 只存暫時驗證產物、產生的報告或 recovery drafts。
- 當 skill 要求發布或讀取 issue tracker 時，使用 Linear MCP，並回傳 Linear identifier 與 URL。

## 前端架構

- 前端設計採用 DDD（Domain-Driven Design），以清楚的領域語言與邊界組織功能。
- 遵循 Colocation：元件或 feature 的邏輯、樣式、型別與測試應放在最接近其使用位置的地方。
- 模組介面應優先考量可讀性、可測試性與維護性，避免跨領域耦合。

## Python 套件管理

- Python 套件管理強制且唯一使用 `uv`。
- 禁止使用 `pip`、`venv`、`poetry` 或直接呼叫全域 `python`。
- 新增套件使用 `uv add <package>`。
- 安裝或同步依賴使用 `uv sync`。
- 執行 Python 指令或腳本使用 `uv run <command>`。
- `uv` 無法使用且無法安裝時，停止並回報，不可改用其他套件管理方式。
