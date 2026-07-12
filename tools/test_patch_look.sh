export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /work
SCI_CP_BYPASS=1 timeout 35 ./out/release/LSL2-CHT-patch-x86_64.AppImage --appimage-extract-and-run --path=/game --auto-detect 2>/tmp/p.log &
sleep 7
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
xdotool type --delay 80 "look in store"; sleep 0.4; xdotool key Return; sleep 2
import -window root /out/shots/patch_look.png 2>/dev/null
pkill -f scummvm 2>/dev/null; pkill -f AppImage 2>/dev/null
