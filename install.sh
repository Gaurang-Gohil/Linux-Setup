#!/usr/bin/env bash
# Restores this Hyprland setup on a fresh Arch Linux install.
#   git clone https://github.com/Gaurang-Gohil/Linux-Setup.git ~/Linux-Setup
#   cd ~/Linux-Setup && bash install.sh
# Run as your normal user (not root). It asks for your sudo password when needed,
# and asks before each big step. Your existing configs are backed up first.

set -uo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
STAMP=$(date +%F-%H%M%S)
BACKUP="$HOME/.config-backup-linux-setup-$STAMP"

BOLD=$'\e[1m'; GRN=$'\e[32m'; YLW=$'\e[33m'; RED=$'\e[31m'; RST=$'\e[0m'
step() { echo; echo "${BOLD}${GRN}==> $*${RST}"; }
warn() { echo "${YLW}!! $*${RST}"; }
die()  { echo "${RED}xx $*${RST}" >&2; exit 1; }
ask()  { local r; read -rp "${BOLD}$1 [Y/n] ${RST}" r; [[ ! $r =~ ^[Nn]$ ]]; }

[[ $EUID -eq 0 ]] && die "Don't run this as root. Run it as your user; it uses sudo when needed."
command -v pacman >/dev/null || die "This script is for Arch Linux (pacman not found)."

# ---------------------------------------------------------------- 1. packages
if ask "Install all packages (pacman + AUR)? This also updates the system."; then
    step "Updating the system and installing official packages"
    sudo pacman -Syu --needed git base-devel
    # skip names that don't exist in the repos any more, instead of failing the whole install
    mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$REPO/packages/pacman.txt")
    mapfile -t AVAIL < <(comm -12 <(printf '%s\n' "${PKGS[@]}" | sort -u) <(pacman -Slq | sort -u))
    MISSING=$(comm -23 <(printf '%s\n' "${PKGS[@]}" | sort -u) <(printf '%s\n' "${AVAIL[@]}" | sort -u))
    sudo pacman -S --needed "${AVAIL[@]}"
    [[ -n $MISSING ]] && warn "Not in the official repos (will try AUR): $(echo $MISSING)"

    if ! command -v yay >/dev/null; then
        step "Installing yay (AUR helper)"
        tmp=$(mktemp -d)
        git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" &&
            (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp"
    fi
    step "Installing AUR packages"
    mapfile -t AUR < <(grep -vE '^\s*(#|$)' "$REPO/packages/aur.txt"; printf '%s\n' $MISSING)
    yay -S --needed "${AUR[@]}" || warn "Some AUR packages failed; re-run: yay -S --needed \$(cat packages/aur.txt)"
fi

# ---------------------------------------------------------------- 2. configs
step "Backing up your current configs to $BACKUP"
mkdir -p "$BACKUP"
for item in "$REPO"/config/* "$REPO"/config/.[!.]*; do
    [[ -e $item ]] || continue
    name=$(basename "$item")
    [[ -e $HOME/.config/$name ]] && cp -a "$HOME/.config/$name" "$BACKUP/"
done
[[ -e $HOME/.local/bin/wallust ]] && mkdir -p "$BACKUP/local-bin" && cp -a "$HOME/.local/bin/wallust" "$BACKUP/local-bin/"
echo "Restore later with:  cp -a $BACKUP/* ~/.config/"

step "Copying configs into ~/.config"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
for item in "$REPO"/config/*; do
    name=$(basename "$item")
    rm -rf "$HOME/.config/$name"
    cp -a "$item" "$HOME/.config/$name"
done
cp -a "$REPO/local/bin/." "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"* "$HOME"/.config/hypr/scripts/* "$HOME"/.config/hypr/UserScripts/* \
         "$HOME"/.config/waybar/scripts/* 2>/dev/null
# paths saved with the original username
grep -rlI "/home/ronie" "$HOME/.config/qt5ct" "$HOME/.config/qt6ct" 2>/dev/null |
    xargs -r sed -i "s|/home/ronie|$HOME|g"

step "Copying GTK themes (~/.themes) and wallpapers (~/Pictures/wallpapers)"
mkdir -p "$HOME/.themes" "$HOME/Pictures/wallpapers"
cp -a "$REPO/home/themes/." "$HOME/.themes/"
cp -n "$REPO/wallpapers/"* "$HOME/Pictures/wallpapers/"

# ---------------------------------------------------------------- 3. look & feel
step "Applying GTK theme, icons, cursor and fonts"
gsettings set org.gnome.desktop.interface gtk-theme      'Flat-Remix-GTK-Blue-Dark'
gsettings set org.gnome.desktop.interface icon-theme     'Flat-Remix-Blue-Dark'
gsettings set org.gnome.desktop.interface cursor-theme   'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface color-scheme   'prefer-dark'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.1
fc-cache -f >/dev/null

step "Generating theme colors (wallust theme 3024-dark, locked)"
if command -v wallust >/dev/null; then
    /usr/bin/wallust theme 3024-dark -q || warn "wallust failed; press SUPER+T after logging in to pick a theme"
else
    warn "wallust not installed; press SUPER+T after logging in to pick a theme"
fi
WALL="$HOME/Pictures/wallpapers/Buildings.png"
mkdir -p "$HOME/.config/hypr/wallpaper_effects"
[[ -f $WALL ]] && cp "$WALL" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current" &&
    ln -sfn "$WALL" "$HOME/.config/rofi/.current_wallpaper"

# ---------------------------------------------------------------- 4. shell
if [[ $(getent passwd "$USER" | cut -d: -f7) != */fish ]] && command -v fish >/dev/null; then
    ask "Make fish your login shell?" && chsh -s "$(command -v fish)"
fi

# ---------------------------------------------------------------- 5. login screen
if ask "Install the SDDM login screen (simple_sddm_2) and make SDDM the login manager?"; then
    sudo mkdir -p /usr/share/sddm/themes
    sudo cp -a "$REPO/system/sddm/simple_sddm_2" /usr/share/sddm/themes/
    sudo cp "$REPO/system/sddm/sddm.conf" /etc/sddm.conf
    for dm in gdm lightdm ly; do
        systemctl is-enabled "$dm" &>/dev/null && sudo systemctl disable "$dm"
    done
    sudo systemctl enable sddm
fi

step "Done!"
cat <<EOF
Reboot, pick Hyprland at the login screen, and you're home.
  SUPER+H   cheat sheet of all shortcuts
  SUPER+T   theme picker        SUPER+W  wallpaper
Your old configs are in: $BACKUP
EOF
