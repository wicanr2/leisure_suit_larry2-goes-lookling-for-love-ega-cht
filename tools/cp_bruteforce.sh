export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 &
sleep 2
cd /src
for i in $(seq 1 20); do
  timeout 20 ./scummvm --path=/game --auto-detect --language=tw >/dev/null 2>&1 &
  SVPID=$!
  sleep 5
  xdotool type --delay 150 "6262" 2>/dev/null; sleep 0.4; xdotool key Return 2>/dev/null
  sleep 3
  import -window root /out/shots/bf_$(printf %02d $i).png 2>/dev/null || true
  kill $SVPID 2>/dev/null; pkill -f scummvm 2>/dev/null
  sleep 1
done
