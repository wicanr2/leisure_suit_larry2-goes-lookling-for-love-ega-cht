export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap3.raw SDL_DISKAUDIODELAY=0
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 40 ./scummvm --path=/game --auto-detect -e adlib --music-volume=255 2>/tmp/m3.log &
sleep 7
xdotool type --delay 100 "0000"; sleep 0.3; xdotool key Return; sleep 4
# 走動+進場景：往右走出畫面換場、往左、點商店
for i in 1 2 3; do
  xdotool mousemove 620 350 click 1; sleep 3
  xdotool mousemove 20 350 click 1; sleep 3
  xdotool mousemove 180 320 click 1; sleep 2
done
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/cap3.raw | awk '{print "cap3:",$5}'
