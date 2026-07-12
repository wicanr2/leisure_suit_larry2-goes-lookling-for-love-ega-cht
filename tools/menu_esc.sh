export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/dev/null &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
xdotool key Escape; sleep 1; import -window root /out/shots/menu_esc1.png
# 選單開啟後，按右鍵/方向鍵看下拉
xdotool key Down; sleep 0.5; import -window root /out/shots/menu_esc2.png
xdotool key Right; sleep 0.5; import -window root /out/shots/menu_esc3.png
pkill -f scummvm 2>/dev/null
