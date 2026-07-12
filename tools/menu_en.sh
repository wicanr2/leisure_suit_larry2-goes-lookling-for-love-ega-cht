export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
# 英文版（不帶 language=tw），仍用 bypass 過 CP
SCI_CP_BYPASS=1 timeout 30 ./scummvm --path=/game --auto-detect 2>/tmp/en.log &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
xdotool mousemove 320 2; sleep 1
import -window root /out/shots/menu_en.png
pkill -f scummvm 2>/dev/null
