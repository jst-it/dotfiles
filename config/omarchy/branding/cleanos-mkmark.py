#!/usr/bin/env python3
"""Render the CleanOS pixel wordmark.

Glyphs are designed on a terminal-cell grid (3-column stems, 1-row bars) so the
same source renders crisply both as block ASCII and as a PNG, using 1:2 cells to
match a terminal character's aspect.
"""
import sys, zlib, struct

GLYPHS = {
"C": [".XXXXXXX.","XXX...XXX","XXX......","XXX......","XXX......","XXX......","XXX......","XXX......","XXX...XXX",".XXXXXXX."],
"L": ["XXX......","XXX......","XXX......","XXX......","XXX......","XXX......","XXX......","XXX......","XXX......","XXXXXXXXX"],
"E": ["XXXXXXXXX","XXX......","XXX......","XXX......","XXXXXXX..","XXX......","XXX......","XXX......","XXX......","XXXXXXXXX"],
"A": [".XXXXXXX.","XXX...XXX","XXX...XXX","XXX...XXX","XXXXXXXXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX"],
"N": ["XXX...XXX","XXXX..XXX","XXXX..XXX","XXXXX.XXX","XXXXX.XXX","XXX.XXXXX","XXX.XXXXX","XXX..XXXX","XXX..XXXX","XXX...XXX"],
"O": [".XXXXXXX.","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX","XXX...XXX",".XXXXXXX."],
"S": [".XXXXXXXX","XXX....XX","XXX......","XXX......",".XXXXXXX.","......XXX","......XXX","......XXX","XX....XXX","XXXXXXXX."],
}
GW, GH, GAP = 9, 10, 2

def word(text):
    w = len(text) * GW + (len(text) - 1) * GAP
    grid = [[0] * w for _ in range(GH)]
    for i, ch in enumerate(text):
        x0 = i * (GW + GAP)
        for r, row in enumerate(GLYPHS[ch]):
            for c, p in enumerate(row):
                if p == "X":
                    grid[r][x0 + c] = 1
    return grid

def stack(blocks, gap_rows):
    w = max(len(b[0]) for b in blocks)
    out = []
    for i, b in enumerate(blocks):
        if i:
            out += [[0] * w for _ in range(gap_rows)]
        pad = (w - len(b[0])) // 2
        out += [[0] * pad + r + [0] * (w - pad - len(r)) for r in b]
    return out

def write_png(grid, cw, ch, rgb, path):
    h, w = len(grid) * ch, len(grid[0]) * cw
    r, g, b = rgb
    on, off = bytes((r, g, b, 255)), b"\0\0\0\0"
    raw = bytearray()
    for row in grid:
        line = bytearray()
        for v in row:
            line += (on if v else off) * cw
        raw += (b"\0" + line) * ch
    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff))
    open(path, "wb").write(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b""))
    return w, h, len(grid[0]), len(grid)

hexc = sys.argv[1].lstrip("#")
rgb = tuple(int(hexc[i:i+2], 16) for i in (0, 2, 4))
out = sys.argv[2]

print("wordmark px=%dx%d cells=%dx%d" % write_png(word("CLEANOS"), 10, 20, rgb, f"{out}/cleanos-wordmark.png"))
print("badge    px=%dx%d cells=%dx%d" % write_png(stack([word("CLEAN"), word("OS")], 3), 10, 20, rgb, f"{out}/cleanos-badge.png"))
