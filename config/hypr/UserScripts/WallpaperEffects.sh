#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# Wallpaper Effects using ImageMagick (SUPER SHIFT W)

# Variables
terminal=kitty
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
wallpaper_output="$HOME/.config/hypr/wallpaper_effects/.wallpaper_modified"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
rofi_theme="$HOME/.config/rofi/config-wallpaper-effect.rasi"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# awww transition config
FPS=60
TYPE="wipe"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Define ImageMagick effects
declare -A effects=(
    ["No Effects"]="no-effects"
    ["Black & White"]="magick $wallpaper_current -colorspace gray -sigmoidal-contrast 10,40% $wallpaper_output"
    ["Blurred"]="magick $wallpaper_current -blur 0x10 $wallpaper_output"
    ["Charcoal"]="magick $wallpaper_current -charcoal 0x5 $wallpaper_output"
    ["Edge Detect"]="magick $wallpaper_current -edge 1 $wallpaper_output"
    ["Emboss"]="magick $wallpaper_current -emboss 0x5 $wallpaper_output"
    ["Frame Raised"]="magick $wallpaper_current +raise 150 $wallpaper_output"
    ["Frame Sunk"]="magick $wallpaper_current -raise 150 $wallpaper_output"
    ["Negate"]="magick $wallpaper_current -negate $wallpaper_output"
    ["Oil Paint"]="magick $wallpaper_current -paint 4 $wallpaper_output"
    ["Posterize"]="magick $wallpaper_current -posterize 4 $wallpaper_output"
    ["Polaroid"]="magick $wallpaper_current -polaroid 0 $wallpaper_output"
    ["Sepia Tone"]="magick $wallpaper_current -sepia-tone 65% $wallpaper_output"
    ["Solarize"]="magick $wallpaper_current -solarize 80% $wallpaper_output"
    ["Sharpen"]="magick $wallpaper_current -sharpen 0x5 $wallpaper_output"
    ["Vignette"]="magick $wallpaper_current -vignette 0x3 $wallpaper_output"
    ["Vignette-black"]="magick $wallpaper_current -background black -vignette 0x3 $wallpaper_output"
    ["Zoomed"]="magick $wallpaper_current -gravity Center -extent 1:1 $wallpaper_output"
)

# Function to apply no effects
no-effects() {
    awww img -o "$focused_monitor" "$wallpaper_current" $SWWW_PARAMS &&
    wait $!
    wallust run "$wallpaper_current" -s &&
    wait $!
    # Refresh rofi, waybar, wallust palettes
	sleep 2
	"$SCRIPTSDIR/Refresh.sh"

    notify-send -u low -i "$iDIR/ja.png" "No wallpaper" "effects applied"
    # copying wallpaper for rofi menu
    cp "$wallpaper_current" "$wallpaper_output"
}

# ---- previews: each effect applied to the current wallpaper, shown as thumbnails ----
rofi_preview_theme="$HOME/.config/rofi/config-wallpaper-effect-preview.rasi"
preview_root="$HOME/.cache/wallpaper-effect-previews"
preview_dir=""

preview_path() {   # thumbnail file for an effect name (names contain spaces and '&', so hash them)
    printf "%s/%s.png" "$preview_dir" "$(printf "%s" "$1" | md5sum | cut -c1-10)"
}

generate_previews() {   # $1 = "quiet" for background builds (no notification)
    local id base name cmd thumb work n
    id=$(md5sum "$wallpaper_current" | cut -c1-12)     # new wallpaper => new previews
    preview_dir="$preview_root/$id"
    [[ -f "$preview_dir/.done-v2" ]] && return
    mkdir -p "$preview_root"
    exec 9>"$preview_root/.lock"; flock 9               # one builder at a time; a 2nd press waits instead of wiping
    [[ -f "$preview_dir/.done-v2" ]] && { flock -u 9; return; }   # finished while we waited
    [[ "$1" != quiet ]] && notify-send -u low -i "$iDIR/ja.png" "Wallpaper effects" "Making previews for this wallpaper…"
    work="$preview_root/.building-$id"; rm -rf "$work"; mkdir -p "$work"
    base="$work/base.png"
    magick "$wallpaper_current" -resize 1920x1920\> "$base"          # screen-sized, so effects look right
    magick "$base" -resize 1200x "$work/$(printf "%s" "No Effects" | md5sum | cut -c1-10).png"
    for name in "${!effects[@]}"; do
        [[ "$name" == "No Effects" ]] && continue
        thumb="$work/$(printf "%s" "$name" | md5sum | cut -c1-10).png"
        cmd=${effects[$name]}
        cmd=${cmd//"$wallpaper_current"/"$base"}                      # read the screen-sized copy
        cmd=${cmd//"$wallpaper_output"/"-resize 1200x $thumb"}        # write a preview image
        eval "$cmd" &
    done
    wait
    rm -f "$base"
    n=$(find "$work" -name '*.png' -size +0 | wc -l)
    if (( n == ${#effects[@]} )); then                 # only keep a complete set
        find "$preview_root" -mindepth 1 -maxdepth 1 -type d ! -name ".building-*" -exec rm -rf {} +
        mv "$work" "$preview_dir"; touch "$preview_dir/.done-v2"
    else
        rm -rf "$work"                                  # incomplete: try again next time
    fi
    flock -u 9
}

# Function to run rofi menu
main() {
    # Populate rofi menu options
    options=("No Effects")
    for effect in "${!effects[@]}"; do
        [[ "$effect" != "No Effects" ]] && options+=("$effect")
    done

    generate_previews
    # one window: effect list on the left, big preview of the highlighted effect on the right
    local list pick
    list=$(mktemp); pick=$(mktemp)
    printf "%s\n" "${options[@]}" | LC_COLLATE=C sort > "$list"
    kitty --class effect-picker --title "Wallpaper Effects" -e bash -c '
        fzf --with-shell "bash -c" --prompt "  Effect ❯ " --layout reverse --info inline-right --no-scrollbar \
            --header "Enter: apply   Esc: cancel   ↑↓ / scroll / click to preview" \
            --preview "$HOME/.config/hypr/scripts/EffectPreview.sh \"$2\" {}" \
            --preview-window "right,75%,border-left" < "$1" > "$3"' _ "$list" "$preview_dir" "$pick"
    choice=$(head -n1 "$pick")
    rm -f "$list" "$pick"

    # Process user choice
    if [[ -n "$choice" ]]; then
        if [[ "$choice" == "No Effects" ]]; then
            no-effects
        elif [[ "${effects[$choice]+exists}" ]]; then
            # Apply selected effect
            notify-send -u normal -i "$iDIR/ja.png"  "Applying:" "$choice effects"
            eval "${effects[$choice]}"
            
            # intial kill process
            for pid in swaybg mpvpaper; do
            killall -SIGUSR1 "$pid"
            done

            sleep 1
            awww img -o "$focused_monitor" "$wallpaper_output" $SWWW_PARAMS &

            sleep 2
  
            wallust run "$wallpaper_output" -s &
            sleep 1
            # Refresh rofi, waybar, wallust palettes
            "${SCRIPTSDIR}/Refresh.sh"
            notify-send -u low -i "$iDIR/ja.png" "$choice" "effects applied"
        else
            echo "Effect '$choice' not recognized."
        fi
    fi
}

# Background mode (started on wallpaper change): just build previews, no menu
if [[ "$1" == "--previews-only" ]]; then
    generate_previews quiet
    exit 0
fi

# Check if rofi is already running and kill it
if pidof rofi > /dev/null; then
    pkill rofi
fi

main

sleep 1
