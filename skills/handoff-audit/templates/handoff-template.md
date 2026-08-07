# <Task Handoff Title>

<!-- Canonical path: docs/handoffs/<task-slug>.md -->

## 先知道這件事在做什麼

用幾段話說明這一個任務：

- 這個功能或問題是什麼
- 使用者真正想解決什麼
- 這份 handoff 明確包含哪些工作
- 哪些相鄰工作屬於其他任務，不包含在這份 handoff

讓今天才加入專案的人先建立單一清楚主線。

## 現在做到哪裡

說明這個任務目前主要是在實作、除錯、驗證、穩定化，還是準備交付。

只寫定義這個任務目前階段的 gap、進行中的 source 修改與 blocker。不要混入其他並行任務的 repository 狀態。

## <Relevant System> 現在怎麼運作

用目前真實流程建立 mental model。

```text
User action
→ state change
→ request or processing
→ runtime behavior
→ observable result
```

只描述現在的系統。不要把舊架構當成更新紀錄保留。

## 幾個不能重新猜的決策

只保留仍約束這個任務未來工作的決策：

- 現在的規則
- 必要時簡短說明原因
- 不要重新引入的錯誤方向

## 接下來先做什麼

依優先順序列出這個任務內的剩餘工作。

每一項必須可獨立驗證，並說明：

- 要做什麼
- 為什麼需要做
- 怎麼驗證
- 什麼算完成
- 什麼情況應停止並回報

如果某項工作有獨立目標、完成邊界或可能由不同人接手，應建立另一份 handoff，不要繼續擴張本文件。

## 程式碼從哪裡看

依「要改什麼／查什麼」提供最小 investigation entry points。

不要列完整 changed-file inventory，也不要列其他任務的檔案。

## 現在已知的風險與未知

只保留尚未解決、仍可能影響這個任務的事項。描述實際後果與已有 fallback。
