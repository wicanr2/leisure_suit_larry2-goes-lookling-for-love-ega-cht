export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
timeout 30 ./scummvm --path=/game --auto-detect --language=tw 2>/dev/null &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
import -window root /out/shots/default_bypass.png 2>/dev/null
pkill -f scummvm 2>/dev/null
