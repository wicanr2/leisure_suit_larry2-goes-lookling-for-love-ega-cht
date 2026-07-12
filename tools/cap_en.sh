export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 45 ./scummvm --path=/game --auto-detect 2>/dev/null &
sleep 6
import -window root /shots/copyprot_en.png    # 版權畫面(EN)
xdotool type --delay 100 "0000"; sleep 0.3; xdotool key Return; sleep 4
xdotool type --delay 80 "look in store"; sleep 0.4; xdotool key Return; sleep 2
import -window root /shots/narr_en.png          # 開場旁白(EN)
pkill -f scummvm 2>/dev/null
