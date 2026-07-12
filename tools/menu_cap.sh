export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/m.log &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
# 移動滑鼠到頂端顯示選單列 + 點擊第一個選單
xdotool mousemove 320 2; sleep 1
import -window root /out/shots/menu_hover.png
xdotool mousemove 100 8 click 1; sleep 1
import -window root /out/shots/menu_open.png
pkill -f scummvm 2>/dev/null
