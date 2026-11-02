#!/usr/bin/env bash
# Animation presets (SUPER+SHIFT+A).
# Converts the chosen JaKooLit preset to Lua (lua/animation-preset.lua) and reloads Hyprland.
# "Hyprlust (default)" removes the preset, going back to lua/animations.lua.

HYPR="$HOME/.config/hypr"
animations_dir="$HYPR/animations"
preset_lua="$HYPR/lua/animation-preset.lua"
current_file="$HYPR/lua/.animation-preset-name"
iDIR="$HOME/.config/swaync/images"
DEFAULT="Hyprlust (default)"

current=$(cat "$current_file" 2>/dev/null); [ -f "$preset_lua" ] || current="$DEFAULT"

list=$(mktemp); pick=$(mktemp)
{ echo "$DEFAULT"; find -L "$animations_dir" -maxdepth 1 -type f -name '*.conf' -printf '%f\n' | sed 's/\.conf$//' | sort -V; } > "$list"
row=$(grep -nxF -- "$current" "$list" | cut -d: -f1); row=${row:-1}
sed -i "${row}s/^/👉 /" "$list"

kitty --class waybar-style-picker --title "Animations" -e bash -c '
    fzf --with-shell "bash -c" --prompt "  Animation ❯ " --layout reverse --info inline-right --no-scrollbar \
        --header "Enter: apply (open/close a window to see it)   Esc: cancel" \
        --bind "load:pos($2)" < "$1" > "$3"' _ "$list" "$row" "$pick"
choice=$(head -n1 "$pick"); choice=${choice#👉 }
rm -f "$list" "$pick"
[ -z "$choice" ] && exit 0

if [ "$choice" = "$DEFAULT" ]; then
    rm -f "$preset_lua" "$current_file"
else
    tmp=$(mktemp --suffix=.lua)
    if ! python3 -I "$HYPR/scripts/AnimationToLua.py" "$animations_dir/$choice.conf" "$tmp"; then
        notify-send -u normal -i "$iDIR/error.png" "Animations" "Could not convert: $choice"; rm -f "$tmp"; exit 1
    fi
    [ -f "$preset_lua" ] && cp "$preset_lua" "$preset_lua.prev"
    mv "$tmp" "$preset_lua"
    if ! (cd "$HYPR" && Hyprland --verify-config 2>&1 | grep -q "config ok"); then
        if [ -f "$preset_lua.prev" ]; then mv "$preset_lua.prev" "$preset_lua"; else rm -f "$preset_lua"; fi
        notify-send -u normal -i "$iDIR/error.png" "Animations" "$choice doesn't work with this Hyprland; kept the old one"; exit 1
    fi
    rm -f "$preset_lua.prev"
    echo "$choice" > "$current_file"
fi

hyprctl reload >/dev/null
notify-send -u low -i "$iDIR/ja.png" "$choice" "Animations loaded"
