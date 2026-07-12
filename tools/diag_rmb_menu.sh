export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/d.log &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
# 右鍵點街景中的物件（商店櫥窗約 180,320）
xdotool mousemove 180 320; sleep 0.5; xdotool click 3; sleep 1
import -window root /out/shots/diag_rmb.png
# 開選單（滑鼠到頂）
xdotool mousemove 100 4; sleep 0.5; xdotool click 1; sleep 1
import -window root /out/shots/diag_menu.png
pkill -f scummvm 2>/dev/null
grep -iE "debug|coord|mouse" /tmp/d.log | head
