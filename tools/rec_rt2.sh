export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/rt2.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 55 ./scummvm --path=/game --auto-detect --music-driver=mt32 --extrapath=/game 2>/tmp/rt2.log &
sleep 7
xdotool type --delay 100 "0000"; sleep 0.3; xdotool key Return
sleep 45
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/rt2.raw | awk '{print "rt2:",$5/4/44100,"s"}'
