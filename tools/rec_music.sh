export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw SDL_DISKAUDIODELAY=0
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
# MT-32 音樂，bypass CP 讓 intro 音樂放
SCI_CP_BYPASS=1 timeout 25 ./scummvm --path=/game --auto-detect --music-driver=mt32 --extrapath=/game 2>/tmp/m.log &
sleep 8
xdotool type --delay 100 "0000"; sleep 0.2; xdotool key Return
sleep 14
pkill -f scummvm 2>/dev/null; sleep 1
echo "cap.raw 大小:"; ls -la /out/cap.raw 2>/dev/null | awk '{print $5}'
grep -iE "MT32|CM32|Falling|music" /tmp/m.log | head -3
