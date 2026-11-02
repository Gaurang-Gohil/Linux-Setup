#!/usr/bin/env bash
# Copies your current setup from this computer back into the repo,
# so you can commit and push the latest changes:
#   bash sync.sh && git add -A && git commit -m "update setup" && git push
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
APPS="hypr waybar rofi swaync kitty wallust quickshell fish gtk-3.0 gtk-4.0 qt5ct qt6ct Kvantum
      btop cava fastfetch wlogout swappy nwg-look Thunar yazi zathura rmpc ghostty wezterm matugen xfce4"

for a in $APPS; do
    [[ -e $HOME/.config/$a ]] || continue
    rm -rf "$REPO/config/$a"
    cp -a "$HOME/.config/$a" "$REPO/config/"
done
cp "$HOME/.config/starship.toml" "$HOME/.config/mimeapps.list" "$REPO/config/" 2>/dev/null || true
cp "$HOME/.local/bin/wallust" "$REPO/local/bin/"
rm -rf "$REPO/home/themes" && cp -a "$HOME/.themes" "$REPO/home/themes"

# leave out backups, caches, generated files and anything private
find "$REPO/config" \( -name '*.bak' -o -name '*.bak[0-9]*' -o -name '*.orig' -o -name '*.pre-*' \
     -o -name '*.log' -o -name fish_variables -o -name bookmarks -o -name __pycache__ \) -prune -exec rm -rf {} +
rm -rf "$REPO/config/hypr/wallpaper_effects" "$REPO/config/rofi/.current_wallpaper"

# absolute symlinks -> relative (so they work for any username)
find "$REPO/config" -type l | while read -r l; do
    t=$(readlink "$l")
    case $t in "$HOME/.config/"*)
        ln -sfn "$(realpath --relative-to="$(dirname "$l")" "$REPO/config/${t#"$HOME"/.config/}")" "$l" ;;
    esac
done

pacman -Qqen > "$REPO/packages/pacman.txt"
{ pacman -Qqem | grep -vE '^(yay-bin|yay-bin-debug)$'; printf '%s\n' flat-remix bibata-cursor-theme-bin; } |
    sort -u > "$REPO/packages/aur.txt"

echo "Synced. Review with:  git -C \"$REPO\" status"
