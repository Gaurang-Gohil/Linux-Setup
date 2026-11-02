#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar styles

IFS=$'\n\t'

# Define directories
waybar_styles="$HOME/.config/waybar/style"
waybar_style="$HOME/.config/waybar/style.css"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
rofi_config="$HOME/.config/rofi/config-waybar-style.rasi"
msg=' 🎌 NOTE: Some waybar STYLES NOT fully compatible with some LAYOUTS'

# Apply selected style
apply_style() {
    ln -sf "$waybar_styles/$1.css" "$waybar_style"
    "${SCRIPTSDIR}/Refresh.sh" &
}

main() {
    # resolve current symlink and strip .css
    current_target=$(readlink -f "$waybar_style")
    current_name=$(basename "$current_target" .css)

    # gather all style names (without .css) into an array
    mapfile -t options < <(
        find -L "$waybar_styles" -maxdepth 1 -type f -name '*.css' \
            -exec basename {} .css \; \
            | sort
    )

    # mark the active style and record its index
    default_row=0
    MARKER="👉"
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    # launch rofi with the annotated list and pre‑selected row
    # Live preview: moving through the list restyles the real top bar.
    # Enter keeps the highlighted style, Esc restores the one you had.
    local list pick
    list=$(mktemp); pick=$(mktemp)
    printf '%s\n' "${options[@]}" > "$list"
    kitty --class waybar-style-picker --title "Waybar Styles" -e bash -c '
        styles="$1"; link="$2"
        fzf --with-shell "bash -c" --prompt "  Bar style ❯ " --layout reverse --info inline-right --no-scrollbar \
            --header "↑↓ / scroll / click: preview on the bar   Enter: keep   Esc: undo" \
            --bind "load:pos($4)" \
            --bind "focus:execute-silent(n={}; n=\${n#👉 }; ln -sfn \"$styles/\$n.css\" \"$link\"; pkill -SIGUSR2 -x waybar)" \
            < "$3" > "$5"' _ "$waybar_styles" "$waybar_style" "$list" "$((default_row + 1))" "$pick"
    choice=$(head -n1 "$pick")
    rm -f "$list" "$pick"
    if [[ -z "$choice" ]]; then            # cancelled: put the original style back
        ln -sfn "$current_target" "$waybar_style"
        pkill -SIGUSR2 -x waybar
        exit 0
    fi
    choice=${choice#"$MARKER "}
    apply_style "$choice"
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    #exit 0
fi

main
