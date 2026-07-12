export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
SCI_CP_BYPASS=1 timeout 40 ./scummvm --path=/game --auto-detect --language=tw 2>/dev/null &
sleep 6
xdotool type --delay 120 "0000"; sleep 0.3; xdotool key Return; sleep 4
# 移到最頂邊觸發選單列
xdotool mousemove 200 0; sleep 1; import -window root /out/shots/menutop1.png
# F-key / ESC 嘗試開選單
xdotool key F1 2>/dev/null; sleep 1; import -window root /out/shots/menutop2.png
# 點第一個選單標題位置
xdotool mousemove 90 2 click 1; sleep 1; import -window root /out/shots/menutop3.png
pkill -f scummvm 2>/dev/null
