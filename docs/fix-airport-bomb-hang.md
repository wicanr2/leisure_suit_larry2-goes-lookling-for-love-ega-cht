# 機場炸彈場景卡死修復記錄

## 症狀

玩到機場、拿了行李轉盤上的「行李箱」（其實是炸彈）後，逃進候機大廳（AERODORK ticket lobby，room 52），畫面凍住：Larry 站著不動、Score 停在 267、整個 ScummVM 像 hang 住，無法繼續。

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

反組譯 `script.052` 的 `rm52Script::changeState`，整段是一個**線性炸彈過場**（state 1 → 8），玩家卡在 **state 3**：

| 狀態 | 內容 | 說明 |
|---|---|---|
| state 1 | `ego.setMotion(MoveTo 255 129 self)` | Larry 走到定點（正常完成） |
| state 2 | 佈景 view 設定 + timer | 自動前進 |
| **state 3** | 佈景 + `ego.setMotion(MoveTo 184 178 self)` | **卡死點**：走到丟炸彈的定點 |
| state 4 | `ego.setMotion(MoveTo 159 188 self)` | 再走一步（也是走位） |
| **state 5** | `ego.put(炸彈, 255)` + `newRoom(152)` | 丟掉炸彈 → **切到 room 152＝全螢幕「BOOM」爆炸畫面** |
| state 6 | timer(5) | room 152 播完回到 room 52 後續跑 |
| state 7 | `changeScore(15)` + 對白 | 加 15 分、旁白「這確實是清空人群的一種辦法！」 |
| state 8 | 收尾動畫 | 人群已清空，Larry 存活可繼續 |

state 3 要 Larry 從 (255,129) 走到 (184,178)，但沒散開的人群（Extra 物件）擋在路徑上，SCI0 mover（`kDoBresen`）每步都判定碰撞、還原位置、永遠到不了目標 → 永不 cue → soft-lock。日文 kinsoku 那類 CJK 路徑無關；這是**過場走位本身卡死**。

**room 152 是什麼**（用 `SCI_DUMP_PIC` 離線 dump `pic.152` 確認）：一張青色大字「BOOM」＋黃紅爆炸星芒的全螢幕畫面。這就是機場炸彈的「爆炸劇情」。它是一段短暫過場——播完就 `newRoom(52)` 回候機大廳續跑 state 6/7/8。

### 為什麼之前的兩版修法都不對

1. **Codex 版**：把矛頭指向 **state 1** 的 MoveTo（「callback 永遠不會回呼」），加 patch 跳過它。實測推翻——state 1 的 `MoveTo(255,129)` 完全正常，他改的是好的那個；卡點在 state 3。無效。
2. **我方第一版（state 3 → changeState 6）**：確實解掉了 hang，但 **state 6/7/8 是「回到 room 52 後」的存活收尾，跳過了 state 5 的 `newRoom(152)`** → 直接跳過 BOOM 畫面。玩家回報「爆炸劇情不見了」，正是因為這版把爆炸過場一起跳掉了。

## 修法

把卡住的 **state 3 直接導向 state 5**（不是 state 6）：跳過兩個走不通的走位（state 3、4），但**保留 state 5 的 `newRoom(152)`**，所以 BOOM 爆炸畫面照播，播完自然回到 room 52 續跑 state 6/7/8 的存活收尾。

Script patch（`patches/0001`，`larry2...AirportBombLobbySoftlock`）攔在 state 3 dispatch 的最開頭（`calle`／`setMotion` 之前），把 state-3 body 換成 `self::changeState(5)`：

```
Signature:  dup; ldi 03; eq?; bnt [state 4]; push2; pushi 34h; pushi 16h
Patch:      (保留 dup; ldi 03; eq?; bnt)
            pushi changeState; push1; pushi 05; self 06   → self::changeState(5)
            jmp <state 原本的 exit jump>
```

攔在 state 3 最開頭的好處：**與「怎麼進入 state 3」無關**，不管真實走進去還是 debugger 強制觸發，patch 都先跑，一律導向 state 5（BOOM → 存活）。

## 驗證

- **Patch 已套用（byte 級確認）**：headless 反組譯 patched 後的 `rm52Script changeState`，state 3 的 body（offset 0x089c）確為 `pushi 72(changeState); push1; pushi 05; self 06`——正是 `self.changeState(5)`。
- **room 152 = BOOM（獨立確認）**：`SCI_DUMP_PIC` 離線 dump `pic.152`，渲染出青色「BOOM」＋爆炸星芒全螢幕圖。
- **state 5 導向存活**：debugger 強制 `changeState 5`，最終停在 room 52、Score +15（262→277）、Rank 升 Nerd、人群清空、旁白「這確實是清空人群的一種辦法！」，Larry 存活可自由行動——證明 state 5 之後的 `newRoom(152)→回 52→state 6/7/8` 鏈完整跑完。
- 合起來：state 3 → state 5 → 丟炸彈 + `newRoom(152)`（BOOM 播出）→ 回 room 52 → state 6/7/8（加分、存活）。**無 hang、BOOM 保留**。

> **headless 測試雷（記錄備忘）**：ScummVM debugger 的 `room N` 是 **pending 換房**，要 `exit` 恢復遊戲跑一幀才真正載入 script；在同一個暫停中的 console session 內 `send ?rmNScript ...` 會因該 script 尚未實例化而「Invalid address」。且 debugger `send` 對 `newRoom` 的副作用不穩定，觀察過場請用 `SCI_DUMP_PIC`（會在 pic 真正繪製時 dump）而非只看畫面。

## 教訓

1. **卡死不一定在「等 callback」的那一步**——先埋 log 拿到真實 state 序列，別憑臆測改 script patch。log 尾端直接指名卡在 `rm52Script.changeState(3)`。
2. **導向「正確的下一步」，不是隨便一個不卡的狀態**：第一版導向 state 6 雖不卡，卻跳過了 state 5 的 BOOM 過場 → 爆炸劇情不見。要導向**保留關鍵劇情又能跳過卡點**的狀態（state 5）。
3. **script patch 要攔在會出問題的程式碼之前**：卡點在 state 3 前段，patch 攔在 state 3 dispatch 最開頭最保險。
4. **用對的工具看對的東西**：debugger `room`/`send` 對換房與 newRoom 副作用不可靠；要看某房間畫面用 `SCI_DUMP_PIC` 離線 dump pic 資源，才是地面真相（一度被 pic 沒重繪的假象誤導，以為 room 152 是普通 lounge，dump 後才確認是 BOOM）。
5. **Windows GUI subsystem 的 `warning()` 去向**：走 ScummVM 預設 log，不是 stdout；診斷務必用 `--logfile` 導固定檔。
