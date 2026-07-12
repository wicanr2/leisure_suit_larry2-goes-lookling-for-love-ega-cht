export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
# 裝 pulseaudio（qfg1-capture 可能沒有；離線裝不了就退出）
which pulseaudio parec >/dev/null 2>&1 || { echo "NO_PULSE"; exit 3; }
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/dev/null 2>&1
export PULSE_SINK=cap SDL_AUDIODRIVER=pulseaudio
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/pulse.raw &
PAREC=$!
cd /src
SCI_CP_BYPASS=1 timeout 45 ./scummvm --path=/game --auto-detect --music-driver=mt32 --extrapath=/game 2>/tmp/p.log &
sleep 7; xdotool type --delay 100 "0000"; sleep 0.3; xdotool key Return; sleep 33
pkill -f scummvm; sleep 1; kill $PAREC 2>/dev/null
ls -la /out/pulse.raw 2>/dev/null | awk '{print "pulse:",$5/4/44100,"s"}'
