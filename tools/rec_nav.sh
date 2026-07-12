export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/nav.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 70 ./scummvm --path=/game --auto-detect --music-driver=adlib --music-volume=255 2>/tmp/n.log &
sleep 7; xdotool type --delay 100 "0000"; sleep 0.3; xdotool key Return; sleep 4
# 進健康食品店（櫃檯 ~180,320）
xdotool mousemove 180 315 click 1; sleep 5
import -window root /out/nav_a.png
# 走右邊出場景換到機場方向
xdotool mousemove 630 340 click 1; sleep 6; import -window root /out/nav_b.png
xdotool mousemove 630 340 click 1; sleep 6; import -window root /out/nav_c.png
xdotool mousemove 630 340 click 1; sleep 6; import -window root /out/nav_d.png
sleep 5
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/nav.raw | awk '{print "nav:",$5/4/44100,"s"}'
