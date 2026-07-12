export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/lsl1vga.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
# LSL1 VGA（SCI），adlib（LSL1 用 adlib），從頭錄
timeout 35 ./scummvm --path=/game --auto-detect --music-driver=adlib --music-volume=255 2>/tmp/l.log &
sleep 32
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/lsl1vga.raw 2>/dev/null | awk '{print "lsl1vga:",$5/4/44100,"s"}'
grep -iE "sound|music|adlib" /tmp/l.log | head -3
