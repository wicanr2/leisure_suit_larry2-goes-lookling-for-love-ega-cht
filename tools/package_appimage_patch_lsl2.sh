#!/usr/bin/env bash
# LSL2 patch 版 AppImage：patched ScummVM 引擎 + 中文資料（dist-cht），**不含遊戲、不含 ROM**。
# → GitHub Release（公開）。玩家自備遊戲，啟動時指 --path 到自己的遊戲夾。
# 中文資料放進 extrapath，引擎經 SearchMan 找 translation.tsv / qfg1_big5*.fnt。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
STAGE="$ROOT/build/appimg-patch"
DIST="$ROOT/out/release"
APPDIR="$STAGE/AppDir"
OUT="$DIST/LSL2-CHT-patch-x86_64.AppImage"

mkdir -p "$DIST"
rm -rf "$APPDIR"; mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" "$APPDIR/usr/share/cht"

echo ">> 複製 scummvm + strip"
cp "$ROOT/scummvm-src/scummvm" "$APPDIR/usr/bin/scummvm"
docker run --rm --name lsl2-pkgp-strip -v "$APPDIR/usr/bin:/b" qfg1-build:latest strip /b/scummvm 2>/dev/null || true

echo ">> 收集共享庫"
docker run --rm --name lsl2-pkgp-libs \
  -v "$APPDIR/usr/bin/scummvm:/collect/bin:ro" \
  -v "$APPDIR/usr/lib:/collect/out" \
  -v "$ROOT/tools/pkg_collect_libs.py:/collect/collect.py:ro" \
  -w /collect qfg1-build:latest python3 collect.py bin out
echo "   $(ls "$APPDIR/usr/lib" | wc -l) 個 .so"

echo ">> 放入中文資料（translation.tsv + 兩個字型），不含遊戲/ROM"
cp "$ROOT/dist-cht/translation.tsv" "$ROOT/dist-cht/qfg1_big5.fnt" "$ROOT/dist-cht/qfg1_big5_hi.fnt" "$APPDIR/usr/share/cht/"

# AppRun：中文資料當 extrapath；玩家自備遊戲用 --path 指定（或用 GUI 加遊戲）。
cat > "$APPDIR/AppRun" <<'APPRUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:${LD_LIBRARY_PATH:-}"
CHT="$HERE/usr/share/cht"
# 玩家自備遊戲：若未帶 --path，開 ScummVM GUI 讓玩家加入自己的 LSL2 遊戲夾。
# --extrapath 讓引擎經 SearchMan 找到中文 translation.tsv / 字型。
exec "$HERE/usr/bin/scummvm" --extrapath="$CHT" --language=tw "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/lsl2-cht.desktop" <<'DESK'
[Desktop Entry]
Type=Application
Name=幻想空間II（繁體中文版）
Comment=Leisure Suit Larry 2: Goes Looking for Love 繁體中文化 — ScummVM patch（自備遊戲）
Exec=AppRun
Icon=lsl2-cht
Categories=Game;
Terminal=false
DESK
cp "$ROOT/tools/assets/lsl2-cht.png" "$APPDIR/lsl2-cht.png"
ln -sf lsl2-cht.png "$APPDIR/.DirIcon"

rm -f "$OUT"
echo ">> appimagetool 打包"
docker run --rm --name lsl2-pkgp-tool -v "$STAGE:/stage" -v "$ROOT/tools/.cache:/cache:ro" -e ARCH=x86_64 -w /stage \
  qfg1-build:latest bash -c "apt-get update -qq >/dev/null && apt-get install -y -qq file >/dev/null && \
    /cache/appimagetool-x86_64.AppImage --appimage-extract-and-run 'AppDir' '/stage/$(basename "$OUT")'"
cp "$STAGE/$(basename "$OUT")" "$OUT" 2>/dev/null || sudo cp "$STAGE/$(basename "$OUT")" "$OUT" 2>/dev/null || mv "$STAGE/$(basename "$OUT")" "$OUT"
chmod +x "$OUT" 2>/dev/null || true
echo ">> 完成: $OUT ($(du -h "$OUT" | cut -f1))"
