#!/usr/bin/env bash
# Kitty terminal themes with live preview.
# Moving through the list recolors kitty right away (this window too). Enter keeps it, Esc undoes.
conf="$HOME/.config/kitty/kitty.conf"
themes="$HOME/.config/kitty/kitty-themes"
scripts="$HOME/.config/hypr/scripts"
iDIR="$HOME/.config/swaync/images"
WALLUST="01-Wallust (global theme)"

backup=$(mktemp); cp "$conf" "$backup"
current=$(grep -oP '^\s*include\s+\./kitty-themes/\K.*(?=\.conf)' "$conf" | tail -n1)
[ -z "$current" ] && current="$WALLUST"

list=$(mktemp); pick=$(mktemp)
find "$themes" -maxdepth 1 -name '*.conf' -type f -printf '%f\n' | sed 's/\.conf$//' | sort | sed "s/^01-Wallust\$/$WALLUST/" > "$list"
row=$(grep -nxF -- "$current" "$list" | cut -d: -f1); row=${row:-1}
sed -i "${row}s/^/👉 /" "$list"

kitty --class effect-picker --title "Kitty Themes" -e bash -c '
    fzf --with-shell "bash -c" --prompt "  Terminal theme ❯ " --layout reverse --info inline-right --no-scrollbar \
        --header "↑↓ / scroll / click: preview live   Enter: keep   Esc: undo" \
        --bind "load:pos($2)" \
        --bind "focus:execute-silent($3/KittyThemeApply.sh {})" \
        --preview "$3/KittySample.sh {}" --preview-window "right,60%,border-left" \
        < "$1" > "$4"' _ "$list" "$row" "$scripts" "$pick"
choice=$(head -n1 "$pick"); choice=${choice#👉 }
rm -f "$list" "$pick"

if [ -z "$choice" ]; then                       # cancelled: put the old theme back
    cp "$backup" "$conf"; rm -f "$backup"
    for pid in $(pidof kitty); do kill -SIGUSR1 "$pid" 2>/dev/null; done
    exit 0
fi
rm -f "$backup"
"$scripts/KittyThemeApply.sh" "$choice"
notify-send -u low -i "$iDIR/ja.png" "Kitty theme" "$choice applied"
