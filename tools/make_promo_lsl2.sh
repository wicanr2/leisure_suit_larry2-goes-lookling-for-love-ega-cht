#!/usr/bin/env bash
set -eu
# 掛載：/shots(截圖) /music(bgm wav) /out(輸出)
# ===== 設計 token（LSL2 霓虹夜店喜劇：洋紅 + 青 + 奶油）=====
BGD='#160726'; BGD2='#3a0f4a'; NEON='#ff3d9a'; CYAN='#25d3d8'; CREAM='#f6ecd8'; SHAD='#4a0a30'
FB='/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc'
FR='/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc'
W=1280; H=720; FPS=25; SHOT=/shots; MUS=/music; OUT=/out; TMP=/tmp/c; mkdir -p "$TMP" "$OUT"

card(){ # $1 out $2 中標 $3 英標 $4 副標
  convert -size ${W}x${H} "radial-gradient:${BGD2}-${BGD}" -font "$FB" -gravity center \
    -fill "$SHAD" -pointsize 92 -annotate +5+5 "$3" -fill "$NEON" -pointsize 92 -annotate +0+0 "$3" \
    -fill "$CREAM" -pointsize 66 -annotate +0+98 "$2" \
    -fill "$CYAN" -font "$FR" -pointsize 30 -annotate +0+182 "$4" "$1"; }
slide(){ # $1 out $2 screenshot $3 字幕
  convert "$SHOT/$2" -resize x574 -bordercolor "$NEON" -border 3 "$TMP/sc.png"
  convert -size ${W}x${H} "gradient:${BGD2}-${BGD}" \( "$TMP/sc.png" \) -gravity north -geometry +0+22 -composite \
    -fill "#000000aa" -draw "rectangle 0,642 ${W},720" \
    -font "$FR" -fill "$CREAM" -gravity south -pointsize 34 -annotate +0+28 "$3" "$1"; }
compare(){ # $1 out $2 en.png $3 cht.png $4 字幕
  convert "$SHOT/$2" -resize 512x384 -bordercolor '#888' -border 2 "$TMP/l.png"
  convert "$SHOT/$3" -resize 512x384 -bordercolor "$NEON" -border 2 "$TMP/r.png"
  convert "$TMP/l.png" -gravity north -background '#00000000' -splice 0x34 -font "$FR" -fill '#cfcfcf' -pointsize 26 -annotate +0+4 '英文原版' "$TMP/l2.png"
  convert "$TMP/r.png" -gravity north -background '#00000000' -splice 0x34 -font "$FR" -fill "$CYAN" -pointsize 26 -annotate +0+4 '繁體中文化' "$TMP/r2.png"
  convert "$TMP/l2.png" "$TMP/r2.png" +append "$TMP/lr.png"
  convert -size ${W}x${H} "gradient:${BGD2}-${BGD}" \( "$TMP/lr.png" \) -gravity center -geometry +0-28 -composite \
    -font "$FR" -fill "$CREAM" -gravity south -pointsize 36 -annotate +0+40 "$4" "$1"; }
kb(){ # $1 png $2 mp4 $3 秒 —— 靜態 + fade
  local FO; FO=$(awk "BEGIN{print $3-0.6}")
  ffmpeg -y -loglevel error -loop 1 -i "$1" -t "$3" -r $FPS \
    -vf "fade=t=in:st=0:d=0.6,fade=t=out:st=$FO:d=0.6,format=yuv420p" \
    -threads 2 -c:v libx264 -preset veryfast -pix_fmt yuv420p "$2"; }

# ===== 分鏡 =====
card    "$TMP/00.png" '幻想空間 II' 'Leisure Suit Larry 2' 'Sierra 1988 · SCI0 EGA · 繁體中文化'
compare "$TMP/01.png" copyprot_en.png copyprot_cht.png '開場版權保護畫面 —— 繁中版預設略過'
slide   "$TMP/02.png" narr_cht.png    '開場旁白全程中文 · Big5 hi-res 銳利'
compare "$TMP/03.png" narr_en.png narr_cht.png '賴瑞與伊芙的往事 —— 台式在地化，自然口語'
slide   "$TMP/04.png" menu_cht.png    '中文選單：檔案 · 動作 · 速度 · 音效'
slide   "$TMP/05.png" help_cht.png    '按 F1 叫出中文操作說明 —— 打字冒險新手友善'
slide   "$TMP/06.png" copyfail_cht.png '連版權失敗訊息都中文化'
card    "$TMP/99.png" '全文字繁中化 · 2362 則' 'Goes Looking for Love' 'github.com/wicanr2 · 致敬 Al Lowe'

# ===== concat =====
LIST="$TMP/list.txt"; : > "$LIST"
declare -A SEC=( [00]=5 [01]=8 [02]=6 [03]=8 [04]=6 [05]=6 [06]=6 [99]=7 )
for f in 00 01 02 03 04 05 06 99; do kb "$TMP/$f.png" "$TMP/s_$f.mp4" "${SEC[$f]}"; echo "file '$TMP/s_$f.mp4'" >> "$LIST"; done
ffmpeg -y -loglevel error -f concat -safe 0 -i "$LIST" -threads 2 -c:v libx264 -preset veryfast -pix_fmt yuv420p "$TMP/silent.mp4"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/silent.mp4"); FO=$(awk "BEGIN{print $DUR-3}")
# ===== 鋪原版配樂（sound.101，aloop 循環，不用 -shortest）=====
ffmpeg -y -loglevel error -i "$TMP/silent.mp4" -i "$MUS/lsl2_bgm.wav" \
  -filter_complex "[1:a]aloop=loop=-1:size=2000000000,atrim=0:$DUR,afade=t=in:st=0:d=2,afade=t=out:st=$FO:d=3[a]" \
  -map 0:v -map "[a]" -threads 2 -c:v libx264 -preset veryfast -c:a aac -b:a 192k -movflags +faststart \
  "$OUT/lsl2_cht_promo.mp4"
echo "=== 完成 ==="
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/lsl2_cht_promo.mp4"
ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$OUT/lsl2_cht_promo.mp4"
