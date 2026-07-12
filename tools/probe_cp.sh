set -e
export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 &
sleep 2
cd /src
timeout 50 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/sv.log &
sleep 6
import -window root /out/shots/cp_0_girl.png 2>/dev/null || true
# 送錯誤答案 0000 Enter
xdotool type --delay 200 "0000"; sleep 0.5; xdotool key Return; sleep 2
import -window root /out/shots/cp_1_after_wrong.png 2>/dev/null || true
sleep 2
import -window root /out/shots/cp_2.png 2>/dev/null || true
# 再送一次錯誤
xdotool type --delay 200 "1111"; sleep 0.5; xdotool key Return; sleep 2
import -window root /out/shots/cp_3.png 2>/dev/null || true
pkill -f scummvm 2>/dev/null || true
