#!/usr/bin/env python3
"""colors.lua に accent の色相回転から complement/triad を追記する (冪等)。

WSL の matugen-apply.sh と NixOS の wppicker.sh (旧実装) が別々に持っていた
同じ計算式を1箇所にまとめたもの。
"""
import colorsys
import re
import sys


def rotate_hue(hex_color: str, amount: float) -> str:
    h = hex_color.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    hh, l, s = colorsys.rgb_to_hls(r, g, b)
    r, g, b = colorsys.hls_to_rgb((hh + amount) % 1.0, l, s * 0.75)
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: derive-colors.py <colors.lua>", file=sys.stderr)
        return 1

    path = sys.argv[1]
    with open(path) as f:
        text = f.read()

    m = re.search(r'^\s*accent\s*=\s*"(#[0-9a-fA-F]{6})"', text, re.MULTILINE)
    if not m:
        print("accent key not found, skipping", file=sys.stderr)
        return 0
    accent = m.group(1)

    additions = []
    if not re.search(r"^\s*complement\s*=", text, re.MULTILINE):
        additions.append(f'  complement = "{rotate_hue(accent, 0.5)}",')
    if not re.search(r"^\s*triad\s*=", text, re.MULTILINE):
        additions.append(f'  triad = "{rotate_hue(accent, 0.3333333)}",')

    if not additions:
        return 0

    text = re.sub(
        r'(^\s*tertiary\s*=\s*"#[0-9a-fA-F]{6}",)',
        lambda mo: mo.group(1) + "\n" + "\n".join(additions),
        text,
        count=1,
        flags=re.MULTILINE,
    )
    with open(path, "w") as f:
        f.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
