#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar layout or configs

IFS=$'\n\t'

# Define directories
waybar_layouts="$HOME/.config/waybar/configs"
waybar_config="$HOME/.config/waybar/config"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
rofi_config="$HOME/.config/rofi/config-waybar-layout.rasi"
msg=' 🎌 NOTE: Some waybar LAYOUT NOT fully compatible with some STYLES'

# Apply selected configuration
apply_config() {
    ln -sf "$waybar_layouts/$1" "$waybar_config"
    "${SCRIPTSDIR}/Refresh.sh" &
}

main() {
    # Resolve current symlink target and basename
    current_target=$(readlink -f "$waybar_config")
    current_name=$(basename "$current_target")

    # Build sorted list of available layouts
    mapfile -t options < <(
        find -L "$waybar_layouts" -maxdepth 1 -type f ! -name '*.bak' -printf '%f\n' | sort
    )

    # Mark and locate the active layout
    default_row=0
    MARKER="👉"
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    # Launch rofi with the annotated list, pre‑selecting the active row
    # Live preview: moving through the list switches the real bar's layout.
    # Enter keeps the highlighted layout, Esc restores the one you had.
    local list pick
    list=$(mktemp); pick=$(mktemp)
    printf '%s\n' "${options[@]}" > "$list"
    kitty --class waybar-style-picker --title "Waybar Layouts" -e bash -c '
        layouts="$1"; link="$2"
        fzf --with-shell "bash -c" --prompt "  Bar layout ❯ " --layout reverse --info inline-right --no-scrollbar \
            --header "↑↓ / scroll / click: preview on the bar   Enter: keep   Esc: undo" \
            --bind "load:pos($4)" \
            --bind "focus:execute-silent(n={}; n=\${n#👉 }; ln -sfn \"$layouts/\$n\" \"$link\"; pkill -SIGUSR2 -x waybar)" \
            < "$3" > "$5"' _ "$waybar_layouts" "$waybar_config" "$list" "$((default_row + 1))" "$pick"
    choice=$(head -n1 "$pick")
    rm -f "$list" "$pick"
    if [[ -z "$choice" ]]; then            # cancelled: put the original layout back
        ln -sfn "$current_target" "$waybar_config"
        pkill -SIGUSR2 -x waybar
        exit 0
    fi
    choice=${choice#"$MARKER "}

    case "$choice" in
        "no panel")
            pgrep -x "waybar" && pkill waybar || true
            ;;
        *)
            apply_config "$choice"
            ;;
    esac
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    #exit 0
fi

main
