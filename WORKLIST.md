# LSL2 中文化 WORKLIST

## 增量一 ✅（建置 + 抽字 + 跑起來）— 2026-07-12
- [x] 建 workplace（複用 KQ4 tools/docker/patches/.github）
- [x] ScummVM 偵測 `sci:lsl2`（KQ4 binary，qfg1-build 容器）
- [x] 抽字：text 2235 + script 144 → `full_skeleton.tsv` 2379 則
- [x] 前作複用種子 105 則（`batch/00-reuse.tsv`）
- [x] 烘 Big5 16px + 32px hi-res 字型
- [x] headless 驗證：英文可跑 + **Big5 hi-res 中文銳利渲染**（版權保護畫面，`screenshots/m1-copyprotect-cht.png`）

## 增量二（翻譯）✅ — 2026-07-12
- [x] GLOSSARY.md 角色/地名術語表 + 台式風格指南
- [x] fan-out 23 個 sonnet 子代理翻完 2268 則（+ 105 複用 + 2 驗證）
- [x] validate：2268 行、0 skeleton 未命中、0 佔位符不一致
- [x] converge.tsv 統一譯名變體（onklunk→昂克隆、Nontoonyt→農圖尼特、Al Lowe→艾爾·洛威、Chief→凱尼瓦瓦）
- [x] 修簡繁誤用（担→擔）、`～` 由 build_cht 修正網處理
- [x] **覆蓋 2362/2379（99%）**，17 則刻意不譯（ASM 謎題/假西文/系統碼）
- [x] 渲染驗證：失敗訊息整段中文正確 word-wrap（`screenshots/m2-copyprotect-fail-cht.png`）
- [ ] 待增量三 playtest 時對「in-game NPC 對白」再實機校（現被版權保護擋住）

## 增量三（引擎/UI/美術）— 進行中
- [x] 搬 scummvm-src 進 workplace（已 patch + 已 configure）
- [x] **版權保護 bypass**：`kStrCmp` 加 env-gated hook（`SCI_CP_BYPASS`：運算元符合 `555-dddd` 時強制相等；`SCI_CP_LOG` 記錄）。回填 patches/0001（11 檔、692 行、dry-run 通過）
- [x] **in-game 中文實機驗證**：開場旁白框整段中文正確（伊芙＝Eve，`screenshots/m3-ingame-narration-cht.png`）
- [x] copy-protection 提示 + 失敗訊息中文（`screenshots/m2-*`）
- [x] 狀態列：`Score: %d of %d Rank: %s` 走 font 0 不支援 Big5 → 還原英文（`Score: 0 of 500 Rank: Novice` 乾淨）
- [x] 選單燒屏修正：選單列標題 Action/Speed/Sound + 項目 Quit/Save/Cancel 走 hi-res drawHiRes 直寫會殘影 → 還原英文（`batch/99-ui-english.tsv`）。頂端已乾淨（`screenshots/m3-ingame-street-clean.png`）
- [x] 標題疊圖：LSL2 EGA **無獨立標題 logo 畫面**（開機→版權房 pic 10→街景 pic 23）→ 不適用，可省
- [ ] 決策：release 是否預設開 SCI_CP_BYPASS（player-friendly）或保持忠實（附電話簿）— 增量四定案
- [ ] （選）F8 中英切換；（選）修 hi-res 選單殘影根因後可還原中文選單

## 增量四（打包 + 驗收）— 進行中
- [x] MT-32 enable 驗證（`grep USE_MT32EMU config.h` = defined）
- [x] **Linux AppImage full**（含遊戲+中文+MT-32 ROM）→ `dist-all/`，[HARD] 驗收含 RESOURCE.*+ROM ✅
- [x] **Linux AppImage patch**（引擎+中文，不含遊戲/ROM）→ `out/release/`，[HARD] 驗收 0 RESOURCE/0 ROM ✅
- [x] **實機驗收**：patch AppImage 經 extrapath + 自備遊戲 → in-game 中文旁白正確（`screenshots/m4-patch-ingame-narration.png`）
- [x] README 圖文 + 中文手冊索引（`docs/manual-cht.md`）+ GLOSSARY
- [x] git init patch-only（106 檔，無 binary/遊戲/ROM）
- [x] **Windows mingw**：scummvm.exe（SCI+mt32emu，PE32+ 79MB→strip 18MB）建置成功
- [x] **Windows patch + full 打包**（`tools/package_windows{,_patch}_lsl2.sh`）；full 含 RESOURCE+ROM、patch 零敏感檔 [HARD] 驗收 ✅。runtime 為 build-verified（同源於已驗證 Linux binary；Wine headless 本環境不穩，需真機驗）
- [x] macOS workflow LSL2 化（名稱/patch 自動套 LSL2）— **ready**
- [ ] **macOS CI 實跑**：需 push GitHub 觸發 Actions（依 rules/30 須使用者確認）→ 產 universal .app → 本機 Mac 注入 game/ROM + `修復.command` 驗
- [ ] **git push GitHub Release**（patch 三平台）+ dist-all 保留本機（需使用者確認 remote/auth）
