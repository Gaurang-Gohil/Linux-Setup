#!/usr/bin/env bash
# Apply a kitty theme from ~/.config/kitty/kitty-themes and recolor all open kitty windows.
# "01-Wallust (global theme)" removes the theme line, so kitty follows your SUPER+T theme again.
name="$1"; name="${name#👉 }"
conf="$HOME/.config/kitty/kitty.conf"
if [[ "$name" == 01-Wallust* ]]; then
    sed -i -E '/^[#[:space:]]*include\s+\.\/kitty-themes\/.*\.conf/d' "$conf"
elif [ -f "$HOME/.config/kitty/kitty-themes/$name.conf" ]; then
    if grep -qE '^[#[:space:]]*include\s+\./kitty-themes/.*\.conf' "$conf"; then
        sed -i -E "s|^[#[:space:]]*include\s+\./kitty-themes/.*\.conf|include ./kitty-themes/$name.conf|" "$conf"
    else
        printf '\ninclude ./kitty-themes/%s.conf\n' "$name" >> "$conf"
    fi
else
    exit 1
fi
for pid in $(pidof kitty); do kill -SIGUSR1 "$pid" 2>/dev/null; done
