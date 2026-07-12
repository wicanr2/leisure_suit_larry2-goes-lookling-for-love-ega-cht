export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap2.raw SDL_DISKAUDIODELAY=0
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
# AdLib + 最大音量，不 bypass（停在版權畫面聽主題曲），再進遊戲
timeout 22 ./scummvm --path=/game --auto-detect -e adlib --music-volume=255 --midi-gain=100 2>/tmp/m2.log &
sleep 18
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/cap2.raw | awk '{print "cap2 大小:",$5}'
