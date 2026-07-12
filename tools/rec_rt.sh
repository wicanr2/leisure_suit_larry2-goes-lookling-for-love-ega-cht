export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/rt.raw
# 不設 DELAY=0 → 即時，排序器正常推進
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
timeout 45 ./scummvm --path=/game --auto-detect --music-driver=mt32 --extrapath=/game 2>/tmp/rt.log &
# 從遊戲一啟動就錄（片頭），約 40s
sleep 42
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/rt.raw | awk '{print "rt.raw:",$5,"bytes ~",$5/4/44100,"s"}'
