set -e
export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 &
sleep 2
cd /src
timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/sv.log &
SV=$!
for t in 01 02 03 04 05 06 08 10 14 18; do
  sleep 1.5
  import -window root /out/shots/intro_${t}.png 2>/dev/null || true
done
kill $SV 2>/dev/null; pkill -f scummvm 2>/dev/null || true
tail -6 /tmp/sv.log
