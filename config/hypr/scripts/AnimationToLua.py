#!/usr/bin/env python3
"""Convert a JaKooLit animation preset (old hyprland.conf format) to Hyprland 0.57 Lua.

Usage: AnimationToLua.py <preset.conf> <output.lua>

Handles:  enabled = yes/no,  bezier = name, x1, y1, x2, y2,
          animation = leaf, on/off, speed, curve[, style]
"""
import re
import sys

src, dst = sys.argv[1], sys.argv[2]
enabled = True
curves, anims = [], []

for raw in open(src, encoding="utf-8"):
    line = raw.split("#", 1)[0].strip()
    if not line or line in ("{", "}") or line.startswith("animations"):
        continue
    key, _, val = line.partition("=")
    key, val = key.strip(), val.strip()
    parts = [p.strip() for p in val.split(",")]
    if key == "enabled":
        enabled = val.lower() not in ("no", "false", "0", "off")
    elif key == "bezier" and len(parts) == 5:
        curves.append((parts[0], parts[1:]))
    elif key == "animation" and len(parts) >= 2:
        anims.append(parts)

defined = {name for name, _ in curves}
cname = lambda n: f"p_{n}" if n in defined else n   # prefix preset curves so they never clash with built-ins

def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

out = [f"-- generated from {src.rsplit('/', 1)[-1]} by AnimationToLua.py (SUPER+SHIFT+A); do not edit",
       f"hl.config({{ animations = {{ enabled = {'true' if enabled else 'false'} }} }})"]
clampy = lambda v: f"{min(max(float(v), -1.0), 2.0):g}"          # 0.57 allows curve y values -1..2
for name, (x1, y1, x2, y2) in curves:
    y1, y2 = clampy(y1), clampy(y2)
    out.append(f'hl.curve({lua_str(cname(name))}, {{ type = "bezier", points = {{ {{{x1}, {y1}}}, {{{x2}, {y2}}} }} }})')
for p in anims:
    leaf, on = p[0], p[1] not in ("0", "no", "false")
    fields = [f"leaf = {lua_str(leaf)}", f"enabled = {'true' if on else 'false'}"]
    if len(p) >= 3 and re.fullmatch(r"[0-9.]+", p[2]):
        fields.append(f"speed = {min(float(p[2]), 100):g}")          # 0.57 caps speed at 100
    if len(p) >= 4 and p[3]:
        fields.append(f"bezier = {lua_str(cname(p[3]))}")
    if len(p) >= 5 and p[4]:
        fields.append(f"style = {lua_str(', '.join(p[4:]))}")
    out.append("hl.animation({ " + ", ".join(fields) + " })")

open(dst, "w", encoding="utf-8").write("\n".join(out) + "\n")
