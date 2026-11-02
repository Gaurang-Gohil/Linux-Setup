#!/usr/bin/env bash
# Searchable list of the keyboard shortcuts Hyprland actually has loaded right now
# (read live from `hyprctl binds`, so it always matches ~/.config/hypr/lua/keybinds.lua).
pidof rofi >/dev/null && { pkill rofi; exit 0; }

hyprctl binds -j | jq -r '
  def mods: [ (if . % 128 >= 64 then "SUPER" else empty end),
              (if . % 8   >= 4  then "CTRL"  else empty end),
              (if . % 16  >= 8  then "ALT"   else empty end),
              (if . % 2   >= 1  then "SHIFT" else empty end) ];
  def keyname: if test("^code:1[0-9]$") then ((.[5:] | tonumber) - 9) % 10 | tostring
               elif . == "mouse:272" then "Left-drag" elif . == "mouse:273" then "Right-drag"
               elif . == "mouse_down" then "Scroll-down" elif . == "mouse_up" then "Scroll-up"
               elif . == "SUPER_L" then "(tap)" else . end;
  .[] | select(.has_description)
      | ((.modmask | mods) + [ (if .key == "" and .keycode >= 10 and .keycode <= 19 then "code:\(.keycode)" else .key end) | keyname ] | join(" + ")) as $k
      | "\($k)\t\(.description)"' \
| awk -F'\t' '!seen[$0]++ { printf "%-32s  %s\n", $1, $2 }' \
| rofi -dmenu -i -p "Keybinds" -theme "$HOME/.config/rofi/config-keybinds.rasi" >/dev/null
