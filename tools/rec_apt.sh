set -e
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq scummvm xvfb >/dev/null 2>&1
export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/apt.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
# 完整 scummvm 加遊戲、跑
scummvm --add --path=/game >/dev/null 2>&1 || true
TARGET=$(scummvm --list-targets 2>/dev/null | grep -iE "lsl2|larry" | awk '{print $1}' | head -1)
echo "target: $TARGET"
timeout 40 scummvm -p /game --auto-detect --music-driver=mt32 --extrapath=/game 2>/tmp/a.log &
sleep 38
pkill -f scummvm 2>/dev/null; sleep 1
ls -la /out/apt.raw 2>/dev/null | awk '{print "apt.raw:",$5/4/44100,"s"}'
