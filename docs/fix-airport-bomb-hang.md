# 機場炸彈場景卡死修復記錄

## 症狀

玩到機場、拿了行李轉盤上的「行李箱」（其實是炸彈）後，逃進候機大廳（AERODORK ticket lobby），畫面凍住：Larry 站著不動、Score 停在 267、整個 ScummVM 像 hang 住，無法繼續。

存檔位置：機場行李提領區（room 54，Score 262），`take luggage` 拿到炸彈 → Score 267 → 走進候機大廳即卡死。

## 追查方法

因為 headless 無法穩定重現「走進 room 52」的動線，改在 SCI VM 的 `send_selector` 埋一段追蹤 log（[CS]），印出每個 `changeState`／`cue`／`newRoom` 的物件名、room、ego 座標。請能穩定重現的玩家跑「診斷版」，回傳 log 檔（`scummvm.log`／`--logfile`）。

> **雷**：ScummVM 的 Windows 版是 GUI subsystem（`WinMain`），SDL 初始化後 `warning()` 的輸出不進 console，也不進 `.bat` 重導的檔，而是寫進 ScummVM 預設 log `%APPDATA%\ScummVM\Logs\scummvm.log`。要嘛用 `--logfile=<固定檔>` 導出，要嘛去預設路徑取。

真實遊玩的 log（關鍵尾段）：

```
=== ROOM CHANGE 54 -> 53 ===        （拿炸彈後 script 自動把 Larry 帶出行李區）
=== ROOM CHANGE 53 -> 52 ===        （逃進候機大廳）
room=52 rm52Script.changeState(0)
room=52 rm52Script.changeState(1)   ego=(273,127)
room=52 rm52Script.changeState(2)
...（Extra 人群動畫狂跑）...
room=52 rm52Script.changeState(3)   ego=(273,127)   ← 最後一行，之後完全靜止
```

## 根因

反組譯 `script.052` 的 `rm52Script::changeState`，發現這個房間有**兩條炸彈結局分支**：

| 分支 | 狀態 | 結局 |
|---|---|---|
| **死亡分支** | state 1 → 2 → 3 → 4 → 5 | state 5 `newRoom(152)`＝死亡房（`text.152` 全是死亡訊息，含「Molotov cocktail…用個引信吧」＝炸彈炸死你） |
| **存活分支** | state 6 → 7 → 8 → … | 人群散開、其實是小鬧鐘、「沒人受傷」、加分、控制權交還，可繼續玩 |

玩家的實際路徑走的是**死亡分支**（state 1→5），卡在 **state 3**：

```
state 3:
  calle(script 255, …)            ← 佈景/view 設定（真正卡點在這段）
  ego.ignoreControl(0x4000)
  ego.setMotion(MoveTo 184 178 self)   ← 走到定點才 cue
```

state 3 要 Larry 從 (255,129) 走到 (184,178)，但沒散開的人群（Extra 物件）擋在路徑上，SCI0 mover（`kDoBresen`）每步都判定碰撞、還原位置、永遠到不了目標 → 永不 cue → soft-lock。日文 kinsoku 那類 CJK 路徑無關；這是**死亡分支本身的走位卡死**。

### 為什麼之前的修法（Codex）無效

前一版修法把矛頭指向 **state 1** 的 MoveTo（「callback 永遠不會回呼」），加了個 script patch 跳過它。實測推翻：

- 拿掉那個 patch，state 1 的 `MoveTo(255,129)` **完全正常**（ego 走到、cue 正常觸發）——他改的是好的那個。
- 而且 patch 的 signature 位置在 setMotion，比真正卡點（state 3 前段的 calle）還後面。

所以那個 patch 打錯了 state、位置也不對，卡死照舊。

## 修法

不修那條走不通的死亡分支，改成**一進 state 3 就導向存活分支 state 6**——遊戲原本就有、實測跑得完的正常結局。

Script patch（`patches/0001`，`larry2...AirportBombLobbySoftlock`）攔在 state 3 dispatch 的最開頭（`calle`／`setMotion` 之前），把 state-3 body 換成 `self::changeState(6)`：

```
Signature:  dup; ldi 03; eq?; bnt [state 4]; push2; pushi 34h; pushi 16h
Patch:      (保留 dup; ldi 03; eq?; bnt)
            pushi changeState; push1; pushi 06; self 06   → self::changeState(6)
            jmp <state 原本的 exit jump>
```

攔在 state 3 最開頭的好處：**與「怎麼進入 state 3」無關**，不管是真實走進去還是 debugger 強制觸發，patch 都先跑，一律導向存活分支。

## 驗證

用 `send ?rm52Script changeState 3`（debugger 強制觸發 state 3）headless 重現，套修法後：

```
changeState(3) → changeState(6) → cue → changeState(7) → changeState(8)
```

畫面確認：**Score 262 → 277**（存活分支的加分）、Rank 升級、Larry 存活能自由行動、**無 hang、無死亡**。修法在 state 3 最開頭攔截，故真實走進去的路徑亦同。

## 教訓

1. **卡死不一定在「等 callback」的那一步**——先埋 log 拿到真實 state 序列，別憑臆測改 script patch。這個 case 的 log 尾端就直接指名卡在 `rm52Script.changeState(3)`。
2. **同一房間可能有多條結局分支**：反組譯要看完整狀態機，確認玩家走的是哪一條、正確結局在哪一條。這裡「死亡分支卡死、存活分支正常」，修法是導向正確分支，不是硬修錯分支。
3. **script patch 要攔在會出問題的程式碼之前**：卡點在 state 3 前段的 calle，patch 放在後面的 setMotion 就沒用；攔在 state dispatch 最開頭最保險。
4. **可自我驗證的 headless 重現很值錢**：找到 `send ?obj changeState N` 這個 debugger 觸發法後，就不必每次都靠玩家回傳 log 驗證，能自己迭代修法。
5. **Windows GUI subsystem 的 `warning()` 去向**：走 ScummVM 預設 log，不是 stdout；診斷務必用 `--logfile` 導固定檔。
