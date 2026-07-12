export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/lsl2adlib.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
timeout 40 ./scummvm --path=/game --auto-detect --music-driver=adlib --music-volume=255 2>/tmp/la.log &
sleep 37
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/lsl2adlib.raw 2>/dev/null | awk '{print "lsl2adlib:",$5/4/44100,"s"}'
grep -iE "no MIDI note|adlib|sound.*driver" /tmp/la.log | head
