#!/usr/bin/env bash
# LSL2 Windows patch 版：scummvm.exe + DLL + 中文資料（cht/），**不含遊戲、不含 ROM**。
# → GitHub Release。玩家自備遊戲，.bat 提示指定遊戲夾（中文資料經 --extrapath 載入）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MINGW_IMG="${MINGW_IMG:-kq4-mingw}"
EXE="$ROOT/build/mingw-tree/scummvm.exe"
STAGE="$ROOT/build/win64-patch"
DIST="$ROOT/out/release"
OUT="$DIST/LSL2-CHT-win64-patch.zip"

[ -f "$EXE" ] || { echo "!! 找不到 $EXE"; exit 1; }
mkdir -p "$DIST"; rm -rf "$STAGE"; mkdir -p "$STAGE/cht"

echo ">> scummvm.exe + strip"
cp "$EXE" "$STAGE/scummvm.exe"
docker run --rm --name lsl2-winp-strip -v "$STAGE:/s" "$MINGW_IMG" x86_64-w64-mingw32-strip /s/scummvm.exe

echo ">> runtime DLL"
docker run --rm --name lsl2-winp-sdl "$MINGW_IMG" cat /usr/x86_64-w64-mingw32/bin/SDL2.dll > "$STAGE/SDL2.dll"
docker run --rm --name lsl2-winp-pth "$MINGW_IMG" cat /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll > "$STAGE/libwinpthread-1.dll"

echo ">> 中文資料（不含遊戲/ROM）"
cp "$ROOT/dist-cht/translation.tsv" "$ROOT/dist-cht/qfg1_big5.fnt" "$ROOT/dist-cht/qfg1_big5_hi.fnt" "$STAGE/cht/"

cat > "$STAGE/玩-幻想空間2-繁中.bat" <<'BAT'
@echo off
chcp 950 >nul
cd /d "%~dp0"
if "%~1"=="" (
  echo 用法：把你的 LSL2 遊戲夾拖到本 .bat 上，或執行：
  echo   玩-幻想空間2-繁中.bat "你的遊戲夾路徑"
  echo 也可直接執行 scummvm.exe 開介面手動加入遊戲（中文資料已內建，會自動套用）。
  scummvm.exe --extrapath="%~dp0cht" --language=tw
) else (
  scummvm.exe --path="%~1" --extrapath="%~dp0cht" --language=tw --auto-detect
)
BAT

cat > "$STAGE/README.txt" <<'TXT'
幻想空間II（Leisure Suit Larry 2: Goes Looking for Love）繁體中文化 — Windows x86_64 patch 版

本包只含引擎與中文資料，不含遊戲。需自備 LSL2 EGA 原版遊戲檔（RESOURCE.001~006 + RESOURCE.MAP）。

用法：
  把你的遊戲夾拖到「玩-幻想空間2-繁中.bat」上，或直接執行 scummvm.exe 用介面加入遊戲。
  中文資料（cht/）經 --extrapath 自動套用。

MT-32 音源（推薦）：自備 MT-32 ROM 放入你的遊戲夾，音效選項選 Roland MT-32。

版權保護（開場電話號碼問答）：繁中版預設略過，輸入任意四碼即過關。

repo：https://github.com/wicanr2/leisure_suit_larry2-goes-lookling-for-love-ega-cht
TXT

rm -f "$OUT"
echo ">> zip 打包"
( cd "$STAGE" && zip -qr "$OUT" . )
echo ">> 完成: $OUT ($(du -h "$OUT" | cut -f1))"
