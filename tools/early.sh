export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
SCI_LOG_GFX=1 timeout 20 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/e.log &
for t in 005 010 015 020 025 030 040; do sleep 0.5; import -window root /out/shots/early_${t}.png 2>/dev/null; done
pkill -f scummvm 2>/dev/null
grep "drawPicture" /tmp/e.log
