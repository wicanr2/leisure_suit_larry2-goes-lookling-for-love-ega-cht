export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 SCI_LOG_TOP=1 timeout 30 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/top.log &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 5
pkill -f scummvm 2>/dev/null
grep "SCI_LOG_TOP" /tmp/top.log | sort | uniq -c | sort -rn | head -30
