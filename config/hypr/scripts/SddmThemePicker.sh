#!/usr/bin/env bash
# Login screen (SDDM) theme picker, opened from SUPER+SHIFT+E -> "Set SDDM Theme".
# List on the left, the theme's screenshot on the right. Ctrl+T opens a real test login screen.
# Enter applies (asks for your password: the setting lives in /etc/sddm.conf).
themes_dir="/usr/share/sddm/themes"
cache="$HOME/.cache/sddm-theme-previews"
scripts="$HOME/.config/hypr/scripts"
mkdir -p "$cache"

current=$(grep -hoP '^\s*Current\s*=\s*\K\S+' /etc/sddm.conf /etc/sddm.conf.d/*.conf 2>/dev/null | tail -n1)
list=$(mktemp)
for t in "$themes_dir"/*/; do
    n=$(basename "$t")
    shot=$(grep -hoP '^\s*Screenshot\s*=\s*\K.*' "$t/metadata.desktop" 2>/dev/null | head -n1 | xargs)
    [ -f "$t/$shot" ] || shot=$(cd "$t" && ls Previews/*.png Previews/*.jpg screenshot* 2>/dev/null | head -n1)
    [ -n "$shot" ] && [ ! -s "$cache/$n.png" ] && magick "$t/$shot" -resize '1200x1200>' "$cache/$n.png" 2>/dev/null
    if [ "$n" = "$current" ]; then echo "👉 $n"; else echo "$n"; fi
done > "$list"
row=$(grep -n '^👉 ' "$list" | cut -d: -f1); row=${row:-1}

kitty --class effect-picker --title "Login Screen Theme" -e bash -c '
    list="$1"; row="$2"; cache="$3"; scripts="$4"; dir="$5"
    choice=$(fzf --with-shell "bash -c" --prompt "  Login theme ❯ " --layout reverse --info inline-right --no-scrollbar \
        --header "Enter: apply (asks password)   Ctrl+T: open a test login screen   Esc: cancel" \
        --bind "load:pos($row)" \
        --bind "ctrl-t:execute-silent(n={}; n=\${n#👉 }; sddm-greeter-qt6 --test-mode --theme \"$dir/\$n\" >/dev/null 2>&1 &)" \
        --preview "n={}; n=\${n#👉 }; \"$scripts/ImagePreview.sh\" \"$cache\" \"\$n\"" \
        --preview-window "right,72%,border-left" < "$list")
    choice=${choice#👉 }
    [ -z "$choice" ] && exit 0
    clear; echo; echo "  Setting the login screen to: $choice"; echo
    if sudo sed -i -E "s/^(\s*Current\s*=).*/\1$choice/" /etc/sddm.conf; then
        notify-send -u low "Login screen" "$choice will show at your next login"
    else
        echo "  Not changed."; sleep 2
    fi' _ "$list" "$row" "$cache" "$scripts" "$themes_dir"
rm -f "$list"
