export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/kq4.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
timeout 35 ./scummvm --path=/game --auto-detect -e adlib --music-volume=255 2>/tmp/k.log &
sleep 32
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/kq4.raw | awk '{print "kq4.raw:",$5/4/44100,"s"}'
