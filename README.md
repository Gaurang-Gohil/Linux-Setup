# Linux-Setup

My Arch Linux + Hyprland desktop: [JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland) dots with the
[Hyprlust](https://github.com/NischalDawadi/Hyprlust) look, converted to the **Hyprland 0.57 Lua config**, plus my own
pickers, keybinds, lock screen, bar and notification styling.

## Install on a fresh Arch

```bash
git clone https://github.com/Gaurang-Gohil/Linux-Setup.git ~/Linux-Setup
cd ~/Linux-Setup
bash install.sh
```

The script asks before each big step. It:

1. installs every package from `packages/pacman.txt` and `packages/aur.txt` (fonts, apps, Hyprland tools; installs `yay` if missing)
2. backs up your current `~/.config/<app>` folders to `~/.config-backup-linux-setup-<date>`
3. copies `config/` into `~/.config`, the `wallust` wrapper into `~/.local/bin`, GTK themes into `~/.themes`, wallpapers into `~/Pictures/wallpapers`
4. sets GTK theme (Flat-Remix-GTK-Blue-Dark), icons (Flat-Remix-Blue-Dark), cursor (Bibata-Modern-Ice), dark mode, text scale 1.1
5. generates colors from the locked wallust theme **3024-dark**
6. optionally makes **fish** the login shell and installs the **SDDM** login screen (simple_sddm_2)

Then reboot and choose Hyprland.

## Save changes back to the repo

```bash
cd ~/Documents/Linux-Setup
bash sync.sh                      # copies the current setup + package lists into the repo
git add -A && git commit -m "update setup" && git push
```

## What's inside

| Path | What |
|---|---|
| `config/hypr/hyprland.lua`, `config/hypr/lua/` | Hyprland config (Lua): colors, settings, animations, autostart, keybinds, window rules, `user.lua` |
| `config/hypr/hyprlock.conf`, `hypridle.conf` | lock screen and idle/sleep |
| `config/hypr/scripts/` | pickers (theme, wallpaper effects, waybar, animations, rofi, kitty, SDDM), lock-screen info, etc. |
| `config/waybar/` | bar layouts/styles, scrolling media module |
| `config/swaync/` | notification center |
| `config/rofi/`, `config/kitty/`, `config/wallust/`, `config/quickshell/` | launcher, terminal, color theming, overview |
| `config/fish/`, `config/starship.toml` | shell |
| `packages/` | package lists (`pacman -Qqen`, `pacman -Qqem`) |
| `home/themes/` | GTK themes |
| `system/sddm/` | login screen theme + `/etc/sddm.conf` |
| `wallpapers/` | wallpapers (only files under 3 MB; the full collection is too big for git) |

## Main shortcuts

| Keys | Action |
|---|---|
| `SUPER` (tap) | app launcher |
| `SUPER+H` | cheat sheet of all shortcuts · `SUPER+SHIFT+K` searchable keybinds |
| `SUPER+Return` | terminal · `SUPER+SHIFT+Return` dropdown terminal |
| `SUPER+S` | show/hide scratchpad (full screen) · `SUPER+SHIFT+U` send window there |
| `SUPER+F` / `SUPER+D` | fullscreen / maximize |
| `SUPER+V` · `SUPER+N` · `SUPER+P` · `SUPER+L` | clipboard · notifications · power menu · lock |
| `SUPER+T` | global color theme picker |
| `SUPER+W` · `SUPER+SHIFT+W` | wallpaper · wallpaper effects |
| `SUPER+CTRL+B` · `SUPER+ALT+B` | waybar style · waybar layout |
| `SUPER+SHIFT+A` | animation presets |
| `SUPER+CTRL+R` | rofi theme picker |
| `SUPER+SHIFT+E` | quick settings (kitty theme, SDDM theme, …) |
| `SUPER+A` | workspace overview |

## Notes

- Hardware this was made on: ASUS Vivobook (Intel + RTX 3050), 1920x1200 @ 144 Hz. Change the monitor in `config/hypr/lua/monitors.lua`.
- NVIDIA drivers are not included; use JaKooLit's `install-scripts/nvidia.sh` if needed.
- Check the config after editing: `Hyprland --verify-config`, apply with `hyprctl reload`.
