export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 & sleep 2
cd /src
for i in 1 2 3; do
  timeout 15 ./scummvm --path=/game --auto-detect --language=tw >/dev/null 2>&1 &
  sleep 5
  import -window root /out/shots/det_$i.png 2>/dev/null || true
  pkill -f scummvm 2>/dev/null; sleep 1
done
