#!/usr/bin/env python3
# colors.lua から tealdeer (tldr) の config.toml を生成する。
# tealdeer の色指定は named color / ansi / rgb {r,g,b} のみで
# "#hex" 文字列を受け付けないため、render-template.sh (@@KEY@@ → #hex 置換)
# ではなく専用の変換スクリプトで 10進 RGB に展開する。
#
# usage: tealdeer-config.py <colors.lua> <output-config.toml>
import re
import sys

colors_lua, output = sys.argv[1], sys.argv[2]

palette = {}
with open(colors_lua, encoding="utf-8") as f:
    for m in re.finditer(r'^\s*([a-z_]+)\s*=\s*"#([0-9a-fA-F]{6})"', f.read(), re.M):
        palette[m.group(1)] = m.group(2)


def rgb(key):
    h = palette[key]
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return f"{{ rgb = {{ r = {r}, g = {g}, b = {b} }} }}"


# 見出し=accent / コード例=tertiary / 変数=secondary / 本文=text / 補足=muted
config = f"""\
# matugen-apply が生成 (テンプレート: modules/theming/matugen/lib/tealdeer-config.py)
[updates]
auto_update = true

[style.description]
foreground = {rgb("text")}

[style.command_name]
foreground = {rgb("accent")}
bold = true

[style.example_text]
foreground = {rgb("muted")}

[style.example_code]
foreground = {rgb("tertiary")}

[style.example_variable]
foreground = {rgb("secondary")}
italic = true
"""

with open(output, "w", encoding="utf-8") as f:
    f.write(config)
