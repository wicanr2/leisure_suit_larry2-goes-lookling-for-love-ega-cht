# 幻想空間II / Leisure Suit Larry 2 中文化 — CONTEXT

## 引擎軌
- **SCI0 EGA**（RESOURCE.001-006 + RESOURCE.MAP + SCIV.EXE）。ScummVM 偵測 ID = `sci:lsl2`。
- 中文文字啟用：`--language=tw`（ZH_TWN），走 SCI0 EGA **hi-res 640×400 upscaled** 路徑，Big5 32px 字模銳利。
- 複用基底 = **KQ4**（同 SCI0 EGA，engine patch/tools/docker/打包全套）。上游 pinned commit `3d408ec3516f7c29314d8ae8fb7916f31c9cd9aa`。
- 目前**尚未搬 scummvm-src**：增量一直接複用 KQ4 已編 binary（engine patch 為 ZH_TWN gated、game-agnostic）跑起來驗證。
  需改 engine（LSL2 標題疊圖 pic id / copy-protection 中文化）時再搬 scummvm-src 進來重編。

## 語料規模（增量一抽字結果）
- `text.*` 資源：2235 則
- `script.*` 內嵌 Print 字串：144 則
- 合併去重 `translation/full_skeleton.tsv` = **2379 則、約 156K 英文字元**
- **LSL2 無 VGA remake** → 同劇情他版譯本複用來源少；前作 Sierra 通用 parser 回應複用 **105 則（4%）**，已種進 `translation/batch/00-reuse.tsv`。
- 無 `message.*` 資源（早期 SCI0 用 text 資源，非 message 系統）。

## 風格
- **台式在地化**（延續 QFG/KQ4/LSL1）。LSL2 為成人喜劇，語氣可放開。
- 角色/地名以中文手冊《珍004-幻想空間Ⅱ》為準（`../manual/`）。

## 字型 / build
- `tools/build_translation.sh`：merge batch → converge → build_cht(16px) + bake_hires(32px) → `game/{translation.tsv,qfg1_big5.fnt,qfg1_big5_hi.fnt}`。
- 字型檔名沿用 `qfg1_big5*.fnt`（engine 寫死此名，勿改）。烘字來源 uming.ttc（本機有）。
- batch 為 **UTF-8**；build_cht 最後才轉 Big5 runtime tsv。

## 已知待辦 / 雷
1. **版權保護畫面**（開場，"complete her telephone number 555-___"）會**擋住進度**，headless 無法過 → 全流程 playtest 需處理（專案根有 `lsl2_loader_v1.1-copy-protection-bypass.rar`；KQ4 有 copy_protection 工具可參考）。此畫面同時是絕佳的靜態渲染驗證標的。
2. **版權框 2 行高**：譯文「…電話號碼：」末尾被截（此 script 對話框行高固定）→ 翻譯階段版權提示要壓短或查框自適應。
3. 標題疊圖、狀態列、選單 baked-art（view）尚未處理。
