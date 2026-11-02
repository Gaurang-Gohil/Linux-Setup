#!/usr/bin/env bash
# Rofi themes with previews (SUPER+CTRL+R / SUPER+CTRL+SHIFT+R).
# One window: theme list on the left, a screenshot of the menu in that theme on the right.
# Previews are captured once (menus flash briefly) and rebuilt only when your colors change.

dirs=("$HOME/.config/rofi/themes" "$HOME/.local/share/rofi/themes")
config="$HOME/.config/rofi/config.rasi"
colors="$HOME/.config/rofi/wallust/colors-rofi.rasi"
cache_root="$HOME/.cache/rofi-theme-previews"
iDIR="$HOME/.config/swaync/images"
scripts="$HOME/.config/hypr/scripts"

pkill -x rofi
DEFAULT="Hyprlust (default)"   # Hyprlust's own menu design (built into config.rasi) with your wallust colors
theme_path() {
    [ "$1" = "$DEFAULT" ] && { echo "$colors"; return; }
    local d; for d in "${dirs[@]}"; do [ -f "$d/$1.rasi" ] && { echo "$d/$1.rasi"; return; }; done
}
# Print config.rasi with the given theme active.
# Hyprlust's own design sits below its "@theme colors-rofi.rasi" line near the top, and in rofi an
# @theme line discards everything above it. So:
#   default  -> that top line active, no other @theme lines (Hyprlust design applies)
#   a theme  -> top line commented out, theme appended at the end (theme replaces the design)
# Old appended @theme lines are removed, so nothing piles up.
with_theme() {
    awk -v target="~${2#$HOME}" -v base_re='^[ \t]*(//)?[ \t]*@theme[ \t]*"~/.config/rofi/wallust/colors-rofi.rasi"' '
        BEGIN { want_default = (target ~ /wallust\/colors-rofi\.rasi$/) }
        $0 ~ base_re && !seen_base { seen_base = 1
            print (want_default ? "@theme \"~/.config/rofi/wallust/colors-rofi.rasi\"" : "//@theme \"~/.config/rofi/wallust/colors-rofi.rasi\""); next }
        /^[ \t]*(\/\/)?[ \t]*@theme[ \t]*"/ { next }
        { print }
        END { if (!want_default) print "@theme \"" target "\"" }' "$1"
}

mapfile -t names < <(for d in "${dirs[@]}"; do find "$d" -maxdepth 1 -name '*.rasi' -type f -printf '%f\n' 2>/dev/null; done | sed 's/\.rasi$//' | sort -V -u)
names=("$DEFAULT" "${names[@]}")
[ ${#names[@]} -eq 0 ] && { notify-send -u low -i "$iDIR/error.png" "Rofi themes" "No themes found"; exit 1; }

# ---- previews (one set per color scheme)
cache="$cache_root/$(md5sum "$colors" 2>/dev/null | cut -c1-10)"
missing=(); for n in "${names[@]}"; do [ -s "$cache/$n.png" ] || missing+=("$n"); done
if [ ${#missing[@]} -gt 0 ]; then
    find "$cache_root" -mindepth 1 -maxdepth 1 -type d ! -path "$cache" -exec rm -rf {} + 2>/dev/null
    mkdir -p "$cache"
    notify-send -u low -i "$iDIR/ja.png" "Rofi themes" "Making previews: menus will flash for ~$(( ${#missing[@]} * 3 / 2 ))s. Don't type."
    hyprctl eval 'hl.config({ animations = { enabled = false } })' >/dev/null   # no slide-in, so captures are complete
    for n in "${missing[@]}"; do
        # preview = exactly what applying gives: a copy of config.rasi with this theme set
        tmpcfg=$(mktemp --suffix=.rasi); with_theme "$config" "$(theme_path "$n")" > "$tmpcfg"
        rofi -config "$tmpcfg" -show drun >/dev/null 2>&1 &
        pid=$!; geo=""
        for _ in $(seq 1 25); do
            geo=$(hyprctl layers -j | jq -r '.[].levels[][] | select(.namespace=="rofi") | "\(.x),\(.y) \(.w)x\(.h)"' | head -1)
            [ -n "$geo" ] && break; sleep 0.2
        done
        sleep 0.6                                    # let icons and images finish drawing
        [ -n "$geo" ] && grim -g "$geo" - | magick - -resize '1000x1000>' "$cache/$n.png"
        kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; rm -f "$tmpcfg"; sleep 0.2
    done
    hyprctl reload >/dev/null                                                    # animations back on
fi

# ---- picker
current=$(grep -oP '^\s*@theme\s*"\K[^"]+' "$config" | tail -n1); current=$(basename "${current%.rasi}")
[ "$current" = "colors-rofi" ] && current="$DEFAULT"
list=$(mktemp); pick=$(mktemp)
printf '%s\n' "${names[@]}" > "$list"
row=$(grep -nxF -- "$current" "$list" | cut -d: -f1); row=${row:-1}
kitty --class effect-picker --title "Rofi Themes" -e bash -c '
    fzf --with-shell "bash -c" --prompt "  Menu theme ❯ " --layout reverse --info inline-right --no-scrollbar \
        --header "Enter: apply   Esc: cancel   ↑↓ / scroll / click to preview" \
        --bind "load:pos($2)" \
        --preview "$4/ImagePreview.sh \"$3\" {}" \
        --preview-window "right,72%,border-left" < "$1" > "$5"' _ "$list" "$row" "$cache" "$scripts" "$pick"
choice=$(head -n1 "$pick"); rm -f "$list" "$pick"
[ -z "$choice" ] && exit 0

# ---- apply (same method as JaKooLit's RofiThemeSelector.sh: comment out old @theme, add the new one)
path=$(theme_path "$choice"); [ -z "$path" ] && exit 1
tmp=$(mktemp); with_theme "$config" "$path" > "$tmp" && cat "$tmp" > "$config"; rm -f "$tmp"
notify-send -u low -i "$iDIR/ja.png" "Rofi theme" "$choice applied"
