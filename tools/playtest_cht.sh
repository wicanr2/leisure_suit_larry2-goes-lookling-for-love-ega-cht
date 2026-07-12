export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 60 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/sv.log &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
import -window root /out/shots/pt_ingame.png
# 開啟輸入行並輸入 look
xdotool key Tab 2>/dev/null; sleep 0.5
xdotool type --delay 80 "look"; sleep 0.4; xdotool key Return; sleep 2
import -window root /out/shots/pt_look.png
sleep 2; import -window root /out/shots/pt_look2.png
# 再試 "look at store" / open door 之類
xdotool type --delay 80 "look in store"; sleep 0.4; xdotool key Return; sleep 2
import -window root /out/shots/pt_look3.png
pkill -f scummvm 2>/dev/null
