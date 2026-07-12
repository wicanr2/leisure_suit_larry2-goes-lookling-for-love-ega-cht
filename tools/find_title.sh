export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
# 不 bypass、不輸入，看 CP 前有無 title；再 bypass 看 CP 後 intro
SCI_CP_BYPASS=1 SCI_LOG_GFX=1 timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/gfx.log &
sleep 5
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return
for t in 02 05 08 11 14 18 24; do sleep 3; import -window root /out/shots/seq_${t}.png 2>/dev/null; done
pkill -f scummvm 2>/dev/null
grep -iE "drawPicture|pic|GFX" /tmp/gfx.log | grep -oiE "pic[a-z]* [0-9]+|picture[^0-9]*[0-9]+" | sort | uniq -c | sort -rn | head -20
cp /tmp/gfx.log /out/gfx.log
