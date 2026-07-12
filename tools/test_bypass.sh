export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 45 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/sv.log &
sleep 6
import -window root /out/shots/byp_0_before.png 2>/dev/null
# 輸入任意 4 碼
xdotool type --delay 150 "0000"; sleep 0.4; xdotool key Return; sleep 3
import -window root /out/shots/byp_1_after.png 2>/dev/null
sleep 3; import -window root /out/shots/byp_2.png 2>/dev/null
sleep 4; import -window root /out/shots/byp_3.png 2>/dev/null
sleep 4; import -window root /out/shots/byp_4.png 2>/dev/null
pkill -f scummvm 2>/dev/null
