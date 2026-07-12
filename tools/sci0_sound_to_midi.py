#!/usr/bin/env python3
"""SCI0 sound 資源 → 標準 MIDI（SMF type 0）。

依 ScummVM engines/sci/sound/midiparser_sci.cpp midiFilterChannels 的 SCI0 單一 stream 格式：
  [2 byte patch header] [1 byte 數位取樣旗標] [16×2 byte channel headers] [MIDI stream]
MIDI stream：delta（0xF8=+240 ticks、其餘=值）+ MIDI 事件（running status）；0xFC=結束；0xF0=sysex 到 0xF7。
channel 15(0xF) 為 SCI 控制通道（loop/cue），非音符 → 預設略過。
輸出 SMF：division=30、tempo=500000（→60 SCI ticks/秒）。

用法：sci0_sound_to_midi.py <sound.NNN> <out.mid> [--all-channels]
純 stdlib。
"""
import sys, struct

NPARAMS = {0x8:2,0x9:2,0xA:2,0xB:2,0xC:1,0xD:1,0xE:2}  # MIDI status high-nibble → data byte count

def parse(data, keep_ctrl_channel=False):
    # 剝 2-byte patch header（type|0x80, skip）
    if len(data) >= 2 and (data[0] & 0x80):
        data = data[2:]
    # 數位取樣旗標 + 16×2 channel headers
    p = 1 + 16 * 2
    stream = data[p:]
    events = []  # (abs_tick, bytes)
    tick = 0
    i = 0
    status = 0
    n = len(stream)
    while i < n:
        b = stream[i]; i += 1
        if b == 0xF8:
            tick += 240; continue
        if b == 0xFC:
            break
        tick += b
        if i >= n: break
        cmd = stream[i]
        if cmd & 0x80:
            status = cmd; i += 1
        # else running status，cmd 是第一個資料 byte
        if status == 0xF0 or status == 0xFC:
            if status == 0xFC: break
            # sysex：讀到 0xF7
            sx = [0xF0]
            while i < n:
                c = stream[i]; i += 1; sx.append(c)
                if c == 0xF7: break
            events.append((tick, bytes(sx))); continue
        hi = status >> 4
        ch = status & 0x0F
        pc = NPARAMS.get(hi, 0)
        params = []
        for k in range(pc):
            if i >= n: break
            params.append(stream[i]); i += 1
        if ch == 0x0F and not keep_ctrl_channel:
            continue  # SCI 控制通道，非音符
        events.append((tick, bytes([status] + params)))
    return events

def vlq(v):
    out = bytearray([v & 0x7F]); v >>= 7
    while v:
        out.insert(0, (v & 0x7F) | 0x80); v >>= 7
    return bytes(out)

def build_smf(events, division=30, tempo=500000):
    track = bytearray()
    # tempo meta
    track += vlq(0) + bytes([0xFF,0x51,0x03]) + struct.pack(">I", tempo)[1:]
    last = 0
    for tk, ev in events:
        track += vlq(tk - last) + ev
        last = tk
    track += vlq(0) + bytes([0xFF,0x2F,0x00])  # EOT
    hdr = b"MThd" + struct.pack(">IHHH", 6, 0, 1, division)
    trk = b"MTrk" + struct.pack(">I", len(track)) + bytes(track)
    return hdr + trk

def main():
    keep = "--all-channels" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    data = open(args[0], "rb").read()
    ev = parse(data, keep_ctrl_channel=keep)
    notes = sum(1 for _, e in ev if (e[0] & 0xF0) == 0x90 and len(e) > 2 and e[2] > 0)
    open(args[1], "wb").write(build_smf(ev))
    print(f"{args[0]} → {args[1]}: {len(ev)} 事件, {notes} note-on, 末 tick {ev[-1][0] if ev else 0}")

if __name__ == "__main__":
    main()
